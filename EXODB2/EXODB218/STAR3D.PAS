PROGRAM Modul_Star3D;

USES Crt,Dos,Graph,Arithmos,RT_Watch,Basic,BmpLoad,BGI2PRN,ConstVar,Image,Scan_EXO;

VAR
  Color           : Byte;
  Input,Swap,
  Temp1,Temp2     : Char;
  x,y             : Integer;
  a,p,e,b,c,pc,t,
  Parsec_Min,
  Parsec_Max      : Real;
  Magnitude2,
  Spec_Min,
  Spec_Max,
  Object_Centered,
  SpectralType    : STRING;
  Str4            : STRING[4];
  Str41           : STRING[41];
  Spec3           : STRING[10];
  SpecR_Min,
  SpecR_Max,
  x2,y2,z2,rv     : Real;

PROCEDURE ReadEXO2;
BEGIN
  Reset(f);
  ReadLn(f,Centralstar);
  ReadLn(f,SpectralType);
  ReadLn(f,Magnitude);
  ReadLn(f,StarMass);
  ReadLn(f,Metalicity);
  ReadLn(f,Distance);
  ReadLn(f,Rectaszension);
  ReadLn(f,Declination);
  ReadLn(f,Constellation);
  ReadLn(f,PlanetName);
  ReadLn(f,PlanetMass);
  ReadLn(f,SemiMajorAxis);
  ReadLn(f,Period);
  ReadLn(f,Eccentricity);
  ReadLn(f,Method);
  ReadLn(f,DiscoveryDate);
  ReadLn(f,Discoverer);
  {ReadLn(f,Remark1);
  ReadLn(f,Remark2);}
  {Notizen, Kommentare usw. werden nicht mitgelesen!!!}
  Close(f);
END;

PROCEDURE GetStar3DOptions;
BEGIN
  { --- Einstellungen von STAR3D aus der Datei STAR3D.CMD ermitteln --- }
  Assign(f3,'star3d.cmd');
  Reset(f3);
  WITH Star3DOption DO BEGIN
    ReadLn(f3,ZoomFactor);
    ReadLn(f3,MidPointShiftX);
    ReadLn(f3,MidPointShiftY);
    ReadLn(f3,SpectraltypeMin);
    ReadLn(f3,SpectraltypeMax);
    ReadLn(f3,Reserved1);
    ReadLn(f3,Reserved2);
    ReadLn(f3,Reserved3);
    ReadLn(f3,Reserved4);
    ReadLn(f3,Reserved5);
    ReadLn(f3,Reserved6);
    ReadLn(f3,NumberOfEntrys);
    FOR i := 1 TO NumberOfEntrys DO ReadLn(f3,ModulFileEntrys[i]);
    Close(f3);
    {IF Magnification = 1 THEN Zoom := 7;}
    FOR i := 1 TO NumberOfEntrys DO BEGIN
      IF NOT(FileExists('EXO/'+ModulFileEntrys[i])) THEN BEGIN
        ClrScr;
        WriteLn(^j^j'Die Datei "','EXO/'+ModulFileEntrys[i],'" wurde nicht gefunden!');
        WriteLn(^j'Achten Sie darauf, dass die DatensÑtze im Verzeichnis "EXO"');
        WriteLn('des Hauptverzeichis liegen.');
        ReadKey;
        Halt;
      END;
    END;
  END;
END;

PROCEDURE CheckLSTFiles;
BEGIN
  { --- öberprÅft, ob alle LST-Dateien vorhanden sind --- }
  IF NOT(FileExists('stars3.lst')) THEN BEGIN
    WriteLn; WriteLn;
    WriteLn('Die Datei "stars3.lst" wurde nicht gefunden!');
    WriteLn('Sie ist fÅr die Darstellung der Sterne wichtig.');
    ReadKey;
  END;
END;

PROCEDURE SaveScreen;
BEGIN
  { --- Bildschirm in eine Datei speichern --- }
  TempStr[0] := '';
  FOR i := 1 TO Length(ModulFileEntrys[1])-4 DO BEGIN
    TempStr[0] := TempStr[0]+ModulFileEntrys[1][i];
  END;
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
  OutTextXY(360,210,TempStr[0]);
  SetColor(White);
  OutTextXY(270,230,'1 - Format PCX');
  OutTextXY(270,240,'2 - Format BMP');
  OutTextXY(270,250,'0 - Abbruch');
  REPEAT
    Input2 := ReadKey;
  UNTIL Input2 IN ['0','1','2'];
  LoadImage(0+200,0+200,'image.tmp');
  IF NOT(DirExists('STAR3D')) THEN MkDir('STAR3D');
  CASE Input2 OF
    '0' : Exit;
    '1' : SavePCX('STAR3D/'+TempStr[0]+'.PCX');
    '2' : SaveBMP('STAR3D/'+TempStr[0]);
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

PROCEDURE SetLegend;
BEGIN
  { --- Legende setzen --- }
  SetColor(White);
  Circle(600,50,20);
  Line(600,30,600,70);
  Line(580,50,620,50);
  SetTextStyle(2,0,5);
  OuttextXY(545,0,'Orientierung');
  SetTextStyle(2,0,4);
  OuttextXY(570,83,'Draufsicht');
  OuttextXY(625,45,'0¯');
  OuttextXY(595,17,'90¯');
  OuttextXY(555,45,'180¯');
  OuttextXY(590,73,'270¯');
END;

PROCEDURE SetAllStars;
BEGIN
  { --- Alle Sterne anzeigen --- }
  Assign(f2,'stars3.lst');
  Reset(f2);
  ReadLn(f2);
  REPEAT
    Read(f2,Str41);
    Read(f2,x2);
    Read(f2,y2);
    Read(f2,z2);
    Read(f2,Str4);
    Read(f2,Spec3);
    Read(f2,t);
    Read(f2,t);
    Read(f2,pc);
    ReadLn(f2);
    Str(pc,Str4);
    CASE Star3DOption.SpectraltypeMin[1] OF
      'O' : SpecR_Min := 10;
      'B' : SpecR_Min := 20;
      'A' : SpecR_Min := 30;
      'G' : SpecR_Min := 40;
      'F' : SpecR_Min := 50;
      'K' : SpecR_Min := 60;
      'M' : SpecR_Min := 70;
      'L' : SpecR_Min := 80;
      'T' : SpecR_Min := 90;
    END;
    CASE Star3DOption.SpectraltypeMax[1] OF
      'O' : SpecR_Max := 10;
      'B' : SpecR_Max := 20;
      'A' : SpecR_Max := 30;
      'G' : SpecR_Max := 40;
      'F' : SpecR_Max := 50;
      'K' : SpecR_Max := 60;
      'M' : SpecR_Max := 70;
      'L' : SpecR_Max := 80;
      'T' : SpecR_Max := 90;
    END;
    CASE Spec3[3] OF
      'O' : IF (SpecR_Min <= 10) AND ((SpecR_Max >= 10)) THEN Color := Cyan ELSE Color := Black;
      'B' : IF (SpecR_Min <= 20) AND ((SpecR_Max >= 20)) THEN Color := White ELSE Color := Black;
      'A' : IF (SpecR_Min <= 30) AND ((SpecR_Max >= 30)) THEN Color := White ELSE Color := Black;
      'G' : IF (SpecR_Min <= 40) AND ((SpecR_Max >= 40)) THEN Color := Yellow ELSE Color := Black;
      'F' : IF (SpecR_Min <= 50) AND ((SpecR_Max >= 50)) THEN Color := Yellow ELSE Color := Black;
      'K' : IF (SpecR_Min <= 60) AND ((SpecR_Max >= 60)) THEN Color := Brown ELSE Color := Black;
      'M' : IF (SpecR_Min <= 70) AND ((SpecR_Max >= 70)) THEN Color := Red ELSE Color := Black;
      'L' : IF (SpecR_Min <= 80) AND ((SpecR_Max >= 80)) THEN Color := Red ELSE Color := Black;
      'T' : IF (SpecR_Min <= 90) AND ((SpecR_Max >= 90)) THEN Color := Red ELSE Color := Black;
      ELSE Color := Black;
    END;
    IF z2 <> 0 THEN x2 := x2/z2;
    IF z2 <> 0 THEN y2 := y2/z2;
    PutPixel(320-Round(x2*Star3DOption.ZoomFactor)+Round(Star3DOption.MidPointShiftX),
      240-Round(y2*Star3DOption.ZoomFactor)+Round(Star3DOption.MidPointShiftY),Color);
  UNTIL EoF(f2);
  Close(f2);
END;


PROCEDURE SetEntry;
BEGIN
  { --- Zentralstern setzen --- }
  Circle(320+Round(Star3DOption.MidPointShiftX),240+Round(Star3DOption.MidPointShiftY),2);
  SetTextStyle(2,0,4);
  OutTextXY(325+Round(Star3DOption.MidPointShiftX),230+Round(Star3DOption.MidPointShiftY),'Sol');
  FOR i := 1 TO Star3DOption.NumberOfEntrys DO BEGIN
    Assign(f,'EXO/'+ModulFileEntrys[i]);
    ReadEXO2;
    Trigonomodus(deg);
    x2 := Distance*Cos(Declination)*Cos(Rectaszension);
    y2 := Distance*Cos(Declination)*Sin(Rectaszension);
    z2 := Distance*Sin(Declination);
    IF z2 <> 0 THEN x2 := x2/z2;
    IF z2 <> 0 THEN y2 := y2/z2;
    CASE SpectralType[1] OF
      'O'         : Color := Cyan;
      'B','A'     : Color := White;
      'G','F'     : Color := Yellow;
      'K'         : Color := Brown;
      'M','L','T' : Color := Red;
       ELSE Color := Black;
    END;
    SetColor(Color);
    Circle(320-Round(x2*Star3DOption.ZoomFactor)+Round(Star3DOption.MidPointShiftX),
      240-Round(y2*Star3DOption.ZoomFactor)+Round(Star3DOption.MidPointShiftY),2);
    SetTextStyle(2,0,4);
    OutTextXY(325-Round(x2*Star3DOption.ZoomFactor)+Round(Star3DOption.MidPointShiftX),
      230-Round(y2*Star3DOption.ZoomFactor)+Round(Star3DOption.MidPointShiftY),Centralstar);
    SetTextStyle(2,0,5);
    SetColor(White);
    Str(Distance:0:3,Str4);
    OutTextXY(5,420+(10*Star3DOption.NumberOfEntrys),Centralstar+': '+Str4+' Parsec');
  END;
  SetColor(15);
  SetTextStyle(2,0,4);
  OutTextXY(10,2,ID);
END;

BEGIN
  Randomize;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  InitStar3DOptions;
  TextBackground(Black);
  TextColor(White);
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF NOT(FileExists('STAR3D.CMD')) THEN BEGIN
    ClrScr;
    WriteLn(^j^j'Die Datei "STAR3D.CMD" wurde nicht gefunden!');
    ReadKey;
    Halt;
  END;
  GetStar3DOptions;
  ClrScr;
  CheckLSTFiles;
  grDriver := Detect;
  InitGraph(grDriver,grMode,'');
  REPEAT
    SetAllStars;
    SetLegend;
    SetEntry;
    Input := Readkey;
    IF UpCase(Input) = 'S' THEN SaveScreen;
    IF UpCase(Input) = 'P' THEN GraftoPrint;
  UNTIL Input <> '';
END.



PROCEDURE SearchDir(Path : PathStr; fspec : STRING);
VAR
  find : SearchRec;
BEGIN
  FindFirst(Path+fspec,AnyFile,find);
  WHILE DosError = 0 DO BEGIN
    Inc(i);
    Assign(f,'exo\'+find.name);
    ReadEXO2;
    CASE SpectralType[1] OF
      'O' : x := 020*2;
      'B' : x := 039*2;
      'A' : x := 063*2;
      'F' : x := 090*2;
      'G' : x := 115*2;
      'K' : x := 140*2;
      'M' : x := 165*2;
    END;
    CASE SpectralType[2] OF
      '0' : x := x+Round(((20*2)/10)+2*0);
      '1' : x := x+Round(((20*2)/10)+2*2.6);
      '2' : x := x+Round(((20*2)/10)+2*5.2);
      '3' : x := x+Round(((20*2)/10)+2*7.8);
      '4' : x := x+Round(((20*2)/10)+2*10.4);
      '5' : x := x+Round(((20*2)/10)+2*13);
      '6' : x := x+Round(((20*2)/10)+2*15.6);
      '7' : x := x+Round(((20*2)/10)+2*18.2);
      '8' : x := x+Round(((20*2)/10)+2*20.8);
      '9' : x := x+Round(((20*2)/10)+2*23.4);
    END;
    PutPixel(20+x,64+Round((((Magnitude*38))+200)/2.1),14);
    PutPixel(20+x,65+Round((((Magnitude*38))+200)/2.1),14);
    PutPixel(20+x,63+Round((((Magnitude*38))+200)/2.1),14);
    PutPixel(21+x,64+Round((((Magnitude*38))+200)/2.1),14);
    PutPixel(19+x,64+Round((((Magnitude*38))+200)/2.1),14);
    SetColor(14);
    Circle(20+x,64+Round((((Magnitude*38))+200)/2.1),5);
    Circle(20+x,64+Round((((Magnitude*38))+200)/2.1),6);
    Str(Magnitude:0:2,Magnitude2);
    SetColor(13);
    OutTextXY(410,70+(10*i),CentralStar);
    SetColor(15);
    OutTextXY(555,70+(10*i),Magnitude2);
    SetColor(12);
    OutTextXY(595,70+(10*i),SpectralType);
    Findnext(find);
  END;
END;

PROCEDURE SearchDir2(Path : PathStr; fspec : STRING);
VAR
  find  : SearchRec;
  w     : Word;
  w2    : STRING;
BEGIN
  IF NOT(DirExists('STAR3D')) THEN MkDir('STAR3D');
  FindFirst(Path+fspec,AnyFile,find);
  SetTextStyle(2,0,4);
  OutTextXY(325+Round(MX),230+Round(MY),'Sol');
  WHILE DosError = 0 DO BEGIN
    Assign(f,'exo\'+find.name);
    ReadEXO2;
    {ClearDevice;}
    Trigonomodus(deg);
    x2 := Distance*Cos(Declination)*Cos(Rectaszension);
    y2 := Distance*Cos(Declination)*Sin(Rectaszension);
    z2 := Distance*Sin(Declination);
    IF z2 <> 0 THEN x2 := x2/z2;
    IF z2 <> 0 THEN y2 := y2/z2;
    CASE SpectralType[1] OF
      'O'         : Color := Cyan;
      'B','A'     : Color := White;
      'G','F'     : Color := Yellow;
      'K'         : Color := Brown;
      'M','L','T' : Color := Red;
      ELSE Color := Black;
    END;
    SetColor(Color);
    Circle(320-Round(x2*Zoom)+Round(MX),240-Round(y2*Zoom)+Round(MY),2);
    SetTextStyle(2,0,4);
    OutTextXY(325-Round(x2*Zoom)+Round(MX),230-Round(y2*Zoom)+Round(MY),Centralstar);
    SetTextStyle(2,0,5);
    SetColor(White);
    Str(Distance:0:3,Str4);
    OutTextXY(5,420+(10*Round(Numb)),Centralstar+': '+Str4+' Parsec');
    SetColor(15);
    SetTextStyle(2,0,4);
    OutTextXY(10,2,ID);
    Fil[0] := '';
    FOR i := 1 TO Length(find.name)-4 DO BEGIN
      Fil[0] := Fil[0]+find.name[i];
    END;
    SavePCX('STAR3D/'+Fil[0]+'.PCX');
    SetTextStyle(2,0,4);
    SetColor(White);
    Circle(320+Round(MX),240+Round(MY),2);
    OutTextXY(325+Round(MX),230+Round(MY),'Sol');
    SetColor(Black);
    Circle(320-Round(x2*Zoom)+Round(MX),240-Round(y2*Zoom)+Round(MY),2);
    SetTextStyle(2,0,4);
    OutTextXY(325-Round(x2*Zoom)+Round(MX),230-Round(y2*Zoom)+Round(MY),Centralstar);
    SetColor(White);
    Circle(600,50,20);
    Line(600,30,600,70);
    Line(580,50,620,50);
    SetTextStyle(2,0,5);
    OuttextXY(545,0,'Orientierung');
    SetTextStyle(2,0,4);
    OuttextXY(570,83,'Draufsicht');
    OuttextXY(625,45,'0¯');
    OuttextXY(595,17,'90¯');
    OuttextXY(555,45,'180¯');
    OuttextXY(590,73,'270¯');
    SetTextStyle(2,0,5);
    SetColor(Black);
    OutTextXY(5,420+(10*Round(Numb)),Centralstar+': '+Str4+' Parsec');
    Findnext(find);
  END;
END;

