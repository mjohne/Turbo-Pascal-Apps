(*-------------------------------------------------- *)
(*                 ARITHMOS.PAS                      *)
(*        Arithmetik-Unit fÅr Turbo Pascal ab 5.5    *)
(*   (c) 1990, 1992 Dirk Hillbrecht & DMV-Verlag     *)
(* ------------------------------------------------- *)
{$A+,B-,D-,E-,F-,I-,N-,O-,R-,V-}

UNIT Arithmos;

INTERFACE

CONST
  Ln10 = 2.3025850930;           { Ln 10              }
  Ln2  = 0.6931471856;           { Ln 2               }
  e    = 2.718281829;            { Eulersche Zahl     }
  pi   = 3.141592654;            { die KreiskonsTante }

  { wichtige physikalische Konstanten,
                      jeweils in normierten Einheiten }

  phy_epsilon0 =  8.854219e-12;
                           { elektrische Feldkonstante}
  phy_my0      = 12.56637061e-7;
                           { magnetische Feldkonstante}
  phy_na       =  6.023e23;    { Avogadro-Konstante   }
  phy_c        =  2.997935e8;  { Lichtgeschwindigkeit }
  phy_g        =  9.80665;     { Fallbeschleunigung   }
  phy_k        =  1.3804e-23;  { Boltzmann-Konstante  }

  { alLgemeines Funktionsergebnis im Fehlerfall }
  MaxReal = 1e+38;

  { Schalter fÅr die Winkelfunktionsdarstellung }
  rad = 0;
  deg = 1;
  gra = 2;


  FUNCTION ArithResult(x : REAL) : SHORTINT;
    { wenn |x| Ú MaxReal,
      dann Fehlermeldung zurÅckgeben }

  FUNCTION ArithErrMsg(ErrNummer  : SHORTINT) : STRING;
    { Klartextfehlermeldung aus <ArithResult> erzeugen}

  PROCEDURE Trigonomodus(modus : WORD);
    { einstellen der Einheit des Winkelma·es }

  FUNCTION Sqr(x : REAL) : REAL;
    { berechnet x˝ mit Test auf BereichsÅberschreitung}

  FUNCTION Sqrt(x : REAL) : REAL;
    { berechnet ˚x mit PlausibilitÑtstest }

  FUNCTION Faku(x : REAL) : REAL;
    { berechnet x!, wenn x Ó N und 0 Û x Û 36 gilt }

  FUNCTION Power(x, y : REAL) : REAL;
    { x^y, auch gebrochene und negative Zahlen erlaubt}

  FUNCTION PwrOfTen(epn : REAL) : REAL;
    { 10^epn }

  FUNCTION Exp(x : REAL) : REAL;
    { berechnet e^x mit PlausibilitÑtsprÅfung }

  FUNCTION Log(b, z : REAL) : REAL;
    { berechnet den Logarithmus von z zur Basis b }

  FUNCTION Lg(x : REAL) : REAL;
    { Logarithmus zur Basis 10 }

  FUNCTION Lb(x : REAL) : REAL;
    { Logarithmus zur Basis 2 }

  FUNCTION Ln(x : REAL) : REAL;
    { berechnet den Logarithmus zur Basis e mit Test }
    { auf GÅltigkeit }

  { ---  Trigonometrie  ----------------------------- }
  { alle trigonometrischen Funktionen, die einen      }
  { Winkel erwarten, interpretieren diesen Winkel in  }
  { der eingestellten Einheit (rad/deg/gra); umgekehrt}
  { geben die Umkehrfunktionen ihren Winkel in dieser }
  { Einheit zurÅck                                    }

  FUNCTION Sin2(x : REAL) : REAL;

  FUNCTION Cos2(x : REAL) : REAL;

  FUNCTION Tan2(x : REAL) : REAL;

  FUNCTION Cot2(x : REAL) : REAL;

  FUNCTION ArcSin(x : REAL) : REAL;

  FUNCTION ArcCos(x : REAL) : REAL;

  FUNCTION ArcTan2(x : REAL) : REAL;

  FUNCTION ArcCot(x : REAL) : REAL;

  FUNCTION Sinh(x : REAL) : REAL;

  FUNCTION Cosh(x : REAL) : REAL;

  FUNCTION Tanh(x : REAL) : REAL;

  FUNCTION Coth(x : REAL) : REAL;

  FUNCTION ArSinh(x : REAL) : REAL;

  FUNCTION ArCosh(x : REAL) : REAL;

  FUNCTION ArTanh(x : REAL) : REAL;

  FUNCTION ArCoth(x : REAL) : REAL;

  (*  --- Zusatzroutinen --------------------------- *)

  FUNCTION RtoStr(zahl : REAL) : STRING;
    { formt eine REAL-Zahl in einen STRING um, kleine }
    { Zahlen werden normal, gro·e in wissen-          }
    { schaftlicher Exponentialschreibweise darge-     }
    { stellt, Rechenfehler werden in gewissen Grenzen }
    { gerundet.                                       }

IMPLEMENTATION

CONST
  durchpi180         = 1.745329252e-2;   { „ / 180 }
  durch180pi         = 5.729577951e1;    { 180 / „ }
  durchpi200         = 1.570796327e-2;   { „ / 200 }
  durch200pi         = 6.366197724e1;    { 200 / „ }

  pi_haLbe           = 1.570796327;      { „ / 2   }
  minExp             = -88;
  maxExp             = 88;

  isNotRad : BOOLEAN = TRUE;
                 { TRUE : RAD / FALSE : umzurechnen }

VAR
  toRad, fromRad, hilf : REAL;
  InternError          : SHORTINT;


  PROCEDURE RadWinkel(VAR Argument : REAL);
  { Winkel in beliebiger Einheit nach RAD konvertieren}
  BEGIN
    IF isNotRad THEN Argument := Argument * toRad;
  END;

  FUNCTION NormWinkel(a : REAL) : REAL;
  { RAD-Winkel in offizielle Einheit
    zurÅckkonvertieren }
  BEGIN
    IF isNotRad THEN NormWinkel := a * fromRad
                ELSE NormWinkel := a;
  END;

  FUNCTION ArithResult(x : REAL) : SHORTINT;
  BEGIN
    IF (Abs(x) >= MaxReal) THEN
      ArithResult := InternError
    ELSE
      ArithResult := 0;
    InternError := -127;
  END;

  PROCEDURE Trigonomodus(modus : WORD);
  BEGIN
    CASE modus OF
      rad : isNotRad := FALSE;
      deg : BEGIN
              toRad    := durchpi180;
              fromRad  := durch180pi;
              isNotRad := TRUE;
            END;
      gra : BEGIN
              toRad    := durchpi200;
              fromRad  := durch200pi;
              isNotRad := TRUE;
            END;
    END;
  END;

  FUNCTION Faku(x : REAL) : REAL;
  VAR
    i       : WORD;
    Zaehler : REAL;
  BEGIN
    InternError := -1;
    IF (Abs(x-Round(x)) > 1e-6) OR (x < 0) OR
                                   (x > 36) THEN
      Zaehler := MaxReal
    ELSE BEGIN
      Zaehler := 1;
      i := Round(x);
      WHILE i > 1 DO BEGIN
        Zaehler := Zaehler * i;
        Dec(i);
      END;
    END;
    Faku := Zaehler;
  END;

  FUNCTION Sqr(x : REAL) : REAL;
  BEGIN
    InternError := -2;
    IF Abs(x) < 1e19 THEN Sqr := System.Sqr(x)
                     ELSE Sqr := MaxReal;
  END;

  FUNCTION Sqrt(x : REAL) : REAL;
  BEGIN
    InternError := -3;
    IF x < 0.0 THEN Sqrt := MaxReal
               ELSE Sqrt := System.Sqrt(x);
  END;

  FUNCTION Power(x, y : REAL) : REAL;
  BEGIN
    InternError := -4;
    IF (x <> 0.0) OR (y <> 0.0) THEN BEGIN
      IF x > 0.0 THEN
        Power := Exp(y*Ln(x))
      ELSE IF x = 0.0 THEN
        Power := 0.0
      ELSE IF Frac(y) = 0 THEN
        IF Odd(Round(y)) THEN
          Power := -Exp(y*Ln(Abs(x)))
        ELSE
          Power := Exp(y*Ln(Abs(x)))
      ELSE BEGIN
        Power := MaxReal;
        InternError := -5;
      END;
    END ELSE Power := MaxReal;
  END;

  FUNCTION PwrOfTen(epn : REAL) : REAL;
  BEGIN
    PwrOfTen := Exp(epn*Ln10);
  END;

  FUNCTION Exp(x : REAL) : REAL;
  BEGIN
    Exp := MaxReal;
    IF x > minExp THEN
      IF x < maxExp THEN
        Exp := System.Exp(x)
      ELSE
        InternError := -6
    ELSE
      InternError := -7;
  END;

  FUNCTION Log(b, z : REAL) : REAL;
  BEGIN
    Log := MaxReal;
    IF b > 0.0 THEN
      IF z > 0.0 THEN BEGIN
        hilf := System.Ln(b);
        IF Abs(hilf) > 1e-7 THEN
          Log := System.Ln(z)/hilf
        ELSE
          InternError := -8
        END
        ELSE InternError := -9
      ELSE InternError := -10;
  END;

  FUNCTION Lg(x : REAL) : REAL;
  BEGIN
    InternError := -9;
    IF x > 0.0 THEN Lg := System.Ln(x)/Ln10
               ELSE Lg := MaxReal;
  END;

  FUNCTION Lb(x : REAL) : REAL;
  BEGIN
    InternError := -9;
    IF x > 0.0 THEN Lb := System.Ln(x)/Ln2
               ELSE Lb := MaxReal;
  END;

  FUNCTION Ln(x : REAL) : REAL;
  BEGIN
    InternError := -9;
    IF x > 0.0 THEN Ln := System.Ln(x)
               ELSE Ln := MaxReal;
  END;

  FUNCTION Sin2(x : REAL) : REAL;
  BEGIN
    RadWinkel(x);
    Sin2 := System.Sin(x);
  END;

  FUNCTION Cos2(x : REAL) : REAL;
  BEGIN
    RadWinkel(x);
    Cos2 := System.Cos(x);
  END;

  FUNCTION Tan2(x : REAL) : REAL;
  BEGIN
    InternError := -11;
    RadWinkel(x);
    hilf := System.Cos(x);
    IF hilf <> 0.0 THEN Tan2 := System.Sin(x)/hilf
                   ELSE Tan2 := MaxReal;
  END;

  FUNCTION Cot2(x : REAL) : REAL;
  BEGIN
    InternError := -11;
    RadWinkel(x);
    hilf := System.Sin(x);
    IF hilf <> 0.0 THEN Cot2 := System.Cos(x)/hilf
                   ELSE Cot2 := MaxReal;
  END;

  FUNCTION ArcSin(x : REAL) : REAL;
  BEGIN
    InternError := -12;
    hilf := Abs(x);
    IF hilf > 1.0 THEN
      ArcSin := MaxReal
    ELSE IF hilf = 1.0 THEN
      ArcSin := NormWinkel(x * pi_halbe)
    ELSE
      ArcSin :=
      NormWinkel(System.ArcTan(x/Sqrt(1-Sqr(x))));
  END;

  FUNCTION ArcCos(x : REAL) : REAL;
  BEGIN
    InternError := -12;
    ArcCos := NormWinkel(pi_haLbe) - ArcSin(x);
  END;

  FUNCTION ArcTan2(x : REAL) : REAL;
  BEGIN
    ArcTan2 := Normwinkel(System.ArcTan(x));
  END;

  FUNCTION ArcCot(x : REAL) : REAL;
  BEGIN
    ArcCot := NormWinkel(pi_halbe) - ArcTan(x);
  END;

  FUNCTION Sinh(x : REAL) : REAL;
  BEGIN
    x := Exp(x);
    Sinh := 0.5 * (x - 1/x);
  END;

  FUNCTION Cosh(x : REAL) : REAL;
  BEGIN
    x := Exp(x);
    Cosh := 0.5 * (x + 1/x);
  END;

  FUNCTION Tanh(x : REAL) : REAL;
  BEGIN
    Tanh := 1 - 2/(1 + Exp(2 * x));
    InternError := -13;
  END;

  FUNCTION Coth(x : REAL) : REAL;
  BEGIN
    InternError := -13;
    hilf := Sinh(x);
    IF hilf <> 0 THEN Coth := Cosh(x) / hilf
                 ELSE Coth := MaxReal;
  END;

  FUNCTION ArSinh(x : REAL) : REAL;
  BEGIN
    ArSinh := Ln(x + System.Sqrt(Sqr(x) + 1));
    InternError := -14;
  END;

  FUNCTION ArCosh(x : REAL) : REAL;
  BEGIN
    IF x < 1 THEN
      ArCosh := MaxReal
    ELSE
      ArCosh := Ln(x + System.Sqrt(Sqr(x) - 1));
    InternError := -14;
  END;

  FUNCTION ArTanh(x : REAL) : REAL;
  BEGIN
    IF Abs(x) < 1.0 THEN
      ArTanh := 0.5 * Ln((1+x) / (1-x))
    ELSE
      ArTanh := MaxReal;
    InternError := -14;
  END;

  FUNCTION ArCoth(x : REAL) : REAL;
  BEGIN
    IF Abs(x) > 1 THEN
      ArCoth := 0.5 * Ln((x+1) / (x-1))
    ELSE
      ArCoth := MaxReal;
    InternError := -14;
  END;

  FUNCTION RtoStr(zahl : REAL) : STRING;
  VAR
    i                    : INTEGER;
    negativ, eneg        : BOOLEAN;
    rExponent            : REAL;
    Exponent             : INTEGER;
    hstr1, hstr2, ausstr : STRING [21];
    tstzahl              : REAL;
  BEGIN
    IF zahl = 0.0 THEN BEGIN
      RtoStr := '0';
      Exit;
    END;
    negativ := (zahl < 0.0);
      { Zahl mu· wegen Logarithmen immer positiv sein,}
      { negativ wird ggf. au·erhalb gespeichert.      }
    IF negativ THEN ausstr := '-'
               ELSE ausstr := '';
    zahl := Abs(zahl);
    rExponent := Ln(zahl)/Ln10;
      { Exponent fÅr spÑtere Normalisierung
        herausfiltern  }
    eneg := (rExponent < 0);
    IF eneg THEN Exponent := Trunc(rExponent-1)
            ELSE Exponent := Trunc(rExponent);
    zahl := zahl / (Exp(Exponent * Ln10));
    zahl := Int(zahl * 10e6) / 10e6;
    tstzahl := Frac(zahl) * 1e7;
    IF (Frac(tstzahl / 10) * 10) = 1 THEN
      zahl := zahl -1e-7
    ELSE BEGIN
      tstzahl := tstzahl / 10;
      tstzahl := Frac(tstzahl);
      tstzahl := Round(tstzahl * 10);
      IF tstzahl = 9 THEN zahl := zahl + 1e-7;
    END;
    WHILE zahl > 9.999999 DO BEGIN
         { Sonderfall 1*10^nn auch noch normalisieren }
         { (geschieht oben nicht korrekt)             }
      zahl := zahl / 10;
      Inc(Exponent)
    END;
    IF (Exponent < -3) OR (Exponent > 6) THEN BEGIN
            { Unterscheidung zw. Darstellungen }
            {      1.) Exponentialschreibweise }
      Str(zahl:9:7, hstr1);
                           { Zahl in STRING umwandeln }
      i := Length(hstr1);
      WHILE (hstr1[i] = '0') AND
            (hstr1[i-1] <> '.') DO BEGIN
        Delete(hstr1, i, 1);
        Dec(i);
      END;
      Exponent := Abs(Exponent);
      Str(Exponent:2, hstr2);
      IF hstr2[1] = ' ' THEN hstr2[1] := '0';
      ausstr := ausstr + hstr1 + 'e';
      IF eneg THEN ausstr := ausstr + '-';
      ausstr := ausstr + hstr2;
    END ELSE BEGIN
            {      2.) natÅrliche Schreibweise }
      zahl := zahl * (Exp(Exponent * Ln10));
      Str(zahl:20:10, hstr1);
      WHILE hstr1[1] = ' ' DO Delete(hstr1, 1, 1);
      Delete(hstr1, 9, 255);
      i := Length(hstr1);
      WHILE hstr1[i] = '0' DO BEGIN
        Delete(hstr1, i, 1);
        Dec(i);
      END;
      IF hstr1[i] = '.' THEN Delete(hstr1, i, 1);
      ausstr := ausstr + hstr1;
    END;
    RtoStr := ausstr;
  END;

  FUNCTION ArithErrMsg(ErrNummer : SHORTINT) : STRING;
  BEGIN
    CASE ErrNummer Of
    0 : ArithErrMsg := 'kein Fehler';
   -1 : ArithErrMsg := 'FakultÑt zu gro·';
   -2 : ArithErrMsg := 'Quadratfunktion zu gro·';
   -3 : ArithErrMsg := 'WurzelArgument negativ';
   -4 : ArithErrMsg := 'Potenz : 0^0 nicht definiert';
   -5 : ArithErrMsg := 'Potenz : -x^(z/n) nicht ' +
                       'definiert';
   -6 : ArithErrMsg := 'Exp : Argument zu gro·';
   -7 : ArithErrMsg := 'Exp : Argument zu klein';
   -8 : ArithErrMsg := 'Log : Basis darf nicht 1 sein';
   -9 : ArithErrMsg := 'LogArithmusArgument mu· > 0 ' +
                       'sein';
  -10 : ArithErrMsg := 'Log : Basis mu· > 0 sein';
  -11 : ArithErrMsg := 'Winkelfunktion hier nicht ' +
                       'definiert';
  -12 : ArithErrMsg := 'Winkelumkehrfunktion hier ' +
                       'nicht definiert';
  -13 : ArithErrMsg := 'hyp-Funktion hier nicht ' +
                       'definiert';
  -14 : ArithErrMsg := 'Area-Funktion hier nicht ' +
                       'definiert';
 -127 : ArithErrMsg := 'undifferenzierter ' +
                       'Gleitkommafehler';
    END;
  END;

BEGIN
  Trigonomodus(rad);
  InternError := -127;
END.
(* ------------------------------------------------- *)
(*               Ende von ARITHMOS.PAS               *)
