PROGRAM Drei_A_Algorithmus;

VAR
  a,n : LongInt;

BEGIN
  WriteLn;
  WriteLn(' 3A - ALGORITHMUS ');
  WriteLn(' ================ ');
  WriteLn;
  WriteLn(' Starte mit einem positiven, ganzzahligen a...');
  WriteLn(' Wiederhole, solange a von eins verschieden ist:');
  WriteLn('   Ist a durch 2 teilbar, so ersetze dieses a durch a DIV 2,');
  WriteLn('                          andernfalls jedoch durch 3*a+1 ...');
  WriteLn;
  n := 0;
  Write(' Gib n ein: ');
  ReadLn(a);
  REPEAT
    WriteLn(a);
    n := n+1;
    IF a MOD 2 = 0 THEN a := a DIV 2
                   ELSE a := (**)3*a(**)+1;
  UNTIL a IN [0,1];
  WriteLn(n,' Schritte...');
  ReadLn;
END.