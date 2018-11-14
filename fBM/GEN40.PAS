{                   ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
                    º    GENESIS13 Version 4.00      º
                    ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼


ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»Ü
º                                                                        ºÛ
º                                                   Û Û                  ºÛ
º                                                  Û°Û°Û                 ºÛ
º                                                ÜÛÛÛÛÛÛÛÛÛ              ºÛ
º                                              ÛÛÛÛÛÛÛÛÛÛÛÛÛ             ºÛ
º                                             ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ            ºÛ
º                                            ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ          ºÛ
º                                           ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ        ºÛ
º                                          ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ      ºÛ
º                                         ÛÛÛÛÛÛÛÛ±±±±±ÛÛÛÛÛÛÛÛÛÛÛÛÛÛ    ºÛ
º ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÜÜÜÜ                ÜÜÜÜÛÛÛÛÛÛÛÛÛÛÛÛ°°±±      ÛÛÛÛÛÛÛ²  ºÛ
º    ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ°°°°°         ÛÛÛ²²²² ºÛ
º         ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ°°°°°°°            ²²²²² ºÛ
º              ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ°°°°°°°               ²²  ºÛ
º                 ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ°°°°°°                     ºÛ
º                   ²²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ°°°°                       ºÛ
º                   ²²²²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ°°°°                        ºÛ
º KEIN ARSCHLOCH!-->²²²²ÛÛÛÛÛÛÛÛÛÛÛ²²²²ÛÛÛÛÛÛ°°°°                        ºÛ
º                    ²²²²ÛÛÛÛÛÛÛÛÛ²²²²²ÛÛÛÛÛ°°°                          ºÛ
º                    ²²²²ÛÛÛÛÛÛÛÛÛ²²²²ÛÛÛÛÛ°°°°                          ºÛ
º                     ²²²ÛÛÛÛÛÛÛÛ²²²²ÛÛÛÛÛ°°°°                           ºÛ
º                       ÛÛÛÛÛÛÛÛÛ²²²²ÛÛÛÛ°°°°                            ºÛ
º                       ÛÛÛÛÛÛÛÛÛ²²²²ÛÛÛ°°°                              ºÛ
º                      ²²ÛÛÛÛÛÛÛ²²²²²ÛÛÛ°°                               ºÛ
º                      ²²²²ÛÛÛÛÛÛ²²²²²²Û°°                               ºÛ
º                    ²²²²²ÛÛÛÛÛ²²²²²                                     ºÛ
º                    ²²²²²²     ²²²²²                                    ºÛ
º                    ²²²²²²²    ²²²²²                                    ºÛ
º                    ²²²²²²²    ²²²²²²                                   ºÛ
º                    ²²²²²²²     ²²²²                                    ºÛ
º                     ²²²²²                                              ºÛ
º                      ²²²                                               ºÛ
º                                                                        ºÛ
ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼Û
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


 HALLO!

 Nun ist sie da: Die vierte Version der GENESIS 13 Grafikunit.

 Eine Liste der Neuerungen:
  - Einbindung der glcklicherweise nie ver”ffentlichen Unit Paltool 1.05
  - Anzeigen von BMP und PCX Dateien m”glich

 Hey! Das ist mehr, als es aussieht!



 Nun eine detailliertere Liste:

 [Paltool 1.05]
  SavePalV   ÄÄ Speichert eine Palette in einer Variable
  LoadPalV   ÄÄ L„dt eine Palette aus einer Variable
  SavePalF   ÄÄ Speichert Palette in Datei
  LoadPalF   ÄÄ L„dt eine Palette aus einer Datei

 [BMP und PCX]
  ShowPCXP   ÄÄ Schreibt eine PCX in den Puffer
  BGShowPCXP ÄÄ Schreibt eine PCX in den Puffer mit Begrenzung
  BGShowBMPP ÄÄ Schreibt eine BMP in den Puffer mit Begrenzung
  ShowBMPP   ÄÄ Schreibt eine BMP in den Puffer
  ShowPCX    ÄÄ Zeigt ein PCX Bild an
  BGShowPCX  ÄÄ Zeigt ein PCX Bild an mit Begrenzung
  ShowBMP    ÄÄ Zeigt eine BMP an
  BGShowBMP  ÄÄ Zeigt eine BMP mit Begrenzung an






{---------------------------------------------------------------------------}

Unit Gen40;
interface

Type
 Palette = Record
  Rot   : Array[0..255] of Byte;
  Gruen : Array[0..255] of Byte;
  Blau  : Array[0..255] of Byte;
 End;

Const
 GMinX = 0;
 GMinY = 0;
 GMaxX = 319;
 GMaxY = 199;
 {---------}
 Ver  = 4.00;
 An   = TRUE;
 Aus  = FALSE;
 On   = TRUE;
 Off  = FALSE;
 {-----------}

Var
 Puffs: record
  P1: Boolean;
  P2: Boolean;
  P3: Boolean;
 End;


{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
{ÄÄÄÄÄÄÄÄÄ========== Grafikbefehle fr Screenbuffering  ==========ÄÄÄÄÄÄÄÄÄ}
{ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}

PROCEDURE BMPInfo(DateiName: String; Var Width, Height: Integer);
PROCEDURE ShowPCXP(DateiName: String; PX, PY:Integer; Pal:Boolean; Pu: Word);
PROCEDURE BGShowPCXP(DateiName: String; PX, PY, MX, MY:Integer; Pal:Boolean; Pu: Word);
PROCEDURE BGShowBMPP(DateiName: String; X, Y, MX, MY: Word; Pal: Boolean; P: Word);
PROCEDURE ShowBMPP(DateiName: String; X, Y: Word; Pal: Boolean; P: Word);

FUNCTION  GetPixelP(X,Y: Word; P: Byte): Word;
PROCEDURE PutTextP(X, Y: Integer; t: String;f,P: Byte);
PROCEDURE ThreeangleP(X1, Y1, X2, Y2, X3, Y3, Farbe: Word; P: Byte);
PROCEDURE RectangleP(X1, Y1, X2, Y2, Farbe: Word; P: Byte);
PROCEDURE CircleP(X, Y, Radius, Farbe: Word; P: Byte);
PROCEDURE EllipseP(px,py:LongInt; XRadius,YRadius:LongInt; Farbe, P:Byte);
PROCEDURE LineP(x1, y1, x2, y2 : Integer; Farbe, P : Byte);
PROCEDURE PutpixelP(X,Y: Integer; C,P: Byte);
PROCEDURE Fill4P(x1,y1,x2,y2,x3,y3,x4,y4: Integer; c,P: Byte);
PROCEDURE HPolyP(x1,y1,x2,y2,x3,y3,x4,y4: Integer; c,P: Byte);
PROCEDURE DrawPolyP(x1,y1, x2,y2, x3,y3: Integer; c,P: Byte);
PROCEDURE WaitRetrace;
PROCEDURE MovePuffer(P: Byte);
PROCEDURE CLPUFFER(farbe,P: Byte);


{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
{ÄÄÄÄÄÄÄÄÄ========== Grafikbefehle ohne Screenbuffering ==========ÄÄÄÄÄÄÄÄÄ}
{ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}

PROCEDURE ShowPCX(DateiName: String; PX, PY:Integer; Pal:Boolean);
PROCEDURE BGShowPCX(DateiName: String; PX, PY, MX, MY:Integer; Pal:Boolean);
PROCEDURE ShowBMP(DateiName: String; X, Y: Word; Pal: Boolean);
PROCEDURE BGShowBMP(DateiName: String; X, Y, MX, MY: Word; Pal: Boolean);

PROCEDURE HPoly(x1,y1,x2,y2,x3,y3,x4,y4: Integer; c: Byte);
PROCEDURE PutText(X, Y: Integer; t: String;f: Byte);
PROCEDURE FillRectangle(x1, y1, x2, y2, Farben: word);
PROCEDURE Fill4(x1,y1,x2,y2,x3,y3,x4,y4: Integer; c: Byte);
PROCEDURE DrawPoly(x1,y1, x2,y2, x3,y3: Integer; c: Byte);
PROCEDURE Threeangle(X1, Y1, X2, Y2, X3, Y3, Farbe: Word);
PROCEDURE Rectangle(X1, Y1, X2, Y2, Farbe: Word);
PROCEDURE Circle(X, Y, Radius, Farbe: Word);
PROCEDURE Ellipse(px,py:LongInt; XRadius,YRadius:LongInt; Farbe:Byte);
PROCEDURE Line(x1, y1, x2, y2 : Integer; Farbe : Byte);
FUNCTION  GetPixel(x,y: Integer):Byte;
PROCEDURE PutPixel(x,y: Integer; c: Byte);


{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
{ÄÄÄÄÄÄÄÄÄ==========         Palettenbefehle            ==========ÄÄÄÄÄÄÄÄÄ}
{ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}

PROCEDURE GrayScale(Startfarbe, Anzahl: Word);
PROCEDURE GetRegBlock(StartFarbe, Anzahl: Word; VAR Farbtabelle);
PROCEDURE SetRegBlock(StartFarbe, Anzahl: Word; VAR Farbtabelle);
PROCEDURE GetReg(FarbeNr: Byte; VAR rot, gruen, blau: Byte);
PROCEDURE SetReg(FarbeNr, rot, gruen, blau: Byte);
PROCEDURE SavePalV(Var SPal : Palette);
PROCEDURE LoadPalV(LPal : Palette);
PROCEDURE SavePalF(PalFile : String);
PROCEDURE LoadPalF(Palfile : String);



{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
{ÄÄÄÄÄÄÄÄÄ==========        Allgemeine Befehle          ==========ÄÄÄÄÄÄÄÄÄ}
{ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ}

PROCEDURE CLS(farbe: Byte);
FUNCTION  GRVersion: String;
PROCEDURE VGA(Anaus: boolean);
FUNCTION FileExists(FileName: string): Boolean;

IMPLEMENTATION

{####################################################################}
{####################################################################}
{####################################################################}

USES DOS;
TYPE
  t_koor = RECORD              {Die Koordinaten eines Punktes}
    x,y: LongInt;
  END;
  TBuchstabe=ARRAY[0..7] OF Byte;

VAR
  Puffer3,
  Puffer1,Puffer2: Pointer;
  Zeichensatz: ARRAY[0..255] OF TBuchstabe;
  I: Integer;



{********************************************************************}
{*         PROCEDURE VGA                                            *}
{********************************************************************}

PROCEDURE VGA(Anaus: boolean);
PROCEDURE SetMode(ModusNr: Byte); Assembler;
ASM
  mov ah, 0
  mov al, ModusNr
  int 10h
END;

begin
 IF Anaus THEN
 begin
 Setmode(19);
 If MemAvail > 64000 then
 Begin
  GetMem(Puffer1,64000);
  Puffs.P1:= True;
 End;
 If MemAvail > 64000 then
 Begin
  GetMem(Puffer2,64000);
  Puffs.P2:= True;
 End;
 If MemAvail > 64000 then
 Begin
  GetMem(Puffer3,64000);
  Puffs.P3:= True;
 End;
 End
 ELSE
 begin
 Setmode(3);
 If Puffs.P1 then FreeMem(Puffer1,64000);
 If Puffs.P1 then FreeMem(Puffer2,64000);
 If Puffs.P1 then FreeMem(Puffer3,64000);
 end;
END;



{********************************************************************}
{*         PROCEDURE PUTPIXEL                                       *}
{********************************************************************}

PROCEDURE PutPixel(x,y: Integer; c:Byte); Assembler;
ASM
  mov es, sega000
  mov ax, y
  mov bx, ax

  shl ax, 8
  shl bx, 6

  add bx, ax
  add bx, x
  mov ah, c

  mov es:[bx],ah
END;



{********************************************************************}
{*         PROCEDURE SWAPINT                                        *}
{********************************************************************}

PROCEDURE SwapInt(Var i1: Integer;Var i2: Integer);
VAR
  h: Integer;
BEGIN
  h:=i1;
  i1:=i2;
  i2:=h;
END;



{********************************************************************}
{*         PROCEDURE LINE                                           *}
{********************************************************************}

PROCEDURE Line(x1, y1, x2, y2 : Integer; Farbe : Byte);
VAR
  dx, dy:          Integer;
  dG, dAB1, dAB2:  Integer;
  x, y:            Integer;
  hilf1, hilf2 :   Integer;
BEGIN
   IF x1 > x2 THEN BEGIN
      SwapInt(x1,x2);
      SwapInt(y1,y2);
   END;


    dx := x2-x1;
    dy := y2-y1;
    hilf1 := dx;
    hilf2 := dy;

   IF (dx < -dy) AND (dy < 0) THEN BEGIN     {Steigung < -1}
      y1 := -y1;
      y2 := -y2;
      SwapInt(x1,y1);
      SwapInt(x2,y2);
   END;

   IF (dx >= -dy) AND (dy < 0) THEN BEGIN     { -1 < Steigung < 0}
      y1 := -y1;
      y2 := -y2;
   END;

   IF (dx <= dy) AND (dy > 0) THEN BEGIN      { Steigung >= 1}
      SwapInt(x1,y1);
      SwapInt(x2,y2);
   END;

   dx := x2-x1;
   dy := y2-y1;

   dG := 2*dy-dx;
   dAB1 := 2*(dy-dx);
   dAB2 := 2*dy;
   x := x1;
   y := y1;

   IF (hilf1 < -hilf2) AND (hilf2 < 0) THEN BEGIN
      PutPixel(y,-x,farbe);
      FOR x := x1+1 TO x2 DO BEGIN
        IF dG < 0 THEN
          Inc(dG, dAB2)
        ELSE BEGIN
          Inc(dG, dAB1);
          Inc(y);
        END;
        PutPixel(y, -x, Farbe);
      END;
    END

    ELSE IF (hilf1 >= -hilf2) AND (hilf2 < 0) THEN BEGIN
      PutPixel(x, -y, Farbe);
      FOR x := x1+1 TO x2 DO BEGIN
        IF dG < 0 THEN
          Inc(dG, dAB2)
        ELSE BEGIN
          Inc(dG, dAB1);
          Inc(y);
        END;
        PutPixel(x, -y, Farbe);
      END;
    END

    ELSE IF (hilf1 > hilf2) AND (hilf2 >= 0) THEN BEGIN
      PutPixel(x, y, Farbe);
      FOR x := x1+1 TO x2 DO BEGIN
        IF dG < 0 THEN
          Inc(dG, dAB2)
        ELSE BEGIN
          Inc(dG, dAB1);
          Inc(y);
        END;
        PutPixel(x, y, Farbe);
      END;
    END

    ELSE IF (hilf1 <= hilf2) AND (hilf2 > 0) THEN BEGIN
      PutPixel(y, x, Farbe);
      FOR x := x1+1 TO x2 DO BEGIN
        IF dG < 0 THEN
          Inc(dG, dAB2)
        ELSE BEGIN
          Inc(dG, dAB1);
          Inc(y);
        END;
        PutPixel(y, x, Farbe);
      END;
    END
END;



{********************************************************************}
{*         FUNCTION GETPIXEL                                        *}
{********************************************************************}

FUNCTION GetPixel(x,y: Integer):Byte;
BEGIN
  GetPixel:=MEM[$A000:y*320+x];
END;



{********************************************************************}
{*         PROCEDURE ELLIPSE                                        *}
{********************************************************************}

PROCEDURE Ellipse(px,py:LongInt; XRadius,YRadius:LongInt; Farbe:Byte);
VAR

  d1, d2, d3 : LongInt;
  x, y       : LongInt;
  q          : LongInt;

BEGIN
  IF XRadius = YRadius THEN
     YRadius := (YRadius * 85) DIV 100;


  x := 0;
  IF XRadius > YRadius THEN BEGIN
     y := XRadius;
     d1 := XRadius;
     q := (YRadius SHL 16) DIV XRadius;
  END
  ELSE BEGIN
    y := YRadius;
    d1 := YRadius;
    q := (XRadius SHL 16) DIV YRadius;
  END;


  WHILE x <= y DO
    IF d1 < 0 THEN BEGIN
       Dec(y);
       Inc(d1, 2*y);
    END
    ELSE BEGIN

      d2 := (x*q) SHR 16;
      d3 := (y*q) SHR 16;

      IF XRadius > YRadius THEN BEGIN
         PutPixel(px-x, py-d3, farbe);
         PutPixel(px-x, py+d3, farbe);
         PutPixel(px+x, py-d3, farbe);
         PutPixel(px+x, py+d3, farbe);
         PutPixel(px-y, py-d2, farbe);
         PutPixel(px-y, py+d2, farbe);
         PutPixel(px+y, py-d2, farbe);
         PutPixel(px+y, py+d2, farbe);
      END
      ELSE BEGIN
         PutPixel(px-d2, py-y, farbe);
         PutPixel(px-d2, py+y, farbe);
         PutPixel(px+d2, py-y, farbe);
         PutPixel(px+d2, py+y, farbe);
         PutPixel(px-d3, py-x, farbe);
         PutPixel(px-d3, py+x, farbe);
         PutPixel(px+d3, py-x, farbe);
         PutPixel(px+d3, py+x, farbe);
      END;

      Dec(d1, 2*x-1);
      Inc(x);
    END;
END;



{********************************************************************}
{*         PROCEDURE CLS                                            *}
{********************************************************************}

PROCEDURE CLS(farbe: Byte);
BEGIN
  FillChar(Mem[$A000:0000], 64000, farbe);
END;


{####################################################################}
{####################################################################}
{####################################################################}

{********************************************************************}
{*         PROCEDURE SETREG                                         *}
{********************************************************************}

PROCEDURE SetReg(FarbeNr, Rot, Gruen, Blau: Byte); ASSEMBLER;
ASM
  mov dx, $3C8
  mov al, FarbeNr
  out dx, al

  mov dx, $3C9
  mov al, Rot
  out dx, al
  mov al, Gruen
  out dx, al
  mov al, Blau
  out dx, al
END;



{********************************************************************}
{*         PROCEDURE GETREG                                         *}
{********************************************************************}

PROCEDURE GetReg(FarbeNr: Byte; VAR Rot, Gruen, Blau: Byte);
VAR
  r, g, b: Byte;
BEGIN
  ASM
    mov dx, $3C7
    mov al, FarbeNr
    out dx, al
    mov dx, $3C9
    in al, dx
    mov r, al
    in al, dx
    mov g, al
    in al, dx
    mov b, al
  END;
  Rot:=r;
  Gruen:=g;
  Blau:=b;
END;



{********************************************************************}
{*         PROCEDURE SETREGBLOCK                                    *}
{********************************************************************}

PROCEDURE SetRegBlock(StartFarbe, Anzahl: Word; VAR Farbtabelle);
VAR
  regs: Registers;
BEGIN
  regs.ah := $10;
  regs.al := $12;
  regs.bx := StartFarbe;
  regs.cx := Anzahl;
  regs.es := Seg(Farbtabelle);
  regs.dx := Ofs(Farbtabelle) + 3 * StartFarbe;
  Intr($10, regs);
END;



{********************************************************************}
{*         PROCEDURE GETREGBLOCK                                    *}
{********************************************************************}

PROCEDURE GetRegBlock(StartFarbe, Anzahl: Word; VAR Farbtabelle);
VAR
  regs: Registers;
BEGIN
  regs.ah := $10;
  regs.al := $17;
  regs.bx := StartFarbe;
  regs.cx := Anzahl;
  regs.es := Seg(Farbtabelle);
  regs.dx := Ofs(Farbtabelle) + 3 * StartFarbe;
  Intr($10, regs);
END;



{********************************************************************}
{*         PROCEDURE GRAYSCALE                                      *}
{********************************************************************}

PROCEDURE GrayScale(Startfarbe, Anzahl: Word);
VAR
  regs: Registers;
BEGIN
  regs.ah := $10;
  regs.al := $1B;
  regs.bx := Startfarbe;
  regs.cx := Anzahl;
  Intr($10, regs);
END;



{####################################################################}
{####################################################################}
{####################################################################}

{********************************************************************}
{*         PROCEDURE CIRCLE                                         *}
{********************************************************************}

PROCEDURE Circle(X, Y, Radius, Farbe: Word);
BEGIN
 ELLIPSE(X, Y, Radius, Radius, Farbe);
END;



{********************************************************************}
{*         PROCEDURE RECTANGLE                                      *}
{********************************************************************}

PROCEDURE Rectangle(X1, Y1, X2, Y2, Farbe: Word);
BEGIN
 LINE(X1, Y1, X2, Y1, Farbe);
 LINE(X1, Y1, X1, Y2, Farbe);
 LINE(X1, Y2, X2, Y2, Farbe);
 LINE(X2, Y2, X2, Y1, Farbe);
END;



{********************************************************************}
{*         PROCEDURE THREEANGLE                                     *}
{********************************************************************}

PROCEDURE Threeangle(X1, Y1, X2, Y2, X3, Y3, Farbe: Word);
BEGIN
 LINE(X1, Y1, X2, Y2, Farbe);
 LINE(X1, Y1, X3, Y3, Farbe);
 LINE(X2, Y2, X3, Y3, Farbe);
END;



{********************************************************************}
{*         PROCEDURE HLINE                                          *}
{********************************************************************}

PROCEDURE HLine(x1,x2,y: Integer; c: Byte);
BEGIN
  if x2>x1 then
    FillChar(Mem[$A000:y*320+x1],x2-x1+1,c)
  else
    FillChar(Mem[$A000:y*320+x2],x1-x2+1,c);
END;



{********************************************************************}
{*         PROCEDURE DRAWPOLY                                       *}
{********************************************************************}

PROCEDURE DrawPoly(x1,y1, x2,y2, x3,y3: Integer; c: Byte);
VAR
  p1,p2,p3: t_koor;
  ml, mr: LongInt;
  y: Integer;
  xstart, xend: LongInt;
  xs, xe: Integer;

BEGIN
  if y1 >= y2 then begin
    p1.x:=x2;
    p1.y:=y2;
    p3.x:=x1;
    p3.y:=y1;
  end
  else begin
    p1.x:=x1;
    p1.y:=y1;
    p3.x:=x2;
    p3.y:=y2;
  end;
  if (y3 >= p1.y) and (y3 <= p3.y) then begin
    p2.x:=x3;
    p2.y:=y3;
  end
  else if y3 < p1.y then begin
    p2:=p1;
    p1.x:=x3;
    p1.y:=y3;
  end
  else if y3 > p3.y then begin
    p2:=p3;
    p3.x:=x3;
    p3.y:=y3;
  end;

  if (p3.y=p2.y) and (p3.y=p1.y) then
    exit;

  ml:=LongInt((p3.x - p1.x) SHL 16) div (p3.y - p1.y);


  if p2.y-p1.y <> 0 then begin

    mr:=LongInt((p2.x - p1.x) SHL 16) div (p2.y - p1.y);

    xstart:=p1.x SHL 16;
    xend:=p1.x SHL 16;
    HLine(p1.x,p1.x,p1.y,c);
    for y:=p1.y+1 to p2.y do begin
      Inc(xstart,ml);
      Inc(xend,mr);
      Hline(xstart SHR 16,xend SHR 16,y,c);
    end;
  end

  else begin
    xstart:=p1.x shl 16;
    xend:=p2.x shl 16;
    HLine(p1.x,p2.x,p1.y,c);
  end;

  if p3.y-p2.y <> 0 then begin
    mr:=((p3.x - p2.x) SHL 16) div (p3.y - p2.y);
    for y:=p2.y+1 to p3.y do begin
      Inc(xstart,ml);
      Inc(xend,mr);
      Hline(xstart SHR 16,xend SHR 16,y, c);
    end;
  end
  else
    HLine(p2.x,p3.x,p2.y,c);
END;



{********************************************************************}
{*         PROCEDURE FILL4                                          *}
{********************************************************************}

PROCEDURE Fill4(x1,y1,x2,y2,x3,y3,x4,y4: Integer; c: Byte);
BEGIN
  DrawPoly(x1,y1,x2,y2,x3,y3,c);
  DrawPoly(x1,y1,x4,y4,x3,y3,c);
END;



{********************************************************************}
{*         PROCEDURE FILLRECTANGLE                                  *}
{********************************************************************}

PROCEDURE FillRectangle(x1, y1, x2, y2, Farben: word);
Var
 x,y: integer;
BEGIN
Fill4(x1,y1,x2,y2,x1,y2,x2,y2,Farben);
Drawpoly(x1,y1,x2,y1,x2,y2,Farben);
END;



{********************************************************************}
{*         PROCEDURE GETROMFONT                                     *}
{********************************************************************}

PROCEDURE GetROMFont;
BEGIN
  {1. Teil}
  Move(Mem[$FFA6:$000E],Zeichensatz,128*8);
  {2. Teil}
  Move(Mem[MemW[0:$7E]:MemW[0:$7C]],
       Mem[Seg(Zeichensatz):Ofs(Zeichensatz)+128*8],128*8);
END;



{********************************************************************}
{*         PROCEDURE PUTCHAR                                        *}
{********************************************************************}

PROCEDURE PutChar(X, Y: Integer; C: Char; f: Byte);
VAR
 z,s,n: Byte;
BEGIN
 n:=Ord(c);
 FOR z:=0 to 7 DO
   FOR s:=0 to 7 DO
      IF ((128 SHR s) AND Zeichensatz[n,z]) = (128 SHR s) THEN
        PutPixel(X+s,Y+z,f);
END;



{********************************************************************}
{*         PROCEDURE PUTTEXT                                        *}
{********************************************************************}

PROCEDURE PutText(X, Y: Integer; t: String;f: Byte);
VAR
 px,n: Byte;
BEGIN
  px:=9;
  FOR n:=1 TO Length(t) DO
    PutChar(X+px*(n-1),Y,t[n],f);
END;



{********************************************************************}
{*         PROCEDURE WAITRETRACE                                    *}
{********************************************************************}

PROCEDURE WaitRetrace; Assembler;
Asm
  mov     dx,3dah  {Abfrage der Register an Port 3Dah}
@l1:
  in      al,dx
  and     al,08h
  jnz     @l1
@l2:
  in      al,dx
  and     al,08h
  jz      @l2
End;



{********************************************************************}
{*         PROCEDURE HPOLY                                          *}
{********************************************************************}

PROCEDURE HPoly(x1,y1,x2,y2,x3,y3,x4,y4: Integer; c: Byte);
VAR
  z: Integer;
BEGIN
  DrawPoly(x1,y1,x2,y2,x3,y3,c);
  DrawPoly(x1,y1,x4,y4,x3,y3,c);
END;



{********************************************************************}
{*         PROCEDURE HLINEP                                         *}
{********************************************************************}

PROCEDURE HLineP(x1,x2,y: Integer; c: Byte; P: byte);
BEGIN
Case P of
1: begin if x2>x1 then
    FillChar(Mem[Seg(Puffer1^):Ofs(Puffer1^)+y*320+x1],x2-x1+1,c)
  else
    FillChar(Mem[Seg(Puffer1^):Ofs(Puffer1^)+y*320+x2],x1-x2+1,c);
    end;
2: begin if x2>x1 then
    FillChar(Mem[Seg(Puffer2^):Ofs(Puffer2^)+y*320+x1],x2-x1+1,c)
  else
    FillChar(Mem[Seg(Puffer2^):Ofs(Puffer2^)+y*320+x2],x1-x2+1,c);
    end;
3: begin if x2>x1 then
    FillChar(Mem[Seg(Puffer3^):Ofs(Puffer3^)+y*320+x1],x2-x1+1,c)
  else
    FillChar(Mem[Seg(Puffer3^):Ofs(Puffer3^)+y*320+x2],x1-x2+1,c);
    end;
End;
END;




{********************************************************************}
{*         PROCEDURE DRAWPOLYP                                      *}
{********************************************************************}

PROCEDURE DrawPolyP(x1,y1, x2,y2, x3,y3: Integer; c,P: Byte);
VAR
  p1,p2,p3: t_koor;
  ml, mr: LongInt;
  y: Integer;
  xstart, xend: LongInt;
  xs, xe: Integer;

BEGIN
  if y1 >= y2 then begin
    p1.x:=x2;
    p1.y:=y2;
    p3.x:=x1;
    p3.y:=y1;
  end
  else begin
    p1.x:=x1;
    p1.y:=y1;
    p3.x:=x2;
    p3.y:=y2;
  end;
  if (y3 >= p1.y) and (y3 <= p3.y) then begin
    p2.x:=x3;
    p2.y:=y3;
  end
  else if y3 < p1.y then begin
    p2:=p1;
    p1.x:=x3;
    p1.y:=y3;
  end
  else if y3 > p3.y then begin
    p2:=p3;
    p3.x:=x3;
    p3.y:=y3;
  end;

  if (p3.y=p2.y) and (p3.y=p1.y) then
    exit;

  ml:=LongInt((p3.x - p1.x) SHL 16) div (p3.y - p1.y);

  if p2.y-p1.y <> 0 then begin
    mr:=LongInt((p2.x - p1.x) SHL 16) div (p2.y - p1.y);

    xstart:=p1.x SHL 16;
    xend:=p1.x SHL 16;
    HlineP(p1.x,p1.x,p1.y,c,P);
    for y:=p1.y+1 to p2.y do begin
      Inc(xstart,ml);
      Inc(xend,mr);
      HlineP(xstart SHR 16,xend SHR 16,y,c,P);
    end;
  end

  else begin
    xstart:=p1.x shl 16;
    xend:=p2.x shl 16;
    HlineP(p1.x,p2.x,p1.y,c,P);
  end;

  if p3.y-p2.y <> 0 then begin
    mr:=((p3.x - p2.x) SHL 16) div (p3.y - p2.y);
    for y:=p2.y+1 to p3.y do begin
      Inc(xstart,ml);
      Inc(xend,mr);
      HlineP(xstart SHR 16,xend SHR 16,y, c,P);
    end;
  end
  else
    HlineP(p2.x,p3.x,p2.y,c,P);
END;



{********************************************************************}
{*         PROCEDURE MOVEPUFFER                                     *}
{********************************************************************}

PROCEDURE MovePuffer(P: Byte);
BEGIN
Case P of
1: Move(Puffer1^,Mem[$A000:0],64000);
2: Move(Puffer2^,Mem[$A000:0],64000);
3: Move(Puffer3^,Mem[$A000:0],64000);
End;
END;



{********************************************************************}
{*         PROCEDURE HPOLYP                                         *}
{********************************************************************}

PROCEDURE HPolyP(x1,y1,x2,y2,x3,y3,x4,y4: Integer; c,P: Byte);
VAR
  z: Integer;
BEGIN
  DrawPolyP(x1,y1,x2,y2,x3,y3,c,P);
  DrawPolyP(x1,y1,x4,y4,x3,y3,c,P);
END;



{********************************************************************}
{*         PROCEDURE FILL4P                                         *}
{********************************************************************}

PROCEDURE Fill4P(x1,y1,x2,y2,x3,y3,x4,y4: Integer; c,P: Byte);
BEGIN
  DrawPolyp(x1,y1,x2,y2,x3,y3,c,P);
  DrawPolyp(x1,y1,x4,y4,x3,y3,c,P);
END;



{********************************************************************}
{*         PROCEDURE FILL4P                                         *}
{********************************************************************}

PROCEDURE CLPUFFER(farbe,P: Byte);
BEGIN
Case P of
1: FillChar(Puffer1^,64000,farbe);
2: FillChar(Puffer2^,64000,farbe);
3: FillChar(Puffer3^,64000,farbe);
End;
END;



{********************************************************************}
{*         PROCEDURE PUTPIXELP                                      *}
{********************************************************************}

PROCEDURE PutpixelP(X,Y: Integer; C,P: Byte);
PROCEDURE PpP1(x,y,c : word); assembler;
asm
  les   di,Puffer1
  mov   ax,320
  mul   y
  add   ax,x
  add   di,ax {oder auch mov   di,ax}
  mov   al,byte ptr c
  stosb
end;

PROCEDURE PpP2(x,y,c : word); assembler;
asm
  les   di,Puffer2
  mov   ax,320
  mul   y
  add   ax,x
  add   di,ax {oder auch mov   di,ax}
  mov   al,byte ptr c
  stosb
end;

PROCEDURE PpP3(x,y,c : word); assembler;
asm
  les   di,Puffer3
  mov   ax,320
  mul   y
  add   ax,x
  add   di,ax {oder auch mov   di,ax}
  mov   al,byte ptr c
  stosb
end;


Begin
Case P of
1: PpP1(X,Y,C);
2: PpP2(X,Y,C);
3: PpP3(X,Y,C);
End;
End;


{####################################################################}
{####################################################################}
{####################################################################}

{********************************************************************}
{*         PROCEDURE LINEP                                          *}
{********************************************************************}

PROCEDURE LineP(x1, y1, x2, y2 : Integer; Farbe, P : Byte);
VAR
  dx, dy:          Integer;
  dG, dAB1, dAB2:  Integer;
  x, y:            Integer;
  hilf1, hilf2 :   Integer;
BEGIN
   IF x1 > x2 THEN BEGIN
      SwapInt(x1,x2);
      SwapInt(y1,y2);
   END;


    dx := x2-x1;
    dy := y2-y1;
    hilf1 := dx;
    hilf2 := dy;

   IF (dx < -dy) AND (dy < 0) THEN BEGIN     {Steigung < -1}
      y1 := -y1;
      y2 := -y2;
      SwapInt(x1,y1);
      SwapInt(x2,y2);
   END;

   IF (dx >= -dy) AND (dy < 0) THEN BEGIN     { -1 < Steigung < 0}
      y1 := -y1;
      y2 := -y2;
   END;

   IF (dx <= dy) AND (dy > 0) THEN BEGIN      { Steigung >= 1}
      SwapInt(x1,y1);
      SwapInt(x2,y2);
   END;

   dx := x2-x1;
   dy := y2-y1;

   dG := 2*dy-dx;
   dAB1 := 2*(dy-dx);
   dAB2 := 2*dy;
   x := x1;
   y := y1;

   IF (hilf1 < -hilf2) AND (hilf2 < 0) THEN BEGIN
      putpixelp(y,-x,farbe,P);
      FOR x := x1+1 TO x2 DO BEGIN
        IF dG < 0 THEN
          Inc(dG, dAB2)
        ELSE BEGIN
          Inc(dG, dAB1);
          Inc(y);
        END;
        putpixelp(y, -x, Farbe,P);
      END;
    END

    ELSE IF (hilf1 >= -hilf2) AND (hilf2 < 0) THEN BEGIN
      putpixelp(x, -y, Farbe,P);
      FOR x := x1+1 TO x2 DO BEGIN
        IF dG < 0 THEN
          Inc(dG, dAB2)
        ELSE BEGIN
          Inc(dG, dAB1);
          Inc(y);
        END;
        putpixelp(x, -y, Farbe,P);
      END;
    END

    ELSE IF (hilf1 > hilf2) AND (hilf2 >= 0) THEN BEGIN
      putpixelp(x, y, Farbe,P);
      FOR x := x1+1 TO x2 DO BEGIN
        IF dG < 0 THEN
          Inc(dG, dAB2)
        ELSE BEGIN
          Inc(dG, dAB1);
          Inc(y);
        END;
        putpixelp(x, y, Farbe,P);
      END;
    END

    ELSE IF (hilf1 <= hilf2) AND (hilf2 > 0) THEN BEGIN
      putpixelp(y, x, Farbe,P);
      FOR x := x1+1 TO x2 DO BEGIN
        IF dG < 0 THEN
          Inc(dG, dAB2)
        ELSE BEGIN
          Inc(dG, dAB1);
          Inc(y);
        END;
        putpixelp(y, x, Farbe,P);
      END;
    END
END;



{********************************************************************}
{*         PROCEDURE ELLIPSEP                                       *}
{********************************************************************}

PROCEDURE Ellipsep(px,py:LongInt; XRadius,YRadius:LongInt; Farbe, P:Byte);
VAR

  d1, d2, d3 : LongInt;
  x, y       : LongInt;
  q          : LongInt;

BEGIN
  IF XRadius = YRadius THEN
     YRadius := (YRadius * 85) DIV 100;


  x := 0;
  IF XRadius > YRadius THEN BEGIN
     y := XRadius;
     d1 := XRadius;
     q := (YRadius SHL 16) DIV XRadius;
  END
  ELSE BEGIN
    y := YRadius;
    d1 := YRadius;
    q := (XRadius SHL 16) DIV YRadius;
  END;


  WHILE x <= y DO
    IF d1 < 0 THEN BEGIN
       Dec(y);
       Inc(d1, 2*y);
    END
    ELSE BEGIN

      d2 := (x*q) SHR 16;
      d3 := (y*q) SHR 16;

      IF XRadius > YRadius THEN BEGIN
         putpixelp(px-x, py-d3, farbe,P);
         putpixelp(px-x, py+d3, farbe,P);
         putpixelp(px+x, py-d3, farbe,P);
         putpixelp(px+x, py+d3, farbe,P);
         putpixelp(px-y, py-d2, farbe,P);
         putpixelp(px-y, py+d2, farbe,P);
         putpixelp(px+y, py-d2, farbe,P);
         putpixelp(px+y, py+d2, farbe,P);
      END
      ELSE BEGIN
         putpixelp(px-d2, py-y, farbe,P);
         putpixelp(px-d2, py+y, farbe,P);
         putpixelp(px+d2, py-y, farbe,P);
         putpixelp(px+d2, py+y, farbe,P);
         putpixelp(px-d3, py-x, farbe,P);
         putpixelp(px-d3, py+x, farbe,P);
         putpixelp(px+d3, py-x, farbe,P);
         putpixelp(px+d3, py+x, farbe,P);
      END;

      Dec(d1, 2*x-1);
      Inc(x);
    END;
END;



{********************************************************************}
{*         PROCEDURE CIRCLEP                                        *}
{********************************************************************}

PROCEDURE CircleP(X, Y, Radius, Farbe: Word; P: Byte);
BEGIN
 ELLIPSEP(X, Y, Radius, Radius, Farbe,P);
END;



{********************************************************************}
{*         PROCEDURE RECTANGLEP                                     *}
{********************************************************************}

PROCEDURE RectangleP(X1, Y1, X2, Y2, Farbe: Word; P: Byte);
BEGIN
 LINEP(X1, Y1, X2, Y1, Farbe,P);
 LINEP(X1, Y1, X1, Y2, Farbe,P);
 LINEP(X1, Y2, X2, Y2, Farbe,P);
 LINEP(X2, Y2, X2, Y1, Farbe,P);
END;



{********************************************************************}
{*         PROCEDURE THREEANGLEP                                    *}
{********************************************************************}

PROCEDURE ThreeangleP(X1, Y1, X2, Y2, X3, Y3, Farbe: Word; P: Byte);
BEGIN
 LINEP(X1, Y1, X2, Y2, Farbe,P);
 LINEP(X1, Y1, X3, Y3, Farbe,P);
 LINEP(X2, Y2, X3, Y3, Farbe,P);
END;


{********************************************************************}
{*         PROCEDURE PUTCHARP                                       *}
{********************************************************************}

PROCEDURE PutCharP(X, Y: Integer; C: Char; f,P: Byte);
VAR
 z,s,n: Byte;
BEGIN
 n:=Ord(c);
 FOR z:=0 to 7 DO
   FOR s:=0 to 7 DO
      IF ((128 SHR s) AND Zeichensatz[n,z]) = (128 SHR s) THEN
        PutPixelP(X+s,Y+z,f,P);
END;



{********************************************************************}
{*         PROCEDURE PUTTEXTP                                       *}
{********************************************************************}

PROCEDURE PutTextP(X, Y: Integer; t: String;f,P: Byte);
VAR
 px,n: Byte;
BEGIN
  px:=9;
  FOR n:=1 TO Length(t) DO
    PutCharP(X+px*(n-1),Y,t[n],f,P);
END;


{********************************************************************}
{*         FUNCTION GETPIXELP                                       *}
{********************************************************************}

FUNCTION GetPixelP(X,Y: Word; P: Byte): Word;

FUNCTION GPP1(X, Y : Word): Word; assembler;
asm
  les   si,Puffer1
  mov   ax,320
  mul   y
  add   ax,x
  add   si,ax
  xor   ax,ax
  mov   al,es:[si]
END;

FUNCTION GPP2(X, Y : Word): Word; assembler;
asm
  les   si,Puffer2
  mov   ax,320
  mul   y
  add   ax,x
  add   si,ax
  xor   ax,ax
  mov   al,es:[si]
END;

FUNCTION GPP3(X, Y : Word): Word; assembler;
asm
  les   si,Puffer3
  mov   ax,320
  mul   y
  add   ax,x
  add   si,ax
  xor   ax,ax
  mov   al,es:[si]
END;

Begin
 Case P of
  1: GetPixelP:= GPP1(X,Y);
  2: GetPixelP:= GPP1(X,Y);
  3: GetPixelP:= GPP1(X,Y);
 End;
End;


{####################################################################}
{####################################################################}
{####################################################################}

{********************************************************************}
{*         FUNCTION GRVERSION                                       *}
{********************************************************************}

FUNCTION GRVERSION: String;
Begin
 GRVersion:= 'Genesis13 Grafikunit Version 4.00';
End;


{####################################################################}
{####################################################################}
{####################################################################}

{********************************************************************}
{*         PROCEDURE SHOWBMP                                        *}
{********************************************************************}

PROCEDURE ShowBMP(DateiName: String; X, Y: Word; Pal: Boolean);
Var
 BMPFileHeader : record
  BfType     : Integer;
  BfSize     : Longint;
  BfReserved1: Integer;
  BfReserved2: Integer;
  BfOffBits  : Longint
 End;

 BMPInfoHeader : record
  BiSize         : Longint;
  BiWidth        : Longint;
  BiHeight       : Longint;
  BiPlanes       : Word;
  BiBitCount     : Word;
  BiCompression  : Longint;
  BiSizeImage    : Longint;
  BiXPelsPerMeter: Longint;
  BiYPelsPerMeter: Longint;
  BiClrUsed      : Longint;
  BiClrImportant : Longint
 End;

 J,
 I: Longint;
 F: File;
 Size: Longint;
 CH: Boolean;
 Palette: array[0..255, 1..4] of Byte;
 B: array[1..4] of Byte;
 K: Byte;

 Label 100;
Begin
 If not FileExists(DateiName) then Goto 100;
 Assign(F, DateiName);
 Reset(F, 1);
 Size:= FileSize(F);
 BlockRead(F, BMPFileHeader, 14);
 BlockRead(F, Size, 4);
 CH:= Size= $0C;
 BMPInfoHeader.BiSize:= Size;
 BlockRead(F, BMPInfoHeader.BiWidth, $24);
 If Pal then
 Begin
  Seek(f,54);
  BlockRead(f, Palette,1024);
  For I:=0 to 255 do
   SetReg(I, Palette[I, 3] div 4, Palette[I, 2] div 4, Palette[I, 1] div 4);
 End;
 Seek(F,BMPFileHeader.BfOffBits);
 With BMPInfoHeader do
  For J:= BiHeight-1 downto 0 do
  Begin
   I:= 0;
   Repeat
    BlockRead(F, B[1], 4);
    For K:= 1 to 4 do
    Begin
     If (X+I < 320) and (X+I > -1) and (Y+J < 200) and (Y+I > -1) then
      PutPixel(X+I, Y+J, B[K]);
     Inc (I)
    End;
   Until I > BiWidth-1;
  End;
 Close(f);
 100:
End;


{********************************************************************}
{*         PROCEDURE SHOWBMPP                                       *}
{********************************************************************}

PROCEDURE ShowBMPP(DateiName: String; X, Y: Word; Pal: Boolean; P: Word);
Var
 BMPFileHeader : record
  BfType     : Integer;
  BfSize     : Longint;
  BfReserved1: Integer;
  BfReserved2: Integer;
  BfOffBits  : Longint
 End;

 BMPInfoHeader : record
  BiSize         : Longint;
  BiWidth        : Longint;
  BiHeight       : Longint;
  BiPlanes       : Word;
  BiBitCount     : Word;
  BiCompression  : Longint;
  BiSizeImage    : Longint;
  BiXPelsPerMeter: Longint;
  BiYPelsPerMeter: Longint;
  BiClrUsed      : Longint;
  BiClrImportant : Longint
 End;

 J,
 I: Longint;
 F: File;
 Size: Longint;
 CH: Boolean;
 Palette: array[0..255, 1..4] of Byte;
 B: array[1..4] of Byte;
 K: Byte;

 Label 100;
Begin
 If not FileExists(DateiName) then Goto 100;
 Assign(F, DateiName);
 Reset(F, 1);
 Size:= FileSize(F);
 BlockRead(F, BMPFileHeader, 14);
 BlockRead(F, Size, 4);
 CH:= Size= $0C;
 BMPInfoHeader.BiSize:= Size;
 BlockRead(F, BMPInfoHeader.BiWidth, $24);
 If Pal then
 Begin
  Seek(f,54);
  BlockRead(f, Palette,1024);
  For I:=0 to 255 do
   SetReg(I, Palette[I, 3] div 4, Palette[I, 2] div 4, Palette[I, 1] div 4);
 End;
 Seek(F,BMPFileHeader.BfOffBits);
 With BMPInfoHeader do
  For J:= BiHeight-1 downto 0 do
  Begin
   I:= 0;
   Repeat
    BlockRead(F, B[1], 4);
    For K:= 1 to 4 do
    Begin
     If (X+I < 320) and (X+I > -1) and (Y+J < 200) and (Y+I > -1) then
      PutPixelP(X+I, Y+J, B[K], P);
     Inc (I)
    End;
   Until I > BiWidth-1;
  End;
 Close(f);
 100:
End;


{********************************************************************}
{*         PROCEDURE BGSHOWBMP                                      *}
{********************************************************************}

PROCEDURE BGShowBMP(DateiName: String; X, Y, MX, MY: Word; Pal: Boolean);
Var
 BMPFileHeader : record
  BfType     : Integer;
  BfSize     : Longint;
  BfReserved1: Integer;
  BfReserved2: Integer;
  BfOffBits  : Longint
 End;

 BMPInfoHeader : record
  BiSize         : Longint;
  BiWidth        : Longint;
  BiHeight       : Longint;
  BiPlanes       : Word;
  BiBitCount     : Word;
  BiCompression  : Longint;
  BiSizeImage    : Longint;
  BiXPelsPerMeter: Longint;
  BiYPelsPerMeter: Longint;
  BiClrUsed      : Longint;
  BiClrImportant : Longint
 End;

 J,
 I: Longint;
 F: File;
 Size: Longint;
 CH: Boolean;
 Palette: array[0..255, 1..4] of Byte;
 B: array[1..4] of Byte;
 K: Byte;

 Label 100;
Begin
 If not FileExists(DateiName) then Goto 100;
 Assign(F, DateiName);
 Reset(F, 1);
 Size:= FileSize(F);
 BlockRead(F, BMPFileHeader, 14);
 BlockRead(F, Size, 4);
 CH:= Size= $0C;
 BMPInfoHeader.BiSize:= Size;
 BlockRead(F, BMPInfoHeader.BiWidth, $24);
 If Pal then
 Begin
  Seek(f,54);
  BlockRead(f, Palette,1024);
  For I:=0 to 255 do
   SetReg(I, Palette[I, 3] div 4, Palette[I, 2] div 4, Palette[I, 1] div 4);
 End;
 Seek(F,BMPFileHeader.BfOffBits);
 With BMPInfoHeader do
  For J:= BiHeight-1 downto 0 do
  Begin
   I:= 0;
   Repeat
    BlockRead(F, B[1], 4);
    For K:= 1 to 4 do
    Begin
     If (X+I < 320) and (X+I > -1) and (Y+J < 200) and (Y+I > -1) then
      If (X+I < MX) and (Y+J < MY) then
       PutPixel(X+I, Y+J, B[K]);
     Inc (I)
    End;
   Until I > BiWidth-1;
  End;
 Close(f);
 100:
End;


{********************************************************************}
{*         PROCEDURE BGSHOWBMPP                                     *}
{********************************************************************}

PROCEDURE BGShowBMPP(DateiName: String; X, Y, MX, MY: Word; Pal: Boolean; P: Word);
Var
 BMPFileHeader : record
  BfType     : Integer;
  BfSize     : Longint;
  BfReserved1: Integer;
  BfReserved2: Integer;
  BfOffBits  : Longint
 End;

 BMPInfoHeader : record
  BiSize         : Longint;
  BiWidth        : Longint;
  BiHeight       : Longint;
  BiPlanes       : Word;
  BiBitCount     : Word;
  BiCompression  : Longint;
  BiSizeImage    : Longint;
  BiXPelsPerMeter: Longint;
  BiYPelsPerMeter: Longint;
  BiClrUsed      : Longint;
  BiClrImportant : Longint
 End;

 J,
 I: Longint;
 F: File;
 Size: Longint;
 CH: Boolean;
 Palette: array[0..255, 1..4] of Byte;
 B: array[1..4] of Byte;
 K: Byte;

 Label 100;
Begin
 If not FileExists(DateiName) then Goto 100;
 Assign(F, DateiName);
 Reset(F, 1);
 Size:= FileSize(F);
 BlockRead(F, BMPFileHeader, 14);
 BlockRead(F, Size, 4);
 CH:= Size= $0C;
 BMPInfoHeader.BiSize:= Size;
 BlockRead(F, BMPInfoHeader.BiWidth, $24);
 If Pal then
 Begin
  Seek(f,54);
  BlockRead(f, Palette,1024);
  For I:=0 to 255 do
   SetReg(I, Palette[I, 3] div 4, Palette[I, 2] div 4, Palette[I, 1] div 4);
 End;
 Seek(F,BMPFileHeader.BfOffBits);
 With BMPInfoHeader do
  For J:= BiHeight-1 downto 0 do
  Begin
   I:= 0;
   Repeat
    BlockRead(F, B[1], 4);
    For K:= 1 to 4 do
    Begin
     If (X+I < 320) and (X+I > -1) and (Y+J < 200) and (Y+I > -1) then
      If (X+I < MX) and (Y+J < MY) then
       PutPixelP(X+I, Y+J, B[K], P);
     Inc (I)
    End;
   Until I > BiWidth-1;
  End;
 Close(f);
 100:
End;


{********************************************************************}
{*         PROCEDURE SHOWPCX                                        *}
{********************************************************************}

PROCEDURE ShowPCX(DateiName: String; PX, PY:Integer; Pal:Boolean);
Var
 F: File;
 Puf: Pointer;
 P1, P2: Byte;
 Pall: array[0..767] of Byte;
 I, J, K, Count: Word;
 C, D: Byte;
 P: Byte;
 X, Y: Integer;
 Streck: Integer;
 SX, SY, EX, EY: Word;

 Label 100;
Begin
 If not FileExists(DateiName) then Goto 100;
 Assign(F, DateiName);
 Reset(f,1);
 GetMem(Puf, FileSize(f));
 Seek(F, FileSize(F)- 768);
 BlockRead(F, Pall, 768);
 If Pal Then
 Begin
  For I:= 0 to 255 do
  Begin
   SetReg(I, Pall[i* 3] div 4, Pall[i* 3+ 1] div 4, Pall[i* 3+ 2] div 4);
  End;
 End;
 Seek(F, 4);
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 SX:= P2 SHL 8 + P1;
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 SY:= P2 SHL 8 + P1;
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 EX:= P2 SHL 8 + P1;
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 EY:= P2 SHL 8 + P1;
 Seek(f,128);
 Blockread(F, Puf^, FileSize(F)- 128- 768, Count);
 I:= 0;
 K:= 0;
 X:= PX div 2;
 X:= PX;
 REPEAT
  P1:= Mem[Seg(Puf^):Ofs(puf^)+ i];
  If P1>192 THEN
  Begin
   C:= P1-192;
   D:= Mem[Seg(Puf^):Ofs(Puf^)+ i+ 1];
   Inc(i, 2);
  End
  else
  Begin
   C:= 1;
   D:= P1;
   Inc(I, 1);
  End;
  For J:= 1 to C do
  Begin
   Inc(K);
   Inc(X);
   If X > PX+ EX then
   Begin
    X:= PX;
    Inc(PY);
   End;
   If (PX+ X < 320) and (PX+ X > -1) and (PY < 200) and (PY > -1) then
    Putpixel(PX+ X, PY, D);
  End;
 UNTIL I >= Count-1;
 FreeMem(Puf, FileSize(F));
 Close(F);
 100:
End;


{********************************************************************}
{*         PROCEDURE SHOWPCXP                                       *}
{********************************************************************}

PROCEDURE ShowPCXP(DateiName: String; PX, PY:Integer; Pal:Boolean; Pu: Word);
Var
 F: File;
 Puf: Pointer;
 P1, P2: Byte;
 Pall: array[0..767] of Byte;
 I, J, K, Count: Word;
 C, D: Byte;
 P: Byte;
 X, Y: Integer;
 Streck: Integer;
 SX, SY, EX, EY: Word;

 Label 100;
Begin
 If not FileExists(DateiName) then Goto 100;
 Assign(F, DateiName);
 Reset(f,1);
 GetMem(Puf, FileSize(f));
 Seek(F, FileSize(F)- 768);
 BlockRead(F, Pall, 768);
 If Pal Then
 Begin
  For I:= 0 to 255 do
  Begin
   SetReg(I, Pall[i* 3] div 4, Pall[i* 3+ 1] div 4, Pall[i* 3+ 2] div 4);
  End;
 End;
 Seek(F, 4);
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 SX:= P2 SHL 8 + P1;
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 SY:= P2 SHL 8 + P1;
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 EX:= P2 SHL 8 + P1;
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 EY:= P2 SHL 8 + P1;
 Seek(f,128);
 Blockread(F, Puf^, FileSize(F)- 128- 768, Count);
 I:= 0;
 K:= 0;
 X:= PX div 2;
 X:= PX;
 REPEAT
  P1:= Mem[Seg(Puf^):Ofs(puf^)+ i];
  If P1>192 THEN
  Begin
   C:= P1-192;
   D:= Mem[Seg(Puf^):Ofs(Puf^)+ i+ 1];
   Inc(i, 2);
  End
  else
  Begin
   C:= 1;
   D:= P1;
   Inc(I, 1);
  End;
  For J:= 1 to C do
  Begin
   Inc(K);
   Inc(X);
   If X > PX+ EX then
   Begin
    X:= PX;
    Inc(PY);
   End;
   If (PX+ X < 320) and (PX+ X > -1) and (PY < 200) and (PY > -1) then
    PutpixelP(PX+ X, PY, D, Pu);
  End;
 UNTIL I >= Count-1;
 FreeMem(Puf, FileSize(F));
 Close(F);
 100:
End;


{********************************************************************}
{*         PROCEDURE BGSHOWPCX                                      *}
{********************************************************************}

PROCEDURE BGShowPCX(DateiName: String; PX, PY, MX, MY:Integer; Pal:Boolean);
Var
 F: File;
 Puf: Pointer;
 P1, P2: Byte;
 Pall: array[0..767] of Byte;
 I, J, K, Count: Word;
 C, D: Byte;
 P: Byte;
 X, Y: Integer;
 Streck: Integer;
 SX, SY, EX, EY: Word;

 Label 100;
Begin
 If not FileExists(DateiName) then Goto 100;
 Assign(F, DateiName);
 Reset(f,1);
 GetMem(Puf, FileSize(f));
 Seek(F, FileSize(F)- 768);
 BlockRead(F, Pall, 768);
 If Pal Then
 Begin
  For I:= 0 to 255 do
  Begin
   SetReg(I, Pall[i* 3] div 4, Pall[i* 3+ 1] div 4, Pall[i* 3+ 2] div 4);
  End;
 End;
 Seek(F, 4);
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 SX:= P2 SHL 8 + P1;
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 SY:= P2 SHL 8 + P1;
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 EX:= P2 SHL 8 + P1;
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 EY:= P2 SHL 8 + P1;
 Seek(f,128);
 Blockread(F, Puf^, FileSize(F)- 128- 768, Count);
 I:= 0;
 K:= 0;
 X:= PX div 2;
 X:= PX;
 REPEAT
  P1:= Mem[Seg(Puf^):Ofs(puf^)+ i];
  If P1>192 THEN
  Begin
   C:= P1-192;
   D:= Mem[Seg(Puf^):Ofs(Puf^)+ i+ 1];
   Inc(i, 2);
  End
  else
  Begin
   C:= 1;
   D:= P1;
   Inc(I, 1);
  End;
  For J:= 1 to C do
  Begin
   Inc(K);
   Inc(X);
   If X > PX+ EX then
   Begin
    X:= PX;
    Inc(PY);
   End;
   If (PX+ X < 320) and (PX+ X > -1) and (PY < 200) and (PY > -1) then
    If (PX+ X < MX) and (PY < MY) then Putpixel(PX+ X, PY, D);
  End;
 UNTIL I >= Count-1;
 FreeMem(Puf, FileSize(F));
 Close(F);
 100:
End;


{********************************************************************}
{*         PROCEDURE BGSHOWPCXP                                     *}
{********************************************************************}

PROCEDURE BGShowPCXP(DateiName: String; PX, PY, MX, MY:Integer; Pal:Boolean; Pu: Word);
Var
 F: File;
 Puf: Pointer;
 P1, P2: Byte;
 Pall: array[0..767] of Byte;
 I, J, K, Count: Word;
 C, D: Byte;
 P: Byte;
 X, Y: Integer;
 Streck: Integer;
 SX, SY, EX, EY: Word;

 Label 100;
Begin
 If not FileExists(DateiName) then Goto 100;
 Assign(F, DateiName);
 Reset(f,1);
 GetMem(Puf, FileSize(f));
 Seek(F, FileSize(F)- 768);
 BlockRead(F, Pall, 768);
 If Pal Then
 Begin
  For I:= 0 to 255 do
  Begin
   SetReg(I, Pall[i* 3] div 4, Pall[i* 3+ 1] div 4, Pall[i* 3+ 2] div 4);
  End;
 End;
 Seek(F, 4);
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 SX:= P2 SHL 8 + P1;
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 SY:= P2 SHL 8 + P1;
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 EX:= P2 SHL 8 + P1;
 BlockRead(F, P1, 1);
 BlockRead(F, P2, 1);
 EY:= P2 SHL 8 + P1;
 Seek(f,128);
 Blockread(F, Puf^, FileSize(F)- 128- 768, Count);
 I:= 0;
 K:= 0;
 X:= PX div 2;
 X:= PX;
 REPEAT
  P1:= Mem[Seg(Puf^):Ofs(puf^)+ i];
  If P1>192 THEN
  Begin
   C:= P1-192;
   D:= Mem[Seg(Puf^):Ofs(Puf^)+ i+ 1];
   Inc(i, 2);
  End
  else
  Begin
   C:= 1;
   D:= P1;
   Inc(I, 1);
  End;
  For J:= 1 to C do
  Begin
   Inc(K);
   Inc(X);
   If X > PX+ EX then
   Begin
    X:= PX;
    Inc(PY);
   End;
   If (PX+ X < 320) and (PX+ X > -1) and (PY < 200) and (PY > -1) then
    If (PX+ X < MX) and (PY < MY) then PutpixelP(PX+ X, PY, D, Pu);
  End;
 UNTIL I >= Count-1;
 FreeMem(Puf, FileSize(F));
 Close(F);
 100:
End;


{####################################################################}
{####################################################################}
{####################################################################}


{********************************************************************}
{*         FUNCTION FILEEXISTS                                      *}
{********************************************************************}

FUNCTION FileExists(FileName: string): Boolean;
Var
  F: File;
begin
  {$I-}
  Assign(f, FileName);
  Reset(f);
  Close(f);
  {$I+}
  FileExists:= (IOResult = 0) and (FileName <> '');
end;


{********************************************************************}
{*         PROCEDURE SAVEPALV                                       *}
{********************************************************************}

PROCEDURE SavepalV(Var SPal : Palette);
Var
 I : Integer;
Begin
 For I := 0 to 255 do
  GetReg(I , SPal.Rot[I] , SPal.Gruen[I] , SPal.Blau[I]);
End;


{********************************************************************}
{*         PROCEDURE LOADPALV                                       *}
{********************************************************************}

PROCEDURE LoadpalV(LPal : Palette);
Var
 I : Integer;
Begin
 For I := 0 to 255 do
  SetReg(I , LPal.Rot[I] , LPal.Gruen[I] , LPal.Blau[I]);
End;


{********************************************************************}
{*         PROCEDURE SAVEPALF                                       *}
{********************************************************************}

PROCEDURE SavePalF(PalFile : String);
Var
 I : Integer;
 F : Text;
 CH : Char;
 R,G,B : Byte;

BEGIN
 {$I-}
 Assign(F, PalFile);
 Rewrite(F);
 For I := 0 to 255 do
 Begin
  Getreg(I,R,G,B);
  Write(F, Chr(R),Chr(G),Chr(B));
 End;
Close(F);
 {$I+}
End;


{********************************************************************}
{*         PROCEDURE LOADPALF                                       *}
{********************************************************************}

PROCEDURE LoadPalF(Palfile : String);
Var
 I : integer;
 Ch : char;
 F: Text;
 R,G,B : Byte;
 CS : File of Byte;
 Size : Longint;

Begin
If Fileexists(PalFile) then
 Begin
 Assign(Cs, Palfile);
 Reset(Cs);
 Size:= filesize(Cs);
 Close(CS);
 If Size = 768 then
  Begin
  assign(f,Palfile);
  reset(f);
  for i:= 0 to 255 do
   begin
   read(f,ch);
   r:= ord(ch);
   read(f,ch);
   g:= ord(ch);
   read(f,ch);
   b:= ord(ch);
   setreg(i, r,g,b);
   End;
  close(f);
  End;
 End;
End;



PROCEDURE BMPInfo(DateiName: String; Var Width, Height: Integer);
Var
 BMPFileHeader : record
  BfType     : Integer;
  BfSize     : Longint;
  BfReserved1: Integer;
  BfReserved2: Integer;
  BfOffBits  : Longint
 End;

 BMPInfoHeader : record
  BiSize         : Longint;
  BiWidth        : Longint;
  BiHeight       : Longint;
  BiPlanes       : Word;
  BiBitCount     : Word;
  BiCompression  : Longint;
  BiSizeImage    : Longint;
  BiXPelsPerMeter: Longint;
  BiYPelsPerMeter: Longint;
  BiClrUsed      : Longint;
  BiClrImportant : Longint
 End;

 F: File;
 Size: Longint;
 CH: Boolean;

 Label 100;
Begin
 Width:= 0;
 Height:= 0;
 If not FileExists(DateiName) then Goto 100;
 Assign(F, DateiName);
 Reset(F, 1);
 Size:= FileSize(F);
 BlockRead(F, BMPFileHeader, 14);
 BlockRead(F, Size, 4);
 CH:= Size= $0C;
 BMPInfoHeader.BiSize:= Size;
 BlockRead(F, BMPInfoHeader.BiWidth, $24);
 Width:= BMPInfoHeader.BiWidth;
 Height:= BMPInfoHeader.BiHeight;
 100:
End;


BEGIN
GetRomFont;
END.