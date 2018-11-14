PROGRAM EXO_DB2_v01;

USES Crt,Dos,Graph,Printer;

VAR
  Exit            : Boolean;
  n,i             : Byte;
  Input,Input2    : Char;
  a,p,e           : Real;
  Fil             : STRING[12];
  f               : Text;
  CentralStar,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Remarks,
  SpectralType    : STRING;
  Deklination,
  Distance,
  Eccentricity,
  Metalicity,
  Period,
  PlanetMass,
  Rectaszension,
  SemiMajorAxis,
  StarMass        : Real;

PROCEDURE Add;
BEGIN
  GotoXY(1,15);
  WriteLn('DATENANGABE ZUM ZENTRALSTERN');
  WriteLn('----------------------------');
  WriteLn('Name des Zentralsterns         :');
  WriteLn('Spektraltyp/Leuchtkraftklasse  :');
  WriteLn('Masse in Sonnenmasse           :');
  WriteLn('MetallizitÑt                   :');
  WriteLn('Entfernung zur Sonne in Parsec :');
  WriteLn('Rektaszension (2000)           :');
  WriteLn('Deklination (2000)             :');
  WriteLn('Sternbild                      :');
  WriteLn(^j'DATENANGABE ZUM EXOPLANETEN');
  WriteLn('---------------------------');
  WriteLn('Masse in Jupitermasse          :');
  WriteLn('Gro·e Halbachse in AE          :');
  WriteLn('Umlaufzeit in Tage             :');
  WriteLn('Num. ExzentizitÑt              :');
  WriteLn('Entdeckungsdatum               :');
  WriteLn('Entdecker/-team                :');
  WriteLn('Notiz, Bermerkung etc.         :');
  GotoXY(36,17); ReadLn(Centralstar);
  GotoXY(36,18); ReadLn(SpectralType);
  GotoXY(36,19); ReadLn(StarMass);
  GotoXY(36,20); ReadLn(Metalicity);
  GotoXY(36,21); ReadLn(Distance);
  GotoXY(36,22); ReadLn(Rectaszension);
  GotoXY(36,23); ReadLn(Deklination);
  GotoXY(36,24); ReadLn(Constellation);
  GotoXY(36,28); ReadLn(PlanetMass);
  GotoXY(36,29); ReadLn(SemiMajorAxis);
  GotoXY(36,30); ReadLn(Period);
  GotoXY(36,31); ReadLn(Eccentricity);
  GotoXY(36,32); ReadLn(DiscoveryDate);
  GotoXY(36,33); ReadLn(Discoverer);
  GotoXY(36,34); ReadLn(Remarks);
  Write(^j'Name der Datei zum Speichern (max. 8): ');
  ReadLn(Fil);
  Assign(f,Fil+'.EXO');
  Rewrite(f);
  WriteLn(f,Centralstar);
  WriteLn(f,SpectralType);
  WriteLn(f,StarMass);
  WriteLn(f,Metalicity);
  WriteLn(f,Distance);
  WriteLn(f,Rectaszension);
  WriteLn(f,Deklination);
  WriteLn(f,Constellation);
  WriteLn(f,PlanetMass);
  WriteLn(f,SemiMajorAxis);
  WriteLn(f,Period);
  WriteLn(f,Eccentricity);
  WriteLn(f,DiscoveryDate);
  WriteLn(f,Discoverer);
  WriteLn(f,Remarks);
  Close(f);
  Write('Datei ist gespeichert! Eine beliebige Taste drÅcken!');
  ReadKey;
  FOR i := 1 TO 40 DO BEGIN
    GotoXY(1,12+i);
    InsLine;
  END;
  GotoXY(1,5);
END;

PROCEDURE Change;
BEGIN
  GotoXY(1,15);
  Write('Name der Datei zum éndern (max. 8): ');
  ReadLn(Fil);
  Assign(f,Fil+'.EXO');
  Reset(f);
  ReadLn(f,Centralstar);
  ReadLn(f,SpectralType);
  ReadLn(f,StarMass);
  ReadLn(f,Metalicity);
  ReadLn(f,Distance);
  ReadLn(f,Rectaszension);
  ReadLn(f,Deklination);
  ReadLn(f,Constellation);
  ReadLn(f,PlanetMass);
  ReadLn(f,SemiMajorAxis);
  ReadLn(f,Period);
  ReadLn(f,Eccentricity);
  ReadLn(f,DiscoveryDate);
  ReadLn(f,Discoverer);
  ReadLn(f,Remarks);
  Close(f);
  WriteLn('Der Datei-Inhalt wurde gelesen.');
  WriteLn(^j^j'     DATENANGABE ZUM ZENTRALSTERN');
  WriteLn('     ----------------------------');
  WriteLn('(11) Name des Zentralsterns         :   ',CentralStar);
  WriteLn('(12) Spektraltyp/Leuchtkraftklasse  :   ',Spectraltype);
  WriteLn('(13) Masse in Sonnenmasse           :   ',StarMass:0:2);
  WriteLn('(14) MetallizitÑt                   :   ',Metalicity:0:2);
  WriteLn('(15) Entfernung zur Sonne in Parsec :   ',Distance:0:2);
  WriteLn('(16) Rektaszension (2000)           :   ',Rectaszension:0:4);
  WriteLn('(17) Deklination (2000)             :   ',Deklination:0:4);
  WriteLn('(18) Sternbild                      :   ',Constellation);
  WriteLn(^j'     DATENANGABE ZUM EXOPLANETEN');
  WriteLn('     ---------------------------');
  WriteLn('(21) Masse in Jupitermasse          :   ',PlanetMass:0:2);
  WriteLn('(22) Gro·e Halbachse in AE          :   ',SemiMajorAxis:0:2);
  WriteLn('(23) Umlaufzeit in Tage             :   ',Period:0:2);
  WriteLn('(24) Num. ExzentizitÑt              :   ',Eccentricity:0:2);
  WriteLn('(25) Entdeckungsdatum               :   ',DiscoveryDate);
  WriteLn('(26) Entdecker/-team                :   ',Discoverer);
  WriteLn('(27) Notiz, Bermerkung etc.         :   ',Remarks);
  WriteLn(^j'(30) FERTIG');
  Exit := False;
  GotoXY(1,42);
  Write('Eingabe:');
  REPEAT
    GotoXY(10,42); Write('   ');
    GotoXY(10,42);
    Input  := ReadKey;
    GotoXY(10,42); Write(Input);
    Input2 := ReadKey;
    GotoXY(11,42); Write(Input2);
    IF Input = '1' THEN CASE Input2 OF
      '1' : BEGIN
              GotoXY(41,21);
              ClrEol;
              GotoXY(41,21);
              ReadLn(CentralStar);
              GotoXY(1,21);
            END;
      '2' : BEGIN
              GotoXY(41,22);
              ClrEol;
              GotoXY(41,22);
              ReadLn(SpectralType);
              GotoXY(1,22);
            END;
      '3' : BEGIN
              GotoXY(41,23);
              ClrEol;
              GotoXY(41,23);
              ReadLn(StarMass);
              GotoXY(1,23);
            END;
      '4' : BEGIN
              GotoXY(41,24);
              ClrEol;
              GotoXY(41,24);
              ReadLn(Metalicity);
              GotoXY(1,24);
            END;
      '5' : BEGIN
              GotoXY(41,25);
              ClrEol;
              GotoXY(41,25);
              ReadLn(Distance);
              GotoXY(1,25);
            END;
      '6' : BEGIN
              GotoXY(41,26);
              ClrEol;
              GotoXY(41,26);
              ReadLn(Rectaszension);
              GotoXY(1,26);
            END;
      '7' : BEGIN
              GotoXY(41,27);
              ClrEol;
              GotoXY(41,27);
              ReadLn(Deklination);
              GotoXY(1,27);
            END;
      '8' : BEGIN
              GotoXY(41,28);
              ClrEol;
              GotoXY(41,28);
              ReadLn(Constellation);
              GotoXY(1,28);
            END;
    END ELSE IF Input = '2' THEN CASE Input2 OF
      '1' : BEGIN
              GotoXY(41,32);
              ClrEol;
              GotoXY(41,32);
              ReadLn(PlanetMass);
              GotoXY(1,32);
            END;
      '2' : BEGIN
              GotoXY(41,33);
              ClrEol;
              GotoXY(41,33);
              ReadLn(SemiMajorAxis);
              GotoXY(1,33);
            END;
      '3' : BEGIN
              GotoXY(41,34);
              ClrEol;
              GotoXY(41,34);
              ReadLn(Period);
              GotoXY(1,34);
            END;
      '4' : BEGIN
              GotoXY(41,35);
              ClrEol;
              GotoXY(41,35);
              ReadLn(Eccentricity);
              GotoXY(1,35);
            END;
      '5' : BEGIN
              GotoXY(41,36);
              ClrEol;
              GotoXY(41,36);
              ReadLn(DiscoveryDate);
              GotoXY(1,36);
            END;
      '6' : BEGIN
              GotoXY(41,37);
              ClrEol;
              GotoXY(41,37);
              ReadLn(Discoverer);
              GotoXY(1,37);
            END;
      '7' : BEGIN
              GotoXY(41,38);
              ClrEol;
              GotoXY(41,38);
              ReadLn(Remarks);
              GotoXY(1,38);
            END;
    END ELSE IF Input = '3' THEN CASE Input2 OF
      '0' : Exit := True;
    END;
  UNTIL Exit;
  Exit := False;
  Assign(f,Fil+'.EXO');
  Rewrite(f);
  WriteLn(f,Centralstar);
  WriteLn(f,SpectralType);
  WriteLn(f,StarMass);
  WriteLn(f,Metalicity);
  WriteLn(f,Distance);
  WriteLn(f,Rectaszension);
  WriteLn(f,Deklination);
  WriteLn(f,Constellation);
  WriteLn(f,PlanetMass);
  WriteLn(f,SemiMajorAxis);
  WriteLn(f,Period);
  WriteLn(f,Eccentricity);
  WriteLn(f,DiscoveryDate);
  WriteLn(f,Discoverer);
  WriteLn(f,Remarks);
  Close(f);
  Write(^m^j^j'Datei ist gesichert! Eine beliebige Taste drÅcken!');
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
  ReadLn(Fil);
  Assign(f,Fil+'.EXO');
  Erase(f);
  Write('Datei ist gelîscht! Eine beliebige Taste drÅcken!');
  ReadKey;
  FOR i := 1 TO 40 DO BEGIN
    GotoXY(1,12+i);
    InsLine;
  END;
  GotoXY(1,5);
END;

PROCEDURE Print;
BEGIN
  GotoXY(1,15);
  Write('Name der Datei zum Drucken (max. 8): ');
  ReadLn(Fil);
  Assign(f,Fil+'.EXO');
  Reset(f);
  ReadLn(f,Centralstar);
  ReadLn(f,SpectralType);
  ReadLn(f,StarMass);
  ReadLn(f,Metalicity);
  ReadLn(f,Distance);
  ReadLn(f,Rectaszension);
  ReadLn(f,Deklination);
  ReadLn(f,Constellation);
  ReadLn(f,PlanetMass);
  ReadLn(f,SemiMajorAxis);
  ReadLn(f,Period);
  ReadLn(f,Eccentricity);
  ReadLn(f,DiscoveryDate);
  ReadLn(f,Discoverer);
  ReadLn(f,Remarks);
  Close(f);
  WriteLn(Lst,'EXOPLANETEN-DATENBANK (EXO-DB2)');
  WriteLn(Lst,'Version: 0.1  (C) Michael Johne 1995-2003');
  WriteLn(Lst,^j'DATENANGABE ZUM ZENTRALSTERN');
  WriteLn(Lst,'----------------------------');
  WriteLn(Lst,'Name des Zentralsterns         :',CentralStar);
  WriteLn(Lst,'Spektraltyp/Leuchtkraftklasse  :',SpectralType);
  WriteLn(Lst,'Masse in Sonnenmasse           :',StarMass:0:2);
  WriteLn(Lst,'MetallizitÑt                   :',Metalicity:0:2);
  WriteLn(Lst,'Entfernung zur Sonne in Parsec :',Distance:0:2);
  WriteLn(Lst,'Rektaszension (2000)           :',Rectaszension:0:4);
  WriteLn(Lst,'Deklination (2000)             :',Deklination:0:4);
  WriteLn(Lst,'Sternbild                      :',Constellation);
  WriteLn(Lst,^j'DATENANGABE ZUM EXOPLANETEN');
  WriteLn(Lst,'---------------------------');
  WriteLn(Lst,'Masse in Jupitermasse          :',Planetmass:0:2);
  WriteLn(Lst,'Gro·e Halbachse in AE          :',SemiMajorAxis:0:2);
  WriteLn(Lst,'Umlaufzeit in Tage             :',Period:0:2);
  WriteLn(Lst,'Num. ExzentizitÑt              :',Eccentricity:0:4);
  WriteLn(Lst,'Entdeckungsdatum               :',DiscoveryDate);
  WriteLn(Lst,'Entdecker/-team                :',Discoverer);
  WriteLn(Lst,'Notiz, Bermerkung etc.         :',Remarks);
  Write('Datei ist gedruckt! Eine beliebige Taste drÅcken!');
  ReadKey;
  FOR i := 1 TO 40 DO BEGIN
    GotoXY(1,12+i);
    InsLine;
  END;
  GotoXY(1,5);
END;

BEGIN
  ClrScr;
  TextMode(300);
  TextColor(White);
  Exit := False;
  WriteLn('EXOPLANETEN-DATENBANK (EXO-DB2)     Version: 0.1     (C) 1995-2003 Michael Johne');
  WriteLn('===============================     ------------     ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ');
  WriteLn(^j^j'(1) - Neuen Datensatz anlegen');
  WriteLn('(2) - Vorhandenen Datensatz Ñndern');
  WriteLn('(3) - Existierenden Datensatz lîschen');
  WriteLn('(4) - Vorhandenen Datensatz drucken');
  WriteLn('(5) - EXIT');
  REPEAT
    Input := Readkey;
    CASE Input OF
      '1' : Add;
      '2' : Change;
      '3' : Delete;
      '4' : Print;
      '5' : Exit := True;
    END;
  UNTIL Exit;
END.