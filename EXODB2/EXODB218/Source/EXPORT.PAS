PROGRAM Plugin_Export;

USES Crt,Dos,RT_Watch;

VAR
  Fil             : ARRAY[1..20] OF STRING;
  Input           : Char;
  Control,i       : Integer;
  a,p,e,b,c,
  Numb            : Real;
  regs            : Registers;
  Format          : STRING;
  f               : Text;
  PlanetMass2,
  CentralStar,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Method,
  PlanetName,
  Remarks,
  SpectralType    : ARRAY[1..20] OF STRING;
  Deklination,
  Distance,
  Eccentricity,
  Magnitude,
  Metalicity,
  Period,
  PlanetMass,
  Rectaszension,
  SemiMajorAxis,
  StarMass        : ARRAY[1..20] OF Real;

FUNCTION FileExists(FName : STRING) : Boolean;
VAR
  f     : FILE;
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

FUNCTION DeleteFile(FileName : STRING) : Boolean;
VAR
  FileAttr : Word;
  FileHandle : Text;
BEGIN
  Assign(FileHandle,FileName);
  GetFAttr(FileHandle,FileAttr);
  IF (FileAttr AND ReadOnly) <> 0 THEN SetFAttr(FileHandle,FileAttr AND (NOT ReadOnly));
  Erase(FileHandle);
  DeleteFile := (IOResult=0);
END;

FUNCTION UpString(inString : STRING) : STRING;
VAR
  index : Byte;
  tempString : STRING;
BEGIN
  FOR index := 1 TO Length(inString) DO tempString[index] := UpCase(inString[index]);
  tempString[0] := inString[0];
  UpString := tempString;
END;

BEGIN
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF ParamStr(1) = '' THEN BEGIN
    ClrScr;
    WriteLn(^j^j'Der Parameter als Anzahl der darzustellende Datens„tze fehlt!');
    WriteLn('    -  EXPORT.EXE [format] [dateiname]');
    WriteLn(^j'Achten Sie darauf, dass die Datens„tze im Verzeichnis "EXO"');
    WriteLn('des Hauptverzeichis liegen.');
    ReadKey;
    Halt;
  END ELSE IF ParamStr(2) = '' THEN BEGIN
    ClrScr;
    WriteLn(^j^j'Der Parameter fehlt! Aufruf des Datenansatz ohne [.EXO]:');
    WriteLn('    -  EXPORT.EXE [format] [dateiname]');
    WriteLn(^j'Achten Sie darauf, dass die Datens„tze im Verzeichnis "EXO"');
    WriteLn('des Hauptverzeichis liegen.');
    ReadKey;
  END ELSE BEGIN
    Assign(f,'EXO/'+ParamStr(2)+'.EXO');
    Reset(f);
    ReadLn(f,Centralstar[1]);
    ReadLn(f,SpectralType[1]);
    ReadLn(f,Magnitude[1]);
    ReadLn(f,StarMass[1]);
    ReadLn(f,Metalicity[1]);
    ReadLn(f,Distance[1]);
    ReadLn(f,Rectaszension[1]);
    ReadLn(f,Deklination[1]);
    ReadLn(f,Constellation[1]);
    ReadLn(f,PlanetName[1]);
    ReadLn(f,PlanetMass[1]);
    ReadLn(f,SemiMajorAxis[1]);
    ReadLn(f,Period[1]);
    ReadLn(f,Eccentricity[1]);
    ReadLn(f,Method[1]);
    ReadLn(f,DiscoveryDate[1]);
    ReadLn(f,Discoverer[1]);
    ReadLn(f,Remarks[1]);
    Close(f);
    IF NOT(DirExists('EXPORT')) THEN MkDir('EXPORT');
    Format := UpString(ParamStr(1));
    i := 0;
    IF Format = 'TXT' THEN i := 1;
    IF Format = 'HTM' THEN i := 2;
    IF Format = 'RTF' THEN i := 3;
    IF Format = 'CSV' THEN i := 4;
    IF Format = 'SLK' THEN i := 5;
    CASE i OF
      1 : BEGIN
            Assign(f,'EXPORT/'+ParamStr(2)+'.TXT');
            Rewrite(f);
            WriteLn(f,'EXOPLANETEN-DATENBANK (EXO-DB2)');
            WriteLn(f,'Version: 1.7 (C) Michael Johne 1995-2006');
            WriteLn(f);
            WriteLn(f,'DATENANGABE ZUM ZENTRALSTERN');
            WriteLn(f,'----------------------------');
            WriteLn(f,'Name des Zentralsterns         :   ',CentralStar[1]);
            WriteLn(f,'Spektraltyp/Leuchtkraftklasse  :   ',Spectraltype[1]);
            WriteLn(f,'Scheinbare Helligkeit mag      :   ',Magnitude[1]:0:2);
            WriteLn(f,'Masse in Sonnenmasse           :   ',StarMass[1]:0:2);
            WriteLn(f,'Metallizität                   :   ',Metalicity[1]:0:2);;
            WriteLn(f,'Entfernung zur Sonne in Parsec :   ',Distance[1]:0:2);
            WriteLn(f,'Rektaszension (2000)           :   ',Rectaszension[1]:0:4);
            WriteLn(f,'Deklination (2000)             :   ',Deklination[1]:0:4);
            WriteLn(f,'Sternbild                      :   ',Constellation[1]);
            WriteLn(f);
            WriteLn(f,'DATENANGABE ZUM EXOPLANETEN');
            WriteLn(f,'---------------------------');
            WriteLn(f,'Standardbezeichnung            :   ',PlanetName[1]);
            WriteLn(f,'Masse in Jupitermasse          :   ',PlanetMass[1]:0:2);
            WriteLn(f,'Große Halbachse in AE          :   ',SemiMajorAxis[1]:0:2);
            WriteLn(f,'Umlaufzeit in Tage             :   ',Period[1]:0:2);
            WriteLn(f,'Num. Exzentizität              :   ',Eccentricity[1]:0:2);
            WriteLn(f,'Methode der Entdeckung         :   ',Method[1]);
            WriteLn(f,'Entdeckungsdatum               :   ',DiscoveryDate[1]);
            WriteLn(f,'Entdecker/-team                :   ',Discoverer[1]);
            WriteLn(f,'Notiz, Bermerkung etc.         :   ',Remarks[1]);
            Close(f);
          END;
      2 : BEGIN
            Assign(f,'EXPORT/'+ParamStr(2)+'.HTM');
            Rewrite(f);
            WriteLn(f,'<html><head><title>',ParamStr(2),'</title></head><body>');
            WriteLn(f,'<h1>EXOPLANETEN-DATENBANK (EXO-DB2)</h1>');
            WriteLn(f,'<h3>Version: 1.7 (C) Michael Johne 1995-2006</h3>');
            WriteLn(f,'<table border="1"><tr><td colspan="2"><b>DATENANGABE ZUM ZENTRALSTERN<b></td></tr>');
            WriteLn(f,'<tr><td><b>Name des Zentralsterns</b></td><td>',CentralStar[1],'</td></tr>');
            WriteLn(f,'<tr><td><b>Spektraltyp/Leuchtkraftklasse</b></td><td>',Spectraltype[1],'</td></tr>');
            WriteLn(f,'<tr><td><b>Scheinbare Helligkeit</b> <i>mag</i></td><td>',Magnitude[1]:0:2,'</td></tr>');
            WriteLn(f,'<tr><td><b>Masse</b> <i>Sonnenmasse</i></td><td>',StarMass[1]:0:2,'</td></tr>');
            WriteLn(f,'<tr><td><b>Metallizit&auml;t</b></td><td>',Metalicity[1]:0:2,'</td></tr>');
            WriteLn(f,'<tr><td><b>Entfernung zur Sonne</b> <i>Parsec</i></td><td>',Distance[1]:0:2,'</td></tr>');
            WriteLn(f,'<tr><td><b>Rektaszension</b> <i>(J2000)</i></td><td>',Rectaszension[1]:0:4,'</td></tr>');
            WriteLn(f,'<tr><td><b>Deklination</b> <i>(J2000)</i></td><td>',Deklination[1]:0:4,'</td></tr>');
            WriteLn(f,'<tr><td><b>Sternbild</b></td><td>',Constellation[1],'</td></tr></table><p>');
            WriteLn(f,'<table border="1"><tr><td colspan="2"><b>DATENANGABE ZUM EXOPLANETEN<b></td></tr>');
            WriteLn(f,'<tr><td><b>Standardbezeichnung</b></td><td>',PlanetName[1],'</td></tr>');
            WriteLn(f,'<tr><td><b>Masse</b> <i>Jupitermasse</i></td><td>',PlanetMass[1]:0:2,'</td></tr>');
            WriteLn(f,'<tr><td><b>Gro&szlig;e Halbachse</b> <i>AE</i></td><td>',SemiMajorAxis[1]:0:2,'</td></tr>');
            WriteLn(f,'<tr><td><b>Umlaufzeit</b> <i>Tage</i></td><td>',Period[1]:0:2,'</td></tr>');
            WriteLn(f,'<tr><td><b>Num. Exzentizit&auml;t</b></td><td>',Eccentricity[1]:0:2,'</td></tr>');
            WriteLn(f,'<tr><td><b>Methode der Entdeckung</b></td><td>',Method[1],'</td></tr>');
            WriteLn(f,'<tr><td><b>Entdeckungsdatum</b></td><td>',DiscoveryDate[1],'</td></tr>');
            WriteLn(f,'<tr><td><b>Entdecker/-team</b></td><td>',Discoverer[1],'</td></tr>');
            WriteLn(f,'<tr><td><b>Notiz, Bermerkung</b> <i>etc.</i></td><td>',Remarks[1],'</td></tr></table>');
            WriteLn(f,'</body></html>');
            Close(f);
          END;
      3 : BEGIN
            Assign(f,'EXPORT/'+ParamStr(2)+'.RTF');
            Rewrite(f);
            WriteLn(f,'{\rtf1\ansi\deff0\adeflang1025');
            WriteLn(f,'{\fonttbl{\f0\froman\fprq2\fcharset0 Thorndale{\*\falt Times New Roman};}{\f1\froman\fprq2\fcharset0 ',
              'Thorndale{\*\falt Times New Roman};}{\f2\froman\fprq2\fcharset1 Times New Roman;}{\f3\fnil\fprq2\fcharset0 ',
              'Andale Sans UI{\*\falt Arial Unicode MS};}{\f4\fnil\fprq2\fcharset0 Tahoma;}{\f5\fnil\fprq0\fcharset0 ',
              'Tahoma;}}');
            WriteLn(f,'{\colortbl;\red0\green0\blue0;\red128\green128\blue128;}');
            WriteLn(f,'{\stylesheet{\s1\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af4\afs24\lang1025\ltrch\dbch\',
              'af3\afs24\langfe2052\loch\f0\fs24\lang1031\snext1 Standard;}');
            WriteLn(f,'{\s2\sa120\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af4\afs24\lang1025\ltrch\dbch\af3\',
              'afs24\langfe2052\loch\f0\fs24\lang1031\sbasedon1\snext2 Textk\',Chr(39),'f6rper;}');
            WriteLn(f,'{\s3\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af5\afs24\lang1025\ltrch\dbch\af3\afs24\',
              'langfe2052\loch\f0\fs24\lang1031\sbasedon2\snext3 Liste;}');
            WriteLn(f,'{\s4\sb120\sa120\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af5\afs20\lang1025\ai\ltrch\',
              'dbch\af3\afs20\langfe2052\ai\loch\f0\fs20\lang1031\i\sbasedon1\snext4 Beschriftung;}');
            WriteLn(f,'{\s5\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af5\afs24\lang1025\ltrch\dbch\af3\afs24\',
              'langfe2052\loch\f0\fs24\lang1031\sbasedon1\snext5 Verzeichnis;}');
            WriteLn(f,'}');
            WriteLn(f,'{\info{\creatim\yr2005\mo4\dy8\hr11\min23}{\revtim\yr2005\mo4\dy8\hr11\min34}{\printim\yr1601\mo1',
              '\dy1\hr0\min0}{\comment StarWriter}{\vern6450}}\deftab709');
            WriteLn(f,'{\*\pgdsctbl');
            WriteLn(f,'{\pgdsc0\pgdscuse195\pgwsxn11905\pghsxn16837\marglsxn1134\margrsxn1134\margtsxn1134\margbsxn1134',
              '\pgdscnxt0 Standard;}}');
            WriteLn(f,'\paperh16837\paperw11905\margl1134\margr1134\margt1134\margb1134\sectd\sbknone\pgwsxn1',
              '1905\pghsxn16837\marglsxn1134\margrsxn1134\margtsxn1134\margbsxn1134\ftnbj\ftnstart1\ftnrstcont\ftnnar\',
              'aenddoc\aftnrstcont\aftnstart1\aftnnrlc');
            WriteLn(f,'\pard\plain \ltrpar\s1\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af4\afs40\lang1025\',
              'ltrch\dbch\af3\afs40\langfe2052\loch\f2\fs40\lang1031 {\loch\f2\fs40\lang1031\i0\b0 EXOPLANETEN-DATEN',
              'BANK (EXO-DB2)}');
            WriteLn(f,'\par \pard\plain \ltrpar\s1\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af4\afs28\',
              'lang1025\ltrch\dbch\af3\afs28\langfe2052\loch\f2\fs28\lang1031 {\loch\f2\fs28\lang1031\i0\b0 Version:',
              ' 1.7 (C) Michael Johne 1995-2006}');
            WriteLn(f,'\par \pard\plain \ltrpar\s1\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af4\afs24\',
              'lang1025\ltrch\dbch\af3\afs24\langfe2052\loch\f2\fs24\lang1031 {\loch\f2\fs24\lang1031\i0\b0 \line',
              ' {\b\ul DATENANGABE ZUM ZENTRALSTERN}}');
            WriteLn(f,'\par \pard\plain \ltrpar\s1\cf0\ul{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af4\',
              'afs24\lang1025\ab\ltrch\dbch\af3\afs24\langfe2052\ab\loch\f2\fs24\lang1031\b');
            WriteLn(f,'\par \pard\plain \ltrpar\s1\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af4\',
              'afs24\lang1025\ltrch\dbch\af3\afs24\langfe2052\loch\f2\fs24\lang1031{\loch\f2\fs24\lang1031\',
              'i0\b{\b Name des Zentralsterns}}{\loch\f2\fs24\lang1031: ',CentralStar[1],'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Spektraltyp/Leuchtkraftklasse}}{\loch\f2\fs24\lang1031: ',
              Spectraltype[1],'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Scheinbare Helligkeit }}{\loch\f2\fs24\lang1031 {\i mag}: ',
              Magnitude[1]:0:2,'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Masse }}{\loch\f2\fs24\lang1031 {\i Sonnenmasse}: ',
              StarMass[1]:0:2,'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Metallizit\',Chr(39),'e4t}}{\loch\f2\fs24\lang1031: ',
              Metalicity[1]:0:2,'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Entfernung zur Sonne }}{\loch\f2\fs24\lang1031 {\i Parsec}: ',
              Distance[1]:0:2,'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Rektaszension }}{\loch\f2\fs24\lang1031 ({\i J2000}): ',
              Rectaszension[1]:0:4,'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Deklination }}{\loch\f2\fs24\lang1031 ({\i J2000}): ',
              Deklination[1]:0:4,'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Sternbild}}{\loch\f2\fs24\lang1031: ',Constellation[1],'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b0 \line {\b\ul DATENANGABE ZUM EXOPLANETEN}}');
            WriteLn(f,'\par \pard\plain \ltrpar\s1\cf0\ul{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af4\afs24\',
              'lang1025\ab\ltrch\dbch\af3\afs24\langfe2052\ab\loch\f2\fs24\lang1031\b');
            WriteLn(f,'\par \pard\plain \ltrpar\s1\cf0{\*\hyphen2\hyphlead2\hyphtrail2\hyphmax0}\rtlch\af4\afs24\lang',
              '1025\ltrch\dbch\af3\afs24\langfe2052\loch\f2\fs24\lang1031{\loch\f2\fs24\lang1031\i0\b{\b Standard',
              'bezeichnung}}{\loch\f2\fs24\lang1031: ',PlanetName[1],'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Masse }}{\loch\f2\fs24\lang1031 {\i Jupitermasse}: ',
              PlanetMass[1]:0:2,'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Gro\',Chr(39),'dfe Halbachse }}{\loch\f2\fs24\lang1031 {\i AE}: ',
              SemiMajorAxis[1]:0:2,'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Umlaufzeit }}{\loch\f2\fs24\lang1031 {\i Tage}: ',
              Period[1]:0:2,'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Num. Exzentizit\',Chr(39),'e4t}}{\loch\f2\fs24\lang1031: ',
              Eccentricity[1]:0:2,'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Methode der Entdeckung}}{\loch\f2\fs24\lang1031: ',Method[1],'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Entdeckungsdatum}}{\loch\f2\fs24\lang1031: ',DiscoveryDate[1],'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Entdecker/-team: }}{\loch\f2\fs24\lang1031',Discoverer[1],'}');
            WriteLn(f,'\par {\loch\f2\fs24\lang1031\i0\b{\b Notiz, Bermerkung }}{\loch\f2\fs24\lang1031 {\i etc}.: ',
              Remarks[1],'{\*\bkmkstart DDE_LINK1}{\*\bkmkend DDE_LINK1}}');
            WriteLn(f,'\par }');
            Close(f);
          END;
      4 : BEGIN
            Assign(f,'EXPORT/'+ParamStr(2)+'.CSV');
            Rewrite(f);
            WriteLn(f,'"EXOPLANETEN-DATENBANK (EXO-DB2)";');
            WriteLn(f,'"Version: 1.7 (C) Michael Johne 1995-2006";');
            WriteLn(f,';');
            WriteLn(f,'"DATENANGABE ZUM ZENTRALSTERN";');
            WriteLn(f,';');
            WriteLn(f,'"Name des Zentralsterns";"',CentralStar[1],'";');
            WriteLn(f,'"Spektraltyp/Leuchtkraftklasse";"',Spectraltype[1],'";');
            WriteLn(f,'"Scheinbare Helligkeit mag";',Magnitude[1]:0:2,';');
            WriteLn(f,'"Masse in Sonnenmasse";',StarMass[1]:0:2,';');
            WriteLn(f,'"Metallizität";',Metalicity[1]:0:2,';');;
            WriteLn(f,'"Entfernung zur Sonne in Parsec";',Distance[1]:0:2,';');
            WriteLn(f,'"Rektaszension (2000)";',Rectaszension[1]:0:4,';');
            WriteLn(f,'"Deklination (2000)";',Deklination[1]:0:4,';');
            WriteLn(f,'"Sternbild";"',Constellation[1],'";');
            WriteLn(f,';');
            WriteLn(f,'"DATENANGABE ZUM EXOPLANETEN";');
            WriteLn(f,';');
            WriteLn(f,'"Standardbezeichnung";"',PlanetName[1],'";');
            WriteLn(f,'"Masse in Jupitermasse";',PlanetMass[1]:0:2,';');
            WriteLn(f,'"Große Halbachse in AE";',SemiMajorAxis[1]:0:2,';');
            WriteLn(f,'"Umlaufzeit in Tage";',Period[1]:0:2,';');
            WriteLn(f,'"Num. Exzentizität";',Eccentricity[1]:0:2,';');
            WriteLn(f,'"Methode der Entdeckung";"',Method[1],'";');
            WriteLn(f,'"Entdeckungsdatum";"',DiscoveryDate[1],'";');
            WriteLn(f,'"Entdecker/-team";"',Discoverer[1],'";');
            WriteLn(f,'"Notiz, Bermerkung etc.";"',Remarks[1],'";');
            Close(f);
          END;
      5 : BEGIN
            Assign(f,'EXPORT/'+ParamStr(2)+'.SLK');
            Rewrite(f);
            WriteLn(f,'ID;PSCALC3');
            WriteLn(f,'C;X1;Y1;K"EXOPLANETEN-DATENBANK (EXO-DB2)"');
            WriteLn(f,'C;X1;Y2;K"Version: 1.7 (C) Michael Johne 1995-2006"');
            WriteLn(f,'C;X1;Y4;K"DATENANGABE ZUM ZENTRALSTERN"');
            WriteLn(f,'C;X1;Y6;K"Name des Zentralsterns"');
            WriteLn(f,'C;X2;Y6;K"',CentralStar[1],'"');
            WriteLn(f,'C;X1;Y7;K"Spektraltyp/Leuchtkraftklasse"');
            WriteLn(f,'C;X2;Y7;K"',Spectraltype[1],'"');
            WriteLn(f,'C;X1;Y8;K"Scheinbare Helligkeit mag"');
            WriteLn(f,'C;X2;Y8;K"',Magnitude[1]:0:2,'"');
            WriteLn(f,'C;X1;Y9;K"Masse in Sonnenmasse"');
            WriteLn(f,'C;X2;Y9;K"',StarMass[1]:0:2,'"');
            WriteLn(f,'C;X1;Y10;K"Metallizität"');
            WriteLn(f,'C;X2;Y10;K"',Metalicity[1]:0:2,'"');
            WriteLn(f,'C;X1;Y11;K"Entfernung zur Sonne in Parsec"');
            WriteLn(f,'C;X2;Y11;K"',Distance[1]:0:2,'"');
            WriteLn(f,'C;X1;Y12;K"Rektaszension (2000)"');
            WriteLn(f,'C;X2;Y12;K"',Rectaszension[1]:0:4,'"');
            WriteLn(f,'C;X1;Y13;K"Deklination (2000)"');
            WriteLn(f,'C;X2;Y13;K"',Deklination[1]:0:4,'"');
            WriteLn(f,'C;X1;Y14;K"Sternbild"');
            WriteLn(f,'C;X2;Y14;K"',Constellation[1],'"');
            WriteLn(f,'C;X1;Y16;K"DATENANGABE ZUM ZENTRALSTERN"');
            WriteLn(f,'C;X1;Y18;K"Standardbezeichnung');
            WriteLn(f,'C;X2;Y18;K"',PlanetName[1],'"');
            WriteLn(f,'C;X1;Y19;K"Masse in Jupitermasse"');
            WriteLn(f,'C;X2;Y19;K"',PlanetMass[1]:0:2,'"');
            WriteLn(f,'C;X1;Y20;K"Große Halbachse in AE"');
            WriteLn(f,'C;X2;Y20;K"',SemiMajorAxis[1]:0:2,'"');
            WriteLn(f,'C;X1;Y21;K"Umlaufzeit in Tage"');
            WriteLn(f,'C;X2;Y21;K"',Period[1]:0:2,'"');
            WriteLn(f,'C;X1;Y22;K"Num. Exzentizität"');
            WriteLn(f,'C;X2;Y22;K"',Eccentricity[1]:0:2,'"');
            WriteLn(f,'C;X1;Y23;K"Methode der Entdeckung"');
            WriteLn(f,'C;X2;Y23;K"',Method[1],'"');
            WriteLn(f,'C;X1;Y24;K"Entdeckungsdatum"');
            WriteLn(f,'C;X2;Y24;K"',DiscoveryDate[1],'"');
            WriteLn(f,'C;X1;Y25;K"Entdecker/-team"');
            WriteLn(f,'C;X2;Y25;K"',Discoverer[1],'"');
            WriteLn(f,'C;X1;Y26;K"Notiz, Bermerkung etc."');
            WriteLn(f,'C;X2;Y26;K"',Remarks[1],'"');
            WriteLn(f,'E');
            Close(f);
          END;
    END
  END;
END.


