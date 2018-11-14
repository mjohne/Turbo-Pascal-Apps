PROGRAM SOLITAIRE_Code;

USES
  Crt,Dos;

VAR
  Crypt,
  Delta       : Byte;
  FileData,
  CryptMode,
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
  WriteLn('                     Version 1.0a DOS TP-7.0    (C) MJ 2005                    ');
  WriteLn('                                                                               ');
  TextBackground(Black);
  WriteLn;
  WriteLn;
  TextColor(LightGray);
  WriteLn(' Soll die Datei verschl《selt (=1) oder entschl《selt (=0)?');
  TextColor(White);
  Write  (' CryptMode = ');
  REPEAT
    CryptMode := ReadKey;
  UNTIL CryptMode IN ['0','1'];
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
{    IF CryptMode = '1' THEN Crypt := Ord(Delta)+Ord(FileData)
                       ELSE Crypt := Ord(FileData)-Ord(Delta);}

    Crypt := Ord(Delta) XOR Ord(FileData);

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
END.