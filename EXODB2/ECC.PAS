PROGRAM ecc;

uses crt,DOS,Graph,Arithmos;

var

MA,EA,e,WA,a,r,EA2,CA,V

:real;

t0,T,t1,t2,i,n,w : LongInt;

da,db

:integer;
temp :string;

(*---------------------------------------------------------------------------*)
(* ECCANOM: Berechnung der exzentrischen Anomalie E=ECCANOM(MAN,ECC)         *)
(*          aus der mittleren Anomalie MAN und der Exzentrizitaet ECC.       *)
(*          (Loesung der Keplergleichung durch Newtonverfahren.)             *)
(*          (E, MAN in Grad)                                                 *)
(*---------------------------------------------------------------------------*)
FUNCTION ECCANOM(MAN,ECC:REAL):REAL;
  CONST PI=3.141592654; TWOPI=6.283185308; RAD=0.0174532925199433;
        EPS = 1E-11; MAXIT = 15;
  VAR M,E,F: REAL;
      I    : INTEGER;
  BEGIN
    M:=MAN/360.0;  M:=TWOPI*(M-TRUNC(M)); IF M<0 THEN M:=M+TWOPI;
    IF (ECC<0.8) THEN E:=M ELSE E:=PI;
    F := E - ECC*SIN(E) - M; I:=0;
    WHILE ( (ABS(F)>EPS) AND (I<MAXIT) ) DO
      BEGIN
        E := E - F / (1.0-ECC*COS(E));  F := E-ECC*SIN(E)-M; I:=I+1;
      END;
    ECCANOM:=E/RAD;
    IF (I=MAXIT) THEN  WRITELN(' Konvergenzprobleme in ECCANOM');
  END;

begin

da := detect;
Trigonomodus(1);

e := 0.5;
a := 1;
T := 110;
t1 := 20;
t0 := 0;
MA := (360/T)*(t1-t0);

clrscr;
initgraph(da,db,'');
e := 0.9;
a := 1.34;
t0 := 00;
t1 := 70;
T := 551;
{for w := 1 TO 360 DO BEGIN}
for t1 := 1 TO 1*T DO BEGIN
t2 := t0+t1;
MA := (360/T)*(t1-t0);
EA := ECCANOM(MA,e);
{r := (EA*a)/360;}
w := 94;

WA := Sqrt((1+e)/(1-e))*tan2(EA/2);
WA := arctan2(2/(Sqrt((1+e)/(1-e))*tan2(EA/2)));

r := a*(1-e*cos2(EA));

{V := 2*pi/(T);
V := V*(r/Sqrt(1-Sqr(e)));
V := V*(e*cos2(w)+cos2(w+WA));}
{V := e*cos2(w)+cos2(w+WA);
V := V/(a*(1-Sqr(e)));
V := V*Sqr(r)*WA;}
V := r*sin2(WA);



putpixel(round(t1),Round(EA),red);

putpixel(round(t1),100+Round(r*10),Yellow);
lineto(round(t1),200+Round(V*100));



{outtextXY(round(t1),round(5*t1),temp);}
{setcolor(blue);
  FOR i := 1 TO 360 DO BEGIN
    PutPixel(i,10+Round(Sin2(EA)),Red);
  END;}

end;
readkey;
closegraph;
{initgraph(da,db,'');}

end.