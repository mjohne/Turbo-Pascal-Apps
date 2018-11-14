PROGRAM EXO_DB2_v17;

USES Crt,Dos,Graph,Arithmos,Basic,BMPLoad,Cursor,RT_Watch,Scan_Exo,ConstVar;

PROCEDURE MakeTimestamp;
BEGIN
  Assign(TS_File,'TIMESTMP.LOG');
  IF FileExists('TIMESTMP.LOG') THEN Append(TS_File) ELSE Rewrite(TS_File);
  WITH TimeStamp DO BEGIN
    GetDate(Year,Month,Day,Dow);
    GetTime(Hour,Min,Sec,MSec);
    Write(TS_File,Chr(Byte(Year-2000)),Chr(Byte(Month)),Chr(Byte(Day)),Chr(Byte(Dow)),Chr(0));
    Write(TS_File,Chr(Byte(Hour)),Chr(Byte(Min)),Chr(Byte(Sec)),Chr(Byte(MSec)),Chr(0));
  END;
  Close(TS_File);
END;

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

PROCEDURE Search;
VAR FoundMore : Boolean;
BEGIN
  FoundMore := False;
  Search_Interface;
  SearchStr := ReadStr(27);
  HideCursor;
  Con := 1;
  Val(SearchStr,SearchReal,Con);
  Found := False;
  SetButton(38,27,White,LightRed+Blink,OK,50);
  SetButton(38,27,White,Black+Blink,OK,50);
  FindFirst('EXO\*.EXO',AnyFile,SearchFile);
  WHILE DosError = 0 DO BEGIN
    Assign(f,'EXO\'+SearchFile.Name);
    Reset(f);
    ReadLn(f,Centralstar);
    TextBackground(White);
    TextColor(Black+Blink);
    GotoXY(38,27);
    Write(OK);
    IF UpString(CentralStar) = UpString(SearchStr) THEN BEGIN
      SearchBox(1,CentralStar,0,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,SpectralType);
    IF UpString(SpectralType) = UpString(SearchStr) THEN BEGIN
      SearchBox(2,SpectralType,0,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,Magnitude);
    IF Con = 0 THEN IF Magnitude = SearchReal THEN BEGIN
      SearchBox(3,'',Magnitude,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,StarMass);
    IF Con = 0 THEN IF StarMass = SearchReal THEN BEGIN
      SearchBox(4,'',StarMass,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,Metalicity);
    IF Con = 0 THEN IF Metalicity = SearchReal THEN BEGIN
      SearchBox(5,'',Metalicity,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,Distance);
    IF Con = 0 THEN IF Distance = SearchReal THEN BEGIN
      SearchBox(6,'',Distance,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,Rectaszension);
    IF Con = 0 THEN IF Rectaszension = SearchReal THEN BEGIN
      SearchBox(7,'',Rectaszension,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,Deklination);
    IF Con = 0 THEN IF Deklination = SearchReal THEN BEGIN
      SearchBox(8,'',Deklination,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,Constellation);
    IF UpString(Constellation) = UpString(SearchStr) THEN BEGIN
      SearchBox(9,Constellation,0,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,PlanetName);
    IF UpString(PlanetName) = UpString(SearchStr) THEN BEGIN
      SearchBox(10,PlanetName,0,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,PlanetMass);
    IF Con = 0 THEN IF PlanetMass = SearchReal THEN BEGIN
      SearchBox(11,'',PlanetMass,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,SemiMajorAxis);
    IF Con = 0 THEN IF SemiMajorAxis = SearchReal THEN BEGIN
      SearchBox(12,'',SemiMajorAxis,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,Period);
    IF Con = 0 THEN IF Period = SearchReal THEN BEGIN
      SearchBox(13,'',Period,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,Eccentricity);
    IF Con = 0 THEN IF Eccentricity = SearchReal THEN BEGIN
      SearchBox(14,'',Eccentricity,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,Method);
    IF UpString(Method) = UpString(SearchStr) THEN BEGIN
      SearchBox(15,Method,0,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,DiscoveryDate);
    IF UpString(DiscoveryDate) = UpString(SearchStr) THEN BEGIN
      SearchBox(16,DiscoveryDate,0,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,Discoverer);
    IF UpString(Discoverer) = UpString(SearchStr) THEN BEGIN
      SearchBox(17,Discoverer,0,SearchFile.Name);
      FoundMore := True;
    END;
    ReadLn(f,Remarks);
    IF UpString(Remarks) = UpString(SearchStr) THEN BEGIN
      SearchBox(18,Remarks,0,SearchFile.Name);
      FoundMore := True;
    END;
    Close(f);
    FindNext(SearchFile);
  END;
  IF Found = False THEN BEGIN
    IF FoundMore = False THEN BEGIN
      MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
      TextColor(Black+Blink);
      GotoXY(23,23);
      Write('Es wurden keine Eintr„ge gefunden.');
    END ELSE IF FoundMore THEN BEGIN
      MessageBox(20,20,60,28,LightGreen,Blink,White+Blink,Green+Blink);
      TextColor(Black+Blink);
      GotoXY(23,23);
      Write('Die Suche ist damit abgeschlossen.');
    END;
    SetButton(37,25,White,Black+Blink,OK,0);
    REPEAT
      Input := ReadKey;
    UNTIL Input <> NULL;
    SetButton(37,25,White,LightRed+Blink,OK,50);
    SetButton(37,25,White,Black+Blink,OK,50);
  END;
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE Filter;
BEGIN
  Filter_Interface;
  FOR i := 0 TO 14 DO BEGIN
    TextBackground(Black);
    TextColor(White);
    Filter_Interface2(i);
    CASE i OF
      00..06 : GotoXY(12+1,13+1+(2*i));
      10..14 : GotoXY(50,13+1+(2*(i-10)));
    END;
    CASE i OF
      00 : Write(Spec2_Min);
      01 : Write(Mag2_Min:0:1);
      02 : Write(StarMass2_Min:0:1);
      03 : Write(Metal2_Min:0:2);
      04 : Write(Dist2_Min:0:1);
      05 : Write(Rec2_Min:0:1);
      06 : Write(Dec2_Min:0:1);
      10 : Write(PlanetMass2_Min:0:1);
      11 : Write(Axis2_Min:0:1);
      12 : Write(Period2_Min:0:1);
      13 : Write(Ecc2_Min:0:1);
      14 : Write(j3[7],j3[8]+'.'+j3[5],j3[6]+'.'+j3[1],j3[2],j3[3],j3[4]);
      {j3,m3,t3,j4,m4,t4,}
    END;
    CASE i OF
      00..06 : GotoXY(24+1,13+1+(2*i));
      10..13 : GotoXY(62,13+1+(2*(i-10)));
      14     : GotoXY(50,13+2+(2*(i-10)));
    END;
    CASE i OF
      00 : Write(Spec2_Max);
      01 : Write(Mag2_Max:0:1);
      02 : Write(StarMass2_Max:0:1);
      03 : Write(Metal2_Max:0:2);
      04 : Write(Dist2_Max:0:0);
      05 : Write(Rec2_Max:0:1);
      06 : Write(Dec2_Max:0:1);
      10 : Write(PlanetMass2_Max:0:1);
      11 : Write(Axis2_Max:0:1);
      12 : Write(Period2_Max:0:0);
      13 : Write(Ecc2_Max:0:1);
      14 : Write(j4[7],j4[8]+'.'+j4[5],j4[6]+'.'+j4[1],j4[2],j4[3],j4[4]);
    END;
  END;
  TextBackground(LightGray);
  i := 0;
  REPEAT
    FOR n := 0 TO 13 DO BEGIN
      GotoXY(07,13+n); Write(' ');
      GotoXY(44,13+n); Write(' ');
    END;
    TextColor(LightRed);
    IF i < 7 THEN BEGIN
      GotoXY(07,13+(2*i)); Write('')
    END ELSE IF i = 15 THEN BEGIN
      GotoXY(44,25); Arrow;
    END ELSE IF i > 9 THEN BEGIN
      GotoXY(44,13+(2*(i-10))); Arrow;
    END;
    Input := ReadKey;
    IF Input = NULL THEN BEGIN
      Input2 := ReadKey;
      IF Input2 = ArUp THEN Dec(i);
      IF Input2 = ArDn THEN Inc(i);
      IF Input2 = ArRt THEN Inc(i,10);
      IF Input2 = ArLf THEN Dec(i,10);
      IF Input2 = PgUp THEN i := 0;
      IF Input2 = PgDn THEN i := 6;
      IF i < 0 THEN i := 15;
      IF i > 15 THEN i := 0;
      IF (i > 6) AND (i < 10) THEN i := 10;
      IF i < 7 THEN BEGIN
        GotoXY(07,13+(2*i)); Write('')
      END ELSE IF i = 15 THEN BEGIN
        GotoXY(44,25); Arrow;
      END ELSE IF i > 9 THEN BEGIN
        GotoXY(44,13+(2*(i-10))); Arrow;
      END;
    END;
    IF Input = ENTER THEN BEGIN
      IF i < 7 THEN BEGIN
        TextColor(White);
        GotoXY(08,13+1+(2*i)); Write('Von:');
        GotoXY(20,13+1+(2*i)); Write('Bis:');
        TextBackground(Black);
        TextColor(White);
        GotoXY(13,13+1+(2*i)); Blank6;
        GotoXY(25,13+1+(2*i)); Blank6;
        GotoXY(13,13+1+(2*i));
      END ELSE IF i > 9 THEN BEGIN
        IF i = 14 THEN BEGIN
          TextColor(White);
          GotoXY(45,13+1+(2*(i-10))); Write('Von:');
          GotoXY(45,14+1+(2*(i-10))); Write('Bis:');
          TextBackground(Black);
          TextColor(White);
          GotoXY(50,13+1+(2*(i-10))); Blank17;
          GotoXY(50,14+1+(2*(i-10))); Blank17;
          GotoXY(50,13+1+(2*(i-10)));
        END ELSE BEGIN
          TextColor(White);
          GotoXY(45,13+1+(2*(i-10))); Write('Von:');
          GotoXY(57,13+1+(2*(i-10))); Write('Bis:');
          TextBackground(Black);
          TextColor(White);
          GotoXY(50,13+1+(2*(i-10))); Blank6;
          GotoXY(62,13+1+(2*(i-10))); Blank6;
          GotoXY(50,13+1+(2*(i-10)));
        END;
      END;
      ShowCursor;
      CASE i OF
        0: Spec2_Min := ReadStr(6);
        1: Mag2_Min := ReadReal(6);
        2: StarMass2_Min := ReadReal(6);
        3: Metal2_Min := ReadReal(6);
        4: Dist2_Min := ReadReal(6);
        5: Rec2_Min := ReadReal(6);
        6: Dec2_Min := ReadReal(6);
        10: PlanetMass2_Min := ReadReal(6);
        11: Axis2_Min := ReadReal(6);
        12: Period2_Min := ReadReal(6);
        13: Ecc2_Min := ReadReal(6);
        14: BEGIN
              GotoXY(50+00,13+1+(2*(i-10))); Write('j '); j := ReadInt(4); Str(j,j3);
              GotoXY(50+Length(j3)+3,13+1+(2*(i-10))); Write('m '); m := ReadInt(2); Str(m,m3);
              GotoXY(50+Length(j3)+3+Length(m3)+3,13+1+(2*(i-10))); Write('t '); t := ReadInt(2); Str(t,t3);
              IF m < 10 THEN m3 := '0'+m3;
              IF t < 10 THEN t3 := '0'+t3;
            END;
      END;
      IF i < 7 THEN GotoXY(25,13+1+(2*i)) ELSE IF i > 9 THEN GotoXY(62,13+1+(2*(i-10)));
      CASE i OF
        0: Spec2_Max := ReadStr(6);
        1: Mag2_Max := ReadReal(6);
        2: StarMass2_Max := ReadReal(6);
        3: Metal2_Max := ReadReal(6);
        4: Dist2_Max := ReadReal(6);
        5: Rec2_Max := ReadReal(6);
        6: Dec2_Max := ReadReal(6);
        10: PlanetMass2_Max := ReadReal(6);
        11: Axis2_Max := ReadReal(6);
        12: Period2_Max := ReadReal(6);
        13: Ecc2_Max := ReadReal(6);
        14: BEGIN
              GotoXY(50+00,14+1+(2*(i-10))); Write('j '); j := ReadInt(4); Str(j,j4);
              GotoXY(50+Length(j4)+3,14+1+(2*(i-10))); Write('m '); m := ReadInt(2); Str(m,m4);
              GotoXY(50+Length(j4)+3+Length(m4)+3,14+1+(2*(i-10))); Write('t '); t := ReadInt(2); Str(t,t4);
              IF m < 10 THEN m4 := '0'+m4;
              IF t < 10 THEN t4 := '0'+t4;
            END;
      END;
      HideCursor;
      TextBackground(LightGray);
    END;
  UNTIL (((i=15)) AND (Input = ENTER)) OR (Input = ESC);
  HideCursor;
  IF Input = ENTER THEN BEGIN
    SetButton(30,28,White,LightRed+Blink,OK,50);
    SetButton(30,28,White,Black+Blink,OK,50);
  END ELSE IF Input = ESC THEN BEGIN
    SetButton(40,28,White,LightRed+Blink,NO,50);
    SetButton(40,28,White,Black+Blink,NO,50);
  END;
  j3 := j3+m3+t3;
  j4 := j4+m4+t4;
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(1);
END;

PROCEDURE Add;
BEGIN
  Add_Interface;
  GotoXY(03,2+24+04); Centralstar := ReadStr(27);
  GotoXY(03,2+24+06); SpectralType := ReadStr(27);
  GotoXY(03,2+24+08); Magnitude := ReadReal(11);
  GotoXY(03,2+24+10); StarMass := ReadReal(11);
  GotoXY(03,2+24+12); Metalicity := ReadReal(11);
  {IF Korrektur THEN BEGIN
    Write(' +/- ');
    Metalicity2 := ReadReal(11);
  END;}
  GotoXY(03,2+24+14); Distance := ReadReal(11);
  GotoXY(03,2+24+16); Rectaszension := ReadHMS;
  GotoXY(03,2+24+18); Deklination := ReadDeg;
  GotoXY(03,2+24+20); Constellation := ReadStr(27);
  GotoXY(40,2+24+04); PlanetName := ReadStr(27);
  GotoXY(40,2+24+06); PlanetMass := ReadReal(11);
  {IF Korrektur THEN BEGIN
    Write(' +/- ');
    PlanetMass2 := ReadReal(11);
  END;}
  GotoXY(40,2+24+08); SemiMajorAxis := ReadReal(11);
  {IF Korrektur THEN BEGIN
    Write(' +/- ');
    SemiMajorAxis2 := ReadReal(11);
  END;}
  GotoXY(40,2+24+10); Period := ReadReal(11);
  {IF Korrektur THEN BEGIN
    Write(' +/- ');
    Period2 := ReadReal(11);
  END;}
  GotoXY(40,2+24+12); Eccentricity := ReadReal(11);
  {IF Korrektur THEN BEGIN
    Write(' +/- ');
    Eccentricity2 := ReadReal(11);
  END;}
  GotoXY(40,2+24+14); Method := ReadStr(27);
  GotoXY(40,2+24+16); DiscoveryDate := ReadDate;{DiscoveryDate := ReadStr(27);}
  GotoXY(40,2+24+18); Discoverer := ReadStr(27);
  GotoXY(40,2+24+20); Remarks := ReadStr(27);
  MessageBox(20,20,60,27,LightGray,LightGray,White,DarkGray);
  TextColor(Black);
  GotoXY(24,23);
  Write('Name des Datensatz zum Speichern:');
  GotoXY(24+8,25);
  Write('.EXO');
  TextBackground(Black);
  TextColor(White);
  GotoXY(24,25);
  Write('        ');
  SetButton(40,25,White,Black+Blink,OK,0);
  REPEAT
    TextBackground(Black);
    TextColor(White);
    GotoXY(24,25);
    Fil[1] := ReadStr(8);
  UNTIL Fil[1] <> '';
  HideCursor;
  SetButton(40,25,White,LightRed+Blink,OK,50);
  SetButton(40,25,White,Black+Blink,OK,50);
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  Assign(f,'EXO\'+Fil[1]+'.EXO');
  Rewrite(f);
  WriteLn(f,Centralstar);
  WriteLn(f,SpectralType);
  WriteLn(f,Magnitude:0:5);
  WriteLn(f,StarMass:0:5);
  {IF Korrektur THEN BEGIN
    WriteLn(f,Metalicity,Metalicity2);
  END ELSE} WriteLn(f,Metalicity:0:5);
  WriteLn(f,Distance:0:5);
  WriteLn(f,Rectaszension:0:10);
  WriteLn(f,Deklination:0:10);
  WriteLn(f,Constellation);
  WriteLn(f,PlanetName);
  {IF Korrektur THEN BEGIN
    WriteLn(f,PlanetMass,PlanetMass2);
  END ELSE} WriteLn(f,PlanetMass:0:5);
  {IF Korrektur THEN BEGIN
    WriteLn(f,SemiMajorAxis,SemiMajorAxis2);
  END ELSE} WriteLn(f,SemiMajorAxis:0:5);
  {IF Korrektur THEN BEGIN
    WriteLn(f,Period,Period2);
  END ELSE} WriteLn(f,Period:0:5);
  {IF Korrektur THEN BEGIN
    WriteLn(f,Eccentricity,Eccentricity2);
  END ELSE} WriteLn(f,Eccentricity:0:5);
  WriteLn(f,Method);
  WriteLn(f,DiscoveryDate);
  WriteLn(f,Discoverer);
  WriteLn(f,Remarks);
  Close(f);
  MessageBox(20,20,60,28,LightGreen,Blink,White+Blink,Green+Blink);
  TextColor(Black+Blink);
  GotoXY(26,23);
  Write('Der Datensatz ist gespeichert!');
  SetButton(37,25,White,Black+Blink,OK,0);
  REPEAT
    Input := ReadKey;
  UNTIL Input <> NULL;
  SetButton(37,25,White,LightRed+Blink,OK,50);
  SetButton(37,25,White,Black+Blink,OK,50);
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(ExoFileMax);
END;

PROCEDURE Load;
BEGIN
  Load_Interface;
  Numb := Index;
  GotoXY(30,14);
  Write('');
  GotoXY(30,35);
  Write('');
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
  Write('²');
  FOR i := 0 TO 21 DO BEGIN
    IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
    GotoXY(12,14+i);
    Write('     ');
    GotoXY(12,14+i);
    IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
    GotoXY(18,14+i);
    Blank12;
    GotoXY(18,14+i);
    Write(ExoFile[Numb+i]);
  END;
  ScanExoInfo(Numb);
  GotoXY(35,15); IF Length(Centralstar) > 27 THEN FOR n := 1 TO 27 DO Write(Centralstar[n])
                                             ELSE Write(Centralstar);
  GotoXY(35,16); IF Length(Spectraltype) > 27 THEN FOR n := 1 TO 27 DO Write(Spectraltype[n],' / ',Magnitude:0:2,' mag')
                                              ELSE Write(Spectraltype,' / ',Magnitude:0:2,' mag');
  GotoXY(35,17); Write('REK ',Rectaszension:0:3,' DEC ',Deklination:0:3);
  GotoXY(35,19); IF Length(PlanetName) > 27 THEN FOR n := 1 TO 27 DO Write(PlanetName[n])
                                            ELSE Write(PlanetName);
  GotoXY(35,20); Write(PlanetMass:0:2,' Mjup / ',SemiMajorAxis:0:2,' AE');
  GotoXY(35,21); Write(Period:0:2,' Tage / ',Eccentricity:0:2,' ecc');
  GotoXY(35,23); IF Length(Method) > 27 THEN FOR n := 1 TO 27 DO Write(Method[n])
                                        ELSE Write(Method);
  GotoXY(35,24); Write('Jahr '+DiscoveryDate[1]+DiscoveryDate[2]+DiscoveryDate[3]+DiscoveryDate[4]+' Monat '+
    DiscoveryDate[5]+DiscoveryDate[6]+' Tag '+DiscoveryDate[7]+DiscoveryDate[8]);
  GotoXY(35,25); IF Length(Discoverer) > 27 THEN FOR n := 1 TO 27 DO Write(Discoverer[n])
                                            ELSE Write(Discoverer);
  GotoXY(35,27); IF Length(Remarks) > 27 THEN FOR n := 1 TO 27 DO Write(Remarks[n])
                                         ELSE Write(Remarks);
  REPEAT
    Input := ReadKey;
    IF Input = NULL THEN BEGIN
      Input2 := ReadKey;
      IF Input2 IN [ARLF,ARUP] THEN Dec(Numb);
      IF Input2 IN [ARRT,ARDN] THEN Inc(Numb);
      IF Input2 = PGUP THEN Dec(Numb,10);
      IF Input2 = PGDN THEN Inc(Numb,10);
      IF Input2 = POS1 THEN Numb := 1;
      IF Input2 = END1 THEN Numb := ExoFileMax;
      IF Numb < 1 THEN Numb := ExoFileMax;
      IF Numb > ExoFileMax THEN Numb := 1;
      FOR i := 0 TO 21 DO BEGIN
        FOR n := 1 TO 20 DO BEGIN
          GotoXY(30,14+n);
          Write('°');
        END;
        GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
        Write('²');
        IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
        GotoXY(12,14+i);
        Write('     ');
        GotoXY(12,14+i);
        IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
        GotoXY(18,14+i);
        Blank12;
        GotoXY(18,14+i);
        ExoFile[ExoFileMax+1] := '';
        Write(ExoFile[Numb+i]);
        FOR n := 1 TO 22 DO BEGIN
          GotoXY(33,13+n);
          Blank29;
        END;
        ScanExoInfo(Numb);
        GotoXY(35,15); IF Length(Centralstar) > 27 THEN FOR n := 1 TO 27 DO Write(Centralstar[n])
                                                   ELSE Write(Centralstar);
        GotoXY(35,16); IF Length(Spectraltype) > 27 THEN FOR n := 1 TO 27 DO Write(Spectraltype[n],' / ',Magnitude:0:2,' mag')
                                                    ELSE Write(Spectraltype,' / ',Magnitude:0:2,' mag');
        GotoXY(35,17); Write('REK ',Rectaszension:0:3,' DEC ',Deklination:0:3);
        GotoXY(35,19); IF Length(PlanetName) > 27 THEN FOR n := 1 TO 27 DO Write(PlanetName[n])
                                                  ELSE Write(PlanetName);
        GotoXY(35,20); Write(PlanetMass:0:2,' Mjup / ',SemiMajorAxis:0:2,' AE');
        GotoXY(35,21); Write(Period:0:2,' Tage / ',Eccentricity:0:2,' ecc');
        GotoXY(35,23); IF Length(Method) > 27 THEN FOR n := 1 TO 27 DO Write(Method[n])
                                              ELSE Write(Method);
        GotoXY(35,24); Write('Jahr '+DiscoveryDate[1]+DiscoveryDate[2]+DiscoveryDate[3]+DiscoveryDate[4]+' Monat '+
          DiscoveryDate[5]+DiscoveryDate[6]+' Tag '+DiscoveryDate[7]+DiscoveryDate[8]);
        GotoXY(35,25); IF Length(Discoverer) > 27 THEN FOR n := 1 TO 27 DO Write(Discoverer[n])
                                                  ELSE Write(Discoverer);
        GotoXY(35,27); IF Length(Remarks) > 27 THEN FOR n := 1 TO 27 DO Write(Remarks[n])
                                               ELSE Write(Remarks);
      END;
    END;
  UNTIL Input IN [ENTER,ESC];
  IF Input = ENTER THEN BEGIN
    SetButton(63,14,White,LightRed+Blink,OK,50);
    SetButton(63,14,White,Black+Blink,OK,50);
  END ELSE BEGIN
    SetButton(63,16,White,LightRed+Blink,NO,50);
    SetButton(63,16,White,Black+Blink,NO,50);
    Numb := Index;
  END;
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  Index := Numb;
  ScanExoUpdate(Index);
END;

PROCEDURE Change;
BEGIN
  Change_Interface;
  {GotoXY(1,14);
  Write('Mit Fehlerspanne? (j/n)');
  REPEAT
    Input := ReadKey;
  UNTIL Input IN ['j','J','y','Y','z','Z','n','N'];
  IF Input IN ['N','n'] THEN Korrektur := False ELSE Korrektur := True;}
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF FileExists('EXO\'+ExoFile[Index]) THEN BEGIN
    Assign(f,'EXO\'+ExoFile[Index]);
    ReadEXO;
  END;
  i := 1;
  REPEAT
    TextBackground(LightBlue);
    TextColor(LightBlue+Blink);
    FOR n := 4 TO 20 DO BEGIN
      IF NOT(Odd(n)) THEN BEGIN
        GotoXY(02,2+24+n); Arrow;
        GotoXY(39,2+24+n); Arrow;
      END;
    END;
    TextColor(LightRed+Blink);
    CASE i OF
      01..09: BEGIN GotoXY(02,2+24+02+(2*i)); Arrow; END;
      11..19: BEGIN GotoXY(39,2+24+02+(2*(i-10))); Arrow; END;
    END;
    Input := Readkey;
    Input := Upcase(Input);
    IF Input = ENTER THEN BEGIN
      TextBackground(Black);
      TextColor(White);
      ShowCursor;
      CASE i OF
        01 : BEGIN
               GotoXY(03,2+24+04); Blank29;
               GotoXY(03,2+24+04); Centralstar := ReadStr(27);
             END;
        02 : BEGIN
               GotoXY(03,2+24+06); Blank29;
               GotoXY(03,2+24+06); SpectralType := ReadStr(27);
             END;
        03 : BEGIN
               GotoXY(03,2+24+08); Blank29;
               GotoXY(03,2+24+08); Magnitude := ReadReal(11);
             END;
        04 : BEGIN
               GotoXY(03,2+24+10); Blank29;
               GotoXY(03,2+24+10); StarMass := ReadReal(11);
             END;
        05 : BEGIN
               GotoXY(03,2+24+12); Blank29;
               GotoXY(03,2+24+12); Metalicity := ReadReal(11);
               {IF Korrektur THEN BEGIN
                 Write(' +/- ');
                 Metalicity2 := ReadReal(11);
               END;}
             END;
        06 : BEGIN
               GotoXY(03,2+24+14); Blank29;
               GotoXY(03,2+24+14); Distance := ReadReal(11);
             END;
        07 : BEGIN
               GotoXY(03,2+24+16); Blank29;
               GotoXY(03,2+24+16); Rectaszension := ReadHMS;
             END;
        08 : BEGIN
               GotoXY(03,2+24+18); Blank29;
               GotoXY(03,2+24+18); Deklination := ReadDeg;
             END;
        09 : BEGIN
               GotoXY(03,2+24+20); Blank29;
               GotoXY(03,2+24+20); Constellation := ReadStr(27);
             END;
        11 : BEGIN
               GotoXY(40,2+24+04); Blank29;
               GotoXY(40,2+24+04); PlanetName := ReadStr(27);
             END;
        12 : BEGIN
               GotoXY(40,2+24+06); Blank29;
               GotoXY(40,2+24+06); PlanetMass := ReadReal(11);
               {IF Korrektur THEN BEGIN
                 Write(' +/- ');
                 PlanetMass2 := ReadReal(11);
               END;}
             END;
        13 : BEGIN
               GotoXY(40,2+24+08); Blank29;
               GotoXY(40,2+24+08); SemiMajorAxis := ReadReal(11);
               {IF Korrektur THEN BEGIN
                 Write(' +/- ');
                 SemiMajorAxis2 := ReadReal(11);
               END;}
             END;
        14 : BEGIN
               GotoXY(40,2+24+10); Blank29;
               GotoXY(40,2+24+10); Period := ReadReal(11);
               {IF Korrektur THEN BEGIN
                 Write(' +/- ');
                 Period2 := ReadReal(11);
               END;}
             END;
        15 : BEGIN
               GotoXY(40,2+24+12); Blank29;
               GotoXY(40,2+24+12); Eccentricity := ReadReal(11);
               {IF Korrektur THEN BEGIN
                 Write(' +/- ');
                 Eccentricity2 := ReadReal(11);
               END;}
             END;
        16 : BEGIN
               GotoXY(40,2+24+14); Blank29;
               GotoXY(40,2+24+14); Method := ReadStr(27);
             END;
        17 : BEGIN
               GotoXY(40,2+24+16); Blank29;
               GotoXY(40,2+24+16); DiscoveryDate := ReadDate;
             END;
        18 : BEGIN
               GotoXY(40,2+24+18); Blank29;
               GotoXY(40,2+24+18); Discoverer := ReadStr(27);
             END;
        19 : BEGIN
               GotoXY(40,2+24+20); Blank29;
               GotoXY(40,2+24+20); Remarks := ReadStr(27);
             END;
      END;
      HideCursor;
    END;
    IF NOT(Input = ESC) THEN CASE Input OF
      NULL : BEGIN
        Input2 := Readkey;
        Input2 := Upcase(Input2);
        CASE Input2 OF
          ARLF : BEGIN
                   Dec(i,10);
                   IF i < 1 THEN Inc(i,10);
                 END;
          ARRT : BEGIN
                   Inc(i,10);
                   IF i > 19 THEN Dec(i,10);
                 END;
          ARUP : BEGIN
                   Dec(i,1);
                   IF i < 1 THEN i := 1;
                   IF i = 10 THEN i := 9;
                 END;
          ARDN : BEGIN
                   Inc(i,1);
                   IF i > 19 THEN i := 19;
                   IF i = 10 THEN i := 11;
                 END;
        END;
      END;
    END;
  UNTIL Input = ESC;
  MessageBox(20,20,60,28,LightRed,Blink,White+Blink,Red+Blink);
  TextColor(Black+Blink);
  GotoXY(21,23);
  Write('Wollen Sie diesen Datensatz speichern?');
  TextBackground(White);
  TextColor(Black+Blink);
  SetButton(33,25,White,Black+Blink,YES,0);
  SetButton(43,25,White,Black+Blink,NO,0);
  i := 0;
  REPEAT
    CASE i OF
      0 : BEGIN
            SetButton(33,25,White,Green+Blink,YES,0);
            SetButton(43,25,White,Black+Blink,NO,0);
          END;
      1 : BEGIN
            SetButton(33,25,White,Black+Blink,YES,0);
            SetButton(43,25,White,Green+Blink,NO,0);
          END;
    END;
    Input := Readkey;
    Input := Upcase(Input);
    IF NOT(Input = ENTER) THEN CASE Input OF
      NULL : BEGIN
        Input2 := Readkey;
        Input2 := Upcase(Input2);
        CASE Input2 OF
          ARLF : i := 0;
          ARRT : i := 1;
        END;
      END;
    END;
  UNTIL Input = ENTER;
  CASE i OF
    0 : BEGIN
          SetButton(33,25,White,LightRed+Blink,YES,0);
          SetButton(43,25,White,Black+Blink,NO,0);
        END;
    1 : BEGIN
          SetButton(33,25,White,Black+Blink,YES,0);
          SetButton(43,25,White,LightRed+Blink,NO,0);
        END;
  END;
  Wait(5);
  SetButton(33,25,White,Black+Blink,YES,0);
  SetButton(43,25,White,Black+Blink,NO,50);
  IF i = 0 THEN BEGIN
    Assign(f,'EXO\'+ExoFile[Index]);
    Rewrite(f);
    WriteLn(f,Centralstar);
    WriteLn(f,SpectralType);
    WriteLn(f,Magnitude:0:5);
    WriteLn(f,StarMass:0:5);
    {IF Korrektur THEN BEGIN
     WriteLn(f,Metalicity,Metalicity2);
    END ELSE} WriteLn(f,Metalicity:0:5);
    WriteLn(f,Distance:0:5);
    WriteLn(f,Rectaszension:0:10);
    WriteLn(f,Deklination:0:10);
    WriteLn(f,Constellation);
    WriteLn(f,PlanetName);
    {IF Korrektur THEN BEGIN
    WriteLn(f,PlanetMass,PlanetMass2);
    END ELSE} WriteLn(f,PlanetMass:0:5);
    {IF Korrektur THEN BEGIN
    WriteLn(f,SemiMajorAxis,SemiMajorAxis2);
    END ELSE} WriteLn(f,SemiMajorAxis:0:5);
    {IF Korrektur THEN BEGIN
    WriteLn(f,Period,Period2);
    END ELSE} WriteLn(f,Period:0:5);
    {IF Korrektur THEN BEGIN
    WriteLn(f,Eccentricity,Eccentricity2);
    END ELSE} WriteLn(f,Eccentricity:0:5);
    WriteLn(f,Method);
    WriteLn(f,DiscoveryDate);
    WriteLn(f,Discoverer);
    WriteLn(f,Remarks);
    Close(f);
    MessageBox(20,20,60,28,LightGreen,Blink,White+Blink,Green+Blink);
    TextColor(Black+Blink);
    GotoXY(24,23);
    Write('Der Datensatz wurde gespeichert!');
    SetButton(37,25,White,Black+Blink,OK,0);
    REPEAT
      Input := ReadKey;
    UNTIL Input <> NULL;
    SetButton(37,25,White,LightRed+Blink,OK,50);
    SetButton(37,25,White,Black+Blink,OK,50);
  END;
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE Rename2;
BEGIN
  Rename_Interface;
  REPEAT
    TextBackground(Black);
    TextColor(White);
    GotoXY(24,25);
    Fil[1] := ReadStr(8);
  UNTIL Fil[1] <> '';
  HideCursor;
  SetButton(40,25,White,Lightred+Blink,OK,50);
  SetButton(40,25,White,Black+Blink,OK,50);
  IF RenameFile('EXO\'+ExoFile[Index],'EXO\'+Fil[1]+'.EXO') THEN BEGIN
    MessageBox(20,20,60,27,LightGreen,Blink,White+Blink,Green+Blink);
    GotoXY(28,23);
    TextColor(Black+Blink);
    Write('Datei wurde umbenannt!');
    SetButton(37,25,White,Black+Blink,OK,0);
    REPEAT
      Input := ReadKey;
    UNTIL Input <> NULL;
    SetButton(37,25,White,LightRed+Blink,OK,50);
    SetButton(37,25,White,Black+Blink,OK,50);
  END;
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE Delete;
BEGIN
  Delete_Interface;
  i := 0;
  REPEAT
    CASE i OF
      0 : BEGIN
            SetButton(33,25,White,Green+Blink,YES,0);
            SetButton(40,25,White,Black+Blink,NO,0);
          END;
      1 : BEGIN
            SetButton(33,25,White,Black+Blink,YES,0);
            SetButton(40,25,White,Green+Blink,NO,0);
          END;
    END;
    Input := Readkey;
    Input := Upcase(Input);
    IF NOT(Input = ENTER) THEN CASE Input OF
      NULL : BEGIN
        Input2 := Readkey;
        Input2 := Upcase(Input2);
        CASE Input2 OF
          ARLF : i := 0;
          ARRT : i := 1;
        END;
      END;
    END;
  UNTIL Input = ENTER;
  CASE i OF
    0 : BEGIN
          SetButton(33,25,White,LightRed+Blink,YES,0);
          SetButton(40,25,White,Black+Blink,NO,0);
        END;
    1 : BEGIN
          SetButton(33,25,White,Black+Blink,YES,0);
          SetButton(40,25,White,LightRed+Blink,NO,0);
        END;
  END;
  Wait(5);
  SetButton(33,25,White,Black+Blink,YES,0);
  SetButton(40,25,White,Black+Blink,NO,50);
  IF i = 0 THEN BEGIN
    IF FileExists('EXO\'+ExoFile[Index]) THEN BEGIN
      Assign(f,'EXO\'+ExoFile[Index]);
      Erase(f);
      MessageBox(20,20,60,28,LightGreen,Blink,White+Blink,Green+Blink);
      TextColor(Black+Blink);
      GotoXY(26,23);
      Write('Der Datensatz wurde gel”scht..');
      SetButton(37,25,White,Black+Blink,OK,0);
      REPEAT
        Input := ReadKey;
      UNTIL Input <> NULL;
      SetButton(37,25,White,LightRed+Blink,OK,50);
      SetButton(37,25,White,Black+Blink,OK,50);
    END ELSE BEGIN
      Msg_NoDataset;
    END;
  END;
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE Check;
BEGIN
  Check_Interface1;
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE Records;
BEGIN
  Records_Interface;
  Axis_Min := 1;   Axis_Max := 1;
  Ecc_Min  := 0.5; Ecc_Max  := 0.5;
  Mass_Min := 1;   Mass_Max := 1;
  StarMass_Min := 1; StarMass_Max := 1;
  Distance_Min := 6; Distance_Max := 6;
  Spec_Min := 50; Spec_Max := 50;
  Mag_Min := 4; Mag_Max := 4;
  j6 := 19970000; j7 := 19970000;
  ExoFileMax := 0;
  FindFirst('EXO\*.EXO',AnyFile,SearchFile);
  WHILE DosError = 0 DO BEGIN
    Inc(ExoFileMax);
    ExoFile[ExoFileMax] := SearchFile.Name;
    ScanExoInfo(ExoFileMax);
    IF PlanetMass < Mass_Min THEN BEGIN
      Mass_Min := PlanetMass;
      GotoXY(20,11); Blank20; Blank20;
      GotoXY(20,11); Write(PlanetName,': ',Mass_Min:0:2,' Mjup');
    END;
    IF PlanetMass > Mass_Max THEN BEGIN
      Mass_Max := PlanetMass;
      GotoXY(20,13); Blank20; Blank20;
      GotoXY(20,13); Write(PlanetName,': ',Mass_Max:0:2,' Mjup');
    END;
    IF SemiMajorAxis < Axis_Min THEN BEGIN
      Axis_Min := SemiMajorAxis;
      GotoXY(20,15); Blank20; Blank20;
      GotoXY(20,15); Write(PlanetName,': ',Axis_Min:0:2,' AE');
    END;
    IF SemiMajorAxis > Axis_Max THEN BEGIN
      Axis_Max := SemiMajorAxis;
      GotoXY(20,17); Blank20; Blank20;
      GotoXY(20,17); Write(PlanetName,': ',Axis_Max:0:2,' AE');
    END;
    IF Eccentricity <> 0 THEN BEGIN
      IF Eccentricity < Ecc_Min THEN BEGIN
        Ecc_Min := Eccentricity;
        GotoXY(20,19); Blank20; Blank20;
        GotoXY(20,19); Write(PlanetName,': ',Ecc_Min:0:2);
      END;
      IF Eccentricity > Ecc_Max THEN BEGIN
        Ecc_Max := Eccentricity;
        GotoXY(20,21); Blank20; Blank20;
        GotoXY(20,21); Write(PlanetName,': ',Ecc_Max:0:2);
      END;
    END;
    Val(DiscoveryDate,j5,Con);
    IF j5 < j6 THEN BEGIN
      GotoXY(20,23); Blank20; Blank20;
      j6 := j5;
      Str(j6:0:0,j0);
      GotoXY(20,23); Write(PlanetName,': ',j0[7]+j0[8]+'.'+j0[5]+j0[6]+'.'+j0[1]+j0[2]+j0[3]+j0[4]);
    END;
    Val(DiscoveryDate,j5,Con);
    IF j5 > j7 THEN BEGIN
      GotoXY(20,25); Blank20; Blank20;
      j7 := j5;
      Str(j7:0:0,j0);
      GotoXY(20,25); Write(PlanetName,': ',j0[7]+j0[8]+'.'+j0[5]+j0[6]+'.'+j0[1]+j0[2]+j0[3]+j0[4]);
    END;
    CASE SpectralType[1] OF
      'O' : Spec := 10;
      'B' : Spec := 20;
      'A' : Spec := 30;
      'F' : Spec := 40;
      'G' : Spec := 50;
      'K' : Spec := 60;
      'M' : Spec := 70;
      'L' : Spec := 80;
      'T' : Spec := 90;
    END;
    Val(SpectralType[2],n,Con);
    Spec := Spec+n;
    IF Spec < Spec_Min THEN BEGIN
      Spec_Min := Spec;
      GotoXY(20,29); Blank20; Blank20;
      GotoXY(20,29); Write(CentralStar,': ',SpectralType);
    END;
    IF Spec > Spec_Max THEN BEGIN
      Spec_Max := Spec;
      GotoXY(20,31); Blank20; Blank20;
      GotoXY(20,31); Write(CentralStar,': ',SpectralType);
    END;
    IF StarMass <> 0 THEN BEGIN
      IF StarMass < StarMass_Min THEN BEGIN
        StarMass_Min := StarMass;
        GotoXY(20,33); Blank20; Blank20;
        GotoXY(20,33); Write(CentralStar,': ',StarMass_Min:0:2,' Msol');
      END;
    END;
    IF StarMass <> 0 THEN BEGIN
      IF StarMass > StarMass_Max THEN BEGIN
        StarMass_Max := StarMass;
        GotoXY(20,35); Blank20; Blank20;
        GotoXY(20,35); Write(CentralStar,': ',StarMass_Max:0:2,' Msol');
      END;
    END;
    IF Distance <> 0 THEN BEGIN
      IF Distance < Distance_Min THEN BEGIN
        Distance_Min := Distance;
        GotoXY(20,37); Blank20; Blank20;
        GotoXY(20,37); Write(CentralStar,': ',Distance_Min:0:2,' Parsec');
      END;
    END;
    IF Distance <> 0 THEN BEGIN
      IF Distance > Distance_Max THEN BEGIN
        Distance_Max := Distance;
        GotoXY(20,39); Blank20; Blank20;
        GotoXY(20,39); Write(CentralStar,': ',Distance_Max:0:2,' Parsec');
      END;
    END;
    IF Magnitude < Mag_Max THEN BEGIN
      Mag_Max := Magnitude;
      GotoXY(20,41); Blank20; Blank20;
      GotoXY(20,41); Write(CentralStar,': ',Mag_Max:0:2,' mag');
    END;
    IF Magnitude > Mag_Min THEN BEGIN
      Mag_Min := Magnitude;
      GotoXY(20,43); Blank20; Blank20;
      GotoXY(20,43); Write(CentralStar,': ',Mag_Min:0:2,' mag');
    END;
    FindNext(SearchFile);
  END;
  TextColor(Blue);
  GotoXY(26,7); Write('Fertig!');
  SetButton(50,8,White,Black+Blink,OK,0);
  ReadKey;
  Wait(5);
  SetButton(50,8,White,LightRed+Blink,OK,50);
  SetButton(50,8,White,Black+Blink,OK,0);
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE Status;
BEGIN
  Status_Interface;
  ma1 := 0; ma2 := 0; ma3 := 0; ma4 := 0; ma5 := 0;
  ecc_T1 := 0; ecc_T2 := 0; ecc_T3 := 0; ecc_T4 := 0;
  ExoFileMax := 0;
  FindFirst('EXO\*.EXO',AnyFile,SearchFile);
  WHILE DosError = 0 DO BEGIN
    Inc(ExoFileMax);
    ExoFile[ExoFileMax] := SearchFile.Name;
    ScanExoInfo(ExoFileMax);
    IF PlanetMass <= 0.2 THEN Inc(ma1);
    IF (PlanetMass > 0.2) AND (PlanetMass <= 0.5) THEN Inc(ma2);
    IF (PlanetMass > 0.5) AND (PlanetMass <= 5.0) THEN Inc(ma3);
    IF (PlanetMass > 5.0) AND (PlanetMass <= 10.0) THEN Inc(ma4);
    IF PlanetMass > 10.0 THEN Inc(ma5);
    GotoXY(43,11); Write(ma1);
    GotoXY(43,13); Write(ma2);
    GotoXY(43,15); Write(ma3);
    GotoXY(43,17); Write(ma4);
    GotoXY(43,19); Write(ma5);
    IF (Eccentricity <= 0.25) AND (Period <= 88) THEN Inc(ecc_T1);
    IF (Eccentricity  > 0.25) AND (Period <= 88) THEN Inc(ecc_T2);
    IF (Eccentricity <= 0.25) AND (Period  > 88) THEN Inc(ecc_T3);
    IF (Eccentricity  > 0.25) AND (Period  > 88) THEN Inc(ecc_T4);
    GotoXY(47,24); Write(ecc_T1);
    GotoXY(47,26); Write(ecc_T2);
    GotoXY(47,28); Write(ecc_T3);
    GotoXY(47,30); Write(ecc_T4);
    FindNext(SearchFile);
  END;
  TextColor(Blue);
  GotoXY(34,7); Write('Fertig!');
  SetButton(50,8,White,Black+Blink,OK,0);
  ReadKey;
  Wait(5);
  SetButton(50,8,White,LightRed+Blink,OK,50);
  SetButton(50,8,White,Black+Blink,OK,0);
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_Export;
BEGIN
  {$M 50000,0,0}
  TextBackground(LightBlue);
  TextColor(LightRed+Blink);
  GotoXY(4,13); Writeln('5 - exportieren');
  Wait(5);
  TextColor(Yellow+Blink);
  GotoXY(4,13); Writeln('5 - exportieren');
  IF NOT(FileExists('export.exe')) AND NOT(FileExists('export.dat')) THEN BEGIN
    Msg_NoModule;
  END ELSE BEGIN
    Export_Interface1;
    i := 1;
    REPEAT
      Input := ReadKey;
      IF Input = NULL THEN BEGIN
        Input2 := ReadKey;
        IF Input2 = ARDN THEN Inc(i);
        IF Input2 = ARUP THEN Dec(i);
        IF Input2 = ARLF THEN Dec(i,3);
        IF Input2 = ARRT THEN Inc(i,3);
        IF i < 1 THEN i := 5;
        IF i > 5 THEN i := 1;
        TextBackground(LightGray);
        TextColor(LightGray);
        FOR n := 1 TO 3 DO BEGIN
          GotoXY(22,23+n); Arrow;
        END;
        GotoXY(31,24); Arrow;
        GotoXY(31,25); Arrow;
        TextColor(LightRed);
        CASE i OF
          1..3: BEGIN GotoXY(22,23+i); Arrow; END;
          4: BEGIN GotoXY(31,24); Arrow; END;
          5: BEGIN GotoXY(31,25); Arrow; END;
        END;
      END;
    UNTIL Input IN [ENTER,ESC];
    IF Input = ENTER THEN BEGIN
      SetButton(48,24,White,LightRed+Blink,OK,50);
      SetButton(48,24,White,Black+Blink,OK,50);
      Export_Interface2;
      Assign(f2,'export.dat');
      Rename(f2,'export.exe');
      CASE i OF
        1: Numb2 := 'TXT';
        2: Numb2 := 'HTM';
        3: Numb2 := 'RTF';
        4: Numb2 := 'CSV';
        5: Numb2 := 'SLK';
      END;
      Fil[0] := '';
      FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
        Fil[0] := Fil[0]+ExoFile[Index][i];
      END;
      Exec('export.exe',' '+Numb2+' '+Fil[0]);
      Rename(f2,'export.dat');
      MessageBox(20,20,60,28,LightGreen,Blink,White+Blink,Green+Blink);
      TextColor(Black+Blink);
      GotoXY(22,23);
      Write('Der Datensatz wurde exportiert!');
      GotoXY(22,24);
      Write('Der Dateiname ist EXPORT\',Fil[0],'.',Numb2,'!');
      SetButton(38,26,White,Black+Blink,OK,0);
      REPEAT
        Input := ReadKey;
      UNTIL Input <> NULL;
      SetButton(38,26,White,LightRed+Blink,OK,50);
      SetButton(38,26,White,Black+Blink,OK,50);
    END ELSE IF Input = ESC THEN BEGIN
      SetButton(48,26,White,LightRed+Blink,NO,50);
      SetButton(48,26,White,Black+Blink,NO,50);
    END;
  END;
  MainApp;
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_Orbit;
BEGIN
  {$M 50000,0,0}
  Orbit_Interface1;
  Numb := Index;
  b := 1;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
  Write('²');
  FOR i := 0 TO 21 DO BEGIN
    IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
    GotoXY(12,14+i);
    Write('     ');
    GotoXY(12,14+i);
    IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
    GotoXY(18,14+i);
    Blank12;
    GotoXY(18,14+i);
    Write(ExoFile[Numb+i]);
  END;
  GotoXY(33,14); Write(1:4,' ³ ',ExoFile[Index]);
  TextBackground(White);
  TextColor(Black+Blink);
  GotoXY(33,12); Write('Zu laden: ',+b:2,'/12');
  Textbackground(Black);
  REPEAT
    Input := ReadKey;
    Input := UpCase(Input);
    IF Input = NULL THEN BEGIN
      Input2 := ReadKey;
      NotDouble := 0;
      FOR i := 1 TO 12 DO BEGIN
        IF ExoFile[Numb] = Fil[i] THEN Inc(NotDouble);
        IF ExoFile[Index] = Fil[i] THEN Inc(NotDouble);
      END;
      IF b < 12 THEN IF (Input2 = ARRT) AND (ExoFile[Numb] <> ExoFile[Index]) AND (NotDouble = 0) THEN BEGIN
        Inc(b);
        Fil[b] := ExoFile[Numb];
        SetButton(63,18,White,Black+Blink,'  ->  ',50);
        SetButton(63,18,White,LightRed+Blink,'  ->  ',50);
        SetButton(63,18,White,Black+Blink,'  ->  ',0);
        TextBackground(Black);
        TextColor(White);
      END;
      IF b IN [2..12] THEN IF Input2 = ARLF THEN BEGIN
        Dec(b);
        Fil[b+1] := '';
        SetButton(63,20,White,Black+Blink,'  <-  ',50);
        SetButton(63,20,White,LightRed+Blink,'  <-  ',50);
        SetButton(63,20,White,Black+Blink,'  <-  ',0);
        TextBackground(Black);
        TextColor(White);
      END;
      IF Input2 = ARUP THEN Dec(Numb);
      IF Input2 = ARDN THEN Inc(Numb);
      IF Input2 = PGUP THEN Dec(Numb,10);
      IF Input2 = PGDN THEN Inc(Numb,10);
      IF Input2 = POS1 THEN Numb := 1;
      IF Input2 = END1 THEN Numb := ExoFileMax;
      IF Numb < 1 THEN Numb := ExoFileMax;
      IF Numb > ExoFileMax THEN Numb := 1;
      FOR i := 0 TO 21 DO BEGIN
        FOR n := 1 TO 20 DO BEGIN
          GotoXY(30,14+n);
          Write('°');
        END;
        GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
        Write('²');
        IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
        GotoXY(12,14+i);
        Write('     ');
        GotoXY(12,14+i);
        IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
        GotoXY(18,14+i);
        Blank12;
        GotoXY(18,14+i);
        ExoFile[ExoFileMax+1] := '';
        Write(ExoFile[Numb+i]);
        TextBackground(White);
        TextColor(Black+Blink);
        GotoXY(33,12); Write('Zu laden: ',+b:2,'/12');
        Textbackground(Black);
        TextColor(White);
        FOR n := 2 TO 12 DO BEGIN
          GotoXY(33,13+n);
          Blank29;
          IF n <= b THEN BEGIN
            GotoXY(33,13+n); Write(n:4,' ³ ',Fil[n]);
          END;
        END;
      END;
    END;
  UNTIL Input IN [ENTER,ESC,'A'];
  IF Input = 'A' THEN BEGIN
    Numb := 0;
    SetButton(63,22,White,Black+Blink,' Alle ',50);
    SetButton(63,22,White,LightRed+Blink,' Alle ',50);
    SetButton(63,22,White,Black+Blink,' Alle ',0);
    TextBackground(Black);
    TextColor(White);
  END;
  IF Input IN [ENTER,'A'] THEN BEGIN
    SetButton(63,14,White,LightRed+Blink,OK,50);
    SetButton(63,14,White,Black+Blink,OK,50);
    IF NOT(FileExists('starmap.exe')) AND NOT(FileExists('starmap.dat')) THEN BEGIN
      Msg_NoModule;
    END ELSE BEGIN
      Orbit_Interface3;
      IF Input = 'A' THEN Numb := 0 ELSE Numb := b;
      Fil[0] := '';
      FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
        Fil[0] := Fil[0]+ExoFile[Index][i];
      END;
      FOR n := 1 TO Numb DO BEGIN
        FOR i := 1 TO Length(Fil[n])-4 DO BEGIN
          TempStr := TempStr+Fil[n][i];
        END;
        Fil[n] := TempStr;
        TempStr := '';
        Fil[0] := Fil[0]+' '+Fil[n];
      END;
      Orbit_Interface2;
      GotoXY(23,15); Zoom := ReadInt(8);
      GotoXY(23,19); mx := ReadInt(8);
      GotoXY(23,23); my := ReadInt(8);
      IF (Numb < 2) THEN BEGIN
        IF NOT(Input IN ['a','A']) THEN BEGIN
          GotoXY(51,25);
          REPEAT
            HZ := ReadKey;
            HZ := UpCase(HZ);
          UNTIL HZ IN ['Y','J','Z','N'];
          Write(HZ);
          IF HZ <> 'N' THEN HZ := '1' ELSE HZ := '0';
        END;
      END;
      HideCursor;
      SetButton(38,27,White,LightRed+Blink,OK,50);
      SetButton(38,27,White,Black+Blink,OK,50);
      Str(Zoom,Zoom2);
      Str(Numb,Numb2);
      Str(mx,mx2);
      Str(my,my2);
      Assign(f2,'orbit.dat');
      Rename(f2,'orbit.exe');
      IF Numb <> 0 THEN BEGIN
        Exec('orbit.exe ',' '+Numb2+' '+Fil[0]+' '+Zoom2+' '+mx2+' '+my2+' '+HZ);
      END ELSE BEGIN
        Exec('orbit.exe ',' '+'all'+' '+Zoom2+' '+mx2+' '+my2);
      END;
      Rename(f2,'orbit.dat');
    END;
  END ELSE BEGIN
    SetButton(63,16,White,LightRed+Blink,NO,50);
    SetButton(63,16,White,Black+Blink,NO,50);
    Numb := Index;
  END;
  TextMode(300);
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_Starmap;
BEGIN
  {$M 50000,0,0}
  Starmap_Interface1;
  b := 1;
  Numb := Index;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
  Write('²');
  FOR i := 0 TO 21 DO BEGIN
    IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
    GotoXY(12,14+i);
    Write('     ');
    GotoXY(12,14+i);
    IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
    GotoXY(18,14+i);
    Blank12;
    GotoXY(18,14+i);
    Write(ExoFile[Numb+i]);
  END;
  GotoXY(33,14); Write(1:4,' ³ ',ExoFile[Index]);
  TextBackground(White);
  TextColor(Black+Blink);
  GotoXY(33,12); Write('Zu laden: ',+b:2,'/12');
  Textbackground(Black);
  REPEAT
    Input := ReadKey;
    Input := UpCase(Input);
    IF Input = NULL THEN BEGIN
      Input2 := ReadKey;
      NotDouble := 0;
      FOR i := 1 TO 12 DO BEGIN
        IF ExoFile[Numb] = Fil[i] THEN Inc(NotDouble);
      END;
      IF b < 12 THEN IF (Input2 = ARRT) AND (ExoFile[Numb] <> ExoFile[Index]) AND (NotDouble = 0) THEN BEGIN
        Inc(b);
        Fil[b] := ExoFile[Numb];
        SetButton(63,18,White,Black+Blink,'  ->  ',50);
        SetButton(63,18,White,LightRed+Blink,'  ->  ',50);
        SetButton(63,18,White,Black+Blink,'  ->  ',0);
        TextBackground(Black);
        TextColor(White);
      END;
      IF b IN [2..12] THEN IF Input2 = ARLF THEN BEGIN
        Dec(b);
        Fil[b+1] := '';
        SetButton(63,20,White,Black+Blink,'  <-  ',50);
        SetButton(63,20,White,LightRed+Blink,'  <-  ',50);
        SetButton(63,20,White,Black+Blink,'  <-  ',0);
        TextBackground(Black);
        TextColor(White);
      END;
      IF Input2 = ARUP THEN Dec(Numb);
      IF Input2 = ARDN THEN Inc(Numb);
      IF Input2 = PGUP THEN Dec(Numb,10);
      IF Input2 = PGDN THEN Inc(Numb,10);
      IF Input2 = POS1 THEN Numb := 1;
      IF Input2 = END1 THEN Numb := ExoFileMax;
      IF Numb < 1 THEN Numb := ExoFileMax;
      IF Numb > ExoFileMax THEN Numb := 1;
      FOR i := 0 TO 21 DO BEGIN
        FOR n := 1 TO 20 DO BEGIN
          GotoXY(30,14+n);
          Write('°');
        END;
        GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
        Write('²');
        IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
        GotoXY(12,14+i);
        Write('     ');
        GotoXY(12,14+i);
        IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
        GotoXY(18,14+i);
        Blank12;
        GotoXY(18,14+i);
        ExoFile[ExoFileMax+1] := '';
        Write(ExoFile[Numb+i]);
        TextBackground(White);
        TextColor(Black+Blink);
        GotoXY(33,12); Write('Zu laden: ',+b:2,'/12');
        Textbackground(Black);
        TextColor(White);
        FOR n := 2 TO 12 DO BEGIN
          GotoXY(33,13+n);
          Blank29;
          IF n <= b THEN BEGIN
            GotoXY(33,13+n); Write(n:4,' ³ ',Fil[n]);
          END;
        END;
      END;
    END;
  UNTIL Input IN [ENTER,ESC,'A'];
  IF Input = 'A' THEN BEGIN
    Numb := 0;
    SetButton(63,22,White,Black+Blink,' Alle ',50);
    SetButton(63,22,White,LightRed+Blink,' Alle ',50);
    SetButton(63,22,White,Black+Blink,' Alle ',0);
    TextBackground(Black);
    TextColor(White);
  END;
  IF Input IN [ENTER,'A'] THEN BEGIN
    SetButton(63,14,White,LightRed+Blink,OK,50);
    SetButton(63,14,White,Black+Blink,OK,50);
    IF NOT(FileExists('starmap.exe')) AND NOT(FileExists('starmap.dat')) THEN BEGIN
      Msg_NoModule;
    END ELSE BEGIN
      StarMap_Interface3;
      IF Input = 'A' THEN Numb := 0 ELSE Numb := b;
      Fil[0] := '';
      FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
        Fil[0] := Fil[0]+ExoFile[Index][i];
      END;
      FOR n := 1 TO Numb DO BEGIN
        FOR i := 1 TO Length(Fil[n])-4 DO BEGIN
          TempStr := TempStr+Fil[n][i];
        END;
        Fil[n] := TempStr;
        TempStr := '';
        Fil[0] := Fil[0]+' '+Fil[n];
      END;
      Starmap_Interface2;
      Numb2 := '';
      Numb3 := 0;
      Numb4 := '';
      Numb5 := '';
      Numb6 := '';
      Numb7 := '';
      Numb8 := '';
      TextBackground(Black);
      TextColor(White);
      IF Numb = 1 THEN BEGIN
        GotoXY(43,13); Write(' ');
        GotoXY(43,13);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN Numb5 := '1';
        HideCursor;
        Write(Input);
      END;
      IF Numb5 <> '1' THEN BEGIN
        GotoXY(38,15); Write(' ');
        GotoXY(38,15);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN Inc(Numb3,16);
        HideCursor;
        Write(Input);
      END;
      IF Numb5 <> '1' THEN BEGIN
        GotoXY(56,17); Write(' ');
        GotoXY(56,17);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN Inc(Numb3,8);
        HideCursor;
        Write(Input);
      END;
      GotoXY(57,19); Write(' ');
      GotoXY(57,19);
      ShowCursor;
      REPEAT
        Input := Readkey;
        Input := UpCase(Input);
      UNTIL Input IN ['Y','Z','J','N'];
      IF Input <> 'N' THEN Inc(Numb3,4);
      Write(Input);
      HideCursor;
      IF (Numb = 1) THEN BEGIN
        GotoXY(56,21); Write(' ');
        GotoXY(56,21);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN Inc(Numb3,2);
        HideCursor;
        Write(Input);
      END;
      IF (Numb5 = '1') AND (Numb = 1) THEN BEGIN
        GotoXY(57,23); Write(' ');
        GotoXY(57,23);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN Numb6 := '1' ELSE Numb6 := '';
        HideCursor;
        Write(Input);
      END;
      IF (Numb5 = '1') AND (Numb = 1) THEN BEGIN
        GotoXY(52,25); Write(' ');
        GotoXY(52,25);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN Numb7 := '1' ELSE Numb7 := '';
        HideCursor;
        Write(Input);
      END;
      SetButton(38,27,White,LightRed+Blink,OK,50);
      SetButton(38,27,White,Black+Blink,OK,50);
      IF Numb6 = '1' THEN BEGIN
        Starmap_Interface4;
        TextBackground(LightGray);
        TextColor(LightRed);
        i := 1;
        GotoXY(22,14+i); Arrow;
        REPEAT
          Input := ReadKey;
          IF Input = NULL THEN BEGIN
            Input2 := ReadKey;
            IF Input2 = ARDN THEN Inc(i);
            IF Input2 = ARUP THEN Dec(i);
            IF i < 1 THEN i := 6;
            IF i > 6 THEN i := 1;
            TextColor(LightGray);
            FOR n := 1 TO 6 DO BEGIN
              GotoXY(22,14+(2*n)-1); Arrow;
            END;
            TextColor(LightRed);
            IF i < 7 THEN BEGIN
              GotoXY(22,14+(2*i)-1); Arrow;
            END;
          END;
        UNTIL Input IN [ENTER,ESC];
        CASE i OF
          1 : Numb8 := '1';
          2 : Numb8 := '2';
          3 : Numb8 := '3';
          4 : Numb8 := '4';
          5 : Numb8 := '5';
          6 : Numb8 := '6';
        END;
        SetButton(38,27,White,LightRed+Blink,OK,50);
        SetButton(38,27,White,Black+Blink,OK,50);
      END;
      Str(Numb,Numb2);
      Str(Numb3,Numb4);
      Assign(f2,'starmap.dat');
      Rename(f2,'starmap.exe');
      IF Numb4 = '' THEN Numb4 := '0';
      IF Numb5 = '' THEN Numb5 := '0';
      IF Numb6 = '' THEN Numb6 := '0';
      IF Numb7 = '' THEN Numb7 := '0';
      IF Numb8 = '' THEN Numb8 := '1';
      IF Numb <> 0 THEN BEGIN
        Exec('starmap.exe',' '+Numb2+' '+Fil[0]+' '+Numb4+' '+Numb5+' '+Numb6+' '+Numb7+' '+Numb8);
        {Writeln('starmap.exe',' '+Numb2+' '+Fil[0]+' '+Numb4+' '+Numb5+' '+Numb6+' '+Numb7+' '+Numb8); Readkey;}
      END ELSE BEGIN
        Exec('starmap.exe',' '+'all'+' '+Numb4);
      END;
      Rename(f2,'starmap.dat');
    END;
  END ELSE BEGIN
    SetButton(63,16,White,LightRed+Blink,NO,50);
    SetButton(63,16,White,Black+Blink,NO,50);
    Numb := Index;
  END;
  TextMode(300);
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_MassCompare;
BEGIN
  {$M 50000,0,0}
  MassCompare_Interface1;
  b := 1;
  Numb := Index;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
  Write('²');
  FOR i := 0 TO 21 DO BEGIN
    IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
    GotoXY(12,14+i);
    Write('     ');
    GotoXY(12,14+i);
    IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
    GotoXY(18,14+i);
    Blank12;
    GotoXY(18,14+i);
    Write(ExoFile[Numb+i]);
  END;
  GotoXY(33,14); Write(1:4,' ³ ',ExoFile[Index]);
  TextBackground(White);
  TextColor(Black+Blink);
  GotoXY(33,12); Write('Zu laden: ',+b:2,'/5');
  Textbackground(Black);
  REPEAT
    Input := ReadKey;
    Input := UpCase(Input);
    IF Input = NULL THEN BEGIN
      Input2 := ReadKey;
      NotDouble := 0;
      FOR i := 1 TO 5 DO BEGIN
        IF ExoFile[Numb] = Fil[i] THEN Inc(NotDouble);
      END;
      IF b < 5 THEN IF (Input2 = ARRT) AND (ExoFile[Numb] <> ExoFile[Index]) AND (NotDouble = 0) THEN BEGIN
        Inc(b);
        Fil[b] := ExoFile[Numb];
        SetButton(63,18,White,Black+Blink,'  ->  ',50);
        SetButton(63,18,White,LightRed+Blink,'  ->  ',50);
        SetButton(63,18,White,Black+Blink,'  ->  ',0);
        TextBackground(Black);
        TextColor(White);
      END;
      IF b IN [2..5] THEN IF Input2 = ARLF THEN BEGIN
        Dec(b);
        Fil[b+1] := '';
        SetButton(63,20,White,Black+Blink,'  <-  ',50);
        SetButton(63,20,White,LightRed+Blink,'  <-  ',50);
        SetButton(63,20,White,Black+Blink,'  <-  ',0);
        TextBackground(Black);
        TextColor(White);
      END;
      IF Input2 = ARUP THEN Dec(Numb);
      IF Input2 = ARDN THEN Inc(Numb);
      IF Input2 = PGUP THEN Dec(Numb,10);
      IF Input2 = PGDN THEN Inc(Numb,10);
      IF Input2 = POS1 THEN Numb := 1;
      IF Input2 = END1 THEN Numb := ExoFileMax;
      IF Numb < 1 THEN Numb := ExoFileMax;
      IF Numb > ExoFileMax THEN Numb := 1;
      FOR i := 0 TO 21 DO BEGIN
        FOR n := 1 TO 20 DO BEGIN
          GotoXY(30,14+n);
          Write('°');
        END;
        GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
        Write('²');
        IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
        GotoXY(12,14+i);
        Write('     ');
        GotoXY(12,14+i);
        IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
        GotoXY(18,14+i);
        Blank12;
        GotoXY(18,14+i);
        ExoFile[ExoFileMax+1] := '';
        Write(ExoFile[Numb+i]);
        TextBackground(White);
        TextColor(Black+Blink);
        GotoXY(33,12); Write('Zu laden: ',+b:2,'/5');
        Textbackground(Black);
        TextColor(White);
        FOR n := 2 TO 5 DO BEGIN
          GotoXY(33,13+n);
          Blank29;
          IF n <= b THEN BEGIN
            GotoXY(33,13+n); Write(n:4,' ³ ',Fil[n]);
          END;
        END;
      END;
    END;
  UNTIL Input IN [ENTER,ESC];
  IF Input IN [ENTER] THEN BEGIN
    SetButton(63,14,White,LightRed+Blink,OK,50);
    SetButton(63,14,White,Black+Blink,OK,50);
    IF NOT(FileExists('masscomp.exe')) AND NOT(FileExists('masscomp.dat')) THEN BEGIN
      Msg_NoModule;
    END ELSE BEGIN
      MassCompare_Interface2;
      IF Input = 'A' THEN Numb := 0 ELSE Numb := b;
      Fil[0] := '';
      FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
        Fil[0] := Fil[0]+ExoFile[Index][i];
      END;
      FOR n := 1 TO Numb DO BEGIN
        FOR i := 1 TO Length(Fil[n])-4 DO BEGIN
          TempStr := TempStr+Fil[n][i];
        END;
        Fil[n] := TempStr;
        TempStr := '';
        Fil[0] := Fil[0]+' '+Fil[n];
      END;
      Str(Numb,Numb2);
      Assign(f2,'masscomp.dat');
      Rename(f2,'masscomp.exe');
      IF Numb <> 0 THEN BEGIN
        Exec('masscomp.exe',' '+Numb2+' '+Fil[0]);
      {END ELSE BEGIN
        Exec('masscomp.exe',' '+'all');]}
      END;
      Rename(f2,'masscomp.dat');
    END;
  END ELSE BEGIN
    SetButton(63,16,White,LightRed+Blink,NO,50);
    SetButton(63,16,White,Black+Blink,NO,50);
    Numb := Index;
  END;
  TextMode(300);
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE SelectCumulative;
BEGIN
  Distribution_Interface3;
  i := 0;
  REPEAT
    CASE i OF
      0 : BEGIN
            SetButton(33,25,LightGray,Green+Blink,YES,0);
            SetButton(40,25,LightGray,Black+Blink,NO,0);
          END;
      1 : BEGIN
            SetButton(33,25,LightGray,Black+Blink,YES,0);
            SetButton(40,25,LightGray,Green+Blink,NO,0);
          END;
     END;
     Input := Readkey;
     Input := Upcase(Input);
     IF NOT(Input = ENTER) THEN CASE Input OF
       NULL : BEGIN
        Input2 := Readkey;
        Input2 := Upcase(Input2);
        CASE Input2 OF
           ARLF : i := 0;
           ARRT : i := 1;
        END;
      END;
    END;
  UNTIL Input = ENTER;
  CASE i OF
    0 : BEGIN
      SetButton(33,25,LightGray,LightRed+Blink,YES,0);
      SetButton(40,25,LightGray,Black+Blink,NO,0);
      Input2Str := Input2Str+' 1';
    END;
    1 : BEGIN
      SetButton(33,25,LightGray,Black+Blink,YES,0);
      SetButton(40,25,LightGray,LightRed+Blink,NO,0);
      Input2Str := Input2Str+' 0';
    END;
  END;
  Wait(5);
  SetButton(33,25,LightGray,Black+Blink,YES,0);
  SetButton(40,25,LightGray,Black+Blink,NO,50);
END;

PROCEDURE Modul_Distribution;
BEGIN
  {$M 50000,0,0}
  Distribution_Interface1;
  IF NOT(FileExists('distri.exe')) AND NOT(FileExists('distri.dat')) THEN BEGIN
    Msg_NoModule;
  END ELSE BEGIN
    Distribution_Interface2;
    i := 1;
    REPEAT
      Input := ReadKey;
      IF Input = NULL THEN BEGIN
        Input2 := ReadKey;
        IF Input2 = ARDN THEN Inc(i);
        IF Input2 = ARUP THEN Dec(i);
        IF i < 1 THEN i := 12;
        IF i > 12 THEN i := 1;
        TextBackground(LightGray);
        TextColor(LightGray);
        FOR n := 1 TO 12+1 DO BEGIN
          GotoXY(22,23+n); Arrow;
        END;
        TextColor(LightRed);
        IF i < 5 THEN BEGIN
          GotoXY(22,23+i); Arrow;
        END ELSE BEGIN
          GotoXY(22,24+i); Arrow;
        END;
      END;
    UNTIL Input IN [ENTER,ESC];
    IF Input = ENTER THEN BEGIN
      SetButton(53,24,LightGray,LightRed+Blink,OK,50);
      SetButton(53,24,LightGray,Black+Blink,OK,50);
      CASE i OF
        1 : BEGIN Input2Str := '1'; SelectCumulative; END;
        2 : BEGIN Input2Str := '2'; SelectCumulative; END;
        3 : BEGIN Input2Str := '3'; SelectCumulative; END;
        4 : BEGIN
              Input2Str := '4';
              TextBackground(Black);
              TextColor(White);
              GotoXY(52,28);
              ShowCursor;
              REPEAT
                Input := ReadKey;
                Input := UpCase(Input);
              UNTIL Input IN ['J','Y','Z','N'];
              IF Input <> 'N' THEN Input2Str := '0';
              Write(Input);
              HideCursor;
              SetButton(53,24,LightGray,LightRed+Blink,OK,50);
              SetButton(53,24,LightGray,Black+Blink,OK,50);
            END;
        5 : Input2Str := '5';
        6 : BEGIN Input2Str := '6'; SelectCumulative; END;
        7 : BEGIn Input2Str := '7'; SelectCumulative; END;
        8 : Input2Str := '8';
        9 : BEGIN Input2Str := '9'; SelectCumulative; END;
        10 : BEGIN Input2Str := '-7'; SelectCumulative; END;
        11 : BEGIN Input2Str := '-1'; SelectCumulative; END;
        12 : Input2Str := '-2';
      END;
      Assign(f2,'distri.dat');
      Rename(f2,'distri.exe');
      Exec('distri.exe',Input2Str);
      Rename(f2,'distri.dat');
    END ELSE BEGIN
      SetButton(53,26,White,LightRed+Blink,NO,50);
      SetButton(53,26,White,Black+Blink,NO,50);
    END;
  END;
  TextMode(300);
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_Diagram;
BEGIN
  {$M 50000,0,0}
  Diagram_Interface1;
  IF NOT(FileExists('diagram.exe')) AND NOT(FileExists('diagram.dat')) THEN BEGIN
    Msg_NoModule;
  END ELSE BEGIN
    Numb := 1;
    Fil[0] := '';
    FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
      Fil[0] := Fil[0]+ExoFile[Index][i];
    END;
    Diagram_Interface2;
    i := 1;
    REPEAT
      Input := ReadKey;
      IF Input = NULL THEN BEGIN
        Input2 := ReadKey;
        IF Input2 = ARDN THEN Inc(i);
        IF Input2 = ARUP THEN Dec(i);
        IF i <  1 THEN i := 14;
        IF i > 14 THEN i := 1;
        TextBackground(LightGray);
        TextColor(LightGray);
        FOR n := 1 TO 14 DO BEGIN
          GotoXY(22,23+n); Arrow;
        END;
        TextColor(LightRed);
        GotoXY(22,23+i); Arrow;
      END;
    UNTIL Input IN [ENTER,ESC];
    IF Input = ENTER THEN BEGIN
      SetButton(51,24,White,LightRed+Blink,OK,50);
      SetButton(51,24,White,Black+Blink,OK,50);
      CASE i OF
         1 : Input2Str := '1';
         2 : Input2Str := '2';
         3 : Input2Str := '3';
         4 : Input2Str := '4';
         5 : Input2Str := '5';
         6 : Input2Str := '6';
         7 : Input2Str := '7';
         8 : Input2Str := '8';
         9 : Input2Str := '9';
        10 : Input2Str := '0';
        11 : Input2Str := '-9';
        12 : Input2Str := '-1';
        13 : Input2Str := '-2';
        14 : Input2Str := '-3';
      END;
      Assign(f2,'diagram.dat');
      Rename(f2,'diagram.exe');
      Exec('diagram.exe',' '+Input2Str);
      Rename(f2,'diagram.dat');
    END;
  END;
  TextMode(300);
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_HRD;
BEGIN
  {$M 50000,0,0}
  HRD_Interface1;
  b := 1;
  Numb := Index;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
  Write('²');
  FOR i := 0 TO 21 DO BEGIN
    IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
    GotoXY(12,14+i);
    Write('     ');
    GotoXY(12,14+i);
    IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
    GotoXY(18,14+i);
    Blank12;
    GotoXY(18,14+i);
    Write(ExoFile[Numb+i]);
  END;
  GotoXY(33,14); Write(1:4,' ³ ',ExoFile[Index]);
  TextBackground(White);
  TextColor(Black+Blink);
  GotoXY(33,12); Write('Zu laden: ',+b:2,'/12');
  Textbackground(Black);
  REPEAT
    Input := ReadKey;
    Input := UpCase(Input);
    IF Input = NULL THEN BEGIN
      Input2 := ReadKey;
      NotDouble := 0;
      FOR i := 1 TO 12 DO BEGIN
        IF ExoFile[Numb] = Fil[i] THEN Inc(NotDouble);
      END;
      IF b < 12 THEN IF (Input2 = ARRT) AND (ExoFile[Numb] <> ExoFile[Index]) AND (NotDouble = 0) THEN BEGIN
        Inc(b);
        Fil[b] := ExoFile[Numb];
        HRD_Interface2;
      END;
      IF b IN [2..12] THEN IF Input2 = ARLF THEN BEGIN
        Dec(b);
        Fil[b+1] := '';
        HRD_Interface3;
      END;
      IF Input2 = ARUP THEN Dec(Numb);
      IF Input2 = ARDN THEN Inc(Numb);
      IF Input2 = PGUP THEN Dec(Numb,10);
      IF Input2 = PGDN THEN Inc(Numb,10);
      IF Input2 = POS1 THEN Numb := 1;
      IF Input2 = END1 THEN Numb := ExoFileMax;
      IF Numb < 1 THEN Numb := ExoFileMax;
      IF Numb > ExoFileMax THEN Numb := 1;
      FOR i := 0 TO 21 DO BEGIN
        FOR n := 1 TO 20 DO BEGIN
          GotoXY(30,14+n);
          Write('°');
        END;
        GotoXY(30,15+(Round(19*Numb/ExoFileMax)));
        Write('²');
        IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
        GotoXY(12,14+i);
        Write('     ');
        GotoXY(12,14+i);
        IF (Numb+i > 0) AND (Numb+i <= ExoFileMax) THEN Write(Numb+i:5);
        GotoXY(18,14+i);
        Blank12;
        GotoXY(18,14+i);
        ExoFile[ExoFileMax+1] := '';
        Write(ExoFile[Numb+i]);
        TextBackground(White);
        TextColor(Black+Blink);
        GotoXY(33,12); Write('Zu laden: ',+b:2,'/12');
        Textbackground(Black);
        TextColor(White);
        FOR n := 2 TO 12 DO BEGIN
          GotoXY(33,13+n);
          Blank29;
          IF n <= b THEN BEGIN
            GotoXY(33,13+n); Write(n:4,' ³ ',Fil[n]);
          END;
        END;
      END;
    END;
  UNTIL Input IN [ENTER,ESC,'A'];
  IF Input = 'A' THEN BEGIN
    Numb := 0;
    SetButton(63,22,White,Black+Blink,' Alle ',50);
    SetButton(63,22,White,LightRed+Blink,' Alle ',50);
    SetButton(63,22,White,Black+Blink,' Alle ',0);
    TextBackground(Black);
    TextColor(White);
  END;
  IF Input IN [ENTER,'A'] THEN BEGIN
    SetButton(63,14,White,LightRed+Blink,OK,50);
    SetButton(63,14,White,Black+Blink,OK,50);
    IF NOT(FileExists('hrd.exe')) AND NOT(FileExists('hrd.dat')) THEN BEGIN
      Msg_NoModule;
    END ELSE BEGIN
      HRD_Interface4;
      IF Input = 'A' THEN Numb := 0 ELSE Numb := b;
      Fil[0] := '';
      FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
        Fil[0] := Fil[0]+ExoFile[Index][i];
      END;
      FOR n := 1 TO Numb DO BEGIN
        FOR i := 1 TO Length(Fil[n])-4 DO BEGIN
          TempStr := TempStr+Fil[n][i];
        END;
        Fil[n] := TempStr;
        TempStr := '';
        Fil[0] := Fil[0]+' '+Fil[n];
      END;
      Str(Numb,Numb2);
      Assign(f2,'hrd.dat');
      Rename(f2,'hrd.exe');
      IF Numb <> 0 THEN BEGIN
        Exec('hrd.exe',' '+Numb2+' '+Fil[0]);
      END ELSE BEGIN
        Exec('hrd.exe',' '+'all');
      END;
      Rename(f2,'hrd.dat');
    END;
  END ELSE BEGIN
    SetButton(63,16,White,LightRed+Blink,NO,50);
    SetButton(63,16,White,Black+Blink,NO,50);
    Numb := Index;
  END;
  TextMode(300);
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE Modul_Star3D;
BEGIN
  {$M 50000,0,0}
  IF NOT(FileExists('star3d.exe')) AND NOT(FileExists('star3d.dat')) THEN BEGIN
    Msg_NoModule;
  END ELSE BEGIN
    Star3D_Interface;
    NumbR  := 0;
    Numb  := 1;
    Numb3 := 0;
    Numb2 := '';
    Numb4 := '';
    Numb5 := '';
    Numb6 := '';
    Numb7 := '';
    GotoXY(23,12); Zoom := ReadInt(8); Str(Zoom,Numb2);
    GotoXY(23,16); MX := ReadInt(8); Str(MX,Numb4);
    GotoXY(23,20); MY := ReadInt(8); Str(MY,Numb5);
    REPEAT
      GotoXY(23,23); SpecStr3_1 := ReadStr(3);
      SpecStr3_1[1] := UpCase(SpecStr3_1[1]);
    UNTIL (SpecStr3_1[1] = 'O') OR (SpecStr3_1[1] = 'B') OR
          (SpecStr3_1[1] = 'A') OR (SpecStr3_1[1] = 'F') OR
          (SpecStr3_1[1] = 'G') OR (SpecStr3_1[1] = 'K') OR
          (SpecStr3_1[1] = 'M') OR (SpecStr3_1[1] = 'L') OR
          (SpecStr3_1[1] = 'T');
    REPEAT
      GotoXY(23,24); SpecStr3_2 := ReadStr(3);
      SpecStr3_2[1] := UpCase(SpecStr3_2[1]);
    UNTIL (SpecStr3_2[1] = 'O') OR (SpecStr3_2[1] = 'B') OR
          (SpecStr3_2[1] = 'A') OR (SpecStr3_2[1] = 'F') OR
          (SpecStr3_2[1] = 'G') OR (SpecStr3_2[1] = 'K') OR
          (SpecStr3_2[1] = 'M') OR (SpecStr3_2[1] = 'L') OR
          (SpecStr3_2[1] = 'T');
    HideCursor;
    Fil[0] := '';
    FOR i := 1 TO Length(ExoFile[Index])-4 DO BEGIN
      Fil[0] := Fil[0]+ExoFile[Index][i];
    END;
    FOR n := 1 TO Numb DO BEGIN
      FOR i := 1 TO Length(Fil[n])-4 DO BEGIN
        TempStr := TempStr+Fil[n][i];
      END;
      Fil[n] := TempStr;
      TempStr := '';
      Fil[0] := Fil[0]+' '+Fil[n];
    END;
    Str(Numb,Numb8);
    Assign(f2,'star3d.dat');
    Rename(f2,'star3d.exe');
    Exec('star3d.exe',' '+Numb2+' '+Numb4+' '+Numb5+' '+SpecStr3_1[1]+' '+SpecStr3_2[1]+' '
      +' '+Numb8+' '+Fil[0]);
    Rename(f2,'star3d.dat');
  END;
  TextMode(300);
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

PROCEDURE ScreenSaver;
BEGIN
  IF NOT(FileExists('screen.exe')) AND NOT(FileExists('screen.dat')) THEN BEGIN
    Msg_NoModule;
  END ELSE BEGIN
    IF FileExists('screen.exe') THEN BEGIN
      IF FileExists('screen.dat') THEN BEGIN
        Assign(f2,'screen.dat');
        Erase(f2);
      END;
       Assign(f2,'screen.exe');
       Rename(f2,'screen.dat');
    END;
    Assign(f2,'screen.dat');
    Rename(f2,'screen.exe');
    IF Random(3) = 0 THEN Exec('screen.exe','0') ELSE IF Random(3) = 1 THEN Exec('screen.exe','1')
      ELSE IF Random(3) = 2 THEN Exec('screen.exe','2') ELSE Exec('screen.exe','');
    Rename(f2,'screen.dat');
  END;
  TextMode(300);
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
END;

BEGIN
  Index := 1;
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
  Randomize;
  b := 0;
  REPEAT
    SearchDirX('splash\','*.lzs');
  UNTIL DosError <> 0;
  IF b <> 0 THEN BEGIN
    b := Random(b)+1;
  END;
  {$M 50000,0,0}
  IF NOT(FileExists('splash.exe')) AND NOT(FileExists('splash.dat')) THEN BEGIN
    {Do Nothing}
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
  ClrScr;
  MakeTimestamp;
  TextMode(300);
  HideCursor;
  MainApp;
  ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
    Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
    Period2_Max,Ecc2_Min,Ecc2_Max);
  ScanExoUpdate(Index);
  REPEAT
    Input := Readkey;
    Input := Upcase(Input);
    CASE Input OF
      NULL : BEGIN
        Input2 := Readkey;
        CASE Input2 OF
          POS1 : BEGIN
            SetButton(5,20,White,LightRed+Blink,'þ',50);
            SetButton(5,20,White,Black+Blink,'þ',0);
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
            SetButton(35,20,White,LightRed+Blink,'þ',50);
            SetButton(35,20,White,Black+Blink,'þ',0);
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
      'I' : BEGIN
              Info;
              ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,
                Metal2_Max,Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,
                Axis2_Max,Period2_Min,Period2_Max,Ecc2_Min,Ecc2_Max);
              ScanExoUpdate(Index);
            END;
      'C' : BEGIN
              Credits;
              ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,
                Metal2_Max,Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,
                Axis2_Max,Period2_Min,Period2_Max,Ecc2_Min,Ecc2_Max);
              ScanExoUpdate(Index);
            END;
      'T' : BEGIN
              Thanks;
              ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,
                Metal2_Max,Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,
                Axis2_Max,Period2_Min,Period2_Max,Ecc2_Min,Ecc2_Max);
              ScanExoUpdate(Index);
            END;
      'E' : BEGIN Help; ScanExoUpdate(Index); END;
      'F' : Search;
      'V' : Filter;
      'Z' : ScreenSaver;
      'Y' : BEGIN History; ScanExoUpdate(Index); END;
      'X',ESC : Exit2 := True;
    END;
  UNTIL Exit2;
  ShowCursor;
END.
