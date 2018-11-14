PROGRAM Brownsche_Bewegung;

USES Crt,Dos,Graph;

CONST
  NULL  = Chr(00);
  TAB   = Chr(09);
  ENTER = Chr(13);
  ESC   = Chr(27);
  SPACE = Chr(32);

TYPE
  FourthDim = RECORD
    Year1,Year2,
    Month1,Month2,
    Day1,Day2,
    Dow1,Dow2,
    Hour1,Hour2,
    Min1,Min2,
    Sek1,Sek2,
    MSek1,MSek2  : Word;
    Time,Time2 : Real;
    TimeStr,
    DateStr,
    YearStr,
    MonthStr,
    DayStr   : STRING;
  END;

VAR
  MoveX,MoveY : ARRAY[1..2] OF LongInt;
  MoveXStr,MoveYStr : ARRAY[1..2] OF STRING;
  Special : Boolean;
  In1,Connect,Color,Col,Option,Twilight : Byte;
  a,b,c,i,n,xold,yold,xnew,ynew,RandX,RandY,Driver,Mode,
  Delay,Factor,Distance,Straw : Integer;
  Data1,Data2 : Char;
  Moves : LongInt;
  ColorStr,DelayStr,FactorStr,
  MovesStr : STRING;
  File1    : Text;
  DateTime : FourthDim;

FUNCTION RealToHms(kooD : Real) : STRING;
VAR
  kooG      : STRING;
  Zweistell : String[2];
  dez       : Real;
BEGIN
  kooG := '';
  Str(Trunc(kooD),kooG);
  IF (kooD < 10) AND (kooD > 0) THEN kooG := '0'+kooG;
  kooG := kooG+':';
  dez := Abs(Frac(kooD))*60;
  Str(Trunc(dez),Zweistell);
  IF dez < 10 THEN kooG := kooG+'0';
  kooG := kooG+zweistell+':';
  dez := Abs(Frac(dez))*60;
  Str(dez:2:0,Zweistell);
  IF dez < 10 THEN kooG := kooG+'0'+Copy(Zweistell,2,1)+' ' ELSE kooG := kooG+Zweistell+' ';
  RealToHMS := kooG;
END;

PROCEDURE Cursor(Visible : Boolean);
VAR
  grDriver,grMode : Integer;
  BTXMEM	  : LongInt;
  regs            : Registers;
BEGIN
  grDriver := Detect;
  DetectGraph(grDriver,grMode);
  CASE grDriver OF
    1..6,8..9 : BTXMEM := $B800;
    -2,7,10   : BTXMEM := $B000;
  END;
  regs.ah := 1;
  IF Visible THEN BEGIN
    IF BTXMEM = $B800 THEN BEGIN
      regs.ch := 6;
      regs.cl := 7;
    END
    ELSE
    BEGIN
      regs.ch := 12;
      regs.cl := 13;
    END;
    Intr(16,regs);
  END
  ELSE
  BEGIN
    regs.ch := 32;
    regs.cl := 7;
    Intr(16,regs);
  END;
END;

PROCEDURE Wait(ms : LongInt);
VAR
  Hour,Minute,Second,Sec100 : Word;
  MilliSec,MilliSec1,MilliSec2 : LongInt;
BEGIN
  ms := ms DIV 10;
  GetTime(Hour,Minute,Second,Sec100);
  MilliSec1 := (144000*Hour)+(6000*Minute)+(100*Second)+Sec100;
  REPEAT
    gotoXY(1,1);
    GetTime(Hour,Minute,Second,Sec100);
    MilliSec2 := (144000*Hour)+(6000*Minute)+(100*Second)+Sec100;
  UNTIL ((MilliSec2-MilliSec1) >= ms);
END;

FUNCTION ReadInt(Anzahl : Byte) : LongInt;
VAR
  eingabe,Buffer: STRING[80];
  cf            : Text;
  SaveX,SaveY   : Byte;
  Control       : Integer;
  Zahl          : LongInt;
BEGIN
  IF Anzahl > 11 THEN Anzahl := 11;
  AssignCrt(cf);
  SetTextBuf(cf,Buffer,Anzahl+2);
  Reset(cf);
  SaveX := WhereX;
  SaveY := WhereY;
  REPEAT
    GotoXY(SaveX,SaveY);
    ReadLn(cf,Eingabe);
    IF SaveY = Hi(WindMax)+1 THEN System.Dec(SaveY);
    Val(Eingabe,Zahl,Control);
  UNTIL Control = 0;
  Close(cf);
  GotoXY(SaveX+Length(Eingabe),SaveY);
  ReadInt := Zahl;
END;

PROCEDURE Choose;
BEGIN
  RandX := Random(3);
  a := RandX;
  CASE RandX OF
    0: RandX := 0;
    1: IF Factor = 1 THEN RandX := -1 ELSE RandX := -Random(Factor);
    2: IF Factor = 1 THEN RandX := +1 ELSE RandX := +Random(Factor);
  END;
  RandY := Random(3);
  b := RandY;

  CASE RandY OF
    0: RandY := 0;
    1: IF Factor = 1 THEN RandY := -1 ELSE RandY := -Random(Factor);
    2: IF Factor = 1 THEN RandY := +1 ELSE RandY := +Random(Factor);
  END;
END;

BEGIN
  REPEAT
    Cursor(False);
    TextBackground(Black);
    TextColor(White);
    ClrScr;
    Randomize;
    c := 0;
    Connect  := 1;
    Color    := White;
    Col      := 1;
    Distance := 10;
    Delay    := 0;
    Factor   := 0;
    In1      := 1;
    Moves    := 0;
    Option   := 1;
    Special  := False;
    Straw    := 1;
    Twilight := 1;
    FOR i := 1 TO 3 DO BEGIN
      MoveX[i] := 0;
      MoveY[i] := 0;
    END;
    ASM
      mov AH,10h
      mov AL,03h
      mov BL,0
      int 10h
    END;
    TextBackground(Red);
    TextColor(Blink);
    FOR i := 1 TO 40 DO Write('  ');
    FOR i := 2 TO 13 DO BEGIN
      GotoXY(1,i);
      Write('  ');
      GotoXY(79,i);
      Write('  ');
    END;
    GotoXY(1,14);
    FOR i := 1 TO 160 DO BEGIN
      Write('     ');
    END;
    TextBackground(Black);
    GotoXY(1,1);
    TextColor(White);
    InsLine;
    GotoXY(5,4);
    WriteLn('€€€€€€‹ €€€€€€‹ ‹€€€€€‹ €€ €€ €€ ‹€€€€€‹ ‹€€€€€‹ ‹€€€€€‹ €€   €€ ‹€€€€€€');
    GotoXY(5,5);
    WriteLn('€€‹‹‹€ﬂ €€   €€ €€   €€ €€ €€ €€ €€   €€ €€‹‹‹‹  €€      €€‹‹‹€€ €€‹‹‹‹');
    GotoXY(5,6);
    WriteLn('€€ﬂﬂﬂ€€ €€€€€€  €€   €€ €€ €€ €€ €€   €€  ﬂﬂﬂﬂ€€ €€      €€ﬂﬂﬂ€€ €€ﬂﬂﬂﬂ');
    GotoXY(5,7);
    WriteLn('€€€€€€ﬂ €€  ﬂ€€ ﬂ€€€€€ﬂ ﬂ€€€€€€ﬂ €€   €€ ﬂ€€€€€ﬂ ﬂ€€€€€ﬂ €€   €€ ﬂ€€€€€€');
    GotoXY(5,9);
    WriteLn('€€€€€€‹ ‹€€€€€€ €€ €€ €€ ‹€€€€€€ ‹€€€€€‹ €€   €€ ‹€€€€€‹ ‹€€€€€‹');
    GotoXY(5,10);
    WriteLn('€€‹‹‹€ﬂ €€‹‹‹‹  €€ €€ €€ €€‹‹‹‹  €€  ‹‹‹ €€   €€ €€   €€ €€  ‹‹‹');
    GotoXY(5,11);
    WriteLn('€€ﬂﬂﬂ€€ €€ﬂﬂﬂﬂ  €€ €€ €€ €€ﬂﬂﬂﬂ  €€   €€ €€   €€ €€   €€ €€   €€');
    GotoXY(5,12);
    WriteLn('€€€€€€ﬂ ﬂ€€€€€€ ﬂ€€€€€€ﬂ ﬂ€€€€€€ ﬂ€€€€€ﬂ ﬂ€€€€€ﬂ €€   €€ ﬂ€€€€€ﬂ   v1.3');
    TextBackground(Blue);
    FOR i := 1 TO 9 DO BEGIN
      FOR n := 1 TO 5 DO BEGIN
        GotoXY(67+i,16+n);
        Write(' ');
      END;
    END;
    TextColor(White);
    GotoXY(70,19);
    Write('ENTER');
    TextBackground(Red);
    TextColor(White+Blink);
    GotoXY(5,17);
    Write('Verbindung:');
    GotoXY(9,19);
    Write('- Punkte');
    GotoXY(9,20);
    Write('- Linien');
    TextBackground(Black);
    TextColor(White);
    GotoXY(5,19);
    Write('( )');
    GotoXY(5,20);
    Write('( )');
    TextBackground(Red);
    TextColor(White+Blink);
    GotoXY(23,17);
    Write('Farbauswahl:');
    TextBackground(Black);
    FOR i := 1 TO 15 DO BEGIN
      TextColor(16-i);
      GotoXY(22+i,19);
      Write('a');
    END;
    TextBackground(Red);
    TextColor(White+Blink);
    GotoXY(43,17);
    Write('Optionen:');
    GotoXY(41,19);
    Write(Chr(16),' EindÑmmungsfeld -');
    GotoXY(43,20);
    Write('Zeitverzîgerung:');
    GotoXY(43,21);
    Write('Steuungsfaktor:  ');
    TextBackground(Black);
    TextColor(White);
    Write('   ');
    GotoXY(62,21);
    Write(Straw);
    GotoXY(61,19);
    Write('[ ]');
    GotoXY(60,20);
    Write('    ');
    GotoXY(60,20);
    Write(Delay);
    TextColor(Yellow);
    GotoXY(6,19);
    Write('*');
    GotoXY(62,19);
    Write('x');
    TextColor(White);
    GotoXY(60,20);
    Write(0:4);
    TextBackground(Red);
    TextColor(Yellow+Blink);
    GotoXY(3,17);
    Write(Chr(26));
    TextColor(White+Blink);
    GotoXY(23,20);
    Write(Chr(30));
    GotoXY(05,23);
    Write('SPECIAL: Brownschne Linie');
    REPEAT
      Data1 := ReadKey;
      IF (Data1 = NULL) OR (Data1 = TAB) THEN BEGIN

        IF Data1 = TAB THEN BEGIN
          TextColor(Lightred+Blink);
          GotoXY(3,17);
          Write(' ');
          GotoXY(21,17);
          Write(' ');
          GotoXY(41,17);
          Write(' ');
          TextColor(Yellow+Blink);
          GotoXY(03,23);
          Write(Chr(26));
          REPEAT
            Data1 := ReadKey;
          UNTIL Data1 IN [ENTER,ESC,TAB];

          IF NOT(Data1 IN ([ENTER,ESC])) THEN BEGIN
            CASE In1 OF
              1 : GotoXY(3,17);
              2 : GotoXY(21,17);
              3 : GotoXY(41,17);
            END;
            TextColor(Yellow+Blink);
            Write(Chr(26));
          END ELSE Special := True;;
          TextColor(LightRed+Blink);
          GotoXY(03,23);
          Write(' ');
	END ELSE BEGIN

          Data2 := ReadKey;
          CASE Data2 OF
            'K' : Dec(In1);
            'M' : Inc(In1);
          END;
          IF In1 < 1 THEN In1 := 3;
          IF In1 > 3 THEN In1 := 1;
          TextColor(White+Blink);
          GotoXY(3,17);
          Write(' ');
          GotoXY(21,17);
          Write(' ');
          GotoXY(41,17);
          Write(' ');
          CASE In1 OF
            1 : GotoXY(3,17);
            2 : GotoXY(21,17);
            3 : GotoXY(41,17);
          END;
          TextColor(Yellow+Blink);
          Write(Chr(26));
          IF Data2 IN ['P'] THEN BEGIN
            IF In1 = 1 THEN BEGIN
              GotoXY(3,17);
              TextColor(White+Blink);
              Write(Chr(26));
              TextBackground(Black);
              REPEAT
                IF Data2 = 'P' THEN BEGIN
                  TextColor(White);
                  GotoXY(6,19);
                  Write(' ');
                  TextColor(Yellow);
                  GotoXY(6,20);
                  Write('*');
                  Connect := 2;
                  GotoXY(43,21);
                  TextBackground(Red);
                  TextColor(White+Blink);
                  Write('Distanzierung:   ');
                  TextBackground(Black);
                  TextColor(White);
                  Write('   ');
                  GotoXY(60,21);
                  Write(Distance);
                END ELSE IF Data2 = 'H' THEN BEGIN
                  TextColor(Yellow);
                  GotoXY(6,19);
                  Write('*');
                  TextColor(White);
                  GotoXY(6,20);
                  Write(' ');
                  Connect := 1;
                  GotoXY(43,21);
                  TextBackground(Red);
                  TextColor(White+Blink);
                  Write('Steuungsfaktor:  ');
                  TextBackground(Black);
                  TextColor(White);
                  Write('   ');
                  GotoXY(60,21);
                  Write(Straw);
                END;
                Data2 := ReadKey;
                IF Data2 = NULL THEN Data2 := ReadKey;
              UNTIL Data2 IN ['K','M',ENTER,ESC];
              TextBackground(Red);
              TextColor(Yellow+Blink);
              GotoXY(3,17);
              Write(Chr(26));
            END ELSE IF In1 = 2 THEN BEGIN
              GotoXY(21,17);
              TextColor(White+Blink);
              Write(Chr(26));
              TextColor(Yellow+Blink);
              GotoXY(22+Col,20);
              Write(Chr(30));
              REPEAT
                Data2 := ReadKey;
                IF Data2 IN ['K','M'] THEN BEGIN
                  IF Data2 = 'K' THEN Dec(Col) ELSE IF Data2 = 'M' THEN Inc(Col);
                  IF Col < 1 THEN Col := 15;
                  IF Col > 15 THEN Col := 1;
    	          GotoXY(23,20);
                  FOR i := 1 TO 15 DO Write(' ');
                  GotoXY(22+Col,20);
                  Write(Chr(30));
                  IF Data2 = NULL THEN Data2 := ReadKey;
                END;
              UNTIL Data2 IN ['H','P',ENTER,ESC];
              TextColor(White+Blink);
              GotoXY(22+Col,20);
              Write(Chr(30));
              TextColor(Yellow+Blink);
              GotoXY(21,17);
              Write(Chr(26));
	    END ELSE IF In1 = 3 THEN BEGIN
              GotoXY(41,17);
              TextColor(White+Blink);
              Write(Chr(26));
              REPEAT
                TextColor(Yellow+Blink);
                IF Option = 1 THEN BEGIN
                  GotoXY(41,19);
                  Write(Chr(16));
                  GotoXY(41,20);
                  Write(' ');
                  GotoXY(41,21);
                  Write(' ');
                END ELSE IF Option = 2 THEN BEGIN
                  GotoXY(41,19);
                  Write(' ');
                  GotoXY(41,20);
                  Write(Chr(16));
                  GotoXY(41,21);
                  Write(' ');
                END ELSE IF Option = 3 THEN BEGIN
                  GotoXY(41,19);
                  Write(' ');
                  GotoXY(41,20);
                  Write(' ');
                  GotoXY(41,21);
                  Write(Chr(16));
                END;
                Data2 := ReadKey;
                IF (Data2 = SPACE) AND (Option = 1) THEN BEGIN
                  TextBackground(Black);
                  TextColor(Yellow);
                  GotoXY(62,19);
                  IF Twilight = 1 THEN BEGIN
	            Write(' ');
                    Twilight := 0;
  	          END ELSE IF Twilight = 0 THEN BEGIN
  	            Write('x');
                    Twilight := 1;
                  END;
                  TextBackground(Red);
                END ELSE IF (Data2 = SPACE) AND (Option = 2) THEN BEGIN
                  TextBackground(Black);
                  TextColor(White);
                  GotoXY(60,20);
                  Write('    ');
                  Cursor(True);
                  GotoXY(60,20);
                  Delay := ReadInt(4);
                  Cursor(False);
                  TextBackground(Red);
                END ELSE IF (Data2 = SPACE) AND (Option = 3) THEN BEGIN
                  TextBackground(Black);
                  TextColor(White);
                  GotoXY(60,21);
                  Write('   ');
                  Cursor(True);
                  GotoXY(60,21);
                  IF Connect = 1 THEN Straw := ReadInt(3) ELSE IF Connect = 2 THEN Distance := ReadInt(3);
                  Cursor(False);
                  TextBackground(Red);
                END;
                IF Data2 IN ['P','H',SPACE] THEN BEGIN
                  IF (Option=1) AND (Data2='P') THEN BEGIN
                    Option := 2;
	          END ELSE IF (Option=2) AND (Data2='P') THEN BEGIN
                    Option := 3;
	          END ELSE IF (Option=2) AND (Data2='H') THEN BEGIN
                    Option := 1;
	          END ELSE IF (Option=3) AND (Data2='H') THEN BEGIN
                    Option := 2;
	  	  END;
                  IF Data2 = NULL THEN Data2 := ReadKey;
                END;
              UNTIL Data2 IN ['K','M',ENTER,ESC];
              TextBackground(Red);
              TextColor(White+Blink);
              IF Option = 1 THEN BEGIN
                GotoXY(41,19);
                Write(Chr(16));
                GotoXY(41,20);
                Write(' ');
                GotoXY(41,21);
                Write(' ');
              END;
	      IF Option = 2 THEN BEGIN
                GotoXY(41,19);
                Write(' ');
                GotoXY(41,20);
                Write(Chr(16));
                GotoXY(41,21);
                Write(' ');
              END;
	      IF Option = 3 THEN BEGIN
                GotoXY(41,19);
                Write(' ');
                GotoXY(41,20);
                Write(' ');
                GotoXY(41,21);
                Write(Chr(16));
              END;
              TextColor(Yellow+Blink);
              GotoXY(41,17);
              Write(Chr(26));
            END;
          END;
        END;
      END;
    UNTIL (Data1 = ENTER) OR (Data1 = ESC);
    IF Data1 = ESC THEN Halt;
    TextBackground(Blue);
    TextColor(White+Blink);
    FOR i := 1 TO 9 DO BEGIN
      FOR n := 1 TO 5 DO BEGIN
        GotoXY(67+i,16+n);
        Write(' ');
      END;
    END;
    GotoXY(70,19);
    Write('ENTER');
    Wait(240);
    TextBackground(Blue);
    TextColor(White);
    FOR i := 1 TO 9 DO BEGIN
      FOR n := 1 TO 5 DO BEGIN
        GotoXY(67+i,16+n);
        Write(' ');
      END;
    END;
    GotoXY(70,19);
    Write('ENTER');
    Wait(240);
    Color := 16-Col;
    Driver := Detect;
    InitGraph(Driver,Mode,'');

    IF Special = True THEN BEGIN
      yold := 480 DIV 2;
      ynew := 480 DIV 2;
      REPEAT
        SetColor(Red);
        Line(1,480 DIV 2,640,480 DIV 2);
        SetColor(White);
        FOR i := 1 TO 640 DO BEGIN
          PutPixel(i,ynew,White);
          yold := ynew;

          RandY := Random(3);
          CASE RandY OF
            0 : RandY := 0;
            1 : RandY := -1;
            2 : RandY := +1;
          END;

          ynew := yold+RandY;
        END;
        Data1 := ReadKey;
        ClearDevice;
      UNTIL Data1 = ESC;

    END ELSE BEGIN

      WITH DateTime DO BEGIN
        GetTime(Hour2,Min2,Sek2,MSek2);
        Time2 := Hour2+(Min2/60)+(Sek2/3600);
      END;
      xold := 640 DIV 2;
      yold := 480 DIV 2;
      xnew := 640 DIV 2;
      ynew := 480 DIV 2;
      IF Connect = 1 THEN Factor := Straw ELSE IF Connect = 2 THEN Factor := Distance;
      IF Factor = 0 THEN IF Connect = 1 THEN Factor := Straw ELSE IF Connect = 2 THEN Factor := Distance;
      REPEAT
        Inc(Moves,2);
        IF Delay <> 0 THEN Wait(Delay);
        IF Connect = 1 THEN BEGIN
          PutPixel(xnew,ynew,Color)
        END ELSE BEGIN
          SetColor(Color);
          Line(xold,yold,xnew,ynew);
        END;
        xold := xnew;
        yold := ynew;
        IF Twilight = 1 THEN BEGIN
          REPEAT
            Choose;
          UNTIL ((xold+RandX > 0) AND (xold+RandX < 640)) AND ((yold+RandY > 0) AND (yold+RandY < 480));
        END ELSE IF Twilight = 0 THEN BEGIN
          Choose;
        END;
        CASE a OF
          1: Inc(MoveX[1]);
          2: Inc(MoveX[2]);
        END;
        CASE b OF
          1: Inc(MoveY[1]);
          2: Inc(MoveY[2]);
        END;
        xnew := xold+RandX;
        ynew := yold+RandY;
      UNTIL (Keypressed) OR (Moves>2147483647-10);
    END;
    WITH DateTime DO BEGIN
      GetDate(Year1,Month1,Day1,Dow1);
      GetTime(Hour1,Min1,Sek1,MSek1);
      Time := Hour1+(Min1/60)+(Sek1/3600);
      Time2 := Time-Time2;
      TimeStr := RealToHms(Time);
      Str(Year1,YearStr);
      Str(Month1,MonthStr);
      Str(Day1,DayStr);
      DateStr := YearStr+'-'+MonthStr+'-'+DayStr;
    END;
    ASM
      mov ax,$0C06;
      mov dl,$FF;
      int $21
    END;
    Assign(File1,'BROWN.LOG');
    Rewrite(File1);
    SetFillStyle(SolidFill,Blue);
    Bar(0+50,0+50,640-50,480-50);
    SetColor(DarkGray);
    Rectangle(0+50,0+50,640-50,480-50);
    SetColor(LightGray);
    Rectangle(0+51,0+51,640-51,480-51);
    SetColor(White);
    Rectangle(0+52,0+52,640-52,480-52);
    SetColor(LightGray);
    Rectangle(0+53,0+53,640-53,480-53);
    SetColor(DarkGray);
    Rectangle(0+54,0+54,640-54,480-54);
    SetColor(White);
    SetTextStyle(2,HorizDir,6);
    OutTextXY((640-TextWidth('BERICHT')) DIV 2,100,'BERICHT');
    Line(640-TextWidth('BERICHT'),135,TextWidth('BERICHT'),135);
    WriteLn(File1,'BERICHT');
    WriteLn(File1,'-------');
    WriteLn(File1);
    SetColor(LightCyan);
    SetTextStyle(2,HorizDir,4);
    OutTextXY(70,145,'Bericht wurde am '+DateTime.DateStr+' um '+DateTime.TimeStr+'erstellt.');
    WriteLn(File1,'Bericht wurde am '+DateTime.DateStr+' um '+DateTime.TimeStr+'erstellt.');
    WriteLn(File1);
    SetTextStyle(2,HorizDir,5);
    SetColor(Yellow);
    OutTextXY(70,165,'Folgende Optionen wurden gewÑhlt:');
    WriteLn(File1,'Folgende Optionen wurden gewÑhlt:');
    SetTextStyle(2,HorizDir,4);
    SetColor(White);
    OutTextXY(85,185,'Verbindung');
    OutTextXY(85,195,'Farbauswahl');
    OutTextXY(85,205,'EindÑmmungsfeld');
    OutTextXY(85,215,'Zeitverzîgerung');
    IF Connect = 1 THEN OutTextXY(85,225,'Streuungsfaktor') ELSE IF Connect = 2 THEN OutTextXY(85,225,'Distanzierung');
    FOR i := 1 TO 5 DO BEGIN
      OutTextXY(230,175+(10*i),'-');
    END;
    SetColor(LightRed);
    IF Connect = 1 THEN OutTextXY(290,185,'Punkte') ELSE IF Connect = 2 THEN OutTextXY(290,185,'Linien');
    Str(Color,ColorStr);
    OutTextXY(290,195,ColorStr);
    IF Twilight = 0 THEN OutTextXY(290,205,'Ausgeschaltet') ELSE IF Twilight = 1 THEN OutTextXY(290,205,'Eingeschaltet');
    Str(Delay,DelayStr);
    OutTextXY(290,215,DelayStr+' Millisekunden');
    Str(Factor,FactorStr);
    OutTextXY(290,225,FactorStr);
    Write(File1,'Verbindung      - ');
    IF Connect = 1 THEN WriteLn(File1,'Punkte') ELSE IF Connect = 2 THEN WriteLn(File1,'Linien');
    WriteLn(File1,'Farbauswahl     - '+ColorStr);
    Write(File1,'EindÑmmungsfeld - ');
    IF Twilight = 0 THEN WriteLn(File1,'Ausgeschaltet') ELSE IF Twilight = 1 THEN WriteLn(File1,'Eingeschaltet');
    WriteLn(File1,'Zeitverzîgerung - '+DelayStr+' Sekunden');
    IF Connect = 1 THEN Write(File1,'Streuungsfaktor - ') ELSE IF Connect = 2 THEN Write(File1,'Distanzierung   - ');
    WriteLn(File1,FactorStr);
    WriteLn(File1);
    WriteLn(File1,'Resultat:');
    SetTextStyle(2,HorizDir,5);
    SetColor(Yellow);
    OutTextXY(70,250,'Resultat:');
    SetTextStyle(2,HorizDir,4);
    SetColor(White);
    OutTextXY(70,270,'Es wurden');
    SetColor(LightRed);
    Str(Moves,MovesStr);
    OutTextXY(130,270,MovesStr);
    SetColor(White);
    OutTextXY(140+TextWidth(MovesStr),270,'Bewegungen registriert.');
    WriteLn(File1,'Es wurden '+MovesStr+' Bewegungen registriert.');
    OutTextXY(70,280,'Dabei wurden');
    SetColor(LightRed);
    Str(MoveX[1]+MoveX[2],MoveXStr[1]);
    OutTextXY(150,280,MoveXStr[1]);
    SetColor(White);
    OutTextXY(160+TextWidth(MoveXStr[1]),280,'Bewegungen in horizontaler Achse wahrgenommen');
    WriteLn(File1,'Dabei wurden '+MoveXStr[1]+' Bewegungen in horizontaler Achse wahrgenommen');
    OutTextXY(70,290,'und');
    SetColor(LightRed);
    Str(MoveY[1]+MoveY[2],MoveYStr[1]);
    OutTextXY(100,290,MoveYStr[1]);
    SetColor(White);
    OutTextXY(110+TextWidth(MoveYStr[1]),290,'Bewegungen zeigten sich in vertikaler Achse.');
    WriteLn(File1,'und '+MoveYStr[1]+' Bewegungen zeigten sich in vertikaler Achse.');
    OutTextXY(70,300,'Es waren');
    SetColor(LightRed);
    Str(Moves-MoveX[1]-MoveX[2]-MoveY[1]-MoveY[2],MoveXStr[2]);
    OutTextXY(130,300,MoveXStr[2]);
    SetColor(White);
    OutTextXY(140+TextWidth(MoveXStr[2]),300,'Bewegungen inaktiv.');
    WriteLn(File1,'Es waren '+MoveXStr[2]+' Bewegungen inaktiv.');
    OutTextXY(70,310,'In horizontaler Richtung waren');
    SetColor(LightRed);
    Str(MoveX[1],MoveXStr[1]);
    OutTextXY(250,310,MoveXStr[1]);
    SetColor(White);
    OutTextXY(260+TextWidth(MoveXStr[1]),310,'Bewegungen negativ');
    WriteLn(File1,'In horizontaler Richtung waren '+MoveXStr[1]+' Bewegungen negativ');
    OutTextXY(70,320,'und');
    SetColor(LightRed);
    Str(MoveX[2],MoveXStr[2]);
    OutTextXY(100,320,MoveXStr[2]);
    SetColor(White);
    OutTextXY(110+TextWidth(MoveXStr[2]),320,'Bewegungen positiv.');
    WriteLn(File1,'und '+MoveXStr[2]+' Bewegungen positiv');
    OutTextXY(70,330,'In vertikaler Richtung waren');
    SetColor(LightRed);
    Str(MoveY[1],MoveYStr[1]);
    OutTextXY(240,330,MoveYStr[1]);
    SetColor(White);
    OutTextXY(250+TextWidth(MoveYStr[1]),330,'Bewegungen negativ');
    WriteLn(File1,'In vertikaler Richtung waren '+MoveYStr[1]+' Bewegungen negativ');
    OutTextXY(70,340,'und');
    SetColor(LightRed);
    Str(MoveY[2],MoveYStr[2]);
    OutTextXY(100,340,MoveYStr[2]);
    SetColor(White);
    OutTextXY(110+TextWidth(MoveYStr[2]),340,'Bewegungen positiv.');
    WriteLn(File1,'und '+MoveYStr[2]+' Bewegungen positiv');
    DateTime.TimeStr := RealToHms(DateTime.Time2);
    OutTextXY(70,350,'Der gesamte Vorgang dauerte');
    SetColor(LightRed);
    OutTextXY(240,350,DateTime.TimeStr);
    SetColor(White);
    OutTextXY(240+TextWidth(DateTime.TimeStr),350,'(Stunden/Minuten/Sekunden).');
    WriteLn(File1,'Der gesamte Vorgang dauerte '+DateTime.TimeStr+'(Stunden/Minuten/Sekunden).');
    IF DateTime.Time2 = 0 THEN DateTime.Time2 := 0.001;
    DateTime.Time2 := Round(Moves/(DateTime.Time2*3600));
    Str(DateTime.Time2:0:0,DateTime.TimeStr);
    OutTextXY(70,360,'Es wurden dabei rund ');
    SetColor(LightRed);
    OutTextXY(200,360,DateTime.TimeStr);
    SetColor(White);
    OutTextXY(210+TextWidth(DateTime.TimeStr),360,'Bewegungen pro Sekunde durchgefÅhrt.');
    WriteLn(File1,'Es wurden dabei rund '+DateTime.TimeStr+' Bewegungen pro Sekunde durchgefÅhrt.');
    SetColor(LightCyan);
    OutTextXY(70,400,'Bericht wurde in der Datei BROWN.LOG abgespeichert.');
    SetTextStyle(2,HorizDir,5);
    SetColor(White);
    OutTextXY(500,400,'- ENDE -');
    WriteLn(File1);
    WriteLn(File1,'- ENDE -');
    Close(File1);
    ReadKey;


    CloseGraph;
    RestoreCrtMode;
  UNTIL Data1 = ESC;
  ASM
    mov AH,10h
    mov AL,03h
    mov BL,1
    int 10h
  END;
END.
