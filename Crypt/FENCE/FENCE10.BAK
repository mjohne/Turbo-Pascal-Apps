PROGRAM Fence_Code (Gartenzaunverschluesselung);

USES Crt,Dos;

VAR
  Row,Merk       : Byte;
  CryptMode,Data   : Char;
  Contact,
  CodeFile1,
  CodeFile2,
  TempFile    : Text;
  FilesStr    : ARRAY[1..10] OF STRING[3];
  FilesVar    : ARRAY[1..10] OF Text;
  FileOfSize  : FILE OF Byte;
  CryptFile1,
  CryptFile2  : STRING[12];
  x,i,a,Ten,
  SizeOfFile  : LongInt;

BEGIN
  TextBackGround(Black);
  ClrScr;
  TextColor(White);
  TextBackground(Red);
  WriteLn('                                                                               ');
  WriteLn('                                                                               ');
  WriteLn('              Ûßßß Ûßßß ÛßÛ Û Ûßßß Ûßßß      Ûßßß ÛßßÛ ßÛßßÛ Ûßßß              ');
  WriteLn('              Ûß   Ûß   Û Û Û Û    Ûß   ßßßß Û    Û  Û  Û  Û Ûß                ');
  WriteLn('              ß    ßßßß ß ßßß ßßßß ßßßß      ßßßß ßßßß ßßßßß ßßßß              ');
  WriteLn('                     Version 1.0a DOS TP-7.0    (C) MJ 2002                    ');
  WriteLn('                                                                               ');
  TextBackground(Black);
  WriteLn;
  WriteLn;
  TextColor(LightGray);
  Write(' FENCE-Sequenz[1..10] = ');
  TextColor(White);
  ReadLn(Row);
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
  IF CryptMode = '1' THEN BEGIN
    Write  (' Name der Datei zum Verschlsseln: ');
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
    Rewrite(CodeFile2);
    x := 0;
    Write('°°°°°°°°°°');
    FOR i := 1 TO Row+1 DO Write('°');
    Write(^m,' ');
    FOR i := 1 TO Row DO BEGIN
      Str(i,FilesStr[i]);
      Assign(FilesVar[i],FilesStr[i]);
      Rewrite(FilesVar[i]);
    END;
    i := 0;
    a := 0;
    Merk := 1;
    REPEAT
      Read(CodeFile1,Data);
      Inc(i);
      Inc(x);
      IF a = Row THEN Merk := 0; {0=Dec}
      IF a = 1 THEN Merk := 1;   {1=Inc}
      IF Merk = 1 THEN Inc(a);
      IF Merk = 0 THEN Dec(a);
      Write(FilesVar[a],Data);
      IF x = Ten THEN BEGIN
        Write(#178);
        x := 0;
      END;
    UNTIL i >= SizeOfFile;
    TextColor(Cyan);
    FOR i := 1 TO Row DO Close(FilesVar[i]);
    FOR i := 1 TO Row DO BEGIN
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
    WriteLn;
    TextColor(Red);
    WriteLn(' Die ENTSCHLšSSELUNG ist in dieser Version noch nicht implementiert!!!');
    TextColor(LightGray);
    Readkey;
  END;
END.


  Row                                           5         5
   1	 a	 i	 q	 y   4           a       a
   2	  b	h j	p r	x z  7            a     a
   3	   c   g   k   o   s   w     6             a   a
   4	    d f     l n     t v      6              a a
   5	     e	     m	     u       3               a


                                        1:-  4:4+1  7:7+4 1. Ebene
  abcdefghijklmnopqrstuvwxyz            2:1  5:5+2  8:8+5
                                        3:3  6:6+3  9:9+6
  aiqybhjprxzcgkoswdflntvemu



  Stelle := 1;
  Lese_ein(1)
  Schreibe_aus(1)
  Inc(Stelle);
  REPEAT
    IF Stelle > Dateigr”sse THEN Finished := True ELSE BEGIN
      CASE Reihe OF
        2: Inc(Stelle,1);
        3: Inc(Stelle,Reihe);
        4: Inc(Stelle,Reihe+1);
        5: Inc(Stelle,Reihe+2);
        6: Inc(Stelle,Reihe+3);
        7: Inc(Stelle,Reihe+4);
        8: Inc(Stelle,Reihe+5);
        9: Inc(Stelle,Reihe+6);
        10: Inc(Stelle,Reihe+7);
        {....}
      END;
      IF Stelle > Dateigr”sse THEN Finished := True ELSE BEGIN
        Lese_Ein(Stelle);
        Lese_ein(1)
        Schreibe_aus(1)
        Inc(Stelle);
      END;
    END;
  END;



  UNTIL Finished;








