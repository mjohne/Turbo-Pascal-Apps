PROGRAM Modul_Distribution;

USES Crt,Dos,Graph,Basic,BGI2PRN,RT_Watch,Image,Var2;

{VAR
  Alle Variablen in Unit VAR2 deklariert}

BEGIN
  CheckParameters;
  DisYearMin := 2000;
  DisYearMax := 2000;
  FindFirst('EXO\*.EXO',AnyFile,SearchFile);
  ExoFileMax := 0;
  WHILE DosError = 0 DO BEGIN
    Assign(f,'exo/'+SearchFile.Name);
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
    Inc(ExoFileMax);
    CheckPropertiesForDistributions;
    FindNext(SearchFile);
  END;
  grDriver := Detect;
  InitGraph(grDriver,grMode,'');
  SetFillStyle(SolidFill,White);
  Bar(20,20,520,420);
  SetFillStyle(SolidFill,LightBlue);
  SetColor(Black);
  CASE Numb OF
   -1: BEGIN
         FOR i := 1 TO 25 DO BEGIN
           Bar((i*20),420-Round(10*Dis_RadialVelocityPlanet[i-1]),(i*20)+20,420);
           Rectangle((i*20),420-Round(10*Dis_RadialVelocityPlanet[i-1]),(i*20)+20,420);
         END;
         DistriReadEXO;
         Finished := False;
         WHILE NOT Finished DO BEGIN
           Finished := True;
           FOR i := 1 TO ExoFileMax-1 DO BEGIN
             IF (K_Pl[i] > K_Pl[i+1]) THEN BEGIN
               Swap := K_Pl[i];
               K_Pl[i]   := K_Pl[i+1];
               K_Pl[i+1] := Swap;
               Finished := False;
             END;
           END;
         END;
         IF ParamStr(2) = '1' THEN BEGIN
           SetColor(White);
           SetTextStyle(2,0,4);
           x := 2.1;
           y := 340;
           Line(17,420-Round(y/ExoFileMax)+2,17,420-Round((y/ExoFileMax)*ExoFileMax));
           y := -340/10;
           FOR i := 0 TO 10 DO BEGIN
             y := y+340/10;
             Line(12,420-Round((y/ExoFileMax)*ExoFileMax),17,420-Round((y/ExoFileMax)*ExoFileMax));
             Str(i*0.1:0:1,TempStr);
             OutTextXY(01,408-Round((y/ExoFileMax)*ExoFileMax),TempStr);
           END;
           SetColor(Red);
           y := 340;
           FOR i := 1 TO ExoFileMax DO BEGIN
             IF K_Pl[i] <= 240 THEN BEGIN
               Line(20+Round(x*K_Pl[i]),420-Round((y/ExoFileMax)*i-1),20+Round(x*K_Pl[i]),
                 420-Round((y/ExoFileMax)*i));
               Line(20+Round(x*K_Pl[i-1]),420-Round((y/ExoFileMax)*i-1),20+Round(x*K_Pl[i]),
                420-Round((y/ExoFileMax)*i-1));
             END;
           END;
         END;
       END;
    1: BEGIN
         FOR i := 1 TO 10 DO BEGIN
           Bar((i*40)+30,420-Round(7*Dis_Eccentricity[i-1]),(i*40)+40+30,420);
           Rectangle((i*40)+30,420-Round(7*Dis_Eccentricity[i-1]),(i*40)+40+30,420);
         END;
         DistriReadEXO;
         Finished := False;
         WHILE NOT Finished DO BEGIN
           Finished := True;
           FOR i := 1 TO ExoFileMax-1 DO BEGIN
             IF (Eccentricity[i] > Eccentricity[i+1]) THEN BEGIN
               Swap := Eccentricity[i];
               Eccentricity[i]   := Eccentricity[i+1];
               Eccentricity[i+1] := Swap;
               Finished := False;
             END;
           END;
         END;
         IF ParamStr(2) = '1' THEN BEGIN
           SetTextStyle(2,0,5);
           x := 395;
           y := 340;
           Line(60,420-Round(y/ExoFileMax)+2,60,420-Round((y/ExoFileMax)*ExoFileMax));
           y := -340/10;
           FOR i := 0 TO 10 DO BEGIN
             y := y+340/10;
             Line(55,420-Round((y/ExoFileMax)*ExoFileMax),60,420-Round((y/ExoFileMax)*ExoFileMax));
             Str(i*0.1:0:1,TempStr);
             IF i = 0 THEN OutTextXY(30,407-Round((y/ExoFileMax)*ExoFileMax),TempStr)
               ELSE OutTextXY(30,412-Round((y/ExoFileMax)*ExoFileMax),TempStr);
           END;
           y := 340;
           FOR i := 1 TO ExoFileMax DO BEGIN
             Line(70+Round(x*Eccentricity[i]),420-Round((y/ExoFileMax)*i-1),70+Round(x*Eccentricity[i]),
            420-Round((y/ExoFileMax)*i));
             Line(70+Round(x*Eccentricity[i-1]),420-Round((y/ExoFileMax)*i-1),70+Round(x*Eccentricity[i]),
             420-Round((y/ExoFileMax)*i-1));
           END;
         END;
       END;
    2: BEGIN
         FOR i := 1 TO 15 DO BEGIN
           Bar((i*30),420-Round(6*Dis_PlanetMass[i-1]),(i*30)+30,420);
           Rectangle((i*30),420-Round(6*Dis_PlanetMass[i-1]),(i*30)+30,420);
         END;
         DistriReadEXO;
         Finished := False;
         WHILE NOT Finished DO BEGIN
           Finished := True;
           FOR i := 1 TO ExoFileMax-1 DO BEGIN
             IF (PlanetMass[i] > PlanetMass[i+1]) THEN BEGIN
               Swap := PlanetMass[i];
               PlanetMass[i]   := PlanetMass[i+1];
               PlanetMass[i+1] := Swap;
               Finished := False;
             END;
           END;
         END;
         IF ParamStr(2) = '1' THEN BEGIN
           SetTextStyle(2,0,4);
           x := 29.4;
           y := 350;
           Line(26,420-Round(y/ExoFileMax)+2,26,420-Round((y/ExoFileMax)*ExoFileMax));
           y := -350/10;
           FOR i := 0 TO 10 DO BEGIN
             y := y+350/10;
             SetColor(Red);
             Line(20,420-Round((y/ExoFileMax)*ExoFileMax),25,420-Round((y/ExoFileMax)*ExoFileMax));
             Str(i*0.1:0:1,TempStr);
             SetColor(White);
             OutTextXY(02,412-Round((y/ExoFileMax)*ExoFileMax),TempStr);
           END;
           SetColor(Red);
           y := 350;
           FOR i := 1 TO ExoFileMax DO BEGIN
             IF PlanetMass[i] <= 15 THEN BEGIN
               Line(30+Round(x*PlanetMass[i]),420-Round((y/ExoFileMax)*i-1),30+Round(x*PlanetMass[i]),
               420-Round((y/ExoFileMax)*i));
               Line(30+Round(x*PlanetMass[i-1]),420-Round((y/ExoFileMax)*i-1),30+Round(x*PlanetMass[i]),
               420-Round((y/ExoFileMax)*i-1));
             END;
           END;
         END;
       END;
   -2: BEGIN
         FOR i := 1 TO 6 DO BEGIN
           Bar((i*40)+30,420-Round(3*Dis_PlanetMass[i]),(i*40)+40+30,420);
           Rectangle((i*40)+30,420-Round(3*Dis_PlanetMass[i]),(i*40)+40+30,420);
         END;
       END;
    3: BEGIN
         FOR i := 1 TO 10 DO BEGIN
           Bar((i*40)+30,420-Round(4*Dis_SemiMajorAxis[i-1]),(i*40)+40+30,420);
           Rectangle((i*40)+30,420-Round(4*Dis_SemiMajorAxis[i-1]),(i*40)+40+30,420);
         END;
         DistriReadEXO;
         Finished := False;
         WHILE NOT Finished DO BEGIN
           Finished := True;
           FOR i := 1 TO ExoFileMax-1 DO BEGIN
             IF (SemiMajorAxis[i] > SemiMajorAxis[i+1]) THEN BEGIN
               Swap := SemiMajorAxis[i];
               SemiMajorAxis[i]   := SemiMajorAxis[i+1];
               SemiMajorAxis[i+1] := Swap;
               Finished := False;
             END;
           END;
         END;
         IF ParamStr(2) = '1' THEN BEGIN
           SetTextStyle(2,0,5);
           x := 40;
           y := 350;
           Line(60,420-Round(y/ExoFileMax)+2,60,420-Round((y/ExoFileMax)*ExoFileMax));
           y := -350/10;
           FOR i := 0 TO 10 DO BEGIN
             y := y+350/10;
             Line(55,420-Round((y/ExoFileMax)*ExoFileMax),60,420-Round((y/ExoFileMax)*ExoFileMax));
             Str(i*0.1:0:1,TempStr);
             IF i = 0 THEN OutTextXY(30,407-Round((y/ExoFileMax)*ExoFileMax),TempStr)
               ELSE OutTextXY(30,412-Round((y/ExoFileMax)*ExoFileMax),TempStr);
           END;
           y := 350;
           FOR i := 1 TO ExoFileMax DO BEGIN
             IF SemiMajorAxis[i] <= 10 THEN BEGIN
               Line(70+Round(x*SemiMajorAxis[i]),420-Round((y/ExoFileMax)*i-1),70+Round(x*SemiMajorAxis[i]),
               420-Round((y/ExoFileMax)*i));
               Line(70+Round(x*SemiMajorAxis[i-1]),420-Round((y/ExoFileMax)*i-1),70+Round(x*SemiMajorAxis[i]),
               420-Round((y/ExoFileMax)*i-1));
             END;
           END;
         END;
       END;
    0,4: BEGIN
         SetFillStyle(SolidFill,LightRed);
         n := Round(450/(DisYearMax-DisYearMin)+1);
         FOR i := 1 TO (DisYearMax-DisYearMin)+1 DO BEGIN
           IF Numb = 0 THEN BEGIN
             DisYearSum := DisYearSum+DiscoveryDate2[DisYearMin+i-1];
             SetColor(DarkGray);
             IF i <> 1 THEN
               Line(20+((i-1)*(n))-30,410-2*Round(1*DisYearSum-DiscoveryDate2[DisYearMin+i-1]),
                 20+(i*(n))-30,410-2*Round(1*DisYearSum));
           END;
           SetColor(Blue);
           IF Numb = 0 THEN BEGIN
             IF i <> 1 THEN
               Line(20+((i-1)*(n))-30,410-2*Round(DiscoveryDate2[DisYearMin-1+(i-1)]),
                 20+(i*(n))-30,410-2*Round(DiscoveryDate2[DisYearMin-1+i]));
             SetColor(Red);
             Bar(20+(i*(n))-30-1,410-2*Round(DiscoveryDate2[DisYearMin-1+i]+1),
               20+(i*(n))-30+2,410-2*Round(DiscoveryDate2[DisYearMin-1+i])+2);
           END ELSE BEGIN
             IF i <> 1 THEN
               Line(20+((i-1)*(n))-30,410-Round(10*DiscoveryDate2[DisYearMin-1+(i-1)]),
                 20+(i*(n))-30,410-Round(10*DiscoveryDate2[DisYearMin-1+i]));
             SetColor(Red);
             Bar(20+(i*(n))-30-1,410-Round(10*DiscoveryDate2[DisYearMin-1+i]+1),
               20+(i*(n))-30+2,410-Round(10*DiscoveryDate2[DisYearMin-1+i])+2);
           END;
           Str(i-1+DisYearMin,Strin[1]);
           Str(Discoverydate2[i-1+DisYearMin],Strin[2]);
           IF Numb = 0 THEN BEGIN
             Str(DisYearSum,Strin[3]);
             SetTextStyle(2,0,5);
             SetColor(LightGreen);
             OutTextXY(530,37+(i*10)+(3*i),Strin[1]+': '+Strin[2]+' ('+Strin[3]+')');
           END ELSE BEGIN
             Str(DisYearSum,Strin[3]);
             SetTextStyle(2,0,5);
             SetColor(LightGreen);
             OutTextXY(530,37+(i*10)+(3*i),Strin[1]+': '+Strin[2]);
           END;
           SetTextStyle(2,1,4);
           SetColor(White);
           OutTextXY(20+((i)*(n))-30,430,Strin[1]);
           SetTextStyle(2,0,5);
           OutTextXY(530,430,'Jahre');
         END;
       END;
    5: BEGIN
         FOR i := 1 TO 9 DO BEGIN
           Bar((i*40)+30,420-Round(3*Dis_SpectralType[i]),(i*40)+40+30,420);
           Rectangle((i*40)+30,420-Round(3*Dis_SpectralType[i]),(i*40)+40+30,420);
         END;
       END;
    6: BEGIN
         FOR i := 0 TO 10 DO BEGIN
           Bar((i*40)+30,420-Round(6*Dis_PlanetMass[i]),(i*40)+40+30,420);
           Rectangle((i*40)+30,420-Round(6*Dis_PlanetMass[i]),(i*40)+40+30,420);
         END;
         DistriReadEXO;
         Finished := False;
         WHILE NOT Finished DO BEGIN
           Finished := True;
           FOR i := 1 TO ExoFileMax-1 DO BEGIN
             IF (Distance[i] > Distance[i+1]) THEN BEGIN
               Swap := Distance[i];
               Distance[i]   := Distance[i+1];
               Distance[i+1] := Swap;
               Finished := False;
             END;
           END;
         END;
         IF ParamStr(2) = '1' THEN BEGIN
           SetTextStyle(2,0,4);
           x := 4;
           y := 350;
           Line(26,420-Round(y/ExoFileMax)+2,26,420-Round((y/ExoFileMax)*ExoFileMax));
           y := -350/10;
           FOR i := 0 TO 10 DO BEGIN
             y := y+350/10;
             SetColor(Red);
             Line(20,420-Round((y/ExoFileMax)*ExoFileMax),25,420-Round((y/ExoFileMax)*ExoFileMax));
             Str(i*0.1:0:1,TempStr);
             SetColor(White);
             OutTextXY(02,412-Round((y/ExoFileMax)*ExoFileMax),TempStr);
           END;
           SetColor(Red);
           y := 350;
           FOR i := 1 TO ExoFileMax DO BEGIN
             IF Distance[i] <= 120 THEN BEGIN
               Line(30+Round(x*Distance[i]),420-Round((y/ExoFileMax)*i-1),30+Round(x*Distance[i]),
               420-Round((y/ExoFileMax)*i));
               Line(30+Round(x*Distance[i-1]),420-Round((y/ExoFileMax)*i-1),30+Round(x*Distance[i]),
               420-Round((y/ExoFileMax)*i-1));
             END;
           END;
         END;
       END;
    -7,7: BEGIN
         FOR i := 0 TO 10 DO BEGIN
           IF Numb = 7 THEN BEGIN
             Bar((i*40)+30,420-Round(6*Dis_PlanetMass[i]),(i*40)+40+30,420);
             Rectangle((i*40)+30,420-Round(6*Dis_PlanetMass[i]),(i*40)+40+30,420);
           END ELSE IF Numb = -7 THEN BEGIN
             Bar((i*40)+30,420-Round(4*Dis_PlanetMass[i]),(i*40)+40+30,420);
             Rectangle((i*40)+30,420-Round(4*Dis_PlanetMass[i]),(i*40)+40+30,420);
           END;
         END;
         DistriReadEXO;
         FOR i := 1 TO ExoFileMax DO BEGIN
           IF Numb = -7 THEN Magnitude[i] := Magnitude[i]+5-5*(Ln(Distance[i])/Ln(10));
         END;
         Finished := False;
         WHILE NOT Finished DO BEGIN
           Finished := True;
           FOR i := 1 TO ExoFileMax-1 DO BEGIN
             IF (Magnitude[i] > Magnitude[i+1]) THEN BEGIN
               Swap := Magnitude[i];
               Magnitude[i]   := Magnitude[i+1];
               Magnitude[i+1] := Swap;
               Finished := False;
             END;
           END;
         END;
         IF ParamStr(2) = '1' THEN BEGIN
           SetTextStyle(2,0,4);
           x := 40;
           y := 350;
           Line(26,420-Round(y/ExoFileMax)+2,26,420-Round((y/ExoFileMax)*ExoFileMax));
           y := -350/10;
           FOR i := 0 TO 10 DO BEGIN
             y := y+350/10;
             SetColor(Red);
             Line(20,420-Round((y/ExoFileMax)*ExoFileMax),25,420-Round((y/ExoFileMax)*ExoFileMax));
             Str(i*0.1:0:1,TempStr);
             SetColor(White);
             OutTextXY(02,412-Round((y/ExoFileMax)*ExoFileMax),TempStr);
           END;
           SetColor(Red);
           y := 350;
           FOR i := 1 TO ExoFileMax DO BEGIN
             IF (Magnitude[i] <= 11) AND (Magnitude[i] >= 0) THEN BEGIN
               IF Numb = -7 THEN BEGIN
                 Line(40+Round(x*Magnitude[i]),420-Round((y/ExoFileMax)*i-1),40+Round(x*Magnitude[i]),
                 420-Round((y/ExoFileMax)*i));
                 Line(40+Round(x*Magnitude[i-1]),420-Round((y/ExoFileMax)*i-1),40+Round(x*Magnitude[i]),
                 420-Round((y/ExoFileMax)*i-1));
               END ELSE BEGIN
                 Line(30+Round(x*Magnitude[i]),420-Round((y/ExoFileMax)*i-1),30+Round(x*Magnitude[i]),
                 420-Round((y/ExoFileMax)*i));
                 Line(30+Round(x*Magnitude[i-1]),420-Round((y/ExoFileMax)*i-1),30+Round(x*Magnitude[i]),
                 420-Round((y/ExoFileMax)*i-1));
               END;
             END;
           END;
         END;
       END;
    8: BEGIN
         FOR i := 1 TO 11 DO BEGIN
           Bar((i*40)+30,420-Round(6*Dis_PlanetMass[i]),(i*40)+40+30,420);
           Rectangle((i*40)+30,420-Round(6*Dis_PlanetMass[i]),(i*40)+40+30,420);
         END;
       END;
    9: BEGIN
         FOR i := 1 TO 15 DO BEGIN
           Bar((i*30),420-Round(6*Dis_PlanetMass[i-1]),(i*30)+30,420);
           Rectangle((i*30),420-Round(6*Dis_PlanetMass[i-1]),(i*30)+30,420);
         END;
         DistriReadEXO;
         Finished := False;
         WHILE NOT Finished DO BEGIN
           Finished := True;
           FOR i := 1 TO ExoFileMax-1 DO BEGIN
             IF (StarMass[i] > StarMass[i+1]) THEN BEGIN
               Swap := StarMass[i];
               StarMass[i]   := StarMass[i+1];
               StarMass[i+1] := Swap;
               Finished := False;
             END;
           END;
         END;
         IF ParamStr(2) = '1' THEN BEGIN
           SetTextStyle(2,0,4);
           x := 300;
           y := 350;
           Line(26,420-Round(y/ExoFileMax)+2,26,420-Round((y/ExoFileMax)*ExoFileMax));
           y := -350/10;
           FOR i := 0 TO 10 DO BEGIN
             y := y+350/10;
             SetColor(Red);
             Line(20,420-Round((y/ExoFileMax)*ExoFileMax),25,420-Round((y/ExoFileMax)*ExoFileMax));
             Str(i*0.1:0:1,TempStr);
             SetColor(White);
             OutTextXY(02,412-Round((y/ExoFileMax)*ExoFileMax),TempStr);
           END;
           SetColor(Red);
           y := 350;
           FOR i := 1 TO ExoFileMax DO BEGIN
             IF StarMass[i] <= 1.6 THEN BEGIN
               Line(30+Round(x*StarMass[i]),420-Round((y/ExoFileMax)*i-1),30+Round(x*StarMass[i]),
               420-Round((y/ExoFileMax)*i));
               Line(30+Round(x*StarMass[i-1]),420-Round((y/ExoFileMax)*i-1),30+Round(x*StarMass[i]),
               420-Round((y/ExoFileMax)*i-1));
             END;
           END;
         END;
       END;
  END;
  SetTitle;
  SetAxisDescription;
  SetColor(Cyan);
  SetTextStyle(2,0,4);
  OutTextXY(20,2,'(C) 1995-2006 EXODB2 1.7 * Michael Johne * http://www.exodb.de.vu');
  Input := ReadKey;
  IF Input IN ['S','s'] THEN BEGIN
    SavePicture;
  END ELSE IF Input IN ['P','p'] THEN GraftoPrint;
  CloseGraph;
END.
