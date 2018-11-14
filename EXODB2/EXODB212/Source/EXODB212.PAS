PROGRAM EXO_DB2_v12;

USES Crt,Dos,Graph,Cursor,RT_Watch;

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
  a,p,e           : Real;
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
  SearchReal,
  Deklination,
  Distance,
  Eccentricity,
  Eccentricity2,
  Magnitude,
  Metalicity,
  Metalicity2,
  Period,
  Period2,
  PlanetMass,
  PlanetMass2,
  Rectaszension,
  SemiMajorAxis,
  SemiMajorAxis2,
  StarMass        : Real;

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

PROCEDURE Blank29;
BEGIN Write('                             '); END;

PROCEDURE SetButton(x1,y1,BackgrCol,ForegrCol : Byte; Str : STRING);
BEGIN
  TextBackground(BackgrCol);
  TextColor(ForegrCol);
  GotoXY(x1,y1);
  Write(Str);
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

PROCEDURE ScanExo(Date2,Date : STRING);
VAR j,j2,j3,j4 : Real;
BEGIN
  IF Date2 <> '' THEN Val(Date2,j3,Con);
  IF Date <> '' THEN Val(Date,j,Con);
  IF Date = '' THEN BEGIN
    ExoFileMax := 0;
    FindFirst('EXO\*.EXO',AnyFile,SearchFile);
    WHILE DosError = 0 DO BEGIN
      Inc(ExoFileMax);
      ExoFile[ExoFileMax] := SearchFile.Name;
      FindNext(SearchFile);
    END;
  END ELSE BEGIN
    FOR i := 1 TO 500 DO ExoFile[i] := ''; {500 !!! 1000}
    ExoFileMax := 1;
    FindFirst('EXO\*.EXO',AnyFile,SearchFile);
    WHILE DosError = 0 DO BEGIN
        ExoFile[ExoFileMax] := SearchFile.Name;
      IF FileExists('EXO\'+ExoFile[ExoFileMax]) THEN BEGIN
        Assign(f,'EXO\'+ExoFile[ExoFileMax]);
        Reset(f);
        ReadLn(f,Centralstar);
        ReadLn(f,SpectralType);
        ReadLn(f,Magnitude);
        ReadLn(f,StarMass);
        {IF Korrektur THEN BEGIN
          ReadLn(f,Metalicity,Metalicity2);
        END ELSE}
        ReadLn(f,Metalicity);
        ReadLn(f,Distance);
        ReadLn(f,Rectaszension);
        ReadLn(f,Deklination);
        ReadLn(f,Constellation);
        ReadLn(f,PlanetName);
        {IF Korrektur THEN BEGIN
          ReadLn(f,PlanetMass,PlanetMass2);
        END ELSE}
        ReadLn(f,PlanetMass);
        {IF Korrektur THEN BEGIN
          ReadLn(f,SemiMajorAxis,SemiMajorAxis2);
        END ELSE}
        ReadLn(f,SemiMajorAxis);
        {IF Korrektur THEN BEGIN
          ReadLn(f,Period,Period2);
        END ELSE}
        ReadLn(f,Period);
        {IF Korrektur THEN BEGIN
          ReadLn(f,Eccentricity,Eccentricity2);
        END ELSE}
        ReadLn(f,Eccentricity);
        ReadLn(f,Method);
        ReadLn(f,DiscoveryDate);
        ReadLn(f,Discoverer);
        ReadLn(f,Remarks);
        Close(f);
      END;
      Val(DiscoveryDate,j2,Con);
      IF (j2 < j) AND (j2 > j3) THEN BEGIN
        Inc(ExoFileMax);
        ExoFile[ExoFileMax] := SearchFile.Name;
      END;
      FindNext(SearchFile);
    END;
    Dec(ExoFileMax,1);
  END;
END;

PROCEDURE ScanExoUpdate(n : Byte);
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
  IF FileExists('EXO\'+ExoFile[n]) THEN BEGIN
    Assign(f,'EXO\'+ExoFile[n]);
    Reset(f);
    ReadLn(f,Centralstar);
    ReadLn(f,SpectralType);
    ReadLn(f,Magnitude);
    ReadLn(f,StarMass);
    {IF Korrektur THEN BEGIN
      ReadLn(f,Metalicity,Metalicity2);
    END ELSE}
    ReadLn(f,Metalicity);
    ReadLn(f,Distance);
    ReadLn(f,Rectaszension);
    ReadLn(f,Deklination);
    ReadLn(f,Constellation);
    ReadLn(f,PlanetName);
    {IF Korrektur THEN BEGIN
      ReadLn(f,PlanetMass,PlanetMass2);
    END ELSE}
    ReadLn(f,PlanetMass);
    {IF Korrektur THEN BEGIN
      ReadLn(f,SemiMajorAxis,SemiMajorAxis2);
    END ELSE}
    ReadLn(f,SemiMajorAxis);
    {IF Korrektur THEN BEGIN
      ReadLn(f,Period,Period2);
    END ELSE}
    ReadLn(f,Period);
    {IF Korrektur THEN BEGIN
      ReadLn(f,Eccentricity,Eccentricity2);
    END ELSE}
    ReadLn(f,Eccentricity);
    ReadLn(f,Method);
    ReadLn(f,DiscoveryDate);
    ReadLn(f,Discoverer);
    ReadLn(f,Remarks);
    Close(f);
  END;
  TextColor(LightGreen);
  GotoXY(05,2+24+04); Write(Centralstar);
  GotoXY(05,2+24+06); Write(SpectralType);
  GotoXY(05,2+24+08); Write(Magnitude:0:3);
  GotoXY(05,2+24+10); Write(StarMass:0:3);
  GotoXY(05,2+24+12); Write(Metalicity:0:3);
  GotoXY(05,2+24+14); Write(Distance:0:3);
  GotoXY(05,2+24+16); Write(Rectaszension:0:3);
  GotoXY(05,2+24+18); Write(Deklination:0:3);
  GotoXY(05,2+24+20); Write(Constellation);
  GotoXY(42,2+24+04); Write(PlanetName);
  GotoXY(42,2+24+06); Write(PlanetMass:0:3);
  GotoXY(42,2+24+08); Write(SemiMajorAxis:0:3);
  GotoXY(42,2+24+10); Write(Period:0:3);
  GotoXY(42,2+24+12); Write(Eccentricity:0:3);
  GotoXY(42,2+24+14); Write(Method);
  GotoXY(42,2+24+16); Write('Jahr '+DiscoveryDate[1]+DiscoveryDate[2]+DiscoveryDate[3]+DiscoveryDate[4]+' Monat '+
    DiscoveryDate[5]+DiscoveryDate[6]+' Tag '+DiscoveryDate[7]+DiscoveryDate[8]);
  GotoXY(42,2+24+18); Write(Discoverer);
  GotoXY(42,2+24+20); Write(Remarks);
  TextBackground(LightBlue);
  TextColor(White+Blink);
  GotoXY(54,20);
  Write('          ');
  GotoXY(54,20);
  Write(n:3,' / ',ExoFileMax);
  GotoXY(65,20);
  TextBackground(Black);
  TextColor(White);
  WriteLn('            ');
  GotoXY(65,20);
  WriteLn(ExoFile[n]);
END;

PROCEDURE ScanExoInfo(n : Byte);
BEGIN
  IF FileExists('EXO\'+ExoFile[n]) THEN BEGIN
    Assign(f,'EXO\'+ExoFile[n]);
    Reset(f);
    ReadLn(f,Centralstar);
    ReadLn(f,SpectralType);
    ReadLn(f,Magnitude);
    ReadLn(f,StarMass);
{    IF Korrektur THEN BEGIN
      ReadLn(f,Metalicity,Metalicity2);
    END ELSE}
    ReadLn(f,Metalicity);
    ReadLn(f,Distance);
    ReadLn(f,Rectaszension);
    ReadLn(f,Deklination);
    ReadLn(f,Constellation);
    ReadLn(f,PlanetName);
    {IF Korrektur THEN BEGIN
      ReadLn(f,PlanetMass,PlanetMass2);
    END ELSE}
    ReadLn(f,PlanetMass);
    {IF Korrektur THEN BEGIN
      ReadLn(f,SemiMajorAxis,SemiMajorAxis2);
    END ELSE}
    ReadLn(f,SemiMajorAxis);
    {IF Korrektur THEN BEGIN
      ReadLn(f,Period,Period2);
    END ELSE}
    ReadLn(f,Period);
    {IF Korrektur THEN BEGIN
      ReadLn(f,Eccentricity,Eccentricity2);
    END ELSE}
    ReadLn(f,Eccentricity);
    ReadLn(f,Method);
    ReadLn(f,DiscoveryDate);
    ReadLn(f,Discoverer);
    ReadLn(f,Remarks);
    Close(f);
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
      GotoXY(i,n);
      Write(' ');
    END;
  END;
  TextColor(White+Blink);
  GotoXY(1,1); Write('⁄');
  FOR i := 2 TO 79 DO BEGIN
    GotoXY(i,1); Write('ƒ');
  END;
  GotoXY(1,80);
  Write('ø');
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
  Write('EXOPLANETEN-DATENBANK (EXO-DB2)   Version: 1.2   (C) 1995-2005');
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
  GotoXY(50,07); Write('SONSTIGES');
  GotoXY(50,09); Write('i - Programm-Info');
  GotoXY(50,10); Write('c - Credits');
  GotoXY(50,11); Write('t - Danksagung');
  GotoXY(50,12); Write('e - Hilfe');
  GotoXY(50,13); Write('f - Suchen');
  GotoXY(50,14); Write('z - Zeitsprung');
  GotoXY(50,15); Write('x - Exit');
  TextColor(Yellow+Blink);
  GotoXY(65,14); Write(j3+m3+t3,' ->');
  GotoXY(65,15); Write(j4+m4+t4);
  TextColor(White+Blink);
  GotoXY(1,18);
  Write('⁄');
  FOR i := 2 TO 79 DO BEGIN
    GotoXY(i,18);
    Write('ƒ');
  END;
  GotoXY(1,80);
  Write('ø');
  FOR i := 1 TO 3 DO BEGIN
    GotoXY(1,18+i);
    Write('≥');
  END;
  TextColor(Black+Blink);
  GotoXY(1,4+18);
  Write('¿');
  FOR i := 2 TO 79 DO BEGIN
    GotoXY(i,4+18);
    Write('ƒ');
  END;
  GotoXY(80,4+18);
  Write('Ÿ');
  FOR i := 1 TO 3 DO BEGIN
    GotoXY(80,18+i);
    Write('≥');
  END;
  SetButton(04,20,White,Black+Blink,' ˛ ');
  SetButton(10,20,White,Black+Blink,' << ');
  SetButton(16,20,White,Black+Blink,' <- ');
  SetButton(22,20,White,Black+Blink,' -> ');
  SetButton(28,20,White,Black+Blink,' >> ');
  SetButton(34,20,White,Black+Blink,' ˛ ');
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
  GotoXY(1,24);
  Write('⁄');
  GotoXY(80,24);
  Write('ø');
  FOR i := 2 TO 79 DO BEGIN
    GotoXY(i,24);
    Write('ƒ');
  END;
  FOR i := 1 TO 25 DO BEGIN
    GotoXY(1,24+i);
    Write('≥');
  END;
  TextColor(White+Blink);
  FOR i := 2 TO 79 DO BEGIN
    GotoXY(i,25+24);
    Write('ƒ');
  END;
  FOR i := 1 TO 25 DO BEGIN
    GotoXY(80,24+i);
    Write('≥');
  END;
  GotoXY(80,25+24);
  Write('Ÿ');
  GotoXY(1,25+24);
  Write('¿');
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
  Write('Num. ExzentizitÑt');
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

PROCEDURE Info;
BEGIN
  IF FileExists('info.man') THEN BEGIN
    TextBackground(LightBlue);
    TextColor(LightRed+Blink);
    GotoXY(50,09); Writeln('i - Programm-Info');
    Delay(50);
    TextColor(Yellow+Blink);
    GotoXY(50,09); Writeln('i - Programm-Info');
    TextBackground(LightGray);
    TextColor(LightGray);
    MessageBox(17,09,63,36,LightGray,LightGray,White,DarkGray);
    TextBackground(White);
    TextColor(Black+Blink);
{    GotoXY(38,33);
    Write('  OK  ');}
    SetButton(38,33,White,Black+Blink,'  OK  ');
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
    SetButton(38,33,White,LightRed+Blink,'  OK  ');
    Wait(50);
    TextColor(Black+Blink);
    SetButton(38,33,White,Black+Blink,'  OK  ');
    Wait(50);
    MainApp;
    ScanExo(j3+m3+t3,j4+m4+t4);
    ScanExoUpdate(Index);
  END;
END;

PROCEDURE Credits;
BEGIN
  IF FileExists('credits.man') THEN BEGIN
    TextBackground(LightBlue);
    TextColor(LightRed+Blink);
    GotoXY(50,10); Writeln('c - Credits');
    Delay(50);
    TextColor(Yellow+Blink);
    GotoXY(50,10); Writeln('c - Credits');
    TextBackground(LightGray);
    TextColor(LightGray);
    MessageBox(17,09,63,30,LightGray,LightGray,White,DarkGray);
    TextColor(Black+Blink);
    SetButton(38,28,White,Black+Blink,'  OK  ');
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
    SetButton(38,28,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(38,28,White,Black+Blink,'  OK  ');
    Wait(50);
    MainApp;
    ScanExo(j3+m3+t3,j4+m4+t4);
    ScanExoUpdate(Index);
  END;
END;

PROCEDURE Thanks;
BEGIN
  IF FileExists('thanks.man') THEN BEGIN
    TextBackground(LightBlue);
    TextColor(LightRed+Blink);
    GotoXY(50,11); Writeln('t - Danksagung');
    Delay(50);
    TextColor(Yellow+Blink);
    GotoXY(50,11); Writeln('t - Danksagung');
    TextBackground(LightGray);
    TextColor(LightGray);
    MessageBox(17,9,63,36,LightGray,LightGray,White,DarkGray);
    TextColor(Black+Blink);
    SetButton(38,34,White,Black+Blink,'  OK  ');
    TextBackground(LightGray);
    Assign(f,'thanks.man');
    Reset(f);
    FOR i := 1 TO 22 DO BEGIN
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
    SetButton(38,34,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(38,34,White,Black+Blink,'  OK  ');
    Wait(50);
    MainApp;
    ScanExo(j3+m3+t3,j4+m4+t4);
    ScanExoUpdate(Index);
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
      SetButton(37,25,White,Black+Blink,'  OK  ');
      REPEAT
        Input := ReadKey;
      UNTIL Input <> NULL;
      SetButton(37,25,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(37,25,White,Black+Blink,'  OK  ');
      Wait(50);
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
    ScanExo(j3+m3+t3,j4+m4+t4);
    ScanExoUpdate(Index);
  END
END;

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
  SetButton(38,27,White,Black+Blink,'  OK  ');
  REPEAT
    Input := ReadKey;
  UNTIL Input <> NULL;
  SetButton(38,27,White,LightRed+Blink,'  OK  ');
  Wait(50);
  SetButton(38,27,White,Black+Blink,'  OK  ');
  Wait(50);
END;

PROCEDURE Search;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(50,13); Writeln('f - Suchen');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(50,13); Writeln('f - Suchen');
  TextBackground(LightGray);
  TextColor(LightGray);
  MessageBox(20,20,60,29,LightGray,LightGray,White,DarkGray);
  SetButton(38,27,White,Black+Blink,'  OK  ');
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
  SearchStr := ReadStr(27);
  HideCursor;
  Con := 1;
  Val(SearchStr,SearchReal,Con);
  Found := False;
  SetButton(38,27,White,LightRed+Blink,'  OK  ');
  Wait(50);
  SetButton(38,27,White,Black+Blink,'  OK  ');
  Wait(50);
  FindFirst('EXO\*.EXO',AnyFile,SearchFile);
  WHILE DosError = 0 DO BEGIN
    Assign(f,'EXO/'+SearchFile.Name);
    Reset(f);
    ReadLn(f,Centralstar);
    TextBackground(White);
    TextColor(Black+Blink);
    GotoXY(38,27);
    Write('  OK  ');
    IF UpString(CentralStar) = UpString(SearchStr) THEN BEGIN
      SearchBox(1,CentralStar,0);
    END;
    ReadLn(f,SpectralType);
    IF UpString(SpectralType) = UpString(SearchStr) THEN BEGIN
      SearchBox(2,SpectralType,0);
    END;
    ReadLn(f,Magnitude);
    IF Con = 0 THEN IF Magnitude = SearchReal THEN BEGIN
      SearchBox(3,'',Magnitude);
    END;
    ReadLn(f,StarMass);
    IF Con = 0 THEN IF StarMass = SearchReal THEN BEGIN
      SearchBox(4,'',StarMass);
    END;
    ReadLn(f,Metalicity);
    IF Con = 0 THEN IF Metalicity = SearchReal THEN BEGIN
      SearchBox(5,'',Metalicity);
    END;
    ReadLn(f,Distance);
    IF Con = 0 THEN IF Distance = SearchReal THEN BEGIN
      SearchBox(6,'',Distance);
    END;
    ReadLn(f,Rectaszension);
    IF Con = 0 THEN IF Rectaszension = SearchReal THEN BEGIN
      SearchBox(7,'',Rectaszension);
    END;
    ReadLn(f,Deklination);
    IF Con = 0 THEN IF Deklination = SearchReal THEN BEGIN
      SearchBox(8,'',Deklination);
    END;
    ReadLn(f,Constellation);
    IF UpString(Constellation) = UpString(SearchStr) THEN BEGIN
      SearchBox(9,Constellation,0);
    END;
    ReadLn(f,PlanetName);
    IF UpString(PlanetName) = UpString(SearchStr) THEN BEGIN
      SearchBox(10,PlanetName,0);
    END;
    ReadLn(f,PlanetMass);
    IF Con = 0 THEN IF PlanetMass = SearchReal THEN BEGIN
      SearchBox(11,'',PlanetMass);
    END;
    ReadLn(f,SemiMajorAxis);
    IF Con = 0 THEN IF SemiMajorAxis = SearchReal THEN BEGIN
      SearchBox(12,'',SemiMajorAxis);
    END;
    ReadLn(f,Period);
    IF Con = 0 THEN IF Period = SearchReal THEN BEGIN
      SearchBox(13,'',Period);
    END;
    ReadLn(f,Eccentricity);
    IF Con = 0 THEN IF Eccentricity = SearchReal THEN BEGIN
      SearchBox(14,'',Eccentricity);
    END;
    ReadLn(f,Method);
    IF UpString(Method) = UpString(SearchStr) THEN BEGIN
      SearchBox(15,Method,0);
    END;
    ReadLn(f,DiscoveryDate);
    IF UpString(DiscoveryDate) = UpString(SearchStr) THEN BEGIN
      SearchBox(16,DiscoveryDate,0);
    END;
    ReadLn(f,Discoverer);
    IF UpString(Discoverer) = UpString(SearchStr) THEN BEGIN
      SearchBox(17,Discoverer,0);
    END;
    ReadLn(f,Remarks);
    IF UpString(Remarks) = UpString(SearchStr) THEN BEGIN
      SearchBox(18,Remarks,0);
    END;
    Close(f);
    FindNext(SearchFile);
  END;
  IF Found = False THEN BEGIN
    MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
    TextColor(Black+Blink);
    GotoXY(23,23);
    Write('Es wurden keine EintrÑge gefunden.');
    SetButton(37,25,White,Black+Blink,'  OK  ');
    REPEAT
      Input := ReadKey;
    UNTIL Input <> NULL;
    SetButton(37,25,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(37,25,White,Black+Blink,'  OK  ');
    Wait(50);
  END;
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(Index);
END;

PROCEDURE TimeLine;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(50,15); Writeln('z - Zeitsprung');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(50,15); Writeln('z - Zeitsprung');
  TextBackground(LightGray);
  TextColor(LightGray);
  MessageBox(23,9,60,29,LightGray,LightGray,White,DarkGray);
  SetButton(38,27,White,Black+Blink,'  OK  ');
  TextBackground(LightGray);
  TextColor(White);
  GotoXY(26,11); Write('Zeitsprung:');
  TextColor(Black);
  GotoXY(26,13); Write('VON Jahr:');
  GotoXY(44,13); Write('BIS Jahr:');
  GotoXY(30,17); Write('Monat:');
  GotoXY(48,17); Write('Monat:');
  GotoXY(34,19); Write('(0-12)');
  GotoXY(52,19); Write('(0-12)');
  GotoXY(30,21); Write('Tag:');
  GotoXY(48,21); Write('Tag:');
  GotoXY(34,23); Write('(1-31)');
  GotoXY(52,23); Write('(1-31)');
  TextBackground(Black);
  TextColor(White);
  GotoXY(30,15); Write('     ');
  GotoXY(48,15); Write('     ');
  GotoXY(30,19); Write('  ');
  GotoXY(48,19); Write('  ');
  GotoXY(30,23); Write('  ');
  GotoXY(48,23); Write('  ');
  ShowCursor;
  GotoXY(30,15); j := ReadInt(4); Str(j,j3);
  GotoXY(30,19); m := ReadInt(2); Str(m,m3);
  GotoXY(30,23); t := ReadInt(2); Str(t,t3);
  IF m < 10 THEN m3 := '0'+m3;
  IF t < 10 THEN t3 := '0'+t3;
  GotoXY(48,15); j := ReadInt(4); Str(j,j4);
  GotoXY(48,19); m := ReadInt(2); Str(m,m4);
  GotoXY(48,23); t := ReadInt(2); Str(t,t4);
  IF m < 10 THEN m4 := '0'+m4;
  IF t < 10 THEN t4 := '0'+t4;
  HideCursor;
  SetButton(38,27,White,LightRed+Blink,'  OK  ');
  Wait(50);
  SetButton(38,27,White,Black+Blink,'  OK  ');
  Wait(50);
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(1);
END;

PROCEDURE Language;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(50,14); Writeln('l - Sprache');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(50,14); Writeln('z - Sprache');
  TextBackground(LightGray);
  TextColor(LightGray);
  MessageBox(30,9,50,29,LightGray,LightGray,White,DarkGray);
  SetButton(38,27,White,Black+Blink,'  OK  ');
  TextBackground(LightGray);
  TextColor(Black);
  GotoXY(32,11); Write('Sprache wÑhlen:');
  GotoXY(34,14); Write('german (DE)');
  GotoXY(34,15); Write('english (EN-BT)');
  TextColor(DarkGray);
  GotoXY(34,17); Write('french (FR)');
  GotoXY(34,18); Write('spanish (ES)');
  GotoXY(34,19); Write('italian (IT)');
  GotoXY(34,20); Write('(comming soon)');
  i := 0;
  REPEAT
    FOR n := 0 TO 1 DO BEGIN
      GotoXY(32,14+n); Write(' ');
    END;
    TextColor(LightRed);
    GotoXY(32,14+i); Write('');
    Input := ReadKey;
    IF Input = NULL THEN BEGIN
      Input2 := ReadKey;
      IF Input2 = ArUp THEN Dec(i);
      IF Input2 = ArDn THEN Inc(i);
      IF Input2 = PgUp THEN i := 0;
      IF Input2 = PgDn THEN i := 1;
      IF i < 0 THEN i := 1;
      IF i > 1 THEN i := 0;
      GotoXY(32,14+i); Write('');
    END;
  UNTIL ((i=0) OR (i=1)) AND (Input = ENTER);
  Sprache := i;
  Input := NULL;
  Input2 := NULL;
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(1);
END;

PROCEDURE Add;
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
  Delay(50);
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
  GotoXY(03,2+24+04); Centralstar := ReadStr(27);
  GotoXY(03,2+24+06); SpectralType := ReadStr(27);
  GotoXY(03,2+24+08); Magnitude := ReadReal(11);
  GotoXY(03,2+24+10); StarMass := ReadReal(11);
  GotoXY(03,2+24+12); Metalicity := ReadReal(11);
  {IF Korrektur THEN BEGIN
    Write(' +/- ');
    Metalicity2 := ReadReal(11);
  END;}
  GotoXY(03,2+24+14); Distance := ReadReal(11);
  GotoXY(03,2+24+16); Rectaszension := ReadHMS;
  GotoXY(03,2+24+18); Deklination := ReadDeg;
  GotoXY(03,2+24+20); Constellation := ReadStr(27);
  GotoXY(40,2+24+04); PlanetName := ReadStr(27);
  GotoXY(40,2+24+06); PlanetMass := ReadReal(11);
  {IF Korrektur THEN BEGIN
    Write(' +/- ');
    PlanetMass2 := ReadReal(11);
  END;}
  GotoXY(40,2+24+08); SemiMajorAxis := ReadReal(11);
  {IF Korrektur THEN BEGIN
    Write(' +/- ');
    SemiMajorAxis2 := ReadReal(11);
  END;}
  GotoXY(40,2+24+10); Period := ReadReal(11);
  {IF Korrektur THEN BEGIN
    Write(' +/- ');
    Period2 := ReadReal(11);
  END;}
  GotoXY(40,2+24+12); Eccentricity := ReadReal(11);
  {IF Korrektur THEN BEGIN
    Write(' +/- ');
    Eccentricity2 := ReadReal(11);
  END;}
  GotoXY(40,2+24+14); Method := ReadStr(27);
  GotoXY(40,2+24+16); DiscoveryDate := ReadDate;{DiscoveryDate := ReadStr(27);}
  GotoXY(40,2+24+18); Discoverer := ReadStr(27);
  GotoXY(40,2+24+20); Remarks := ReadStr(27);
  MessageBox(20,20,60,27,LightGray,LightGray,White,DarkGray);
  TextColor(Black);
  GotoXY(24,23);
  Write('Name des Datensatz zum Speichern:');
  GotoXY(24+8,25);
  Write('.EXO');
  TextBackground(Black);
  TextColor(White);
  GotoXY(24,25);
  Write('        ');
  SetButton(40,25,White,Black+Blink,'  OK  ');
  REPEAT
    TextBackground(Black);
    TextColor(White);
    GotoXY(24,25);
    Fil[1] := ReadStr(8);
  UNTIL Fil[1] <> '';
  HideCursor;
  SetButton(40,25,White,LightRed+Blink,'  OK  ');
  Wait(50);
  SetButton(40,25,White,Black+Blink,'  OK  ');
  Wait(50);
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  Assign(f,'EXO\'+Fil[1]+'.EXO');
  Rewrite(f);
  WriteLn(f,Centralstar);
  WriteLn(f,SpectralType);
  WriteLn(f,Magnitude);
  WriteLn(f,StarMass);
  {IF Korrektur THEN BEGIN
    WriteLn(f,Metalicity,Metalicity2);
  END ELSE} WriteLn(f,Metalicity);
  WriteLn(f,Distance);
  WriteLn(f,Rectaszension);
  WriteLn(f,Deklination);
  WriteLn(f,Constellation);
  WriteLn(f,PlanetName);
  {IF Korrektur THEN BEGIN
    WriteLn(f,PlanetMass,PlanetMass2);
  END ELSE} WriteLn(f,PlanetMass);
  {IF Korrektur THEN BEGIN
    WriteLn(f,SemiMajorAxis,SemiMajorAxis2);
  END ELSE} WriteLn(f,SemiMajorAxis);
  {IF Korrektur THEN BEGIN
    WriteLn(f,Period,Period2);
  END ELSE} WriteLn(f,Period);
  {IF Korrektur THEN BEGIN
    WriteLn(f,Eccentricity,Eccentricity2);
  END ELSE} WriteLn(f,Eccentricity);
  WriteLn(f,Method);
  WriteLn(f,DiscoveryDate);
  WriteLn(f,Discoverer);
  WriteLn(f,Remarks);
  Close(f);
  MessageBox(20,20,60,28,LightGreen,Blink,White+Blink,Green+Blink);
  TextColor(Black+Blink);
  GotoXY(26,23);
  Write('Der Datensatz ist gespeichert!');
  SetButton(37,25,White,Black+Blink,'  OK  ');
  REPEAT
    Input := ReadKey;
  UNTIL Input <> NULL;
  SetButton(37,25,White,LightRed+Blink,'  OK  ');
  Wait(50);
  SetButton(37,25,White,Black+Blink,'  OK  ');
  Wait(50);
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(ExoFileMax);
END;

PROCEDURE Load;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(4,10); Writeln('2 - laden');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(4,10); Writeln('2 - laden');
  TextBackground(LightGreen);
  TextColor(Blink);
  MessageBox(10,10,70,37,LightGray,LightGray,White,DarkGray);
  TextBackground(White);
  TextColor(Black+Blink);
  SetButton(63,14,White,Black+Blink,'  OK  ');
  SetButton(63,16,White,Black+Blink,' NEIN ');
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
  Numb := Index;
  GotoXY(30,14);
  Write('');
  GotoXY(30,35);
  Write('');
  ScanExo(j3+m3+t3,j4+m4+t4);
  GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
  Write('≤');
  FOR i := 0 TO 21 DO BEGIN
    IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
    GotoXY(12,14+i);
    Write('     ');
    GotoXY(12,14+i);
    IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
    GotoXY(18,14+i);
    Write('            ');
    GotoXY(18,14+i);
    Write(ExoFile[Numb+i]);
  END;
  ScanExoInfo(Numb);
  GotoXY(35,15); Write(Centralstar);
  GotoXY(35,16); Write(SpectralType,' / ',Magnitude:0:2,' mag');
  GotoXY(35,17); Write('REK ',Rectaszension:0:3,' DEC ',Deklination:0:3);
  GotoXY(35,19); Write(PlanetName);
  GotoXY(35,20); Write(PlanetMass:0:2,' Mjup / ',SemiMajorAxis:0:2,' AE');
  GotoXY(35,21); Write(Period:0:2,' Tage / ',Eccentricity:0:2,' ecc');
  GotoXY(35,21); Write(Period:0:2,' Tage / ',Eccentricity:0:2,' ecc');
  GotoXY(35,23); Write(Method);
  GotoXY(35,24); Write('Jahr '+DiscoveryDate[1]+DiscoveryDate[2]+DiscoveryDate[3]+DiscoveryDate[4]+' Monat '+
    DiscoveryDate[5]+DiscoveryDate[6]+' Tag '+DiscoveryDate[7]+DiscoveryDate[8]);
  GotoXY(35,25); Write(Discoverer);
  GotoXY(35,27); Write(Remarks);
  REPEAT
    Input := ReadKey;
    IF Input = NULL THEN BEGIN
      Input2 := ReadKey;
      IF Input2 IN [ARLF,ARUP] THEN Dec(Numb);
      IF Input2 IN [ARRT,ARDN] THEN Inc(Numb);
      IF Input2 = PGUP THEN Dec(Numb,10);
      IF Input2 = PGDN THEN Inc(Numb,10);
      IF Input2 = POS1 THEN Numb := 1;
      IF Input2 = END1 THEN Numb := ExoFileMax;
      IF Numb < 1 THEN Numb := ExoFileMax;
      IF Numb > ExoFileMax THEN Numb := 1;
      FOR i := 0 TO 21 DO BEGIN
        FOR n := 1 TO 20 DO BEGIN
          GotoXY(30,14+n);
          Write('∞');
        END;
        GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
        Write('≤');
        IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
        GotoXY(12,14+i);
        Write('     ');
        GotoXY(12,14+i);
        IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
        GotoXY(18,14+i);
        Write('            ');
        GotoXY(18,14+i);
        Write(ExoFile[Numb+i]);
        FOR n := 1 TO 22 DO BEGIN
          GotoXY(33,13+n);
          Blank29;
        END;
        ScanExoInfo(Numb);
        GotoXY(35,15); Write(Centralstar);
        GotoXY(35,16); Write(SpectralType,' / ',Magnitude:0:2,' mag');
        GotoXY(35,17); Write('REK ',Rectaszension:0:3,' DEC ',Deklination:0:3);
        GotoXY(35,19); Write(PlanetName);
        GotoXY(35,20); Write(PlanetMass:0:2,' Mjup / ',SemiMajorAxis:0:2,' AE');
        GotoXY(35,21); Write(Period:0:2,' Tage / ',Eccentricity:0:2,' ecc');
        GotoXY(35,21); Write(Period:0:2,' Tage / ',Eccentricity:0:2,' ecc');
        GotoXY(35,23); Write(Method);
        GotoXY(35,24); Write('Jahr '+DiscoveryDate[1]+DiscoveryDate[2]+DiscoveryDate[3]+DiscoveryDate[4]+' Monat '+
          DiscoveryDate[5]+DiscoveryDate[6]+' Tag '+DiscoveryDate[7]+DiscoveryDate[8]);
        GotoXY(35,25); Write(Discoverer);
        GotoXY(35,27); Write(Remarks);
      END;
    END;
  UNTIL Input IN [ENTER,ESC];
  IF Input = ENTER THEN BEGIN
    SetButton(63,14,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(63,14,White,Black+Blink,'  OK  ');
    Wait(50);
  END ELSE BEGIN
    SetButton(63,16,White,LightRed+Blink,' NEIN ');
    Wait(50);
    SetButton(63,16,White,Black+Blink,' NEIN ');
    Wait(50);
    Numb := Index;
  END;
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(Numb);
END;

PROCEDURE Change;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(4,11); Writeln('3 - Ñndern');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(4,11); Writeln('3 - Ñndern');
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  {GotoXY(1,14);
  Write('Mit Fehlerspanne? (j/n)');
  REPEAT
    Input := ReadKey;
  UNTIL Input IN ['j','J','y','Y','z','Z','n','N'];
  IF Input IN ['N','n'] THEN Korrektur := False ELSE Korrektur := True;}
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF FileExists('EXO\'+ExoFile[Index]) THEN BEGIN
    Assign(f,'EXO\'+ExoFile[Index]);
    Reset(f);
    ReadLn(f,Centralstar);
    ReadLn(f,SpectralType);
    ReadLn(f,Magnitude);
    ReadLn(f,StarMass);
    {IF Korrektur THEN BEGIN
      ReadLn(f,Metalicity,Metalicity2);
    END ELSE} ReadLn(f,Metalicity);
    ReadLn(f,Distance);
    ReadLn(f,Rectaszension);
    ReadLn(f,Deklination);
    ReadLn(f,Constellation);
    ReadLn(f,PlanetName);
    {IF Korrektur THEN BEGIN
      ReadLn(f,PlanetMass,PlanetMass2);
    END ELSE} ReadLn(f,PlanetMass);
    {IF Korrektur THEN BEGIN
      ReadLn(f,SemiMajorAxis,SemiMajorAxis2);
    END ELSE} ReadLn(f,SemiMajorAxis);
    {IF Korrektur THEN BEGIN
      ReadLn(f,Period,Period2);
    END ELSE} ReadLn(f,Period);
    {IF Korrektur THEN BEGIN
      ReadLn(f,Eccentricity,Eccentricity2);
    END ELSE} ReadLn(f,Eccentricity);
    ReadLn(f,Method);
    ReadLn(f,DiscoveryDate);
    ReadLn(f,Discoverer);
    ReadLn(f,Remarks);
    Close(f);
  END;
  i := 1;
  REPEAT
    TextBackground(LightBlue);
    TextColor(LightBlue+Blink);
    FOR n := 4 TO 20 DO BEGIN
      IF NOT(Odd(n)) THEN BEGIN
        GotoXY(02,2+24+n); Write('');
        GotoXY(39,2+24+n); Write('');
      END;
    END;
    TextColor(LightRed+Blink);
    CASE i OF
      01 : BEGIN GotoXY(02,2+24+04); Write(''); END;
      02 : BEGIN GotoXY(02,2+24+06); Write(''); END;
      03 : BEGIN GotoXY(02,2+24+08); Write(''); END;
      04 : BEGIN GotoXY(02,2+24+10); Write(''); END;
      05 : BEGIN GotoXY(02,2+24+12); Write(''); END;
      06 : BEGIN GotoXY(02,2+24+14); Write(''); END;
      07 : BEGIN GotoXY(02,2+24+16); Write(''); END;
      08 : BEGIN GotoXY(02,2+24+18); Write(''); END;
      09 : BEGIN GotoXY(02,2+24+20); Write(''); END;
      11 : BEGIN GotoXY(39,2+24+04); Write(''); END;
      12 : BEGIN GotoXY(39,2+24+06); Write(''); END;
      13 : BEGIN GotoXY(39,2+24+08); Write(''); END;
      14 : BEGIN GotoXY(39,2+24+10); Write(''); END;
      15 : BEGIN GotoXY(39,2+24+12); Write(''); END;
      16 : BEGIN GotoXY(39,2+24+14); Write(''); END;
      17 : BEGIN GotoXY(39,2+24+16); Write(''); END;
      18 : BEGIN GotoXY(39,2+24+18); Write(''); END;
      19 : BEGIN GotoXY(39,2+24+20); Write(''); END;
    END;
    Input := Readkey;
    Input := Upcase(Input);
    IF Input = ENTER THEN BEGIN
      TextBackground(Black);
      TextColor(White);
      ShowCursor;
      CASE i OF
        01 : BEGIN
               GotoXY(03,2+24+04);
               Blank29;
               GotoXY(03,2+24+04); Centralstar := ReadStr(27);
             END;
        02 : BEGIN
               GotoXY(03,2+24+06);
               Blank29;
               GotoXY(03,2+24+06); SpectralType := ReadStr(27);
             END;
        03 : BEGIN
               GotoXY(03,2+24+08);
               Blank29;
               GotoXY(03,2+24+08); Magnitude := ReadReal(11);
             END;
        04 : BEGIN
               GotoXY(03,2+24+10);
               Blank29;
               GotoXY(03,2+24+10); StarMass := ReadReal(11);
             END;
        05 : BEGIN
               GotoXY(03,2+24+12);
               Blank29;
               GotoXY(03,2+24+12); Metalicity := ReadReal(11);
               {IF Korrektur THEN BEGIN
                 Write(' +/- ');
                 Metalicity2 := ReadReal(11);
               END;}
             END;
        06 : BEGIN
               GotoXY(03,2+24+14);
               Blank29;
               GotoXY(03,2+24+14); Distance := ReadReal(11);
             END;
        07 : BEGIN
               GotoXY(03,2+24+16);
               Blank29;
               GotoXY(03,2+24+16); Rectaszension := ReadHMS;
             END;
        08 : BEGIN
               GotoXY(03,2+24+18);
               Blank29;
               GotoXY(03,2+24+18); Deklination := ReadDeg;
             END;
        09 : BEGIN
               GotoXY(03,2+24+20);
               Blank29;
               GotoXY(03,2+24+20); Constellation := ReadStr(27);
             END;
        11 : BEGIN
               GotoXY(40,2+24+04);
               Blank29;
               GotoXY(40,2+24+04); PlanetName := ReadStr(27);
             END;
        12 : BEGIN
               GotoXY(40,2+24+06);
               Blank29;
               GotoXY(40,2+24+06); PlanetMass := ReadReal(11);
               {IF Korrektur THEN BEGIN
                 Write(' +/- ');
                 PlanetMass2 := ReadReal(11);
               END;}
             END;
        13 : BEGIN
               GotoXY(40,2+24+08);
               Blank29;
               GotoXY(40,2+24+08); SemiMajorAxis := ReadReal(11);
               {IF Korrektur THEN BEGIN
                 Write(' +/- ');
                 SemiMajorAxis2 := ReadReal(11);
               END;}
             END;
        14 : BEGIN
               GotoXY(40,2+24+10);
               Blank29;
               GotoXY(40,2+24+10); Period := ReadReal(11);
               {IF Korrektur THEN BEGIN
                 Write(' +/- ');
                 Period2 := ReadReal(11);
               END;}
             END;
        15 : BEGIN
               GotoXY(40,2+24+12);
               Blank29;
               GotoXY(40,2+24+12); Eccentricity := ReadReal(11);
               {IF Korrektur THEN BEGIN
                 Write(' +/- ');
                 Eccentricity2 := ReadReal(11);
               END;}
             END;
        16 : BEGIN
               GotoXY(40,2+24+14);
               Blank29;
               GotoXY(40,2+24+14); Method := ReadStr(27);
             END;
        17 : BEGIN
               GotoXY(40,2+24+16);
               Blank29;
               GotoXY(40,2+24+16); DiscoveryDate := ReadDate;
             END;
        18 : BEGIN
               GotoXY(40,2+24+18);
               Blank29;
               GotoXY(40,2+24+18); Discoverer := ReadStr(27);
             END;
        19 : BEGIN
               GotoXY(40,2+24+20);
               Blank29;
               GotoXY(40,2+24+20); Remarks := ReadStr(27);
             END;
      END;
      HideCursor;
    END;
    IF NOT(Input = ESC) THEN CASE Input OF
      NULL : BEGIN
        Input2 := Readkey;
        Input2 := Upcase(Input2);
        CASE Input2 OF
          ARLF : BEGIN
                   Dec(i,10);
                   IF i < 1 THEN Inc(i,10);
                 END;
          ARRT : BEGIN
                   Inc(i,10);
                   IF i > 19 THEN Dec(i,10);
                 END;
          ARUP : BEGIN
                   Dec(i,1);
                   IF i < 1 THEN i := 1;
                   IF i = 10 THEN i := 9;
                 END;
          ARDN : BEGIN
                   Inc(i,1);
                   IF i > 19 THEN i := 19;
                   IF i = 10 THEN i := 11;
                 END;
        END;
      END;
    END;
  UNTIL Input = ESC;
  MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
  TextColor(Black+Blink);
  GotoXY(21,23);
  Write('Wollen Sie diesen Datensatz speichern?');
  TextBackground(White);
  TextColor(Black+Blink);
  SetButton(33,25,White,Black+Blink,'  JA  ');
  SetButton(43,25,White,Black+Blink,' NEIN ');
  i := 0;
  REPEAT
    CASE i OF
      0 : BEGIN
            SetButton(33,25,White,Green+Blink,'  JA  ');
            SetButton(43,25,White,Black+Blink,' NEIN ');
          END;
      1 : BEGIN
            SetButton(33,25,White,Black+Blink,'  JA  ');
            SetButton(43,25,White,Green+Blink,' NEIN ');
          END;
    END;
    Input := Readkey;
    Input := Upcase(Input);
    IF NOT(Input = ENTER) THEN CASE Input OF
      NULL : BEGIN
        Input2 := Readkey;
        Input2 := Upcase(Input2);
        CASE Input2 OF
          ARLF : i := 0;
          ARRT : i := 1;
        END;
      END;
    END;
  UNTIL Input = ENTER;
  CASE i OF
    0 : BEGIN
          SetButton(33,25,White,LightRed+Blink,'  JA  ');
          SetButton(43,25,White,Black+Blink,' NEIN ');
        END;
    1 : BEGIN
          SetButton(33,25,White,Black+Blink,'  JA  ');
          SetButton(43,25,White,LightRed+Blink,' NEIN ');
        END;
  END;
  Wait(50);
  SetButton(33,25,White,Black+Blink,'  JA  ');
  SetButton(43,25,White,Black+Blink,' NEIN ');
  Wait(50);
  IF i = 0 THEN BEGIN
    Assign(f,'EXO\'+ExoFile[Index]);
    Rewrite(f);
    WriteLn(f,Centralstar);
    WriteLn(f,SpectralType);
    WriteLn(f,Magnitude);
    WriteLn(f,StarMass);
    {IF Korrektur THEN BEGIN
     WriteLn(f,Metalicity,Metalicity2);
    END ELSE} WriteLn(f,Metalicity);
    WriteLn(f,Distance);
    WriteLn(f,Rectaszension);
    WriteLn(f,Deklination);
    WriteLn(f,Constellation);
    WriteLn(f,PlanetName);
    {IF Korrektur THEN BEGIN
    WriteLn(f,PlanetMass,PlanetMass2);
    END ELSE} WriteLn(f,PlanetMass);
    {IF Korrektur THEN BEGIN
    WriteLn(f,SemiMajorAxis,SemiMajorAxis2);
    END ELSE} WriteLn(f,SemiMajorAxis);
    {IF Korrektur THEN BEGIN
    WriteLn(f,Period,Period2);
    END ELSE} WriteLn(f,Period);
    {IF Korrektur THEN BEGIN
    WriteLn(f,Eccentricity,Eccentricity2);
    END ELSE} WriteLn(f,Eccentricity);
    WriteLn(f,Method);
    WriteLn(f,DiscoveryDate);
    WriteLn(f,Discoverer);
    WriteLn(f,Remarks);
    Close(f);
    MessageBox(20,20,60,28,LightGreen,Blink,White+Blink,Green+Blink);
    TextColor(Black+Blink);
    GotoXY(24,23);
    Write('Der Datensatz wurde gespeichert!');
    SetButton(37,25,White,Black+Blink,'  OK  ');
    REPEAT
      Input := ReadKey;
    UNTIL Input <> NULL;
    SetButton(37,25,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(37,25,White,Black+Blink,'  OK  ');
    Wait(50);
  END;
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(Index);
END;

PROCEDURE Rename2;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(4,12); Writeln('4 - umbenennen');
  Delay(50);
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
  SetButton(40,25,White,Black+Blink,'  OK  ');
  REPEAT
    TextBackground(Black);
    TextColor(White);
    GotoXY(24,25);
    Fil[1] := ReadStr(8);
  UNTIL Fil[1] <> '';
  HideCursor;
  SetButton(40,25,White,Lightred+Blink,'  OK  ');
  Wait(50);
  SetButton(40,25,White,Black+Blink,'  OK  ');
  Wait(50);
  IF RenameFile('EXO\'+ExoFile[Index],'EXO\'+Fil[1]+'.EXO') THEN BEGIN
    MessageBox(20,20,60,27,LightGreen,Blink,White+Blink,Green+Blink);
    GotoXY(28,23);
    TextColor(Black+Blink);
    Write('Datei wurde umbenannt!');
    SetButton(37,25,White,Black+Blink,'  OK  ');
    REPEAT
      Input := ReadKey;
    UNTIL Input <> NULL;
    SetButton(37,25,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(37,25,White,Black+Blink,'  OK  ');
    Wait(50);
  END;
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(Index);
END;

PROCEDURE Delete;
BEGIN
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(4,14); Writeln('7 - lîschen');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(4,14); Writeln('7 - lîschen');
  MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
  TextColor(Black+Blink);
  GotoXY(22,23);
  Write('Wollen Sie diesen Datensatz lîschen?');
  SetButton(33,25,White,Black+Blink,'  JA  ');
  SetButton(40,25,White,Black+Blink,' NEIN ');
  i := 0;
  REPEAT
    CASE i OF
      0 : BEGIN
            SetButton(33,25,White,Green+Blink,'  JA  ');
            SetButton(40,25,White,Black+Blink,' NEIN ');
          END;
      1 : BEGIN
            SetButton(33,25,White,Black+Blink,'  JA  ');
            SetButton(40,25,White,Green+Blink,' NEIN ');
          END;
    END;
    Input := Readkey;
    Input := Upcase(Input);
    IF NOT(Input = ENTER) THEN CASE Input OF
      NULL : BEGIN
        Input2 := Readkey;
        Input2 := Upcase(Input2);
        CASE Input2 OF
          ARLF : i := 0;
          ARRT : i := 1;
        END;
      END;
    END;
  UNTIL Input = ENTER;
  CASE i OF
    0 : BEGIN
          SetButton(33,25,White,LightRed+Blink,'  JA  ');
          SetButton(40,25,White,Black+Blink,' NEIN ');
        END;
    1 : BEGIN
          SetButton(33,25,White,Black+Blink,'  JA  ');
          SetButton(40,25,White,LightRed+Blink,' NEIN ');
        END;
  END;
  Wait(50);
  SetButton(33,25,White,Black+Blink,'  JA  ');
  SetButton(40,25,White,Black+Blink,' NEIN ');
  Wait(50);
  IF i = 0 THEN BEGIN
    IF FileExists('EXO\'+ExoFile[Index]) THEN BEGIN
      Assign(f,'EXO\'+ExoFile[Index]);
      Erase(f);
      MessageBox(20,20,60,28,LightGreen,Blink,White+Blink,Green+Blink);
      TextColor(Black+Blink);
      GotoXY(26,23);
      Write('Der Datensatz wurde gelîscht..');
      SetButton(37,25,White,Black+Blink,'  OK  ');
      REPEAT
        Input := ReadKey;
      UNTIL Input <> NULL;
      SetButton(37,25,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(37,25,White,Black+Blink,'  OK  ');
      Wait(50);
    END ELSE BEGIN
      MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
      TextColor(Black+Blink);
      GotoXY(23,23);
      Write('Der Datensatz wurde nicht gefunden!');
      SetButton(37,25,White,Black+Blink,'  OK  ');
      REPEAT
        Input := ReadKey;
      UNTIL Input <> NULL;
      SetButton(37,25,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(37,25,White,Black+Blink,'  OK  ');
      Wait(50);
    END;
  END;
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_Export;
BEGIN
  {$M 50000,0,0}
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(4,13); Writeln('5 - exportieren');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(4,13); Writeln('5 - exportieren');
  IF NOT(FileExists('export.exe')) AND NOT(FileExists('export.dat')) THEN BEGIN
    MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
    TextColor(Black+Blink);
    GotoXY(23,23);
    Write('Dieses Modul wurde nicht gefunden!');
    SetButton(37,25,White,Black+Blink,'  OK  ');
    REPEAT
      Input := ReadKey;
    UNTIL Input <> NULL;
    SetButton(37,25,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(37,25,White,Black+Blink,'  OK  ');
    Wait(50);
  END ELSE BEGIN
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
    SetButton(48,24,White,Black+Blink,'  OK  ');
    SetButton(48,26,White,Black+Blink,' NEIN ');
    TextBackground(LightGray);
    TextColor(LightRed);
    GotoXY(22,24); Write('');
    i := 1;
    REPEAT
      Input := ReadKey;
      IF Input = NULL THEN BEGIN
        Input2 := ReadKey;
        IF Input2 = ARDN THEN Inc(i);
        IF Input2 = ARUP THEN Dec(i);
        IF Input2 = ARLF THEN Dec(i,3);
        IF Input2 = ARRT THEN Inc(i,3);
        IF i < 1 THEN i := 5;
        IF i > 5 THEN i := 1;
        TextBackground(LightGray);
        TextColor(LightGray);
        GotoXY(22,24); Write('');
        GotoXY(22,25); Write('');
        GotoXY(22,26); Write('');
        GotoXY(31,24); Write('');
        GotoXY(31,25); Write('');
        TextColor(LightRed);
        CASE i OF
          1: BEGIN GotoXY(22,24); Write(''); END;
          2: BEGIN GotoXY(22,25); Write(''); END;
          3: BEGIN GotoXY(22,26); Write(''); END;
          4: BEGIN GotoXY(31,24); Write(''); END;
          5: BEGIN GotoXY(31,25); Write(''); END;
        END;
      END;
    UNTIL Input IN [ENTER,ESC];
    IF Input = ENTER THEN BEGIN
      SetButton(48,24,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(48,24,White,Black+Blink,'  OK  ');
      Wait(50);
      IF FileExists('export.exe') THEN BEGIN
        IF FileExists('export.dat') THEN BEGIN
          Assign(f2,'export.dat');
          Erase(f2);
        END;
         Assign(f2,'export.exe');
         Rename(f2,'export.dat');
      END;
      Assign(f2,'export.dat');
      Rename(f2,'export.exe');
      CASE i OF
        1: Numb2 := 'TXT';
        2: Numb2 := 'HTM';
        3: Numb2 := 'RTF';
        4: Numb2 := 'CSV';
        5: Numb2 := 'SLK';
      END;
      Fil[0] := '';
      FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
        Fil[0] := Fil[0]+ExoFile[Index][i];
      END;
      Exec('export.exe',' '+Numb2+' '+Fil[0]);
      Rename(f2,'export.dat');
      MessageBox(20,20,60,28,LightGreen,Blink,White+Blink,Green+Blink);
      TextColor(Black+Blink);
      GotoXY(22,23);
      Write('Der Datensatz wurde exportiert!');
      GotoXY(22,24);
      Write('Der Dateiname ist EXPORT\',Fil[0],'.',Numb2,'!');
      SetButton(38,26,White,Black+Blink,'  OK  ');
      REPEAT
        Input := ReadKey;
      UNTIL Input <> NULL;
      SetButton(38,26,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(38,26,White,Black+Blink,'  OK  ');
      Wait(50);
    END ELSE IF Input = ESC THEN BEGIN
      SetButton(48,26,White,LightRed+Blink,' NEIN ');
      Wait(50);
      SetButton(48,26,White,Black+Blink,' NEIN ');
      Wait(50);
    END;
  END;
  MainApp;
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_Orbit;
BEGIN
  b := 1;
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,09); Write('o - Orbit-Abbild');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(26,09); Write('o - Orbit-Abbild');
  TextBackground(LightGreen);
  TextColor(Blink);
  MessageBox(10,10,70,37,LightGray,LightGray,White,DarkGray);
  TextBackground(White);
  TextColor(Black+Blink);
  SetButton(63,14,White,Black+Blink,'  OK  ');
  SetButton(63,16,White,Black+Blink,' NEIN ');
  SetButton(63,18,White,Black+Blink,'  ->  ');
  SetButton(63,20,White,Black+Blink,'  <-  ');
  SetButton(63,22,White,Black+Blink,' Alle ');
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
  Numb := Index;
  GotoXY(30,14); Write('');
  GotoXY(30,35); Write('');
  ScanExo(j3+m3+t3,j4+m4+t4);
  GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
  Write('≤');
  FOR i := 0 TO 21 DO BEGIN
    IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
    GotoXY(12,14+i);
    Write('     ');
    GotoXY(12,14+i);
    IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
    GotoXY(18,14+i);
    Write('            ');
    GotoXY(18,14+i);
    Write(ExoFile[Numb+i]);
  END;
  GotoXY(33,14); Write(1:4,' ≥ ',ExoFile[Index]);
  TextBackground(White);
  TextColor(Black+Blink);
  GotoXY(33,12); Write('Zu laden: ',+b:2,'/13');
  Textbackground(Black);
  REPEAT
    Input := ReadKey;
    Input := UpCase(Input);
    IF Input = NULL THEN BEGIN
      Input2 := ReadKey;
      IF b < 12 THEN IF Input2 = ARRT THEN BEGIN
        Inc(b);
        Fil[b] := ExoFile[Numb];
        SetButton(63,18,White,Black+Blink,'  ->  ');
        Wait(50);
        SetButton(63,18,White,LightRed+Blink,'  ->  ');
        Wait(50);
        SetButton(63,18,White,Black+Blink,'  ->  ');
        TextBackground(Black);
        TextColor(White);
      END;
      IF b IN [2..12] THEN IF Input2 = ARLF THEN BEGIN
        Dec(b);
        Fil[b+1] := '';
        SetButton(63,20,White,Black+Blink,'  <-  ');
        Wait(50);
        SetButton(63,20,White,LightRed+Blink,'  <-  ');
        Wait(50);
        SetButton(63,20,White,Black+Blink,'  <-  ');
        TextBackground(Black);
        TextColor(White);
      END;
      IF Input2 = ARUP THEN Dec(Numb);
      IF Input2 = ARDN THEN Inc(Numb);
      IF Input2 = PGUP THEN Dec(Numb,10);
      IF Input2 = PGDN THEN Inc(Numb,10);
      IF Input2 = POS1 THEN Numb := 1;
      IF Input2 = END1 THEN Numb := ExoFileMax;
      IF Numb < 1 THEN Numb := ExoFileMax;
      IF Numb > ExoFileMax THEN Numb := 1;
      FOR i := 0 TO 21 DO BEGIN
        FOR n := 1 TO 20 DO BEGIN
          GotoXY(30,14+n);
          Write('∞');
        END;
        GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
        Write('≤');
        IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
        GotoXY(12,14+i);
        Write('     ');
        GotoXY(12,14+i);
        IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
        GotoXY(18,14+i);
        Write('            ');
        GotoXY(18,14+i);
        Write(ExoFile[Numb+i]);
        TextBackground(White);
        TextColor(Black+Blink);
        GotoXY(33,12); Write('Zu laden: ',+b:2,'/13');
        Textbackground(Black);
        TextColor(White);
        FOR n := 2 TO 14 DO BEGIN
          GotoXY(33,13+n);
          Blank29;
          IF n <= b THEN BEGIN
            GotoXY(33,13+n); Write(n:4,' ≥ ',Fil[n]);
          END;
        END;
      END;
    END;
  UNTIL Input IN [ENTER,ESC,'A'];
  IF Input = 'A' THEN BEGIN
    Numb := 0;
    SetButton(63,22,White,Black+Blink,' Alle ');
    Wait(50);
    SetButton(63,22,White,LightRed+Blink,' Alle ');
    Wait(50);
    SetButton(63,22,White,Black+Blink,' Alle ');
    TextBackground(Black);
    TextColor(White);
  END;
  IF Input IN [ENTER,'A'] THEN BEGIN
    SetButton(63,14,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(63,14,White,Black+Blink,'  OK  ');
    Wait(50);
    IF NOT(FileExists('starmap.exe')) AND NOT(FileExists('starmap.dat')) THEN BEGIN
      MessageBox(20,20,60,27,LightRed,Blink,White+Blink,Red+Blink);
      TextColor(Black+Blink);
      GotoXY(23,23);
      Write('Dieses Modul wurde nicht gefunden!');
      SetButton(37,25,White,Black+Blink,'  OK  ');
      REPEAT
        Input := ReadKey;
      UNTIL Input <> NULL;
      SetButton(37,25,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(37,25,White,Black+Blink,'  OK  ');
      Wait(50);
    END ELSE BEGIN
      IF FileExists('orbit.exe') THEN BEGIN
        IF FileExists('orbit.dat') THEN BEGIN
          Assign(f2,'orbit.dat');
          Erase(f2);
        END;
        Assign(f2,'orbit.exe');
        Rename(f2,'orbit.dat');
      END;
      IF Input = 'A' THEN Numb := 0 ELSE Numb := b;
      Fil[0] := '';
      FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
        Fil[0] := Fil[0]+ExoFile[Index][i];
      END;
      FOR n := 1 TO Numb DO BEGIN
        FOR i := 1 TO Length(Fil[n])-4 DO BEGIN
          TempStr := TempStr+Fil[n][i];
        END;
        Fil[n] := TempStr;
        TempStr := '';
        Fil[0] := Fil[0]+' '+Fil[n];
      END;
      MessageBox(20,10,60,29,LightGray,LightGray,White,DarkGray);
      SetButton(38,27,White,Black+Blink,'  OK  ');
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
      GotoXY(23,15); Zoom := ReadInt(8);
      GotoXY(23,19); mx := ReadInt(8);
      GotoXY(23,23); my := ReadInt(8);
      GotoXY(51,25);
      REPEAT
        HZ := ReadKey;
        HZ := UpCase(HZ);
      UNTIL HZ IN ['Y','J','Z','N'];
      Write(HZ);
      IF HZ <> 'N' THEN HZ := '1' ELSE HZ := '0';
      HideCursor;
      SetButton(38,27,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(38,27,White,Black+Blink,'  OK  ');
      Wait(50);
      Str(Zoom,Zoom2);
      Str(Numb,Numb2);
      Str(mx,mx2);
      Str(my,my2);
      Assign(f2,'orbit.dat');
      Rename(f2,'orbit.exe');
      IF Numb <> 0 THEN BEGIN
        Exec('orbit.exe ',' '+Numb2+' '+Fil[0]+' '+Zoom2+' '+mx2+' '+my2+' '+HZ);
      END ELSE BEGIN
        Exec('orbit.exe ',' '+'all'+' '+Zoom2+' '+mx2+' '+my2);
      END;
      Rename(f2,'orbit.dat');
    END;
  END ELSE BEGIN
    SetButton(63,16,White,LightRed+Blink,' NEIN ');
    Wait(50);
    SetButton(63,16,White,Black+Blink,' NEIN ');
    Wait(50);
    Numb := Index;
  END;
  TextMode(300);
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_Starmap;
BEGIN
  {$M 50000,0,0}
  b := 1;
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,11); Write('s - Sternkarte');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(26,11); Write('s - Sternkarte');
  TextBackground(LightGreen);
  TextColor(Blink);
  MessageBox(10,10,70,37,LightGray,LightGray,White,DarkGray);
  TextBackground(White);
  TextColor(Black+Blink);
  SetButton(63,14,White,Black+Blink,'  OK  ');
  SetButton(63,16,White,Black+Blink,' NEIN ');
  SetButton(63,18,White,Black+Blink,'  ->  ');
  SetButton(63,20,White,Black+Blink,'  <-  ');
  SetButton(63,22,White,Black+Blink,' Alle ');
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
  Numb := Index;
  GotoXY(30,14); Write('');
  GotoXY(30,35); Write('');
  ScanExo(j3+m3+t3,j4+m4+t4);
  GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
  Write('≤');
  FOR i := 0 TO 21 DO BEGIN
    IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
    GotoXY(12,14+i);
    Write('     ');
    GotoXY(12,14+i);
    IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
    GotoXY(18,14+i);
    Write('            ');
    GotoXY(18,14+i);
    Write(ExoFile[Numb+i]);
  END;
  GotoXY(33,14); Write(1:4,' ≥ ',ExoFile[Index]);
  TextBackground(White);
  TextColor(Black+Blink);
  GotoXY(33,12); Write('Zu laden: ',+b:2,'/13');
  Textbackground(Black);
  REPEAT
    Input := ReadKey;
    Input := UpCase(Input);
    IF Input = NULL THEN BEGIN
      Input2 := ReadKey;
      IF b < 12 THEN IF Input2 = ARRT THEN BEGIN
        Inc(b);
        Fil[b] := ExoFile[Numb];
        SetButton(63,18,White,Black+Blink,'  ->  ');
        Wait(50);
        SetButton(63,18,White,LightRed+Blink,'  ->  ');
        Wait(50);
        SetButton(63,18,White,Black+Blink,'  ->  ');
        TextBackground(Black);
        TextColor(White);
      END;
      IF b IN [2..12] THEN IF Input2 = ARLF THEN BEGIN
        Dec(b);
        Fil[b+1] := '';
        SetButton(63,20,White,Black+Blink,'  <-  ');
        Wait(50);
        SetButton(63,20,White,LightRed+Blink,'  <-  ');
        Wait(50);
        SetButton(63,20,White,Black+Blink,'  <-  ');
        TextBackground(Black);
        TextColor(White);
      END;
      IF Input2 = ARUP THEN Dec(Numb);
      IF Input2 = ARDN THEN Inc(Numb);
      IF Input2 = PGUP THEN Dec(Numb,10);
      IF Input2 = PGDN THEN Inc(Numb,10);
      IF Input2 = POS1 THEN Numb := 1;
      IF Input2 = END1 THEN Numb := ExoFileMax;
      IF Numb < 1 THEN Numb := ExoFileMax;
      IF Numb > ExoFileMax THEN Numb := 1;
      FOR i := 0 TO 21 DO BEGIN
        FOR n := 1 TO 20 DO BEGIN
          GotoXY(30,14+n);
          Write('∞');
        END;
        GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
        Write('≤');
        IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
        GotoXY(12,14+i);
        Write('     ');
        GotoXY(12,14+i);
        IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
        GotoXY(18,14+i);
        Write('            ');
        GotoXY(18,14+i);
        Write(ExoFile[Numb+i]);
        TextBackground(White);
        TextColor(Black+Blink);
        GotoXY(33,12); Write('Zu laden: ',+b:2,'/13');
        Textbackground(Black);
        TextColor(White);
        FOR n := 2 TO 14 DO BEGIN
          GotoXY(33,13+n);
          Blank29;
          IF n <= b THEN BEGIN
            GotoXY(33,13+n); Write(n:4,' ≥ ',Fil[n]);
          END;
        END;
      END;
    END;
  UNTIL Input IN [ENTER,ESC,'A'];
  IF Input = 'A' THEN BEGIN
    Numb := 0;
    SetButton(63,22,White,Black+Blink,' Alle ');
    Wait(50);
    SetButton(63,22,White,LightRed+Blink,' Alle ');
    Wait(50);
    SetButton(63,22,White,Black+Blink,' Alle ');
    TextBackground(Black);
    TextColor(White);
  END;
  IF Input IN [ENTER,'A'] THEN BEGIN
    SetButton(63,14,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(63,14,White,Black+Blink,'  OK  ');
    Wait(50);
    IF NOT(FileExists('starmap.exe')) AND NOT(FileExists('starmap.dat')) THEN BEGIN
      MessageBox(20,20,60,27,LightRed,Blink,White+Blink,Red+Blink);
      TextColor(Black+Blink);
      GotoXY(23,23);
      Write('Dieses Modul wurde nicht gefunden!');
      SetButton(37,25,White,Black+Blink,'  OK  ');
      REPEAT
        Input := ReadKey;
      UNTIL Input <> NULL;
      SetButton(37,25,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(37,25,White,Black+Blink,'  OK  ');
      Wait(50);
    END ELSE BEGIN
      IF FileExists('starmap.exe') THEN BEGIN
        IF FileExists('starmap.dat') THEN BEGIN
          Assign(f2,'starmap.dat');
          Erase(f2);
        END;
        Assign(f2,'starmap.exe');
        Rename(f2,'starmap.dat');
      END;
      IF Input = 'A' THEN Numb := 0 ELSE Numb := b;
      Fil[0] := '';
      FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
        Fil[0] := Fil[0]+ExoFile[Index][i];
      END;
      FOR n := 1 TO Numb DO BEGIN
        FOR i := 1 TO Length(Fil[n])-4 DO BEGIN
          TempStr := TempStr+Fil[n][i];
        END;
        Fil[n] := TempStr;
        TempStr := '';
        Fil[0] := Fil[0]+' '+Fil[n];
      END;
      MessageBox(20,10,60,29,LightGray,LightGray,White,DarkGray);
      SetButton(38,27,White,Black+Blink,'  OK  ');
      TextBackground(LightGray);
      TextColor(Black);
      GotoXY(22,13); Write('Vergrîsserung? [j/n]');
      GotoXY(22,15); Write('Gradnetz? [j/n]');
      GotoXY(22,17); Write('Ekliptik u. HimmelsÑquator? [j/n]');
      GotoXY(22,19); Write('Sternbilder-Konstellationen? [j/n]');
      GotoXY(22,21); Write('Begrenzung fÅr Sternbilder? [j/n]');
      GotoXY(22,23); Write('Bezeichnung fÅr Sternbilder? [j/n]');
      GotoXY(22,25); Write('Bezeichnung fÅr Sterne? [j/n]');
      Numb2 := '';
      Numb3 := 0;
      Numb4 := '';
      Numb5 := '';
      Numb6 := '';
      Numb7 := '';
      TextBackground(Black);
      TextColor(White);
      IF Numb = 1 THEN BEGIN
        GotoXY(43,13); Write(' ');
        GotoXY(43,13);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN Numb5 := '1';
        HideCursor;
        Write(Input);
      END;
      IF Numb5 <> '1' THEN BEGIN
        GotoXY(38,15); Write(' ');
        GotoXY(38,15);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN Inc(Numb3,16);
        HideCursor;
        Write(Input);
      END;
      IF Numb5 <> '1' THEN BEGIN
        GotoXY(56,17); Write(' ');
        GotoXY(56,17);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN Inc(Numb3,8);
        HideCursor;
        Write(Input);
      END;
      GotoXY(57,19); Write(' ');
      GotoXY(57,19);
      ShowCursor;
      REPEAT
        Input := Readkey;
        Input := UpCase(Input);
      UNTIL Input IN ['Y','Z','J','N'];
      IF Input <> 'N' THEN Inc(Numb3,4);
      Write(Input);
      HideCursor;
      IF (Numb = 1) THEN BEGIN
        GotoXY(56,21); Write(' ');
        GotoXY(56,21);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN Inc(Numb3,2);
        HideCursor;
        Write(Input);
      END;
      IF (Numb5 = '1') AND (Numb = 1) THEN BEGIN
        GotoXY(57,23); Write(' ');
        GotoXY(57,23);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN Numb6 := '1' ELSE Numb6 := '';
        HideCursor;
        Write(Input);
      END;
      IF (Numb5 = '1') AND (Numb = 1) THEN BEGIN
        GotoXY(52,25); Write(' ');
        GotoXY(52,25);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN Numb7 := '1' ELSE Numb7 := '';
        HideCursor;
        Write(Input);
      END;
      SetButton(38,27,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(38,27,White,Black+Blink,'  OK  ');
      Wait(50);
      Str(Numb,Numb2);
      Str(Numb3,Numb4);
      Assign(f2,'starmap.dat');
      Rename(f2,'starmap.exe');
      IF Numb <> 0 THEN BEGIN
        Exec('starmap.exe',' '+Numb2+' '+Fil[0]+' '+Numb4+' '+Numb5+' '+Numb6+' '+Numb7+' '+Numb8);
      END ELSE BEGIN
        Exec('starmap.exe',' '+'all'+' '+Numb4);
      END;
      Rename(f2,'starmap.dat');
    END;
  END ELSE BEGIN
    SetButton(63,16,White,LightRed+Blink,' NEIN ');
    Wait(50);
    SetButton(63,16,White,Black+Blink,' NEIN ');
    Wait(50);
    Numb := Index;
  END;
  TextMode(300);
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_MassCompare;
BEGIN
  {$M 50000,0,0}
  b := 1;
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,10); Write('m - Masse-Vergleich');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(26,10); Write('m - Masse-Vergleich');
  TextBackground(LightGreen);
  TextColor(Blink);
  MessageBox(10,10,70,37,LightGray,LightGray,White,DarkGray);
  TextBackground(White);
  TextColor(Black+Blink);
  SetButton(63,14,White,Black+Blink,'  OK  ');
  SetButton(63,16,White,Black+Blink,' NEIN ');
  SetButton(63,18,White,Black+Blink,'  ->  ');
  SetButton(63,20,White,Black+Blink,'  <-  ');
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
  Numb := Index;
  GotoXY(30,14); Write('');
  GotoXY(30,35); Write('');
  ScanExo(j3+m3+t3,j4+m4+t4);
  GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
  Write('≤');
  FOR i := 0 TO 21 DO BEGIN
    IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
    GotoXY(12,14+i);
    Write('     ');
    GotoXY(12,14+i);
    IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
    GotoXY(18,14+i);
    Write('            ');
    GotoXY(18,14+i);
    Write(ExoFile[Numb+i]);
  END;
  GotoXY(33,14); Write(1:4,' ≥ ',ExoFile[Index]);
  TextBackground(White);
  TextColor(Black+Blink);
  GotoXY(33,12); Write('Zu laden: ',+b:2,'/5');
  Textbackground(Black);
  REPEAT
    Input := ReadKey;
    Input := UpCase(Input);
    IF Input = NULL THEN BEGIN
      Input2 := ReadKey;
      IF b < 5 THEN IF Input2 = ARRT THEN BEGIN
        Inc(b);
        Fil[b] := ExoFile[Numb];
        SetButton(63,18,White,Black+Blink,'  ->  ');
        Wait(50);
        SetButton(63,18,White,LightRed+Blink,'  ->  ');
        Wait(50);
        SetButton(63,18,White,Black+Blink,'  ->  ');
        TextBackground(Black);
        TextColor(White);
      END;
      IF b IN [2..5] THEN IF Input2 = ARLF THEN BEGIN
        Dec(b);
        Fil[b+1] := '';
        SetButton(63,20,White,Black+Blink,'  <-  ');
        Wait(50);
        SetButton(63,20,White,LightRed+Blink,'  <-  ');
        Wait(50);
        SetButton(63,20,White,Black+Blink,'  <-  ');
        TextBackground(Black);
        TextColor(White);
      END;
      IF Input2 = ARUP THEN Dec(Numb);
      IF Input2 = ARDN THEN Inc(Numb);
      IF Input2 = PGUP THEN Dec(Numb,10);
      IF Input2 = PGDN THEN Inc(Numb,10);
      IF Input2 = POS1 THEN Numb := 1;
      IF Input2 = END1 THEN Numb := ExoFileMax;
      IF Numb < 1 THEN Numb := ExoFileMax;
      IF Numb > ExoFileMax THEN Numb := 1;
      FOR i := 0 TO 21 DO BEGIN
        FOR n := 1 TO 20 DO BEGIN
          GotoXY(30,14+n);
          Write('∞');
        END;
        GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
        Write('≤');
        IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
        GotoXY(12,14+i);
        Write('     ');
        GotoXY(12,14+i);
        IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
        GotoXY(18,14+i);
        Write('            ');
        GotoXY(18,14+i);
        Write(ExoFile[Numb+i]);
        TextBackground(White);
        TextColor(Black+Blink);
        GotoXY(33,12); Write('Zu laden: ',+b:2,'/5');
        Textbackground(Black);
        TextColor(White);
        FOR n := 2 TO 6 DO BEGIN
          GotoXY(33,13+n);
          Blank29;
          IF n <= b THEN BEGIN
            GotoXY(33,13+n); Write(n:4,' ≥ ',Fil[n]);
          END;
        END;
      END;
    END;
  UNTIL Input IN [ENTER,ESC];
  IF Input IN [ENTER] THEN BEGIN
    SetButton(63,14,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(63,14,White,Black+Blink,'  OK  ');
    Wait(50);
    IF NOT(FileExists('masscomp.exe')) AND NOT(FileExists('masscomp.dat')) THEN BEGIN
      MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
      TextColor(Black+Blink);
      GotoXY(23,23);
      Write('Dieses Modul wurde nicht gefunden!');
      SetButton(37,25,White,Black+Blink,'  OK  ');
      REPEAT
        Input := ReadKey;
      UNTIL Input <> NULL;
      SetButton(37,25,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(37,25,White,Black+Blink,'  OK  ');
      Wait(50);
    END ELSE BEGIN
      IF FileExists('masscomp.exe') THEN BEGIN
        IF FileExists('masscomp.dat') THEN BEGIN
          Assign(f2,'masscomp.dat');
          Erase(f2);
        END;
        Assign(f2,'masscomp.exe');
        Rename(f2,'masscomp.dat');
      END;
      IF Input = 'A' THEN Numb := 0 ELSE Numb := b;
      Fil[0] := '';
      FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
        Fil[0] := Fil[0]+ExoFile[Index][i];
      END;
      FOR n := 1 TO Numb DO BEGIN
        FOR i := 1 TO Length(Fil[n])-4 DO BEGIN
          TempStr := TempStr+Fil[n][i];
        END;
        Fil[n] := TempStr;
        TempStr := '';
        Fil[0] := Fil[0]+' '+Fil[n];
      END;
      Str(Numb,Numb2);
      Assign(f2,'masscomp.dat');
      Rename(f2,'masscomp.exe');
      IF Numb <> 0 THEN BEGIN
        Exec('masscomp.exe',' '+Numb2+' '+Fil[0]);
      {END ELSE BEGIN
        Exec('masscomp.exe',' '+'all');]}
      END;
      Rename(f2,'masscomp.dat');
    END;
  END ELSE BEGIN
    SetButton(63,16,White,LightRed+Blink,' NEIN ');
    Wait(50);
    SetButton(63,16,White,Black+Blink,' NEIN ');
    Wait(50);
    Numb := Index;
  END;
  TextMode(300);
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_Distribution;
BEGIN
  {$M 50000,0,0}
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,12); Write('d - Distribution');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(26,12); Write('d - Distribution');
  IF NOT(FileExists('distri.exe')) AND NOT(FileExists('distri.dat')) THEN BEGIN
    MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
    TextColor(Black+Blink);
    GotoXY(23,23);
    Write('Dieses Modul wurde nicht gefunden!');
    SetButton(37,25,White,Black+Blink,'  OK  ');
    REPEAT
      Input := ReadKey;
    UNTIL Input <> NULL;
    SetButton(37,25,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(37,25,White,Black+Blink,'  OK  ');
    Wait(50);
  END ELSE BEGIN
    IF FileExists('distri.exe') THEN BEGIN
      IF FileExists('distri.dat') THEN BEGIN
        Assign(f2,'distri.dat');
        Erase(f2);
      END;
      Assign(f2,'distri.exe');
      Rename(f2,'distri.dat');
    END;
    MessageBox(20,20,60,34,LightGray,LightGray,White,DarkGray);
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
    TextColor(Black+Blink);
    SetButton(53,24,White,Black+Blink,'  OK  ');
    SetButton(53,26,White,Black+Blink,' NEIN ');
    TextBackground(LightGray);
    TextColor(LightRed);
    GotoXY(22,24); Write('');
    i := 1;
    REPEAT
      Input := ReadKey;
      IF Input = NULL THEN BEGIN
        Input2 := ReadKey;
        IF Input2 = ARDN THEN Inc(i);
        IF Input2 = ARUP THEN Dec(i);
        IF i < 1 THEN i := 9;
        IF i > 9 THEN i := 1;
        TextBackground(LightGray);
        TextColor(LightGray);
        FOR n := 1 TO 9+1 DO BEGIN
          GotoXY(22,23+n); Write('');
        END;
        TextColor(LightRed);
        IF i < 5 THEN BEGIN
          GotoXY(22,23+i); Write('');
        END ELSE BEGIN
          GotoXY(22,24+i); Write('');
        END;
      END;
    UNTIL Input IN [ENTER,ESC];
    IF Input = ENTER THEN BEGIN
      SetButton(53,24,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(53,24,White,Black+Blink,'  OK  ');
      Wait(50);
      CASE i OF
        1 : Input2 := '1';
        2 : Input2 := '2';
        3 : Input2 := '3';
        4 : BEGIN
              Input2 := '4';
              TextBackground(Black);
              TextColor(White);
              GotoXY(52,28);
              ShowCursor;
              REPEAT
                Input := ReadKey;
                Input := UpCase(Input);
              UNTIL Input IN ['J','Y','Z','N'];
              IF Input <> 'N' THEN Input2 := '0';
              Write(Input);
              HideCursor;
              SetButton(53,24,White,LightRed+Blink,'  OK  ');
              Wait(50);
              SetButton(53,24,White,Black+Blink,'  OK  ');
              Wait(50);
            END;
        5 : Input2 := '5';
        6 : Input2 := '6';
        7 : Input2 := '7';
        8 : Input2 := '8';
        9 : Input2 := '9';
      END;
      Assign(f2,'distri.dat');
      Rename(f2,'distri.exe');
      Exec('distri.exe',Input2);
      Rename(f2,'distri.dat');
    END ELSE BEGIN
      SetButton(53,26,White,LightRed+Blink,' NEIN ');
      Wait(50);
      SetButton(53,26,White,Black+Blink,' NEIN ');
      Wait(50);
    END;
  END;
  TextMode(300);
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_Diagram;
BEGIN
  {$M 50000,0,0}
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,13); Write('a - Diagramme');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(26,13); Write('a - Diagramme');
  IF NOT(FileExists('diagram.exe')) AND NOT(FileExists('diagram.dat')) THEN BEGIN
    MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
    TextColor(Black+Blink);
    GotoXY(23,23);
    Write('Dieses Modul wurde nicht gefunden!');
    SetButton(37,25,White,Black+Blink,'  OK  ');
    REPEAT
      Input := ReadKey;
    UNTIL Input <> NULL;
    SetButton(37,25,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(37,25,White,Black+Blink,'  OK  ');
    Wait(50);
  END ELSE BEGIN
    IF FileExists('diagram.exe') THEN BEGIN
      IF FileExists('diagram.dat') THEN BEGIN
        Assign(f2,'diagram.dat');
        Erase(f2);
      END;
      Assign(f2,'diagram.exe');
      Rename(f2,'diagram.dat');
    END;
    Numb := 1;
    Fil[0] := '';
    FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
      Fil[0] := Fil[0]+ExoFile[Index][i];
    END;
    MessageBox(20,20,60,28,LightGray,LightGray,White,DarkGray);
    TextColor(Black);
    GotoXY(23,22);
    Write('Folgende Diagramme sind wÑhlbar:');
    TextColor(Black);
    GotoXY(24,24);
    Write('1) - Halbachse / Exzentri.');
    GotoXY(24,25);
    Write('2) - Halbachse / Masse');
    GotoXY(24,26);
    Write('3) - Exzentri. / Masse');
    TextBackground(White);
    TextColor(Black+Blink);
    GotoXY(51,24);
    Write('  OK  ');
    GotoXY(51,26);
    Write(' NEIN ');
    TextBackground(LightGray);
    TextColor(LightRed);
    GotoXY(22,24); Write('');
    i := 1;
    REPEAT
      Input := ReadKey;
      IF Input = NULL THEN BEGIN
        Input2 := ReadKey;
        IF Input2 = ARDN THEN Inc(i);
        IF Input2 = ARUP THEN Dec(i);
        IF i < 1 THEN i := 3;
        IF i > 3 THEN i := 1;
        TextBackground(LightGray);
        TextColor(LightGray);
        GotoXY(22,24); Write('');
        GotoXY(22,25); Write('');
        GotoXY(22,26); Write('');
        TextColor(LightRed);
        CASE i OF
          1: BEGIN GotoXY(22,24); Write(''); END;
          2: BEGIN GotoXY(22,25); Write(''); END;
          3: BEGIN GotoXY(22,26); Write(''); END;
        END;
      END;
    UNTIL Input IN [ENTER,ESC];
    IF Input = ENTER THEN BEGIN
      SetButton(51,24,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(51,24,White,Black+Blink,'  OK  ');
      Wait(50);
      CASE i OF
        1 : Input2 := '1';
        2 : Input2 := '2';
        3 : Input2 := '3';
      END;
      Assign(f2,'diagram.dat');
      Rename(f2,'diagram.exe');
      Exec('diagram.exe',' '+Input2);
      Rename(f2,'diagram.dat');
    END;
  END;
  TextMode(300);
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_HRD;
BEGIN
  {$M 50000,0,0}
  b := 1;
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(26,14); Write('h - HRD');
  Delay(50);
  TextColor(Yellow+Blink);
  GotoXY(26,14); Write('h - HRD');
  TextBackground(LightGreen);
  TextColor(Blink);
  MessageBox(10,10,70,37,LightGray,LightGray,White,DarkGray);
  TextBackground(White);
  TextColor(Black+Blink);
  SetButton(63,14,White,Black+Blink,'  OK  ');
  SetButton(63,16,White,Black+Blink,' NEIN ');
  SetButton(63,18,White,Black+Blink,'  ->  ');
  SetButton(63,20,White,Black+Blink,'  <-  ');
  SetButton(63,22,White,Black+Blink,' Alle ');
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
  Numb := Index;
  GotoXY(30,14); Write('');
  GotoXY(30,35); Write('');
  ScanExo(j3+m3+t3,j4+m4+t4);
  GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
  Write('≤');
  FOR i := 0 TO 21 DO BEGIN
    IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
    GotoXY(12,14+i);
    Write('     ');
    GotoXY(12,14+i);
    IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
    GotoXY(18,14+i);
    Write('            ');
    GotoXY(18,14+i);
    Write(ExoFile[Numb+i]);
  END;
  GotoXY(33,14); Write(1:4,' ≥ ',ExoFile[Index]);
  TextBackground(White);
  TextColor(Black+Blink);
  GotoXY(33,12); Write('Zu laden: ',+b:2,'/13');
  Textbackground(Black);
  REPEAT
    Input := ReadKey;
    Input := UpCase(Input);
    IF Input = NULL THEN BEGIN
      Input2 := ReadKey;
      IF b < 12 THEN IF Input2 = ARRT THEN BEGIN
        Inc(b);
        Fil[b] := ExoFile[Numb];
        SetButton(63,18,White,Black+Blink,'  ->  ');
        Wait(50);
        SetButton(63,18,White,LightRed+Blink,'  ->  ');
        Wait(50);
        SetButton(63,18,White,Black+Blink,'  ->  ');
        TextBackground(Black);
        TextColor(White);
      END;
      IF b IN [2..12] THEN IF Input2 = ARLF THEN BEGIN
        Dec(b);
        Fil[b+1] := '';
        SetButton(63,20,White,Black+Blink,'  <-  ');
        Wait(50);
        SetButton(63,20,White,LightRed+Blink,'  <-  ');
        Wait(50);
        SetButton(63,20,White,Black+Blink,'  <-  ');
        TextBackground(Black);
        TextColor(White);
      END;
      IF Input2 = ARUP THEN Dec(Numb);
      IF Input2 = ARDN THEN Inc(Numb);
      IF Input2 = PGUP THEN Dec(Numb,10);
      IF Input2 = PGDN THEN Inc(Numb,10);
      IF Input2 = POS1 THEN Numb := 1;
      IF Input2 = END1 THEN Numb := ExoFileMax;
      IF Numb < 1 THEN Numb := ExoFileMax;
      IF Numb > ExoFileMax THEN Numb := 1;
      FOR i := 0 TO 21 DO BEGIN
        FOR n := 1 TO 20 DO BEGIN
          GotoXY(30,14+n);
          Write('∞');
        END;
        GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
        Write('≤');
        IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
        GotoXY(12,14+i);
        Write('     ');
        GotoXY(12,14+i);
        IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
        GotoXY(18,14+i);
        Write('            ');
        GotoXY(18,14+i);
        Write(ExoFile[Numb+i]);
        TextBackground(White);
        TextColor(Black+Blink);
        GotoXY(33,12); Write('Zu laden: ',+b:2,'/13');
        Textbackground(Black);
        TextColor(White);
        FOR n := 2 TO 14 DO BEGIN
          GotoXY(33,13+n);
          Blank29;
          IF n <= b THEN BEGIN
            GotoXY(33,13+n); Write(n:4,' ≥ ',Fil[n]);
          END;
        END;
      END;
    END;
  UNTIL Input IN [ENTER,ESC,'A'];
  IF Input = 'A' THEN BEGIN
    Numb := 0;
    SetButton(63,22,White,Black+Blink,' Alle ');
    Wait(50);
    SetButton(63,22,White,LightRed+Blink,' Alle ');
    Wait(50);
    SetButton(63,22,White,Black+Blink,' Alle ');
    TextBackground(Black);
    TextColor(White);
  END;
  IF Input IN [ENTER,'A'] THEN BEGIN
    SetButton(63,14,White,LightRed+Blink,'  OK  ');
    Wait(50);
    SetButton(63,14,White,Black+Blink,'  OK  ');
    Wait(50);
    IF NOT(FileExists('hrd.exe')) AND NOT(FileExists('hrd.dat')) THEN BEGIN
      MessageBox(20,20,60,27,LightRed,Blink,White+Blink,Red+Blink);
      TextColor(Black+Blink);
      GotoXY(23,23);
      Write('Dieses Modul wurde nicht gefunden!');
      SetButton(37,25,White,Black+Blink,'  OK  ');
      REPEAT
        Input := ReadKey;
      UNTIL Input <> NULL;
      SetButton(37,25,White,LightRed+Blink,'  OK  ');
      Wait(50);
      SetButton(37,25,White,Black+Blink,'  OK  ');
      Wait(50);
    END ELSE BEGIN
      IF FileExists('hrd.exe') THEN BEGIN
        IF FileExists('hrd.dat') THEN BEGIN
          Assign(f2,'hrd.dat');
          Erase(f2);
        END;
        Assign(f2,'hrd.exe');
        Rename(f2,'hrd.dat');
      END;
      IF Input = 'A' THEN Numb := 0 ELSE Numb := b;
      Fil[0] := '';
      FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
        Fil[0] := Fil[0]+ExoFile[Index][i];
      END;
      FOR n := 1 TO Numb DO BEGIN
        FOR i := 1 TO Length(Fil[n])-4 DO BEGIN
          TempStr := TempStr+Fil[n][i];
        END;
        Fil[n] := TempStr;
        TempStr := '';
        Fil[0] := Fil[0]+' '+Fil[n];
      END;
      Str(Numb,Numb2);
      Assign(f2,'hrd.dat');
      Rename(f2,'hrd.exe');
      IF Numb <> 0 THEN BEGIN
        Exec('hrd.exe',' '+Numb2+' '+Fil[0]);
      END ELSE BEGIN
        Exec('hrd.exe',' '+'all');
      END;
      Rename(f2,'hrd.dat');
    END;
  END ELSE BEGIN
    SetButton(63,16,White,LightRed+Blink,' NEIN ');
    Wait(50);
    SetButton(63,16,White,Black+Blink,' NEIN ');
    Wait(50);
    Numb := Index;
  END;
  TextMode(300);
  MainApp;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(Index);
END;

BEGIN
  Index := 1;
  Sprache := DE;
  ClrScr;
  TextMode(300);
  MainApp;
  HideCursor;
  ScanExo(j3+m3+t3,j4+m4+t4);
  ScanExoUpdate(Index);
  REPEAT
    Input := Readkey;
    Input := Upcase(Input);
    CASE Input OF
      NULL : BEGIN
        Input2 := Readkey;
        CASE Input2 OF
          POS1 : BEGIN
            SetButton(5,20,White,LightRed+Blink,'˛');
            Wait(50);
            SetButton(5,20,White,Black+Blink,'˛');
            Index := 1;
            ScanExoUpdate(Index);
          END;
          PGUP : BEGIN
            SetButton(11,20,White,LightRed+Blink,'<<');
            Wait(50);
            SetButton(11,20,White,Black+Blink,'<<');
            Dec(Index,10);
            IF Index < 1 THEN Index := ExoFileMax-Index-10;
            ScanExoUpdate(Index);
          END;
          ARLF,ARUP : BEGIN
            SetButton(17,20,White,LightRed+Blink,'<-');
            Wait(50);
            SetButton(17,20,White,Black+Blink,'<-');
            Dec(Index);
            IF Index < 1 THEN Index := ExoFileMax-Index;
            ScanExoUpdate(Index);
          END;
          ARRT,ARDN : BEGIN
            SetButton(23,20,White,LightRed+Blink,'->');
            Wait(50);
            SetButton(23,20,White,Black+Blink,'->');
            Inc(Index);
            IF Index > ExoFileMax THEN Index := Index-ExoFileMax;
            ScanExoUpdate(Index);
          END;
          PGDN : BEGIN
            SetButton(29,20,White,LightRed+Blink,'>>');
            Wait(50);
            SetButton(29,20,White,Black+Blink,'>>');
            Inc(Index,10);
            IF Index > ExoFileMax THEN Index := Index-ExoFileMax;
            ScanExoUpdate(Index);
          END;
          END1 : BEGIN
            SetButton(35,20,White,LightRed+Blink,'˛');
            Wait(50);
            SetButton(35,20,White,Black+Blink,'˛');
            Index := ExoFileMax;
            ScanExoUpdate(Index);
          END;
          EINFG : Add;
          ENTF  : Delete;
        END;
      END;
      'G' : BEGIN
        REPEAT
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
          Index := ReadInt(3);
        UNTIL Index IN [1..ExoFileMax];
        IF Index < 1 THEN Index := 1;
        IF Index > ExoFileMax THEN Index := ExoFileMax;
        HideCursor;
        ScanExoUpdate(Index);
      END;
      '1' : Add;
      '2' : Load;
      '3' : Change;
      '4' : Rename2;
      '5' : Modul_Export;
      '6' : Delete;
      'O' : Modul_Orbit;
      'M' : Modul_MassCompare;
      'S' : Modul_Starmap;
      'H' : Modul_HRD;
      'D' : Modul_Distribution;
      'A' : Modul_Diagram;
      'I' : Info;
      'C' : Credits;
      'T' : Thanks;
      'E' : Help;
      'F' : Search;
      'Z' : Timeline;
{      'L' : Language;}
      'X',ESC : Exit2 := True;
    END;
  UNTIL Exit2;
  ShowCursor;
END.
