PROGRAM Read_DAC;

USES Crt,Dos;

VAR
  i,Max : Byte;
  r     : Registers;
  Name  : STRING;
  File1 : Text;

BEGIN
  WriteLn('SAVEPAL v1.0 by Michael Johne 2002');
  WriteLn('----------------------------------');
  WriteLn('SAVEPAL saves the DAC color palette into file.');
  WriteLn;
  WriteLn(' [1] - for  16 colors in the file "savepal. 16"');
  WriteLn(' [2] - for 256 colors in the file "savepal.256"');
  WriteLn;
  Write('Press a number to chosse: ');
  ReadLn(Max);
  IF Max = 1 THEN Max := 15 ELSE IF Max = 2 THEN Max := 255 ELSE BEGIN
    WriteLn('You must input a number between 1 and 2.');
    Halt;
  END;
  IF Max = 15 THEN Name := 'SAVEPAL. 16' ELSE IF Max = 255 THEN Name := 'SAVEPAL.256';
  Assign(File1,Name);
  Rewrite(File1);
  FOR i := 0 TO Max DO BEGIN
    Write(^m,i);
    WITH r DO BEGIN
      ah := $10;
      al := $15;
      bx := i;
    END;
    Intr($10,r);
    Write(File1,Chr(r.dh));
    Write(File1,Chr(r.ch));
    Write(File1,Chr(r.cl));
  END;
  Close(File1);
  WriteLn;
END.