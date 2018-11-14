PROGRAM Modul_Starmap;

USES Crt,Dos,Graph,Arithmos,Basic,BGI2PRN,ConstVar,Image,RT_Watch,Scan_Exo;

VAR
  Zoom : Real;

PROCEDURE RD_Correction;
BEGIN
  { --- Umrechung, Entspiegelung und Korrektur -> Anpassung am Bildschirm --- }
  Rectaszension := 10*Rectaszension;
  Rectaszension := (Rectaszension*360)/240;
  Rectaszension := 360-Rectaszension;
  Declination   := -(Declination)+90;
END;

PROCEDURE GetStarmapOptions;
BEGIN
  { --- Einstellungen von STARMAP aus der Datei STARMAP.CMD ermitteln --- }
  Assign(f3,'starmap.cmd');
  Reset(f3);
  WITH StarmapOption DO BEGIN
    ReadLn(f3,Magnification);
    ReadLn(f3,GridLines);
    ReadLn(f3,Ecliptic);
    ReadLn(f3,ConstellationBorder);
    ReadLn(f3,ConstellationLines);
    ReadLn(f3,ConstellationNames);
    ReadLn(f3,Starnames);
    ReadLn(f3,StarCatalogue);
    ReadLn(f3,Milkyway);
    ReadLn(f3,Reserved1);
    ReadLn(f3,Reserved2);
    ReadLn(f3,NumberOfEntrys);
    FOR i := 1 TO NumberOfEntrys DO ReadLn(f3,ModulFileEntrys[i]);
    Close(f3);
    IF Magnification = 1 THEN Zoom := 7;
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
  IF NOT(FileExists('stars.lst')) THEN BEGIN
    WriteLn; WriteLn;
    WriteLn('Die Datei "stars.lst" wurde nicht gefunden!');
    WriteLn('Sie ist fÅr die Darstellung der Sterne wichtig.');
    ReadKey;
  END;
  IF NOT(FileExists('stars2.lst')) THEN BEGIN
    WriteLn; WriteLn;
    WriteLn('Die Datei "stars2.lst" wurde nicht gefunden!');
    WriteLn('Sie ist fÅr die Darstellung der Sterne bei Vergrîsserung wichtig.');
    ReadKey;
  END;
  IF NOT(FileExists('clines.lst')) THEN BEGIN
    WriteLn; WriteLn;
    WriteLn('Die Datei "clines.lst" wurde nicht gefunden!');
    WriteLn('Sie ist fÅr die Darstellung der Sternbilder wichtig.');
    ReadKey;
  END;
  IF NOT(FileExists('eclip.lst')) THEN BEGIN
    WriteLn; WriteLn;
    WriteLn('Die Datei "eclip.lst" wurde nicht gefunden!');
    WriteLn('Sie ist fÅr die Darstellung der Ekliptik wichtig.');
    ReadKey;
  END;
  IF NOT(FileExists('cnames.lst')) THEN BEGIN
    WriteLn; WriteLn;
    WriteLn('Die Datei "cnames.lst" wurde nicht gefunden!');
    WriteLn('Sie ist fÅr die Benennung der Sternbilder wichtig.');
    ReadKey;
  END;
  IF NOT(FileExists('starname.lst')) THEN BEGIN
    WriteLn; WriteLn;
    WriteLn('Die Datei "starname.lst" wurde nicht gefunden!');
    WriteLn('Sie ist fÅr die Benennung der Sterne wichtig.');
    ReadKey;
  END;
  IF NOT(FileExists('cbounds.lst')) THEN BEGIN
    WriteLn; WriteLn;
    WriteLn('Die Datei "cbounds.lst" wurde nicht gefunden!');
    WriteLn('Sie ist fÅr die Darstellung der Sternbilder wichtig.');
    ReadKey;
  END;
END;

PROCEDURE SetBlueSky;
BEGIN
  { --- blauen Himmel-Hintergrund setzen --- }
  SetFillStyle(SolidFill,Blue);
  Bar(0,0,Round(Zoom*360),Round(Zoom*180));
  SetFillStyle(SolidFill,Yellow);
END;

PROCEDURE SetGridlines;
BEGIN
  { --- Gradnetz setzen --- }
  SetColor(Black);
  SetLineStyle(1,0,1);
  Line(0,Round((Zoom*180)),Round(Zoom*360),Round((Zoom*180)));
  Line(0,Round(Zoom*(180-30)),Round(Zoom*360),Round(Zoom*(180-30)));
  Line(0,Round(Zoom*(180-60)),Round(Zoom*360),Round(Zoom*(180-60)));
  Line(0,Round(Zoom*(180-90)),Round(Zoom*360),Round(Zoom*(180-90)));
  Line(0,Round(Zoom*(180-120)),Round(Zoom*360),Round(Zoom*(180-120)));
  Line(0,Round(Zoom*(180-150)),Round(Zoom*360),Round(Zoom*(180-150)));
  Line(0,Round(Zoom*(180-180)),Round(Zoom*360),Round(Zoom*(180-180)));
  Line(Round(Zoom*0),0,Round(Zoom*0),Round(Zoom*180));
  Line(Round(Zoom*60),0,Round(Zoom*60),Round(Zoom*180));
  Line(Round(Zoom*120),0,Round(Zoom*120),Round(Zoom*180));
  Line(Round(Zoom*180),0,Round(Zoom*180),Round(Zoom*180));
  Line(Round(Zoom*240),0,Round(Zoom*240),Round(Zoom*180));
  Line(Round(Zoom*300),0,Round(Zoom*300),Round(Zoom*180));
  Line(Round(Zoom*360),0,Round(Zoom*360),Round(Zoom*180));
  SetTextStyle(2,0,4);
  SetColor(White);
  OutTextXY(Round(Zoom*361),Round((Zoom*(0-2))),'+90¯');
  OutTextXY(Round(Zoom*361),Round((Zoom*(30-2))),'+60¯');
  OutTextXY(Round(Zoom*361),Round((Zoom*(60-2))),'+30¯');
  OutTextXY(Round(Zoom*361),Round((Zoom*(90-2))),'  0¯');
  OutTextXY(Round(Zoom*361),Round((Zoom*(120-2))),'-30¯');
  OutTextXY(Round(Zoom*361),Round((Zoom*(150-2))),'-60¯');
  OutTextXY(Round(Zoom*361),Round((Zoom*(180-2))),'-90¯');
  OuttextXY(Round(Zoom*0),Round(Zoom*180),'24h');
  OuttextXY(Round(Zoom*60),Round(Zoom*180),'20h');
  OuttextXY(Round(Zoom*120),Round(Zoom*180),'16h');
  OuttextXY(Round(Zoom*180),Round(Zoom*180),'12h');
  OuttextXY(Round(Zoom*240),Round(Zoom*180),'8h');
  OuttextXY(Round(Zoom*300),Round(Zoom*180),'4h');
  OuttextXY(Round(Zoom*360),Round(Zoom*185),'0h');
  SetLineStyle(0,0,1);
END;

PROCEDURE SetEcliptic;
BEGIN
  { --- Elkiptik und HimmelsÑquator setzen --- }
  SetLineStyle(0,0,1);
  SetColor(Green);
  Line(0,Round((Zoom*180)/2),Round(Zoom*360),Round((Zoom*180)/2));
  SetColor(Cyan);
  IF FileExists('eclip.lst') THEN BEGIN
    Assign(f,'eclip.lst');
    Reset(f);
    Rectaszension := 0;
    Declination   := 0;
    RD_Correction;
    MoveTo(Round(Zoom*Rectaszension+x),Round(Zoom*Declination+y));
    REPEAT
      Read(f,Rectaszension);
      ReadLn(f,Declination);
      RD_Correction;
      LineTo(Round(Zoom*Rectaszension+x),Round(Zoom*Declination+y));
    UNTIL EoF(f);
    Close(f);
  END;
END;

PROCEDURE SetConstellationLines;
BEGIN
  {Sternbilder-Linien setzen}
  SetColor(DarkGray);
  IF FileExists('clines.lst') THEN BEGIN
    Assign(f,'clines.lst');
    Reset(f);
    REPEAT
      ReadLn(f,Numb);
      FOR i := 1 TO 6 DO Read(f,Coordinates[i]);
      ReadLn(f);
      Rectaszension := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
      Declination   := Coordinates[4]+(Coordinates[5]/60)+(Coordinates[6]/3600);
      RD_Correction;
      MoveTo(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)));
      FOR n := 1 TO Numb-1 DO BEGIN
        FOR i := 1 TO 6 DO Read(f,Coordinates[i]);
        ReadLn(f);
        Rectaszension := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
        Declination   := Coordinates[4]+(Coordinates[5]/60)+(Coordinates[6]/3600);
        RD_Correction;
        LineTo(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)));
      END;
    UNTIL EoF(f);
    Close(f);
  END;
END;

PROCEDURE SetConstellationBorder;
BEGIN
  { --- Sternbilder-Begrenzung setzen --- }
  SetColor(LightBlue);
  IF FileExists('cbounds.lst') THEN BEGIN
    Assign(f,'cbounds.lst');
    Reset(f);
    REPEAT
    FOR i := 1 TO 3 DO Read(f,Coordinates[i]);
    ReadLn(f);
    Rectaszension := Coordinates[2]/1000;
    Declination := Coordinates[3]/100;
    RD_Correction;
    IF Coordinates[1] = 0 THEN MoveTo(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)))
      ELSE IF Coordinates[1] = 1 THEN LineTo(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)));
    UNTIL EoF(f);
    Close(f);
  END;
END;

PROCEDURE SetConstellationNames;
BEGIN
  { --- Sternbilder-Bezeichnungen setzen --- }
  SetTextStyle(2,0,5);
  SetColor(Yellow);
  IF FileExists('cnames.lst') THEN BEGIN
    Assign(f,'cnames.lst');
    Reset(f);
    REPEAT
      Read(f,Coordinates[1]);
      ReadLn(f,Coordinates[2]);
      FOR i := 1 TO 6 DO ReadLn(f,TempStr[i]);
      Rectaszension := Coordinates[1]/1000;
      Declination := Coordinates[2]/100;
      RD_Correction;
      OutTextXY(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)),TempStr[StarmapOption.ConstellationNames]);
    UNTIL EoF(f);
    Close(f);
  END;
END;

PROCEDURE SetStarnames;
BEGIN
  { --- Sternnamen setzen --- }
  SetTextStyle(2,0,4);
  SetColor(White);
  IF FileExists('starname.lst') THEN BEGIN
    Assign(f,'starname.lst');
    Reset(f);
    REPEAT
      FOR i := 1 TO 6 DO Read(f,Coordinates[i]);
      Read(f,TempStr[0]);
      ReadLn(f);
      Rectaszension := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
      Declination   := Coordinates[4]+(Coordinates[5]/60)+(Round(Coordinates[6])/3600);
      RD_Correction;
      OutTextXY(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)),TempStr[0]);
    UNTIL EoF(f);
    Close(f);
  END;
END;

PROCEDURE SetStarCatalogue;
BEGIN
  { --- Sternkatalog setzen --- }
  IF (StarmapOption.Magnification = 0) THEN TempStr[0] := 'stars.lst'
  ELSE IF (StarmapOption.Magnification = 1) THEN BEGIN
    IF (StarmapOption.StarCatalogue = 1) THEN TempStr[0] := 'stars2.lst'
    ELSE IF (StarmapOption.StarCatalogue = 2) THEN TempStr[0] := 'stars2hp.lst';
  END;
  IF FileExists(TempStr[0]) THEN BEGIN
    SetColor(White);
    Assign(f,TempStr[0]);
    Reset(f);
    REPEAT
      FOR i := 1 TO 6 DO Read(f,Coordinates[i]);
      ReadLn(f,Magnitude);
      Rectaszension := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
      Declination   := Coordinates[4]+(Coordinates[5]/60)+(Round(Coordinates[6])/3600);
      RD_Correction;
      CASE Round(Magnitude) OF
        9..100: PutPixel(Round((Zoom*Rectaszension)+x),Round((Zoom*Declination+y)),DarkGray);
        7..8: PutPixel(Round((Zoom*Rectaszension)+x),Round((Zoom*Declination+y)),LightGray);
        5..6:  PutPixel(Round((Zoom*Rectaszension)+x),Round((Zoom*Declination+y)),White);
        4: PutPixel(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)),Yellow);
        3: IF (StarmapOption.Magnification = 1) THEN PieSlice(Round((Zoom*Rectaszension)+x),
             Round((Zoom*Declination+y)),0,360,1) ELSE PieSlice(Round((Zoom*Rectaszension)+x),
               Round((Zoom*Declination+y)),0,360,0);
        2: PieSlice(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)),0,360,1);
        1: IF (StarmapOption.Magnification = 1) THEN PieSlice(Round((Zoom*Rectaszension)+x),
             Round((Zoom*Declination+y)),0,360,2) ELSE PieSlice(Round((Zoom*Rectaszension)+x),
               Round((Zoom*Declination+y)),0,360,1);
        0: PieSlice(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)),0,360,2);
         -1..-50: PieSlice(Round((Zoom*Rectaszension)+x),Round(Zoom*Declination+y),0,360,2);
      END;
    UNTIL EoF(f);
  END;
  Close(f);
END;

PROCEDURE SetMilkyWay;
BEGIN
        TempStr[0] := 'milkyway.lst';
        SetColor(Red);
        IF FileExists(TempStr[0]) THEN BEGIN
          Assign(f,TempStr[0]);
          Reset(f);
          REPEAT
            Read(f,i);
            Read(f,Rectaszension);
            ReadLn(f,Declination);
            RD_Correction;
            IF i = 0 THEN MoveTo(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)))
              ELSE LineTo(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)));
          UNTIL EoF(f);
          Close(f);
        END;
END;


PROCEDURE SetEntryWithMagnification;
BEGIN
  { --- Exoplanet setzen mit Ausschnitt-Vergrî·erung --- }
  IF FileExists('EXO/'+ModulFileEntrys[1]) THEN BEGIN
    Assign(f,'EXO/'+ModulFileEntrys[1]);
    ReadEXO;
    x2 := Rectaszension;
    y2 := Declination;
    RD_Correction;
    IF (StarmapOption.Magnification = 1) THEN BEGIN
      x := (640/2)-(Zoom*Rectaszension);
      y := (480/2)-(Zoom*Declination);
      IF (Zoom*Rectaszension) < 640/2 THEN x := 0;
      IF (Zoom*Declination) < 480/2 THEN y := 0;
      IF x2 < 3 THEN x := -Zoom*268;
      IF y2 < -40 THEN y := -Zoom*110;
    END;
    Rec2 := Rectaszension;
    Dec2 := Declination;
    IF (StarmapOption.Magnification = 0) AND (StarmapOption.GridLines = 1) THEN SetGridLines;
    IF (StarmapOption.Ecliptic = 1) THEN SetEcliptic;
    IF (StarmapOption.ConstellationLines = 1) THEN SetConstellationLines;
    IF (StarmapOption.ConstellationBorder = 1) THEN SetConstellationBorder;
    IF (StarmapOption.ConstellationNames > 0) THEN SetConstellationNames;
    IF (StarmapOption.StarCatalogue > 0) THEN SetStarCatalogue;
    IF (StarmapOption.Starnames = 1) THEN SetStarnames;
    {SetMilkyWay;}
    Rectaszension := Rec2;
    Declination := Dec2;
    PutPixel(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)),Red);
    PutPixel(1+Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)),Red);
    PutPixel(Round((Zoom*Rectaszension+x)),1+Round((Zoom*Declination+y)),Red);
    SetColor(Red);
    Circle(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)),5);
    Circle(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)),6);
  END;
  IF (StarmapOption.NumberOfEntrys <> ExoFileMax) THEN BEGIN
    SetTextStyle(2,0,5);
    SetColor(White);
    Str(24-(Rectaszension*24)/360:0:3,Rectaszension2);
    Str(90-Declination:0:3,Declination2);
    OutTextXY(10,340+(10*n)+80,PlanetName+': '+Rectaszension2+'h '+Declination2+'¯');
  END;
  SetTextStyle(2,0,4);
  SetColor(LightGreen);
  OutTextXY(2,460,ID);
END;

PROCEDURE SetEntryWithoutMagnification;
BEGIN
  { --- Exoplanet setzen ohne Ausschnitt-Vergrî·erung --- }
  IF (StarmapOption.Magnification = 0) AND (StarmapOption.GridLines = 1) THEN SetGridLines;
  IF (StarmapOption.Ecliptic = 1) THEN SetEcliptic;
  IF (StarmapOption.ConstellationLines = 1) THEN SetConstellationLines;
  IF (StarmapOption.ConstellationBorder = 1) THEN SetConstellationBorder;
  IF (StarmapOption.ConstellationNames > 0) THEN SetConstellationNames;
  IF (StarmapOption.StarCatalogue > 0) THEN SetStarCatalogue;
  IF (StarmapOption.Starnames = 1) THEN SetStarnames;
  {SetMilkyWay;}
  FOR n := 1 TO StarmapOption.NumberOfEntrys DO BEGIN
    IF FileExists('EXO/'+ModulFileEntrys[n]) THEN BEGIN
      Assign(f,'EXO/'+ModulFileEntrys[n]);
      ReadEXO;
      x2 := Rectaszension;
      y2 := Declination;
      RD_Correction;
      IF (StarmapOption.Magnification = 1) THEN BEGIN
        x := (640/2)-(Zoom*Rectaszension);
        y := (480/2)-(Zoom*Declination);
        IF (Zoom*Rectaszension) < 640/2 THEN x := 0;
        IF (Zoom*Declination) < 480/2 THEN y := 0;
        IF x2 < 3 THEN x := -Zoom*268;
        IF y2 < -40 THEN y := -Zoom*110;
      END;
      SetColor(Red);
      PutPixel(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)),Red);
      Circle(Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y)),2);
      IF (StarmapOption.NumberOfEntrys <> ExoFileMax) THEN BEGIN
        SetTextStyle(2,0,4);
        OutTextXY(5+Round((Zoom*Rectaszension+x)),Round((Zoom*Declination+y))-14,Planetname);
        SetTextStyle(2,0,5);
        SetColor(White);
        Str(24-(Rectaszension*24)/360:0:3,Rectaszension2);
        Str(90-Declination:0:3,Declination2);
        IF n > 13 THEN
          OutTextXY(300,210+(10*(n-1))+0,PlanetName+': '+Rectaszension2+'h '+Declination2+'¯')
          ELSE OutTextXY(10,340+(10*(n-1))+0,PlanetName+': '+Rectaszension2+'h '+Declination2+'¯');
      END;
    END;
  END;
  SetTextStyle(2,0,4);
  SetColor(Cyan);
  OutTextXY(2,320,ID);
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
  IF StarmapOption.NumberOfEntrys = ExoFileMax THEN OutTextXY(360,210,'STARMAP') ELSE OutTextXY(360,210,TempStr[0]);
  SetColor(White);
  OutTextXY(270,230,'1 - Format PCX');
  OutTextXY(270,240,'2 - Format BMP');
  OutTextXY(270,250,'0 - Abbruch');
  REPEAT
    Input2 := ReadKey;
  UNTIL Input2 IN ['0','1','2'];
  LoadImage(0+200,0+200,'image.tmp');
  IF (StarmapOption.Magnification = 1) THEN BEGIN
    IF NOT(DirExists('STARMAP2')) THEN MkDir('STARMAP2');
      CASE Input2 OF
        '1' : IF (StarmapOption.NumberOfEntrys = ExoFileMax) THEN SavePCX('STARMAP2/'+'STARMAP2.PCX')
              ELSE BEGIN
                SavePCX('STARMAP2/'+TempStr[0]+'.PCX');
              END;
        '2' : IF (StarmapOption.NumberOfEntrys = ExoFileMax) THEN SaveBMP('STARMAP2/'+'STARMAP2')
              ELSE BEGIN
                SaveBMP('STARMAP2/'+TempStr[0]);
              END;
        '0' : Exit;
     END;
  END ELSE IF (StarmapOption.Magnification = 0) THEN BEGIN
    IF NOT(DirExists('STARMAP')) THEN MkDir('STARMAP');
      CASE Input2 OF
        '1' : IF (StarmapOption.NumberOfEntrys = ExoFileMax) THEN SavePCX('STARMAP/'+'STARMAP.PCX')
              ELSE BEGIN
                SavePCX('STARMAP/'+TempStr[0]+'.PCX');
              END;
        '2' : IF (StarmapOption.NumberOfEntrys = ExoFileMax) THEN SaveBMP('STARMAP/'+'STARMAP')
              ELSE BEGIN
                SaveBMP('STARMAP/'+TempStr[0]);
              END;
        '0' : Exit;
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
  Randomize;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  InitStarmapOptions;
  TextBackground(Black);
  TextColor(White);
  Zoom := 1.72;
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF NOT(FileExists('STARMAP.CMD')) THEN BEGIN
    ClrScr;
    WriteLn(^j^j'Die Datei "STARMAP.CMD" wurde nicht gefunden!');
    ReadKey;
    Halt;
  END;
  GetStarmapOptions;
  ClrScr;
  CheckLSTFiles;
  grDriver := Detect;
  InitGraph(grDriver,grMode,'');
  REPEAT
    SetBluesky;
    IF (StarmapOption.Magnification = 0) THEN SetEntryWithoutMagnification
    ELSE IF (StarmapOption.NumberOfEntrys > 0) THEN BEGIN
      IF (StarmapOption.Magnification = 1) THEN SetEntryWithMagnification;
    END;
    Input := Readkey;
    IF UpCase(Input) = 'S' THEN SaveScreen;
    IF UpCase(Input) = 'P' THEN GraftoPrint;
  UNTIL Input <> '';
END.

      {

      !!! Erweiterung fÅr Milkyway

      FOR i := 1 TO 4 DO BEGIN
        CASE i OF
          1 : TempStr[0] := 'ml1o.lst';
          2 : TempStr[0] := 'ml2u.lst';
          3 : TempStr[0] := 'ml2o.lst';
          4 : TempStr[0] := 'ml1u.lst';
        END;
        IF FileExists(TempStr[0]) THEN BEGIN
          Assign(f,TempStr[0]);
          Reset(f);
          Read(f,Rectaszension[0]);
          ReadLn(f,Declination[0]);
          Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor
          Rectaszension[0] := 10*Rectaszension[0];
          Rectaszension[0] := (Rectaszension[0]*360)/240;
          Rectaszension[0] := 360-Rectaszension[0];
          Declination[0]   := -(Declination[0])+90;
          MoveTo(Round((Zoom*Rectaszension[0]+x)),Round((Zoom*Declination[0]+y)));
          REPEAT
            Read(f,Rectaszension[0]);
            ReadLn(f,Declination[0]);
            Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor
            Rectaszension[0] := 10*Rectaszension[0];
            Rectaszension[0] := (Rectaszension[0]*360)/240;
            Rectaszension[0] := 360-Rectaszension[0];
            Declination[0]   := -(Declination[0])+90;
            CASE i OF
              1,2 : SetColor(Darkgray);
              3,4 : SetColor(LightGray);
            END;
            LineTo(Round((Zoom*Rectaszension[0]+x)),Round((Zoom*Declination[0]+y)));
          UNTIL EoF(f);
          Close(f);
        END;
      END;}
      {FOR i := 1 TO 5 DO BEGIN
        CASE i OF
          1 : TempStr[0] := 'mw_sh1.dat';
          2 : TempStr[0] := 'mw_sh2.dat';
          3 : TempStr[0] := 'mw_sh3.dat';
          4 : TempStr[0] := 'mw_sh4.dat';
          5 : TempStr[0] := 'mw_sh5.dat';
        END;
        IF FileExists(TempStr[0]) THEN BEGIN
          Assign(f,TempStr[0]);
          Reset(f);
          ReadLn(f,TempStr[1]);
          Val(TempStr[1][1]+TempStr[1][2],Coordinates[1],Control);
          Val(TempStr[1][3]+TempStr[1][4],Coordinates[2],Control);
          Val(TempStr[1][5]+TempStr[1][6],Coordinates[3],Control);
          Rectaszension[0] := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
          Val(TempStr[1][7]+TempStr[1][8]+TempStr[1][9],Coordinates[4],Control);
          Val(TempStr[1][10]+TempStr[1][11],Coordinates[5],Control);
          Val(TempStr[1][11]+TempStr[1][12],Coordinates[6],Control);
          Declination[0] := Coordinates[4]+(Coordinates[5]/60)+(Round(Coordinates[6])/3600);
          REPEAT
            ReadLn(f,TempStr[2]);
            Val(TempStr[2][1]+TempStr[2][2],Coordinates[1],Control);
            Val(TempStr[2][3]+TempStr[2][4],Coordinates[2],Control);
            Val(TempStr[2][5]+TempStr[2][6],Coordinates[3],Control);
            Rectaszension[0] := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
            Val(TempStr[2][7]+TempStr[2][8]+TempStr[2][9],Coordinates[4],Control);
            Val(TempStr[2][10]+TempStr[2][11],Coordinates[5],Control);
            Val(TempStr[2][11]+TempStr[2][12],Coordinates[6],Control);
            Declination[0] := Coordinates[4]+(Coordinates[5]/60)+(Round(Coordinates[6])/3600);

            Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor

            Rectaszension[0] := 10*Rectaszension[0];
            Rectaszension[0] := (Rectaszension[0]*360)/240;
            Rectaszension[0] := 360-Rectaszension[0];
            Declination[0]   := -(Declination[0])+90;
            CASE i OF
              1 : BEGIN
                    SetColor(DarkGray);
                    SetFillStyle(1,DarkGray);
                    FillEllipse(Round((Zoom*Rectaszension[0]+x)),Round((Zoom*Declination[0]+y)),1,1);
                  END;
            END;
            MoveTo(Round((Zoom*Rectaszension[0]+x)),Round((Zoom*Declination[0]+y)));
            LineTo(Round((Zoom*Rectaszension[0]+x)),Round((Zoom*Declination[0]+y)));
          UNTIL EoF(f);
          Close(f);
        END;
      END;}
