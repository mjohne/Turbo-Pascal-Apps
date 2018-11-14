PROGRAM Festplattenspeicher;

USES Crt, Dos;

VAR
  SpeicherInsgesamt,
  SpeicherFrei,
  SpeicherBelegt				 					: LongInt;
  SIinMB, SFinMB, SBinMB,
  SIinPr, SFinPr, SBinPr, SBinXY1	: Real;
  Lauf, SBinXY2										: Integer;

BEGIN
  ClrScr;
  SpeicherInsgesamt := DiskSize(0);
  SpeicherFrei 	    := DiskFree(0);
  SpeicherBelegt    := SpeicherInsgesamt-SpeicherFrei;
  SIinPr := 100;
  SFinPr := SIinPr*SpeicherFrei/SpeicherInsgesamt;
  SBinPr := SIinPr-SFinPr;
  SIinMB := SpeicherInsgesamt/1024/1024;
  SFinMB := SpeicherFrei/1024/1024;
  SBinMB := SpeicherBelegt/1024/1024;
  SBinXY1 := Trunc(SBinPr)/2;
  SBinXY2 := Trunc(SBinXY1)-1;
  TextColor(Yellow);
  GotoXY(12,3);
  Write('อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
  TextColor(White);
  GotoXY(12,4);
  Write(' DISKSIZE TP7-Version 1.1, Copyright 2002 by Michael Johne ');
  TextColor(Yellow);
  GotoXY(12,5);
  Write('อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ');
  TextColor(LightGreen);
  GotoXY(15,10);
  WriteLn('รยยยยลยยยยลยยยยลยยยยลยยยยลยยยยลยยยยลยยยยลยยยยลยยยยด');
  GotoXY(15,11);
  WriteLn('ณ                                                 ณ');
  GotoXY(15,12);
  WriteLn('รมมมมลมมมมลมมมมลมมมมลมมมมลมมมมลมมมมลมมมมลมมมมลมมมมด');
  GotoXY(15,13);
  WriteLn('0   10   20   30   40   50   60   70   80   90   100');
  TextColor(LightGreen);
  GotoXY(16,11);
  FOR Lauf := 1 TO SBinXY2 DO Write('Û');
  TextColor(LightCyan);
  GotoXY(5,18);
  Write('Speicher insgesamt:   ');
  TextColor(LightRed);
  Write(SpeicherInsgesamt:10);
  TextColor(LightCyan);
  Write(' Byte   =   ');
  TextColor(LightRed);
  Write(SIinMB:3:2);
  TextColor(LightCyan);
  Write(' MB   =   ');
  TextColor(LightRed);
  Write(SIinPr:3:2);
  TextColor(LightCyan);
  Write(' %');
  GotoXY(5,19);
  Write('Speicher frei:        ');
  TextColor(LightRed);
  Write(SpeicherFrei:10);
  TextColor(LightCyan);
  Write(' Byte   =   ');
  TextColor(LightRed);
  Write(SFinMB:3:2);
  TextColor(LightCyan);
  Write(' MB   =   ');
  TextColor(LightRed);
  Write(SFinPr:3:2);
  TextColor(LightCyan);
  Write(' %');
  GotoXY(5,20);
  Write('Speicher belegt:      ');
  TextColor(LightRed);
  Write(SpeicherBelegt:10);
  TextColor(LightCyan);
  Write(' Byte   =   ');
  TextColor(LightRed);
  Write(SBinMB:3:2);
  TextColor(LightCyan);
  Write(' MB   =   ');
  TextColor(LightRed);
  Write(SBinPr:3:2);
  TextColor(LightCyan);
  Write(' %');
  TextColor(LightGray);
  WriteLn(^j^j^j);
  Readkey;
END.