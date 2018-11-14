PROGRAM Retro;

USES Crt,Dos;

TYPE PtrArr = ARRAY[1..65535] OF Byte;

VAR
  CryptMode,
  Data        : Char;
  CodeFile1,
  CodeFile2   : Text;
  FileOfSize  : FILE OF Byte;
  CryptFile1,
  CryptFile2  : STRING[12];
  x,i,a,Ten,
  SizeOfFile,
  SizeOfFile2 : LongInt;
  MaxSize     : Word;
  FileBytes   : ^PtrArr;

BEGIN
  MaxSize := 65535;
  New(FileBytes);
  TextBackGround(Black);
  ClrScr;
  TextColor(White);
  TextBackground(Red);
  WriteLn('                                                                               ');
  WriteLn('                                                                               ');
  WriteLn('              ÛßßÛ Ûßßß ßßÛßß ÛßßÛ ÛßßÛ      Ûßßß ÛßßÛ ßÛßßÛ Ûßßß              ');
  WriteLn('              ÛßÛß Ûß     Û   ÛßÛß Û  Û ßßßß Û    Û  Û  Û  Û Ûß                ');
  WriteLn('              ß ßß ßßßß   ß   ß ßß ßßßß      ßßßß ßßßß ßßßßß ßßßß              ');
  WriteLn('                     Version 1.0a DOS TP-7.0    (C) MJ 2002                    ');
  WriteLn('                                                                               ');
  TextBackground(Black);
  WriteLn;
  WriteLn;
  TextColor(LightGray);
  WriteLn(' Soll Datei verschlsselt (=1) oder entschlsselt (=0)?');
  TextColor(White);
  Write(' CryptMode = ');
  REPEAT
    CryptMode := ReadKey;
  UNTIL CryptMode IN ['0','1'];
  Write(CryptMode);
  TextColor(LightGray);
  WriteLn;
  Write(' Name der Datei zum ');
  IF CryptMode = '1' THEN Write('Ver') ELSE Write('Ent');
  Write('schlsseln: ');
  TextColor(White);
  ReadLn(CryptFile1);
  Assign(FileOfSize,CryptFile1);
  Reset(FileOfSize);
  SizeOfFile := FileSize(FileOfSize);
  Ten := Round(SizeOfFile/10);
  Close(FileOfSize);
  TextColor(LightGray);
  Write(' Name der Ausgabedatei: ');
  TextColor(White);
  ReadLn(CryptFile2);
  Assign(CodeFile1,CryptFile1);
  Reset(CodeFile1);
  TextColor(Cyan);
  Assign(CodeFile2,CryptFile2);
  Rewrite(CodeFile2);
  Write('°°°°°°°°°°°°°°°°°°°°');
  Write(^m,' ');
  SizeOfFile2 := SizeOfFile;
  IF SizeOfFile > MaxSize THEN BEGIN
    REPEAT
      x := 0;
      FOR i := 1 TO MaxSize DO BEGIN
        Read(CodeFile1,Data);
        FileBytes^[i] := Ord(Data);
        Inc(x);
        IF x = Ten THEN BEGIN
         Write(#178);
          x := 0;
        END;
      END;
      x := 0;
      FOR i := MaxSize DOWNTO 1 DO BEGIN
        Data := Chr(FileBytes^[i]);
        Write(CodeFile2,Data);
        Inc(x);
        IF x = Ten THEN BEGIN
          Write(#178);
          x := 0;
        END;
      END;
      SizeOfFile2 := SizeOfFile-MaxSize;
      IF SizeOfFile2 < MaxSize THEN MaxSize := SizeOfFile2;
    UNTIL SizeOfFile2+MaxSize >= SizeOfFile;
  END ELSE BEGIN;
    x := 0;
    FOR i := 1 TO SizeOfFile DO BEGIN
      Read(CodeFile1,Data);
      FileBytes^[i] := Ord(Data);
      Inc(x);
      IF x = Ten THEN BEGIN
        Write(#178);
        x := 0;
      END;
    END;
    x := 0;
    FOR i := SizeOfFile DOWNTO 1 DO BEGIN
      Data := Chr(FileBytes^[i]);
      Write(CodeFile2,Data);
      Inc(x);
      IF x = Ten THEN BEGIN
        Write(#178);
        x := 0;
      END;
    END;
  END;
  Write(' Fertig!');
  Close(CodeFile1);
  Close(CodeFile2);
  TextColor(LightGray);
  Dispose(FileBytes);
END.