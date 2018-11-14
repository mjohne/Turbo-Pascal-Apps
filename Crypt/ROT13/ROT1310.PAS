PROGRAM ROT13_Code;

USES
  Crt,Dos;

CONST
  Delta = 13;

VAR
  Percent,
  Crypt       : Byte;
  FileData,
  CryptMode,
  WhatToCrypt,
  Eingabe     : Char;
  CodeFile1,
  CodeFile2   : Text;
  FileOfSize  : FILE OF Byte;
  CryptFile1,
  CryptFile2  : STRING[12];
  i,
  SizeOfFile  : LongInt;

BEGIN
  TextBackGround(Black);
  ClrScr;
  TextColor(White);
  TextBackground(Red);
  WriteLn('                                                                               ');
  WriteLn('                                                                               ');
  WriteLn('               ﾛﾟﾟﾛ ﾛﾟﾟﾛ ﾟﾟﾛﾟﾟ  ﾛ ﾟﾟﾟﾛ     ﾛﾟﾟﾟ ﾛﾟﾟﾛ ﾟﾛﾟﾟﾛ ﾛﾟﾟﾟ                ');
  WriteLn('               ﾛﾟﾛﾟ ﾛ  ﾛ   ﾛ    ﾛ   ﾟﾛ ﾟﾟﾟ ﾛ    ﾛ  ﾛ  ﾛ  ﾛ ﾛﾟ                  ');                       
  WriteLn('               ﾟ ﾟﾟ ﾟﾟﾟﾟ   ﾟ    ﾟ ﾟﾟﾟﾟ     ﾟﾟﾟﾟ ﾟﾟﾟﾟ ﾟﾟﾟﾟﾟ ﾟﾟﾟﾟ                ');
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
    ReadLn(CryptFile1);
    Assign(FileOfSize,CryptFile1);
    Reset(FileOfSize);
    SizeOfFile := FileSize(FileOfSize);
    Close(FileOfSize);
    textColor(LightGray);
    Write(' Name der Ausgabedatei: ');
    TextColor(White);
    ReadLn(CryptFile2);
    Assign(CodeFile1,CryptFile1);
    Reset(CodeFile1);
    TextColor(Cyan);
    Assign(CodeFile2,CryptFile2);
    ReWrite(CodeFile2);
    Percent := 0;
    i := 0;
    REPEAT
      Read(CodeFile1,FileData);
      IF CryptMode = '1' THEN Crypt := Delta+Ord(FileData)
                         ELSE Crypt := Ord(FileData)-Delta;
      Write(CodeFile2,Chr(Crypt));
      Inc(i);
      Percent := Round(100*i/SizeOfFile);
      Write(^m,' ',Percent,' %');
    UNTIL i>=SizeOfFile;
    Close(CodeFile1);
    Close(CodeFile2);
    WriteLn(' Fertig!');
    TextColor(White);
  END ELSE BEGIN {Text}
    TextColor(LightGray);
    WriteLn(' Wie soll die Datei hei疇n, in die der Text gespeichert wird?');
    Write(' ');
    TextColor(White);
    ReadLn(CryptFile1);
    Assign(CodeFile1,CryptFile1);
    Rewrite(CodeFile1);
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
    Write  ('automatisch in der Datei "',CryptFile1,'" abgelegt. Ende mit ESC!');
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
      IF Eingabe = #13 THEN WriteLn ELSE IF Eingabe =  #8 THEN Write(#8,' ',#8) ELSE Write(Eingabe);
      IF CryptMode = '1' THEN Crypt := Delta+Ord(Eingabe)
                         ELSE Crypt := Ord(Eingabe)-Delta;
      Write(CodeFile1,Chr(Crypt));
    UNTIL Eingabe = #27;
    Window(1,1,80,25);
    Close(CodeFile1);
    TextBackGround(Black);
    ClrScr;
  END;
END.
