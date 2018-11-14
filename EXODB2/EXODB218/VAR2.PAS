UNIT Var2; {Dieses Unit ist nur fÅr Unit DISTRI!!!}

INTERFACE

USES Crt,Dos,Graph,Basic,Cursor,Image,RT_Watch;

VAR
  Finished          : Boolean;
  Input             : Char;
  ExoFileMax,
  Control,i,Numb,
  Zoom,n,SM_Nil,
  grDriver,grMode   : Integer;
  Swap,x,y,
  Magnitude2        : Real;
  a,p,e,b,c,
  regs              : Registers;
  SearchFile        : SearchRec;
  TempStr           : STRING;
  f,f2              : Text;
  DiscoveryDate2    : ARRAY[0..2100] OF Word;
  K_Pl,
  Deklination,
  Distance,
  Eccentricity,
  Magnitude,
  Metalicity,
  Period,
  PlanetMass,
  Rectaszension,
  SemiMajorAxis,
  StarMass          : ARRAY[0..700] OF Real; {500 ~ MAxExoFil}
  Dis_Eccentricity,
  Dis_Metalicity,
  Dis_PlanetMass,
  Dis_RadialVelocityPlanet,
  Dis_SpectralType,
  Dis_SemiMajorAxis : ARRAY[0..30] OF Byte;
  DisYearCorr,
  DisYearSum,
  DisYearMin,
  DisYearMax        : Word;
  PlanetMass2,
  CentralStar,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Method,
  PlanetName,
  Remarks,
  Strin,
  SpectralType      : ARRAY[0..3] OF STRING;
  Fil               : ARRAY[1..3] OF STRING;

  PROCEDURE DistriReadEXO;
  PROCEDURE CheckParameters;
  PROCEDURE CheckPropertiesForDistributions;
  PROCEDURE SetTitle;
  PROCEDURE SetAxisDescription;
  PROCEDURE SavePicture;

IMPLEMENTATION

PROCEDURE DistriReadEXO;
BEGIN
  SetColor(Red);
  FindFirst('EXO\*.EXO',AnyFile,SearchFile);
  i := 0;
  WHILE DosError = 0 DO BEGIN
    Inc(i);
    Assign(f,'exo/'+SearchFile.Name);
    Reset(f);
    ReadLn(f,Centralstar[1]);
    ReadLn(f,SpectralType[1]);
    ReadLn(f,Magnitude[i]);
    ReadLn(f,StarMass[i]);
    ReadLn(f,Metalicity[i]);
    ReadLn(f,Distance[i]);
    ReadLn(f,Rectaszension[i]);
    ReadLn(f,Deklination[i]);
    ReadLn(f,Constellation[1]);
    ReadLn(f,PlanetName[1]);
    ReadLn(f,PlanetMass[i]);
    ReadLn(f,SemiMajorAxis[i]);
    ReadLn(f,Period[i]);
    ReadLn(f,Eccentricity[i]);
    ReadLn(f,Method[1]);
    ReadLn(f,DiscoveryDate[1]);
    ReadLn(f,Discoverer[1]);
    ReadLn(f,Remarks[1]);
    K_Pl[i] := ((28*PlanetMass[i])/Power(SemiMajorAxis[i]*StarMass[i],0.5))*(1/SqRt(1-Sqr(Eccentricity[i])));
    Close(f);
    FindNext(SearchFile);
  END;
END;


PROCEDURE CheckParameters;
BEGIN
  TextBackground(Black);
  TextColor(White);
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF ParamStr(1) = '' THEN BEGIN
    ClrScr;
    WriteLn(^j^j'Der Parameter als Anzahl der darzustellenden Distribution fehlt!');
    ReadKey;
    Halt;
  END ELSE BEGIN
    Val(ParamStr(1),Numb,Control);
    IF (Control <> 0) THEN BEGIN
      ClrScr;
      WriteLn(^j^j'Der eingegebene Zahlenwert ',ParamStr(1),' ist ungÅltig.');
      WriteLn('Es sind die Zahlen von 0 bis 4 erlebt.');
      ReadKey;
      Halt;
    END;
  END;
END;

PROCEDURE CheckPropertiesForDistributions;
BEGIN
  CASE Numb OF
    0,4 : BEGIN
            IF (Numb = 4) OR (Numb = 0) THEN BEGIN
              Val(DiscoveryDate[1][1]+DiscoveryDate[1][2]+DiscoveryDate[1][3]+DiscoveryDate[1][4],DisYearCorr,Control);
              Inc(DiscoveryDate2[DisYearCorr]);
              IF DisYearCorr < DisYearMin THEN DisYearMin := DisYearCorr;
              IF DisYearCorr > DisYearMax THEN DisYearMax := DisYearCorr;
            END;
          END;
   -1 : BEGIN
          K_Pl[1] := ((28*PlanetMass[1])/Power(SemiMajorAxis[1]*StarMass[1],0.5))*(1/SqRt(1-Sqr(Eccentricity[1])));
          IF Round(K_Pl[1]) > 240 THEN Inc(Dis_RadialVelocityPlanet[24])
          ELSE Inc(Dis_RadialVelocityPlanet[Round(K_Pl[1]/10)]);
        END;
    1 : Inc(Dis_Eccentricity[Round(Eccentricity[1]*10)]);
    2 : Inc(Dis_PlanetMass[Round(PlanetMass[1])]);
   -2 : BEGIN
          IF StarMass[1] = 0 THEN Inc(SM_Nil) ELSE BEGIN
            IF (PlanetMass[1]/1047)/StarMass[1] < 0.000001 THEN Inc(Dis_PlanetMass[1]) ELSE
            IF ((PlanetMass[1]/1047)/StarMass[1] >= 0.00001) AND ((PlanetMass[1]/1047)/StarMass[1] < 0.0001)
              THEN Inc(Dis_PlanetMass[2]) ELSE
            IF ((PlanetMass[1]/1047)/StarMass[1] >= 0.0001) AND ((PlanetMass[1]/1047)/StarMass[1] < 0.001)
              THEN Inc(Dis_PlanetMass[3]) ELSE
            IF ((PlanetMass[1]/1047)/StarMass[1] >= 0.001) AND ((PlanetMass[1]/1047)/StarMass[1] < 0.01)
              THEN Inc(Dis_PlanetMass[4]) ELSE
            IF ((PlanetMass[1]/1047)/StarMass[1] >= 0.01) AND ((PlanetMass[1]/1047)/StarMass[1] < 0.1)
              THEN Inc(Dis_PlanetMass[5]) ELSE
            IF ((PlanetMass[1]/1047)/StarMass[1] >= 0.1) AND ((PlanetMass[1]/1047)/StarMass[1] < 1)
              THEN Inc(Dis_PlanetMass[6]);
          END;
        END;
    3 : Inc(Dis_SemiMajorAxis[Round(SemiMajorAxis[1])]);
    5 : BEGIN
          IF (SpectralType[1][1] = 'O') OR (SpectralType[1][1] = 'o') THEN Inc(Dis_SpectralType[1]) ELSE
          IF (SpectralType[1][1] = 'B') OR (SpectralType[1][1] = 'B') THEN Inc(Dis_SpectralType[2]) ELSE
          IF (SpectralType[1][1] = 'A') OR (SpectralType[1][1] = 'A') THEN Inc(Dis_SpectralType[3]) ELSE
          IF (SpectralType[1][1] = 'F') OR (SpectralType[1][1] = 'F') THEN Inc(Dis_SpectralType[4]) ELSE
          IF (SpectralType[1][1] = 'G') OR (SpectralType[1][1] = 'G') THEN Inc(Dis_SpectralType[5]) ELSE
          IF (SpectralType[1][1] = 'K') OR (SpectralType[1][1] = 'K') THEN Inc(Dis_SpectralType[6]) ELSE
          IF (SpectralType[1][1] = 'M') OR (SpectralType[1][1] = 'M') THEN Inc(Dis_SpectralType[7]) ELSE
          IF (SpectralType[1][1] = 'L') OR (SpectralType[1][1] = 'L') THEN Inc(Dis_SpectralType[8]) ELSE
          IF (SpectralType[1][1] = 'T') OR (SpectralType[1][1] = 'T') THEN Inc(Dis_SpectralType[9]) ELSE
            Inc(Dis_SpectralType[0]);
        END;
    6 : IF Distance[1] < 100 THEN Inc(Dis_PlanetMass[Round(Distance[1]/10)]) ELSE Inc(Dis_PlanetMass[10]);
    7 : IF Magnitude[1] < 10 THEN Inc(Dis_PlanetMass[Round(Magnitude[1])]) ELSE Inc(Dis_PlanetMass[10]);
   -7 : BEGIN
          Magnitude2 := Magnitude[1]+5-5*(Ln(Distance[1])/Ln(10));
          IF Magnitude2 < 10 THEN Inc(Dis_PlanetMass[Round(Magnitude2)]) ELSE Inc(Dis_PlanetMass[10]);
        END;
    8 : BEGIN
          Metalicity[1] := Metalicity[1]*10;
          CASE Round(Metalicity[1]) OF
            -5 : Inc(Dis_PlanetMass[1]);
            -4 : Inc(Dis_PlanetMass[2]);
            -3 : Inc(Dis_PlanetMass[3]);
            -2 : Inc(Dis_PlanetMass[4]);
            -1 : Inc(Dis_PlanetMass[5]);
             0 : Inc(Dis_PlanetMass[6]);
             1 : Inc(Dis_PlanetMass[7]);
             2 : Inc(Dis_PlanetMass[8]);
             3 : Inc(Dis_PlanetMass[9]);
             4 : Inc(Dis_PlanetMass[10]);
             5 : Inc(Dis_PlanetMass[11]);
          END;
        END;
    9 : BEGIN
          IF StarMass[1] < 1.6 THEN Inc(Dis_PlanetMass[Round(StarMass[1]*10)])
            ELSE Inc(Dis_PlanetMass[0]);
        END;
  END;
END;

PROCEDURE SetTitle;
BEGIN
  SetColor(Black);
  {IF ParamStr(2) = '1' THEN BEGIN
    SetTextStyle(2,0,4);
    OutTextXY(40,65,'+ kumulativer Darstellung');
  END;}
  SetTextStyle(2,0,8);
  CASE Numb OF
    1: BEGIN
         OutTextXY(40,40,'ZÑhlung: BahnexzentrizitÑt');
       END;
    -1: BEGIN
         OutTextXY(40,40,'ZÑhlung: Radialgeschwindigkeiten');
         OutTextXY(170,60,'der Exoplaneten');
       END;
    2: OutTextXY(40,40,'ZÑhlung: Exoplaneten-Masse');
   -2: BEGIN
         OutTextXY(40,40,'ZÑhlung: MasseverhÑltnis:');
         OutTextXY(170,60,'Planet/Stern');
       END;
    3: OutTextXY(40,40,'ZÑhlung: Gro·e Halbachse');
    4,0: OutTextXY(40,40,'JÑhrliche Entdeckung');
    5: OutTextXY(40,40,'ZÑhlung: Spektralklasse');
    6: OutTextXY(40,40,'ZÑhlung: Distanz zur Sonne');
    7: OutTextXY(23,40,'ZÑhlung: Scheinbare Helligkeit');
    -7: OutTextXY(23,40,'ZÑhlung: Absolute Helligkeit');
    8: OutTextXY(40,40,'ZÑhlung: MetallizitÑt');
    9: OutTextXY(40,40,'ZÑhlung: Zentralstern-Masse');
  END;
END;

PROCEDURE SetAxisDescription;
BEGIN
  SetTextStyle(2,0,5);
  SetColor(LightGreen);
  CASE Numb OF
   -1: FOR i := 1 TO 25 DO BEGIN
         SetTextStyle(2,0,4);
         Str(Round((i-1)*10),Strin[1]);
         Str(Round(i*10),Strin[2]);
         Strin[1] := Strin[1]+' - '+Strin[2];
         Str(Dis_RadialVelocityPlanet[i-1],Strin[2]);
         IF i = 25 THEN OutTextXY(530,37+(i*10)+(3*i),'> 240:  '+Strin[2])
           ELSE OutTextXY(530,37+(i*10)+(3*i),Strin[1]+':  '+Strin[2]);
         OutTextXY(530,37+(27*10)+(3*27),'Angaben in km/s');
       END;
    1: FOR i := 1 TO 10 DO BEGIN
         Str((i*0.1)-0.1:0:1,Strin[1]);
         Str(Dis_Eccentricity[i-1],Strin[2]);
         OutTextXY(550,37+(i*10)+(3*i),Strin[1]+': '+Strin[2]);
       END;
    2: FOR i := 1 TO 15 DO BEGIN
         Str((i)-1,Strin[1]);
         Str(Dis_PlanetMass[i-1],Strin[2]);
         OutTextXY(550,37+(i*10)+(3*i),Strin[1]+' Mjup: '+Strin[2]);
       END;
   -2: FOR i := 1 TO 6 DO BEGIN
         SetColor(LightGreen);
         SetTextStyle(2,0,4);
         Str(Dis_PlanetMass[i],Strin[2]);
         CASE i OF
           1: OutTextXY(530,37+(i*20)+(3*i),'0.000001 - 0.000009');
           2: OutTextXY(530,37+(i*20)+(3*i),'0.00001  - 0.00009');
           3: OutTextXY(530,37+(i*20)+(3*i),'0.0001   - 0.0009');
           4: OutTextXY(530,37+(i*20)+(3*i),'0.001    - 0.009');
           5: OutTextXY(530,37+(i*20)+(3*i),'0.01     - 0.09');
           6: OutTextXY(530,37+(i*20)+(3*i),'0.1      - 0.9');
         END;
         SetColor(White);
         Str(Dis_PlanetMass[i],Strin[1]);
         OutTextXY(550,47+(i*20)+(3*i),Strin[1]);
         SetTextStyle(2,0,5);
       END;
    3: FOR i := 1 TO 10 DO BEGIN
         Str((i)-1,Strin[1]);
         Str(Dis_SemiMajorAxis[i-1],Strin[2]);
         OutTextXY(550,37+(i*10)+(3*i),Strin[1]+' AE: '+Strin[2]);
       END;
    5: FOR i := 0 TO 9 DO BEGIN
         CASE i OF
           0 : Strin[1] := '-';
           1 : Strin[1] := 'O';
           2 : Strin[1] := 'B';
           3 : Strin[1] := 'A';
           4 : Strin[1] := 'F';
           5 : Strin[1] := 'G';
           6 : Strin[1] := 'K';
           7 : Strin[1] := 'M';
           8 : Strin[1] := 'L';
           9 : Strin[1] := 'T';
         END;
         Str(Dis_SpectralType[i],Strin[2]);
         OutTextXY(550,37+(i*10)+(3*i),Strin[1]+': '+Strin[2]);
       END;
    6: FOR i := 1 TO 11 DO BEGIN
         Str((i)-1,Strin[1]);
         Strin[1] := Strin[1]+'0';
         Str((i),Strin[2]);
         Strin[1] := Strin[1]+'-'+Strin[2]+'0';
         Str(Dis_PlanetMass[i-1],Strin[2]);
         IF i = 11 THEN OutTextXY(530,37+(i*10)+(3*i),'> 100 pc: '+Strin[2])
           ELSE OutTextXY(530,37+(i*10)+(3*i),Strin[1]+' pc: '+Strin[2]);
       END;
    -7,7: FOR i := 1 TO 11 DO BEGIN
         Str((i)-1,Strin[1]);
         Strin[1] := Strin[1];
         Str((i),Strin[2]);
         Strin[1] := Strin[1]+'-'+Strin[2];
         Str(Dis_PlanetMass[i-1],Strin[2]);
         IF i = 11 THEN OutTextXY(530,37+(i*10)+(3*i),'> 10 mag: '+Strin[2])
           ELSE OutTextXY(530,37+(i*10)+(3*i),Strin[1]+' mag: '+Strin[2]);
       END;
    8: FOR i := 1 TO 11 DO BEGIN
         Str(((i)-6)/10:4:1,Strin[1]);
         Str(Dis_PlanetMass[i],Strin[2]);
         OutTextXY(530,37+(i*10)+(3*i),'Fe/H '+Strin[1]+': '+Strin[2]);
       END;
    9: FOR i := 1 TO 15 DO BEGIN
         Str((i*0.1):0:1,Strin[1]);
         Str(Dis_PlanetMass[i-1],Strin[2]);
         OutTextXY(530,37+(i*10)+(3*i),Strin[1]+' Msol: '+Strin[2]);
       END;
  END;
  SetColor(White);
  CASE Numb OF
   -1: FOR i := 1 TO 25 DO BEGIN
         IF i < 25 THEN Str(Round((i)*10),Strin[1]) ELSE Str(Round((i-1)*10),Strin[1]);
         IF i < 10 THEN OutTextXY(5+(i*20),430,Strin[1])
           ELSE IF i = 25 THEN OutTextXY(2+(i*20),430,' >'+Strin[1])
             ELSE OutTextXY(2+(i*20),430,Strin[1]);
         SetTextStyle(2,0,5);
         OutTextXY(250,460,'Radialgeschwindigkeiten der Exoplaneten in km/s');
         SetTextStyle(2,0,4);
       END;
    1: FOR i := 1 TO 10 DO BEGIN
         Str((i*0.1)-0.1:0:1,Strin[1]);
         OutTextXY(42+(i*37)+(3*i),430,Strin[1]);
       END;
    2: FOR i := 1 TO 15 DO BEGIN
         Str(i-1,Strin[1]);
         OutTextXY(10+(i*25)+(5*i),430,Strin[1]);
         OutTextXY(500,430,'Jupitermassen');
       END;
   -2: FOR i := 1 TO 6 DO BEGIN
         Str(Dis_PlanetMass[i],Strin[1]);
         IF Dis_PlanetMass[i] < 9 THEN OutTextXY(50+(i*25)+(15*i),430,Strin[1])
           ELSE OutTextXY(45+(i*25)+(15*i),430,Strin[1]);;
         OutTextXY(400,430,'Anzahl d. Exoplaneten');
       END;
    3: FOR i := 1 TO 10 DO BEGIN
         Str(i-1,Strin[1]);
         OutTextXY(46+(i*37)+(3*i),430,Strin[1]);
         OutTextXY(500,430,'Astron. Einheiten');
       END;
    5: FOR i := 1 TO 9 DO BEGIN
         CASE i OF
           1 : Strin[1] := 'O';
           2 : Strin[1] := 'B';
           3 : Strin[1] := 'A';
           4 : Strin[1] := 'F';
           5 : Strin[1] := 'G';
           6 : Strin[1] := 'K';
           7 : Strin[1] := 'M';
           8 : Strin[1] := 'L';
           9 : Strin[1] := 'T';
         END;
         OutTextXY(42+(i*37)+(3*i),430,Strin[1]);
         OutTextXY(500,430,'Spektraltyp');
       END;
    6: BEGIN
         SetTextStyle(2,0,4);
         FOR i := 1 TO 11 DO BEGIN
           Str((i)-1,Strin[1]);
           Strin[1] := Strin[1]+'0';
           Str((i),Strin[2]);
           Strin[1] := Strin[1]+'-'+Strin[2]+'0';
           IF i = 11 THEN OutTextXY((i*37)+(3*i)-5,430,' >100')
             ELSE OutTextXY((i*37)+(3*i)-5,430,Strin[1]);
         END;
         SetTextStyle(2,0,5);
         OutTextXY(400,460,'Distanz zur Sonne in Parsec');
       END;
    -7,7: BEGIN
         SetTextStyle(2,0,4);
         FOR i := 1 TO 11 DO BEGIN
           Str((i)-1,Strin[1]);
           Strin[1] := Strin[1];
           Str((i),Strin[2]);
           Strin[1] := Strin[1]+'-'+Strin[2];
           IF i = 11 THEN OutTextXY((i*37)+(3*i)-5,430,' >10')
             ELSE OutTextXY((i*37)+(3*i)-5,430,Strin[1]);
         END;
         SetTextStyle(2,0,5);
         IF Numb = 7 THEN OutTextXY(400,460,'Scheinbare Helligkeit im mag') ELSE
           IF Numb = -7 THEN OutTextXY(400,460,'Absolute Helligkeit im mag');
       END;
    8: BEGIN
         SetTextStyle(2,0,4);
         FOR i := 1 TO 11 DO BEGIN
           Str(((i)-6)/10:4:1,Strin[1]);
           Str(Dis_PlanetMass[i],Strin[2]);
           OutTextXY((i*37)+(3*i)+40,430,Strin[1]);
         END;
         SetTextStyle(2,0,5);
         OutTextXY(400,460,'MetallizitÑt (Fe/H)');
       END;
    9: FOR i := 1 TO 15 DO BEGIN
         Str((i*0.1):0:1,Strin[1]);
         OutTextXY(7+(i*25)+(5*i),430,Strin[1]);
         OutTextXY(500,430,'in Sonnenmassen');
       END;
  END;
END;

PROCEDURE SavePicture;
BEGIN
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
    1: OutTextXY(360,210,'ECC');
   -1: OutTextXY(360,210,'RVPLANET');
    2: OutTextXY(360,210,'MASS');
   -2: OutTextXY(360,210,'M2M1');
    3: OutTextXY(360,210,'AXIS');
    4: OutTextXY(360,210,'YEAR');
    0: OutTextXY(360,210,'YEAR2');
    5: OutTextXY(360,210,'SPEC');
    6: OutTextXY(360,210,'DISTANCE');
    7: OutTextXY(360,210,'VMAG');
   -7: OutTextXY(360,210,'AMAG');
    8: OutTextXY(360,210,'METAL');
    9: OutTextXY(360,210,'STARMASS');
  END;
  SetColor(White);
  OutTextXY(270,230,'1 - Format PCX');
  OutTextXY(270,240,'2 - Format BMP');
  OutTextXY(270,250,'0 - Abbruch');
  REPEAT
    Input := ReadKey;
  UNTIL Input IN ['0','1','2'];
  LoadImage(0+200,0+200,'image.tmp');
  IF NOT(DirExists('DISTRI')) THEN MkDir('DISTRI');
  CASE Input OF
    '1' :
      CASE Numb OF
        1: SavePCX('DISTRI/'+'ECC'+'.PCX');
       -1: SavePCX('DISTRI/'+'RVPLANET'+'.PCX');
        2: SavePCX('DISTRI/'+'MASS'+'.PCX');
       -2: SavePCX('DISTRI/'+'M2M1'+'.PCX');
        3: SavePCX('DISTRI/'+'AXIS'+'.PCX');
        4: SavePCX('DISTRI/'+'YEAR'+'.PCX');
        0: SavePCX('DISTRI/'+'YEAR2'+'.PCX');
        5: SavePCX('DISTRI/'+'SPEC'+'.PCX');
        6: SavePCX('DISTRI/'+'DISTANCE'+'.PCX');
        7: SavePCX('DISTRI/'+'VMAG'+'.PCX');
       -7: SavePCX('DISTRI/'+'AMAG'+'.PCX');
        8: SavePCX('DISTRI/'+'METAL'+'.PCX');
        9: SavePCX('DISTRI/'+'STARMASS'+'.PCX');
      END;
    '2' :
      CASE Numb OF
        1: SaveBMP('DISTRI/'+'ECC');
       -1: SaveBMP('DISTRI/'+'RVPLANET');
        2: SaveBMP('DISTRI/'+'MASS');
       -2: SaveBMP('DISTRI/'+'M2M1');
        3: SaveBMP('DISTRI/'+'AXIS');
        4: SaveBMP('DISTRI/'+'YEAR');
        0: SaveBMP('DISTRI/'+'YEAR2');
        5: SaveBMP('DISTRI/'+'SPEC');
        6: SaveBMP('DISTRI/'+'DISTANCE');
        7: SaveBMP('DISTRI/'+'VMAG');
       -7: SaveBMP('DISTRI/'+'AMAG');
        8: SaveBMP('DISTRI/'+'METAL');
        9: SaveBMP('DISTRI/'+'STARMASS');
      END;
    '0' : BEGIN
            DeleteFile('image.tmp');
            Exit;
          END;
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
END;

BEGIN
END.
