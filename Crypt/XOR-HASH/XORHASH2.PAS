PROGRAM XOR_Hash;

USES Crt, Dos;

VAR
  XORCheck     : Byte;
  CheckVar     : Char;
  FileOfSize   : FILE OF Byte;
  i,SizeOfFile : LongInt;
  FileToCheck  : STRING[13];
  CheckFile    : Text;

BEGIN
  WriteLn('XOR-Hash');
  WriteLn('========',^j);
  Write  ('Name der Datei zum PrÅfen: ');
  ReadLn(FileToCheck);
  Assign(FileOfSize,FileToCheck);
  Reset(FileOFSize);
  SizeOfFile := FileSize(FileOfSize);
  Close(FileOfSize);
  Assign(CheckFile,FileToCheck);
  Reset(CheckFile);
  FOR i := 1 TO  SizeOfFile DO BEGIN
    Read(CheckFile,CheckVar);
    XORCheck := XORCheck XOR Ord(CheckVar);
    Write(^m,i,' von ',SizeOfFile);
  END;
  Close(CheckFile);
  WriteLn;
  WriteLn('Der XOR-Hashwert der Datei ',FileToCheck,' lautet ',XORCheck);
END.