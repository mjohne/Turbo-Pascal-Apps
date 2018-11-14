PROGRAM Caesar_Code;

USES
  Crt,Dos;

VAR
  Percent,
  Place,
  PlaceCan,
  PlaceCon,
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
  Randomize;
  TextBackGround(Black);
  ClrScr;
  TextColor(White);
  TextBackground(Red);
  WriteLn('                                                                               ');
  WriteLn('                                                                               ');
  WriteLn('            ﾛﾟﾟﾟ ﾛﾟﾟﾛ ﾛﾟﾟﾟ ﾛﾟﾟﾟ ﾛﾟﾟﾛ ﾛﾟﾟﾛ     ﾛﾟﾟﾟ ﾛﾟﾟﾛ ﾟﾛﾟﾟﾛ ﾛﾟﾟﾟ             ');
  WriteLn('            ﾛ    ﾛﾟﾟﾛ ﾛﾟ   ﾟﾟﾟﾛ ﾛﾟﾟﾛ ﾛﾟﾛﾟ ﾟﾟﾟ ﾛ    ﾛ  ﾛ  ﾛ  ﾛ ﾛﾟ               ');
  WriteLn('            ﾟﾟﾟﾟ ﾟ  ﾟ ﾟﾟﾟﾟ ﾟﾟﾟﾟ ﾟ  ﾟ ﾟ ﾟﾟ     ﾟﾟﾟﾟ ﾟﾟﾟﾟ ﾟﾟﾟﾟﾟ ﾟﾟﾟﾟ             ');
  WriteLn('                     Version 1.0a DOS TP-7.0    (C) MJ 2003                    ');
  WriteLn('                                                                               ');
  TextBackground(Black);
  WriteLn;
  WriteLn;
  TextColor(LightGray);
  WriteLn(' Nach wievielter Stelle sollver schl《selt werden?');
  TextColor(White);
  Write  (' Place = ');
  ReadLn(Place);
  TextColor(LightGray);
  WriteLn(' Soll die Datei verschl《selt (=1) oder entschl《selt (=0)?');
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
  Write  ('schl《seln: ');
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
  PlaceCan := 0;
  REPEAT
    Inc(PlaceCan);
    Read(CodeFile1,FileData);
    Write(CodeFile2,FileData);
    IF PlaceCan >= Place THEN BEGIN
      PlaceCan := 0;
      PlaceCon := Random(255);
      IF CryptMode = '1' THEN Write(CodeFile2,Chr(Random(255)))
                         ELSE Read(CodeFile1,FileData);

    END;
;

{
    IF PlaceCan >= Place THEN BEGIN
      PlaceCan := 0;
      PlaceCon := Random(255);
      IF CryptMode = '1' THEN Write(CodeFile2,Chr(Random(255)))
                         ELSE Read(CodeFile1,FileData);

    END;

IF CryptMode = '1' THEN Crypt := Place+Ord(FileData)
                       ELSE Crypt := Ord(FileData)-Place;}


    Inc(i);
    Percent := Round(100*i/SizeOfFile);
    Write(^m,' ',Percent,' %');
  UNTIL EoF(CodeFile1){i>=SizeOfFile};
  Close(CodeFile1);
  Close(CodeFile2);
  WriteLn(' Fertig!');
  TextColor(White);
END.