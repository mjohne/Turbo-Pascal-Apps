PROGRAM NSIPSD;

USES Crt,Dos,Graph;

CONST Author = 'NSIPSD  *  Net Send IP Shutdown  *  (C) Taios 2005';

VAR
  a,b,c,d : Byte;

BEGIN
  FOR a := 0 TO 255 DO BEGIN
    FOR b := 0 TO 255 DO BEGIN
      FOR c := 0 TO 255 DO BEGIN
        FOR d := 0 TO 255 DO BEGIN
          WriteLn('net send \\',a,'.',b,'.',c,'.',d,' shutdown -s -t 10');
        END;
      END;
    END;
  END;
END.