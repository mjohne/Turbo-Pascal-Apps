PROGRAM Make_TimeStamp;

USES Crt,Dos;

VAR
  TimeStamp : RECORD
                Year,Month,Day,Dow,
                Hour,Min,Sec,MSec,CRC : Word;
              END;
  TS_File : Text;

BEGIN
  Assign(TS_File,'TIMESTMP.DAT');
  Append(TS_File);
  WITH TimeStamp DO BEGIN
    GetDate(Year,Month,Day,Dow);
    GetTime(Hour,Min,Sec,MSec);
    CRC := Byte(Year DIV 255) XOR Byte(Year-(255*(Year DIV 255))) XOR Byte(Month) XOR Byte(Day) XOR Byte(Dow) XOR Byte(Hour)
	   XOR Byte(Min) XOR Byte(Sec) XOR Byte(MSec);
    Write(TS_File,Chr(Byte(Year DIV 255)),Chr(Byte(Year-(255*(Year DIV 255)))),
    Chr(Byte(Month)),Chr(Byte(Day)),Chr(Byte(Dow)));
    Write(TS_File,Chr(Byte(Hour)),Chr(Byte(Min)),Chr(Byte(Sec)),Chr(Byte(MSec)),Chr(Byte(CRC)));
  END;
  Close(TS_File);
END.