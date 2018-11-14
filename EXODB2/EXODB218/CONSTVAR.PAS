UNIT ConstVar;

INTERFACE

USES Crt,Dos,Graph,Cursor,RT_Watch;

CONST
  MaxReadFile = 1000;        {Maximale Anzahl aller lesbaren Dateien}
  NULL  = Chr(00);           {Symbol fÅr Null}
  TAB   = Chr(09);           {Symbol fÅr Tabulatortaste}
  ENTER = Chr(13);           {Symbol fÅr Eingabetaste}
  ESC   = Chr(27);           {Symbol fÅr Escape-Taste}
  SPACE = Chr(32);           {Symbol fÅr Leertaste}
  ARUP  = 'H';               {Symbol fÅr Pfeil oben}
  ARDN  = 'P';               {Symbol fÅr Pfeil unten}
  ARLF  = 'K';               {Symbol fÅr Pfeil links}
  ARRT  = 'M';               {Symbol fÅr Pfeil rechts}
  PGUP  = 'I';               {Symbol fÅr Bildauf}
  PGDN  = 'Q';               {Symbol fÅr Bildab}
  POS1  = 'G';               {Symbol fÅr POS-Taste}
  END1  = 'O';               {Symbol fÅr END-Taste}
  EINFG = 'R';               {Symbol fÅr EinfÅge-Taste}
  ENTF  = 'S';               {Symbol fÅr Entfern-Taste}
  FileBufferSize = 32768;
  OK = '  OK  ';             {Zeichenkette fÅr OK-Button}
  YES = '  JA  ';            {Zeichenkette fÅr JA-Button}
  NO = ' NEIN ';             {Zeichenkette fÅr NEIN-Button}
  ID = '(C) 1995-2006 EXO-DB2 1.8 * Michael Johne * http://www.exodb.de.vu';

TYPE
  FourthDim = RECORD
    Year1,Year2,
    Month1,Month2,
    Day1,Day2,
    Dow1,Dow2,
    Hour1,Hour2,
    Min1,Min2,
    Sek1,Sek2,
    MSek1,MSek2  : Word;
    Time,Time2 : Real;
    TimeStr,
    DateStr,
    YearStr,
    MonthStr,
    DayStr   : STRING;
  END;

VAR
  DiagramOption : RECORD
    ArtOfFigure,
    Reserved1,
    Reserved2,
    Reserved3,
    NumberOfEntrys        : Integer;
  END;
  DistributionOption : RECORD
    ArtOfFigure,
    Cumulative,
    Reserved1,
    Reserved2,
    NumberOfEntrys        : Integer;
  END;
  HRDOption : RECORD
    Reserved1,
    Reserved2,
    Reserved3,
    Reserved4,
    NumberOfEntrys        : Integer;
  END;
  MassOption : RECORD
    Reserved1,
    Reserved2,
    Reserved3,
    Reserved4,
    NumberOfEntrys        : Integer;
  END;
  OrbitOption : RECORD
    ZoomFactor,
    MidPointShiftX,
    MidPointShiftY,
    HabilitableZone,
    Reserved1,
    Reserved2,
    Reserved3,
    Reserved4,
    Reserved5,
    Reserved6,
    Reserved7,
    NumberOfEntrys        : Integer;
  END;
  Star3DOption : RECORD
    ZoomFactor,
    MidPointShiftX,
    MidPointShiftY        : Integer;
    SpectraltypeMin,
    SpectraltypeMax       : STRING[10];
    Reserved1,
    Reserved2,
    Reserved3,
    Reserved4,
    Reserved5,
    Reserved6,
    NumberOfEntrys        : Integer;
  END;
  StarmapOption : RECORD
    Magnification,
    GridLines,
    Ecliptic,
    ConstellationBorder,
    ConstellationLines,
    ConstellationNames,
    Starnames,
    StarCatalogue,
    Milkyway,
    Reserved1,
    Reserved2,
    NumberOfEntrys        : Integer;
  END;
  DateTime        : FourthDim;
  CharArray       : ARRAY[0..10] OF Char;
  Coordinates     : ARRAY[0..10] OF Real;
  TempStr         : ARRAY[0..10] OF STRING;
  Fil             : ARRAY[0..20] OF STRING;
  ExoFile,
  ModulFileEntrys : ARRAY[0..MaxReadFile] OF STRING[12];
  Exit2,Korrektur,
  Splash,
  Found           : Boolean;
  NotDouble       : Byte;
  Input,Input2,HZ : Char;
  LPT,j,m,t,m2,t2,
  Control,
  grDriver,grMode,
  ExoFileMax,
  ExoFileStd,
  ecc_T1,ecc_T2,ecc_T3,ecc_T4,
  ma1,ma2,ma3,ma4,ma5,
  Spec0,Spec1,Spec2,Spec3,Spec4,Spec5,Spec6,
  Zoom,Numb,n,i,b,GraphDriver,GraphMode,
  mx,my,Numb3,Con : Integer;
  FileHandle      : FILE;
  SearchFile      : SearchRec;
  Input2Str       : STRING;
  f,{fÅr EXO-DatensÑtze}
  f2,{fÅr EXE-Dateien}
  f3{fÅr CMD-Dateien} : Text;
  mx2,my2,Numb2,
  Zoom2,Numb4,Numb5,
  Numb6,Numb7,Numb8,
  j0,j3,m3,t3,j4,m4,t4,
  Date,Date2,
  CentralStar,
  Declination2,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Method,
  PlanetName,
  Rectaszension2,
  Remarks1,
  Remarks2,
  SearchStr,
  SpectralType,
  Spec2_Min,Spec2_Max,
  Remarks3 : STRING;
  SpecStr3_3 : STRING[3];
  Axis_Min,Axis_Max,
  Date_Min,Date_Max,
  Ecc_Min,Ecc_Max,
  Mass_Min,Mass_Max,
  StarMass_Min,StarMass_Max,
  Distance_Min,Distance_Max,
  Spec,Spec_Min,Spec_Max,
  Mag_Min,Mag_Max,
  j5,j6,j7,
  a,p,e,x,y,x2,y2,
  SearchReal,
  Declination,
  Dec2,
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
  Rec2,
  SemiMajorAxis,
  SemiMajorAxis2,
  StarMass,
  Mag2_Min,Mag2_Max,
  StarMass2_Min,StarMass2_Max,
  Metal2_Min,Metal2_Max,
  Dist2_Min,Dist2_Max,
  Rec2_Min,Rec2_Max,
  Dec2_Min,Dec2_Max,
  PlanetMass2_Min,PlanetMass2_Max,
  Axis2_Min,Axis2_Max,
  Period2_Min,Period2_Max,
  Ecc2_Min,Ecc2_Max,NumbR : Real;
  Index                   : Word;


IMPLEMENTATION

BEGIN
  Spec2_Min := 'O';
  Spec2_Max := 'T';
  Mag2_Min := -10;
  Mag2_Max := 50;
  StarMass2_Min := -0.000001;
  StarMass2_Max := 10;
  Metal2_Min := -3;
  Metal2_Max := 3;
  Dist2_Min := -0.000001;
  Dist2_Max := 50000;
  Rec2_Min := -0.000001;
  Rec2_Max := 24;
  Dec2_Min := -90;
  Dec2_Max := 90;
  PlanetMass2_Min := -0.000001;
  PlanetMass2_Max := 30;
  Axis2_Min := -0.000001;
  Axis2_Max := 300;
  Period2_Min := -0.000001;
  Period2_Max := 2000000;
  Ecc2_Min := -0.000001;
  Ecc2_Max := 1;
  j3 := '19800101'; {01.01.1980}
  j4 := '20100101'; {01.01.2010}
END.
