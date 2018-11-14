UNIT Scan_Exo;

INTERFACE

PROCEDURE ReadExo;
PROCEDURE ScanExo(Spec2_Min,Spec2_Max,Date2,Date : STRING; Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max : Real);
PROCEDURE ScanExoUpdate(n : Byte);
PROCEDURE ScanExoInfo(n : Byte);

IMPLEMENTATION

USES Crt,Dos,Graph,Arithmos,Basic,Cursor,RT_Watch,ConstVar;

PROCEDURE ReadEXO;
BEGIN
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
  ReadLn(f,Declination);
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
  ReadLn(f,Remarks1);
  ReadLn(f,Remarks2);
  Close(f);
END;

PROCEDURE ScanExo(Spec2_Min,Spec2_Max,Date2,Date : STRING; Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
  Dist2_min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
  Period2_Max,Ecc2_Min,Ecc2_Max : Real);
VAR
  j,j2,j3,j4 : Real;
  Con : ARRAY[0..15] OF Integer;
  TmpStr : STRING;
BEGIN
  IF Date2 <> '' THEN Val(Date2,j3,Con[1]);
  IF Date <> '' THEN Val(Date,j,Con[2]);
  IF Date2 = '' THEN j3 := 0000000;
  IF Date = '' THEN j := 30000000;
  FOR i := 1 TO MaxReadFile DO ExoFile[i] := '';
  ExoFileMax := 1;
  FindFirst('EXO\*.EXO',AnyFile,SearchFile);
  WHILE DosError = 0 DO BEGIN
    ExoFile[ExoFileMax] := SearchFile.Name;
    IF FileExists('EXO\'+ExoFile[ExoFileMax]) THEN BEGIN
      Assign(f,'EXO\'+ExoFile[ExoFileMax]);
      Reset(f);
      ReadLn(f,Centralstar);
      ReadLn(f,SpectralType);
      ReadLn(f,TmpStr);
      Val(TmpStr,Magnitude,Con[3]);
      ReadLn(f,TmpStr);
      Val(TmpStr,StarMass,Con[4]);
      {IF Korrektur THEN BEGIN
        ReadLn(f,Metalicity,Metalicity2);
      END ELSE}
      ReadLn(f,TmpStr);
      Val(TmpStr,Metalicity,Con[5]);
      ReadLn(f,TmpStr);
      Val(TmpStr,Distance,Con[6]);
      ReadLn(f,TmpStr);
      Val(TmpStr,Rectaszension,Con[7]);
      ReadLn(f,TmpStr);
      Val(TmpStr,Declination,Con[8]);
      ReadLn(f,Constellation);
      ReadLn(f,PlanetName);
      {IF Korrektur THEN BEGIN
        ReadLn(f,PlanetMass,PlanetMass2);
      END ELSE}
      ReadLn(f,TmpStr);
      Val(TmpStr,PlanetMass,Con[9]);
      {IF Korrektur THEN BEGIN
        ReadLn(f,SemiMajorAxis,SemiMajorAxis2);
      END ELSE}
      ReadLn(f,TmpStr);
      Val(TmpStr,SemiMajorAxis,Con[10]);
      {IF Korrektur THEN BEGIN
        ReadLn(f,Period,Period2);
      END ELSE}
      ReadLn(f,TmpStr);
      Val(TmpStr,Period,Con[11]);
      {IF Korrektur THEN BEGIN
        ReadLn(f,Eccentricity,Eccentricity2);
      END ELSE}
      ReadLn(f,TmpStr);
      Val(TmpStr,Eccentricity,Con[12]);
      ReadLn(f,Method);
      ReadLn(f,DiscoveryDate);
      ReadLn(f,Discoverer);
      ReadLn(f,Remarks1);
      ReadLn(f,Remarks2);
      Close(f);
    END;
    IF StarMass < 0 THEN Starmass := 1.7e38;
    IF Distance < 0 THEN Distance := 1.7e38;
    IF PlanetMass < 0 THEN PlanetMass := 1.7e38;
    IF SemiMajorAxis < 0 THEN SemiMajorAxis := 1.7e38;
    IF Period < 0 THEN Period := 1.7e38;
    IF Eccentricity < 0 THEN Eccentricity := 1.7e38;
    IF Declination < -90 THEN Declination := 1.7e38;
    IF Declination > 90 THEN Declination := 1.7e38;
    IF Rectaszension < 0 THEN Rectaszension := 1.7e38;
    IF Rectaszension > 24 THEN Rectaszension := 1.7e38;
    IF Distance < 0 THEN Distance := 1.7e38;
    CASE Upcase(SpectralType[1]) OF
      'O' : Spec := 10;
      'B' : Spec := 20;
      'A' : Spec := 30;
      'F' : Spec := 40;
      'G' : Spec := 50;
      'K' : Spec := 60;
      'M' : Spec := 70;
      'L' : Spec := 80;
      'T' : Spec := 90;
       ELSE Spec := 100;
    END;
    Val(SpectralType[2],n,Con[0]);
    IF Con[0] <> 0 THEN n := 0;
    Spec := Spec+n;
    CASE UpCase(Spec2_Min[1]) OF
      'O' : Spec_Min := 10;
      'B' : Spec_Min := 20;
      'A' : Spec_Min := 30;
      'F' : Spec_Min := 40;
      'G' : Spec_Min := 50;
      'K' : Spec_Min := 60;
      'M' : Spec_Min := 70;
      'L' : Spec_Min := 80;
      'T' : Spec_Min := 90;
    END;
    Val(Spec2_Min[2],n,Con[0]);
    IF Con[0] <> 0 THEN n := 0;
    Spec_Min := Spec_Min+n;
    CASE UpCase(Spec2_Max[1]) OF
      'O' : Spec_Max := 10;
      'B' : Spec_Max := 20;
      'A' : Spec_Max := 30;
      'F' : Spec_Max := 40;
      'G' : Spec_Max := 50;
      'K' : Spec_Max := 60;
      'M' : Spec_Max := 70;
      'L' : Spec_Max := 80;
      'T' : Spec_Max := 90;
    END;
    Val(Spec2_Max[2],n,Con[0]);
    IF Con[0] <> 0 THEN n := 0;
    Spec_Max := Spec_Max+n;
    Val(DiscoveryDate,j2,Con[0]);
    IF (Con[0] = 0) AND (Con[1] = 0) AND (Con[2] = 0) AND (Con[3] = 0) AND
      (Con[4] = 0) AND (Con[5] = 0) AND (Con[6] = 0) AND (Con[7] = 0) AND
        (Con[8] = 0) AND (Con[9] = 0) AND (Con[10] = 0) AND (Con[11] = 0) AND
        (Con[12] = 0) THEN BEGIN
      IF ((j2 < j) AND (j2 > j3)) AND
        ((Spec_Min <= Spec) AND (Spec_Max >= Spec)) AND
          ((Magnitude >= Mag2_Min) AND (Magnitude <= Mag2_Max)) AND
           ((Starmass2_Min <= StarMass) AND (Starmass2_Max >= StarMass)) AND
             ((Metal2_Min <= Metalicity) AND (Metal2_Max >= Metalicity)) AND
               ((Dist2_Min <= Distance) AND (Dist2_Max >= Distance)) AND
                 ((Rec2_Min <= Rectaszension) AND (Rec2_Max >= Rectaszension)) AND
                   ((Dec2_Min <= Declination) AND (Dec2_Max >= Declination)) AND
                     ((PlanetMass2_Min <= PlanetMass) AND (PlanetMass2_Max >= PlanetMass)) AND
                       ((Axis2_Min <= SemiMajorAxis) AND (Axis2_Max >= SemiMajorAxis)) AND
                         ((Period2_Min <= Period) AND (Period2_Max >= Period)) AND
                           ((Ecc2_Min <= Eccentricity) AND (Ecc2_Max >= Eccentricity))
      THEN BEGIN
        Inc(ExoFileMax);
        ExoFile[ExoFileMax] := SearchFile.Name;
      END;
    END;
    FindNext(SearchFile);
  END;
  Dec(ExoFileMax,1);
END;

PROCEDURE ScanExoUpdate(n : Byte);
BEGIN
  ScanExoUpdate_Interface;
  IF FileExists('EXO\'+ExoFile[n]) THEN BEGIN
    Assign(f,'EXO\'+ExoFile[n]);
    ReadEXO;
  END;
  TextColor(LightGreen);
  FOR i := 1 TO 18 DO BEGIN
    IF i < 10 THEN GotoXY(05,2+24+(01+(i*2))) ELSE IF i > 9 THEN GotoXY(42,2+24+(03+((i-10)*2)));
    CASE i OF
      01 : IF Length(Centralstar) > 27 THEN FOR n := 1 TO 27 DO Write(Centralstar[n])
                                       ELSE Write(Centralstar);
      02 : IF Length(Spectraltype) > 27 THEN FOR n := 1 TO 27 DO Write(Spectraltype[n])
                                        ELSE Write(Spectraltype);
      03 : Write(Magnitude:0:3);
      04 : Write(StarMass:0:3);
      05 : Write(Metalicity:0:3);
      06 : Write(Distance:0:3);
      07 : Write(Rectaszension:0:3);
      08 : Write(Declination:0:3);
      09 : IF Length(Constellation) > 27 THEN FOR n := 1 TO 27 DO Write(Constellation[n])
                                         ELSE Write(Constellation);
      10 : IF Length(PlanetName) > 27 THEN FOR n := 1 TO 27 DO Write(PlanetName[n])
                                      ELSE Write(PlanetName);
      11 : Write(PlanetMass:0:3);
      12 : Write(SemiMajorAxis:0:3);
      13 : Write(Period:0:3);
      14 : Write(Eccentricity:0:3);
      15 : IF Length(Method) > 27 THEN FOR n := 1 TO 27 DO Write(Method[n])
                                  ELSE Write(Method);
      16 : Write('Jahr '+DiscoveryDate[1]+DiscoveryDate[2]+DiscoveryDate[3]+DiscoveryDate[4]+' Monat '+
           DiscoveryDate[5]+DiscoveryDate[6]+' Tag '+DiscoveryDate[7]+DiscoveryDate[8]);
      17 : IF Length(Discoverer) > 27 THEN FOR n := 1 TO 27 DO Write(Discoverer[n])
                                      ELSE Write(Discoverer);
    END;
    GotoXY(02+17,29+18);
    IF Length(Remarks1) > 2*27 THEN FOR n := 1 TO 2*27 DO Write(Remarks1[n]) ELSE Write(Remarks1);
    IF Remarks1 = '' THEN BEGIN
      TextColor(LightGray);
      Write('--- kein Kommentar angegeben ---');
      TextColor(LightGreen);
    END;
    GotoXY(02+17,29+19);
    IF Length(Remarks2) > 2*27 THEN FOR n := 1 TO 2*27 DO Write(Remarks2[n]) ELSE Write(Remarks2);
    IF Remarks2 = '' THEN BEGIN
      TextColor(LightGray);
      Write('--- kein Kommentar angegeben ---');
      TextColor(LightGreen);
    END;
   END;
  TextBackground(LightBlue);
  TextColor(White+Blink);
  GotoXY(54,20);
  Blank10;
  GotoXY(54,20);
  Write(n:3,' / ',ExoFileMax);
  GotoXY(65,20);
  TextBackground(Black);
  TextColor(White);
  Blank12;
  GotoXY(65,20);
  WriteLn(ExoFile[n]);
END;

PROCEDURE ScanExoInfo(n : Byte);
BEGIN
  IF FileExists('EXO\'+ExoFile[n]) THEN BEGIN
    Assign(f,'EXO\'+ExoFile[n]);
    ReadEXO;
  END;
END;

BEGIN
END.
