PROGRAM Slot_Maschine;

USES Crt,Dos;

VAR
  Sieg                            : Boolean;
  Entscheidung                    : Char;
  a,i,Kontrolle,Einsatz,
  Random1,Random2,Random3,Random4,
  GGewinn,GVerlust,Vermoegen,
  Versuch,Gewinn,Verlust,
  R0,R1,R2,R3,R4                  : Integer;
  regs                            : Registers;
  EinsatzStr                      : STRING[3];

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

PROCEDURE Box(x1, y1, x2, y2 : Integer);
BEGIN
  GotoXY(x1,y1);
  Write('Ú');
  FOR a := x1+1 TO x2-1 DO Write('Ä');
  Write('¿');
  FOR a := y1+1 TO y2-1 DO BEGIN
    GotoXY(x1,a);
    Write('³');
    GotoXY(x2,a);
    Write('³');
  END;
  GotoXY(x1,y2);
  Write('À');
  FOR a := x1+1 TO x2-1 DO Write('Ä');
  Write('Ù');
END;

PROCEDURE SlotMaschine;
BEGIN
  TextBackground(Black);
  Normvideo;
  TextBackground(Yellow);
  TextColor(Yellow);
  Write('   Slot Maschine  TP7-Version 1.4    (C) 2006  Programmiert von Michael Johne   ');
  TextBackground(Blue);
  TextColor(White);
  Box(25,5,54,19);
  FOR a := 1 TO 28 DO FOR i := 1 TO 13 DO BEGIN
   GotoXY(25+a,5+i);
   Write(' ');
  END;
  GotoXY(51,17); Write('o');
  TextBackground(LightGray);
  TextColor(Black);
  GotoXY(25,4);
  Write('   S L O T  M A S C H I N E   ');
  TextBackground(Red);
  FOR a := 1 TO 20 DO BEGIN
    FOR i := 1 TO 4 DO BEGIN
      GotoXY(29+a,9+i);
      Write(' ');
    END;
  END;
  TextColor(White);
  Box(30,10,34,14);
  Box(35,10,39,14);
  Box(40,10,44,14);
  Box(45,10,49,14);
  TextColor(White+Blink);
  i := 27;
  FOR a := 1 TO 4 DO BEGIN
    i := i+5;
    GotoXY(i,12);
    Write('²');
  END;
  TextBackground(LightGray);
  TextColor(Black);
  GotoXY(30,17);
  Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  TextBackground(Black);
  GotoXY(48,17);
  Write('  ');
  TextColor(White);
  FOR a := 6 DOWNTO 1 DO BEGIN
    GotoXY(59,8+a);
    Write('ÛÛÛÛ');
  END;
  GotoXY(55,15);
  Write('ÛÛÛÛÛÛÛÛ');
  TextColor(Green);
  FOR a := 1 TO 2 DO BEGIN
    GotoXY(58,6+a);
    Write('ÛÛÛÛÛÛ');
  END;
END;

PROCEDURE Legende;
BEGIN
  TextBackGround(Black);
  TextColor(White);
  Box(2,4,18,10);
  GotoXY(3,5);
  Write('    10 Pkt.');
  GotoXY(3,6);
  Write('    20 Pkt.');
  GotoXY(3,7);
  Write('    30 Pkt.');
  GotoXY(3,8);
  Write('    40 Pkt.');
  GotoXY(3,9);
  Write('   100 Pkt.');
  GotoXY(2,11);
  Write('Punktbewertung ');
  Box(2,12,22,19);
  GotoXY(3,13);
  WriteLn('Einsatz        ');
  GotoXY(3,14);
  WriteLn('Gewinn         ');
  GotoXY(3,15);
  WriteLn('Verlust        ');
  GotoXY(3,16);
  WriteLn('Verm”gen       ');
  GotoXY(3,17);
  WriteLn('Gesamtgewinn   ');
  GotoXY(3,18);
  WriteLn('Gesamtverlust  ');
  GotoXY(2,20);
  Write('Punktestatus   ');
  GotoXY(2,22);
  Write('Bericht       ',Chr(26));
  Box(18,22,64,25);
  GotoXY(67,10);
  Write('Ergebnis ');
  Box(67,4,79,9);
  Box(67,11,79,20);
  GotoXY(68,12);
  Write('Versuch');
  GotoXY(68,13);
  Write('Gewinn ');
  GotoXY(68,14);
  Write('Verlust');
  GotoXY(68,15);
  Write('');
  GotoXY(68,16);
  Write('');
  GotoXY(68,17);
  Write('');
  GotoXY(68,18);
  Write('');
  GotoXY(68,19);
  Write('');
  GotoXY(67,21);
  Write('Statistik ');
END;

PROCEDURE Animation;
BEGIN
  FOR a := 1 TO 8 DO BEGIN
    TextColor(Green);
    GotoXY(58,7+a);
    Write('ÛÛÛÛÛÛ');
    TextColor(Black);
    GotoXY(58,5+a);
    Write('ÛÛÛÛÛÛ');
    Wait(60);
  END;
  FOR a := 1 TO 2 DO BEGIN
    GotoXY(58,7+a);
    Write('ÛÛÛÛÛÛ');
  END;
  TextColor(White);
  FOR a := 6 DOWNTO 1 DO BEGIN
    GotoXY(59,8+a);
    Write('ÛÛÛÛ');
  END;
  GotoXY(55,15);
  Write('ÛÛÛÛÛÛÛÛ');
  TextColor(Green);
  FOR a := 1 TO 2 DO BEGIN
    GotoXY(58,6+a);
    Write('ÛÛÛÛÛÛ');
  END;
  TextColor(Black);
  GotoXY(58,14);
  Write('Û');
  GotoXY(63,14);
  Write('Û');
  GotoXY(63,15);
  Write('Û');
END;

BEGIN
  Randomize;
  TextBackGround(Black);
  ClrScr;
  SlotMaschine;
  Legende;
  regs.ax := $0100;
  regs.cx := $2607;
  Intr(16,regs);
  GotoXY(25,23);
  Write('Willkommen zu der Slot Maschine!');
  TextColor(Cyan+Blink);
  GotoXY(35,24);
  Write('> Enter <');
  ReadKey;
  REPEAT
    REPEAT
      FOR a := 1 TO 45 DO BEGIN
        FOR i := 1 TO 2 DO BEGIN
          GotoXY(18+a,22+i);
          Write(' ');
        END;
      END;
      GotoXY(20,23);
      TextColor(White);
      Write('Zum Starten geben Sie bitte den Einsatz ein:');
      GotoXY(20,24);
      Write('Einsatz (1-100) ist ');
      ReadLn(EinsatzStr);
    UNTIL EinsatzStr <> '';
    Val(EinsatzStr,Einsatz,Kontrolle);
    Einsatz := Round(Einsatz);
  UNTIL (Einsatz >= 0) AND (Einsatz <= 100) AND (Kontrolle = 0);
  Vermoegen := Einsatz;
  FOR a := 1 TO 45 DO BEGIN
    FOR i := 1 TO 2 DO BEGIN
      GotoXY(18+a,22+i); Write(' ');
    END;
  END;
  Random1 := 5;
  Versuch := 0-1;
  Gewinn  := 0;
  Verlust := 0;
  R0 := 0;
  R1 := 0;
  R2 := 0;
  R3 := 0;
  R4 := 0;
  Random1 := 9;
  Random2 := 8;
  Random3 := 7;
  Random4 := 6;
  REPEAT
    Sieg := False;
    TextBackGround(Black);
    GotoXY(19,13);
    Write(Einsatz:3);
    GotoXY(19,17);
    Write(GGewinn:3);
    GotoXY(19,18);
    Write(GVerlust:3);
    Inc(Versuch);
    GotoXY(76,12);
    Write(Versuch:3);
    GotoXY(76,13);
    Write(Gewinn:3);
    GotoXY(76,14);
    Write(Verlust:3);
    GotoXY(76,15);
    Write(R0:3);
    GotoXY(76,16);
    Write(R1:3);
    GotoXY(76,17);
    Write(R2:3);
    GotoXY(76,18);
    Write(R3:3);
    GotoXY(76,19);
    Write(R4:3);
    IF (Random1 = Random2) AND
       (Random1 = Random3) AND
       (Random1 = Random4) THEN BEGIN
      Sieg := True;
      GotoXY(20,14);
      Write(Random1*10+10);
      Vermoegen := Vermoegen+(Random1*10+10);
      GotoXY(19,16);
      Write(Vermoegen:3);
      GGewinn := GGewinn+(Random1*10+10);
      GotoXY(19,17);
      Write(GGewinn:3);
      Inc(Gewinn);
      GotoXY(76,13);
      Write(Gewinn:3);
      GotoXY(76,15+Random1);
      CASE Random1 OF
        0 : BEGIN
              Inc(R0);
              Write(R0:3);
            END;
        1 : BEGIN
              Inc(R1);
              Write(R1:3);
            END;
        2 : BEGIN
              Inc(R2);
              Write(R2:3);
            END;
        3 : BEGIN
              Inc(R3);
              Write(R3:3);
            END;
      END;
    END ELSE IF (Random1 = 0) AND
                (Random2 = 1) AND
                (Random3 = 2) AND
                (Random4 = 3) THEN BEGIN
      Sieg := True;
      GotoXY(19,14);
      Write('100');
      Vermoegen := Vermoegen+100;
      GotoXY(19,16);
      Write(Vermoegen:3);
      GGewinn := GGewinn+100;
      GotoXY(19,17);
      Write(GGewinn:3);
      Inc(R4);
      GotoXY(76,19);
      Write(R4:3);
      Inc(Gewinn);
      GotoXY(76,13);
      Write(Gewinn:3);
    END ELSE BEGIN
      Inc(Verlust);
      GotoXY(76,14);
      Write(Verlust-1:3);
      IF Random1 <> 5 THEN BEGIN
        GotoXY(21,15);
        Write('1');
        Dec(Vermoegen);
        GotoXY(19,16);
        Write(Vermoegen:3);
        GVerlust := GVerlust+1;
        GotoXY(19,18);
        Write(GVerlust:3);
      END;
    END;
    FOR a := 1 TO 45 DO BEGIN
      FOR i := 1 TO 2 DO BEGIN
        GotoXY(18+a,22+i);
        Write(' ');
      END;
    END;
    TextBackGround(Black);
    Window(68,5,78,8);
    GotoXY(1,4);
    WriteLn;
    IF Sieg = True THEN TextColor(LightGreen) ELSE TextColor(LightRed);
    IF Versuch <> 0 THEN BEGIN
      CASE Random1 OF
        0 : Write('');
        1 : Write('');
        2 : Write('');
        3 : Write('');
      END;
      CASE Random2 OF
        0 : Write('');
        1 : Write('');
        2 : Write('');
        3 : Write('');
      END;
      CASE Random3 OF
        0 : Write('');
        1 : Write('');
        2 : Write('');
        3 : Write('');
      END;
      CASE Random4 OF
        0 : Write('');
        1 : Write('');
        2 : Write('');
        3 : Write('');
      END;
      IF Sieg = True THEN BEGIN
        Write(' + ');
        IF (Random1 = 0) AND
           (Random2 = 1) AND
           (Random3 = 2) AND
           (Random4 = 3) THEN Write(100:3) ELSE Write(Random1*10+10:3);
      END ELSE BEGIN
        Write(' - ',1:3);
      END;
    END;
    Window(1,1,80,25);
    TextColor(White);
    GotoXY(24,23);
    Write('Tastenbedienung w„hrend des Spiels');
    GotoXY(22,24);
    TextColor(Cyan+Blink);
    Write('ENTER zum Beginnen oder ESC zu Abbruch');
    REPEAT
      Entscheidung := ReadKey;
    UNTIL Entscheidung IN [#13,#27];
    IF (Entscheidung = #27) OR (Vermoegen <= 0) THEN BEGIN
      TextBackGround(Black);
      TextColor(White);
      Exit;
    END;
    IF Entscheidung = #13 THEN BEGIN
      Animation;
      TextBackground(Red);
      TextColor(White);
      Random1 := Random(4);
      Random2 := Random(4);
      Random3 := Random(4);
      Random4 := Random(4);
    END;
    GotoXY(32,12);
    CASE Random1 OF
      0 : Write('');
      1 : Write('');
      2 : Write('');
      3 : Write('');
    END;
    GotoXY(37,12);
    CASE Random2 OF
      0 : Write('');
      1 : Write('');
      2 : Write('');
      3 : Write('');
    END;
    GotoXY(42,12);
    CASE Random3 OF
      0 : Write('');
      1 : Write('');
      2 : Write('');
      3 : Write('');
    END;
    GotoXY(47,12);
    CASE Random4 OF
      0 : Write('');
      1 : Write('');
      2 : Write('');
      3 : Write('');
    END;
  UNTIL Entscheidung = #27;
  regs.ax := $0100;
  regs.cx := $0506;
  Intr(16,regs);
END.
