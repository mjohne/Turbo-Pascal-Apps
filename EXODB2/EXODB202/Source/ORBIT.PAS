PROGRAM Plugin_Orbit;

USES Crt,Dos,Graph,Printer,RT_Watch;

VAR
  Control,i,
  grDriver,grMode : Integer;
  a,p,e,b,c,
  Numb,Zoom       : Real;
  Fil             : ARRAY[1..20] OF STRING;
  f               : Text;
  SemiMajorAxis2,
  Eccentricity2,
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

procedure Ellipse (mxe, mye, xa, xb, color: integer);
var e, mx1, mx2, my1, my2: integer;
aq, bq, dx, dy, r, rx, ry: longint;
l1, l2, l3, l4:integer;
begin
  l1:= mxe + xa;
  l2:= mxe - xa;
  l3:= mye;
  Putpixel (l1, l3, color);
  Putpixel (l2, l3, color);
  mx1:= mxe - xa; my1:= mye;
  mx2:= mxe + xa; my2:= mye;
  aq:= longint (xa) * xa;
  bq:= longint (xb) * xb;
  dx:= aq shl 1;
  dy:= bq shl 1;
  r:= xa * bq;
  rx:= r shl 1;
  ry:= 0;
  e:= xa;
  while e > 0
  do begin 
  if r > 0
  then begin
inc (my1); 
dec (my2);
inc (ry, dx);
dec (r, ry);
end;

if r <= 0
then begin
dec (e);
inc(mx1);
dec (mx2);
      dec (rx, dy);
      inc(r, rx);
    end;
    l1:=mx1;
    l2:=mx2;
    l3:=my1;
    l4:=my2;
    Putpixel (l1, l3, color);
    Putpixel (l1, l4, color);
    Putpixel (l2, l3, color);
    Putpixel (l2, l4, color);
  end;
end;

BEGIN
  IF ParamStr(1) = '' THEN BEGIN
    WriteLn(^j^j'Der Parameter als Anzahl der darzustellende DatensÑtze fehlt!');
    WriteLn('    -  ORBIT.EXE [anzahl] [dateiname] [zoom]');
    WriteLn(^j'Achten Sie darauf, dass die DatensÑtze im Verzeichnis "EXO"');
    WriteLn('des Hauptverzeichis liegen.');
    ReadKey;
    Halt;
  END ELSE BEGIN
    Val(ParamStr(1),Numb,Control);
    IF (Control <> 0) OR (Numb=0) THEN BEGIN
      WriteLn(^j^j'Der eingegebene Zahlenwert ',ParamStr(1),' ist ungÅltig.');
      WriteLn('Es sind alle Zahlen von 1 bis x erlebt; je nachdem wieviel');
      WriteLn('DatensÑtze vorliegen Im Verzeichnis "EXO" vorliegen.');
      ReadKey;
      Halt;
    END;
  END;
  IF ParamStr(2) = '' THEN BEGIN
    WriteLn(^j^j'Der Parameter fehlt! Aufruf des Datenansatz ohne [.EXO]:');
    WriteLn('    -  ORBIT.EXE [dateiname] [zoom]');
    WriteLn(^j'Achten Sie darauf, dass die DatensÑtze im Verzeichnis "EXO"');
    WriteLn('des Hauptverzeichis liegen.');
    ReadKey;
  END ELSE BEGIN
    FOR i := 1 TO Round(Numb) DO BEGIN
      IF NOT(FileExists('exo/'+ParamStr(1+i)+'.EXO')) THEN BEGIN
        WriteLn(^j^j'Die Datei "','exo/'+ParamStr(1+i)+'.EXO','" wurde nicht gefunden!');
        WriteLn(^j'Achten Sie darauf, dass die DatensÑtze im Verzeichnis "EXO"');
        WriteLn('des Hauptverzeichis liegen.');
        ReadKey;
        Halt;
      END ELSE BEGIN
        Assign(f,'exo/'+ParamStr(1+i)+'.EXO');
        Reset(f);
        ReadLn(f,Centralstar[i]);
        ReadLn(f,SpectralType[i]);
        ReadLn(f,Magnitude[i]);
        ReadLn(f,StarMass[i]);
        ReadLn(f,Metalicity[i]);
        ReadLn(f,Distance[i]);
        ReadLn(f,Rectaszension[i]);
        ReadLn(f,Deklination[i]);
        ReadLn(f,Constellation[i]);
        ReadLn(f,PlanetName[i]);
        ReadLn(f,PlanetMass[i]);
        ReadLn(f,SemiMajorAxis[i]);
        ReadLn(f,Period[i]);
        ReadLn(f,Eccentricity[i]);
        ReadLn(f,Method[i]);
        ReadLn(f,DiscoveryDate[i]);
        ReadLn(f,Discoverer[i]);
        ReadLn(f,Remarks[i]);
        Close(f);
      END;
    END;
    IF ParamStr(2+Round(Numb)) = '' THEN Zoom := 100 ELSE BEGIN
      Val(ParamStr(2+Round(Numb)),Zoom,Control);
      IF Control <> 0 THEN BEGIN
        Zoom := 100;
        WriteLn(^j^j'Der eingegebene Zoom-Wert ',ParamStr(2+Round(Numb)),' ist ungÅltig.');
        WriteLn('Folgende Beispielwerte sind erlaubt: 100.0; 70.32; 25.32432...; etc.');
        WriteLn(^j'Als Stanardwert fÅr Zoom wird nun 100 genommen.');
        ReadKey;
       END;
    END;
    Zoom := Zoom/100;
    grDriver := Detect;
    InitGraph(grDriver,grMode,'');
    SetFillStyle(SolidFill,White);
    Bar(0,0,640,480);
    PutPixel(320-1,240,Black);
    PutPixel(320,240-1,Black);
    PutPixel(320+1,240,Black);
    PutPixel(320,240+1,Black);
    PutPixel(320,240,Black);
    SetColor(Black);
    IF Zoom < 25/100 THEN SetTextStyle(2,HorizDir,2) ELSE SetTextStyle(2,HorizDir,4);
    {Merkur}
    a := 0.387*(149.6);
    e := 0.205;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(11.868);
    Ellipse(320+Round(c*Zoom),240,Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom),240+Round(b*Zoom),'Merkur');
    {Venus}
    a := 0.723*(149.6);
    e := 0.0067;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(0.724);
    Ellipse(320+Round(c*Zoom),240,Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom),240+Round(b*Zoom),'Venus');
    {Erde}
    a := 1.00*(149.6);
    e := 0.0167;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(2.498);
    Ellipse(320+Round(c*Zoom),240,Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom),240+Round(b*Zoom),'Erde');
    {Mars}
    a := 1.523*(149.6);
    e := 0.093;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(21.189);
    Ellipse(320+Round(c*Zoom),240,Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom),240+Round(b*Zoom),'Mars');
    {Jupiter}
    a := 5.203*(149.6);
    e := 0.048;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(37.362);
    Ellipse(320+Round(c*Zoom),240,Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom),240+Round(b*Zoom),'Jupiter');
    {Saturn}
    a := 9.55*(149.6);
    e := 0.05;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(71.434);
    Ellipse(320+Round(c*Zoom),240,Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom),240+Round(b*Zoom),'Saturn');
    {Uranus}
    a := 19.2*(149.6);
    e := 0.04;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(114.893);
    Ellipse(320+Round(c*Zoom),240,Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom),240+Round(b*Zoom),'Uranus');
    {Neptun}
    a := 30.1*(149.6);
    e := 0.01;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(45.029);
    OutTextXY(310+Round(c*Zoom),240+Round(b*Zoom),'Neptun');
    Ellipse(320+Round(c*Zoom),240,Round(a*Zoom),Round(b*Zoom),LightGray);
    {Pluto}
    a := 39.5*(149.6);
    e := 0.25;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(9.875);{!!!}
    Ellipse(320+Round(c*Zoom),240,Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom),240+Round(b*Zoom),'Pluto');
    {Exoplanet}
    FOR i := 1 TO Round(Numb) DO BEGIN
      a := SemiMajorAxis[i]*(149.6);
      e := Eccentricity[i];
      b := a*Sqrt(1-Sqr(e));
      c := (a-b)*(2.498);
      Ellipse(320+Round(c*Zoom),240,Round(a*Zoom),Round(b*Zoom),LightBlue);
      Ellipse(320+Round(c*Zoom),240,Round(a*Zoom-1),Round(b*Zoom-1),LightBlue);
      SetTextStyle(2,0,5);
      SetColor(Green);
      OutTextXY(5,410,'Orbit by');
      SetColor(Blue);
      OutTextXY(72,410,Centralstar[i]);
      SetColor(LightRed);
      Str(SemiMajorAxis[i]:0:3,SemiMajorAxis2[i]);
      Str(Eccentricity[i]:0:3,Eccentricity2[i]);
      OutTextXY(5,420+(10*i),SemiMajorAxis2[i]+' AE - ecc '+Eccentricity2[i]);
    END;
    SetColor(Cyan);
    SetTextStyle(2,0,4);
    OutTextXY(10,10,'(C) 1995-2003 EXO-DB2 Michael Johne * http://www.die-exoplaneten.de');
    ReadKey;
    CloseGraph;
  END;
END.