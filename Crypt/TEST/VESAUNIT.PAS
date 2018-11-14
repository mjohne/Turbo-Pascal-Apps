{filename: vesaunit.pas}


{This is a Real Mode/Protected Mode vesa unit written by TCA of NewOrder
(iuzzolin@nmia.com).  Special thanx to mark@mbaldwin.demon.co.uk for the
TVESARec and TModeRec and writing the VesaInfo.pas proggie, and Ted Gruber
for pointing out I needed a Real Mode Callback.  There are no drawing
routines in this unit, as it is just a front end for a vesa library.
I wrote this because I have yet to see a PM version of a VESA library...
and now I know why.

Notes:

   This was specifically written so that the same [VESA Information] code
would run under either RM or PM.

   One must call AllocVESAStrucs *before* you call IsVesaInstalled or
GetModeInfo.  This allocates the pointers to the two records.  Calling
DeAllocVESAStrucs at the end of your program is a good idea, but no one
will notice if you forget to do so.

   IsVESAInstalled and GetModeInfo do not check to see if the call
itself fails.  On one of my machines it supposedly returns a fail code,
but the call completes successfully.

   RMRegs is actually a copy of the RealModeRegs variable in the system
unit.  It is unclear as to whether or not it is alright to access that
variable, so I made my own.

   Calling the BankSwitch routine from protected mode doesn't seem to work.
One can either write a real mode callback (via func 301h I think) or just
call Int 10h.  I'll leave this up to you.

   Yes, I know that the code: boolean(byte(RMRegs.eax)) is not pretty
(reminds me of C), but it is required unless I do some union type stuff
(which I do have in my personal library, but could be confusing to people).
After some testing, I'm not even sure if the return value works properly 
for GetModeInfo().

   In the PM version of GetModeInfo the BankSwitch conversion from a Real
Mode pointer to a Protected mode pointer is commented out.  This is because
one could (should?) set up a real mode callback to it.

   This is freeware/public domain.  You can use it for whatever you want.
If it blows up your computer, Danny owes me lunch (but I'm not responsible!)
It would be nice, however, if you gave me credit in your Greetz section
if you use this (if it doesn't blow up your computer, that is =).

}
unit vesaunit;

interface

type
  PWordArray = ^TWordArray;
  TWordArray = array [0..256] of Word;

  TVESARec = record
    Sig: array [0..3] of Char;
    uVersion: Byte;
    lVersion: Byte;
    Manufacturer: Pointer;
    Flag: LongInt;
    Modes: PWordArray;
    Paddington: array [19..256] of Byte;
  end;

  TModeRec = record
    ModeFlag: Word;
    WindowFlags: array [0..1] of Byte;
    Gran: Word;
    WindowSize: Word;
    Window1Seg,Window2Seg: Word;
    BankSwitch: Pointer;
    BytesPerLine: Word;
    XRes,YRes: Word;
    CharWidth,CharHeight: Byte;
    NumBitplanes: Byte;
    BitsPerPixel: Byte;
    MemBlocks: Byte;
    MemModel: Byte;
    MemBlockSize: Byte;
    paddington: array [1..300] of Byte;
  end;

var RMRegs:record
            edi,esi,ebp,reserved,ebx,edx,ecx,eax:longint;
            flags,es,ds,fs,gs,ip,cs,sp,ss:word
           end;
    VESARec:^TVESARec;
    ModeRec:^TModeRec;
    BankSwitch:procedure;

procedure AllocVesaStrucs;
procedure DeAllocVesaStrucs;
function IsVESAInstalled (var VESARec:TVesaRec): Boolean;
function GetModeInfo (mode: Word;var ModeRec:TModeRec): Boolean;

implementation
{$ifdef DPMI}
uses winapi;

{Simulate Real Mode Interrupt}
procedure SimRMI(IntNum:byte;var CallStruc); assembler;
asm
        mov     ax,300h
        mov     bh,1
        mov     bl,IntNum
        xor     cx,cx
        les     di,CallStruc
        int     31h
end;

{Call Real Mode Procedure (with Far Return Frame)}
procedure CallRMP(var CallStruc); assembler;
asm
        mov     ax,301h
        mov     bh,1
        xor     cx,cx
        les     di,CallStruc
        int     31h
end;

function GetSegBaseAddr(Selector:word):longint; assembler;
asm
        mov     ax,0006h
        mov     bx,Selector
        int     31h
        mov     ax,dx
        mov     dx,cx
end;

function SegToDescriptor(SegAddr:word):word; assembler;
asm
        mov     ax,0002h
        mov     bx,SegAddr
        int     31h
end;

{ConvertPtr converts a Real Mode Pointer into a valid Protected Mode Pointer}
function ConvertPtr(RMPointer:Pointer):pointer; assembler;
asm
        mov     ax,0002h
        mov     bx,word ptr RMPointer+2
        int     31h
        mov     dx,ax
        mov     ax,word ptr RMPointer
end;

function IsVesaInstalled(var VESARec:TVesaRec):boolean;
begin
 with RMRegs do
  begin
   eax:=$4f00;
   edi:=0;
   es:=GetSegBaseAddr(seg(VESARec)) shr 4;
   ss:=0; {Clear stack so DPMI handles it}
   sp:=0  {"}
  end;
 SimRMI($10,RMRegs);

 {Convert all real mode pointers to protected mode pointers}
 with VesaRec do
  begin
   Modes:=ConvertPtr(Modes);
   Manufacturer:=ConvertPtr(Manufacturer);
  end;

 IsVesaInstalled:=boolean(byte(RMRegs.eax)) {Yeah, yeah}
end;

function GetModeInfo(mode:Word; var ModeRec:TModeRec): Boolean;
var poy:pointer;
begin
 with RMRegs do
  begin
   eax:=$4f01;
   ecx:=longint(mode);
   edi:=0;
   es:=GetSegBaseAddr(seg(ModeRec)) shr 4;
   sp:=0; {Clear stack so DPMI handles it}
   ss:=0  {"}
  end;
 SimRMI($10,RMRegs);
{
 with ModeRec do
  BankSwitch:=ConvertPtr(BankSwitch);
}
 GetModeInfo:=boolean(byte(RMRegs.eax)); {Bad typecasts, bad bad typecasts!}
end;

{$else}

function IsVESAInstalled (var VESARec:TVesaRec): Boolean; assembler;
asm
        mov     ax,4F00h
        les     di,VESARec
        int     10h
end;

function GetModeInfo (mode: Word;var ModeRec:TModeRec): Boolean; assembler;
asm
        mov     ax,4F01h
        mov     cx,mode
        les     di,ModeRec
        int     10h
end;
{$endif}

procedure AllocVesaStrucs;
begin
{$ifdef DPMI}
 ModeRec:=GlobalLock(GlobalDosAlloc(sizeof(Tmoderec)));
 VesaRec:=GlobalLock(GlobalDosAlloc(sizeof(TVESARec)))
{$else}
 new(VesaRec);
 new(ModeRec)
{$endif}
end;

procedure DeAllocVesaStrucs;
begin
{$ifdef DPMI}
 if globalunlock(seg(VesaRec^)) then globaldosfree(seg(VesaRec^));
 if globalunlock(seg(ModeRec^)) then globaldosfree(seg(ModeRec^))
{$else}
 dispose(VesaRec);
 dispose(ModeRec)
{$endif}
end;

end.

{--- snip here ---}

program vesainfo;
uses Crt,vesaunit;

const
  Digits : array[0..$F] of Char = '0123456789ABCDEF';

function HexW(W : Word) : string;
    {-Return hex string for word}
begin
 HexW[0] := #4;
 HexW[1] := Digits[hi(W) shr 4];
 HexW[2] := Digits[hi(W) and $F];
 HexW[3] := Digits[lo(W) shr 4];
 HexW[4] := Digits[lo(W) and $F];
end;

function Trim(S : string) : string;
    {-Return a string with leading and trailing white space removed}
var
 I : Word;
 SLen : Byte absolute S;
begin
 while (SLen > 0) and (S[SLen] <= ' ') do
  Dec(SLen);
 I := 1;
 while (I <= SLen) and (S[I] <= ' ') do
  Inc(I);
 Dec(I);
 if I > 0 then Delete(S, 1, I);
 Trim := S;
end;

function LeftPadCh(S : string; Ch : Char; Len : Byte) : string;
    {-Return a string left-padded to length len with ch}
  var
    o : string;
    SLen : Byte absolute S;
  begin
    if Length(S) >= Len then
      LeftPadCh := S
    else if SLen < 255 then begin
      o[0] := Chr(Len);
      Move(S[1], o[Succ(Word(Len))-SLen], SLen);
      FillChar(o[1], Len-SLen, Ch);
      LeftPadCh := o;
    end;
  end;

  function LeftPad(S : string; Len : Byte) : string;
    {-Return a string left-padded to length len with blanks}
  begin
    LeftPad := LeftPadCh(S, ' ', Len);
  end;

  function PadCh(S : string; Ch : Char; Len : Byte) : string;
    {-Return a string right-padded to length len with ch}
  var
    o : string;
    SLen : Byte absolute S;
  begin
    if Length(S) >= Len then
      PadCh := S
    else begin
      o[0] := Chr(Len);
      Move(S[1], o[1], SLen);
      if SLen < 255 then
        FillChar(o[Succ(SLen)], Len-SLen, Ch);
      PadCh := o;
    end;
  end;

function Pad(S : string; Len : Byte) : string;
    {-Return a string right-padded to length len with blanks}
begin
 Pad := PadCh(S, ' ', Len);
end;

function Long2Str(L : LongInt) : string;
    {-Convert a long/word/integer/byte/shortint to a string}
var
    S : string;
begin
 Str(L, S);
 Long2Str := S;
end;

procedure DisplayString (x,y: Byte; s: String);
var
  i: Byte;
  c: Char;
begin
 for i := 1 to Length (s) do
  begin
   c := s [i];
   GotoXY (x,y);
   asm
        mov     ah,09h
        mov     al,[c]
        mov     bh,0
        mov     bl,01h
        mov     cx,1
        int     10h
        inc     x
   end
  end
end;

var
  i: Integer;
  num: Word;
  ii: Byte;
  mode: String;

begin
 AllocVesaStrucs; {THIS IS IMPORTANT}

 if IsVESAInstalled (VESARec^) then
  begin
   repeat
    ClrScr;
    i:=0;
    while VESARec^.Modes^ [i] <> $FFFF do
     begin
      Write (Pad (HexW (VESARec^.Modes^ [i]),8));
      GetModeInfo (VESARec^.Modes^ [i], ModeRec^);
      with ModeRec^ do
       Writeln (LeftPad (Long2Str (XRes)+'x'+Long2Str (YRes),9),' ',BitsPerPixel:2,' ',MemModel:2,' ',Gran);
      Inc (i);
     end;
    Writeln;
    Write('Enter video mode: ');
    Readln(mode);
    mode:=Trim(mode);
    if mode<>'' then
     begin
      num:=0;
      ii:=0;
      for i:=Length(mode) downto 1 do
       begin
        if mode[i] in ['0'..'9'] then
         inc(num, ((Ord (mode [i]) - Ord ('0')) shl ii))
        else inc(num,ord(upcase(mode[i]))-ord('A')+10);
        Inc (ii,4);
       end;
      if GetModeInfo (num, ModeRec^) then
       begin
        ClrScr;
        with ModeRec^ do
         begin
          Writeln ('Information for mode ',HexW (num),'h - ',XRes,'x',YRes,' ',BitsPerPixel,'bit color');
          Writeln;
          Write ('Can this mode be used with the attached monitor?    ');
          if ModeFlag and 1 = 1 then Writeln ('Yes') else Writeln ('No');
          Write ('Are the BIOS text functions supported in this mode? ');
          if ModeFlag and 4 = 4 then Writeln ('Yes') else Writeln ('No');
          Write ('Monochrome or colour?                               ');
          if ModeFlag and 8 = 8 then Writeln ('Colour') else Writeln ('Monochrome');
          Write ('Mode type                                           ');
          if ModeFlag and 16 = 16 then Writeln ('Graphic') else Writeln ('Text');
          Writeln;
          Writeln ('Access window information:');
          for i := 0 to 1 do
           begin
            Write ('  ',i,' ');
            if WindowFlags [i] and 1 = 1 then Write ('Available') else Write ('Not Available');
            Write (',');
            if WindowFlags [i] and 2 = 2 then Write ('Read Access') else Write ('No Read Access');
            Write (',');
            if WindowFlags [i] and 4 = 4 then Write ('Write Access') else Write ('No Write Access');
            Writeln;
           end;
          Writeln;
          Writeln('Granularity                                         ',Gran,'k');
          Writeln('Size of the two access windows                      ',WindowSize,'k');
          Writeln('Segment address of first access window              ',HexW(Window1Seg),'h');
          Writeln('Segment address of second access window             ',HexW(Window2Seg),'h');
          Writeln('Number of bytes required for each pixel line        ',BytesPerLine);
          Writeln('Width of character matrix in pixels                 ',CharWidth);
          Writeln('Height of character matrix in pixels                ',CharHeight);
          Writeln('Number of bitplanes                                 ',NumBitPlanes);
          Writeln('Number of bits per screen pixel                     ',BitsPerPixel);
          Writeln('Number of memory blocks                             ',MemBlocks);
          Writeln('Memory model                                        ',MemModel);
          Writeln('Size of memory blocks                               ',MemBlockSize);
         end;
       end
        else Writeln ('Invalid mode'); {I've never seen this executed}
      Writeln;
      Write ('Press any key...');
      Readln;
     end;
    until Trim (mode) = '';
  end
  else Writeln ('VESA is not installed.');

 DeAllocVesaStrucs; {THIS IS IMPORTANT, too}
end.

