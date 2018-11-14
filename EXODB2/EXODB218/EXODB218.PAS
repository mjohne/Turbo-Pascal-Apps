PROGRAM EXO_DB2_v18;

USES Crt,Dos,Graph,Arithmos,Basic,BMPLoad,Cursor,RT_Watch,Scan_Exo,TimeStmp,ConstVar,Moduls;

PROCEDURE SearchDirX(Path : PathStr; fspec : STRING);
VAR
  f : SearchRec;
BEGIN
  FindFirst(Path+fspec,AnyFile,f);
  WHILE DosError = 0 DO BEGIN
    Inc(b);
    ExoFile[b] := f.name;
    Findnext(f);
  END;
END;

BEGIN
  { --- Wichtige Initialisierungen --- }
  Index := 1;
  Splash := True;
  {weitere Variablen-Initialisierungen fÅr Scan_Exo() in CONSTVAR enthalten}
  Randomize;
  { --- Zeitstempel setzen --- }
  MakeTimestamp;
  { --- Teil der Parameter-Abfrage; nur EXIT-Parameter --- }
  IF ParamStr(1) <> '' THEN BEGIN
    TempStr[0] := UpString(ParamStr(1));
    IF (TempStr[0] = 'EXIT') OR (TempStr[0] = 'QUIT') OR (TempStr[0] = 'ESC') THEN BEGIN ClrScr; Halt; END;
  END;
  { --- Zeitstempel-Parameter auswerten --- }
  IF ParamStr(1) <> '' THEN BEGIN
    TempStr[0] := UpString(ParamStr(1));
    IF TempStr[0] = 'TIMESTAMP' THEN BEGIN
      TempStr[0] := UpString(ParamStr(2));
      IF TempStr[0] = 'MAKE' THEN MakeTimeStamp;
     IF TempStr[0] = 'VIEW' THEN ViewTimeStamp;
      IF TempStr[0] = 'LOG' THEN LogTimeStamp;
      IF (TempStr[0] = 'DEL') OR (TempStr[0] = 'DELETE') OR (TempStr[0] = 'ERASE') THEN EraseTimeStamp;;
    END;
  END;
  { --- Splash Screens suchen und anzeigen --- }
  IF ParamStr(1) <> '' THEN BEGIN
    TempStr[0] := UpString(ParamStr(1));
    IF TempStr[0] = 'NOSPLASH' THEN Splash := False;
  END;
  b := 0;
  IF Splash = True THEN BEGIN
    REPEAT
      SearchDirX('splash\','*.lzs');
    UNTIL DosError <> 0;
    IF b <> 0 THEN BEGIN
      b := Random(b)+1;
    END;
    {$M 50000,0,0}
    IF NOT(FileExists('splash.exe')) AND NOT(FileExists('splash.dat')) THEN BEGIN
      { --- Dummy --- }
    END ELSE BEGIN
      IF FileExists('splash.exe') THEN BEGIN
        IF FileExists('splash.dat') THEN BEGIN
          Assign(f2,'splash.dat');
          Erase(f2);
        END;
         Assign(f2,'splash.exe');
         Rename(f2,'splash.dat');
      END;
      Assign(f2,'splash.dat');
      Rename(f2,'splash.exe');
      Exec('splash.exe','splash\'+ExoFile[b]+' splash\temp.pic unsquash');
      Rename(f2,'splash.dat');
    END;
  END;
  { --- Programm aufbauen --- }
  ClrScr;
  TextMode(300);
  HideCursor;
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
  { --- Parameter-Abfrage --- }
  IF ParamStr(1) <> '' THEN BEGIN
    IF Splash = False THEN TempStr[0] := UpString(ParamStr(2)) ELSE TempStr[0] := UpString(ParamStr(1));
    IF TempStr[0] = 'ADD' THEN Add;
    IF TempStr[0] = 'LOAD' THEN Load;
    IF TempStr[0] = 'CHANGE' THEN Change;
    IF TempStr[0] = 'RENAME' THEN Rename2;
    IF TempStr[0] = 'EXPORT' THEN Modul_Export;
    IF TempStr[0] = 'DELETE' THEN Delete;
    IF TempStr[0] = 'CHECK' THEN Check;
    IF TempStr[0] = 'MASSCOMP' THEN Modul_MassCompare;
    IF TempStr[0] = 'STARMAP' THEN Modul_Starmap;
    IF TempStr[0] = 'HRD' THEN Modul_HRD;
    IF TempStr[0] = 'DISTRI' THEN Modul_Distribution;
    IF TempStr[0] = 'DIAGRAM' THEN Modul_Diagram;
    IF TempStr[0] = 'STAR3D' THEN Modul_Star3D;
    IF TempStr[0] = 'RECORDS' THEN Records;
    IF TempStr[0] = 'STATUS' THEN Status;
    IF TempStr[0] = 'INFO' THEN Info;
    IF TempStr[0] = 'CREDITS' THEN Credits;
    IF TempStr[0] = 'THANKS' THEN Thanks;
    IF TempStr[0] = 'HELP' THEN BEGIN Help; ScanExoUpdate(Index); END;
    IF TempStr[0] = 'SEARCH' THEN Search;
    IF TempStr[0] = 'FILTER' THEN Filter;
    IF TempStr[0] = 'SCREEN' THEN ScreenSaver;
    IF TempStr[0] = 'HISTORY' THEN BEGIN History; ScanExoUpdate(Index); END;
    IF ParamStr(2) <> '' THEN BEGIN
      TempStr[0] := UpString(ParamStr(2));
      IF (TempStr[0] = 'EXIT') OR (TempStr[0] = 'QUIT') OR (TempStr[0] = 'ESC') THEN BEGIN ClrScr; Halt; END;
    END;
    IF ParamStr(3) <> '' THEN BEGIN
      TempStr[0] := UpString(ParamStr(3));
      IF (TempStr[0] = 'EXIT') OR (TempStr[0] = 'QUIT') OR (TempStr[0] = 'ESC') THEN BEGIN ClrScr; Halt; END;
    END;
  END;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,
    Metal2_Max,Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,
    Axis2_Max,Period2_Min,Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
  { --- Tasten-Abfrage, -auswertung & eigentliche FunktionsausfÅhrung --- }
  REPEAT
    Input := Readkey;
    Input := Upcase(Input);
    CASE Input OF
      NULL : BEGIN
        Input2 := Readkey;
        CASE Input2 OF
          POS1 : BEGIN
            SetButton(5,20,White,LightRed+Blink,'˛',50);
            SetButton(5,20,White,Black+Blink,'˛',0);
            Index := 1;
            ScanExoUpdate(Index);
          END;
          PGUP : BEGIN
            SetButton(11,20,White,LightRed+Blink,'<<',50);
            SetButton(11,20,White,Black+Blink,'<<',0);
            Dec(Index,10);
            IF Index < 1 THEN Index := ExoFileMax-Index-10;
            ScanExoUpdate(Index);
          END;
          ARLF,ARUP : BEGIN
            SetButton(17,20,White,LightRed+Blink,'<-',50);
            SetButton(17,20,White,Black+Blink,'<-',0);
            Dec(Index);
            IF Index < 1 THEN Index := ExoFileMax-Index;
            ScanExoUpdate(Index);
          END;
          ARRT,ARDN : BEGIN
            SetButton(23,20,White,LightRed+Blink,'->',50);
            SetButton(23,20,White,Black+Blink,'->',0);
            Inc(Index);
            IF Index > ExoFileMax THEN Index := Index-ExoFileMax;
            ScanExoUpdate(Index);
          END;
          PGDN : BEGIN
            SetButton(29,20,White,LightRed+Blink,'>>',50);
            SetButton(29,20,White,Black+Blink,'>>',0);
            Inc(Index,10);
            IF Index > ExoFileMax THEN Index := Index-ExoFileMax;
            ScanExoUpdate(Index);
          END;
          END1 : BEGIN
            SetButton(35,20,White,LightRed+Blink,'˛',50);
            SetButton(35,20,White,Black+Blink,'˛',0);
            Index := ExoFileMax;
            ScanExoUpdate(Index);
          END;
          EINFG : Add;
          ENTF  : Delete;
        END;
      END;
      'G' : BEGIN
        REPEAT
          Goto_Interface;
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
      '7' : Check;
      'O' : Modul_Orbit;
      'M' : Modul_MassCompare;
      'S' : Modul_Starmap;
      'H' : Modul_HRD;
      'D' : Modul_Distribution;
      'A' : Modul_Diagram;
      'P' : Modul_Star3D;
      'R' : Records;
      'U' : Status;
      'I' : Info;
      'C' : Credits;
      'T' : Thanks;
      'E' : BEGIN Help; ScanExoUpdate(Index); END;
      'F' : Search;
      'V' : Filter;
      'Z' : ScreenSaver;
      'Y' : BEGIN History; ScanExoUpdate(Index); END;
      'X',ESC : Exit2 := True;
    END;
    ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
      Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
      Period2_Max,Ecc2_Min,Ecc2_Max);
    ScanExoUpdate(Index);
  UNTIL Exit2;
  ClrScr;
  ShowCursor;
END.
