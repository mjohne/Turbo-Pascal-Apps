PROGRAM MouseTester;

USES Crt, Dos, Graph;

TYPE MouseParamTyp = ARRAY[1..4] OF Word;

VAR
  Flag                   : Boolean;
  WhereY                 : Byte;
  Driver,Mode,Numerator  : Integer;
  BTXMEM                 : LongInt;
  MouseParam             : MouseParamTyp;
  reg                    : Registers;

PROCEDURE Wait(ms : Word); ASSEMBLER; {Cpu-independent delay}
ASM
  mov ax, 1000;
  mul ms;
  mov cx, dx;
  mov dx, ax;
  mov ah, $86;
  Int $15;
END;

PROCEDURE Cursor(Visible : Boolean);
BEGIN
  Driver := Detect;
  DetectGraph(Driver,Mode);
  CASE Driver OF
    1..6,8..9 : BTXMEM := $B800;
    -2,7,10   : BTXMEM := $B000;
  END;
  reg.ah := 1;
  IF Visible THEN BEGIN
    IF BTXMEM = $B800 THEN BEGIN
      reg.ch := 6;
      reg.cl := 7;
    END
    ELSE
    BEGIN
      reg.ch := 12;
      reg.cl := 13;
    END;
    Intr(16,reg);
  END
  ELSE
  BEGIN
    reg.ch := 32;
    reg.cl := 7;
    Intr(16,reg);
  END;
END;

PROCEDURE Frame(x1, y1, x2, y2 : Integer; Color : Byte);
BEGIN
  TextColor(Color);
  GotoXY(x1,y1);
  Write(Chr(218));
  FOR Numerator := x1+1 TO x2-1 DO Write(Chr(196));
  Write(Chr(191));
  FOR Numerator := y1+1 TO y2-1 DO BEGIN
    GotoXY(x1,Numerator);
    Write(Chr(179));
    GotoXY(x2,Numerator);
    Write(Chr(179));
  END;
  GotoXY(x1,y2);
  Write(Chr(192));
  FOR Numerator := x1+1 TO x2-1 DO Write(Chr(196));
  Write(Chr(217));
END;

PROCEDURE Mouse(VAR MouseParam : MouseParamTyp);
BEGIN
  INLINE($55/$89/$E5/$C4/$7E/$06/$26/$8B/$05/$8B/$5D/$02/
         $8B/$4D/$04/$8B/$55/$06/$CD/$33/$26/$89/$05/$89/
         $5D/$02/$89/$4D/$04/$89/$55/$06/$89/$EC/$5D);
END;

BEGIN
  ClrScr;
  Flag := False;
  IF Mem[MemW[0:$CC+2]:MemW[0:$CC]] = $CF THEN BEGIN
    Write('Mouse Driver not installed! Load MOUSE.COM!');
    Halt;
  END;
  Cursor(False);
  TextBackGround(Blue);
  TextColor(White);
  FOR Numerator := 1 TO 80*24 DO Write('²');
  TextColor(White);
  GotoXY(1,1);
  InsLine;
  GotoXY(13,1);
  Write('Mouse Tester Version 1.0     By Michael Johne (C) 2000');
  TextBackGround(Red);
  WhereY := 6;
  FOR Numerator := 1 TO 16 DO BEGIN
    GotoXY(43,WhereY);
    Inc(WhereY);
    Write('                        ');
  END;
  Frame(43,6,66,21,White);
  GotoXY(54,6);
  Write(Chr(193),Chr(193));
  TextColor(Yellow);
  WhereY := 8;
  FOR Numerator := 1 TO 5 DO BEGIN
    GotoXY(46,WhereY);
    Write('°°°°°°°');
    Inc(WhereY);
  END;
  WhereY := 8;
  FOR Numerator := 1 TO 5 DO BEGIN
    GotoXY(57,WhereY);
    Write('°°°°°°°');
    Inc(WhereY);
  END;
  TextBackGround(Green);
  WhereY := 6;
  FOR Numerator := 1 TO 16 DO BEGIN
    GotoXY(13,WhereY);
    Inc(WhereY);
    Write('                        ');
  END;
  Frame(13,6,36,21,White);
  TextColor(Black);
  GotoXY(14,7);
  Write('Put a  button  of  the');
  GotoXY(14,8);
  Write('mouse and you can  see');
  GotoXY(14,9);
  Write('on  the  right  side ,');
  GotoXY(14,10);
  Write('which  button you have');
  GotoXY(14,11);
  Write('pressed now!');
  GotoXY(14,12);
  Write('Click to the top upper');
  GotoXY(14,13);
  Write('right on the " X " and');
  GotoXY(14,14);
  Write('you quit the tester!');
  GotoXY(14,15);
  Write('Button:');
  GotoXY(14,16);
  Write('Coordinates ');
  GotoXY(14,17);
  Write('----------------------');
  GotoXY(14,18);
  Write('Format:   INT   BIT');
  GotoXY(14,19);
  Write('x-axis:');
  GotoXY(14,20);
  Write('y-axis:');
  TextBackGround(Cyan);
  GotoXY(78,1);
  Write(' X ');
  {Maus wird intialisiert}
  MouseParam[1] := 0;
  Mouse(MouseParam);
  MouseParam[1] := 1;
  Mouse(MouseParam);
  MouseParam[1] := 3;
  REPEAT
    Mouse(MouseParam);
    GotoXY(1,2);
    TextColor(White);
    GotoXY(24,19);
    Write(Trunc(MouseParam[3]/8)+1:3);
    GotoXY(30,19);
    Write(MouseParam[3]:3);
    GotoXY(24,20);
    Write(Trunc(MouseParam[4]/8)+1:3);
    GotoXY(30,20);
    Write(MouseParam[4]:3);
    GotoXY(22,15);
    Write(MouseParam[2]);
    TextBackGround(Red);
    TextColor(Yellow);
    IF MouseParam[2] = 1 THEN BEGIN
      WhereY := 8;
      FOR Numerator := 1 TO 5 DO BEGIN
        GotoXY(46,WhereY);
        Write('²²²²²²²');
        Inc(WhereY);
      END;
      Wait(110);
      WhereY := 8;
      FOR Numerator := 1 TO 5 DO BEGIN
        GotoXY(46,WhereY);
        Write('°°°°°°°');
        Inc(WhereY);
      END;
    END;
    IF MouseParam[2] = 2 THEN BEGIN
      WhereY := 8;
      FOR Numerator := 1 TO 5 DO BEGIN
        GotoXY(57,WhereY);
        Write('²²²²²²²');
        Inc(WhereY);
      END;
      Wait(110);
      WhereY := 8;
      FOR Numerator := 1 TO 5 DO BEGIN
        GotoXY(57,WhereY);
        Write('°°°°°°°');
        Inc(WhereY);
      END;
    END;
    IF MouseParam[2] = 3 THEN BEGIN
      WhereY := 8;
      FOR Numerator := 1 TO 5 DO BEGIN
        GotoXY(46,WhereY);
        Write('²²²²²²²');
        Inc(WhereY);
      END;
      WhereY := 8;
      FOR Numerator := 1 TO 5 DO BEGIN
        GotoXY(57,WhereY);
        Write('²²²²²²²');
        Inc(WhereY);
      END;
      Wait(110);
      WhereY := 8;
      FOR Numerator := 1 TO 5 DO BEGIN
        GotoXY(46,WhereY);
        Write('°°°°°°°');
        Inc(WhereY);
      END;
      WhereY := 8;
      FOR Numerator := 1 TO 5 DO BEGIN
        GotoXY(57,WhereY);
        Write('°°°°°°°');
        Inc(WhereY);
      END;
    END;
    TextBackGround(Green);
    IF (MouseParam[2] IN [1..3]) AND
       (MouseParam[3] >= 616) AND
       (MouseParam[3] <= 632) AND
       (MouseParam[4] = 0) THEN Flag := True;
  UNTIL Flag;
  MouseParam[1] := 2; {schaltet den Mauscursor wieder aus}
  Mouse(MouseParam);
  Cursor(True);
  TextBackGround(Black);
  TextColor(White);
  ClrScr;
  WriteLn('Thanks for using this program!!!');
END.