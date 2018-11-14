PROGRAM Caesar_Code;

USES
  Crt,Dos;

VAR
  FileData    : ARRAY[1..64000] OF Char;
  Delta,
  Crypt       : Byte;
  CryptMode,
  WhatToCrypt,
  Eingabe     : Char;
  CodeFile    : Text;
  FileOfSize  : FILE OF Byte;
  CryptFile   : STRING[12];
  i,
  SizeOfFile  : LongInt;

BEGIN
  TextBackGround(Black);
  ClrScr;
  TextColor(White);
  TextBackground(Red);
  WriteLn('                                                                               ');
  WriteLn('                                                                               ');
  WriteLn('            ﾛﾟﾟﾟ ﾛﾟﾟﾛ ﾛﾟﾟﾟ ﾛﾟﾟﾟ ﾛﾟﾟﾛ ﾛﾟﾟﾛ     ﾛﾟﾟﾟ ﾛﾟﾟﾛ ﾟﾛﾟﾟﾛ ﾛﾟﾟﾟ             ');
  WriteLn('            ﾛ    ﾛﾟﾟﾛ ﾛﾟ   ﾟﾟﾟﾛ ﾛﾟﾟﾛ ﾛﾟﾛﾟ ﾟﾟﾟ ﾛ    ﾛ  ﾛ  ﾛ  ﾛ ﾛﾟ               ');
  WriteLn('            ﾟﾟﾟﾟ ﾟ  ﾟ ﾟﾟﾟﾟ ﾟﾟﾟﾟ ﾟ  ﾟ ﾟ ﾟﾟ     ﾟﾟﾟﾟ ﾟﾟﾟﾟ ﾟﾟﾟﾟﾟ ﾟﾟﾟﾟ             ');
  WriteLn('                     Version 1.0a DOS TP-7.0    (C) MJ 2001                    ');
  WriteLn('                                                                               ');
  TextBackground(Black);
  WriteLn;
  WriteLn;
  TextColor(LightGray);
  WriteLn(' Will man eine Datei (=a) ver/entschl《seln oder einen eingegebenen Text (=b)?');
  TextColor(White);
  Write  (' WhatToCrypt = ');
  REPEAT
    WhatToCrypt := ReadKey;
  UNTIL WhatToCrypt IN ['A','a','B','b'];
  Write  (WhatToCrypt);
  WriteLn;
  TextColor(LightGray);
  WriteLn(' Um wieviele Einheiten soll verschoben werden?');
  TextColor(White);
  Write  (' Delta = ');
  ReadLn(Delta);
  TextColor(LightGray);
  Write  (' Soll ');
  IF WhatToCrypt IN ['A','a'] THEN Write('die Datei')
                              ELSE Write('der Text');
  WriteLn(' verschl《selt (=1) oder entschl《selt (=0)?');
  TextColor(White);
  Write  (' CryptMode = ');
  REPEAT
    CryptMode := ReadKey;
  UNTIL CryptMode IN ['0'..'1'];
  Write  (CryptMode);
  TextColor(LightGray);
  WriteLn;
  IF WhatToCrypt IN ['A','a'] THEN BEGIN {Datei}
    Write  (' Name der Datei zum ');
    IF CryptMode = '1' THEN Write('Ver') ELSE Write('Ent');
    Write  ('schl《seln: ');
    TextColor(White);
    ReadLn(CryptFile);
    Assign(FileOfSize,CryptFile);
    Reset(FileOfSize);
    SizeOfFile := FileSize(FileOfSize);
    Close(FileOfSize);
    Assign(CodeFile,CryptFile);
    Reset(CodeFile);
    TextColor(Cyan);
    WriteLn(' Datei ist ge杷fnet.');
    Write  (' Dateiinhalt wird gelesen... ');
    FOR i := 1 TO SizeOfFile DO Read(CodeFile,FileData[i]);
    WriteLn('Fertig!');
    Close(CodeFile);
    Write  (' Ausgabedatei ist "',CryptFile,'"...');
    Assign(CodeFile,CryptFile);
    ReWrite(CodeFile);
    FOR i := 1 TO SizeOfFile DO BEGIN
      IF CryptMode = '1' THEN Crypt := Delta+Ord(FileData[i])
                         ELSE Crypt := Ord(FileData[i])-Delta;
      Write(CodeFile,Chr(Crypt));
    END;
    Close(CodeFile);
    WriteLn(' Fertig!');
    TextColor(White);
  END ELSE BEGIN {Text}
    TextColor(LightGray);
    WriteLn(' Wie soll die Datei hei疇n, in die der Text gespeichert wird?');
    Write(' ');
    TextColor(White);
    ReadLn(CryptFile);
    Assign(CodeFile,CryptFile);
    Rewrite(CodeFile);
    TextColor(Yellow);
    FOR i := 1 TO 9 DO BEGIN
      GotoXY(1,8+i);
      ClrEoL;
    END;
    GotoXY(1,9);
    Write  ('Sie k馬nen jetzt beginnen, den Text einzugeben. Der ');
    IF CryptMode = '1' THEN Write('ver') ELSE Write ('ent');
    Write  ('schl《selte');
    WriteLn(' Text wird');
    Write  ('automatisch in der Datei "',CryptFile,'" abgelegt. Ende mit ESC!');
    WriteLn;
    WriteLn;
    Window(WhereX,WhereY,80,25);
    TextColor(White);
    TextBackground(Cyan);
    ClrScr;
    REPEAT
      Eingabe := ReadKey;
      IF Eingabe = #27 THEN Break;
      IF Eingabe = #08 THEN Continue;
      IF Eingabe = #13 THEN WriteLn ELSE IF Eingabe = #8 THEN Write(#8,' ',#8) ELSE Write(Eingabe);
      IF CryptMode = '1' THEN Crypt := Delta+Ord(Eingabe)
                         ELSE Crypt := Ord(Eingabe)-Delta;
      Write(CodeFile,Chr(Crypt));
    UNTIL Eingabe = #27;
    Window(1,1,80,25);
    Close(CodeFile);
    TextBackGround(Black);
    ClrScr;
  END;
END.