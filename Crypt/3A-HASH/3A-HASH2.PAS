PROGRAM Drei_A_Hash;

VAR
  Data       : Char;
  FS         : FILE OF Byte;
  i,a,n,Size : LongInt;
  A_File     : STRING;
  HF         : Text;

BEGIN
  WriteLn;
  WriteLn(' 3A - Hash ');
  WriteLn(' ========= ');
  WriteLn;
  Write(' Name der Datei zum Werten: ');
  ReadLn(A_File);
  Assign(FS,A_File);
  Reset(FS);
  Size := FileSize(FS);
  Close(FS);
  Assign(HF,A_File);
  reset(HF);
  a := 0;
  i := 0;
  n := 0;
  FOR i:= 1 TO Size DO BEGIN
    ReadLn(HF,Data);
    a := Ord(Data);
    REPEAT
      IF a MOD 2 = 0 THEN a := a DIV 2
                     ELSE a := (**)3*a(**)+1;
      n := n+a;
    UNTIL a IN [0,1];
    Write(^m,' ',i ,' von ',Size);
  END;
  Close(HF);
  WriteLn;
  WriteLn(' Der 3A-Hashwert ist ',n);
END.