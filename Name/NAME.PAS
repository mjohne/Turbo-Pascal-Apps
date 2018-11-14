PROGRAM Random_Name_Generator;

USES Crt,Dos;

VAR
  Len,i,a,b,c
  : Byte;
  St : STRING;

LABEL abc;

BEGIN
  ClrScr;
repeat
  Randomize;
  st := '';
  a := Random(2);
  REPEAT
    Len := Random(9);
  UNTIL Len > 3;
  {WriteLn('Name Lenght: ',Len);}
  FOR i := 1 TO Len DO BEGIN
    IF Odd(a) THEN BEGIN
      b := Random(5);
      CASE b OF
        0 : St := St+'a';
        1 : St := St+'e';
        2 : St := St+'i';
        3 : St := St+'o';
        4 : St := St+'u';
      END;
      Inc(a);
    END ELSE IF NOT(Odd(a)) THEN BEGIN
      abc:
      b := Random(26);
      IF Chr(97+b) = 'a' THEN GOTO abc;
      IF Chr(97+b) = 'e' THEN GOTO abc;
      IF Chr(97+b) = 'i' THEN GOTO abc;
      IF Chr(97+b) = 'o' THEN GOTO abc;
      IF Chr(97+b) = 'u' THEN GOTO abc;
      St := St+Chr(97+b);
      Inc(a);
    END;
  END;
  St[1] := UpCase(St[1]);
  WriteLn('   ',St);
  Delay(50);
until keypressed;
END.


RND-Alg

  ClrScr;
  Randomize;
  st := '';
  REPEAT
    Len := Random(9);
  UNTIL Len > 3;
  WriteLn('Name Lenght: ',Len);
  FOR i := 1 TO Len DO BEGIN
    a := Random(2);
{    WriteLn(i,' ',a);}
    IF a = 0 THEN BEGIN
      b := Random(6);
      CASE b OF
        0 : St := St+'a';
        1 : St := St+'e';
        2 : St := St+'i';
        3 : St := St+'o';
        4 : St := St+'u';
        5 : St := St+'y';
      END;
    END ELSE IF a = 1 THEN BEGIN
      REPEAT
        b := Random(25);
      UNTIL (Chr(b+98) <> 'a') OR (Chr(b+98) <> 'e') OR
      (Chr(b+98) <> 'i') OR (Chr(b+98) <> 'o') OR
      (Chr(b+98) <> 'u') OR (Chr(b+98) <> 'y');
      St := St+Chr(98+b);
    END;
  END;
  St[1] := UpCase(St[1]);
  WriteLn('Name: ',St);
delay(120);
