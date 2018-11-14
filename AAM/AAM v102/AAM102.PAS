PROGRAM AAM_Player;

USES Crt,Dos,RT_Watch;

TYPE
  CursorForm = (CuNone,CuLine,CuBlock,CuHalf);

VAR
  cursors       : ARRAY[CursorForm] OF Word;
  f             : FILE;
  i,n,a,b,x,y,
  Frames,
  GlobalDelay,
  Delay,
  Row25_or_50   : Integer;
  Time          : Real;
  Regs          : Registers;
  AAM_or_ASC,
  Centered,
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
  MemW[$0000:$041C] := MemW[$0000:$041a];
  ASM cli END;
  MemW[Seg0040:$1C] := MemW[Seg0040:$1a];
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

{----------------------- PROCEDURES FOR BUILDING MENU ----------------------}

PROCEDURE BuildMenu80x25;
BEGIN
  Row25_or_50 := 25;
  TextMode(3);
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
  WriteLn(' (AAM)-Player 1.02');
  GotoXY(57,23);
  WriteLn('   ¸ M. Johne 2005');
END;

PROCEDURE BuildMenu80x50;
BEGIN
  Row25_or_50 := 50;
  TextMode(300);
  TextColor(White);
  HideCursor;
  ClrScr;
  FOR i := 1 TO 78 DO BEGIN
    GotoXY(1+i,1);
    Write('Ü');
    GotoXY(1+i,44);
    Write('Ü');
    GotoXY(1+i,49);
    Write('Ü');
  END;
  FOR i := 1 TO 48 DO BEGIN
    GotoXY(2,1+i);
    Write('Û');
    GotoXY(79,1+i);
    Write('Û');
  END;
  FOR i := 1 TO 5 DO BEGIN
    GotoXY(55,44+i);
    Write('Û');
  END;
  GotoXY(57,45);
  WriteLn('Animated ASCII Movie');
  GotoXY(57,46);
  WriteLn(' (AAM)-Player 1.02');
  GotoXY(57,48);
  WriteLn('   ¸ M. Johne 2005');
END;

{---------------------- PROCEDURES FOR FRAME-HANDLING ----------------------}

PROCEDURE Center(Row: Integer; Str: STRING);
BEGIN
  IF Row25_or_50 = 25 THEN Gotoxy(41-Length(Str) DIV 2,(19 DIV 2)-(y DIV 2)+Row)
    ELSE IF Row25_or_50 = 50 THEN Gotoxy(41-Length(Str) DIV 2,(45 DIV 2)-(y DIV 2)+Row);
  Write(Str);
END;

PROCEDURE ClearFrame;
BEGIN
  IF Row25_or_50 = 25 THEN FOR a := 2 TO 18 DO BEGIN
    GotoXY(3,a);
    Write('                                                                            ');
  END ELSE IF Row25_or_50 = 25 THEN FOR a := 2 TO 43 DO BEGIN;
    GotoXY(3,a);
    Write('                                                                            ');
  END;
  Retrace;
END;

PROCEDURE PlayMovie;
BEGIN
  ClearFrame;
  Time := 0;
  IF AAM_or_ASC = 'AAM' THEN BEGIN
    Assign(FileToPlay,FileStr);
    Reset(FileToPlay);
    Read(FileToPlay,x);
    Read(FileToPlay,y);
    Read(FileToPlay,Frames);
    ReadLn(FileToPlay,GlobalDelay);
    IF GlobalDelay = 1 THEN ReadLn(FileToPlay,Delay);
    ReadLn(FileToPlay,Title);
    IF y <= 17 THEN BEGIN
      GotoXY(5,23);
      WriteLn('Format: ',x,'x',y);
      GotoXY(22,23);
      WriteLn('Frames: ',Frames);
      GotoXY(37,23);
      WriteLn('Frame Size: ',x*y);
      GotoXY(5,20);
      WriteLn('Title: ',Title);
    END;
    IF (y > 17) AND (y <= 43) THEN BEGIN
      Close(FileToPlay);
      BuildMenu80x50;
      Assign(FileToPlay,FileStr);
      Reset(FileToPlay);
      Read(FileToPlay,x);
      Read(FileToPlay,y);
      GotoXY(5,47);
      WriteLn('Format: ',x,'x',y);
      Read(FileToPlay,Frames);
      GotoXY(22,47);
      WriteLn('Frames: ',Frames);
      GotoXY(37,47);
      WriteLn('Frame Size: ',x*y);
      ReadLn(FileToPlay,GlobalDelay);
      IF GlobalDelay = 1 THEN ReadLn(FileToPlay,Delay);
      ReadLn(FileToPlay,Title);
      GotoXY(5,45);
      WriteLn('Title: ',Title);
    END;
    FOR n := 1 TO Frames DO BEGIN
      IF ClearFr = 'YES' THEN ClearFrame;
      FOR i := 1 TO y DO BEGIN
        IF (RollUp = 'YES') AND (i <> 1) THEN ReadLn(FileToPlay,Row)
          ELSE IF RollUp <> 'YES' THEN ReadLn(FileToPlay,Row);
        IF Length(Row) < x THEN FOR a := 1 TO x-Length(Row) DO Row := Row+' ';
        IF Centered = 'CENTER' THEN Center(i,Row) ELSE BEGIN
          GotoXY(3,1+i);
          Write(Row);
        END;
        IF y <= 17 THEN GotoXY(5,21) ELSE IF (y > 17) AND (y <= 43) THEN GotoXY(5,46);
        WriteLn('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
        IF y <= 17 THEN GotoXY(6+Round(30*n/Frames),21) ELSE IF (y > 17) AND (y <= 43) THEN GotoXY(6+Round(30*n/Frames),46);
        WriteLn('³');
        IF y <= 17 THEN GotoXY(38,21) ELSE IF (y > 17) AND (y <= 43) THEN GotoXY(38,46);
        Write(n,'/',Frames);
        IF y <= 17 THEN GotoXY(47,21) ELSE IF (y > 17) AND (y <= 43) THEN GotoXY(47,46);
        Write(n/Frames*100:6:2,'%');
        IF y <= 17 THEN GotoXY(5,22) ELSE IF (y > 17) AND (y <= 43) THEN GotoXY(5,48);
        Write('Played Time: ',Time/1000:6:2,' sec');
        IF y <= 17 THEN GotoXY(30,22) ELSE IF (y > 17) AND (y <= 43) THEN GotoXY(30,48);
        Write('Estimated in: ',((Frames*Delay)-Time)/1000:6:2,' sec');
      END;
      IF GlobalDelay = 1 THEN Wait(Delay) ELSE BEGIN
        ReadLn(FileToPlay,Delay);
        Wait(Delay);
      END;
      Time := Time+Delay;
    END;
    Close(FileToPlay);
  END ELSE IF AAM_or_ASC = 'ASC' THEN BEGIN

   IF (ParamStr(2) = 'L') OR (ParamStr(2) = 'l') OR
    (ParamStr(3) = 'L') OR (ParamStr(3) = 'l') OR
    (ParamStr(4) = 'L') OR (ParamStr(4) = 'l') OR
    (ParamStr(5) = 'L') OR (ParamStr(5) = 'l') THEN Centered := 'LEFT';

    {Check format of ASC picture}
    Assign(FileToPlay,FileStr);
    Reset(FileToPlay);
    x := 0;
    y := 0;
    REPEAT
      ReadLn(FileToPlay,Row);
      Inc(y);
      IF Length(Row) > x THEN x := Length(Row);
    UNTIL EoF(FileToPlay);
    Close(FileToPlay);
    IF x < 23 THEN BEGIN
      FOR i := 1 TO 76 DO BEGIN
        GotoXY(2+i,19);
        Write(' ');
      END;
      FOR i := 1 TO 5 DO BEGIN
        GotoXY(55,19+i);
        Write(' ');
      END;
      GotoXY(55,19+5);
      Write('Ü');
      GotoXY(57,20);
      WriteLn('                    ');
      GotoXY(57,21);
      WriteLn('                    ');
      GotoXY(57,23);
      WriteLn('                    ');
    END ELSE BEGIN
      BuildMenu80x50;
      FOR i := 1 TO 76 DO BEGIN
        GotoXY(2+i,44);
        Write(' ');
      END;
      FOR i := 1 TO 4 DO BEGIN
        GotoXY(55,44+i);
        Write(' ');
      END;
      GotoXY(55,44+5);
      Write('Ü');
      GotoXY(57,45);
      WriteLn('                    ');
      GotoXY(57,46);
      WriteLn('                    ');
      GotoXY(57,48);
      WriteLn('                    ');
    END;
    {draw ASC picture}
    Assign(FileToPlay,FileStr);
    Reset(FileToPlay);
    FOR i := 1 TO y DO BEGIN
      ReadLn(FileToPlay,Row);
      IF Length(Row) < x THEN FOR n := 1 TO x-Length(Row) DO Row := Row+' ';
      IF Centered = 'CENTER' THEN Center(i,Row) ELSE BEGIN
        GotoXY(3,1+i);
        Write(Row);
      END;
    END;
    Close(FileToPlay);
  END ELSE Halt;
END;

PROCEDURE LoadMovie;
BEGIN
  REPEAT
    IF ParamStr(1) <> '' THEN FileStr := ParamStr(1);
    GotoXY(6,5);
    WriteLn('Enter file (.aam;.asc) to playing:                              ');
    GotoXY(41,6);
    WriteLn('îîîîîîîîîîîîîîîîîîîîîîîîîîîîî');
    GotoXY(41,5);
    ShowCursor;
    SetCursorForm(CuBlock);
    IF (FileStr = '') OR NOT(FileExists(FileStr)) THEN ReadLn(FileStr)
      ELSE IF (FileStr <> '') AND (FileExists(FileStr)) THEN BEGIN
        GotoXY(41,5);
        WriteLn(FileStr);
    END;
    HideCursor;
    AAM_or_ASC := FileStr[Length(FileStr)-2]+FileStr[Length(FileStr)-1]+FileStr[Length(FileStr)];
    StrUpCase(AAM_or_ASC);
    IF (AAM_or_ASC <> 'AAM') AND (AAM_or_ASC <> 'ASC') THEN BEGIN
      GotoXY(41,5);
      WriteLn('ERROR: Wrong file extension!!!');
      Wait(1000);
    END;
    IF NOT(FileExists(FileStr)) THEN BEGIN
      GotoXY(41,5);
      WriteLn('ERROR: File doesnït exists!!! ');
      Wait(1000);
    END;
  UNTIL FileExists(FileStr);
  IF AAM_or_ASC = 'AAM' THEN BEGIN
    REPEAT
      GotoXY(6,7);
      WriteLn('Loop the movie? Type `yes` or `no`:                             ');
      GotoXY(42,8);
      WriteLn('îîîîîîî');
      IF (ParamStr(2) = 'L') OR (ParamStr(2) = 'l') OR
         (ParamStr(3) = 'L') OR (ParamStr(3) = 'l') OR
         (ParamStr(4) = 'L') OR (ParamStr(4) = 'l') OR
         (ParamStr(5) = 'L') OR (ParamStr(5) = 'l') THEN BEGIN
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
         (ParamStr(4) = 'R') OR (ParamStr(4) = 'r') OR
         (ParamStr(5) = 'R') OR (ParamStr(5) = 'r') THEN BEGIN
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
        WriteLn('ERROR!');
        Wait(1000);
      END;
    UNTIL (RollUp = 'YES') OR (RollUp = 'NO');
    REPEAT
      GotoXY(6,11);
      WriteLn('Clear canvas after any frame? Type `yes` or `no`:                    ');
      GotoXY(56,12);
      WriteLn('îîîîîîî');
      IF (ParamStr(2) = 'CF') OR (ParamStr(2) = 'cf') OR
         (ParamStr(3) = 'CF') OR (ParamStr(3) = 'cf') OR
         (ParamStr(4) = 'CF') OR (ParamStr(4) = 'cf') OR
         (ParamStr(5) = 'CF') OR (ParamStr(5) = 'cf') THEN BEGIN
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
        WriteLn('ERROR!');
        Wait(1000);
      END;
    UNTIL (ClearFr = 'YES') OR (ClearFr = 'NO');
    REPEAT
      GotoXY(6,13);
      WriteLn('Centering frame or upper left? Type `center` or `left`:                 ');
      GotoXY(62,14);
      WriteLn('îîîîîîî');
      IF (ParamStr(2) = 'C1') OR (ParamStr(2) = 'c1') OR
         (ParamStr(3) = 'C1') OR (ParamStr(3) = 'c1') OR
         (ParamStr(4) = 'C1') OR (ParamStr(4) = 'c1') OR
         (ParamStr(5) = 'C1') OR (ParamStr(5) = 'c1') THEN BEGIN
        GotoXY(62,13);
        Write('CENTER');
        Centered := 'CENTER';
      END ELSE BEGIN
        GotoXY(62,13);
        ShowCursor;
        SetCursorForm(CuBlock);
        ReadLn(Centered);
        StrUpCase(Centered);
      END;
      IF Centered = 'C' THEN Centered := 'CENTER';
      IF Centered = 'L' THEN Centered := 'LEFT';
      HideCursor;
      IF NOT((Centered = 'CENTER') OR (Centered = 'LEFT')) THEN BEGIN
        GotoXY(62,13);
        WriteLn('ERROR!');
        Wait(1000);
      END;
    UNTIL (Centered = 'CENTER') OR (Centered = 'LEFT');
  END;
  IF LoopAble = 'YES' THEN REPEAT
    PlayMovie;
  UNTIL KeyPressed ELSE PlayMovie;
END;

{------------------------------- MAIN PROGRAM ------------------------------}

BEGIN
  InitCursor;
  Centered := 'CENTER';
  BuildMenu80x25;
  LoadMovie;
  ShowCursor;
  ClearKeyBuff;
  ReadKey;
END.