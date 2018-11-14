PROGRAM AAM_Player;

USES Crt,Dos;

TYPE
  CursorForm = (CuNone,CuLine,CuBlock,CuHalf);

VAR
  cursors       : ARRAY[CursorForm] OF Word;
  f             : FILE;
  i,n,a,b,x,y,
  Frames,
  GlobalDelay,
  Delay         : Integer;
  Time          : Real;
  ClearFr,Col,
  FileStr,
  Loopable,
  RollUp,Row,
  Title         : STRING;
  FileToPlay    : Text;
  fAttr         : Word;
  cuform        : CursorForm;

{---------------------------- SYSTEM PROCEDURES ----------------------------}

PROCEDURE Wait(ms : LongInt);
BEGIN
  ms := ms*1000;
  ASM
    mov cx, word ptr ms+2
    mov dx, word ptr ms
    mov ah,$86
    int $15
  END;
END;

PROCEDURE ClearKeyBuff;
BEGIN
  MemW[$0000 : $041C] := MemW[$0000 : $041a];
  ASM cli END;
  MemW[Seg0040 : $1C] := MemW[Seg0040 : $1a];
  ASM sti END;
END;

PROCEDURE StrUpCase(VAR S : String);
VAR i : Byte;
BEGIN
  FOR i := 1 TO Length(s) DO S[i] := UpCase(S[i]);
END;

PROCEDURE Retrace; ASSEMBLER;
ASM
  mov dx,3dah;
  @l1: in al,dx;
  test al,8;
  jnz @l1;
  @l2: in al,dx;
  test al,8;
  jz @l2;
END;

{---------------------------- CURSOR PROCEDURES ----------------------------}

FUNCTION getCursorKind : Word; ASSEMBLER;
ASM
  mov ah,$03;
  xor bh,bh;
  int $10;
  xchg ax,cx;
END;

PROCEDURE setCursorKnd(w : Word); ASSEMBLER;
ASM
  mov cx,w;
  mov ah,1;
  int 10h;
END;

FUNCTION ColorBoard : Boolean;
VAR cb : Word;
BEGIN
  ASM int $11; mov cb,ax END;
  ColorBoard := cb AND $30 <> $30;
END;

PROCEDURE InitCursor;
BEGIN
  cursors[cuNone] := $0100;
  IF ColorBoard THEN BEGIN
    cursors[cuLine]  := $0607;
    cursors[cuBlock] := $0007;
    cursors[cuHalf]  := $0407
  END ELSE BEGIN
    cursors[cuLine]  :=$0c0d;
    cursors[cuBlock] :=$000d;
    cursors[cuHalf]  :=$060d
  END;
  setCursorKnd(cursors[cuLine])
END;

PROCEDURE SetCursorForm(kind : CursorForm);
BEGIN
  cuForm := kind;
  setCursorKnd(cursors[kind])
END;

PROCEDURE HideCursor;
BEGIN
 SetCursorForm(CuNone)
END;

PROCEDURE ShowCursor;
BEGIN
  SetCursorForm(CuLine)
END;

{--------------------------- FILESTUFF PROCEDURES --------------------------}

FUNCTION FileExists(FName : STRING) : Boolean;
BEGIN
  Assign(f,FName);
  GetFAttr(f,fAttr);
  FileExists := (DosError = 0)
            AND ((fAttr AND Directory) = 0)
            AND ((fAttr AND VolumeID)  = 0);
END;

FUNCTION DirExists(DName : STRING) : Boolean;
BEGIN
 Assign(f,DName);
 GetFAttr(f,fAttr);
 DirExists := ((fAttr AND Directory) <> 0) AND (DosError = 0);
END;

FUNCTION IsReadOnly(FName : STRING) : Boolean;
BEGIN
  ASSIGN(f,FName);
  GetFAttr(f,fAttr);
  IsReadOnly := (fAttr AND ReadOnly) <> 0;
END;

FUNCTION IsHidden(FName : STRING) : Boolean;
BEGIN
 Assign(f,FName);
 GetFAttr(f,fAttr);
 IsHidden := (fAttr AND Hidden) <> 0;
END;

FUNCTION IsSysFile(FName : STRING) : Boolean;
BEGIN
  Assign(f,FName);
  GetFAttr(f,fAttr);
  IsSysFile := (fAttr AND SysFile) <> 0;
END;

FUNCTION IsVolumeID(FName : STRING) : Boolean;
BEGIN
  Assign(f,FName);
  GetFAttr(f,fAttr);
  IsVolumeID := (fAttr AND VolumeID) <> 0;
END;

FUNCTION IsDirectory(FName : STRING) : Boolean;
BEGIN
  Assign(f,FName);
  GetFAttr(f,fAttr);
  IsDirectory := (fAttr AND Directory) <> 0;
END;

FUNCTION IsArchived(FName : STRING) : Boolean;
BEGIN
 Assign(f,FName);
 GetFAttr(f,fAttr);
 IsArchived := (fAttr AND Archive) = 0;
END;

{---------------------- PROCEDURES FOR FRAME-HANDLING ----------------------}

PROCEDURE Center(Row: Integer; Str: STRING);
BEGIN
  Gotoxy(41-Length(Str) DIV 2,Row+(y DIV 2));
  Write(Str);
END;

PROCEDURE ClearFrame;
BEGIN
  FOR a := 2 TO 18 DO BEGIN
    GotoXY(3,a);
    Write('                                                                            ');
  END;
  Retrace;
END;

PROCEDURE PlayMovie;
BEGIN
  ClearFrame;
  Time := 0;
  Assign(FileToPlay,FileStr);
  Reset(FileToPlay);
  Read(FileToPlay,x);
  Read(FileToPlay,y);
  GotoXY(5,23);
  WriteLn('Format: ',x,'x',y);
  Read(FileToPlay,Frames);
  GotoXY(22,23);
  WriteLn('Frames: ',Frames);
  GotoXY(37,23);
  WriteLn('Frame Size: ',x*y);
  ReadLn(FileToPlay,GlobalDelay);
  IF GlobalDelay = 1 THEN ReadLn(FileToPlay,Delay);
  ReadLn(FileToPlay,Title);
  GotoXY(5,20);
  WriteLn('Title: ',Title);
  FOR n := 1 TO Frames DO BEGIN
    IF ClearFr = 'YES' THEN ClearFrame;
    FOR i := 1 TO y DO BEGIN
      IF (RollUp = 'YES') AND (i <> 1) THEN ReadLn(FileToPlay,Row)
        ELSE IF RollUp <> 'YES' THEN ReadLn(FileToPlay,Row);
      Center(i,Row);
      GotoXY(5,21);
      WriteLn('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
      GotoXY(6+Round(30*n/Frames),21);
      WriteLn('³');
      GotoXY(38,21);
      Write(n,'/',Frames);
      GotoXY(47,21);
      Write(n/Frames*100:6:2,'%');
      GotoXY(5,22);
      Write('Played Time: ',Time/1000:6:2,' sec');
      GotoXY(30,22);
      Write('Estimated in: ',((Frames*Delay)-Time)/1000:6:2,' sec');
    END;
    IF GlobalDelay = 1 THEN Wait(Delay) ELSE BEGIN
      ReadLn(FileToPlay,Delay);
      Wait(Delay);
    END;
    Time := Time+Delay;
  END;
  Close(FileToPlay);
END;

PROCEDURE LoadMovie;
BEGIN
  REPEAT
    IF ParamStr(1) <> '' THEN FileStr := ParamStr(1);
    GotoXY(6,5);
    WriteLn('Enter file (.aam) to playing:                                  ');
    GotoXY(36,6);
    WriteLn('îîîîîîîîîîîîîîîîîîîîîîîîîîîîî');
    GotoXY(36,5);
    ShowCursor;
    SetCursorForm(CuBlock);
    IF (FileStr = '') OR NOT(FileExists(FileStr)) THEN ReadLn(FileStr)
      ELSE IF (FileStr <> '') AND (FileExists(FileStr)) THEN BEGIN
        GotoXY(36,5);
        WriteLn(FileStr);
    END;
    HideCursor;
    IF NOT(FileExists(FileStr)) THEN BEGIN
      GotoXY(36,5);
      WriteLn('ERROR: File doesnït exists!!!');
      Wait(1000);
    END;
  UNTIL FileExists(FileStr);
  REPEAT
    GotoXY(6,7);
    WriteLn('Loop the movie? Type `yes` or `no`:                             ');
    GotoXY(42,8);
    WriteLn('îîîîîîî');
    IF (ParamStr(2) = 'L') OR (ParamStr(2) = 'l') OR
       (ParamStr(3) = 'L') OR (ParamStr(3) = 'l') OR
       (ParamStr(4) = 'L') OR (ParamStr(4) = 'l') THEN BEGIN
      GotoXY(42,7);
      Write('Yes');
      LoopAble := 'YES';
    END ELSE BEGIN
      GotoXY(42,7);
      ShowCursor;
      SetCursorForm(CuBlock);
      ReadLn(Loopable);
      StrUpCase(Loopable);
      IF Loopable = 'N' THEN Loopable := 'NO';
      IF Loopable = 'Y' THEN Loopable := 'YES';
      HideCursor;
    END;
    IF NOT((Loopable = 'YES') OR (Loopable = 'NO')) THEN BEGIN
      GotoXY(42,7);
      WriteLn('ERROR: Illegal comment!!!');
      Wait(1000);
    END;
  UNTIL (Loopable = 'YES') OR (Loopable = 'NO');
  REPEAT
    GotoXY(6,9);
    WriteLn('Roll-Up the movie? Type `yes` or `no`:                             ');
    GotoXY(45,10);
    WriteLn('îîîîîîî');
    IF (ParamStr(2) = 'R') OR (ParamStr(2) = 'r') OR
       (ParamStr(3) = 'R') OR (ParamStr(3) = 'r') OR
       (ParamStr(4) = 'R') OR (ParamStr(4) = 'r') THEN BEGIN
      GotoXY(45,9);
      Write('Yes');
      RollUp := 'YES';
    END ELSE BEGIN
      GotoXY(45,9);
      ShowCursor;
      SetCursorForm(CuBlock);
      ReadLn(RollUp);
      StrUpCase(RollUp);
    END;
    IF RollUp = 'N' THEN RollUp := 'NO';
    IF RollUp = 'Y' THEN RollUp := 'YES';
    HideCursor;
    IF NOT((RollUp = 'YES') OR (RollUp = 'NO')) THEN BEGIN
      GotoXY(45,9);
      WriteLn('ERROR: Illegal comment!!!');
      Wait(1000);
    END;
  UNTIL (RollUp = 'YES') OR (RollUp = 'NO');
  REPEAT
    GotoXY(6,11);
    WriteLn('Clear canvas after any frame? Type `yes` or `no`:                    ');
    GotoXY(56,12);
    WriteLn('îîîîîîî');
    IF (ParamStr(2) = 'C') OR (ParamStr(2) = 'c') OR
       (ParamStr(3) = 'C') OR (ParamStr(3) = 'c') OR
       (ParamStr(4) = 'C') OR (ParamStr(4) = 'c') THEN BEGIN
      GotoXY(56,11);
      Write('Yes');
      ClearFr := 'YES';
    END ELSE BEGIN
      GotoXY(56,11);
      ShowCursor;
      SetCursorForm(CuBlock);
      ReadLn(ClearFr);
      StrUpCase(ClearFr);
    END;
    IF ClearFr = 'N' THEN ClearFr := 'NO';
    IF ClearFr = 'Y' THEN ClearFr := 'YES';
    HideCursor;
    IF NOT((ClearFr = 'YES') OR (ClearFr = 'NO')) THEN BEGIN
      GotoXY(56,11);
      WriteLn('ERROR: Illegal comment!!!');
      Wait(1000);
    END;
  UNTIL (ClearFr = 'YES') OR (ClearFr = 'NO');
  IF LoopAble = 'YES' THEN REPEAT
    PlayMovie;
  UNTIL KeyPressed ELSE PlayMovie;
END;

{------------------------------- MAIN PROGRAM ------------------------------}

BEGIN
  InitCursor;
  TextColor(White);
  HideCursor;
  ClrScr;
  FOR i := 1 TO 78 DO BEGIN
    GotoXY(1+i,1);
    Write('Ü');
    GotoXY(1+i,19);
    Write('Ü');
    GotoXY(1+i,24);
    Write('Ü');
  END;
  FOR i := 1 TO 23 DO BEGIN
    GotoXY(2,1+i);
    Write('Û');
    GotoXY(79,1+i);
    Write('Û');
  END;
  FOR i := 1 TO 5 DO BEGIN
    GotoXY(55,19+i);
    Write('Û');
  END;
  GotoXY(57,20);
  WriteLn('Animated ASCII Movie');
  GotoXY(57,21);
  WriteLn(' (AAM)-Player 1.01');
  GotoXY(57,23);
  WriteLn('   ¸ M. Johne 2005');
  LoadMovie;
  ShowCursor;
  ClearKeyBuff;
  ReadKey;
END.