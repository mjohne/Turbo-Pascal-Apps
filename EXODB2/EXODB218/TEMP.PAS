    ZoomFactor,
    MidPointShiftX,
    MidPointShiftY,
    SpectraltypeMin,
    SpectraltypeMax,
    Reserved1,
    Reserved2,
    Reserved3,
    Reserved4,
    Reserved5,
    Reserved6,
    NumberOfEntrys        : Integer;



  IF FileExists('starmap.dat') THEN BEGIN
    InitStarmapOptions;
    Starmap_Interface1;
    b := 1;
    StarmapOption.NumberOfEntrys := Index;
    ScanExo(Spec2_Min,Spec2_Max,j3,j4,Mag2_Min,Mag2_Max,StarMass2_Min,StarMass2_Max,Metal2_Min,Metal2_Max,
      Dist2_Min,Dist2_Max,Rec2_Min,Rec2_Max,Dec2_Min,Dec2_Max,PlanetMass2_Min,PlanetMass2_Max,Axis2_Min,Axis2_Max,Period2_Min,
      Period2_Max,Ecc2_Min,Ecc2_Max);
    GotoXY(30,15+(Round(19*StarmapOption.NumberOfEntrys/ExoFileMax)));
    Write('²');
    FOR i := 0 TO 21 DO BEGIN
      IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
      GotoXY(12,14+i);
      Write('     ');
      GotoXY(12,14+i);
      IF (StarmapOption.NumberOfEntrys+i > 0) AND (StarmapOption.NumberOfEntrys+i <= ExoFileMax)
        THEN Write(StarmapOption.NumberOfEntrys+i:5);
      GotoXY(18,14+i);
      Blank12;
      GotoXY(18,14+i);
      Write(ExoFile[StarmapOption.NumberOfEntrys+i]);
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
          IF ExoFile[StarmapOption.NumberOfEntrys] = Fil[i] THEN Inc(NotDouble);
        END;
        IF b < 12 THEN
          IF (Input2 = ARRT) AND (ExoFile[StarmapOption.NumberOfEntrys] <> ExoFile[Index]) AND (NotDouble = 0) THEN BEGIN
          Inc(b);
          Fil[b] := ExoFile[StarmapOption.NumberOfEntrys];
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
        IF Input2 = ARUP THEN Dec(StarmapOption.NumberOfEntrys);
        IF Input2 = ARDN THEN Inc(StarmapOption.NumberOfEntrys);
        IF Input2 = PGUP THEN Dec(StarmapOption.NumberOfEntrys,10);
        IF Input2 = PGDN THEN Inc(StarmapOption.NumberOfEntrys,10);
        IF Input2 = POS1 THEN StarmapOption.NumberOfEntrys := 1;
        IF Input2 = END1 THEN StarmapOption.NumberOfEntrys := ExoFileMax;
        IF StarmapOption.NumberOfEntrys < 1 THEN StarmapOption.NumberOfEntrys := ExoFileMax;
        IF StarmapOption.NumberOfEntrys > ExoFileMax THEN StarmapOption.NumberOfEntrys := 1;
        FOR i := 0 TO 21 DO BEGIN
          FOR n := 1 TO 20 DO BEGIN
            GotoXY(30,14+n);
            Write('°');
          END;
          GotoXY(30,15+(Round(19*StarmapOption.NumberOfEntrys/ExoFileMax)));
          Write('²');
          IF i = 0 THEN TextColor(LightCyan) ELSE TextColor(White);
          GotoXY(12,14+i);
          Write('     ');
          GotoXY(12,14+i);
          IF (StarmapOption.NumberOfEntrys+i > 0) AND (StarmapOption.NumberOfEntrys+i <= ExoFileMax)
            THEN Write(StarmapOption.NumberOfEntrys+i:5);
          GotoXY(18,14+i);
          Blank12;
          GotoXY(18,14+i);
          ExoFile[ExoFileMax+1] := '';
          Write(ExoFile[StarmapOption.NumberOfEntrys+i]);
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
      StarmapOption.NumberOfEntrys := 0;
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
        IF Input = 'A' THEN StarmapOption.NumberOfEntrys := ExoFileMax ELSE StarmapOption.NumberOfEntrys := b;
        FOR i := 1 TO StarmapOption.NumberOfEntrys DO ModulFileEntrys[i] := ExoFile[i];
        Starmap_Interface2;
        TextBackground(Black);
        TextColor(White);
        { --- Eingabe der Ausschnitt-Vergr”áerung --- }
        IF StarmapOption.NumberOfEntrys = 1 THEN BEGIN
          GotoXY(43,13); Write(' ');
          GotoXY(43,13);
          ShowCursor;
          REPEAT
            Input := Readkey;
            Input := UpCase(Input);
          UNTIL Input IN ['Y','Z','J','N'];
          IF Input <> 'N' THEN StarmapOption.Magnification := 1;
          HideCursor;
          Write(Input);
        END;
        { --- Eingabe des Gradnetz --- }
        IF StarmapOption.Magnification = 0 THEN BEGIN
          GotoXY(38,15); Write(' ');
          GotoXY(38,15);
          ShowCursor;
          REPEAT
            Input := Readkey;
            Input := UpCase(Input);
          UNTIL Input IN ['Y','Z','J','N'];
          IF Input <> 'N' THEN StarmapOption.GridLines := 1;
          HideCursor;
          Write(Input);
        END;
        { --- Eingabe der Ekliptik & Himmels„quator --- }
        GotoXY(56,17); Write(' ');
        GotoXY(56,17);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN StarmapOption.Ecliptic := 1;
        HideCursor;
        Write(Input);
        { --- Eingabe der Sterbilder-Konstellationen --- }
        GotoXY(57,19); Write(' ');
        GotoXY(57,19);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN StarmapOption.ConstellationLines := 1;
        Write(Input);
        HideCursor;
        { --- Eingabe der Sternbilder-Begrenzung --- }
        GotoXY(56,21); Write(' ');
        GotoXY(56,21);
        ShowCursor;
        REPEAT
          Input := Readkey;
          Input := UpCase(Input);
        UNTIL Input IN ['Y','Z','J','N'];
        IF Input <> 'N' THEN StarmapOption.ConstellationBorder := 1;
        HideCursor;
        Write(Input);
        { --- Eingabe der Sternbilder-Bezeichnungen --- }
        IF (StarmapOption.Magnification = 1) AND (StarmapOption.NumberOfEntrys = 1) THEN BEGIN
          GotoXY(57,23); Write(' ');
          GotoXY(57,23);
          ShowCursor;
          REPEAT
            Input := Readkey;
            Input := UpCase(Input);
          UNTIL Input IN ['Y','Z','J','N'];
          IF Input <> 'N' THEN StarmapOption.ConstellationNames := 1;
          HideCursor;
          Write(Input);
        END;
        { --- Eingabe der Sternnamen --- }
        IF (StarmapOption.Magnification = 1) AND (StarmapOption.NumberOfEntrys = 1) THEN BEGIN
          GotoXY(52,25); Write(' ');
          GotoXY(52,25);
          ShowCursor;
          REPEAT
            Input := Readkey;
            Input := UpCase(Input);
          UNTIL Input IN ['Y','Z','J','N'];
          IF Input <> 'N' THEN StarmapOption.Starnames := 1;
          HideCursor;
          Write(Input);
        END;
        SetButton(38,27,White,LightRed+Blink,OK,50);
        SetButton(38,27,White,Black+Blink,OK,50);
        { --- Auswahl des Sternkatalogs --- }
        IF (StarmapOption.Magnification = 1) THEN BEGIN
          IF FileExists('STARS2HP.LST') THEN BEGIN
            Starmap_Interface4;
            TextBackground(LightGray);
            TextColor(LightRed);
            i := 1;
            GotoXY(19,18+i); Arrow;
            REPEAT
              Input := ReadKey;
              IF Input = NULL THEN BEGIN
                Input2 := ReadKey;
                IF Input2 = ARDN THEN Inc(i);
                IF Input2 = ARUP THEN Dec(i);
                IF i < 1 THEN i := 2;
                IF i > 2 THEN i := 1;
                TextColor(LightGray);
                FOR n := 1 TO 2 DO BEGIN
                  GotoXY(19,18+n); Arrow;
                END;
                TextColor(LightRed);
                IF i < 3 THEN BEGIN
                  GotoXY(19,18+i); Arrow;
                END;
              END;
            UNTIL Input IN [ENTER,ESC];
            StarmapOption.StarCatalogue := i;
            SetButton(38,23,White,LightRed+Blink,OK,50);
            SetButton(38,23,White,Black+Blink,OK,50);
          END;
        END;
        { --- Auswahl der Sternbilder-Bezeichnungen --- }
        IF StarmapOption.ConstellationNames = 1 THEN BEGIN
          Starmap_Interface5;
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
          StarmapOption.ConstellationNames := i;
          SetButton(38,27,White,LightRed+Blink,OK,50);
          SetButton(38,27,White,Black+Blink,OK,50);
        END;
        { --- Kommando-Datei setzen --- }
        Assign(f3,'starmap.cmd');
        Rewrite(f3);
        WITH StarmapOption DO BEGIN
          WriteLn(f3,Magnification,' Ausschnit-Vergr”áerung');
          WriteLn(f3,GridLines,' Gradnetz');
          WriteLn(f3,Ecliptic,' Ekliptik & Žquator');
          WriteLn(f3,ConstellationBorder,' Sternbilder-Begrenzung');
          WriteLn(f3,ConstellationLines,' Sternbilder-Linien');
          WriteLn(f3,ConstellationNames,' Sternbilder-Bezeichnung');
          WriteLn(f3,Starnames,' Sternname');
          WriteLn(f3,StarCatalogue,' Sternkatalog');
          WriteLn(f3,Milkyway);
          WriteLn(f3,Reserved1);
          WriteLn(f3,Reserved2);
          WriteLn(f3,NumberOfEntrys,' Anzahl der Eintr„ge');
          IF NumberOfEntrys <> ExoFileMax THEN BEGIN
            WriteLn(f3,ExoFile[Index]);
            FOR i := 2 TO StarmapOption.NumberOfEntrys DO BEGIN
              WriteLn(f3,Fil[i]);
            END;
          END ELSE BEGIN
            FOR i := 1 TO StarmapOption.NumberOfEntrys DO BEGIN
              WriteLn(f3,ExoFile[i]);
            END;
          END;
        END;
        Close(f3);
        Assign(f2,'starmap.dat');
        Rename(f2,'starmap.exe');
        Exec('starmap.exe','');
        Rename(f2,'starmap.dat');
        Erase(f3);
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
