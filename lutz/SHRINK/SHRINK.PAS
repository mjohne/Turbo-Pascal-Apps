Program Shrinker;

{$M 10240, 0, 0}
{$F+}

{ Shrink.Pas version 1.2  (C) Copyright 1989 by R. P. Byrne                   }
{                                                                             }
{   Compress a set of input files into a Zip file using Lempel-Ziv-Welch      }
{   (LZW) compression techniques (the "shrink" method).                       }

Uses  Dos,
      Crt,
      MemAlloc,
      StrProcs;

Const
   CopyRight = 'Shrink (C) Copyright 1989 by R. P. Byrne';
   Version   = 'Version 1.2 - Compiled on March 11, 1989';

Const

   BUFSIZE     =  10240;   { Use 10K file buffers                             }
   MINBITS     =      9;   { Starting code size of 9 bits                     }
   MAXBITS     =     13;   { Maximum code size of 13 bits                     }
   TABLESIZE   =   8191;   { We'll need 4K entries in table                   }
   SPECIAL     =    256;   { Special function code                            }
   INCSIZE     =      1;   { Code indicating a jump in code size              }
   CLEARCODE   =      2;   { Code indicating code table has been cleared      }
   FIRSTENTRY  =    257;   { First available table entry                      }
   UNUSED      =     -1;   { Prefix indicating an unused code table entry     }

   STDATTR     =    $23;   { Standard file attribute for DOS Find First/Next  }

Const
   LOCAL_FILE_HEADER_SIGNATURE = $04034B50;

Type
   Local_File_Header_Type = Record
                               Signature              :  LongInt;
                               Extract_Version_Reqd   :  Word;
                               Bit_Flag               :  Word;
                               Compress_Method        :  Word;
                               Last_Mod_Time          :  Word;
                               Last_Mod_Date          :  Word;
                               Crc32                  :  LongInt;
                               Compressed_Size        :  LongInt;
                               Uncompressed_Size      :  LongInt;
                               Filename_Length        :  Word;
                               Extra_Field_Length     :  Word;
                            end;

{ Define the Central Directory record types }

Const
   CENTRAL_FILE_HEADER_SIGNATURE = $02014B50;

Type
   Central_File_Header_Type = Record
                                 Signature            :  LongInt;
                                 MadeBy_Version       :  Word;
                                 Extract_Version_Reqd :  Word;
                                 Bit_Flag             :  Word;
                                 Compress_Method      :  Word;
                                 Last_Mod_Time        :  Word;
                                 Last_Mod_Date        :  Word;
                                 Crc32                :  LongInt;
                                 Compressed_Size      :  LongInt;
                                 Uncompressed_Size    :  LongInt;
                                 Filename_Length      :  Word;
                                 Extra_Field_Length   :  Word;
                                 File_Comment_Length  :  Word;
                                 Starting_Disk_Num    :  Word;
                                 Internal_Attributes  :  Word;
                                 External_Attributes  :  LongInt;
                                 Local_Header_Offset  :  LongInt;
                              End;

Const
   END_OF_CENTRAL_DIR_SIGNATURE = $06054B50;

Type
   End_of_Central_Dir_Type =  Record
                                 Signature               :  LongInt;
                                 Disk_Number             :  Word;
                                 Central_Dir_Start_Disk  :  Word;
                                 Entries_This_Disk       :  Word;
                                 Total_Entries           :  Word;
                                 Central_Dir_Size        :  LongInt;
                                 Start_Disk_Offset       :  LongInt;
                                 ZipFile_Comment_Length  :  Word;
                              end;

Const
   Crc_32_Tab : Array[0..255] of LongInt = (
$00000000, $77073096, $ee0e612c, $990951ba, $076dc419, $706af48f, $e963a535, $9e6495a3,
$0edb8832, $79dcb8a4, $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd, $e7b82d07, $90bf1d91,
$1db71064, $6ab020f2, $f3b97148, $84be41de, $1adad47d, $6ddde4eb, $f4d4b551, $83d385c7,
$136c9856, $646ba8c0, $fd62f97a, $8a65c9ec, $14015c4f, $63066cd9, $fa0f3d63, $8d080df5,
$3b6e20c8, $4c69105e, $d56041e4, $a2677172, $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b,
$35b5a8fa, $42b2986c, $dbbbc9d6, $acbcf940, $32d86ce3, $45df5c75, $dcd60dcf, $abd13d59,
$26d930ac, $51de003a, $c8d75180, $bfd06116, $21b4f4b5, $56b3c423, $cfba9599, $b8bda50f,
$2802b89e, $5f058808, $c60cd9b2, $b10be924, $2f6f7c87, $58684c11, $c1611dab, $b6662d3d,
$76dc4190, $01db7106, $98d220bc, $efd5102a, $71b18589, $06b6b51f, $9fbfe4a5, $e8b8d433,
$7807c9a2, $0f00f934, $9609a88e, $e10e9818, $7f6a0dbb, $086d3d2d, $91646c97, $e6635c01,
$6b6b51f4, $1c6c6162, $856530d8, $f262004e, $6c0695ed, $1b01a57b, $8208f4c1, $f50fc457,
$65b0d9c6, $12b7e950, $8bbeb8ea, $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3, $fbd44c65,
$4db26158, $3ab551ce, $a3bc0074, $d4bb30e2, $4adfa541, $3dd895d7, $a4d1c46d, $d3d6f4fb,
$4369e96a, $346ed9fc, $ad678846, $da60b8d0, $44042d73, $33031de5, $aa0a4c5f, $dd0d7cc9,
$5005713c, $270241aa, $be0b1010, $c90c2086, $5768b525, $206f85b3, $b966d409, $ce61e49f,
$5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17, $2eb40d81, $b7bd5c3b, $c0ba6cad,
$edb88320, $9abfb3b6, $03b6e20c, $74b1d29a, $ead54739, $9dd277af, $04db2615, $73dc1683,
$e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8, $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1,
$f00f9344, $8708a3d2, $1e01f268, $6906c2fe, $f762575d, $806567cb, $196c3671, $6e6b06e7,
$fed41b76, $89d32be0, $10da7a5a, $67dd4acc, $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5,
$d6d6a3e8, $a1d1937e, $38d8c2c4, $4fdff252, $d1bb67f1, $a6bc5767, $3fb506dd, $48b2364b,
$d80d2bda, $af0a1b4c, $36034af6, $41047a60, $df60efc3, $a867df55, $316e8eef, $4669be79,
$cb61b38c, $bc66831a, $256fd2a0, $5268e236, $cc0c7795, $bb0b4703, $220216b9, $5505262f,
$c5ba3bbe, $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7, $b5d0cf31, $2cd99e8b, $5bdeae1d,
$9b64c2b0, $ec63f226, $756aa39c, $026d930a, $9c0906a9, $eb0e363f, $72076785, $05005713,
$95bf4a82, $e2b87a14, $7bb12bae, $0cb61b38, $92d28e9b, $e5d5be0d, $7cdcefb7, $0bdbdf21,
$86d3d2d4, $f1d4e242, $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1, $18b74777,
$88085ae6, $ff0f6a70, $66063bca, $11010b5c, $8f659eff, $f862ae69, $616bffd3, $166ccf45,
$a00ae278, $d70dd2ee, $4e048354, $3903b3c2, $a7672661, $d06016f7, $4969474d, $3e6e77db,
$aed16a4a, $d9d65adc, $40df0b66, $37d83bf0, $a9bcae53, $debb9ec5, $47b2cf7f, $30b5ffe9,
$bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605, $cdd70693, $54de5729, $23d967bf,
$b3667a2e, $c4614ab8, $5d681b02, $2a6f2b94, $b40bbe37, $c30c8ea1, $5a05df1b, $2d02ef8d
);

Type

   { Define data types needed to implement a code table for LZW compression   }
   CodeRec     =  Record                { Code Table record format...         }
                     Child   : Integer; { Addr of 1st suffix for this prefix  }
                     Sibling : Integer; { Addr of next suffix in chain        }
                     Suffix  : Byte;    { Suffix character                    }
                  end {CodeRec};
   CodeArray   =  Array[0..TABLESIZE] of CodeRec; { Define the code table     }
   TablePtr    =  ^CodeArray;                     { Allocate dynamically      }

   { Define data types needed to implement a free node list                   }
   FreeListPtr    =  ^FreeListArray;
   FreeListArray  =  Array[FIRSTENTRY..TABLESIZE] of Word;

   { Define data types needed to implement input and output file buffers      }
   BufArray    =  Array[1..BUFSIZE] of byte;
   BufPtr      =  ^BufArray;

   { Define the structure of a DOS Disk Transfer Area (DTA)                   }
   DTARec      =  Record         
                     Filler   :  Array[1..21] of Byte;
                     Attr     :  Byte;
                     Time     :  Word;
                     Date     :  Word;
                     Size     :  LongInt;
                     Name     :  String[12];
                  end {DtaRec};

   { Define data types needed to implement a sorted singly linked list to     }
   { hold the names of all files to be compressed                             }
   NameStr      = String[12];
   PathStr      = String[64];
   NodePtr      = ^NameList;
   NameList     = Record                  { Linked list node structure...     }
                     Path : PathStr;      { Path of input file                }
                     Name : NameStr;      { Name of input file                }
                     Size : LongInt;      { Size in bytes of input file       }
                     Date : Word;         { Date stamp of input file          }
                     Time : Word;         { Time stamp of input file          }
                     Next : NodePtr;      { Next node in linked list          }
                  end {NameList};

Var
   InFileSpecs :  Array[1..20] of String;    { Input file specifications      }
   MaxSpecs    :  Word;          { Total number of filespecs to be Zipped     }
   OutFileName :  String;        { Name of resulting Zip file                 }

   InFile,                       { I/O file variables                         }
   OutFile     :  File;

   InBuf,                        { I/O buffers                                }
   OutBuf      :  BufPtr;
   InBufIdx,                     { Points to next char in buffer to be read   }
   OutBufIdx   :  Word;          { Points to next free space in output buffer }
   MaxInBufIdx :  Word;          { Count of valid chars in input buffer       }

   InputEof    :  Boolean;       { End of file indicator                      }

   Crc32Val    :  LongInt;       { CRC calculation variable                   }
   CodeTable   :  TablePtr;      { Points to code table for LZW compression   }

   FreeList    :  FreeListPtr;   { Table of free code table entries           }
   NextFree    :  Word;          { Index into free list table                 }

   ClearList   :  Array[0..1023] of Byte;  { Bit mapped structure used in     }
                                           {    during adaptive resets        }
   CodeSize    :  Byte;     { Size of codes (in bits) currently being written }
   MaxCode     :  Word;   { Largest code that can be written in CodeSize bits }

   LocalHdr    :  Local_File_Header_Type;
   LocalHdrOfs :  LongInt;  { Offset within output file of the local header   }
   CentralHdr  :  Central_File_Header_Type;
   EndHdr      :  End_of_Central_Dir_Type;

   FirstCh     :  Boolean;  { Flag indicating the START of a shrink operation }
   TableFull   :  Boolean;  { Flag indicating a full symbol table             }

   SaveByte    :  Byte;     { Output code buffer                              }
   BitsUsed    :  Byte;     { Index into output code buffer                   }

   BytesIn     :  LongInt;  { Count of input file bytes processed             }
   BytesOut    :  LongInt;  { Count of output bytes                           }

   ListHead    :  NodePtr;  { Pointer to head of linked list                  }

   TenPercent  :  LongInt;

{ --------------------------------------------------------------------------- }
{ Houskeeping stuff (error routines and initialization of program variables)  }
{ --------------------------------------------------------------------------- }

Procedure Syntax;
Begin
   Writeln('Shrink.Exe');
   Writeln('   Usage:   Shrink zipfilename [filespec [...]]');
   Writeln;
   Writeln('   A filespec is defined as [d:][\path\]name');
   Writeln('   where ''name'' may contain DOS wildcard characters.');
   Writeln;
   Writeln('   Multiple filespecs may be entered up to a maximum of 20.');
   Writeln;
   Writeln('   If no filespecs are entered, *.* is assumed.');
   Writeln;
   Halt(255);
end {Syntax};

{ --------------------------------------------------------------------------- }

Procedure Fatal(Msg : String);
Begin
   Writeln;
   Writeln;
   Writeln('Shrink.Exe');
   Writeln('   Error: ', Msg);
   Writeln('   Program halted');
   Writeln;
   Writeln;
   Halt(128);
end {Fatal};

{ --------------------------------------------------------------------------- }

Procedure AddToList(PathSpec : PathStr; DTA : DTARec);
{ Add an entry to a linked list of filenames to be crunched.  Maintain        }
{ sorted order (standard ASCII collating sequence) by filename                }
Var
   MemError : Word;
   NewNode  : NodePtr;
   Done     : Boolean;
   ListNode : NodePtr;
Begin
   { Allocate a new node                                                      }
   MemError := Malloc(NewNode, SizeOf(NewNode^));
   If MemError <> 0 then
      Fatal('Not enough memory to process all filenames!');

   { Populate the fields of the new node                                      }
   NewNode^.Path := PathSpec;
   NewNode^.Name := DTA.Name;
   NewNode^.Size := DTA.Size;
   NewNode^.Date := DTA.Date;
   NewNode^.Time := DTA.Time;
   NewNode^.Next := NIL;

   { Find the proper location in the list at which to insert the new node     }
   If ListHead = NIL then
      ListHead := NewNode
   else
      If DTA.Name < ListHead^.Name then begin
         NewNode^.Next := ListHead;
         ListHead      := NewNode;
      end {then}
      else begin
         Done     := FALSE;
         ListNode := ListHead;
         While NOT Done do begin
            If ListNode^.Name = DTA.Name then begin
               ListNode^.Path := PathSpec;
               MemError := Dalloc(NewNode);
               Done := TRUE;
            end {then}
            else
               If ListNode^.Next = NIL then begin
                  ListNode^.Next := NewNode;
                  Done := TRUE;
               end {then}
               else
                  If ListNode^.Next^.Name > DTA.Name then begin
                     NewNode^.Next  := ListNode^.Next;
                     ListNode^.Next := NewNode;
                     Done := TRUE;
                  end {then}
                  else
                     ListNode := ListNode^.Next;
         end {while};
      end {if};
end {AddToList};

{ --------------------------------------------------------------------------- }

Procedure GetNames;
{ Expand input file specifications.  Store the name of each file to be        }
{ compressed in a sorted, singly linked list                                  }
Var
   DosDTA   : DTARec;
   I        : Word;
   InPath   : String;
Begin
   ListHead := NIL;
   For I := 1 to MaxSpecs do begin   { Loop through all input file specs      }
      InPath := Upper(PathOnly(InFileSpecs[I]));
      FindFirst(InFileSpecs[I], STDATTR, SearchRec(DosDTA));
      While DosError = 0 do begin    { Loop through all matching files        }
         If (NOT SameFile(InPath + DosDTA.Name, OutFileName)) then
            AddToList(InPath, DosDTA);
         FindNext(SearchRec(DosDTA));
      end {while};
   end {for};
end {GetNames};

{ --------------------------------------------------------------------------- }

Function ParamCheck : Boolean;
{ Verify all command line parameters                                          }
Var
   SearchBuf : SearchRec;
   OutPath   : String;
   Ch        : Char;
   I         : Word;
Begin

   If ParamCount < 1 then Syntax;
   If ParamCount > 21 then begin
      Writeln('Too many command line parameters entered!');
      Syntax;
   end {if};

   OutFileName := Upper(ParamStr(1));
   If Pos('.', OutFileName) = 0 then
      OutFileName := Concat(OutFileName, '.ZIP');

   FindFirst(OutFileName, STDATTR, SearchBuf);
   If DosError = 0 then begin
      Write(OutFileName, ' already exists!  Overwrite it (Y/N, Enter=N)? ');
      Ch := ReadKey;
      Writeln(Ch);
      Writeln;
      If UpCase(Ch) <> 'Y' then begin
         Writeln;
         Writeln('Program aborted!');
         Halt;
      end {if};
   end {if};

   If ParamCount = 1 then begin
      InFileSpecs[1] := '*.*';
      MaxSpecs := 1;
   end {then}
   else
      For I := 2 to ParamCount do begin
         InFilespecs[Pred(I)] := ParamStr(I);
         MaxSpecs := Pred(I);
      end {for};

   GetNames;

End {ParamCheck};

{ --------------------------------------------------------------------------- }
{ Running 32 Bit CRC update function                                          }
{ --------------------------------------------------------------------------- }

Function UpdC32(Octet: Byte; Crc: LongInt) : LongInt;
Var
   L : LongInt;
   W : Array[1..4] of Byte Absolute L;
Begin

   UpdC32 := Crc_32_Tab[Byte(Crc XOR LongInt(Octet))] XOR ((Crc SHR 8) AND $00FFFFFF);

end {UpdC32};

{ --------------------------------------------------------------------------- }
{ I/O Support routines                                                        }
{ --------------------------------------------------------------------------- }

Procedure GetBuffers;
{ Allocate Input and Output buffers                                           }
Var
   MemError : Word;
Begin
   MemError := Malloc(InBuf, Sizeof(InBuf^));
   If MemError <> 0 then
      Fatal(Concat('Cannot allocate Input buffer',
                   #13#10,
                   '           DOS Return Code on allocation request was ',
                   IntStr(MemError, 0)));

   MemError := Malloc(OutBuf, Sizeof(OutBuf^));
   If MemError <> 0 then
      Fatal(Concat('Cannot allocate Output buffer',
                   #13#10,
                   '           DOS Return Code on allocation request was ',
                   IntStr(MemError, 0)));
End {GetBuffers};

{ --------------------------------------------------------------------------- }

Procedure DropBuffers;
{ Deallocate input and output buffers                                         }
Var
   MemError : Word;
Begin
   MemError := Dalloc(InBuf);
   MemError := Dalloc(OutBuf);
end {DropBuffers};

{ --------------------------------------------------------------------------- }

Procedure OpenOutput;
Var
   RC : Integer;
Begin
   Assign(OutFile, OutFileName);
   FileMode := 66;
   {$I-} ReWrite(OutFile, 1); {$I+}
   RC := IOResult;
   If RC <> 0 then
      Fatal(Concat('Cannot open output file',
                   #13#10,
                   '           Return Code was ',
                   IntStr(RC, 0)));
End {OpenOutput};

{ --------------------------------------------------------------------------- }

Function OpenInput(InFileName : String) : Boolean;
Var
   RC : Integer;
Begin
   Assign(InFile, InFileName);
   FileMode := 64;
   {$I-} Reset(InFile, 1); {$I+}
   OpenInput := (IOResult = 0);
End {OpenInput};

{ --------------------------------------------------------------------------- }

Procedure CloseOutput;
Var
   RC : Integer;
Begin
   {$I-} Close(OutFile) {$I+};
   RC := IOResult;
end {CloseOutput};

{ --------------------------------------------------------------------------- }

Procedure CloseInput;
Var
   RC : Integer;
Begin
   {$I-} Close(InFile)  {$I+};
   RC := IOResult;
end {CloseInput};

{ --------------------------------------------------------------------------- }

Procedure Read_Block;
{ Read a "block" of data into our our input buffer                            }
Begin
   BlockRead(InFile, InBuf^[1], SizeOf(InBuf^), MaxInBufIdx);
   If MaxInBufIdx = 0 then
      InputEof := TRUE
   else
      InputEOF := FALSE;
   InBufIdx := 1;
end {Read_Block};

{ --------------------------------------------------------------------------- }

Procedure Write_Block;
{ Write a block of data from the output buffer to our output file             }
Begin
   BlockWrite(OutFile, OutBuf^[1], Pred(OutBufIdx));
   OutBufIdx := 1;
end {Write_Block};

{ --------------------------------------------------------------------------- }

Procedure PutChar(B : Byte);
{ Put one character into our output buffer                                    }
Begin
   OutBuf^[OutBufIdx] := B;
   Inc(OutBufIdx);
   If OutBufIdx > SizeOf(OutBuf^) then
      Write_Block;
   Inc(BytesOut);
end {PutChar};

{ --------------------------------------------------------------------------- }

Procedure FlushOutput;
{ Write any data sitting in our output buffer to the output file              }
Begin
   If OutBufIdx > 1 then
      Write_Block;
End {FlushOutput};

{ --------------------------------------------------------------------------- }

Procedure PutCode(Code : Integer);
{ Assemble coded bytes for output                                             }
Var
   PutCharAddr : Pointer;
Begin
   PutCharAddr := @PutChar;

   Inline(
                            {;  Register useage:}
                            {;}
                            {;  AX - holds Code}
                            {;  BX - BH is a work register, BL holds SaveByte}
                            {;  CX - holds our loop counter CodeSize}
                            {;  DX - holds BitsUsed}
                            {;}
     $8B/$46/<Code/         {                mov         ax,[bp+<Code]}
     $31/$DB/               {                xor         bx,bx}
     $89/$D9/               {                mov         cx,bx}
     $89/$DA/               {                mov         dx,bx}
     $8A/$1E/>SaveByte/     {                mov         bl,[>SaveByte]}
     $8A/$0E/>CodeSize/     {                mov         cl,[>CodeSize]}
     $8A/$16/>BitsUsed/     {                mov         dl,[>BitsUsed]}
     $3D/$FF/$FF/           {                cmp         ax,-1               ;Any work to do?}
     $75/$0D/               {                jnz         Repeat              ;Yup, go do it}
     $80/$FA/$00/           {                cmp         dl,0                ;Any leftovers?}
     $74/$3A/               {                jz          AllDone             ;Nope, we're done}
     $53/                   {                push        bx                  ;Yup...push leftovers}
     $0E/                   {                push        cs}
     $FF/$96/>PutCharAddr/  {                call        [bp+>PutCharAddr]   ;   and send to output}
     $EB/$32/               {                jmp short   AllDone}
                            {;}
     $30/$FF/               {Repeat:         xor         bh,bh               ;Zero out BH}
     $D1/$D8/               {                rcr         ax,1                ;Get low order bit into CY flag}
     $73/$02/               {                jnc         SkipBit             ;Was the bit set?}
     $FE/$C7/               {                inc         bh                  ;Yes, xfer to BH}
     $87/$D1/               {SkipBit:        xchg        cx,dx               ;Swap CX & DX}
     $D2/$E7/               {                shl         bh,cl               ;Shift bit over}
     $87/$D1/               {                xchg        cx,dx               ;Put CX & DX back where they were}
     $42/                   {                inc         dx                  ;Bump count of bit positions used}
     $08/$FB/               {                or          bl,bh               ;Transfer bit to output byte (SaveByte)}
     $83/$FA/$08/           {                cmp         dx,8                ;Full byte yet?}
     $72/$12/               {                jb          GetNext             ;Nope, go get more code bits}
     $50/                   {                push        ax                  ;Yup, save regs in preparation}
     $53/                   {                push        bx                  ;    for call to output routine}
     $51/                   {                push        cx}
     $52/                   {                push        dx}
     $53/                   {                push        bx                  ;Push byte to output onto stack}
     $0E/                   {                push        cs}
     $FF/$96/>PutCharAddr/  {                call        [bp+>PutCharAddr]   ;   and call the output routine}
     $5A/                   {                pop         dx}
     $59/                   {                pop         cx}
     $5B/                   {                pop         bx}
     $58/                   {                pop         ax}
     $31/$DB/               {                xor         bx,bx               ;Prepare SaveByte for next byte}
     $89/$DA/               {                mov         dx,bx               ;Set BitsUsed to zero}
     $E2/$D6/               {GetNext:        loop        Repeat              ;Repeat for all code bits}
                            {;}
     $88/$1E/>SaveByte/     {                mov         [>SaveByte],bl      ;Put SaveByte and BitsUsed}
     $88/$16/>BitsUsed);    {                mov         [>BitsUsed],dl      ;   back in memory}
                            {;}
                            {AllDone:}
   
end {Putcode};

{ --------------------------------------------------------------------------- }
{ The following routines are used to allocate, initialize, and de-allocate    }
{ various dynamic memory structures used by the LZW compression algorithm     }
{ --------------------------------------------------------------------------- }

Procedure Build_Data_Structures;
Var
   Code  :  Word;
Begin
   Code  := Malloc(CodeTable, SizeOf(CodeTable^)) OR
            Malloc(FreeList,  SizeOf(FreeList^ ));
   If Code <> 0 then
      Fatal('Not enough memory to allocate LZW data structures!');
end {Build_Data_Structures};

{ --------------------------------------------------------------------------- }

Procedure Destroy_Data_Structures;
Var
   Code  :  Word;
Begin
   Code := Dalloc(CodeTable);
   Code := Dalloc(FreeList);
end {Destroy_Data_Structures};

{ --------------------------------------------------------------------------- }

Procedure Initialize_Data_Structures;
Var
   I  :  Word;
Begin
   For I := 0 to TableSize do begin
      With CodeTable^[I] do begin
         Child     := -1;
         Sibling   := -1;
         If I <= 255 then
            Suffix := I;
      end {with};
      If I >= 257 then
         FreeList^[I] := I;
   end {for};

   NextFree  := FIRSTENTRY;
   TableFull := FALSE;

end {Initialize_Data_Structures};

{ --------------------------------------------------------------------------- }
{ The following routines handle manipulation of the LZW Code Table            }
{ --------------------------------------------------------------------------- }

Procedure Prune(Parent : Word);
{ Prune leaves from a subtree - Note: this is a recursive procedure }
Var
   CurrChild   : Integer;
   NextSibling : Integer;
Begin
   CurrChild := CodeTable^[Parent].Child;
   { Find first Child that has descendants .. clear any that don't }
   While (CurrChild <> -1) AND (CodeTable^[CurrChild].Child = -1) do begin
      CodeTable^[Parent].Child := CodeTable^[CurrChild].Sibling;
      CodeTable^[CurrChild].Sibling := -1;
      { Turn on ClearList bit to indicate a cleared entry }
      ClearList[CurrChild DIV 8] := (ClearList[CurrChild DIV 8] OR (1 SHL (CurrChild MOD 8)));
      CurrChild := CodeTable^[Parent].Child;
   end {while};

   If CurrChild <> -1 then begin   { If there are any children left ...}
      Prune(CurrChild);
      NextSibling := CodeTable^[CurrChild].Sibling;
      While NextSibling <> -1 do begin
         If CodeTable^[NextSibling].Child = -1 then begin
            CodeTable^[CurrChild].Sibling := CodeTable^[NextSibling].Sibling;
            CodeTable^[NextSibling].Sibling := -1;
            { Turn on ClearList bit to indicate a cleared entry }
            ClearList[NextSibling DIV 8] := (ClearList[NextSibling DIV 8] OR (1 SHL (NextSibling MOD 8)));
            NextSibling := CodeTable^[CurrChild].Sibling;
         end {then}
         else begin
            CurrChild := NextSibling;
            Prune(CurrChild);
            NextSibling := CodeTable^[CurrChild].Sibling;
         end {if};
      end {while};
   end {if};

end {Prune};

{ --------------------------------------------------------------------------- }

Procedure Clear_Table;
Var
   Node : Word;
Begin
   FillChar(ClearList, SizeOf(ClearList), $00);
   { Remove all leaf nodes by recursively pruning subtrees}
   For Node := 0 to 255 do
      Prune(Node);
   { Next, re-initialize our list of free table entries }
   NextFree := Succ(TABLESIZE);
   For Node := TABLESIZE downto FIRSTENTRY do begin
      If (ClearList[Node DIV 8] AND (1 SHL (Node MOD 8))) <> 0 then begin
         Dec(NextFree);
         FreeList^[NextFree] := Node;
      end {if};
   end {for};
   If NextFree <= TABLESIZE then
      TableFull := FALSE;
end {Clear_Table};

{ --------------------------------------------------------------------------- }

Procedure Table_Add(Prefix : Word; Suffix : Byte);
Var
   FreeNode : Word;
Begin
   If NextFree <= TABLESIZE then begin
      FreeNode := FreeList^[NextFree];
      Inc(NextFree);
      CodeTable^[FreeNode].Child := -1;
      CodeTable^[FreeNode].Sibling := -1;
      CodeTable^[FreeNode].Suffix := Suffix;
      If CodeTable^[Prefix].Child  = -1 then
         CodeTable^[Prefix].Child := FreeNode
      else begin
         Prefix := CodeTable^[Prefix].Child;
         While CodeTable^[Prefix].Sibling <> -1 do
            Prefix := CodeTable^[Prefix].Sibling;
         CodeTable^[Prefix].Sibling := FreeNode;
      end {if};
   end {if};

   If NextFree > TABLESIZE then
      TableFull := TRUE;
end {Table_Add};

{ --------------------------------------------------------------------------- }

Function Table_Lookup(    TargetPrefix : Integer;
                          TargetSuffix : Byte;
                      Var FoundAt      : Integer   ) : Boolean;
{ --------------------------------------------------------------------------- }
{ Search for a Prefix:Suffix pair in our Symbol table.  If found, return the  }
{ index value where found.  If not found, return FALSE and set the VAR parm   }
{ FoundAt to -1.                                                              }
{ --------------------------------------------------------------------------- }
Begin
   Inline(
                            {;}
                            {; Lookup an entry in the Hash Table.  If found, return TRUE and set the VAR}
                            {; parameter FoundAt with the index of the entry at which the match was found.}
                            {; If not found, return FALSE and plug a -1 into the FoundAt var.}
                            {;}
                            {;}
                            {; Register usage:}
                            {;   AX - varies                     BL - holds target suffix character}
                            {;                                   BH - If search fails, determines how to}
                            {;                                        add the new entry}
                            {;   CX - not used                   DX - holds size of 1 table entry (5)}
                            {;   DI - varies                     SI - holds offset of 1st table entry}
                            {;   ES - seg addr of hash table     DS - program's data segment}
                            {;}
                            {;}
     $8A/$5E/<TargetSuffix/ {            mov byte    bl,[bp+<TargetSuffix]   ;Target Suffix character}
     $8B/$46/<TargetPrefix/ {            mov word    ax,[bp+<TargetPrefix]   ;Index into table}
     $BA/$05/$00/           {            mov         dx,5                    ;5 byte table entries}
     $F7/$E2/               {            mul         dx                      ;AX now an offset into table}
     $C4/$3E/>CodeTable/    {            les         di,[>CodeTable]         ;Hash table address}
     $89/$FE/               {            mov         si,di                   ;save offset in SI}
     $01/$C7/               {            add         di,ax                   ;es:di points to table entry}
                            {;}
     $B7/$00/               {            mov         bh,0                    ;Chain empty flag (0=empty)}
     $26/$83/$3D/$FF/       {        es: cmp word    [di],-1                 ;Anything on the chain?}
     $74/$33/               {            jz          NotFound                ;Nope, search fails}
     $B7/$01/               {            mov         bh,1                    ;Chain empty flag (1=not empty)}
                            {;}
     $26/$8B/$05/           {        es: mov word    ax,[di]                 ;Get index of 1st entry in chain}
     $89/$46/<TargetPrefix/ {Loop:       mov word    [bp+<TargetPrefix],ax   ;Save index for later}
     $BA/$05/$00/           {            mov         dx,5}
     $F7/$E2/               {            mul         dx                      ;convert index to offset}
     $89/$F7/               {            mov         di,si                   ;es:di points to start of table}
     $01/$C7/               {            add         di,ax                   ;es:di points to table entry}
                            {;}
     $26/$3A/$5D/$04/       {        es: cmp byte    bl,[di+4]               ;match on suffix?}
     $74/$0D/               {            jz          Found                   ;Yup, search succeeds}
                            {;}
     $26/$83/$7D/$02/$FF/   {        es: cmp word    [di+2],-1               ;any more entries in chain?}
     $74/$15/               {            jz          NotFound                ;nope, search fails}
                            {;}
     $26/$8B/$45/$02/       {        es: mov word    ax,[di+2]               ;get index of next chain entry}
     $EB/$E1/               {            jmp short   Loop                    ;   and keep searching}
                            {;}
     $C6/$46/$FF/$01/       {Found:      mov byte    [bp-1],1                ;return TRUE}
     $C4/$7E/<FoundAt/      {            les         di,[bp+<FoundAt]        ;get address of Var parameter}
     $8B/$46/<TargetPrefix/ {            mov word    ax,[bp+<TargetPrefix]   ;get index of entry where found}
     $26/$89/$05/           {        es: mov         [di],ax                 ;and store it}
     $EB/$0C/               {            jmp short   Done}
                            {;}
     $C6/$46/$FF/$00/       {NotFound:   mov byte    [bp-1],0                ;return FALSE}
     $C4/$7E/<FoundAt/      {            les         di,[bp+<FoundAt]        ;get address of Var parameter}
     $26/$C7/$05/$FF/$FF);  {        es: mov word    [di],-1                 ;and store a -1 in it}
                            {;}
                            {Done:}
                            {;}
   
end {Table_Lookup};

{ --------------------------------------------------------------------------- }
{ These routines build the Header structures for the ZIP file                 }
{ --------------------------------------------------------------------------- }

Procedure Begin_ZIP(ListPtr : NodePtr);
{ Write a dummy header to the zip.  Include as much info as is currently      }
{ known (we'll come back and fill in the rest later...)                       }
Begin
   LocalHdrOfs := FilePos(OutFile);       { Save file position for later use  }
   With LocalHdr do begin
      Signature := LOCAL_FILE_HEADER_SIGNATURE;
      Extract_Version_Reqd := 10;
      Bit_Flag := 0;
      Compress_Method := 1;
      Last_Mod_Time := ListPtr^.Time;
      Last_Mod_Date := ListPtr^.Date;
      Crc32 := 0;
      Compressed_Size := 0;
      Uncompressed_Size := ListPtr^.Size;
      FileName_Length := Length(ListPtr^.Name);
      Extra_Field_Length := 0;
   end {with};
   Move(LocalHdr, OutBuf^, SizeOf(LocalHdr)); { Put header into output buffer }
   OutBufIdx := Succ(SizeOf(LocalHdr));   {...adjust buffer index accordingly }
   Move(ListPtr^.Name[1], OutBuf^[OutBufIdx], Length(ListPtr^.Name));
   Inc(OutBufIdx, Length(ListPtr^.Name));
   FlushOutput;                           { Write it now                      }
End {Begin_ZIP};

{ --------------------------------------------------------------------------- }

Procedure Update_ZIP_Header(ListPtr : NodePtr);
{ Update the zip's local header with information that we now possess.  Check  }
{ to make sure that our shrinker actually produced a smaller file.  If not,   }
{ scrap the shrunk data, modify the local header accordingly, and just copy   }
{ the input file to the output file (compress method 0 - Storing).            }
Var
   EndPos : LongInt;
   Redo   : Boolean;
Begin
   Redo := FALSE;                            { Set REDO flag to false         }
   EndPos := FilePos(OutFile);               { Save current file position     }

   Seek(OutFile, LocalHdrOfs);               { Rewind back to file header     }

   With LocalHdr do begin
                                             { Update compressed size field   }
      Compressed_Size := EndPos - LocalHdrOfs - SizeOf(LocalHdr) - Filename_Length;
      Crc32 := Crc32Val;                     { Update CRC value               }
                                             { Have we compressed the file?   }
      Redo := (Compressed_Size >= Uncompressed_Size);
      If Redo then begin                     { No...                          }
         Compress_Method := 0;                  { ...change stowage type      }
         Compressed_Size := Uncompressed_Size;  { ...update compressed size   }
      end {if};

   end {with};

   Move(LocalHdr, OutBuf^, SizeOf(LocalHdr)); { Put header into output buffer }
   OutBufIdx := Succ(SizeOf(LocalHdr));   {...adjust buffer index accordingly }
   Move(ListPtr^.Name[1], OutBuf^[OutBufIdx], Length(ListPtr^.Name));
   Inc(OutBufIdx, Length(ListPtr^.Name));
   FlushOutput;                           { Write it now                      }

   If Redo then begin
      { If compression didn't make a smaller file, then ...                   }
      Seek(InFile, 0);                       { Rewind the input file          }
      InputEof := FALSE;                     { Reset EOF indicator            }
      Read_Block;                            { Prime the input buffer         }
      While NOT InputEof do begin            { Copy input to output           }
         BlockWrite(OutFile, InBuf^, MaxInBufIdx);
         Read_Block;
      end {while};
      Truncate(Outfile);                     { Truncate output file           }
   end {then}
   else begin
      { Compression DID make a smaller file ...                               }
      Seek(OutFile, FileSize(OutFile));   { Move output file pos back to eof  }
   end {if};
End {Update_ZIP_Header};

{ --------------------------------------------------------------------------- }

Procedure Build_Central_Dir;
{ Revisit each local file header to build the Central Directory.  When done,  }
{ build the End of Central Directory record.                                  }
Var
   BytesRead : Word;
   SavePos   : LongInt;
   HdrPos    : LongInt;
   CenDirPos : LongInt;
   Entries   : Word;
   FileName  : String;
Begin
   Entries := 0;
   CenDirPos := FilePos(Outfile);
   Seek(OutFile, 0);             { Rewind output file }
   HdrPos := FilePos(OutFile);
   BlockRead(OutFile, LocalHdr, SizeOf(LocalHdr), BytesRead);
   Repeat
      BlockRead(OutFile, FileName[1], LocalHdr.FileName_Length, BytesRead);
      FileName[0] := Chr(LocalHdr.FileName_Length);
      SavePos := FilePos(OutFile);

      With CentralHdr do begin
         Signature := CENTRAL_FILE_HEADER_SIGNATURE;
         MadeBy_Version := LocalHdr.Extract_Version_Reqd;
         Move(LocalHdr.Extract_Version_Reqd, Extract_Version_Reqd, 26);
         File_Comment_Length := 0;
         Starting_Disk_Num := 0;
         Internal_Attributes := 0;
         External_Attributes := ARCHIVE;
         Local_Header_Offset := HdrPos;
         Seek(OutFile, FileSize(OutFile));
         BlockWrite(Outfile, CentralHdr, SizeOf(CentralHdr));
         BlockWrite(OutFile, FileName[1], Length(FileName));
         Inc(Entries);
      end {with};

      Seek(OutFile, SavePos + LocalHdr.Compressed_Size);
      HdrPos := FilePos(OutFile);
      BlockRead(OutFile, LocalHdr, SizeOf(LocalHdr), BytesRead);
   Until LocalHdr.Signature = CENTRAL_FILE_HEADER_SIGNATURE;

   Seek(OutFile, FileSize(OutFile));

   With EndHdr do begin
      Signature := END_OF_CENTRAL_DIR_SIGNATURE;
      Disk_Number := 0;
      Central_Dir_Start_Disk := 0;
      Entries_This_Disk := Entries;
      Total_Entries := Entries;
      Central_Dir_Size := CenDirPos - FileSize(OutFile);
      Start_Disk_Offset := CenDirPos;
      ZipFile_Comment_Length := 0;
      BlockWrite(Outfile, EndHdr, SizeOf(EndHdr));
   end {with};

end {Build_Central_Dir};

{ --------------------------------------------------------------------------- }
{ The actual Crunching algorithm                                              }
{ --------------------------------------------------------------------------- }

Procedure Shrink(Suffix : Integer);
Const
   LastCode    : Integer = 0;   { Typed constant, so value retained across calls }
Var
   WhereFound   : Integer;
   CrunchRatio  : LongInt;
Begin
   If FirstCh then begin         { If just getting started ...                }
      SaveByte := $00;           { Initialize our output code buffer          }
      BitsUsed := 0;
      CodeSize := MINBITS;       {     Initialize code size to minimum        }
      MaxCode  := (1 SHL CodeSize) - 1;
      LastCode := Suffix;        {     get first character from input,        }
      FirstCh  := FALSE;         {     and reset the first char flag.         }
   end {then}
   else begin
      If Suffix <> -1 then begin { If there's work to do ...                  }
         If TableFull then begin
            { Ok, lets clear the code table (adaptive reset)            }
            Putcode(LastCode);
            PutCode(SPECIAL);
            Putcode(CLEARCODE);
            Clear_Table;
            Table_Add(LastCode, Suffix);
            LastCode := Suffix;
         end {then}
         else begin
            If Table_Lookup(LastCode, Suffix, WhereFound) then begin
               { If LastCode:Suffix pair is found in the code table, then ...    }
               { ... set LastCode to the entry where the pair is located         }
               LastCode  := WhereFound;
            end {then}
            else begin
               { Not in table                                                    }
               PutCode(LastCode);            { Write current LastCode code       }
               Table_Add(LastCode, Suffix);  { Attempt to add to code table      }
               LastCode := Suffix;           { Reset LastCode code for new char  }
               If (FreeList^[NextFree] > MaxCode) and (CodeSize < MaxBits) then begin
                  { Time to increase the code size and change the max. code      }
                  PutCode(SPECIAL);
                  PutCode(INCSIZE);
                  Inc(CodeSize);
                  MaxCode := (1 SHL CodeSize) -1;
               end {if};
            end {if};
         end {if};
      end {then}
      else begin                    { Nothing to crunch...must be EOF on input   }
         PutCode(LastCode);         { Write last prefix code                     }
         PutCode(-1);               { Tell putcode to flush remaining bits       }
         FlushOutput;               { Flush our output buffer                    }
      end {if};
   end {if};
end {Crunch};

{ --------------------------------------------------------------------------- }

Procedure Process_Input(Source : String);
Var
   I       : Word;
   PctDone : Integer;
Begin
   If Source = '' then
      Shrink(-1)
   else
      For I := 1 to Length(Source) do begin
         Inc(BytesIn);
         If (Pred(BytesIn) MOD TenPercent) = 0 then begin
            PctDone := Round( 100 * ( BytesIn / FileSize(InFile)));
            GotoXY(WhereX - 4, WhereY);
            Write(PctDone:3, '%');
         end {if};
         CRC32Val := UpdC32(Ord(Source[I]), CRC32Val);
         Shrink(Ord(Source[I]));
      end {for};
end {Process_Input};

{ --------------------------------------------------------------------------- }
{ This routine handles processing for one input file                          }
{ --------------------------------------------------------------------------- }

Procedure Process_One_File;
Var
   OneString : String;
   Remaining : Word;
Begin

   Read_Block;                { Prime the input buffer                        }
   FirstCh   := TRUE;         { 1st character flag for Crunch procedure       }
   Crc32Val  := $FFFFFFFF;

   TenPercent := FileSize(InFile) DIV 10;

   While NOT InputEof do begin
      Remaining := Succ(MaxInBufIdx - InBufIdx);

      If Remaining > 255 then
         Remaining := 255;

      If Remaining = 0 then
         Read_Block
      else begin
         Move(InBuf^[InBufIdx], OneString[1], Remaining);
         OneString[0] := Chr(Remaining);
         Inc(InBufIdx, Remaining);
         Process_Input(OneString);
      end {if};

   end {while};

   Crc32Val := NOT Crc32Val;

   Process_Input('');     { This forces EOF processing }

end {Process_One_File};

{ --------------------------------------------------------------------------- }

Procedure Process_All_Files;
Var
   InPath   : String;
   ComprPct : Word;
   ListNode : NodePtr;
Begin
   If ListHead = NIL then begin
      Writeln;
      Writeln('There are no files to shrink!');
      Writeln;
      Halt;
   end {if};

   OpenOutput;

   ListNode := ListHead;
   While ListNode <> NIL do begin
      If OpenInput(Concat(ListNode^.Path, ListNode^.Name)) then begin
         Write('Processing ', ListNode^.Name, ' ');
         While WhereX < 28 do
            Write('.');
         Write('    ');
         BytesIn := 1; BytesOut := 1;
         TenPercent := FileSize(InFile) DIV 10;
         Initialize_Data_Structures;
         Begin_ZIP(ListNode);
         Process_One_File;
         Update_ZIP_Header(ListNode);
         CloseInput;
         If LocalHdr.Uncompressed_Size > 0 then
            ComprPct := Round((100.0 * (LocalHdr.Uncompressed_Size - LocalHdr.Compressed_Size)) / LocalHdr.Uncompressed_Size)
         else
            ComprPct := 0;
         GotoXY(WhereX - 4, WhereY);
         ClrEol;
         Writeln(' done (compression = ', ComprPct:2, '%)');
      end {then}
      else
         Writeln('Could not open ', ListNode^.Name, '.  Skipping this file ...');
      ListNode := ListNode^.Next;
   end {while};
   Build_Central_Dir;
   CloseOutput;
End {Process_All_Files};

{ --------------------------------------------------------------------------- }
{ Main Program (driver)                                                       }
{ --------------------------------------------------------------------------- }

Begin
   Assign(Output, '');        { Reset output to DOS stdout device             }
   Rewrite(Output);
   Writeln;
   Writeln(Copyright);
   Writeln(Version);
   Writeln;
   If ParamCheck then begin
      GetBuffers;              { Allocate input and output buffers ...        }
      Build_Data_Structures;   { ... and other data structures required       }
      Process_All_Files;       { Crunch the file                              }
      DropBuffers;             { Be polite and de-allocate Buffer memory and  }
      Destroy_Data_Structures; {    other allocated data structures           }
   end {if};
End.
