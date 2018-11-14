UNIT ConstVar;

INTERFACE

USES Crt,Dos,Graph,Cursor,RT_Watch;

CONST
  MaxReadFile = 1000;
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
  OK = '  OK  ';
  YES = '  JA  ';
  NO = ' NEIN ';

VAR
  Fil             : ARRAY[0..20] OF STRING;
  ExoFile         : ARRAY[0..MaxReadFile] OF STRING[12];
  Exit2,Korrektur,
  Found           : Boolean;
  NotDouble       : Byte;
  Input,Input2,HZ : Char;
  LPT,j,m,t,m2,t2,
  ExoFileMax,
  ExoFileStd,
  ecc_T1,ecc_T2,ecc_T3,ecc_T4,
  ma1,ma2,ma3,ma4,ma5,
  Spec0,Spec1,Spec2,Spec3,Spec4,Spec5,Spec6,
  Zoom,Numb,n,i,b,
  mx,my,Numb3,Con : Integer;
  FileHandle      : FILE;
  SearchFile      : SearchRec;
  Input2Str       : STRING;
  f,f2            : Text;
  mx2,my2,Numb2,
  Zoom2,Numb4,Numb5,
  Numb6,Numb7,Numb8,
  j0,j3,m3,t3,j4,m4,t4,
  Date,Date2,
  TempStr,
  CentralStar,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Method,
  PlanetName,
  Remarks,
  SearchStr,
  SpectralType,
  Spec2_Min,Spec2_Max,
{cc  Centralstar3,
  SpectralType3,
  Magnitude3,
  StarMass3,
  Metalicity3,
  Distance3,
  Rectaszension3,
  Deklination3,
  Constellation3,
  PlanetName3,
  PlanetMass3,
  SemiMajorAxis3,
  Period3,
  Eccentricity3,
  Method3,
  DiscoveryDate3,
  Discoverer3,}
  Remarks3 : STRING;
  SpecStr3_1,SpecStr3_2,SpecStr3_3 : STRING[3];
  Axis_Min,Axis_Max,
  Date_Min,Date_Max,
  Ecc_Min,Ecc_Max,
  Mass_Min,Mass_Max,
  StarMass_Min,StarMass_Max,
  Distance_Min,Distance_Max,
  Spec,Spec_Min,Spec_Max,
  Mag_Min,Mag_Max,
  j5,j6,j7,
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
END.
