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
  WriteLn('DC - Difference Coding v1.0 - (C) 2003 MJ');
  WriteLn;
  WriteLn;
  Write  (' Name der Eingabedatei> ');
  ReadLn(CryptFile1);
  Assign(FileOfSize,CryptFile1);
  Reset(FileOfSize);
  SizeOfFile := FileSize(FileOfSize);
  Close(FileOfSize);
  TextColor(LightGray);
  Write(' Name der Ausgabedatei: ');
  ReadLn(CryptFile2);
  Assign(CodeFile1,CryptFile1);
  Reset(CodeFile1);
  TextColor(Cyan);
  Assign(CodeFile2,CryptFile2);
  ReWrite(CodeFile2);
  Percent := 0;
  i := 1;
  Read(CodeFile1,FileData);
  Crypt := Ord(FileData);
  Write(CodeFile2,FileData);
  REPEAT

{
   Read(CodeFile1,FileData);
   Crypt := Crypt-Ord(FileData);
   Write(CodeFile2,Chr(Crypt));
}
   Read(CodeFile1,FileData);
   Crypt := Crypt+Ord(FileData);
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