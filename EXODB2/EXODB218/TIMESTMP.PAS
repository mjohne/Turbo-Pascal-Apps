UNIT TimeStmp;

INTERFACE

  PROCEDURE MakeTimeStamp;
  PROCEDURE ViewTimeStamp;
  PROCEDURE LogTimeStamp;
  PROCEDURE EraseTimeStamp;

IMPLEMENTATION

USES Crt,Dos,Graph,Arithmos,Basic,Cursor,RT_Watch,ConstVar;

VAR
  TimeStamp : RECORD
                Year,Month,Day,Dow,
                Hour,Min,Sec,MSec,CRC : Word;
              END;
  ch        : ARRAY[0..10] OF Char;
  TS_File   : Text;
  Index     : LongInt;
  {TS_File2  : FILE OF Char;}
  Str       : STRING;

PROCEDURE MakeTimestamp;
BEGIN
  { --- Zeitstempel speichern --- }
  Assign(TS_File,'TIMESTMP.LOG');
  IF FileExists('TIMESTMP.LOG') THEN Append(TS_File) ELSE Rewrite(TS_File);
  WITH TimeStamp DO BEGIN
    GetDate(Year,Month,Day,Dow);
    GetTime(Hour,Min,Sec,MSec);
    Write(TS_File,Year);
    IF Month < 10 THEN Write(TS_File,'0'); Write(TS_File,Month);
    IF Day < 10 THEN Write(TS_File,'0'); Write(TS_File,Day);
    Write(TS_File,'-');
    IF Hour < 10 THEN Write(TS_File,'0'); Write(TS_File,Hour);
    IF Min < 10 THEN Write(TS_File,'0'); Write(TS_File,Min);
    IF Sec < 10 THEN Write(TS_File,'0'); WriteLn(TS_File,Sec);
  END;
  Close(TS_File);
END;

PROCEDURE ViewTimeStamp;
BEGIN
  { --- Liste aller Zeitstempel ausgeben --- }
  ClrScr;
  Assign(TS_File,'TIMESTMP.LOG');
  Reset(TS_File);
  REPEAT
    Str := '';
    ReadLn(TS_File,Str);
    Inc(Index);
    WriteLn('Start #',index,': ',Str[7],Str[8],'.',Str[5],Str[6],'.',Str[1],Str[2],Str[3],Str[4],' ',
      Str[10],Str[11],'h',Str[12],Str[13],'m',Str[14],Str[15],'s');
    IF Index MOD 24 = 0 THEN BEGIN
      WriteLn('>>> Press any key!!! <<<');
      ReadKey;
    END;
  UNTIL EoF(TS_File);
  Close(TS_File);
  Readkey;
END;

PROCEDURE LogTimeStamp;
BEGIN
  { --- Liste aller Zeitstempel ausgeben --- }
  ClrScr;
  Assign(TS_File,'TIMESTMP.LOG');
  Reset(TS_File);
  Assign(TS_File,'TIMESTMP.TXT');
  Rewrite(TS_File);
  REPEAT
    Str := '';
    ReadLn(TS_File,Str);
    Inc(Index);
    WriteLn(TS_File,'Start #',index,': ',Str[7],Str[8],'.',Str[5],Str[6],'.',Str[1],Str[2],Str[3],Str[4],' ',
      Str[10],Str[11],'h',Str[12],Str[13],'m',Str[14],Str[15],'s');
  UNTIL EoF(TS_File);
  Close(TS_File);
END;

PROCEDURE EraseTimeStamp;
BEGIN
  Assign(TS_File,'TIMESTMP.LOG');
  Rewrite(TS_File);
  Close(TS_File);
END;

BEGIN
END.
