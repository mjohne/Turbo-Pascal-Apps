PROGRAM Verman_Code;

USES
  Crt,Dos;

VAR
  DeltaLength,
  Crypt       : Byte;
  FileData,
  CryptMode,
  Eingabe     : Char;
  CodeFile1,
  CodeFile2   : Text;
  Delta       : ARRAY[1..255] OF Char;
  FileOfSize  : FILE OF Byte;
  CryptFile1,
  CryptFile2  : STRING[12];
  n,i,a,Ten,
  SizeOfFile  : LongInt;

BEGIN
  TextBackGround(Black);
  ClrScr;
  TextColor(White);
  TextBackground(Red);
  WriteLn('                                                                               ');
  WriteLn('                                                                               ');
  WriteLn('           Û  Û Ûßßß ÛßßÛ ÛßÛßÛ ÛßßÛ ÛßÛ Û      Ûßßß ÛßßÛ ßÛßßÛ Ûßßß           ');
  WriteLn('           Û Ûß Ûß   ÛßÛß Û Û Û ÛßßÛ Û Û Û ßßßß Û    Û  Û  Û  Û Ûß             ');
  WriteLn('           ßßß  ßßßß ß ßß ß ß ß ß  ß ß ßßß      ßßßß ßßßß ßßßßß ßßßß           ');
  WriteLn('                     Version 1.0a DOS TP-7.0    (C) MJ 2003                    ');
  WriteLn('                                                                               ');
  TextBackground(Black);
  WriteLn;
  WriteLn;
  TextColor(LightGray);
  Write  (' Passwortl„nge: ');
  ReadLn(DeltaLength);
  TextColor(White);
  Write  (' Passwort = ');
  FOR n := 1 TO DeltaLength DO BEGIN
    Delta[n] := ReadKey;
    Write('*'{Delta[n]});
  END;
  WriteLn;
  TextColor(LightGray);
  WriteLn(' Soll Datei verschlsselt (=1) oder entschlsselt (=0)?');
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
  Write  ('schlsseln: ');
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
  TextColor(Cyan);
  Assign(CodeFile2,CryptFile2);
  ReWrite(CodeFile2);
  n := 0;
  i := 0;
  a := 0;
  Write('°°°°°°°°°°',^m,' '); {° = Chr(176) oder #176;}
  REPEAT
    Read(CodeFile1,FileData);
    Inc(n);
    Inc(i);
    Inc(a);
    Crypt := Ord(Delta[n]) XOR Ord(FileData);
    Write(CodeFile2,Chr(Crypt));
    IF n = DeltaLength THEN n := 0;
    IF a = Ten THEN BEGIN
      Write(#178);
      a := 0;
    END;
  UNTIL i>=SizeOfFile;
  Close(CodeFile1);
  Close(CodeFile2);
  WriteLn(' Fertig!');
  TextColor(White);
END.