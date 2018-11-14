PROGRAM Caesar_Code;

USES
  Crt,Dos;

VAR
  Percent,
  Delta,
  Crypt       : Byte;
  FileData,
  CryptMode,
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
  WriteLn('            Ûßßß ÛßßÛ Ûßßß Ûßßß ÛßßÛ ÛßßÛ     Ûßßß ÛßßÛ ßÛßßÛ Ûßßß             ');
  WriteLn('            Û    ÛßßÛ Ûß   ßßßÛ ÛßßÛ ÛßÛß ßßß Û    Û  Û  Û  Û Ûß               ');
  WriteLn('            ßßßß ß  ß ßßßß ßßßß ß  ß ß ßß     ßßßß ßßßß ßßßßß ßßßß             ');
  WriteLn('                     Version 3.0a DOS TP-7.0    (C) MJ 2001                    ');
  WriteLn('                                                                               ');
  TextBackground(Black);
  WriteLn;
  WriteLn;
  TextColor(LightGray);
  WriteLn(' Um wieviele Einheiten soll verschoben werden?');
  TextColor(White);
  Write  (' Delta = ');
  ReadLn(Delta);
  TextColor(LightGray);
  WriteLn(' Soll die Datei verschlsselt (=1) oder entschlsselt (=0)?');
  TextColor(White);
  Write  (' CryptMode = ');
  REPEAT
    CryptMode := ReadKey;
  UNTIL CryptMode IN ['0'..'1'];
  Write  (CryptMode);
  TextColor(LightGray);
  WriteLn;
  Write  (' Name der Datei zum ');
  IF CryptMode = '1' THEN Write('Ver') ELSE Write('Ent');
  Write  ('schlsseln: ');
  TextColor(White);
  ReadLn(CryptFile1);
  Assign(FileOfSize,CryptFile1);
  Reset(FileOfSize);
  SizeOfFile := FileSize(FileOfSize);
  Close(FileOfSize);
  TextColor(LightGray);
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
END.