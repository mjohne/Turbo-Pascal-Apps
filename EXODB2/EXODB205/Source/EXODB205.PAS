PROGRAM EXO_DB2_v05;

USES Crt,Dos,Graph,Printer,RT_Watch;

VAR
  Exit,Korrektur  : Boolean;
  Input,Input2    : Char;
  Zoom,Numb,n,i,
  mx,my,Numb3     : Integer;
  a,p,e           : Real;
  Fil             : ARRAY[0..20] OF STRING;
  f,f2            : Text;
  mx2,my2,Numb2,
  Zoom2,Numb4,
  CentralStar,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Method,
  PlanetName,
  Remarks,
  SpectralType    : STRING;
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

FUNCTION ReadStr(Anzahl : Byte) : STRING;
VAR
  eingabe,puff: String;
  cf          : Text;
  savex,savey : Byte;
BEGIN
  AssignCrt(cf);
  SetTextBuf(cf,puff,anzahl+2);
  Reset(cf);
  savex:=WhereX; savey:=WhereY;
  ReadLn(cf,eingabe);
  Close(cf);
  IF savey=Hi(WindMax)+1 THEN Dec(savey);
  GotoXY(savex+Length(eingabe),savey);
  ReadStr:=eingabe;
END;

FUNCTION ReadInt(anzahl : Byte) : LongInt;
VAR
  eingabe,puff: String;
  cf          : Text;
  savex,savey : Byte;
  contr       : Integer;
  zahl        : LongInt;
BEGIN
  IF anzahl>11 THEN anzahl:=11;
  AssignCrt(cf);
  SetTextBuf(cf,puff,anzahl+2);
  Reset(cf);
  savex:=WhereX; savey:=WhereY;
  REPEAT
   GotoXY(savex,savey);
    ClrEoL;
    ReadLn(cf,eingabe);
    IF savey=Hi(WindMax)+1 THEN Dec(savey);
    Val(eingabe,zahl,contr);
  UNTIL contr=0;
  Close(cf);
  GotoXY(savex+Length(eingabe),savey);
  ReadInt:=zahl;
END;

FUNCTION ReadReal(anzahl : Byte) : Real;
VAR
  eingabe,puff: String;
  cf          : Text;
  savex,savey : Byte;
  contr       : Integer;
  zahl        : Real;
BEGIN
  IF anzahl>11 THEN anzahl:=11;
  AssignCrt(cf);
  SetTextBuf(cf,puff,anzahl+2);
  Reset(cf);
  savex:=WhereX; savey:=WhereY;
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

FUNCTION ReadHMS : Real;
VAR
  h, min      : Integer;
  sec, sum    : Real;
  savex, savey: Integer;
BEGIN
  h:=ReadInt(3);
  Write(' h ');
  savex:=WhereX; savey:=WhereY;
  REPEAT
    GotoXY(savex,savey);
    ClrEoL;
    min:=ReadInt(2);
  UNTIL min<60;
  Write(' m ');
  savex:=WhereX; savey:=WhereY;
  REPEAT
    GotoXY(savex,savey);
    ClrEoL;
    sec:=ReadReal(5);
  UNTIL sec<60;
  Write(' s ');
  sum:=Abs(h)+min/60+sec/3600;
  IF h<0 THEN ReadHMS:=-sum ELSE ReadHMS:=sum;
END;

FUNCTION ReadDeg:Real;
VAR
  h, min      : Integer;
  sec, sum    : Real;
  savex, savey: Integer;
BEGIN
  h:=ReadInt(3);
  Write('� ');
  savex:=WhereX; savey:=WhereY;
  REPEAT
    GotoXY(savex,savey);
    ClrEoL;
    min:=ReadInt(2);
  UNTIL min<60;
  Write(chr(39),' ');
  savex:=WhereX; savey:=WhereY;
  REPEAT
    GotoXY(savex,savey);
    ClrEoL;
    sec:=ReadReal(5);
  UNTIL sec<60;
  Write('" ');
  sum:=Abs(h)+min/60+sec/3600;
  IF h<0 THEN ReadDeg:=-sum ELSE ReadDeg:=sum;
END;

FUNCTION RealToHms(kooD:Real):String;
VAR
  kooG     : String;
  zweistell: String[2];
  dez      : Real;
BEGIN
  kooG:='';
  Str(Trunc(kooD),kooG);
  kooG:=kooG+' h ';
  dez:=Abs(Frac(kooD))*60;
  Str(Trunc(dez),zweistell);
  IF dez<10 THEN kooG:=kooG+'0';
  kooG:=kooG+zweistell+' m ';
  dez:=Abs(Frac(dez))*60;
  Str(dez:2:0,zweistell);
  IF dez<10 THEN kooG:=kooG+'0'+Copy(zweistell,2,1)+' s '
            ELSE kooG:=kooG+zweistell+' s ';
  RealToHMS:=kooG;
END;

FUNCTION RealToDeg(kooD:Real):String;
VAR
  kooG     : String;
  zweistell: String[2];
  dez      : Real;
BEGIN
  kooG:='';
  Str(Trunc(kooD),kooG);
  kooG:=kooG+' h ';
  dez:=Abs(Frac(kooD))*60;
  Str(Trunc(dez),zweistell);
  IF dez<10 THEN kooG:=kooG+'0';
  kooG:=kooG+zweistell+' m ';
  dez:=Abs(Frac(dez))*60;
  Str(dez:2:0,zweistell);
  IF dez<10 THEN kooG:=kooG+'0'+Copy(zweistell,2,1)+' s '
            ELSE kooG:=kooG+zweistell+' s ';
  RealToDeg:=kooG;
END;

PROCEDURE MainApp;
BEGIN
  ClrScr;
  TextMode(300);
  TextBackground(Black);
  TextColor(White);
  Exit := False;
  WriteLn('EXOPLANETEN-DATENBANK (EXO-DB2)     Version: 0.5     (C) 1995-2003 Michael Johne');
  WriteLn('===============================     ------------     ���������������������������');
  WriteLn(^j^j'(1) - Neuen Datensatz anlegen');
  WriteLn('(2) - Vorhandenen Datensatz �ndern');
  WriteLn('(3) - Existierenden Datensatz l�schen');
  WriteLn('(4) - Vorhandenen Datensatz drucken');
  WriteLn(^j'(0) - EXIT');
  GotoXY(45,7); Write('(5) - Orbit-Abbild');
  GotoXY(45,9); Write('(7) - Masse-Vergleich');
  GotoXY(45,8); Write('(6) - Sternkarte');
  GotoXY(45,10); Write('(8) - Konvertierung von EXO-DB');
  GotoXY(65,11); Write('-> EXO.DB2');
END;

PROCEDURE Add;
BEGIN
  GotoXY(1,14);
  Write('Mit Fehlerspanne? (j/n)');
  REPEAT
    Input := ReadKey;
  UNTIL Input IN ['j','J','y','Y','z','Z','n','N'];
  IF Input IN ['N','n'] THEN Korrektur := False ELSE Korrektur := True;
  GotoXY(1,15);
  WriteLn('DATENANGABE ZUM ZENTRALSTERN');
  WriteLn('----------------------------');
  WriteLn('Name des Zentralsterns         :');
  WriteLn('Spektraltyp/Leuchtkraftklasse  :');
  WriteLn('Scheinbare Helligkeit mag      :');
  WriteLn('Masse in Sonnenmasse           :');
  WriteLn('Metallizit�t                   :');
  WriteLn('Entfernung zur Sonne in Parsec :');
  WriteLn('Rektaszension (2000)           :');
  WriteLn('Deklination (2000)             :');
  WriteLn('Sternbild                      :');
  WriteLn(^j'DATENANGABE ZUM EXOPLANETEN');
  WriteLn('---------------------------');
  WriteLn('Standardbezeichnung des Planet :');
  WriteLn('Masse in Jupitermasse          :');
  WriteLn('Gro�e Halbachse in AE          :');
  WriteLn('Umlaufzeit in Tage             :');
  WriteLn('Num. Exzentizit�t              :');
  WriteLn('Methode des Entdeckung         :');
  WriteLn('Entdeckungsdatum               :');
  WriteLn('Entdecker/-team                :');
  WriteLn('Notiz, Bermerkung etc.         :');
  GotoXY(36,17); Centralstar := ReadStr(45);
  GotoXY(36,18); SpectralType := ReadStr(45);
  GotoXY(36,19); Magnitude := ReadReal(11);
  GotoXY(36,20); StarMass := ReadReal(11);
  GotoXY(36,21); Metalicity := ReadReal(11);
  IF Korrektur THEN BEGIN
    Write(' +/- ');
    Metalicity2 := ReadReal(11);
  END;
  GotoXY(36,22); Distance := ReadReal(11);
  GotoXY(36,23); Rectaszension := ReadHMS;
  GotoXY(36,24); Deklination := ReadDeg;
  GotoXY(36,25); Constellation := ReadStr(45);
  GotoXY(36,29); PlanetName := ReadStr(45);
  GotoXY(36,30); PlanetMass := ReadReal(11);
  IF Korrektur THEN BEGIN
    Write(' +/- ');
    PlanetMass2 := ReadReal(11);
  END;
  GotoXY(36,31); SemiMajorAxis := ReadReal(11);
  IF Korrektur THEN BEGIN
    Write(' +/- ');
    SemiMajorAxis2 := ReadReal(11);
  END;
  GotoXY(36,32); Period := ReadReal(11);
  IF Korrektur THEN BEGIN
    Write(' +/- ');
    Period2 := ReadReal(11);
  END;
  GotoXY(36,33); Eccentricity := ReadReal(11);
  IF Korrektur THEN BEGIN
    Write(' +/- ');
    Eccentricity2 := ReadReal(11);
  END;
  GotoXY(36,34); Method := ReadStr(45);
  GotoXY(36,35); DiscoveryDate := ReadStr(45);
  GotoXY(36,36); Discoverer := ReadStr(45);
  GotoXY(36,37); Remarks := ReadStr(45);
  Write(^m^j^j'Name der Datei zum Speichern (max. 8): ');
  ReadLn(Fil[1]);
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  Assign(f,'EXO\'+Fil[1]+'.EXO');
  Rewrite(f);
  WriteLn(f,Centralstar);
  WriteLn(f,SpectralType);
  WriteLn(f,Magnitude);
  WriteLn(f,StarMass);
  IF Korrektur THEN BEGIN
    WriteLn(f,Metalicity,Metalicity2);
  END ELSE WriteLn(f,Metalicity);
  WriteLn(f,Distance);
  WriteLn(f,Rectaszension);
  WriteLn(f,Deklination);
  WriteLn(f,Constellation);
  WriteLn(f,PlanetName);
  IF Korrektur THEN BEGIN
    WriteLn(f,PlanetMass,PlanetMass2);
  END ELSE WriteLn(f,PlanetMass);
  IF Korrektur THEN BEGIN
    WriteLn(f,SemiMajorAxis,SemiMajorAxis2);
  END ELSE WriteLn(f,SemiMajorAxis);
  IF Korrektur THEN BEGIN
    WriteLn(f,Period,Period2);
  END ELSE WriteLn(f,Period);
  IF Korrektur THEN BEGIN
    WriteLn(f,Eccentricity,Eccentricity2);
  END ELSE WriteLn(f,Eccentricity);
  WriteLn(f,Method);
  WriteLn(f,DiscoveryDate);
  WriteLn(f,Discoverer);
  WriteLn(f,Remarks);
  Close(f);
  Write('Datei ist gespeichert! Eine beliebige Taste dr�cken!');
  ReadKey;
  FOR i := 1 TO 40 DO BEGIN
    GotoXY(1,12+i);
    InsLine;
  END;
  GotoXY(1,5);
END;

PROCEDURE Change;
BEGIN
  GotoXY(1,14);
  Write('Mit Fehlerspanne? (j/n)');
  REPEAT
    Input := ReadKey;
  UNTIL Input IN ['j','J','y','Y','z','Z','n','N'];
  IF Input IN ['N','n'] THEN Korrektur := False ELSE Korrektur := True;
  GotoXY(1,15);
  Write('Name der Datei zum �ndern (max. 8): ');
  ReadLn(Fil[1]);
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF FileExists('EXO\'+Fil[1]+'.EXO') THEN BEGIN
    Assign(f,'EXO\'+Fil[1]+'.EXO');
    Reset(f);
    ReadLn(f,Centralstar);
    ReadLn(f,SpectralType);
    ReadLn(f,Magnitude);
    ReadLn(f,StarMass);
    IF Korrektur THEN BEGIN
      ReadLn(f,Metalicity,Metalicity2);
    END ELSE ReadLn(f,Metalicity);
    ReadLn(f,Distance);
    ReadLn(f,Rectaszension);
    ReadLn(f,Deklination);
    ReadLn(f,Constellation);
    ReadLn(f,PlanetName);
    IF Korrektur THEN BEGIN
      ReadLn(f,PlanetMass,PlanetMass2);
    END ELSE ReadLn(f,PlanetMass);
    IF Korrektur THEN BEGIN
      ReadLn(f,SemiMajorAxis,SemiMajorAxis2);
    END ELSE ReadLn(f,SemiMajorAxis);
    IF Korrektur THEN BEGIN
      ReadLn(f,Period,Period2);
    END ELSE ReadLn(f,Period);
    IF Korrektur THEN BEGIN
      ReadLn(f,Eccentricity,Eccentricity2);
    END ELSE ReadLn(f,Eccentricity);
    ReadLn(f,Method);
    ReadLn(f,DiscoveryDate);
    ReadLn(f,Discoverer);
    ReadLn(f,Remarks);
    Close(f);
    WriteLn('Der Datei-Inhalt wurde gelesen.');
    WriteLn(^j^j'     DATENANGABE ZUM ZENTRALSTERN');
    WriteLn('     ----------------------------');
    WriteLn('(11) Name des Zentralsterns         :   ',CentralStar);
    WriteLn('(12) Spektraltyp/Leuchtkraftklasse  :   ',Spectraltype);
    WriteLn('(13) Scheinbare Helligkeit mag      :   ',Magnitude:0:2);
    WriteLn('(14) Masse in Sonnenmasse           :   ',StarMass:0:2);
    IF Korrektur THEN BEGIN
      WriteLn('(15) Metallizit�t                   :   ',Metalicity:0:2,'+/-',Metalicity2:0:2);
    END ELSE WriteLn('(15) Metallizit�t                   :   ',Metalicity:0:2);;
    WriteLn('(16) Entfernung zur Sonne in Parsec :   ',Distance:0:2);
    WriteLn('(17) Rektaszension (2000)           :   ',Rectaszension:0:4);
    WriteLn('(18) Deklination (2000)             :   ',Deklination:0:4);
    WriteLn('(19) Sternbild                      :   ',Constellation);
    WriteLn(^j'     DATENANGABE ZUM EXOPLANETEN');
    WriteLn('     ---------------------------');
    WriteLn('(21) Standardbezeichnung des Planet :   ',PlanetName);
    IF Korrektur THEN BEGIN
      WriteLn('(22) Masse in Jupitermasse          :   ',PlanetMass:0:2,' +/- ',PlanetMass2:0:2);
    END ELSE WriteLn('(22) Masse in Jupitermasse          :   ',PlanetMass:0:2);
    IF Korrektur THEN BEGIN
      WriteLn('(23) Gro�e Halbachse in AE          :   ',SemiMajorAxis:0:2,' +/- ',SemiMajorAxis2:0:2);
    END ELSE WriteLn('(23) Gro�e Halbachse in AE          :   ',SemiMajorAxis:0:2);
    IF Korrektur THEN BEGIN
      WriteLn('(24) Umlaufzeit in Tage             :   ',Period:0:2,' +/- ',Period2:0:2);
    END ELSE WriteLn('(24) Umlaufzeit in Tage             :   ',Period:0:2);
    IF Korrektur THEN BEGIN
      WriteLn('(25) Num. Exzentizit�t              :   ',Eccentricity:0:2,' +/- ',Eccentricity2:0:2);
    END ELSE WriteLn('(25) Num. Exzentizit�t              :   ',Eccentricity:0:2);
    WriteLn('(26) Methode der Entdeckung         :   ',Method);
    WriteLn('(27) Entdeckungsdatum               :   ',DiscoveryDate);
    WriteLn('(28) Entdecker/-team                :   ',Discoverer);
    WriteLn('(29) Notiz, Bermerkung etc.         :   ',Remarks);
    WriteLn(^j'(30) FERTIG');
    Exit := False;
    GotoXY(1,44);
    Write('Eingabe:');
    REPEAT
      GotoXY(10,44); Write('   ');
      GotoXY(10,44);
      Input  := ReadKey;
      GotoXY(10,44); Write(Input);
      Input2 := ReadKey;
      GotoXY(11,44); Write(Input2);
      IF Input = '1' THEN CASE Input2 OF
        '1' : BEGIN
                GotoXY(41,21);
                ClrEol;
                GotoXY(41,21);
                CentralStar := ReadStr(35);
                GotoXY(1,21);
              END;
        '2' : BEGIN
                GotoXY(41,22);
                ClrEol;
                GotoXY(41,22);
                SpectralType := ReadStr(35);
                GotoXY(1,22);
              END;
        '3' : BEGIN
                GotoXY(41,23);
                ClrEol;
                GotoXY(41,23);
                Magnitude := ReadReal(11);
                GotoXY(1,23);
              END;
        '4' : BEGIN
                GotoXY(41,24);
                ClrEol;
                GotoXY(41,24);
                StarMass := ReadReal(11);
                GotoXY(1,24);
              END;
        '5' : BEGIN
                GotoXY(41,25);
                ClrEol;
                GotoXY(41,25);
                Metalicity := ReadReal(11);
                IF Korrektur THEN BEGIN
                  Write(' +/- ');
                  Metalicity2 := ReadReal(11);
                END;
                GotoXY(1,25);
              END;
        '6' : BEGIN
                GotoXY(41,26);
                ClrEol;
                GotoXY(41,26);
                Distance := ReadReal(11);
                GotoXY(1,26);
              END;
        '7' : BEGIN
                GotoXY(41,27);
                ClrEol;
                GotoXY(41,27);
                Rectaszension := ReadHMS;
                GotoXY(1,27);
              END;
        '8' : BEGIN
                GotoXY(41,28);
                ClrEol;
                GotoXY(41,28);
                Deklination := ReadDeg;
                GotoXY(1,28);
              END;
        '9' : BEGIN
                GotoXY(41,29);
                ClrEol;
                GotoXY(41,29);
                ReadLn(Constellation);
                GotoXY(1,29);
              END;
      END ELSE IF Input = '2' THEN CASE Input2 OF
        '1' : BEGIN
                GotoXY(41,33);
                ClrEol;
                GotoXY(41,33);
                PlanetName := ReadStr(35);
                GotoXY(1,33);
              END;
        '2' : BEGIN
                GotoXY(41,34);
                ClrEol;
                GotoXY(41,34);
                PlanetMass := ReadReal(11);
                IF Korrektur THEN BEGIN
                  Write(' +/- ');
                  PlanetMass2 := ReadReal(11);
                END;
                GotoXY(1,34);
              END;
        '3' : BEGIN
                GotoXY(41,35);
                ClrEol;
                GotoXY(41,35);
                SemiMajorAxis := ReadReal(11);
                IF Korrektur THEN BEGIN
                  Write(' +/- ');
                  SemiMajorAxis2 := ReadReal(11);
                END;
                GotoXY(1,35);
              END;
        '4' : BEGIN
                GotoXY(41,36);
                ClrEol;
                GotoXY(41,36);
                Period := ReadReal(11);
                IF Korrektur THEN BEGIN
                  Write(' +/- ');
                  Period2 := ReadReal(11);
                END;
                GotoXY(1,36);
              END;
        '5' : BEGIN
                GotoXY(41,37);
                ClrEol;
                GotoXY(41,37);
                Eccentricity := ReadReal(11);
                IF Korrektur THEN BEGIN
                  Write(' +/- ');
                  Eccentricity2 := ReadReal(11);
                END;
                GotoXY(1,37);
              END;
        '6' : BEGIN
                GotoXY(41,38);
                ClrEol;
                GotoXY(41,38);
                DiscoveryDate := ReadStr(35);
                GotoXY(1,38);
              END;
        '7' : BEGIN
                GotoXY(41,39);
                ClrEol;
                GotoXY(41,39);
                Method := ReadStr(35);
                GotoXY(1,39);
              END;
        '8' : BEGIN
                GotoXY(41,40);
                ClrEol;
                GotoXY(41,40);
                Discoverer := ReadStr(35);
                GotoXY(1,40);
              END;
        '9' : BEGIN
                GotoXY(41,41);
                ClrEol;
                GotoXY(41,41);
                Remarks := ReadStr(35);
                GotoXY(1,41);
              END;
      END ELSE IF Input = '3' THEN CASE Input2 OF
        '0' : Exit := True;
      END;
    UNTIL Exit;
    Exit := False;
    Assign(f,'EXO\'+Fil[1]+'.EXO');
    Rewrite(f);
    WriteLn(f,Centralstar);
    WriteLn(f,SpectralType);
    WriteLn(f,Magnitude);
    WriteLn(f,StarMass);
    IF Korrektur THEN BEGIN
      WriteLn(f,Metalicity,Metalicity2);
    END ELSE WriteLn(f,Metalicity);
    WriteLn(f,Distance);
    WriteLn(f,Rectaszension);
    WriteLn(f,Deklination);
    WriteLn(f,Constellation);
    WriteLn(f,PlanetName);
    IF Korrektur THEN BEGIN
      WriteLn(f,PlanetMass,PlanetMass2);
    END ELSE WriteLn(f,PlanetMass);
    IF Korrektur THEN BEGIN
      WriteLn(f,SemiMajorAxis,SemiMajorAxis2);
     END ELSE WriteLn(f,SemiMajorAxis);
    IF Korrektur THEN BEGIN
      WriteLn(f,Period,Period2);
    END ELSE WriteLn(f,Period);
    IF Korrektur THEN BEGIN
      WriteLn(f,Eccentricity,Eccentricity2);
    END ELSE WriteLn(f,Eccentricity);
    WriteLn(f,Method);
    WriteLn(f,DiscoveryDate);
    WriteLn(f,Discoverer);
    WriteLn(f,Remarks);
    Close(f);
    Write(^j^j'Datei ist gesichert! Eine beliebige Taste dr�cken!');
  END ELSE WriteLn('Diese Datei wurde nicht befunden!');
  ReadKey;
  FOR i := 1 TO 40 DO BEGIN
  GotoXY(1,12+i);
  InsLine;
  END;
  GotoXY(1,5);
END;

PROCEDURE Delete;
BEGIN
  GotoXY(1,15);
  Write('Name der Datei zum Speichern (max. 8): ');
  ReadLn(Fil[1]);
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF FileExists('EXO\'+Fil[1]+'.EXO') THEN BEGIN
    Assign(f,'EXO\'+Fil[1]+'.EXO');
    Erase(f);
    Write('Datei ist gel�scht! Eine beliebige Taste dr�cken!');
  END ELSE WriteLn('Diese Datei ist nicht gefunden!');
  ReadKey;
  FOR i := 1 TO 40 DO BEGIN
    GotoXY(1,12+i);
    InsLine;
  END;
  GotoXY(1,5);
END;

PROCEDURE Print;
BEGIN
  GotoXY(1,14);
  Write('Mit Fehlerspanne? (j/n)');
  REPEAT
    Input := ReadKey;
  UNTIL Input IN ['j','J','y','Y','z','Z','n','N'];
  IF Input IN ['N','n'] THEN Korrektur := False ELSE Korrektur := True;
  GotoXY(1,15);
  Write('Name der Datei zum Drucken (max. 8): ');
  ReadLn(Fil[1]);
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF FileExists('EXO\'+Fil[1]+'.EXO') THEN BEGIN
    Assign(f,'EXO\'+Fil[1]+'.EXO');
    Reset(f);
    ReadLn(f,Centralstar);
    ReadLn(f,SpectralType);
    ReadLn(f,Magnitude);
    ReadLn(f,StarMass);
    IF Korrektur THEN BEGIN
      ReadLn(f,Metalicity,Metalicity2);
    END ELSE ReadLn(f,Metalicity);
    ReadLn(f,Distance);
    ReadLn(f,Rectaszension);
    ReadLn(f,Deklination);
    ReadLn(f,Constellation);
    ReadLn(f,PlanetName);
    IF Korrektur THEN BEGIN
      ReadLn(f,PlanetMass,PlanetMass2);
    END ELSE ReadLn(f,PlanetMass);
    IF Korrektur THEN BEGIN
      ReadLn(f,SemiMajorAxis,SemiMajorAxis2);
    END ELSE ReadLn(f,SemiMajorAxis);
    IF Korrektur THEN BEGIN
      ReadLn(f,Period,Period2);
    END ELSE ReadLn(f,Period);
    IF Korrektur THEN BEGIN
      ReadLn(f,Eccentricity,Eccentricity2);
    END ELSE ReadLn(f,Eccentricity);
    ReadLn(f,Method);
    ReadLn(f,DiscoveryDate);
    ReadLn(f,Discoverer);
    ReadLn(f,Remarks);
    Close(f);
    n := Port[$379];
    CASE n OF
      071 : WriteLn(^j^j'Der Drucker ist an, aber offline.');
      105 : WriteLn(^j^j'Papier nachf�llen.');
      135 : WriteLn(^j^j'Der Drucker ist ausgeschaltet.');
    END;
    IF n = 233 THEN BEGIN
      WriteLn(Lst,'EXOPLANETEN-DATENBANK (EXO-DB2)');
      WriteLn(Lst,'Version: 0.5  (C) Michael Johne 1995-2003');
      WriteLn(Lst,^j'DATENANGABE ZUM ZENTRALSTERN');
      WriteLn(Lst,'----------------------------');
      WriteLn(Lst,'Name des Zentralsterns         :   ',CentralStar);
      WriteLn(Lst,'Spektraltyp/Leuchtkraftklasse  :   ',Spectraltype);
      WriteLn(Lst,'Scheinbare Helligkeit mag      :   ',Magnitude:0:2);
      WriteLn(Lst,' Masse in Sonnenmasse           :   ',StarMass:0:2);
      IF Korrektur THEN BEGIN
        WriteLn(Lst,'Metallizit�t                   :   ',Metalicity:0:2,'+/-',Metalicity2:0:2);
      END ELSE WriteLn(Lst,'Metallizit�t                   :   ',Metalicity:0:2);;
      WriteLn(Lst,'Entfernung zur Sonne in Parsec :   ',Distance:0:2);
      WriteLn(Lst,'Rektaszension (2000)           :   ',Rectaszension:0:4);
      WriteLn(Lst,'Deklination (2000)             :   ',Deklination:0:4);
      WriteLn(Lst,'Sternbild                      :   ',Constellation);
      WriteLn(Lst,^j'DATENANGABE ZUM EXOPLANETEN');
      WriteLn(Lst,'---------------------------');
      WriteLn(Lst,'Standardbezeichnung des Planet :   ',PlanetName);
      IF Korrektur THEN BEGIN
        WriteLn(Lst,'Masse in Jupitermasse          :   ',PlanetMass:0:2,' +/- ',PlanetMass2:0:2);
      END ELSE WriteLn(Lst,'Masse in Jupitermasse          :   ',PlanetMass:0:2);
      IF Korrektur THEN BEGIN
        WriteLn(Lst,'Gro�e Halbachse in AE          :   ',SemiMajorAxis:0:2,' +/- ',SemiMajorAxis2:0:2);
      END ELSE WriteLn(Lst,'Gro�e Halbachse in AE          :   ',SemiMajorAxis:0:2);
      IF Korrektur THEN BEGIN
        WriteLn(Lst,'Umlaufzeit in Tage             :   ',Period:0:2,' +/- ',Period2:0:2);
      END ELSE WriteLn(Lst,'Umlaufzeit in Tage             :   ',Period:0:2);
      IF Korrektur THEN BEGIN
        WriteLn(Lst,'Num. Exzentizit�t              :   ',Eccentricity:0:2,' +/- ',Eccentricity2:0:2);
      END ELSE WriteLn(Lst,'Num. Exzentizit�t              :   ',Eccentricity:0:2);
      WriteLn(Lst,'Methode der Entdeckung         :   ',Method);
      WriteLn(Lst,'Entdeckungsdatum               :   ',DiscoveryDate);
      WriteLn(Lst,'Entdecker/-team                :   ',Discoverer);
      WriteLn(Lst,'Notiz, Bermerkung etc.         :   ',Remarks);
    END ELSE BEGIN
      IF NOT(n IN [71,105,135]) THEN WriteLn(^j^j'Unbekannter Fehler.');
      ReadKey;
    END;
  END ELSE WriteLn('Diese Datei ist nicht gefunden!');
  ReadKey;
  FOR i := 1 TO 40 DO BEGIN
    GotoXY(1,12+i);
    InsLine;
  END;
  GotoXY(1,5);
END;

PROCEDURE Plugin_Orbit;
BEGIN
  {$M 50000,0,0}
  IF NOT(FileExists('orbit.exe')) AND NOT(FileExists('orbit.dat')) THEN BEGIN
    WriteLn(^j^j'Dieses Plugin wurde nicht gefunden!');
    ReadKey;
  END ELSE BEGIN
    IF FileExists('orbit.exe') THEN BEGIN
      IF FileExists('orbit.dat') THEN BEGIN
        Assign(f2,'orbit.dat');
        Erase(f2);
      END;
       Assign(f2,'orbit.exe');
      Rename(f2,'orbit.dat');
    END;
    Fil[0] := '';
    GotoXY(1,15);
    WriteLn('PLUGIN Orbit: Dieses Plugin stellt die Bahn eines Exoplaneten oder auch mehrere');
    WriteLn('im Verh�ltnis zu unserem Sonnensystem dar auf dem Monitor dar.');
    WriteLn('-------------------------------------------------------------------------------'^j);
    Write('Zoom-Faktor (z. B. 100): '); Zoom := ReadInt(4); WriteLn(' %');
    Write('Anzahl der Exoplaneten (max. 20): '); Numb := ReadInt(4); WriteLn;
    FOR i := 1 TO Numb DO BEGIN
      Write('Name des ',i,'. Datensatzes: ');
      Fil[1] := ReadStr(20);
      Fil[0] := Fil[0]+' '+Fil[1];
      WriteLn;
    END;
    Write('Mittelpunktverschiebung x-Achse: '); mx := ReadInt(5); WriteLn;
    Write('Mittelpunktverschiebung y-Achse: '); my := ReadInt(5); WriteLn;
    Str(Zoom,Zoom2);
    Str(Numb,Numb2);
    Str(mx,mx2);
    Str(my,my2);
    Assign(f2,'orbit.dat');
    Rename(f2,'orbit.exe');
    WriteLn('orbit.exe '+Numb2+Fil[0]+' '+Zoom2+' '+mx2+' '+my2);
    Exec('orbit.exe',' '+Numb2+Fil[0]+' '+Zoom2+' '+mx2+' '+my2);
    Rename(f2,'orbit.dat');
  END;
  MainApp;
END;

PROCEDURE Plugin_Starmap;
BEGIN
  {$M 50000,0,0}
  IF NOT(FileExists('starmap.exe')) AND NOT(FileExists('starmap.dat')) THEN BEGIN
    WriteLn(^j^j'Dieses Plugin wurde nicht gefunden!');
    ReadKey;
  END ELSE BEGIN
    IF FileExists('starmap.exe') THEN BEGIN
      IF FileExists('starmap.dat') THEN BEGIN
        Assign(f2,'starmap.dat');
        Erase(f2);
      END;
       Assign(f2,'starmap.exe');
      Rename(f2,'starmap.dat');
    END;
    Fil[0] := '';
    GotoXY(1,15);
    WriteLn('PLUGIN Starmap: Dieses Plugin stellt die Lage des Zentralsterns eines Exoplan-');
    WriteLn('eten oder auch mehrere auf einer Sternkarte am Monitor dar.');
    WriteLn('-------------------------------------------------------------------------------'^j);
    Write('Anzahl der Exoplaneten (max. 20): '); Numb := ReadInt(4); WriteLn;
    FOR i := 1 TO Numb DO BEGIN
      Write('Name des ',i,'. Datensatzes: ');
      Fil[1] := ReadStr(20);
      Fil[0] := Fil[0]+' '+Fil[1];
      WriteLn;
    END;
    Numb3 := 0;
    Write('Mit einfachen Gradnetz? [j/n]: ');
    REPEAT
      Input := Readkey;
      Input := UpCase(Input);
    UNTIL Input IN ['Y','Z','J','N'];
    IF Input <> 'N' THEN Inc(Numb3,8);
    Write(Input);
    WriteLn;
    Write('Mit Ekliptik u. Himmels�quator? [j/n]: ');
    REPEAT
      Input := Readkey;
      Input := UpCase(Input);
    UNTIL Input IN ['Y','Z','J','N'];
    IF Input <> 'N' THEN Inc(Numb3,4);
    Write(Input);
    WriteLn;
    Write('Mit Konstellationen f�r Sternbilder? [j/n]: ');
    REPEAT
      Input := Readkey;
      Input := UpCase(Input);
    UNTIL Input IN ['Y','Z','J','N'];
    IF Input <> 'N' THEN Inc(Numb3,2);
    Write(Input);
    WriteLn;
    Str(Numb,Numb2);
    Str(Numb3,Numb4);
    Assign(f2,'starmap.dat');
    Rename(f2,'starmap.exe');
    WriteLn('starmap.exe '+Numb2+Fil[0]+' '+Numb4);
    Exec('starmap.exe',' '+Numb2+Fil[0]+' '+Numb4);
    Rename(f2,'starmap.dat');
  END;
  MainApp;
END;

PROCEDURE Plugin_MassCompare;
BEGIN
  {$M 50000,0,0}
  IF NOT(FileExists('masscomp.exe')) AND NOT(FileExists('masscomp.dat')) THEN BEGIN
    WriteLn(^j^j'Dieses Plugin wurde nicht gefunden!');
    ReadKey;
  END ELSE BEGIN
    IF FileExists('masscomp.exe') THEN BEGIN
      IF FileExists('masscomp.dat') THEN BEGIN
        Assign(f2,'masscomp.dat');
        Erase(f2);
      END;
       Assign(f2,'masscomp.exe');
      Rename(f2,'masscomp.dat');
    END;
    Fil[0] := '';
    GotoXY(1,15);
    WriteLn('PLUGIN MasseCompare: Dieses Plugin stellt die Bahn eines Exoplaneten oder auch');
    WriteLn('mehrere im Verh�ltnis zu unserem Sonnensystem dar auf dem Monitor dar.');
    WriteLn('-------------------------------------------------------------------------------'^j);
    Write('Anzahl der Exoplaneten (max. 5): '); Numb := ReadInt(4); WriteLn;
    FOR i := 1 TO Numb DO BEGIN
      Write('Name des ',i,'. Datensatzes: ');
      Fil[1] := ReadStr(20);
      Fil[0] := Fil[0]+' '+Fil[1];
      WriteLn;
    END;
    Str(Numb,Numb2);
    Assign(f2,'masscomp.dat');
    Rename(f2,'masscomp.exe');
    WriteLn('masscomp.exe '+Numb2+Fil[0]+' ');
    Exec('masscomp.exe',' '+Numb2+Fil[0]+' ');
    Rename(f2,'masscomp.dat');
  END;
  MainApp;
END;

PROCEDURE Convert;
BEGIN
  {$M 50000,0,0}
  IF NOT(FileExists('convert.exe')) THEN BEGIN
    WriteLn(^j^j'Das Konvertierungsprogramm wurde nicht gefunden!');
  END ELSE BEGIN
    GotoXY(1,15);
    WriteLn('Konvertierungstool: convert.exe');
    WriteLn('------------------------------'^j);
    Write('Datensatz im EXODB(1)-Format (max 8.; ohne [.EXO]): ');
    Fil[0] := ReadStr(20);
    WriteLn;
    Exec('convert.exe',Fil[0]);
  END;
  MainApp;
END;

BEGIN
  MainApp;
  REPEAT
    Input := Readkey;
    CASE Input OF
      '0' : Exit := True;
      '1' : Add;
      '2' : Change;
      '3' : Delete;
      '4' : Print;
      '5' : Plugin_Orbit;
      '6' : Plugin_Starmap;
      '7' : Plugin_MassCompare;
      '8' : Convert;
    END;
  UNTIL Exit;
END.