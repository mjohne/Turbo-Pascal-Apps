PROGRAM Convert;

USES Crt,Dos,RT_Watch;

VAR
  Deklination,
  Distance,
  Eccentricity,
  Magnitude,
  Metalicity,
  Period,
  PlanetMass,
  Rectaszension,
  SemiMajorAxis,
  StarMass        : Real;
  Fil,
  CentralStar,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Method,
  PlanetName,
  Remarks,
  SpectralType    : STRING;
  f               : Text;

FUNCTION ReadStr(Anzahl : Byte) : STRING;
VAR
  Eingabe,Puff : STRING;
  cf           : Text;
  SaveX,SaveY  : Byte;
BEGIN
  AssignCrt(cf);
  SetTextBuf(cf,Puff,Anzahl+2);
  Reset(cf);
  SaveX := WhereX;
  SaveY := WhereY;
  ReadLn(cf,Eingabe);
  Close(cf);
  IF SaveY=Hi(WindMax)+1 THEN Dec(SaveY);
  GotoXY(SaveX+Length(Eingabe),SaveY);
  ReadStr := Eingabe;
END;

FUNCTION ReadInt(Anzahl : Byte) : LongInt;
VAR
  Eingabe,Puff : STRING;
  cf           : Text;
  SaveX,SaveY  : Byte;
  Contr        : Integer;
  Zahl         : LongInt;
BEGIN
  IF Anzahl > 11 THEN Anzahl := 11;
  AssignCrt(cf);
  SetTextBuf(cf,Puff,Anzahl+2);
  Reset(cf);
  SaveX := WhereX;
  SaveY := WhereY;
  REPEAT
    GotoXY(SaveX,SaveY);
    ClrEoL;
    ReadLn(cf,Eingabe);
    IF SaveY = Hi(WindMax)+1 THEN Dec(SaveY);
    Val(Eingabe,Zahl,Contr);
  UNTIL Contr = 0;
  Close(cf);
  GotoXY(SaveX+Length(Eingabe),SaveY);
  ReadInt := Zahl;
END;

FUNCTION ReadReal(Anzahl : Byte) : Real;
VAR
  Eingabe,Puff : STRING;
  cf           : Text;
  SaveX,SaveY  : Byte;
  Contr        : Integer;
  Zahl         : Real;
BEGIN
  IF Anzahl > 11 THEN Anzahl := 11;
  AssignCrt(cf);
  SetTextBuf(cf,Puff,Anzahl+2);
  Reset(cf);
  SaveX := WhereX;
  Savey := WhereY;
  REPEAT
    GotoXY(savex,savey);
    ClrEoL;
    ReadLn(cf,eingabe);
    IF savey=Hi(WindMax)+1 THEN Dec(savey);
    Val(eingabe,zahl,contr);
  UNTIL contr=0;
  Close(cf);
  GotoXY(savex+Length(eingabe),savey);
  ReadReal:=zahl;
END;

FUNCTION FileExists(FName : STRING) : Boolean;
VAR
  f     : FilE;
  fAttr : Word;
BEGIN
  Assign(f, FName);
  GetFAttr(f, fAttr);
  FileExists := (DosError = 0)
                AND ((fAttr AND Directory) = 0)
                AND ((fAttr AND VolumeID)  = 0);
END;

FUNCTION DirExists(DName : STRING) : Boolean;
VAR
  f     : FilE;
  fAttr : Word;
BEGIN
  Assign(f, DName);
  GetFAttr(f, fAttr);
  DirExists := ((fAttr AND Directory) <> 0) AND (DosError = 0);
END;

BEGIN
  WriteLn(^j^j^j'CONVERT - Konvertierungsutility      (C) 1995-2005 Michael Johne');
  WriteLn(^j'Dieses Utility konvertiert DatensÑtze vom Format EXO-DB(1) nach EXODB2');
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF ParamStr(1) = '' THEN BEGIN
    WriteLn('Aufruf: CONVERT.EXE [datensatzname]');
    WriteLn('Name des Datensatzes im EXODB(1)-Format(max. 8; ohne *.EXO).');
  END ELSE IF FileExists('EXO\'+ParamStr(1)+'.EXO') THEN BEGIN
    WriteLn('Daten werden gelesen...');
    Assign(f,'EXO\'+ParamStr(1)+'.EXO');
    Reset(f);
    ReadLn(f,Centralstar);
    ReadLn(f,Distance);
    ReadLn(f,SpectralType);
    ReadLn(f,Magnitude);
    ReadLn(f,Rectaszension);
    ReadLn(f,Deklination);
    ReadLn(f,Method);
    ReadLn(f,PlanetMass);
    ReadLn(f,SemiMajorAxis);
    ReadLn(f,Period);
    ReadLn(f,Eccentricity);
    Close(f);
    Write(^j'HinzufÅgen von "Sternmasse"          :  ');
    StarMass := ReadReal(35);
    WriteLn;
    Write('HinzufÅgen von "MetallizitÑt"        :  ');
    Metalicity := ReadReal(35);
    WriteLn;
    Write('HinzufÅgen von "Konstellation"       :  ');
    Constellation := ReadStr(35);
    WriteLn;
    Write('HinzufÅgen von "Planetenbezeichnung" :  ');
    PlanetName := ReadStr(35);
    WriteLn;
    Write('HinzufÅgen von "Entdeckungsdatum"    :  ');
    DiscoveryDate := ReadStr(35);
    WriteLn;
    Write('HinzufÅgen von "Entdecker/-team"     :  ');
    Discoverer := ReadStr(35);
    WriteLn;
    WriteLn('Daten werden gesichert...');
    WriteLn('Lîsche Eigenschaft "Notizen, Hinweise, etc."...');
    Assign(f,'EXO\'+ParamStr(1)+'.EXO');
    Rewrite(f);
    WriteLn(f,Centralstar);
    WriteLn(f,SpectralType);
    WriteLn(f,Magnitude);
    WriteLn(f,StarMass);
    WriteLn(f,Metalicity);
    WriteLn(f,Distance);
    WriteLn(f,Rectaszension);
    WriteLn(f,Deklination);
    WriteLn(f,Constellation);
    WriteLn(f,PlanetName);
    WriteLn(f,PlanetMass);
    WriteLn(f,SemiMajorAxis);
    WriteLn(f,Period);
    WriteLn(f,Eccentricity);
    WriteLn(f,Method);
    WriteLn(f,DiscoveryDate);
    WriteLn(f,Discoverer);
    WriteLn(f,'-');
    Close(f);
    WriteLn(^j'Datei ist gespeichert! Eine beliebige Taste drÅcken!');
  END ELSE BEGIN
    WriteLn('Dieser Datensatz wurde nicht gefunden. Stellen Sie sicher, dass alle');
    WriteLn('DatensÑtze im EXODB(1)-Format im Verzeichnis "EXO" liegen');
  END;
  ReadKey;
END.
