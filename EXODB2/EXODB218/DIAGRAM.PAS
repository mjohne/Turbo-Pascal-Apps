PROGRAM Modul_Diagram;

USES Crt,Dos,Graph,Basic,Image,RT_Watch,BGI2PRN;

CONST
  bmphead :array[1..118] of byte =
  { BM } (66,77,
          118,
          8,
          0,
          0,0,0,0,0,
          118,0,0,0,40,
          0,0,0,
  { br }  128,2,         { (2x256)+128 = 640 pixels }
          0,0,
  { ho }  224,1,         { (1x256)+224 = 480 pixels }
          0,0,1,0,4,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   { 0}   0,0,0,0,
   { 1}   170,0,0,0,
   { 2}   0,170,0,0,
   { 3}   170,170,0,0,
   { 4}   0,0,170,0,
   { 5}   170,0,170,0,
   { 6}   0,85,170,0,
   { 7}   170,170,170,0,
   { 8}   85,85,85,0,
   { 9}   255,0,0,0,
   {10}   0,255,0,0,
   {11}   255,255,0,0,
   {12}   0,0,255,0,
   {13}   255,0,255,0,
   {14}   0,255,255,0,
   {15}   255,255,255,0);

VAR
  Fil               : ARRAY[1..3] OF STRING;
  Input             : Char;
  Control,i,n,Numb,
  grDriver,grMode   : Integer;
  n2,Magnitude2     : Real;
  a,p,e,b,c,
  regs              : Registers;
  SearchFile        : SearchRec;
  f                 : Text;
  PlanetMass2,
  CentralStar,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Method,
  PlanetName,
  {Remarks1,
  Remarks2,}
  Strin             : ARRAY[1..3] OF STRING;
  SpectralType      : STRING;
  Deklination,
  Distance,
  Eccentricity,
  Magnitude,
  Metalicity,
  Period,
  PlanetMass,
  Rectaszension,
  SemiMajorAxis,
  StarMass          : ARRAY[1..3] OF Real;
  Dis_Eccentricity,
  Dis_PlanetMass,
  Dis_SemiMajorAxis : ARRAY[0..20] OF Byte;

BEGIN
  TextBackground(Black);
  TextColor(White);
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF ParamStr(1) = '' THEN BEGIN
    ClrScr;
    WriteLn(^j^j'Der Parameter als Anzahl des darzustellenden Diagrammes fehlt!');
    ReadKey;
    Halt;
  END ELSE BEGIN
    Val(ParamStr(1),Numb,Control);
    IF (Control <> 0) {OR (Numb=0)} THEN BEGIN
      ClrScr;
      WriteLn(^j^j'Der eingegebene Zahlenwert ',ParamStr(1),' ist ung�ltig.');
      WriteLn('Es sind alle Zahlen von 1 bis 4 erlebt.');
      ReadKey;
      Halt;
    END;
  END;
  grDriver := Detect;
  InitGraph(grDriver,grMode,'');
  SetFillStyle(SolidFill,White);
  Bar(20,20,520,420);
  SetLineStyle(1,0,1);
  SetTextStyle(2,0,4);
  SetColor(LightGray);
  CASE Numb OF
    1: BEGIN
         FOR i := 1 TO 8 DO BEGIN
           Line(Round((i-1)*70)+20,20,Round((i-1)*70)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round((i-1)*70)+20,430,Strin[1]+' AE');
           SetColor(LightGray);
         END;
         FOR i := 1 TO 10 DO BEGIN
           Line(20,Round((i*0.1)*420),520,Round((i*0.1)*420));
           SetColor(White);
           Str(1-(i*0.1):0:1,Strin[1]);
           OutTextXY(530,Round((i*0.1)*420)-6,Strin[1]);
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Gro�e Halbachse');
         SetTextStyle(2,1,5);
         OutTextXY(550,286,'Num. Exzentrizit�t');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(600,0,'Diagramm "Gro�e Halbachse / Num. Exzentrizit�t"');
       END;
    2: BEGIN
         FOR i := 1 TO 8 DO BEGIN
           Line(Round((i-1)*70)+20,20,Round((i-1)*70)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round((i-1)*70)+20,430,Strin[1]+' AE');
           SetColor(LightGray);
         END;
         FOR i := 1 TO 15 DO BEGIN
           Line(20,420-Round(i*22),520,420-Round(i*22));
           SetColor(White);
           Str(i,Strin[1]);
           OutTextXY(530,420-Round(i*22)-6,Strin[1]+' Mjup');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Gro�e Halbachse');
         SetTextStyle(2,1,5);
         OutTextXY(567,286,'Exoplaneten-Masse');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(600,0,'Diagramm "Gro�e Halbachse / Exoplaneten-Masse"');
       END;
    3: BEGIN
         FOR i := 1 TO 10 DO BEGIN
           Line(Round((i-1)*50)+20,20,Round((i-1)*50)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round((i-1)*50)+20,430,'0.'+Strin[1]);
           SetColor(LightGray);
         END;
         FOR i := 1 TO 15 DO BEGIN
           Line(20,420-Round(i*22),520,420-Round(i*22));
           SetColor(White);
           Str(i,Strin[1]);
           OutTextXY(530,420-Round(i*22)-6,Strin[1]+' Mjup');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Num. Exzentrizit�t');
         SetTextStyle(2,1,5);
         OutTextXY(567,286,'Exoplaneten-Masse');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(600,0,'Diagramm "Num. Exzentrizit�t / Exoplaneten-Masse"');
       END;
    4: BEGIN
         FOR i := 1 TO 8 DO BEGIN
           Line(Round((i-1)*70)+20,20,Round((i-1)*70)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round((i-1)*70)+20,430,Strin[1]+' AE');
           SetColor(LightGray);
         END;
         FOR i := 1 TO 15 DO BEGIN
           Line(20,420-Round(i*22),520,420-Round(i*22));
           SetColor(White);
           Str(i,Strin[1]);
           OutTextXY(530,420-Round(i*22)-6,Strin[1]+' Jahre');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Gro�e Halbachse');
         SetTextStyle(2,1,5);
         OutTextXY(580,286,'Umlaufsperiode');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(600,0,'Diagramm "Gro�e Halbachse / Periode" (a^3/T^2)');
       END;
    5: BEGIN
         FOR i := 1990-1990 TO 2050-1990 DO BEGIN
           Line(Round((i)*8.3)+20,20,Round((i)*8.3)+20,420);
           IF (i DIV 10 = 0) AND (1990+(i*10) < 2060) THEN BEGIN
             SetColor(Black);
             SetLineStyle(0,0,1);
             Line(Round(i*83)+20,20,Round(i*83)+20,420);
             SetLineStyle(1,0,1);
             Str(1990+(i*10),Strin[1]);
             SetColor(White);
             OutTextXY(Round(i*83)+20,430,Strin[1]);
           END;
           SetColor(LightGray);
         END;
         Line(20,150-Round(100*1),520,150-Round(100*1));
         SetColor(White);
         OutTextXY(530,150-Round(100*1)-6,'100 AE');
         SetColor(LightGray);
         Line(20,240-Round(10*10),520,240-Round(10*10));
         SetColor(White);
         OutTextXY(530,240-Round(10*10)-6,'10 AE');
         SetColor(LightGray);
         Line(20,330-Round(1*100),520,330-Round(1*100));
         SetColor(White);
         OutTextXY(530,330-Round(1*100)-6,'1 AE');
         SetColor(LightGray);
         Line(20,420-Round(0.1*1000),520,420-Round(0.1*1000));
         SetColor(White);
         OutTextXY(530,420-Round(0.1*1000)-6,'0.1 AE');
         SetColor(LightGray);
         Line(20,420-Round(0.01*1000),520,420-Round(0.01*1000));
         SetColor(White);
         OutTextXY(530,420-Round(0.01*1000)-6,'0.01 AE');
{         FOR i := 1 TO 6 DO BEGIN
           Line(20,420-Round(i*60),520,420-Round(i*60));
           SetColor(White);
           Str(i,Strin[1]);
           OutTextXY(530,420-Round(i*60)-6,Strin[1]+' AE');
           SetColor(LightGray);
         END;}
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Entdeckungsjahr');
         SetTextStyle(2,1,5);
         OutTextXY(580,330,'Gr. Halbachse');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(620,0,'Diagramm "Entdeckungsjahr / Gr. Halbachse"');
       END;
    6: BEGIN
         FOR i := 1990-1990 TO 2050-1990 DO BEGIN
           Line(Round((i)*8.3)+20,20,Round((i)*8.3)+20,420);
           IF (i DIV 10 = 0) AND (1990+(i*10) < 2060) THEN BEGIN
             SetColor(Black);
             SetLineStyle(0,0,1);
             Line(Round(i*83)+20,20,Round(i*83)+20,420);
             SetLineStyle(1,0,1);
             Str(1990+(i*10),Strin[1]);
             SetColor(White);
             OutTextXY(Round(i*83)+20,430,Strin[1]);
           END;
           SetColor(LightGray);
         END;
         Line(20,150-Round(100*1),520,150-Round(100*1));
         SetColor(White);
         OutTextXY(530,150-Round(100*1)-6,'100 Mjup');
         SetColor(LightGray);
         Line(20,240-Round(10*10),520,240-Round(10*10));
         SetColor(White);
         OutTextXY(530,240-Round(10*10)-6,'10 Mjup');
         SetColor(LightGray);
         Line(20,330-Round(1*100),520,330-Round(1*100));
         SetColor(White);
         OutTextXY(530,330-Round(1*100)-6,'1 Mjup');
         SetColor(LightGray);
         Line(20,420-Round(0.1*1000),520,420-Round(0.1*1000));
         SetColor(White);
         OutTextXY(530,420-Round(0.1*1000)-6,'0.1 Mjup');
         SetColor(LightGray);
         Line(20,420-Round(0.01*1000),520,420-Round(0.01*1000));
         SetColor(White);
         OutTextXY(530,420-Round(0.01*1000)-6,'0.01 Mjup');
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Entdeckungsjahr');
         SetTextStyle(2,1,5);
         OutTextXY(580,330,'Exoplaneten-Masse');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(620,0,'Diagramm "Entdeckungsjahr / Exoplaneten-Masse"');
       END;
    7: BEGIN
         FOR i := 2 TO 4 DO BEGIN
           Line(Round(10*(i-1)*16)+20,20,Round(10*(i-1)*16)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round(10*(i-1)*16)+20,430,Strin[1]+' Msol');
           SetColor(LightGray);
         END;
         FOR i := -6 TO 9 DO BEGIN
           Line(20,250-Round(i*25),520,250-Round(i*25));
           SetColor(White);
           Str(i*0.1:4:1,Strin[1]);
           OutTextXY(530,250-Round(i*27)-6,Strin[1]+' [Fe/H]');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Zentralstern-Masse');
         SetTextStyle(2,1,5);
         OutTextXY(593,350,'Metallizit�t');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(620,0,'Diagramm "Zentralstern-Masse / Metallizit�t"');
       END;
    8: BEGIN
         FOR i := 2 TO 10 DO BEGIN
           Line(Round(3*(i-1)*16)+20,20,Round(3*(i-1)*16)+20,420);
           SetColor(White);
           CASE i OF
             02 : Strin[1] := 'O';
             03 : Strin[1] := 'B';
             04 : Strin[1] := 'A';
             05 : Strin[1] := 'F';
             06 : Strin[1] := 'G';
             07 : Strin[1] := 'K';
             08 : Strin[1] := 'M';
             09 : Strin[1] := 'L';
             10 : Strin[1] := 'T';
           END;
           OutTextXY(Round(3*(i-1)*16)+20,430,Strin[1]);
           SetColor(LightGray);
         END;
         FOR i := -6 TO 9 DO BEGIN
           Line(20,250-Round(i*25),520,250-Round(i*25));
           SetColor(White);
           Str(i*0.1:4:1,Strin[1]);
           OutTextXY(530,250-Round(i*25)-6,Strin[1]+' [Fe/H]');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Spektraltyp');
         SetTextStyle(2,1,5);
         OutTextXY(590,370,'Metallizit�t');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(600,0,'Diagramm "Spektraltyp / Metallizit�t"');
       END;
     9: BEGIN
         FOR i := 1 TO 4 DO BEGIN
           Line(Round((i-1)*160)+20,20,Round((i-1)*160)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round((i-1)*160)+20,430,Strin[1]+' Msol');
           SetColor(LightGray);
         END;
         FOR i := 0 TO 15 DO BEGIN
           n := i;
           Line(20,420-Round(n*22),520,420-Round(n*22));
           n := -i;
           SetColor(White);
           Str(Abs(n),Strin[1]);
           OutTextXY(530,90-Round(n*22)-6,Strin[1]+' mag');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Zentralstern-Masse');
         SetTextStyle(2,1,5);
         OutTextXY(567,286,'Absolute Helligkeit');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(600,0,'Diagramm "Zentralstern-Masse / Abs. Helligkeit"');
       END;
     -9: BEGIN
         FOR i := 1 TO 4 DO BEGIN
           Line(Round((i-1)*160)+20,20,Round((i-1)*160)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round((i-1)*160)+20,430,Strin[1]+' Msol');
           SetColor(LightGray);
         END;
         FOR i := 0 TO 17 DO BEGIN
           n := i;
           Line(20,420-Round(n*22),520,420-Round(n*22));
           n := -i;
           SetColor(White);
           Str(Abs(n),Strin[1]);
           OutTextXY(530,46-Round(n*22)-6,Strin[1]+' mag');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Zentralstern-Masse');
         SetTextStyle(2,1,5);
         OutTextXY(567,286,'Scheinbare Helligkeit');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(600,0,'Diagramm "Zentralstern-Masse / Schnb. Helligkeit"');
       END;
    0: BEGIN
         FOR i := 1 TO 4 DO BEGIN
           Line(Round((i-1)*160)+20,20,Round((i-1)*160)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round((i-1)*160)+20,430,Strin[1]+' Msol');
           SetColor(LightGray);
         END;
         FOR i := 1 TO 15 DO BEGIN
           Line(20,420-Round(i*22),520,420-Round(i*22));
           SetColor(White);
           Str(i,Strin[1]);
           OutTextXY(530,420-Round(i*22)-6,Strin[1]+' Mjup');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Zentralstern-Masse');
         SetTextStyle(2,1,5);
         OutTextXY(567,286,'Exoplaneten-Masse');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(600,0,'Diagramm "Zentralstern-Masse / Exoplaneten-Masse"');
       END;
   -1: BEGIN
         FOR i := 1 TO 8 DO BEGIN
           Line(Round((i-1)*70)+20,20,Round((i-1)*70)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round((i-1)*70)+20,430,Strin[1]+' AE');
           SetColor(LightGray);
         END;
         FOR i := -6 TO 9 DO BEGIN
           Line(20,250-Round(i*25),520,250-Round(i*25));
           SetColor(White);
           Str(i*0.1:4:1,Strin[1]);
           OutTextXY(530,250-Round(i*27)-6,Strin[1]+' [Fe/H]');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Gro�e Halbachse');
         SetTextStyle(2,1,5);
         OutTextXY(593,350,'Metallizit�t');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(620,0,'Diagramm "Gro�e Halbachse / Metallizit�t"');
       END;
   -2: BEGIN
         FOR i := 1 TO 15 DO BEGIN
           Line(Round((i-1)*35)+20,20,Round((i-1)*35)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           SetTextStyle(2,0,3);
           OutTextXY(Round((i-1)*35)+20,430,Strin[1]+' MJup');
           SetColor(LightGray);
           SetTextStyle(2,0,4);
         END;
         FOR i := -6 TO 9 DO BEGIN
           Line(20,250-Round(i*25),520,250-Round(i*25));
           SetColor(White);
           Str(i*0.1:4:1,Strin[1]);
           OutTextXY(530,250-Round(i*27)-6,Strin[1]+' [Fe/H]');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Planetenmasse');
         SetTextStyle(2,1,5);
         OutTextXY(593,350,'Metallizit�t');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(620,0,'Diagramm "Exoplaneten-Masse / Metallizit�t"');
       END;
   -3: BEGIN
         FOR i := 1 TO 10 DO BEGIN
           Line(Round((i-1)*50)+20,20,Round((i-1)*50)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round((i-1)*50)+20,430,'0.'+Strin[1]);
           SetColor(LightGray);
         END;
         FOR i := -6 TO 9 DO BEGIN
           Line(20,250-Round(i*25),520,250-Round(i*25));
           SetColor(White);
           Str(i*0.1:4:1,Strin[1]);
           OutTextXY(530,250-Round(i*27)-6,Strin[1]+' [Fe/H]');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Num. Exzentrizit�t');
         SetTextStyle(2,1,5);
         OutTextXY(593,350,'Metallizit�t');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(620,0,'Diagramm "Num. Exzentrizit�t / Metallizit�t"');
       END;
  END;
  SetColor(Blue);
  SetLineStyle(1,0,3);
  MoveTo(Round((1*0.1)*70)+20,420-Round((Sqrt(Power((1*0.1),3)))*22));
  IF Numb = 4 THEN BEGIN
    FOR i := 1 TO 69 DO BEGIN
      LineTo(Round((i*0.1)*70)+20,420-Round((Sqrt(Power((i*0.1),3)))*22));
    END;
  END;
  SetLineStyle(1,0,1);
  SetColor(Red);
  FindFirst('EXO\*.EXO',AnyFile,SearchFile);
  WHILE DosError = 0 DO BEGIN
    Assign(f,'EXO/'+SearchFile.Name);
    Reset(f);
    ReadLn(f,Centralstar[1]);
    ReadLn(f,SpectralType);
    ReadLn(f,Magnitude[1]);
    ReadLn(f,StarMass[1]);
    ReadLn(f,Metalicity[1]);
    ReadLn(f,Distance[1]);
    ReadLn(f,Rectaszension[1]);
    ReadLn(f,Deklination[1]);
    ReadLn(f,Constellation[1]);
    ReadLn(f,PlanetName[1]);
    ReadLn(f,PlanetMass[1]);
    ReadLn(f,SemiMajorAxis[1]);
    ReadLn(f,Period[1]);
    ReadLn(f,Eccentricity[1]);
    ReadLn(f,Method[1]);
    ReadLn(f,DiscoveryDate[1]);
    ReadLn(f,Discoverer[1]);
    {ReadLn(f,Remarks[1]);}
    {Notizen, Kommentare usw. werden nicht mitgelesen!!!}
    Close(f);
    Inc(Dis_Eccentricity[Round(Eccentricity[1]*10)]);
    Inc(Dis_PlanetMass[Round(PlanetMass[1])]);
    Inc(Dis_SemiMajorAxis[Round(SemiMajorAxis[1])]);
    CASE Numb OF
      1: BEGIN
           PutPixel(Round(SemiMajorAxis[1]*70)+20,420-Round(Eccentricity[1]*400),Red);
           Circle(Round(SemiMajorAxis[1]*70)+20,420-Round(Eccentricity[1]*400),3);
         END;
      2: BEGIN
           PutPixel(Round(SemiMajorAxis[1]*70)+20,420-Round(PlanetMass[1]*22),Red);
           Circle(Round(SemiMajorAxis[1]*70)+20,420-Round(PlanetMass[1]*22),3);
         END;
      3: BEGIN
           PutPixel(Round(Eccentricity[1]*445)+20,420-Round(PlanetMass[1]*22),Red);
           Circle(Round(Eccentricity[1]*445)+20,420-Round(PlanetMass[1]*22),3);
         END;
      4: BEGIN
           PutPixel(Round(SemiMajorAxis[1]*70)+20,420-Round((Period[1]/365.25)*22),Red);
           Circle(Round(SemiMajorAxis[1]*70)+20,420-Round((Period[1]/365.25)*22),3);
         END;
      5: BEGIN
           Val(DiscoveryDate[1][1]+DiscoveryDate[1][2]+DiscoveryDate[1][3]+DiscoveryDate[1][4],StarMass[1],Control);
           Val(DiscoveryDate[1][5]+DiscoveryDate[1][6],StarMass[2],Control);
           StarMass[2] := StarMass[2];
           StarMass[1] := StarMass[1]+(StarMass[2]/12);
           IF (SemiMajorAxis[1] < 100) AND (SemiMajorAxis[1] > 10) THEN BEGIN
             SetColor(Black);
             PutPixel(Round((StarMass[1]-1990)*8.3)+20,150-Round(SemiMajorAxis[1]*1),Black);
             Circle(Round((StarMass[1]-1990)*8.3)+20,150-Round(SemiMajorAxis[1]*1),Round(PlanetMass[1]/1));
           END;
           IF (SemiMajorAxis[1] < 10) AND (SemiMajorAxis[1] > 1) THEN BEGIN
             SetColor(Red);
             PutPixel(Round((StarMass[1]-1990)*8.3)+20,240-Round(SemiMajorAxis[1]*10),Red);
             Circle(Round((StarMass[1]-1990)*8.3)+20,240-Round(SemiMajorAxis[1]*10),Round(PlanetMass[1]/1));
           END;
           IF (SemiMajorAxis[1] < 1) AND (SemiMajorAxis[1] > 0.1) THEN BEGIN
             SetColor(Brown);
             PutPixel(Round((StarMass[1]-1990)*8.3)+20,330-Round(SemiMajorAxis[1]*100),Brown);
             Circle(Round((StarMass[1]-1990)*8.3)+20,330-Round(SemiMajorAxis[1]*100),Round(PlanetMass[1]/1));
           END;
           IF (SemiMajorAxis[1] < 0.1) THEN BEGIN
             SetColor(Blue);
             PutPixel(Round((StarMass[1]-1990)*8.3)+20,420-Round(SemiMajorAxis[1]*1000),Blue);
             Circle(Round((StarMass[1]-1990)*8.3)+20,420-Round(SemiMajorAxis[1]*1000),Round(PlanetMass[1]/1));
           END;
         END;
      6: BEGIN
           Val(DiscoveryDate[1][1]+DiscoveryDate[1][2]+DiscoveryDate[1][3]+DiscoveryDate[1][4],StarMass[1],Control);
           Val(DiscoveryDate[1][5]+DiscoveryDate[1][6],StarMass[2],Control);
           StarMass[2] := StarMass[2];
           StarMass[1] := StarMass[1]+(StarMass[2]/12);
           IF (PlanetMass[1] < 100) AND (PlanetMass[1] > 10) THEN BEGIN
             SetColor(Black);
             PutPixel(Round((StarMass[1]-1990)*8.3)+20,150-Round(PlanetMass[1]*1),Black);
             Circle(Round((StarMass[1]-1990)*8.3)+20,150-Round(PlanetMass[1]*1),3);
           END;
           IF (PlanetMass[1] < 10) AND (PlanetMass[1] > 1) THEN BEGIN
             SetColor(Red);
             PutPixel(Round((StarMass[1]-1990)*8.3)+20,240-Round(PlanetMass[1]*10),Red);
             Circle(Round((StarMass[1]-1990)*8.3)+20,240-Round(PlanetMass[1]*10),3);
           END;
           IF (PlanetMass[1] < 1) AND (PlanetMass[1] > 0.1) THEN BEGIN
             SetColor(Brown);
             PutPixel(Round((StarMass[1]-1990)*8.3)+20,330-Round(PlanetMass[1]*100),Brown);
             Circle(Round((StarMass[1]-1990)*8.3)+20,330-Round(PlanetMass[1]*100),3);
           END;
           IF (PlanetMass[1] < 0.1) THEN BEGIN
             SetColor(Blue);
             PutPixel(Round((StarMass[1]-1990)*8.3)+20,420-Round(PlanetMass[1]*1000),Blue);
             Circle(Round((StarMass[1]-1990)*8.3)+20,420-Round(PlanetMass[1]*1000),3);
           END;
           {PutPixel(Round((StarMass[1]-1990)*8.3)+20,420-Round(PlanetMass[1]*22),Red);
           Circle(Round((StarMass[1]-1990)*8.3)+20,420-Round(PlanetMass[1]*22),3);}
         END;
      7: BEGIN
           PutPixel(Round(StarMass[1]*160)+20,250-Round(Metalicity[1]*250),Red);
           Circle(Round(StarMass[1]*160)+20,250-Round(Metalicity[1]*250),3);
         END;
      8: BEGIN
           CASE SpectralType[1] OF
             'O' : StarMass[1] := 0.1;
             'B' : StarMass[1] := 0.2;
             'A' : StarMass[1] := 0.3;
             'F' : StarMass[1] := 0.4;
             'G' : StarMass[1] := 0.5;
             'K' : StarMass[1] := 0.6;
             'M' : StarMass[1] := 0.7;
             'L' : StarMass[1] := 0.8;
             'T' : StarMass[1] := 0.9;
           END;
           IF SpectralType[2] <> '' THEN CASE SpectralType[2] OF
             '0' : StarMass[1] := StarMass[1]+0.00;
             '1' : StarMass[1] := StarMass[1]+0.01;
             '2' : StarMass[1] := StarMass[1]+0.02;
             '3' : StarMass[1] := StarMass[1]+0.03;
             '4' : StarMass[1] := StarMass[1]+0.04;
             '5' : StarMass[1] := StarMass[1]+0.05;
             '6' : StarMass[1] := StarMass[1]+0.06;
             '7' : StarMass[1] := StarMass[1]+0.07;
             '8' : StarMass[1] := StarMass[1]+0.08;
             '9' : StarMass[1] := StarMass[1]+0.09;
           END;
           PutPixel(Round(3*StarMass[1]*160)+20,250-Round(Metalicity[1]*250),Red);
           Circle(Round(3*StarMass[1]*160)+20,250-Round(Metalicity[1]*250),3);
         END;
      9: BEGIN
           Magnitude2 := Magnitude[1]+5-5*(Ln(Distance[1])/Ln(10));
           PutPixel(Round(StarMass[1]*160)+20,Round(Magnitude2*22)+90,Red);
           Circle(Round(StarMass[1]*160)+20,Round(Magnitude2*22)+90,3);
         END;
     -9: BEGIN
           Magnitude2 := Magnitude[1];
           PutPixel(Round(StarMass[1]*160)+20,Round(Magnitude2*22)+46,Red);
           Circle(Round(StarMass[1]*160)+20,Round(Magnitude2*22)+46,3);
         END;
      0: BEGIN
           PutPixel(Round(StarMass[1]*160)+20,420-Round(PlanetMass[1]*22),Red);
           Circle(Round(StarMass[1]*160)+20,420-Round(PlanetMass[1]*22),3);
         END;
     -1: BEGIN
           PutPixel(Round(SemiMajorAxis[1]*70)+20,250-Round(Metalicity[1]*250),Red);
           Circle(Round(SemiMajorAxis[1]*70)+20,250-Round(Metalicity[1]*250),3);
         END;
     -2: BEGIN
           IF PlanetMass[1] < 15 THEN BEGIN
             PutPixel(Round(PlanetMass[1]*35)+20,250-Round(Metalicity[1]*250),Red);
             Circle(Round(PlanetMass[1]*35)+20,250-Round(Metalicity[1]*250),3);
           END;
         END;
     -3: BEGIN
           PutPixel(Round(Eccentricity[1]*445)+20,250-Round(Metalicity[1]*250),Red);
           Circle(Round(Eccentricity[1]*445)+20,250-Round(Metalicity[1]*250),3);
         END;
{      -1: BEGIN
           Period[1] := Period[1]/365.25;
           n2 := Power(StarMass[1]*Period[1],1/3);
           n2 := 4.83*n2;


           PutPixel(Round(SemimajorAxis[1]*100)+10,320 DIV 2,Green);
           PutPixel(Round(n2*50)+10,480 DIV 2,Red);
      END;}
    END;
    FindNext(SearchFile);
  END;
  SetColor(Cyan);
  SetTextStyle(2,0,4);
  OutTextXY(20,2,'(C) 1995-2006 EXODB2 1.8 * Michael Johne * http://www.exodb.de.vu');
  Input := ReadKey;
  IF Input IN ['S','s'] THEN BEGIN
    SetTextStyle(2,HorizDir,4);
    SaveImage(0+200,0+200,640-200,480-200,'image.tmp');
    SetFillStyle(SolidFill,Blue);
    SetLineStyle(0,0,1);
    Bar(0+200,0+200,640-200,480-200);
    SetColor(DarkGray);
    Rectangle(0+200,0+200,640-200,480-200);
    SetColor(LightGray);
    Rectangle(0+201,0+201,640-201,480-201);
    SetColor(White);
    Rectangle(0+202,0+202,640-202,480-202);
    SetColor(LightGray);
    Rectangle(0+203,0+203,640-203,480-203);
    SetColor(DarkGray);
    Rectangle(0+204,0+204,640-204,480-204);
    SetColor(White);
    OutTextXY(210,210,'Speichern der Bilddatei:');
    SetColor(Yellow);
    CASE Numb OF
      1: OutTextXY(360,210,'AXIS_ECC');
      2: OutTextXY(360,210,'AXIS_MASS');
      3: OutTextXY(360,210,'ECC_MASS');
      4: OutTextXY(360,210,'A3_T2');
      5: OutTextXY(360,210,'YR_AXIS');
      6: OutTextXY(360,210,'YR_MASS');
      7: OutTextXY(360,210,'MASS_MTL');
      8: OutTextXY(360,210,'SPEC_MTL');
      9: OutTextXY(360,210,'MASS_MA');
     -9: OutTextXY(360,210,'MASS_MV');
      0: OutTextXY(360,210,'MASS_S-P');
     -1: OutTextXY(360,210,'AXIS_MTL');
     -2: OutTextXY(360,210,'MASP_MTL');
     -3: OutTextXY(360,210,'ECC_MTL');
    END;
    SetColor(White);
    OutTextXY(270,230,'1 - Format PCX');
    OutTextXY(270,240,'2 - Format BMP');
    OutTextXY(270,250,'0 - Abbruch');
    REPEAT
      Input := ReadKey;
    UNTIL Input IN ['0','1','2'];
    LoadImage(0+200,0+200,'image.tmp');
    IF NOT(DirExists('DIAGRAM')) THEN MkDir('DIAGRAM');
    CASE Input OF
      '1' :
        CASE Numb OF
          1: SavePCX('DIAGRAM/'+'AXIS_ECC'+'.PCX');
          2: SavePCX('DIAGRAM/'+'AXIS_MAS'+'.PCX');
          3: SavePCX('DIAGRAM/'+'ECC_MASS'+'.PCX');
          4: SavePCX('DIAGRAM/'+'A3_T2'+'.PCX');
          5: SavePCX('DIAGRAM/'+'YR_AXIS'+'.PCX');
          6: SavePCX('DIAGRAM/'+'YR_MASS'+'.PCX');
          7: SavePCX('DIAGRAM/'+'MASS_MTL'+'.PCX');
          8: SavePCX('DIAGRAM/'+'SPEC_MTL'+'.PCX');
          9: SavePCX('DIAGRAM/'+'MASS_MA'+'.PCX');
         -9: SavePCX('DIAGRAM/'+'MASS_MV'+'.PCX');
          0: SavePCX('DIAGRAM/'+'MASS_S-P'+'.PCX');
         -1: SavePCX('DIAGRAM/'+'AXIS_MTL'+'.PCX');
         -2: SavePCX('DIAGRAM/'+'MASP_MTL'+'.PCX');
         -3: SavePCX('DIAGRAM/'+'ECC_MTL'+'.PCX');
        END;
      '2' :
        CASE Numb OF
          1: SaveBMP('DIAGRAM/'+'AXIS_ECC');
          2: SaveBMP('DIAGRAM/'+'AXIS_MAS');
          3: SavePCX('DIAGRAM/'+'ECC_MASS');
          4: SaveBMP('DIAGRAM/'+'A3_T2');
          5: SaveBMP('DIAGRAM/'+'YR_AXIS');
          6: SaveBMP('DIAGRAM/'+'YR_MASS');
          7: SaveBMP('DIAGRAM/'+'MASS_MTL');
          8: SaveBMP('DIAGRAM/'+'SPEC_MTL');
          9: SaveBMP('DIAGRAM/'+'MASS_MA');
         -9: SaveBMP('DIAGRAM/'+'MASS_MV');
          0: SaveBMP('DIAGRAM/'+'MASS_S-P');
         -1: SaveBMP('DIAGRAM/'+'AXIS_MTL');
         -2: SaveBMP('DIAGRAM/'+'MASP_MTL');
         -3: SaveBMP('DIAGRAM/'+'ECC_MTL');
        END;
      '0' : Exit;
    END;
    Bar(0+200,0+200,640-200,480-200);
    SetColor(DarkGray);
    Rectangle(0+200,0+200,640-200,480-200);
    SetColor(LightGray);
    Rectangle(0+201,0+201,640-201,480-201);
    SetColor(White);
    Rectangle(0+202,0+202,640-202,480-202);
    SetColor(LightGray);
    Rectangle(0+203,0+203,640-203,480-203);
    SetColor(DarkGray);
    Rectangle(0+204,0+204,640-204,480-204);
    SetColor(LightGreen);
    SetTextStyle(2,HorizDir,5);
    OutTextXY(230,230,'Bilddatei gespeichert...');
    DeleteFile('image.tmp');
    Readkey;
  END ELSE IF Input IN ['P','p'] THEN GraftoPrint;
  CloseGraph;
END.

