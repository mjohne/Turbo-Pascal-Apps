PROGRAM Skytale_Code;

USES Crt,Dos;

VAR
  FileBytes : ARRAY[1..61000] OF Byte;
  Col,Col2 : Byte;
  CryptMode,Data   : Char;
  Contact,
  CodeFile1,
  CodeFile2,
  TempFile  : Text;
  FilesStr  : ARRAY[1..10] OF STRING[3];
  FilesVar  : ARRAY[1..10] OF Text;
  FileOfSize  : FILE OF Byte;
  CryptFile1,
  CryptFile2  : STRING[12];
  x,i,a,Ten,n,
  SizeOfFile  : LongInt;

BEGIN
  TextBackGround(Black);
  ClrScr;
  TextColor(White);
  TextBackground(Red);
  WriteLn('                                                                               ');
  WriteLn('                                                                               ');
  WriteLn('         Ûßßß Û Ûß Û  Û ßßÛßß ÛßßÛ Û    Ûßßß      Ûßßß ÛßßÛ ßÛßßÛ Ûßßß         ');
  WriteLn('         ßßßÛ ÛßßÛ ßßßÛ   Û   ÛßßÛ Û    Ûß   ßßßß Û    Û  Û  Û  Û Ûß           ');
  WriteLn('         ßßßß ß  ß   ßß   ß   ß  ß ßßßß ßßßß      ßßßß ßßßß ßßßßß ßßßß         ');
  WriteLn('                     Version 1.0a DOS TP-7.0    (C) MJ 2003                    ');
  WriteLn('                                                                               ');
  WriteLn('                                                                               ');
  TextBackground(Black);
  WriteLn;
  WriteLn;
  TextColor(LightGray);
  Write(' SKYTALE-Sequenz[1..10] = ');
  TextColor(White);
  ReadLn(Col);
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
  IF CryptMode = '1' THEN BEGIN Write(' Name der Datei zum Verschlsseln: ');
    TextColor(White);
    ReadLn(CryptFile1);
    Assign(FileOfSize,CryptFile1);
    Reset(FileOfSize);
    SizeOfFile := FileSize(FileOfSize);
    Ten := Round(SizeOfFile/10);
    Close(FileOfSize);
    {IF CryptMode = '0' THEN Col := Trunc(SizeOfFile/Col)+1;}
    TextColor(LightGray);
    Write(' Name der Ausgabedatei: ');
    TextColor(White);
    ReadLn(CryptFile2);
    Assign(CodeFile1,CryptFile1);
    Reset(CodeFile1);
    TextColor(Cyan);
    Assign(CodeFile2,CryptFile2);
    Rewrite(CodeFile2);
    Write('°°°°°°°°°°°');
    FOR i := 1 TO Col+1 DO Write('°');
    Write(^m,' ');
    FOR i := 1 TO Col DO BEGIN
      Str(i,FilesStr[i]);
      Assign(FilesVar[i],FilesStr[i]);
      Rewrite(FilesVar[i]);
    END;
    x := 0;
    i := 0;
    a := 0;
    REPEAT
      Inc(a);
      IF a > Col THEN a := 1;
      FOR n := 1 TO Col DO BEGIN
        Inc(x);
        Read(CodeFile1,Data);
        IF i < SizeOfFile THEN BEGIN Write(FilesVar[n],Data); END;
        Inc(i);
      END;
      IF x >= Ten THEN BEGIN
        Write(#178);
        x := 0;
      END;
    UNTIL i >= SizeOfFile;
    TextColor(Cyan);
    FOR i := 1 TO Col DO Close(FilesVar[i]);
    FOR i := 1 TO Col DO BEGIN
      Assign(FileOfSize,FilesStr[i]);
      Reset(FileOfSize);
      SizeOfFile := FileSize(FileOfSize);
      Close(FileOfSize);
      Assign(Contact,FilesStr[i]);
      Reset(Contact);
      FOR a := 1 TO SizeOfFile DO BEGIN
        Read(Contact,Data);
        Write(CodeFile2,Data);
      END;
      Close(Contact);
      Rewrite(Contact);
      Close(Contact);
      Erase(Contact);
      Write(#178);
    END;
    Close(CodeFile1);
    Close(CodeFile2);
    WriteLn(' Fertig!');
  END ELSE BEGIN
    Close(CodeFile2);
    WriteLn;
    TextColor(Red);
    WriteLn(' Die ENTSCHLšSSELUNG ist in dieser Version noch nicht implementiert!!!');
    TextColor(LightGray);
 END;
END.
