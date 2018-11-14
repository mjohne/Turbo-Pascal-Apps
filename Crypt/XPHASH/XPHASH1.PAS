PROGRAM XP_Hash;

USES Crt,Dos;

VAR
  CheckByte    : Byte;
  CheckVar     : Char;
  FileOfSize   : FILE OF Byte;
  CheckFile    : FILE OF Char;
  Control      : Integer;
  i,SizeOfFile,
	Temp,Temp2,
	XPCheck      : LongInt;
  CheckStr     : STRING[3];
  FileToCheck  : STRING[13];

BEGIN
  WriteLn('XP-Hash v1.0 Michael Johne 2003');
  WriteLn('===============================',^j);
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
    Checkbyte := Ord(CheckVar);
    Str(Checkbyte,CheckStr);
    Val(CheckStr[1],Temp,Control);
    IF Temp = 0 THEN Temp2 := 10 ELSE Temp2 := Temp;
    Val(CheckStr[2],Temp,Control);
    IF Temp = 0 THEN Temp2 := 10*Temp2 ELSE Temp2 := Temp2*Temp;
    Val(CheckStr[3],Temp,Control);
    IF Temp = 0 THEN Temp2 := 10*Temp2 ELSE Temp2 := Temp2*Temp;
    XPCheck := XPCheck+Temp2;
    Write(^m,i,' von ',SizeOfFile);
  END;
  Close(CheckFile);
  WriteLn;
  WriteLn('Der Hashwert der Datei ',FileToCheck,' lautet ',XPCheck);
END.