PROGRAM OneTimePad_Code;

USES
  Crt,Dos;

VAR
  Crypt,
  Delta       : Byte;
  FileData,
  CryptMode,
  WhatToCrypt,
  Input       : Char;
  CodeFile1,
  CodeFile2,
  KeyFile     : Text;
  FileOfSize  : FILE OF Byte;
  Key,
  CryptFile1,
  CryptFile2  : STRING[12];
  i,a,Ten,
  SizeOfFile  : LongInt;

BEGIN
  Randomize;
  TextBackGround(Black);
  ClrScr;
  TextColor(White);
  TextBackground(Red);
  WriteLn('                                                                               ');
  WriteLn('                                                                               ');
  WriteLn('                   ﾛﾟﾟﾛ ﾟﾟﾛﾟﾟ ﾛﾟﾟﾛ      ﾛﾟﾟﾟ ﾛﾟﾟﾛ ﾟﾛﾟﾟﾛ ﾛﾟﾟﾟ                   ');
  WriteLn('                   ﾛ  ﾛ   ﾛ   ﾛﾟﾟﾟ ﾟﾟﾟﾟ ﾛ    ﾛ  ﾛ  ﾛ  ﾛ ﾛﾟ                     ');
  WriteLn('                   ﾟﾟﾟﾟ   ﾟ   ﾟ         ﾟﾟﾟﾟ ﾟﾟﾟﾟ ﾟﾟﾟﾟﾟ ﾟﾟﾟﾟ                   ');
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
  UNTIL CryptMode IN ['0','1'];
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
    Ten := Round(SizeOfFile/10);
    Close(FileOfSize);
    TextColor(LightGray);
    Write  (' Name der Ausgabedatei: ');
    TextColor(White);
    ReadLn(CryptFile2);
    Assign(CodeFile1,CryptFile1);
    Reset(CodeFile1);
    Assign(CodeFile2,CryptFile2);
    ReWrite(CodeFile2);
    TextColor(LightGray);
    Write  (' Name der Datei f〉 den Schl《sel: ');
    TextColor(White);
    ReadLn(Key);
    TextColor(Cyan);
    IF CryptMode = '1' THEN BEGIN
      Assign(KeyFile,Key);
      Rewrite(KeyFile);
      Write(' Schl《sel in Datei "',Key,'" wird erzeugt...');
      FOR i := 1 TO SizeOfFile DO BEGIN
        Write(KeyFile,Chr(Random(255)));
      END;
      Close(KeyFile);
      WriteLn(^m,' Schl《sel in Datei "',Key,'" wurde erzeugt.');
    END ELSE BEGIN
      Assign(KeyFile,Key);
    END;
    Delta := 0;
    i := 0;
    a := 0;
    Write('ｰｰｰｰｰｰｰｰｰｰ',^m,' '); {ｰ = Chr(176) oder #176;}
    Reset(KeyFile);
    REPEAT
      Read(CodeFile1,FileData);
      Inc(i);
      Inc(a);
      Read(KeyFile,Input);
      Delta := Ord(Input);
      IF CryptMode = '1' THEN Crypt := Ord(Delta)+Ord(FileData)
                         ELSE Crypt := Ord(FileData)-Ord(Delta);
      Write(CodeFile2,Chr(Crypt));
      IF a = Ten THEN BEGIN
        Write(#178);
        a := 0;
      END;
    UNTIL i>=SizeOfFile;
    Close(CodeFile1);
    Close(CodeFile2);
    Close(KeyFile);
    WriteLn(' Fertig!');
    TextColor(White);
  END ELSE BEGIN {Text}
    TextColor(LightGray);
    WriteLn(' Wie soll die Datei hei疇n, in die der Text gespeichert wird?');
    Write  (' ');
    TextColor(White);
    ReadLn(CryptFile1);
    Assign(CodeFile1,CryptFile1);
    Rewrite(CodeFile1);
    TextColor(LightGray);
    WriteLn(' Und wie hei疸 der Name der Datei f〉 den Schl《sel? ');
    Write  (' ');
    TextColor(White);
    ReadLn(Key);
    TextColor(Cyan);
    Assign(KeyFile,Key);
    Rewrite(KeyFile);
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
      Delta := Random(255);
      Input := ReadKey;
      IF Input = #27 THEN Break;
      IF Input = #08 THEN Continue;
      IF Input = #13 THEN WriteLn ELSE IF Input = #8 THEN Write(#8,' ',#8) ELSE Write(Input);
      IF CryptMode = '1' THEN Crypt := Ord(Delta)+Ord(Input)
                         ELSE Crypt := Ord(Input)-Ord(Delta);
      Write(CodeFile1,Chr(Crypt));
      Write(KeyFile,Chr(Delta));
    UNTIL Input = #27;
    Window(1,1,80,25);
    Close(CodeFile1);
    Close(KeyFile);
    TextBackGround(Black);
    ClrScr;
  END;
END.