PROGRAM AAM_Player;

USES Crt,Dos,Cursor;

VAR
  i,n,a,b,x,y,
  Frames,
  GlobalDelay,
  Delay         : Integer;
  Col,Row,Title : STRING;
  FileToPlay    : Text;

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

PROCEDURE Center(Row: Integer; Str: STRING);
BEGIN
  Gotoxy(41-Length(Str) DIV 2,Row+(y DIV 2));
  Write(Str);
END;

PROCEDURE ClearFrame;
BEGIN
  FOR b := 1 TO y DO BEGIN
    FOR a := 1 TO x DO BEGIN
      GotoXY(a,b);
      Write(' ');
    END;
  END;
END;

PROCEDURE PlayFile;
BEGIN
  Assign(FileToPlay,ParamStr(1));
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
  GotoXY(5,21);
  WriteLn('Title: ',Title);
  FOR n := 1 TO Frames DO BEGIN
    {ClearFrame;}
    FOR i := 1 TO y DO BEGIN
      ReadLn(FileToPlay,Row);
      Center(i,Row);
      GotoXY(5,22);
      WriteLn('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
      GotoXY(6+Round(30*n/Frames),22);
      WriteLn('³');
      GotoXY(38,22);
      Write(n,'/',Frames);
      GotoXY(47,22);
      Write(n/Frames*100:6:2,'%');
    END;
    IF GlobalDelay = 1 THEN Wait(Delay) ELSE BEGIN
      ReadLn(FileToPlay,Delay);
      Wait(Delay);
    END;
  END;
  Close(FileToPlay);
END;

BEGIN
  ClrScr; {´³²±°¯®¸¹º»¼¿À Á Â Ã Ä Å È É ÊËÌÍÎ ÙÚ Û Ü ß}
  TextColor(White);
  HideCursor;
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
  WriteLn('  (AAM)-Player 1.0');
  GotoXY(57,23);
  WriteLn('    M. Johne 2005');
  IF ParamStr(2) = 'l' THEN REPEAT
    PlayFile;
  UNTIL KeyPressed ELSE PlayFile;
  ShowCursor;
  ReadKey;
END.