 Program EllipseDrehen;
 {$N+}
 uses
  Graph,crt;
PROCEDURE Ellipse2(Xm,Ym,a,b : Integer; Alpha : Double; Color : Byte);
{Eine Ellipse ist ein in y Richtung um den Faktor a/b gestreckter Kreis}
{mit dem Radius r=a}
CONST ZweiPi = 6.28318530718;
VAR
  x,y,Phi,delta,
  c_delta,s_delta,
  c_alpha,s_Alpha,TempX : double;
BEGIN
  IF (a=0) AND (b=0) THEN Exit;
  c_alpha := cos(Alpha);
  s_alpha := sin(Alpha);
  {Abweichung auf ungefaehr ein Pixel begrenzen}
  {Dadurch wird die Schleife bei kleinen Ellipsen,Kreisen schneller}
  IF abs(a) > abs(b) THEN s_delta := 1/abs(a) ELSE s_delta := 1/abs(b);
  Phi := 0;
  c_delta := Sqrt(1-Sqr(s_delta));
  delta := Arctan(s_delta/c_delta);
  REPEAT
    {Normaler Einheitskreis}
    x := Cos(phi);
    y := Sin(phi);
    TempX := X;
    x := a*c_alpha*X+b*s_alpha*Y+Xm;
    y := b*c_alpha*Y-a*s_alpha*TempX+Ym;
    PutPixel(Round(x),Round(y),Color);
    phi := phi + delta;
   UNTIL phi > ZweiPi
END;

 var
  Gd, Gm: integer;
  i: longint;
  alpha : double;
  begin
    Gd := Detect; InitGraph(Gd, Gm, '');
    if GraphResult <> grOk then Halt(1);

{    alpha := 0;
    for i := 0 to 1440 do
    begin
       alpha := alpha+pi/180;
       setcolor(i mod 15 +1);
       ZeichneEllipse(320,240,220,110round(220*i/1440),alpha);
       setcolor(white);
       line(0,240,639,240);
       line(320,0,320,479);
       if readkey = #27 then break;
       setcolor(0);
       ZeichneEllipse(320,240,220,110round(220*i/1440),alpha);
    end;}

    FOR i := 1 TO 45 DO alpha := alpha+pi/180;
    Ellipse2(320,240,100,150,alpha,Red);

    readkey;

    closegraph;
  end.


    if (a=0)and (b=0) then
       exit;
    c_alpha := cos(Alpha);
    s_alpha := sin(Alpha);

    Farbe := getcolor;
    {Abweichung auf ungefaehr ein Pixel begrenzen}
    {Dadurch wird die Schleife bei kleinen Ellipsen,Kreisen schneller}
    if abs(a) > abs(b) then
       s_delta := 1/abs(a)
    else
       s_delta := 1/abs(b);
    Phi :=0;
    c_delta :=  sqrt(1-sqr(s_delta));
    delta := Arctan (s_delta/c_delta);
    if Farbe = 0 then
       repeat
          {Normaler Einheitskreis}
          x := cos(phi);
          y := sin(phi);
          TempX := X;
          X := a*c_alpha*X+b*s_alpha*Y+Xm;
          Y := b*c_alpha*Y-a*s_alpha*TempX+Ym;
          putpixel(round(x),round(y),Farbe);
          phi := phi + delta;
       until phi > ZweiPi
    else
       repeat
          x := cos(phi);
          y := sin(phi);
          TempX := X;
          X := a*c_alpha*X+b*s_alpha*Y+Xm;
          Y := b*c_alpha*Y-a*s_alpha*TempX+Ym;
          {Schoen bunt}
          putpixel(round(x),round(y),{Farbe}round(phi/ZweiPi*4-0.5)+1);
          phi := phi + delta;
        until phi > ZweiPi;
