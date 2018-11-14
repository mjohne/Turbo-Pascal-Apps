UNIT Basic;

INTERFACE

  PROCEDURE Arrow;
  FUNCTION FileExists(FName : STRING) : Boolean;
  FUNCTION DirExists(DName : STRING) : Boolean;
  FUNCTION DeleteFile(FileName : STRING) : Boolean;
  FUNCTION RenameFile(InputFileName,OutputFileName : STRING) : Boolean;
  FUNCTION UpString(inString : STRING) : STRING;
  FUNCTION ReadStr(Anzahl : Byte) : STRING;
  FUNCTION ReadInt(anzahl : Byte) : LongInt;
  FUNCTION ReadReal(anzahl : Byte) : Real;
  FUNCTION ReadHMS : Real;
  FUNCTION ReadDate : STRING;
  FUNCTION ReadDeg : Real;
  FUNCTION RealToHms(kooD : Real) : STRING;
  FUNCTION RealToDeg(kooD : Real) : STRING;
  FUNCTION GetLangStr(Row : Word) : STRING;
  PROCEDURE BlinkOn;
  PROCEDURE BlinkOff;
  PROCEDURE Wait(ms : Word);
  FUNCTION PrinterOK(lprn : Integer) : Byte;
  PROCEDURE Blank6;
  PROCEDURE Blank10;
  PROCEDURE Blank12;
  PROCEDURE Blank17;
  PROCEDURE Blank20;
  PROCEDURE Blank25;
  PROCEDURE Blank29;
  PROCEDURE SetButton(x1,y1,BackgrCol,ForegrCol : Byte; Str : STRING; Stop : Byte);
  PROCEDURE MessageBox(x1,y1,x2,y2,BackgrCol,ForegrCol,BorderCol1,BorderCol2 : Byte);
  PROCEDURE MainApp;
  PROCEDURE SearchBoxString(Str1 : Byte);
  PROCEDURE SearchBox2;
  PROCEDURE SearchBox3;
  PROCEDURE SearchBox4;
  PROCEDURE SearchBox5;
  PROCEDURE SearchBox6;
  PROCEDURE SearchBox(Str1 : Byte; Str2 : STRING; Str3 : Real; SearchF : STRING);
  PROCEDURE Info;
  PROCEDURE Credits;
  PROCEDURE Thanks;
  PROCEDURE Help;
  PROCEDURE ScanExoUpdate_Interface;
  PROCEDURE Filter_Interface;
  PROCEDURE Filter_Interface2(i : Byte);
  PROCEDURE Filter_Interface3(i : Byte);
  PROCEDURE Search_Interface;
  PROCEDURE Add_Interface;
  PROCEDURE Load_Interface;
  PROCEDURE Change_Interface;
  PROCEDURE Rename_Interface;
  PROCEDURE Delete_Interface;
  PROCEDURE Records_Interface;
  PROCEDURE Status_Interface;
  PROCEDURE Export_Interface1;
  PROCEDURE Export_Interface2;
  PROCEDURE Orbit_Interface1;
  PROCEDURE Orbit_Interface2;
  PROCEDURE Orbit_Interface3;
  PROCEDURE Starmap_Interface1;
  PROCEDURE Starmap_Interface2;
  PROCEDURE Starmap_Interface3;
  PROCEDURE MassCompare_Interface1;
  PROCEDURE MassCompare_Interface2;
  PROCEDURE Distribution_Interface1;
  PROCEDURE Distribution_Interface2;
  PROCEDURE Diagram_Interface1;
  PROCEDURE Diagram_Interface2;
  PROCEDURE HRD_Interface1;
  PROCEDURE HRD_Interface2;
  PROCEDURE HRD_Interface3;
  PROCEDURE HRD_Interface4;
  PROCEDURE Star3D_Interface;
  PROCEDURE Goto_Interface;
  PROCEDURE Msg_NoModule;
  PROCEDURE Msg_NoDataset;

IMPLEMENTATION

USES Crt,Dos,Graph,Arithmos,Cursor,RT_Watch,ConstVar;

CONST
  DE = 0; EN = 1; FR = 2; ES = 3; IT = 4;
  NULL  = Chr(00);
  TAB   = Chr(09);
  ENTER = Chr(13);
  ESC   = Chr(27);
  SPACE = Chr(32);
  ARUP  = 'H';
  ARDN  = 'P';
  ARLF  = 'K';
  ARRT  = 'M';
  PGUP  = 'I';
  PGDN  = 'Q';
  POS1  = 'G';
  END1  = 'O';
  EINFG = 'R';
  ENTF  = 'S';
  FileBufferSize = 32768;

VAR
  Fil             : ARRAY[0..20] OF STRING;
  ExoFile         : ARRAY[0..1000] OF STRING[12];
  Exit2,Korrektur,
  Found           : Boolean;
  Sprache         : Byte;
  Input,Input2,HZ : Char;
  Index,LPT,
  j,m,t,m2,t2,
  ExoFileMax,
  ExoFileStd,
  Zoom,Numb,n,i,b,
  mx,my,Numb3,Con : Integer;
  FileHandle      : FILE;
  SearchFile      : SearchRec;
  f,f2            : Text;
  mx2,my2,Numb2,
  Zoom2,Numb4,Numb5,
  Numb6,Numb7,Numb8,
  j3,m3,t3,j4,m4,t4,
  TempStr,
  CentralStar,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Method,
  PlanetName,
  Remarks,
  SearchStr,
  SpectralType    : STRING;
  Axis_Min,Axis_Max,
  Date_Min,Date_Max,
  Ecc_Min,Ecc_Max,
  Mass_Min,Mass_Max,
  a,p,e,
  SearchReal,
  Deklination,
  Distance,
  Eccentricity,
  Eccentricity2,
  Magnitude,
  Metalicity,
  Metalicity2,
  Period,Period2,
  PlanetMass,
  PlanetMass2,
  Rectaszension,
  SemiMajorAxis,
  SemiMajorAxis2,
  StarMass        : Real;


PROCEDURE Arrow;
BEGIN Write(''); END;

FUNCTION FileExists(FName : STRING) : Boolean;
VAR
  f     : FilE;
  fAttr : Word;
BEGIN
  Assign(f,FName);
  GetFAttr(f,fAttr);
  FileExists := (DosError = 0)
                AND ((fAttr AND Directory) = 0)
                AND ((fAttr AND VolumeID)  = 0);
END;

FUNCTION DirExists(DName : STRING) : Boolean;
VAR
  f     : FilE;
  fAttr : Word;
BEGIN
  Assign(f,DName);
  GetFAttr(f,fAttr);
  DirExists := ((fAttr AND Directory) <> 0) AND (DosError = 0);
END;

FUNCTION DeleteFile(FileName : STRING) : Boolean;
VAR FileAttr:word;
BEGIN
  Assign(FileHandle,FileName);
  GetFAttr(FileHandle,FileAttr);
  IF (FileAttr AND ReadOnly) <> 0 THEN SetFAttr(FileHandle,FileAttr AND (NOT ReadOnly));
  Erase(FileHandle);
  DeleteFile := (IOResult=0);
END;

FUNCTION RenameFile(InputFileName,OutputFileName : STRING) : Boolean;
BEGIN
  Assign(FileHandle,InputFileName);
  Rename(FileHandle,OutputFileName);
  RenameFile := (IOResult=0);
END;

FUNCTION UpString(inString : STRING) : STRING;
VAR
  index : Byte;
  tempString : STRING;
BEGIN
  FOR index := 1 TO Length(inString) DO tempString[index] := UpCase(inString[index]);
  tempString[0] := inString[0];
  UpString := tempString;
END;

FUNCTION ReadStr(Anzahl : Byte) : STRING;
VAR
  eingabe,puff : String;
  cf           : Text;
  savex,savey  : Byte;
BEGIN
  AssignCrt(cf);
  SetTextBuf(cf,puff,anzahl+2);
  Reset(cf);
  savex := WhereX;
  savey := WhereY;
  ReadLn(cf,eingabe);
  Close(cf);
  IF savey = Hi(WindMax)+1 THEN Dec(savey);
  GotoXY(savex+Length(eingabe),savey);
  ReadStr := eingabe;
END;

FUNCTION ReadInt(anzahl : Byte) : LongInt;
VAR
  eingabe,puff: String;
  cf          : Text;
  savex,savey : Byte;
  contr       : Integer;
  zahl        : LongInt;
BEGIN
  IF anzahl > 11 THEN anzahl := 11;
  AssignCrt(cf);
  SetTextBuf(cf,puff,anzahl+2);
  Reset(cf);
  savex := WhereX; savey := WhereY;
  REPEAT
   GotoXY(savex,savey);
    {ClrEoL;}
    ReadLn(cf,eingabe);
    IF savey = Hi(WindMax)+1 THEN Dec(savey);
    Val(eingabe,zahl,contr);
  UNTIL contr = 0;
  Close(cf);
  GotoXY(savex+Length(eingabe),savey);
  ReadInt := zahl;
END;

FUNCTION ReadReal(anzahl : Byte) : Real;
VAR
  eingabe,puff : String;
  cf           : Text;
  savex,savey  : Byte;
  contr        : Integer;
  zahl         : Real;
BEGIN
  IF anzahl > 11 THEN anzahl := 11;
  AssignCrt(cf);
  SetTextBuf(cf,puff,anzahl+2);
  Reset(cf);
  savex := WhereX;
  savey := WhereY;
  REPEAT
    GotoXY(savex,savey);
    {ClrEoL;}
    ReadLn(cf,eingabe);
    IF savey = Hi(WindMax)+1 THEN Dec(savey);
    Val(eingabe,zahl,contr);
  UNTIL contr = 0;
  Close(cf);
  GotoXY(savex+Length(eingabe),savey);
  ReadReal := zahl;
END;

FUNCTION ReadHMS : Real;
VAR
  h, min       : Integer;
  sec, sum     : Real;
  savex, savey : Integer;
BEGIN
  h:=ReadInt(3);
  Write(' h ');
  savex := WhereX;
  savey := WhereY;
  REPEAT
    GotoXY(savex,savey);
    {ClrEoL;}
    min := ReadInt(2);
  UNTIL min < 60;
  Write(' m ');
  savex := WhereX; savey := WhereY;
  REPEAT
    GotoXY(savex,savey);
    {ClrEoL;}
    sec := ReadReal(5);
  UNTIL sec < 60;
  Write(' s ');
  sum := Abs(h)+min/60+sec/3600;
  IF h < 0 THEN ReadHMS := -sum ELSE ReadHMS := sum;
END;

FUNCTION ReadDate : STRING;
VAR
  j,m,t,c      : Integer;
  tmp,tmp2     : STRING;
  savex, savey : Integer;
BEGIN
  savex := WhereX; savey := WhereY;
  Write('Jahr ');
  REPEAT
    {GotoXY(savex,savey);
    ClrEoL;}
    j := ReadInt(4);
  UNTIL j > 0;
  Write(' Monat ');
  savex := WhereX; savey := WhereY;
  REPEAT
    GotoXY(savex,savey);
    {ClrEoL;}
    m := ReadInt(2);
  UNTIL (m >= 0) AND (m <= 12);
  Write(' Tag ');
  savex := WhereX; savey := WhereY;
  REPEAT
    GotoXY(savex,savey);
    {ClrEoL;}
    t := ReadInt(2);
  UNTIL (t >= 0) AND (t <= 31);
  Str(j,tmp);
  tmp2 := tmp;
  IF m < 10 THEN tmp2 := tmp2+'0';
  Str(m,tmp);
  tmp2 := tmp2+tmp;
  IF t < 10 THEN tmp2 := tmp2+'0';
  Str(t,tmp);
  tmp2 := tmp2+tmp;
  ReadDate := tmp2;
END;

FUNCTION ReadDeg : Real;
VAR
  h, min       : Integer;
  sec, sum     : Real;
  savex, savey : Integer;
BEGIN
  h := ReadInt(3);
  Write('¯ ');
  savex := WhereX;
  savey := WhereY;
  REPEAT
    GotoXY(savex,savey);
    {ClrEoL;}
    min := ReadInt(2);
  UNTIL min < 60;
  Write(chr(39),' ');
  savex := WhereX;
  savey := WhereY;
  REPEAT
    GotoXY(savex,savey);
    {ClrEoL;}
    sec := ReadReal(5);
  UNTIL sec < 60;
  Write('" ');
  sum := Abs(h)+min/60+sec/3600;
  IF h < 0 THEN ReadDeg := -sum ELSE ReadDeg := sum;
END;

FUNCTION RealToHms(kooD : Real) : STRING;
VAR
  kooG      : STRING;
  zweistell : STRING[2];
  dez       : Real;
BEGIN
  kooG := '';
  Str(Trunc(kooD),kooG);
  kooG := kooG+' h ';
  dez := Abs(Frac(kooD))*60;
  Str(Trunc(dez),zweistell);
  IF dez < 10 THEN kooG := kooG+'0';
  kooG := kooG+zweistell+' m ';
  dez := Abs(Frac(dez))*60;
  Str(dez:2:0,zweistell);
  IF dez < 10 THEN kooG := kooG+'0'+Copy(zweistell,2,1)+' s '
              ELSE kooG := kooG+zweistell+' s ';
  RealToHMS := kooG;
END;

FUNCTION RealToDeg(kooD : Real) : STRING;
VAR
  kooG      : STRING;
  zweistell : STRING[2];
  dez       : Real;
BEGIN
  kooG := '';
  Str(Trunc(kooD),kooG);
  kooG := kooG+' h ';
  dez := Abs(Frac(kooD))*60;
  Str(Trunc(dez),zweistell);
  IF dez < 10 THEN kooG := kooG+'0';
  kooG := kooG+zweistell+' m ';
  dez := Abs(Frac(dez))*60;
  Str(dez:2:0,zweistell);
  IF dez < 10 THEN kooG := kooG+'0'+Copy(zweistell,2,1)+' s '
              ELSE kooG := kooG+zweistell+' s ';
  RealToDeg := kooG;
END;

FUNCTION GetLangStr(Row : Word) : STRING;
VAR
  FileStr  : STRING;
  LangFile : Text;
  x        : Word;
BEGIN
  IF FileExists('LANGUAGE.DIC') THEN BEGIN
    Assign(LangFile,'LANGUAGE.DIC');
    Reset(LangFile);
    FOR x := 1 TO Row-1 DO ReadLn(LangFile,FileStr);
    ReadLn(LangFile,FileStr);
    Close(LangFile);
  END;
  GetLangStr := FileStr;
END;

PROCEDURE BlinkOn;
BEGIN
  ASM
    mov AH,10h
    mov AL,03h
    mov BL,1
    int 10h
  END;
END;

PROCEDURE BlinkOff;
BEGIN
  ASM
    mov AH,10h
    mov AL,03h
    mov BL,0
    int 10h
  END;
END;

PROCEDURE Wait(ms : Word); ASSEMBLER;
ASM
  mov ax, 1000;
  mul ms;
  mov cx, dx;
  mov dx, ax;
  mov ah, $86;
  Int $15;
END;

FUNCTION PrinterOK(lprn : Integer) : Byte;
VAR
  Code : Byte;
  regs : Registers;
BEGIN
  Dec(lprn);
  IF ((lprn >= 0) AND (lprn <= 2)) THEN
  regs.ah := 2;
  regs.dx := lprn;
  Intr($17, regs);
  code := regs.ah;
  IF code <> $90 THEN BEGIN
    CASE code OF
      $02, $4A : PrinterOK := 1; {Printer is not connected}
      $00, $10,
      $18, $58 : PrinterOK := 2; {Printer is offline}
      $28, $38 : PrinterOK := 3; {Printer is out of paper}
      $88, $C8 : PrinterOK := 4; {Printer is turned off}
     ELSE PrinterOK := 5;        {Output device is not ready}
    END
  END ELSE PrinterOK := 0;       {Printer is ready}
END;

PROCEDURE Blank6;
BEGIN Write('      '); END;

PROCEDURE Blank10;
BEGIN Write('          '); END;

PROCEDURE Blank12;
BEGIN Write('            '); END;

PROCEDURE Blank17;
BEGIN Write('                 '); END;

PROCEDURE Blank20;
BEGIN Write('                   '); END;

PROCEDURE Blank25;
BEGIN Write('                         '); END;

PROCEDURE Blank29;
BEGIN Write('                             '); END;

PROCEDURE SetButton(x1,y1,BackgrCol,ForegrCol : Byte; Str : STRING; Stop : Byte);
BEGIN
  TextBackground(BackgrCol);
  TextColor(ForegrCol);
  GotoXY(x1,y1);
  Write(Str);
  Wait(Stop);
END;

PROCEDURE MessageBox(x1,y1,x2,y2,BackgrCol,ForegrCol,BorderCol1,BorderCol2 : Byte);
BEGIN
  TextBackground(BackgrCol);
  TextColor(ForegrCol);
  FOR i := x1 TO x2 DO BEGIN
    FOR n := y1 TO y2 DO BEGIN
      GotoXY(i,n); Write(' ');
    END;
  END;
  TextColor(BorderCol1);
  GotoXY(x1,y1); Write('⁄');
  FOR i := x1+1 TO x2-1 DO BEGIN
    GotoXY(i,y1); Write('ƒ');
  END;
  GotoXY(x2,y1); Write('ø');
  FOR i := y1+1 TO y2-1 DO BEGIN
    GotoXY(x1,i); Write('≥');
  END;
  TextColor(BorderCol2);
  GotoXY(x1,y2); Write('¿');
  FOR i := x1+1 TO x2-1 DO BEGIN
    GotoXY(i,y2); Write('ƒ');
  END;
  GotoXY(x2,y2); Write('Ÿ');
  FOR i := y1+1 TO y2-1 DO BEGIN
    GotoXY(x2,i); Write('≥');
  END;
END;

PROCEDURE MainApp;
BEGIN
  Exit2 := False;
  BlinkOff;
  TextBackground(LightBlue);
  TextColor(Blink);
  HideCursor;
  FOR i := 1 TO 80 DO BEGIN
    FOR n := 2 TO 50 DO BEGIN
      GotoXY(i,n); Write(' ');
    END;
  END;
  TextColor(White+Blink);
  GotoXY(1,1); Write('⁄');
  FOR i := 2 TO 79 DO BEGIN
    GotoXY(i,1); Write('ƒ');
  END;
  GotoXY(1,80); Write('ø');
  FOR i := 1 TO 3 DO BEGIN
    GotoXY(1,1+i); Write('≥');
  END;
  TextColor(Black+Blink);
  GotoXY(1,5); Write('¿');
  FOR i := 2 TO 79 DO BEGIN
    GotoXY(i,5); Write('ƒ');
  END;
  GotoXY(80,5); Write('Ÿ');
  FOR i := 1 TO 3 DO BEGIN
    GotoXY(80,1+i); Write('≥');
  END;
  TextColor(Yellow+Blink);
  GotoXY(10,3);
  Write('EXOPLANETEN-DATENBANK (EXO-DB2)   Version: 1.6   (C) 1995-2005');
  TextColor(White+Blink);
  GotoXY(4,07); Write('DATENBANK');
  GotoXY(4,09); Write('1 - erstellen');
  GotoXY(4,10); Write('2 - laden');
  GotoXY(4,11); Write('3 - Ñndern');
  GotoXY(4,12); Write('4 - umbenennen');
  GotoXY(4,13); Write('5 - exportieren');
  GotoXY(4,14); Write('6 - lîschen');
  GotoXY(26,07); Write('MODULE');
  GotoXY(26,09); Write('o - Orbit-Abbild');
  GotoXY(26,10); Write('m - Masse-Vergleich');
  GotoXY(26,11); Write('s - Sternkarte');
  GotoXY(26,12); Write('d - Distribution');
  GotoXY(26,13); Write('a - Diagramme');
  GotoXY(26,14); Write('h - HRD');
  GotoXY(26,15); Write('p - Star3D');
  GotoXY(26,16); Write('r - Rekorde');
  GotoXY(26,17); Write('u - Planeten-Status');
  GotoXY(50,07); Write('SONSTIGES');
  GotoXY(50,09); Write('i - Programm-Info');
  GotoXY(50,10); Write('c - Credits');
  GotoXY(50,11); Write('t - Danksagung');
  GotoXY(50,12); Write('e - Hilfe');
  GotoXY(50,13); Write('f - Suchen');
  GotoXY(50,14); Write('v - Filter');
  GotoXY(50,15); Write('z - Bildschirmschoner');
  GotoXY(50,16); Write('x - Exit');
  TextColor(White+Blink);
  GotoXY(1,18); Write('⁄');
  FOR i := 2 TO 79 DO BEGIN
    GotoXY(i,18); Write('ƒ');
  END;
  GotoXY(1,80); Write('ø');
  FOR i := 1 TO 3 DO BEGIN
    GotoXY(1,18+i); Write('≥');
  END;
  TextColor(Black+Blink);
  GotoXY(1,4+18); Write('¿');
  FOR i := 2 TO 79 DO BEGIN
    GotoXY(i,4+18); Write('ƒ');
  END;
  GotoXY(80,4+18); Write('Ÿ');
  FOR i := 1 TO 3 DO BEGIN
    GotoXY(80,18+i); Write('≥');
  END;
  SetButton(04,20,White,Black+Blink,' ˛ ',0);
  SetButton(10,20,White,Black+Blink,' << ',0);
  SetButton(16,20,White,Black+Blink,' <- ',0);
  SetButton(22,20,White,Black+Blink,' -> ',0);
  SetButton(28,20,White,Black+Blink,' >> ',0);
  SetButton(34,20,White,Black+Blink,' ˛ ',0);
  TextBackground(LightBlue);
  TextColor(Yellow+Blink);
  GotoXY(40,20);
  Write('G');
  TextColor(White+Blink);
  Write('ehe zu: ');
  TextBackground(Black);
  TextColor(White);
  Write('   ');
  TextBackground(LightBlue);
  TextColor(White+Blink);
  GotoXY(54,20);
  Write('000 / 000');
  GotoXY(65,20);
  TextBackground(Black);
  TextColor(White);
  WriteLn('xxxxxxxx.exo');
  TextBackground(LightBlue);
{  TextColor(Yellow+Blink);
  GotoXY(2,23);
  Write('Tool-Tipp:');}
  TextColor(Black+Blink);
  GotoXY(1,24); Write('⁄');
  GotoXY(80,24); Write('ø');
  FOR i := 2 TO 79 DO BEGIN
    GotoXY(i,24); Write('ƒ');
  END;
  FOR i := 1 TO 25 DO BEGIN
    GotoXY(1,24+i); Write('≥');
  END;
  TextColor(White+Blink);
  FOR i := 2 TO 79 DO BEGIN
    GotoXY(i,25+24); Write('ƒ');
  END;
  FOR i := 1 TO 25 DO BEGIN
    GotoXY(80,24+i); Write('≥');
  END;
  GotoXY(80,25+24); Write('Ÿ');
  GotoXY(1,25+24); Write('¿');
  GotoXY(03,2+24);
  Write('DATENANGABE ZUM ZENTRALSTERN');
  GotoXY(03,2+24+01);
  Write('----------------------------');
  GotoXY(40,2+24);
  Write('DATENANGABE ZUM EXOPLANETEN');
  GotoXY(40,2+24+01);
  Write('----------------------------');
  TextColor(Yellow+Blink);
  GotoXY(03,2+24+03);
  Write('Name des Zentralsterns');
  GotoXY(03,2+24+05);
  Write('Spektraltyp/Leuchtkraftklasse');
  GotoXY(03,2+24+07);
  Write('Scheinbare Helligkeit mag');
  GotoXY(03,2+24+09);
  Write('Masse in Sonnenmasse');
  GotoXY(03,2+24+11);
  Write('MetallizitÑt');
  GotoXY(03,2+24+13);
  Write('Entfernung zur Sonne in Parsec');
  GotoXY(03,2+24+15);
  Write('Rektaszension (2000)');
  GotoXY(03,2+24+17);
  Write('Deklination (2000)');
  GotoXY(03,2+24+19);
  Write('Sternbild');
  GotoXY(40,2+24+03);
  Write('Standardbezeichnung des Planet');
  GotoXY(40,2+24+05);
  Write('Masse in Jupitermasse');
  GotoXY(40,2+24+07);
  Write('Gro·e Halbachse in AE');
  GotoXY(40,2+24+09);
  Write('Umlaufzeit in Tage ');
  GotoXY(40,2+24+11);
  Write('Num. ExzentrizitÑt');
  GotoXY(40,2+24+13);
  Write('Methode des Entdeckung');
  GotoXY(40,2+24+15);
  Write('Entdeckungsdatum');
  GotoXY(40,2+24+17);
  Write('Entdecker/-team');
  GotoXY(40,2+24+19);
  Write('Notiz, Bermerkung etc.');
  TextBackground(Black);
  TextColor(White);
  FOR i := 4 TO 20 DO BEGIN
    IF NOT(Odd(i)) THEN BEGIN
      GotoXY(03,26+i);
      Blank29;
      GotoXY(40,26+i);
      Blank29;
    END;
  END;
END;

PROCEDURE SearchBox(Str1 : Byte; Str2 : STRING; Str3 : Real; SearchF : STRING);
BEGIN
  SearchBox2;
  SearchBoxString(Str1);
  SearchBox3;
  IF Str2 <> '' THEN Write(Str2) ELSE Write(Str3:0:2);
  Write(SearchStr);
  SearchBox4;
  IF Str2 <> '' THEN Write(Str2) ELSE Write(Str3:0:2);
  SearchBox5;
  Write(SearchF);
  SearchBox6;
END;

PROCEDURE SearchBoxString(Str1 : Byte);
BEGIN
  CASE Str1 OF
    01 : Write('dem Zentralstern ');
    02 : Write('dem Spektraltyp');
    03 : Write('der Helligkeit (mag)');
    04 : Write('der Sternmasse (MSol)');
    05 : Write('der MetallizitÑt');
    06 : Write('der Distanz (Parsec)');
    07 : Write('der Rektaszension (hms)');
    08 : Write('der Deklination (¯ ` ")');
    09 : Write('dem Sternbild');
    10 : Write('dem Planetenname');
    11 : Write('der Planetenmasse (MJup)');
    12 : Write('der Gr. Halbachse (AE)');
    13 : Write('der Umlaufzeit (Tage)');
    14 : Write('der ExzentrizitÑt');
    15 : Write('der Entdeckungsmethode');
    16 : Write('dem Entdeckungsdatum');
    17 : Write('den Entdeckern');
    18 : Write('der Notiz');
  END;
END;

PROCEDURE SearchBox2;
BEGIN
  MessageBox(20,10,60,29,LightGray,LightGray,White,DarkGray);
  Found := True;
  TextBackground(LightGray);
  TextColor(Black);
  GotoXY(24,15);
  Write('Der gesuchte Begriff ');
  GotoXY(24,18);
  Write('entspricht');
  GotoXY(35,18);
END;

PROCEDURE SearchBox3;
BEGIN
  GotoXY(24,21);
  Write('des Datensatzes ');
  TextColor(Yellow);
  GotoXY(24,16);
  Write('                    ');
  GotoXY(24,16);
END;

PROCEDURE SearchBox4;
BEGIN
  TextColor(Yellow);
  GotoXY(24,19);
  Write('                    ');
  GotoXY(24,19);
END;

PROCEDURE SearchBox5;
BEGIN
  TextColor(Yellow);
  GotoXY(24,22);
  Write('                    ');
  GotoXY(24,22);
END;

PROCEDURE SearchBox6;
BEGIN
  SetButton(38,27,White,Black+Blink,'  OK  ',0);
  REPEAT
    Input := ReadKey;
  UNTIL Input <> NULL;
  SetButton(38,27,White,LightRed+Blink,'  OK  ',50);
  SetButton(38,27,White,Black+Blink,'  OK  ',50);
END;



{
PROCEDURE SearchBox(Str1 : Byte; Str2 : STRING; Str3 : Real);
BEGIN
  MessageBox(20,10,60,29,LightGray,LightGray,White,DarkGray);
  Found := True;
  TextBackground(LightGray);
  TextColor(Black);
  GotoXY(24,15);
  Write('Der gesuchte Begriff ');
  GotoXY(24,18);
  Write('entspricht');
  GotoXY(35,18);
  CASE Str1 OF
    01 : Write('dem Zentralstern ');
    02 : Write('dem Spektraltyp');
    03 : Write('der Helligkeit');
    04 : Write('der Sternmasse');
    05 : Write('der MetallizitÑt');
    06 : Write('der Distanz');
    07 : Write('der Rektaszension');
    08 : Write('der Deklination');
    09 : Write('dem Sternbild');
    10 : Write('dem Planetenname');
    11 : Write('der Planetenmasse');
    12 : Write('der Gr. Halbachse');
    13 : Write('der Umlaufzeit');
    14 : Write('der ExzentrizitÑt');
    15 : Write('der Entdeckungsmethode');
    16 : Write('dem Entdeckungsdatum');
    17 : Write('den Entdeckern');
    18 : Write('der Notiz');
  END;
  GotoXY(24,21);
  Write('des Datensatzes ');
  TextColor(Yellow);
  GotoXY(24,16);
  Write('                    ');
  GotoXY(24,16);
  Write(SearchStr);
  GotoXY(24,19);
  Write('                    ');
  GotoXY(24,19);
  IF Str2 <> '' THEN Write(Str2) ELSE Write(Str3:0:2);
  GotoXY(24,22);
  Write('                    ');
  GotoXY(24,22);
  Write(SearchFile.Name);
  SetButton(38,27,White,Black+Blink,'  OK  ',0);
  REPEAT
    Input := ReadKey;
  UNTIL Input <> NULL;
  SetButton(38,27,White,LightRed+Blink,'  OK  ',50);
  SetButton(38,27,White,Black+Blink,'  OK  ',50);
END;}

PROCEDURE Info;
BEGIN
  IF FileExists('info.man') THEN BEGIN
    TextBackground(LightBlue);
    TextColor(LightRed+Blink);
    GotoXY(50,09); Writeln('i - Programm-Info');
    Wait(50);
    TextColor(Yellow+Blink);
    GotoXY(50,09); Writeln('i - Programm-Info');
    TextBackground(LightGray);
    TextColor(LightGray);
    MessageBox(17,09,63,36,LightGray,LightGray,White,DarkGray);
    TextBackground(White);
    TextColor(Black+Blink);
{    GotoXY(38,33);
    Write('  OK  ');}
    SetButton(38,33,White,Black+Blink,'  OK  ',0);
    TextBackground(LightGray);
    Assign(f,'info.man');
    Reset(f);
    FOR i := 1 TO 20 DO BEGIN
      ReadLn(f,Fil[0]);
      CASE i OF
        01..05 : TextColor(White);
        06..11 : TextColor(Blue);
        ELSE TextColor(Black);
      END;
      GotoXY(19,10+i);
      WriteLn(Fil[0]);
    END;
    Close(f);
    REPEAT
      Input := ReadKey;
    UNTIL Input <> NULL;
    TextBackground(White);
    TextColor(LightRed+Blink);
    SetButton(38,33,White,LightRed+Blink,'  OK  ',50);
    TextColor(Black+Blink);
    SetButton(38,33,White,Black+Blink,'  OK  ',50);
    MainApp;
  END;
END;

PROCEDURE Credits;
BEGIN
  IF FileExists('credits.man') THEN BEGIN
    TextBackground(LightBlue);
    TextColor(LightRed+Blink);
    GotoXY(50,10); Writeln('c - Credits');
    Wait(50);
    TextColor(Yellow+Blink);
    GotoXY(50,10); Writeln('c - Credits');
    TextBackground(LightGray);
    TextColor(LightGray);
    MessageBox(17,09,63,30,LightGray,LightGray,White,DarkGray);
    TextColor(Black+Blink);
    SetButton(38,28,White,Black+Blink,'  OK  ',0);
    TextBackground(LightGray);
    Assign(f,'credits.man');
    Reset(f);
    FOR i := 1 TO 20 DO BEGIN
      ReadLn(f,Fil[0]);
      CASE i OF
        01..03 : TextColor(White);
        ELSE TextColor(Black);
      END;
      GotoXY(19,10+i);
      WriteLn(Fil[0]);
    END;
    Close(f);
    REPEAT
      Input := ReadKey;
    UNTIL Input <> NULL;
    SetButton(38,28,White,LightRed+Blink,'  OK  ',50);
    SetButton(38,28,White,Black+Blink,'  OK  ',50);
    MainApp;
  END;
END;

PROCEDURE Thanks;
BEGIN
  IF FileExists('thanks.man') THEN BEGIN
    TextBackground(LightBlue);
    TextColor(LightRed+Blink);
    GotoXY(50,11); Writeln('t - Danksagung');
    Wait(50);
    TextColor(Yellow+Blink);
    GotoXY(50,11); Writeln('t - Danksagung');
    TextBackground(LightGray);
    TextColor(LightGray);
    MessageBox(17,9,63,42,LightGray,LightGray,White,DarkGray);
    TextColor(Black+Blink);
    SetButton(38,40,White,Black+Blink,'  OK  ',0);
    TextBackground(LightGray);
    Assign(f,'thanks.man');
    Reset(f);
    FOR i := 1 TO 29 DO BEGIN
      ReadLn(f,Fil[0]);
      CASE i OF
        01..03 : TextColor(White);
        ELSE TextColor(Black);
      END;
      GotoXY(19,10+i);
      WriteLn(Fil[0]);
    END;
    Close(f);
    REPEAT
      Input := ReadKey;
    UNTIL Input <> NULL;
    SetButton(38,40,White,LightRed+Blink,'  OK  ',50);
    SetButton(38,40,White,Black+Blink,'  OK  ',50);
    MainApp;
  END
END;

PROCEDURE Help;
BEGIN
  IF FileExists('help.man') THEN BEGIN
    IF NOT(FileExists('list.exe')) AND NOT(FileExists('list.dat')) THEN BEGIN
      MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
      TextColor(Black+Blink);
      GotoXY(23,23);
      Write('Dieses Modul wurde nicht gefunden!');
      SetButton(37,25,White,Black+Blink,'  OK  ',0);
      REPEAT
        Input := ReadKey;
      UNTIL Input <> NULL;
      SetButton(37,25,White,LightRed+Blink,'  OK  ',50);
      SetButton(37,25,White,Black+Blink,'  OK  ',50);
    END ELSE BEGIN
      IF FileExists('list.exe') THEN BEGIN
        IF FileExists('list.dat') THEN BEGIN
          Assign(f2,'list.dat');
          Erase(f2);
        END;
         Assign(f2,'list.exe');
         Rename(f2,'list.dat');
      END;
      Assign(f2,'list.dat');
      Rename(f2,'list.exe');
      Exec('list.exe','help.man');
      Rename(f2,'list.dat');
    END;
    TextMode(300);
    MainApp;
  END
END;

PROCEDURE ScanExoUpdate_Interface;
BEGIN
  TextBackground(Black);
  TextColor(White);
  FOR i := 4 TO 20 DO BEGIN
    IF NOT(Odd(i)) THEN BEGIN
      GotoXY(03,26+i);
      Blank29;
      GotoXY(40,26+i);
      Blank29;
    END;
  END;
END;

PROCEDURE Filter_Interface;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(50,14); Writeln('v - Filter');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(50,14); Writeln('v - Filter');
  TextBackground(LightGray);
  TextColor(LightGray);
  MessageBox(5,9,75,29,LightGray,LightGray,White,DarkGray);
  SetButton(30,28,White,Black+Blink,'  OK  ',0);
  SetButton(40,28,White,Black+Blink,' NEIN ',0);
  TextBackground(LightGray);
  TextColor(White);
  GotoXY(8,11); Write('Filter:');
  TextColor(Black);
  GotoXY(08,13); Write('Spektraltyp');
  GotoXY(08,15); Write('Scheinbare Helligkeit mag');
  GotoXY(08,17); Write('Masse in Sonnenmasse');
  GotoXY(08,19); Write('MetallizitÑt');
  GotoXY(08,21); Write('Entfernung zur Sonne in Parsec');
  GotoXY(08,23); Write('Rektaszension (2000)');
  GotoXY(08,25); Write('Deklination (2000)');
  GotoXY(45,13); Write('Masse in Jupitermasse');
  GotoXY(45,15); Write('Gro·e Halbachse in AE');
  GotoXY(45,17); Write('Umlaufzeit in Tage ');
  GotoXY(45,19); Write('Num. ExzentrizitÑt');
  GotoXY(45,21); Write('Entdeckungsdatum');
  TextColor(Blue);
  GotoXY(45,25); Write('Fertig!');
  FOR i := 0 TO 14 DO BEGIN
    IF i < 7 THEN BEGIN
      TextBackground(LightGray);
      TextColor(White);
      GotoXY(08,13+1+(2*i)); Write('Von:');
      GotoXY(20,13+1+(2*i)); Write('Bis:');
      TextBackground(Black);
      TextColor(White);
      GotoXY(13,13+1+(2*i)); Blank6;
      GotoXY(25,13+1+(2*i)); Blank6;
      GotoXY(13,13+1+(2*i));
    END ELSE IF i > 9 THEN BEGIN
      IF i = 14 THEN BEGIN
        TextBackground(LightGray);
        TextColor(White);
        GotoXY(45,13+1+(2*(i-10))); Write('Von:');
        GotoXY(45,14+1+(2*(i-10))); Write('Bis:');
        TextBackground(Black);
        TextColor(White);
        GotoXY(50,13+1+(2*(i-10))); Blank17;
        GotoXY(50,14+1+(2*(i-10))); Blank17;
        GotoXY(50,13+1+(2*(i-10)));
      END ELSE BEGIN
        TextBackground(LightGray);
        TextColor(White);
        GotoXY(45,13+1+(2*(i-10))); Write('Von:');
        GotoXY(57,13+1+(2*(i-10))); Write('Bis:');
        TextBackground(Black);
        TextColor(White);
        GotoXY(50,13+1+(2*(i-10))); Blank6;
        GotoXY(62,13+1+(2*(i-10))); Blank6;
        GotoXY(50,13+1+(2*(i-10)));
      END;
    END;
  END;
  TextColor(Black);
  TextBackground(LightGray);
END;

PROCEDURE Filter_Interface2(i : Byte);
BEGIN
  TextBackground(Black);
  TextColor(White);
  CASE i OF
    0..6 : BEGIN
      GotoXY(13,13+1+(2*i)); Blank6;
      GotoXY(25,13+1+(2*i)); Blank6;
    END;
    14 : BEGIN
      GotoXY(50,13+1+(2*(i-10))); Blank17;
      GotoXY(50,14+1+(2*(i-10))); Blank17;
    END;
    10..13 : BEGIN
      GotoXY(50,13+1+(2*(i-10))); Blank6;
      GotoXY(62,13+1+(2*(i-10))); Blank6;
    END;
  END;
END;

PROCEDURE Filter_Interface3(i : Byte);
BEGIN
  TextBackground(Black);
  TextColor(White);
  CASE i OF
    0..6 : BEGIN
      GotoXY(13,13+1+(2*i)); Blank6;
      GotoXY(25,13+1+(2*i)); Blank6;
    END;
    14 : BEGIN
      GotoXY(50,13+1+(2*(i-10))); Blank17;
      GotoXY(50,14+1+(2*(i-10))); Blank17;
    END;
    10..13 : BEGIN
      GotoXY(50,13+1+(2*(i-10))); Blank6;
      GotoXY(62,13+1+(2*(i-10))); Blank6;
    END;
  END;
END;

PROCEDURE Search_Interface;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(50,13); Writeln('f - Suchen');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(50,13); Writeln('f - Suchen');
  TextBackground(LightGray);
  TextColor(LightGray);
  MessageBox(20,20,60,29,LightGray,LightGray,White,DarkGray);
  SetButton(38,27,White,Black+Blink,'  OK  ',0);
  TextBackground(LightGray);
  TextColor(Black);
  GotoXY(21,22);
  Write('Eingabe der gesuchten Zahl bzw. Wortes:');
  TextBackground(Black);
  TextColor(White);
  GotoXY(28,24);
  Write('                        ');
  GotoXY(28,24);
  ShowCursor;
END;

PROCEDURE Add_Interface;
BEGIN
  {GotoXY(1,14);
  Write('Mit Fehlerspanne? (j/n)');
  REPEAT
    Input := ReadKey;
  UNTIL Input IN ['j','J','y','Y','z','Z','n','N'];
  IF Input IN ['N','n'] THEN Korrektur := False ELSE Korrektur := True;}
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(4,9); Writeln('1 - erstellen');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(4,09); Writeln('1 - erstellen');
  TextBackground(Black);
  TextColor(White);
  FOR i := 4 TO 20 DO BEGIN
    IF NOT(Odd(i)) THEN BEGIN
      GotoXY(03,26+i);
      Blank29;
      GotoXY(40,26+i);
      Blank29;
    END;
  END;
  ShowCursor;
END;

PROCEDURE Load_Interface;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(4,10); Writeln('2 - laden');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(4,10); Writeln('2 - laden');
  TextBackground(LightGreen);
  TextColor(Blink);
  MessageBox(10,10,70,37,LightGray,LightGray,White,DarkGray);
  TextBackground(White);
  TextColor(Black+Blink);
  SetButton(63,14,White,Black+Blink,'  OK  ',0);
  SetButton(63,16,White,Black+Blink,' NEIN ',0);
  GotoXY(12,12);
  Write('DatensÑtze');
  GotoXY(33,12);
  Write('Kurzinformationen');
  TextBackground(Black);
  TextColor(White);
  FOR i := 1 TO 22 DO BEGIN
    GotoXY(12,13+i);
    Write('                  ');
    GotoXY(33,13+i);
    Blank29;
  END;
  FOR i := 1 TO 22 DO BEGIN
    GotoXY(17,13+i);
    Write('≥');
    GotoXY(30,13+i);
    Write('∞');
  END;
END;

PROCEDURE Change_Interface;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(4,11); Writeln('3 - Ñndern');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(4,11); Writeln('3 - Ñndern');
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
END;

PROCEDURE Rename_Interface;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(4,12); Writeln('4 - umbenennen');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(4,12); Writeln('4 - umbenennen');
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  ShowCursor;
  MessageBox(20,20,60,28,LightGray,LightGray,White,DarkGray);
  TextColor(Black);
  GotoXY(24,23);
  Write('Name des Datensatz zum Umbenennen:');
  GotoXY(24+8,25);
  Write('.EXO');
  TextBackground(Black);
  TextColor(White);
  GotoXY(24,25);
  Write('        ');
  SetButton(40,25,White,Black+Blink,'  OK  ',0);
END;

PROCEDURE Delete_Interface;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(4,14); Writeln('7 - lîschen');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(4,14); Writeln('7 - lîschen');
  MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
  TextColor(Black+Blink);
  GotoXY(22,23);
  Write('Wollen Sie diesen Datensatz lîschen?');
  SetButton(33,25,White,Black+Blink,'  JA  ',0);
  SetButton(40,25,White,Black+Blink,' NEIN ',0);
END;

PROCEDURE Records_Interface;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,16); Write('r - Rekorde');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(26,16); Write('r - Rekorde');
  TextBackground(LightGreen);
  TextColor(Blink);
  MessageBox(15,5,60,45,LightGray,LightGray,White,DarkGray);
  TextBackground(White);
  TextColor(Black+Blink);
  GotoXY(17,07); Write('Rekorde:');
  TextColor(Black);
  GotoXY(18,10); Write('Kleinste Planetenmasse:');
  GotoXY(18,12); Write('Grî·te Planetenmasse:');
  GotoXY(18,14); Write('Kleinste Halbachse (a):');
  GotoXY(18,16); Write('Grî·te Halbachse (a):');
  GotoXY(18,18); Write('Kleinste BahnexzentrizitÑt:');
  GotoXY(18,20); Write('Grî·te BahnexzentrizitÑt:');
  GotoXY(18,22); Write('Zuerst entdecker Exoplanet:');
  GotoXY(18,24); Write('Neuester entdeckte Exoplanet:');
  GotoXY(18,28); Write('FrÅhester Spektralklasse:');
  GotoXY(18,30); Write('SpÑteste Spektralklasse:');
  GotoXY(18,32); Write('Kleinste Sternmasse:');
  GotoXY(18,34); Write('Grî·te Sternmasse:');
  GotoXY(18,36); Write('NÑheste Entfernung:');
  GotoXY(18,38); Write('Weiteste Entfernung:');
  GotoXY(18,40); Write('Grî·te Helligkeit:');
  GotoXY(18,42); Write('Kleinste Helligkeit:');
  TextColor(Red);
  GotoXY(26,7); Write('Lese...');
  TextColor(Blue);
END;

PROCEDURE Status_Interface;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,18); Write('u - Planeten-Status');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(26,18); Write('u - Planeten-Status');
  TextBackground(LightGreen);
  TextColor(Blink);
  MessageBox(15,5,60,33,LightGray,LightGray,White,DarkGray);
  TextBackground(White);
  TextColor(Black+Blink);
  GotoXY(17,07); Write('Planeten-Status:');
  TextColor(White);
  GotoXY(17,9); Write('sortiert nach Planetenmasse');
  TextColor(Black);
  GotoXY(18,11); Write('Uranus/Neptun-Ñhnlich:');
  GotoXY(19,12); Write('(Masse < 0.2 MJup)');
  GotoXY(18,13); Write('Saturn-Ñhnlich:');
  GotoXY(19,14); Write('(Masse 0.2..0.5 MJup)');
  GotoXY(18,15); Write('Jupiter-Ñhnlich:');
  GotoXY(19,16); Write('(Masse 0.5..5.0 MJup)');
  GotoXY(18,17); Write('Superjupiter-Ñhnlich:');
  GotoXY(19,18); Write('(Masse 5.0..10.0 MJup)');
  GotoXY(18,19); Write('Brauner Zwerg-Ñhnlich:');
  GotoXY(19,20); Write('(Masse > 10.0 MJup)');
  TextColor(White);
  GotoXY(17,22); Write('sortiert nach Bahn');
  TextColor(Black);
  GotoXY(18,24); Write('kreisfîrmig, kurzperiodisch:');
  GotoXY(19,25); Write('(e < 0.25; T < 88 d)');
  GotoXY(18,26); Write('exzentrisch, kurzperiodisch:');
  GotoXY(19,27); Write('(e > 0.25; T < 88 d)');
  GotoXY(18,28); Write('kreisfîrmig, langperiodisch:');
  GotoXY(19,29); Write('(e < 0.25; T > 88 d)');
  GotoXY(18,30); Write('exzentrisch, langperiodisch:');
  GotoXY(19,31); Write('(e > 0.25; T > 88 d)');
  {TextColor(White);
  GotoXY(17,33); Write('sortiert nach Sterntyp');
  TextColor(Black);
  GotoXY(18,35); Write('öberriese:');
  GotoXY(18,36); Write('Riese:');
  GotoXY(18,37); Write('Hauptreihen-Stern:');
  GotoXY(18,38); Write('Wei·er Zwerg:');
  GotoXY(18,39); Write('Roter Zwerg:');
  GotoXY(18,40); Write('Brauner Zwerg:');
  GotoXY(18,41); Write('Unbekannt:');}
  TextColor(Red);
  GotoXY(34,7); Write('Lese...');
  TextColor(Blue);
END;

PROCEDURE Export_Interface1;
BEGIN
  MessageBox(20,20,57,28,LightGray,LightGray,White,DarkGray);
  TextColor(Black);
  GotoXY(23,22);
  Write('WÑhlen Sie ein Format:');
  GotoXY(24,24);
  Write('TXT      CSV');
  GotoXY(24,25);
  Write('HTM      SYLK');
  GotoXY(24,26);
  Write('RTF');
  SetButton(48,24,White,Black+Blink,'  OK  ',0);
  SetButton(48,26,White,Black+Blink,' NEIN ',0);
  TextBackground(LightGray);
  TextColor(LightRed);
  GotoXY(22,24); Arrow;
END;

PROCEDURE Export_Interface2;
BEGIN
  IF FileExists('export.exe') THEN BEGIN
    IF FileExists('export.dat') THEN BEGIN
      Assign(f2,'export.dat');
      Erase(f2);
    END;
    Assign(f2,'export.exe');
    Rename(f2,'export.dat');
  END;
END;

PROCEDURE Orbit_Interface1;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,09); Write('o - Orbit-Abbild');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(26,09); Write('o - Orbit-Abbild');
  TextBackground(LightGreen);
  TextColor(Blink);
  MessageBox(10,10,70,37,LightGray,LightGray,White,DarkGray);
  TextBackground(White);
  TextColor(Black+Blink);
  SetButton(63,14,White,Black+Blink,'  OK  ',0);
  SetButton(63,16,White,Black+Blink,' NEIN ',0);
  SetButton(63,18,White,Black+Blink,'  ->  ',0);
  SetButton(63,20,White,Black+Blink,'  <-  ',0);
  SetButton(63,22,White,Black+Blink,' Alle ',0);
  GotoXY(12,12); Write('DatensÑtze');
  TextBackground(Black);
  TextColor(White);
  FOR i := 1 TO 22 DO BEGIN
    GotoXY(12,13+i);
    Write('                  ');
    GotoXY(33,13+i);
    Blank29;
  END;
  FOR i := 1 TO 22 DO BEGIN
    GotoXY(17,13+i);
    Write('≥');
    GotoXY(30,13+i);
    Write('∞');
  END;
  GotoXY(30,14); Write('');
  GotoXY(30,35); Write('');
END;

PROCEDURE Orbit_Interface2;
BEGIN
  MessageBox(20,10,60,29,LightGray,LightGray,White,DarkGray);
  SetButton(38,27,White,Black+Blink,'  OK  ',0);
  TextBackground(LightGray);
  TextColor(Black);
  GotoXY(23,13); Write('Zoom-Faktor:');
  GotoXY(34,15); Write('(default = 100)');
  GotoXY(23,17); Write('Mittelpunktverschiebung x-Achse:');
  GotoXY(34,19); Write('(default = 0)');
  GotoXY(23,21); Write('Mittelpunktverschiebung y-Achse:');
  GotoXY(34,23); Write('(default = 0)');
  GotoXY(23,25); Write('Bewohnbare Zone (HZ)? [J/N]');
  TextBackground(Black);
  TextColor(White);
  GotoXY(23,15); Write('         ');
  GotoXY(23,19); Write('         ');
  GotoXY(23,23); Write('         ');
  GotoXY(51,25); Write(' ');
  ShowCursor;
END;

PROCEDURE Orbit_Interface3;
BEGIN
  IF FileExists('orbit.exe') THEN BEGIN
    IF FileExists('orbit.dat') THEN BEGIN
      Assign(f2,'orbit.dat');
      Erase(f2);
    END;
    Assign(f2,'orbit.exe');
    Rename(f2,'orbit.dat');
  END;
END;

PROCEDURE Starmap_Interface1;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,11); Write('s - Sternkarte');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(26,11); Write('s - Sternkarte');
  TextBackground(LightGreen);
  TextColor(Blink);
  MessageBox(10,10,70,37,LightGray,LightGray,White,DarkGray);
  TextBackground(White);
  TextColor(Black+Blink);
  SetButton(63,14,White,Black+Blink,'  OK  ',0);
  SetButton(63,16,White,Black+Blink,' NEIN ',0);
  SetButton(63,18,White,Black+Blink,'  ->  ',0);
  SetButton(63,20,White,Black+Blink,'  <-  ',0);
  SetButton(63,22,White,Black+Blink,' Alle ',0);
  GotoXY(12,12); Write('DatensÑtze');
  TextBackground(Black);
  TextColor(White);
  FOR i := 1 TO 22 DO BEGIN
    GotoXY(12,13+i);
    Write('                  ');
    GotoXY(33,13+i);
    Blank29;
  END;
  FOR i := 1 TO 22 DO BEGIN
    GotoXY(17,13+i);
    Write('≥');
    GotoXY(30,13+i);
    Write('∞');
  END;
  GotoXY(30,14); Write('');
  GotoXY(30,35); Write('');
END;

PROCEDURE Starmap_Interface2;
BEGIN
  MessageBox(20,10,60,29,LightGray,LightGray,White,DarkGray);
  SetButton(38,27,White,Black+Blink,'  OK  ',0);
  TextBackground(LightGray);
  TextColor(Black);
  GotoXY(22,13); Write('Vergrîsserung? [j/n]');
  GotoXY(22,15); Write('Gradnetz? [j/n]');
  GotoXY(22,17); Write('Ekliptik u. HimmelsÑquator? [j/n]');
  GotoXY(22,19); Write('Sternbilder-Konstellationen? [j/n]');
  GotoXY(22,21); Write('Begrenzung fÅr Sternbilder? [j/n]');
  GotoXY(22,23); Write('Bezeichnung fÅr Sternbilder? [j/n]');
  GotoXY(22,25); Write('Bezeichnung fÅr Sterne? [j/n]');
END;

PROCEDURE StarMap_Interface3;
BEGIN
  IF FileExists('starmap.exe') THEN BEGIN
    IF FileExists('starmap.dat') THEN BEGIN
      Assign(f2,'starmap.dat');
      Erase(f2);
    END;
    Assign(f2,'starmap.exe');
    Rename(f2,'starmap.dat');
  END;
END;

PROCEDURE MassCompare_Interface1;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,10); Write('m - Masse-Vergleich');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(26,10); Write('m - Masse-Vergleich');
  TextBackground(LightGreen);
  TextColor(Blink);
  MessageBox(10,10,70,37,LightGray,LightGray,White,DarkGray);
  TextBackground(White);
  TextColor(Black+Blink);
  SetButton(63,14,White,Black+Blink,'  OK  ',0);
  SetButton(63,16,White,Black+Blink,' NEIN ',0);
  SetButton(63,18,White,Black+Blink,'  ->  ',0);
  SetButton(63,20,White,Black+Blink,'  <-  ',0);
  GotoXY(12,12); Write('DatensÑtze');
  TextBackground(Black);
  TextColor(White);
  FOR i := 1 TO 22 DO BEGIN
    GotoXY(12,13+i);
    Write('                  ');
    GotoXY(33,13+i);
    Blank29;
  END;
  FOR i := 1 TO 22 DO BEGIN
    GotoXY(17,13+i);
    Write('≥');
    GotoXY(30,13+i);
    Write('∞');
  END;
  GotoXY(30,14); Write('');
  GotoXY(30,35); Write('');
END;

PROCEDURE MassCompare_Interface2;
BEGIN
  IF FileExists('masscomp.exe') THEN BEGIN
    IF FileExists('masscomp.dat') THEN BEGIN
      Assign(f2,'masscomp.dat');
      Erase(f2);
    END;
    Assign(f2,'masscomp.exe');
    Rename(f2,'masscomp.dat');
  END;
END;

PROCEDURE Distribution_Interface1;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,12); Write('d - Distribution');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(26,12); Write('d - Distribution');
END;

PROCEDURE Distribution_Interface2;
BEGIN
  IF FileExists('distri.exe') THEN BEGIN
    IF FileExists('distri.dat') THEN BEGIN
      Assign(f2,'distri.dat');
      Erase(f2);
    END;
    Assign(f2,'distri.exe');
    Rename(f2,'distri.dat');
  END;
  MessageBox(20,20,60,36,LightGray,LightGray,White,DarkGray);
  TextColor(Black);
  GotoXY(23,22); Write('Was soll gezÑhlt werden:');
  GotoXY(24,24); Write('1) - Num. ExzentrizitÑt');
  GotoXY(24,25); Write('2) - Masse d. Exoplaneten');
  GotoXY(24,26); Write('3) - Gro·e Halbachse');
  GotoXY(24,27); Write('4) - JÑhrliche Entdeckungen');
  GotoXY(29,28); Write('JÑhrl. Zusammenfassung   (J/N)');
  GotoXY(29,28);
  TextBackground(Black);
  TextColor(White);
  GotoXY(52,28); Write(' ');
  TextBackground(LightGray);
  TextColor(Black);
  GotoXY(24,29); Write('5) - Spektralklasse');
  GotoXY(24,30); Write('6) - Distanz zur Sonne');
  GotoXY(24,31); Write('7) - Scheinbare Helligkeit');
  GotoXY(24,32); Write('8) - MetallizitÑt');
  GotoXY(24,33); Write('9) - Zentralstern-Masse');
  GotoXY(23,34); Write('10) - Absolute Helligkeit');
  GotoXY(23,35); Write('11) - RV der Exoplaneten');
  TextColor(Black+Blink);
  SetButton(53,24,White,Black+Blink,'  OK  ',0);
  SetButton(53,26,White,Black+Blink,' NEIN ',0);
  TextBackground(LightGray);
  TextColor(LightRed);
  GotoXY(22,24); Arrow;
END;

PROCEDURE Diagram_Interface1;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,13); Write('a - Diagramme');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(26,13); Write('a - Diagramme');
END;

PROCEDURE Diagram_Interface2;
BEGIN
  IF FileExists('diagram.exe') THEN BEGIN
    IF FileExists('diagram.dat') THEN BEGIN
      Assign(f2,'diagram.dat');
      Erase(f2);
    END;
    Assign(f2,'diagram.exe');
    Rename(f2,'diagram.dat');
  END;
  MessageBox(20,20,60,39,LightGray,LightGray,White,DarkGray);
  TextColor(Black);
  GotoXY(23,22); Write('Folgende Diagramme sind wÑhlbar:');
  TextColor(Black);
  GotoXY(24,24); Write('1) - Halbachse / Exzentri.');
  GotoXY(24,25); Write('2) - Halbachse / Masse');
  GotoXY(24,26); Write('3) - Exzentri. / Masse');
  GotoXY(24,27); Write('4) - Halbachse / Periode');
  GotoXY(24,28); Write('5) - Entdeckungsjahr / Halbachse');
  GotoXY(24,29); Write('6) - Entdeckungsjahr / Planetenmasse');
  GotoXY(24,30); Write('7) - Sternmasse / MetallizitÑt');
  GotoXY(24,31); Write('8) - Spektraltyp / MetallizitÑt');
  GotoXY(24,32); Write('9) - Sternmasse / Abs. Helligkeit');
  GotoXY(23,33); Write('10) - Sternmasse / Planetenmasse');
  GotoXY(23,34); Write('11) - Sternmasse / Schnb. Heligkeit');
  GotoXY(23,35); Write('12) - Halbachse / MetallizitÑt');
  GotoXY(23,36); Write('13) - Planetenmasse / MetallizitÑt');
  GotoXY(23,37); Write('14) - ExzentrizitÑt / MetallizitÑt');
  TextBackground(White);
  TextColor(Black+Blink);
  GotoXY(51,24);
  Write('  OK  ');
  GotoXY(51,26);
  Write(' NEIN ');
  TextBackground(LightGray);
  TextColor(LightRed);
  GotoXY(22,24); Arrow;
END;

PROCEDURE HRD_Interface1;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,14); Write('h - HRD');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(26,14); Write('h - HRD');
  TextBackground(LightGreen);
  TextColor(Blink);
  MessageBox(10,10,70,37,LightGray,LightGray,White,DarkGray);
  TextBackground(White);
  TextColor(Black+Blink);
  SetButton(63,14,White,Black+Blink,'  OK  ',0);
  SetButton(63,16,White,Black+Blink,' NEIN ',0);
  SetButton(63,18,White,Black+Blink,'  ->  ',0);
  SetButton(63,20,White,Black+Blink,'  <-  ',0);
  SetButton(63,22,White,Black+Blink,' Alle ',0);
  GotoXY(12,12); Write('DatensÑtze');
  TextBackground(Black);
  TextColor(White);
  FOR i := 1 TO 22 DO BEGIN
    GotoXY(12,13+i);
    Write('                  ');
    GotoXY(33,13+i);
    Blank29;
  END;
  FOR i := 1 TO 22 DO BEGIN
    GotoXY(17,13+i);
    Write('≥');
    GotoXY(30,13+i);
    Write('∞');
  END;
  GotoXY(30,14); Write('');
  GotoXY(30,35); Write('');
END;

PROCEDURE HRD_Interface2;
BEGIN
  SetButton(63,18,White,Black+Blink,'  ->  ',50);
  SetButton(63,18,White,LightRed+Blink,'  ->  ',50);
  SetButton(63,18,White,Black+Blink,'  ->  ',0);
  TextBackground(Black);
  TextColor(White);
END;

PROCEDURE HRD_Interface3;
BEGIN
  SetButton(63,20,White,Black+Blink,'  <-  ',50);
  SetButton(63,20,White,LightRed+Blink,'  <-  ',50);
  SetButton(63,20,White,Black+Blink,'  <-  ',0);
  TextBackground(Black);
  TextColor(White);
END;

PROCEDURE HRD_Interface4;
BEGIN
  IF FileExists('hrd.exe') THEN BEGIN
    IF FileExists('hrd.dat') THEN BEGIN
      Assign(f2,'hrd.dat');
      Erase(f2);
    END;
    Assign(f2,'hrd.exe');
    Rename(f2,'hrd.dat');
  END;
END;

PROCEDURE Star3D_Interface;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,15); Write('p - Star3D');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(26,15); Write('p - Star3D');
  TextBackground(LightGreen);
  TextColor(Blink);
  IF FileExists('star3d.exe') THEN BEGIN
    IF FileExists('star3d.dat') THEN BEGIN
      Assign(f2,'star3d.dat');
      Erase(f2);
    END;
    Assign(f2,'star3d.exe');
    Rename(f2,'star3d.dat');
  END;
  MessageBox(20,07,60,31,LightGray,LightGray,White,DarkGray);
  SetButton(38,29,White,Black+Blink,'  OK  ',0);
  TextBackground(LightGray);
  TextColor(Black);
  GotoXY(23,10); Write('Zoom-Faktor:');
  GotoXY(34,12); Write('(default = 50)');
  GotoXY(23,14); Write('Mittelpunktverschiebung x-Achse:');
  GotoXY(34,16); Write('(default = 0)');
  GotoXY(23,18); Write('Mittelpunktverschiebung y-Achse:');
  GotoXY(34,20); Write('(default = 0)');
  GotoXY(23,22); Write('Spektraltyp-BeschrÑnkung:');
  GotoXY(30,23); Write('Von: (default = O)  [OBAFGKM]');
  GotoXY(30,24); Write('Bis: (default = M)  [OBAFGKM]');
  TextBackground(Black);
  TextColor(White);
  GotoXY(23,12); Write('         ');
  GotoXY(23,16); Write('         ');
  GotoXY(23,20); Write('         ');
  GotoXY(23,23); Write('    ');
  GotoXY(23,24); Write('    ');
  ShowCursor;
END;

PROCEDURE Goto_Interface;
BEGIN
  TextBackground(LightBlue);
  TextColor(Red+Blink);
  GotoXY(40,20);
  Write('G');
  Wait(50);
  TextColor(Yellow+Blink);
  GotoXY(40,20);
  Write('G');
  GotoXY(49,20);
  TextBackground(Black);
  TextColor(White);
  Write('   ');
  GotoXY(49,20);
  ShowCursor;
END;

PROCEDURE Msg_NoModule;
BEGIN
  MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
  TextColor(Black+Blink);
  GotoXY(23,23);
  Write('Dieses Modul wurde nicht gefunden!');
  SetButton(37,25,White,Black+Blink,'  OK  ',0);
  REPEAT
    Input := ReadKey;
  UNTIL Input <> NULL;
  SetButton(37,25,White,LightRed+Blink,'  OK  ',50);
  SetButton(37,25,White,Black+Blink,'  OK  ',50);
END;

PROCEDURE Msg_NoDataset;
BEGIN
  MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
  TextColor(Black+Blink);
  GotoXY(23,23);
  Write('Der Datensatz wurde nicht gefunden!');
  SetButton(37,25,White,Black+Blink,'  OK  ',0);
  REPEAT
    Input := ReadKey;
  UNTIL Input <> NULL;
  SetButton(37,25,White,LightRed+Blink,'  OK  ',50);
  SetButton(37,25,White,Black+Blink,'  OK  ',50);
END;

BEGIN
END.
