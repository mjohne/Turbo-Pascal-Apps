PROGRAM fBM;

USES Crt,Dos,Graph,Gen40;

CONST
  MaxX = 100;
  MaxY = 100;

VAR
  Matrix : ARRAY[1..120,1..120] OF LongInt;
  a,b,c,n,i,X,Y,Move : LongInt;

PROCEDURE ClearKeyBuff; {Clear the keyboard buffer}
BEGIN
  MemW[$0000 : $041C] := MemW[$0000 : $041a];
  ASM cli END;
  MemW[Seg0040 : $1C] := MemW[Seg0040 : $1a];
  ASM sti END;
END;

BEGIN
  ClrScr;
  Randomize;
  X := Random(MaxX)+1;
  Y := Random(MaxY)+1;
  VGA(True);
  FOR a := 1 TO 255 DO BEGIN
      SetReg(a,a,a,a);
  END;

  REPEAT
    Move := Random(10)+1;
    CASE Move OF
      0 : BEGIN {Do Nothing} END;
      1 : BEGIN Dec(X); Inc(Y); END;
      2 : BEGIN Inc(Y); END;
      3 : BEGIN Inc(X); Inc(Y); END;
      4 : BEGIN Dec(X); END;
      5 : BEGIN {Do Nothing} END;
      6 : BEGIN Inc(X); END;
      7 : BEGIN Dec(X); Dec(Y); END;
      8 : BEGIN Dec(Y); END;
      9 : BEGIN Inc(X); Dec(Y); END;
    END;
    IF X < 1 THEN X := X+MaxX;
    IF Y < 1 THEN Y := Y+MaxY;
    IF X > MaxX THEN X := X-MaxX;
    IF Y > MaxY THEN Y := Y-MaxY;
    IF Move <> 0 THEN Inc(Matrix[X,Y]);

    FOR a := 1 TO MaxX DO BEGIN
      {GotoXY(5,4+a);}
      FOR b := 1 TO MaxY DO BEGIN
        {TextColor(Matrix[a][b] MOD 16);
        Write(Matrix[a][b]:3);}
        PutPixel(a,b,Matrix[a][b]);
      END;
      {WriteLn;}
    END;
    {Delay(0);}
  UNTIL KeyPressed;
  VGA(False);

END.