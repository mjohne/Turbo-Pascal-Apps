PROGRAM Drei_A_Hash;

VAR
  Data   : Char;
  a,n    : LongInt;
  HF     : Text;
  A_File : STRING;

BEGIN
  WriteLn;
  WriteLn(' 3A - Hash ');
  WriteLn(' ========= ');
  WriteLn;
  Write(' Name der Datei zum Werten: ');
  ReadLn(A_File);
  Assign(HF,A_File);
  Reset(HF);
  a := 0;
  n := 0;
  REPEAT
    ReadLn(HF,Data);
    a := Ord(Data);
    REPEAT
      IF a MOD 2 = 0 THEN a := a DIV 2
                     ELSE a := (**)3*a(**)+1;
      n := n+a;
    UNTIL a IN [0,1];
  UNTIL EoF(HF);
  Close(HF);
  WriteLn(' Der 3A-Hashwert ist ',n);
END.