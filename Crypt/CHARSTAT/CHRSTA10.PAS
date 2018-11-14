PROGRAM Charakter_Statistik;

USES Crt,Dos;

VAR
  Stat : ARRAY[0..255] OF Byte;
  Swap : Byte;
  Data : Char;
  SoF  : FILE OF Byte;
  i,j,
  Size : LongInt;
  Name : STRING;
  CoF  : Text;

BEGIN
  ClrScr;
  TextColor(LightGray);
  WriteLn('CHARSTAT v1.0 (c) 2002 Michael Johne');
  WriteLn('... fÅhrt eine ZeichenhÑufigkeitsanalyse bei einer Datei durch.');
  Write('[Pfad\] Datei: ');
  ReadLn(Name);
  Assign(SoF,Name);
  Reset(SoF);
  Size := FileSize(SoF);
  Close(SoF);
  Assign(CoF,Name);
  Reset(CoF);
  Write('Datei wird gelesen ... ');
  FOR i := 1 TO Size DO BEGIN
    Read(CoF,Data);
    Inc(Stat[Byte(Data)]);
  END;
  Close(CoF);
  WriteLn(Size,' Bytes');
  WriteLn('Sollen die Daten nebenbei mit in eine Datei geschrieben werden? [J/N]');
  REPEAT
    Data := ReadKey;
    Data := UpCase(Data);
  UNTIL Data IN ['Y','J','N'];
  IF Data <> 'N' THEN BEGIN
    Write('Name der Log-Datei: ');
    ReadLn(Name);
  END;
  WriteLn('Tabellenwertzuordnung: dezimaler Wert, Zeichen bzw Bezeichnung, Anzahl, Prozent');
  Window(1,9,80,25);
  FOR i := 0 TO 255 DO BEGIN
    IF i IN [000..031] THEN TextColor(White);
    IF i IN [032..047] THEN TextColor(LightCyan);
    IF i IN [048..057] THEN TextColor(LightRed);
    IF i IN [058..064] THEN TextColor(LightGreen);
    IF i IN [065..090] THEN TextColor(LightBlue);
    IF i IN [091..096] THEN TextColor(LightGreen);
    IF i IN [097..122] THEN TextColor(LightBlue);
    IF i IN [123..127] THEN TextColor(LightGreen);
    IF i IN [127..255] THEN TextColor(LightGray);
    Write(i:4,'  ');
    CASE i OF
      00: Write('NUL');
      01: Write('SOH');
      02: Write('STX');
      03: Write('ETX');
      04: Write('EOT');
      05: Write('ENQ');
      06: Write('ACK');
      07: Write('BEL');
      08: Write('BS ');
      09: Write('HT ');
      10: Write('LF ');
      11: Write('VT ');
      12: Write('FF ');
      13: Write('CR ');
      14: Write('SO ');
      15: Write('SI ');
      16: Write('DLE');
      17: Write('DC1');
      18: Write('DC2');
      19: Write('DC3');
      20: Write('DC4');
      21: Write('NAK');
      22: Write('SYN');
      23: Write('ETB');
      24: Write('CAN');
      25: Write('EM ');
      26: Write('SUB');
      27: Write('ESC');
      28: Write('FS ');
      29: Write('GS ');
      30: Write('RS ');
      31: Write('US ');
      ELSE Write('  ',Chr(i));
    END;
    Write('  ',Stat[i]:6,'  ',Stat[i]*100/Size:4:1,' ≥ ');
    IF i MOD 3 = 0 THEN BEGIN
      WriteLn;
      ReadKey;
    END;
  END;
  IF Data <> 'N' THEN BEGIN
    Assign(CoF,Name);
    Rewrite(CoF);
    WriteLn(CoF,'CHARSTAT V1.0 Log File');
    WriteLn(CoF);
    FOR i := 0 TO 255 DO BEGIN
      Write(CoF,i:4,'  ');
      CASE i OF
        00: Write(CoF,'NUL');
        01: Write(CoF,'SOH');
        02: Write(CoF,'STX');
        03: Write(CoF,'ETX');
        04: Write(CoF,'EOT');
        05: Write(CoF,'ENQ');
        06: Write(CoF,'ACK');
        07: Write(CoF,'BEL');
        08: Write(CoF,'BS ');
        09: Write(CoF,'HT ');
        10: Write(CoF,'LF ');
        11: Write(CoF,'VT ');
        12: Write(CoF,'FF ');
        13: Write(CoF,'CR ');
        14: Write(CoF,'SO ');
        15: Write(CoF,'SI ');
        16: Write(CoF,'DLE');
        17: Write(CoF,'DC1');
        18: Write(CoF,'DC2');
        19: Write(CoF,'DC3');
        20: Write(CoF,'DC4');
        21: Write(CoF,'NAK');
        22: Write(CoF,'SYN');
        23: Write(CoF,'ETB');
        24: Write(CoF,'CAN');
        25: Write(CoF,'EM ');
        26: Write(CoF,'SUB');
        27: Write(CoF,'ESC');
        28: Write(CoF,'FS ');
        29: Write(CoF,'GS ');
        30: Write(CoF,'RS ');
        31: Write(CoF,'US ');
        ELSE Write(CoF,'  ',Chr(i));
      END;
      WriteLn(CoF,'  ',Stat[i]:6,'  ',Stat[i]*100/Size:4:1);
    END;
    Close(CoF);
  END;
  Window(1,1,80,25);
  GotoXY(80,24);
  WriteLn;
  ReadKey;
END.
