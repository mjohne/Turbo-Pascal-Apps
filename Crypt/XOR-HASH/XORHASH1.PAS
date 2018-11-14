PROGRAM XOR_Hash;

USES Crt, Dos;

VAR
  XORCheck    : Byte;
  CheckVar    : Char;
  Offset      : Longint;
  FileToCheck : STRING[13];
  CheckFile   : Text;

BEGIN
  WriteLn('XOR-Hash');
  WriteLn('========',^j);
  Write  ('Name der Datei zum PrÅfen: ');
  ReadLn(FileToCheck);
  Assign(CheckFile,FileToCheck);
  Reset(CheckFile);
  REPEAT
    Read(CheckFile,CheckVar);
    Inc(Offset);
    XORCheck := XORCheck XOR Ord(CheckVar);
  UNTIL EoF(CheckFile);
  Close(CheckFile);
  WriteLn('Der XOR-Hashwert der Datei ',FileToCheck,' lautet ',XORCheck);
  WriteLn('Offset: ',Offset);
END.