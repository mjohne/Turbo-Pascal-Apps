PROGRAM PlusHash;

USES Crt, Dos;

VAR
  PlusCheck    : Real;
  CheckVar     : Char;
  FileOfSize   : FILE OF Byte;
  i,SizeOfFile : LongInt;
  FileToCheck  : STRING[13];
  CheckFile    : Text;

BEGIN
  WriteLn('Plus-Hash v1.0');
  WriteLn('==============',^j);
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
    PlusCheck := PlusCheck+Ord(CheckVar);
    Write(^m,i,' von ',SizeOfFile);
  END;
  Close(CheckFile);
  WriteLn;
  WriteLn('Der Plus-Hashwert der Datei ',FileToCheck,' lautet ',PlusCheck:0:0);
END.