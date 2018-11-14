{$a+,b-,d+,e+,f-,g+,i+,l+,n-,o-,p-,q-,r-,s+,t-,v+,x+}
{-$define cpu386}
{ Asm-version of Wormhole, by Bas van Gaalen, Holland, PD }
{
    Simulador de Campo de Estrellas.        Starfield Simulator
  -------------------------------------|----------------------------
                 Tomas Laurenzo - tlaure@lsa.lsa.com.uy
                            Montevideo - Uruguay

  DISCLAIMER: Same as usual, use it at your own risk.

  COPYRIGHT: Use it freely, just remember _I_ coded it, BTW the '*' (Big
             Bang Flower) routine will be in a demo i'm coding, and it's
             dedicated to a girl nicknamed Kash, so if you use it, name
             us in the credits, thanks. :)


  DESCRIPTION:
  This is a simple starfield simulator, with two or three simple routines
  in it, press '?' for help (if you can actually read it >;) ), or just try
  '4','5','0','+','-','*'.. i think that's all, check the code anyway.
  I do use some routines that i've collected for quite awhile.
  I think most of'em are from the SWAG files, and from the Asphyxia VGA
  Trainer by Denthor... which helped me a lot, time ago.
  Sorry, it's not fully optimized, but there are some routines that I do
  not wont to make public yet ;)

  Oh, the Big Bang flower in radar mode has a bug... some boxes appear where
  they shouldn't.. help.
  The 'speed < -2' bug is easily fixeable, but I like the 'good bye mon TV'
  effect, and if fixed, the '*' routine would disappear :)

  Any comments, suggestions, whatever, _please_ mail.

  Sal£,
    Tom.


  P.S. Sorry again, it's not very commented, the procedural names are self
       descriptive, but most of them are in spanish.
       Anyway I think the code should be easy to understand. O:)
       And please oversee my tarzan-style english ;)

^`§:;,.,;:§'^`§:;,.,;:§'^`§:;,.,;:§'^`§:;,.,;:§'^`§:;,.,;:§'^`§:;,.,;:§'^`§:;,.
}

PROGRAM Startrek;                         { Yeah, God save the enterprise! }

USES Crt;

CONST
  vidseg:word=$a000;
  divd=128;
  astep=6;
  xst=4;
  yst=5;
  CantStars = 1000;   { # of stars }
  NofPoints = 75;
  Speed = 5;
  Xc : real = 0;
  Yc : real = 0;
  Zc : real = 150;
  SinTab : array[0..255] of integer = (
    0,2,5,7,10,12,15,17,20,22,24,27,29,31,34,36,38,41,43,45,47,49,52,54,
    56,58,60,62,64,66,67,69,71,73,74,76,78,79,81,82,83,85,86,87,88,90,91,
    92,93,93,94,95,96,97,97,98,98,99,99,99,100,100,100,100,100,100,100,
    100,99,99,99,98,98,97,97,96,95,95,94,93,92,91,90,89,88,87,85,84,83,
    81,80,78,77,75,73,72,70,68,66,65,63,61,59,57,55,53,51,48,46,44,42,40,
    37,35,33,30,28,26,23,21,18,16,14,11,9,6,4,1,-1,-4,-6,-9,-11,-14,-16,
    -18,-21,-23,-26,-28,-30,-33,-35,-37,-40,-42,-44,-46,-48,-51,-53,-55,
    -57,-59,-61,-63,-65,-66,-68,-70,-72,-73,-75,-77,-78,-80,-81,-83,-84,
    -85,-87,-88,-89,-90,-91,-92,-93,-94,-95,-95,-96,-97,-97,-98,-98,-99,
    -99,-99,-100,-100,-100,-100,-100,-100,-100,-100,-99,-99,-99,-98,-98,
    -97,-97,-96,-95,-94,-93,-93,-92,-91,-90,-88,-87,-86,-85,-83,-82,-81,
    -79,-78,-76,-74,-73,-71,-69,-67,-66,-64,-62,-60,-58,-56,-54,-52,-49,
    -47,-45,-43,-41,-38,-36,-34,-31,-29,-27,-24,-22,-20,-17,-15,-12,-10,
    -7,-5,-2,0);

TYPE
  PointRec = RECORD
               X,Y,Z : integer;
             END;
  PointPos = ARRAY[0..NofPoints] OF PointRec;
  Observador = RECORD
                  X : Word;
                  Y : Word;
                  Z : Word;
               END;
  Colores  = (Blanco, Amarillo, Celeste, Violeta);
  Estrella = RECORD
                X,Y,Z : Word;
             END;
  Stars = ARRAY [0..CantStars] OF Estrella;

VAR
  x,y,i,j:word; c:byte;
  sintab2:array[0..449] of integer;
  stab,ctab:array[0..255] of integer;
  virscr:pointer;
  virseg:word;
  lstep:byte;
  Point     : PointPos;
  CosTable  : ARRAY [0..1024] of Integer;
  Color     : Colores;
  AnguloZ   : Integer;
  Vel       : ShortInt;
  Campo     : Stars;
  Tecla     : Char;
  RotoZ, Termina,
  Borro     : Boolean;
  Cola      : ARRAY [0..CantStars] OF RECORD
                                   X1,Y1,
                                   X2,Y2 : Integer;
                                  END;
CONST
  VGA = $A000;
  Obs : Observador = (X : 0; Y : 0; Z : 60);

FUNCTION Coseno(Angulo : Integer) : Integer; ASSEMBLER;
ASM
  mov ax,Seg CosTable
  mov es,ax
  mov di,Offset CosTable
  mov dx,Angulo
  shl dx,1
  add di,dx
  mov ax,es:[di]
END;

PROCEDURE Proyecta(X,Y,Z : Integer; VAR Xscr,Yscr : Word; XCentro,YCentro : Integer);
BEGIN
  IF Z >= Obs.Z THEN BEGIN
    Xscr := 319;
    Yscr := 200;
  END ELSE BEGIN
    Xscr := XCentro + ((Obs.X * Z - X * Obs.Z) DIV (Z - Obs.Z));
    Yscr := YCentro + ((Obs.Y * Z - Y * Obs.Z) DIV (Z - Obs.Z));
  END;
END;

PROCEDURE MakeCosTable;
VAR
  CntVal : Word;
  CntAng,IncDeg : Real;
BEGIN
  IncDeg := 2*PI/1024;
  CntAng := IncDeg;
  CntVal := 0;
  REPEAT
    CosTable[CntVal] := Round(255*cos(CntAng));
    CntAng := CntAng+IncDeg;
    Inc (CntVal);
  UNTIL CntVal > 1024;
END;

FUNCTION Seno(Angulo : Integer) : Integer; ASSEMBLER;
ASM
  mov ax,Seg CosTable
  mov es,ax
  mov di,Offset CosTable
  mov dx,Angulo
  mov bx,1024
  add dx,256
  cmp dx,bx
  jle @@Ok
  sub dx,1024
  @@Ok:
  shl dx,1
  add di,dx
  mov ax,es:[di]
END;

PROCEDURE Modo13h; ASSEMBLER;
ASM
  MOV AX, 13h
  INT 10h
{    MOV ah,0fh     Si se quiere que el procedimiento devuelva un errcode
     INT 10h        se le agrega esto, se cambia el proc a func : word
     XOR ah,ah      y si no devuelve 13h ($13) es que no tiene VGA }
END;

PROCEDURE ModoTexto; ASSEMBLER;
ASM
  MOV ax,03h
  INT 10h
END;

PROCEDURE Retraso; ASSEMBLER;
ASM
  mov dx,3DAh
  @@1:
  in  al,dx
  and al,08h
  jnz @@1
  @@2:
  in  al,dx
  and al,08h
  jz  @@2
  END;
{
 BEGIN
  WHILE (PORT[$3da] AND 8)<>0 DO;
  WHILE (PORT[$3da] AND 8)=0 DO;   { sta es la implementaci¢n pascal   }
{ END;}

PROCEDURE Cls(Col : Byte; Where : Word); ASSEMBLER;
ASM
  push es
  mov cx, 32000;
  mov es,[where]
  xor di,di
  mov al,[col]
  mov ah,al
  rep stosw
  pop es
END;

PROCEDURE PutDot(X,Y : Integer; Color : Byte; SegDes : Word); ASSEMBLER;
ASM
  cmp X,0
  jl  @@END
  cmp Y,0
  jl  @@END
  cmp X,319
  jg  @@END
  cmp Y,199
  jg  @@END
  mov ax,SegDes
  mov es,ax
  mov al,Color
  mov di,Y
  mov bx,X
  mov dx,di
  xchg dh,dl
  shl di,6
  add di,dx
  add di,bx
  mov es:[di],al
  @@END:
END;

PROCEDURE SeteaColor(Col,R,G,B : Byte); ASSEMBLER;
ASM
  mov dx,3c8h
  mov al,[col]
  out dx,al
  inc dx
  mov al,[r]
  out dx,al
  mov al,[g]
  out dx,al
  mov al,[b]
  out dx,al
END;

PROCEDURE GeneroPaleta(Tipo : Colores);
VAR I : Byte;
BEGIN
  SeteaColor (0,0,0,0);
  CASE Tipo OF
    Blanco   : FOR I := 1 TO 255 DO SeteaColor(I,I,I,I);
    Celeste  : FOR I := 1 TO 255 DO SeteaColor(I,64,I,I);
    Violeta  : FOR I := 1 TO 255 DO SeteaColor(I,I,64,I);
    Amarillo : FOR I := 1 TO 255 DO SeteaColor(I,I,I,64);
  END;
END;

PROCEDURE GeneroEstrellas;
VAR J,I : Integer;
BEGIN
  FOR I := 0 TO CantStars DIV 6 DO BEGIN
    Campo[I].X := Random(320)-160;
    Campo[I].Y := Random(200)-100;
    Campo[I].Z := 0;
    Cola[I].X1 := Campo[I].X;
    Cola[I].Y1 := Campo[I].Y;
    END;
    FOR I := 1 TO 5 DO FOR J := (I*CantStars DIV 6) TO (CantStars DIV 6)*(I+1)-1 DO BEGIN
      Campo[J].X := Random(320)-160;
      Campo[J].Y := Random(200)-100;
      Campo[J].Z := I*10;
      Cola[I].X1 := Campo[I].X;
      Cola[I].Y1 := Campo[I].Y;
    END;
END;

PROCEDURE EscriboEstrellas;
VAR
  I : Integer;
  X,Y : Word;
  X1,Y1,Z1,X2,Y2,Z2,Xr,Yr,Zr : Integer;
BEGIN
  CASE RotoZ OF
    True : BEGIN
             FOR I := 0 TO CantStars DO BEGIN
               X := Campo[I].X;
               Y := Campo[I].Y;
               Xr := (Coseno(AnguloZ)*X) DIV 256-(Seno(AnguloZ)*Y) DIV 256;
               Yr := (Seno(AnguloZ)*X) DIV 256+(Coseno(AnguloZ)*Y) DIV 256;
{                Campo [I].X := Xr;
                Campo [I].Y := Yr;}
               Proyecta(Xr,Yr,Campo[I].Z,X,Y,160,100);
               PutDot (X,Y,Campo[I].Z,VGA);
               Cola[I].X1 := X;
               Cola[I].Y1 := Y;
             END;
             IF AnguloZ > 1024 THEN AnguloZ := AnguloZ-1024 ELSE Inc(AnguloZ,5);
           END;
    False : BEGIN
              FOR I := 0 to CantStars DO BEGIN
                Proyecta(Campo[I].X,Campo[I].Y,Campo[I].Z,X,Y,160,100);
                PutDot(X,Y,Campo[I].Z,VGA);
                Cola[I].X1 := X;
                Cola[I].Y1 := Y;
              END;
           END;
  END;
END;

PROCEDURE BorroEstrellas;
VAR I : Integer;
BEGIN
  IF Borro THEN BEGIN
    FOR I := 0 TO CantStars DO BEGIN
      PutDot(Cola[I].X1,Cola[I].Y1,0,VGA);
      PutDot(Cola[I].X2,Cola[I].Y2,0,VGA);
    END;
    Borro := FALSE
  END ELSE Borro := True;
END;

PROCEDURE MuevoEstrellas(Creo : Boolean);
VAR I : Integer;
BEGIN
  FOR I := 0 TO CantStars DO BEGIN
    Cola[I].X2 := Cola[I].X1;
    Cola[I].Y2 := Cola[I].Y1;
    IF Vel > 0 THEN BEGIN
      IF (Cola[I].X1 > 0) AND (Cola[I].Y1 > 0) AND (Cola[I].X1 < 320) AND (Cola[I].Y1 < 200) AND (Campo[I].Z < Obs.Z)
        THEN Inc(Campo[I].Z,Vel)
      ELSE BEGIN
        IF Creo THEN BEGIN
          Campo[I].X := Random(320)-160;
          Campo[I].Y := Random(200)-100
        END ELSE BEGIN
          Campo[I].X := 3000;
          Campo[I].Y := 3000
        END;
        Campo[I].Z := 0;
      END;
    END ELSE BEGIN
      IF Campo[I].Z > 0 THEN Inc(Campo[I].Z,Vel)
    ELSE BEGIN
        IF Creo THEN BEGIN
          Campo[I].X := Random(320)-160;
          Campo[I].Y := Random(200)-100;
        END ELSE BEGIN
          Campo[I].X := 3000;
          Campo[I].Y := 3000;
        END;
        Campo[I].Z := Obs.Z+1;
      END;
    END;
  END;
END;

PROCEDURE Bouncing; { Not really, it's the Big Bang Flower }
VAR
  VT : ShortInt;
  I  : Byte;
  J  : Integer;
BEGIN
  VT := Vel;
  Vel := -1;
  FOR I := 1 TO 20 DO BEGIN
    FOR J := 0 TO CantStars DO BEGIN
      Campo[J].Z := Campo[J].Z-1;
    END;
    EscriboEstrellas;
  END;
  Vel := VT;
END;

PROCEDURE Lluvia;  { Rain }
VAR
  J,I : Integer;
  Pant : ARRAY[0..CantStars] OF RECORD X,Y,Z : Word; END;
FUNCTION HayPant : BOOLEAN;
VAR I : Integer; Hay : Boolean;
BEGIN
  Hay := False;
  FOR I := 0 to CantStars DO IF Pant[I].Y < 200 THEN Hay := True;
  HayPant := Hay;
END;

PROCEDURE EscriboPant;
VAR I : Integer;
BEGIN
  FOR I := 0 TO CantStars DO PutDot(Pant[I].X,Pant[I].Y,Pant[I].Z,VGA);
END;

PROCEDURE MuevoPant;
VAR I : Integer;
BEGIN
  FOR I := 0 TO CantStars DO IF Pant[I].Z > 10 THEN Pant[I].Y := Pant[I].Y+Pant[I].Z DIV 8
    ELSE Pant[I].Y := Pant[I].Y+1;
END;

PROCEDURE BorroPant(Inc : ShortInt);
VAR I : Integer;
BEGIN FOR I := 0 TO CantStars DO PutDot(Pant[I].X,Pant[I].Y+Inc,0,VGA); END;
BEGIN
  Cls(0,VGA);
  FOR I := 0 TO CantStars DO BEGIN
    Proyecta(Campo[I].X,Campo[I].Y,Campo[I].Z,Pant[I].X,Pant[I].Y,160,100);
    Pant[I].Z := Campo[I].Z;
  END;
  WHILE HayPant DO BEGIN
    EscriboPant;
    Retraso;
    BorroPant(0);
    MuevoPant;
  END;
END;

PROCEDURE Help;
PROCEDURE Escribo(S : STRING; Salto : Boolean);
VAR I : Byte;
BEGIN
  GotoXY(40-Length(S) DIV 2,WhereY);
  FOR I := 1 TO Length(S) DO BEGIN
    TextColor (Random (15)+1);
    Write (S[I]);
  END;
  IF Salto THEN WriteLn;
END;
PROCEDURE Apagacursor; ASSEMBLER;  { Sets the cursor off }
ASM
  MOV AH, 02h
  MOV BH, 0
  MOV DH, 80
  MOV DL, 25
  INT 10h
END;
BEGIN
  ModoTexto;
  REPEAT
    ClrScr;
    Escribo('Simulador de Campo de Estrellas',True);
    Escribo('(Starfield Simulator)',True);
    Escribo('---------------------------------',True);
    Escribo('1996 ú Tomas Laurenzo ú tlaure@lsa.lsa.com.uy',True);
    WriteLn;
    Escribo('Teclas (keys):',True);
    WriteLn;
    Escribo(' ? : Esta pantalla          ú This screen     ',True);
    Escribo(' + : Aumenta la velocidad   ú Increases speed ',True);
    Escribo(' - : Disminuye la velocidad ú Decreases speed ',True);
    Escribo(' 0 : Rota los colores       ú Rotate colors   ',True);
    Escribo(' 1 : Lluvia                 ú Rain            ',True);
    Escribo(' 5 : Modo radar             ú Radar mode      ',True);
    Escribo(' 4 : Modo normal            ú Normal mode     ',True);
    Escribo('  spc : Rebote                 ú Bounce             ',True);
    Escribo(' * : Flor de Big Bang ;)   ú Big Bang Flower',True);
    WriteLn;
    Escribo('Archivos (files):',True);
    Escribo('CAMPO.EXE | CAMPO.TXT',True);
    WriteLn;
    Escribo('Tomas Laurenzo ú tlaure@lsa.lsa.com.uy ú Montevideo - Uruguay',True);
    WriteLn;   Escribo (' IF Speed < -1 THEN Quite_A_Bug (ON)  a.k.a.  Good Bye mon T.V.',True);
    WriteLn;
    Escribo('^`§:;,.,;:§''^`§:;,.,;:§''^`§:;,.,;:§''^`§:;,.,;:§''^`§:;,.,;:§''^`§:;,.,;:§''^`§:;,.',False);
    ApagaCursor;
    Delay(500);
  UNTIL keypressed;
  ReadKey;
  Modo13h;
  GeneroPaleta (Color);
END;

{----------------------------------------------------------------------------}

procedure SetGraphics(Mode : byte); assembler;
asm mov AH,0; mov AL,Mode; int 10h; end;

procedure Init;

var
  I : byte;

begin
  randomize;
  for I := 0 to NofPoints do begin
    Point[I].X := random(250)-125;
    Point[I].Y := random(250)-125;
    Point[I].Z := random(250)-125;
  end;
end;

procedure DoRotation;

const
  Xstep = 1;
  Ystep = 1;
  Zstep = -2;

var
  Xp,Yp : array[0..NofPoints] of word;
  X,Y,Z,X1,Y1,Z1 : real;
  PhiX,PhiY,PhiZ : byte;
  I,Color : byte;

function Sinus(Idx : byte) : real;

begin
  Sinus := SinTab[Idx]/100;
end;

function Cosinus(Idx : byte) : real;

begin
  Cosinus := SinTab[(Idx+192) mod 255]/100;
end;

begin
  PhiX := 0; PhiY := 0; PhiZ := 0;
  repeat
    while (port[$3da] and 8) <> 8 do;
    while (port[$3da] and 8) = 8 do;
    for I := 0 to NofPoints do begin

      if (Xp[I]+160 < 320) and (Yp[I]+100 < 200) then
        mem[$a000:(Yp[I]+100)*320+Xp[I]+160] := 0;

      X1 := Cosinus(PhiY)*Point[I].X-Sinus(PhiY)*Point[I].Z;
      Z1 := Sinus(PhiY)*Point[I].X+Cosinus(PhiY)*Point[I].Z;
      X := Cosinus(PhiZ)*X1+Sinus(PhiZ)*Point[I].Y;
      Y1 := Cosinus(PhiZ)*Point[I].Y-Sinus(PhiZ)*X1;
      Z := Cosinus(PhiX)*Z1-Sinus(PhiX)*Y1;
      Y := Sinus(PhiX)*Z1+Cosinus(PhiX)*Y1;

      Xp[I] := round((Xc*Z-X*Zc)/(Z-Zc));
      Yp[I] := round((Yc*Z-Y*Zc)/(Z-Zc));
      if (Xp[I]+160 < 320) and (Yp[I]+100 < 200) then begin
        Color := 31+round(Z/7);
        if Color > 31 then Color := 31
        else if Color < 16 then Color := 16;
        mem[$a000:(Yp[I]+100)*320+Xp[I]+160] := Color;
      end;

      inc(Point[I].Z,Speed); if Point[I].Z > 125 then Point[I].Z := -125;
    end;
    inc(PhiX,Xstep);
    inc(PhiY,Ystep);
    inc(PhiZ,Zstep);
  until keypressed;
end;

{----------------------------------------------------------------------------}

procedure setpal(col,r,g,b : byte); assembler;
asm
  mov dx,03c8h
  mov al,col
  out dx,al
  inc dx
  mov al,r
  out dx,al
  mov al,g
  out dx,al
  mov al,b
  out dx,al
end;

procedure drawpolar(xo,yo,r,a:word; c:byte; lvseg:word); assembler;
asm
  mov es,lvseg

  mov bx,a
  add bx,a
  mov cx,word ptr sintab[bx]
  add bx,2*90
  mov ax,word ptr sintab[bx]
  mul r
  mov bx,divd
  xor dx,dx
  cwd
  idiv bx
  add ax,xo
  add ax,160
  cmp ax,320
  ja @out
  mov si,ax

  mov ax,cx
  mul r
  mov bx,divd
  xor dx,dx
  cwd
  idiv bx
  add ax,yo
  add ax,100
  cmp ax,200
  ja @out

  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  add di,si
  mov al,c
  mov [es:di],al
 @out:
end;

procedure cls2(lvseg:word); assembler;
asm
  mov es,[lvseg]
  xor di,di
  xor ax,ax
{$ifdef cpu386}
  mov cx,320*200/4
  rep
  db $66; stosw
{$else}
  mov cx,320*200/2
  rep stosw
{$endif}
end;

procedure flip(src,dst:word); assembler;
asm
  push ds
  mov ax,[dst]
  mov es,ax
  mov ax,[src]
  mov ds,ax
  xor si,si
  xor di,di
{$ifdef cpu386}
  mov cx,320*200/4
  rep
  db $66; movsw
{$else}
  mov cx,320*200/2
  rep movsw
{$endif}
  pop ds
end;

procedure retrace; assembler;
asm
  mov dx,03dah
 @vert1:
  in al,dx
  test al,8
  jnz @vert1
 @vert2:
  in al,dx
  test al,8
  jz @vert2
end;

{----------------------------------------------------------------------------}

BEGIN
  IF ParamStr(1) = '0' THEN BEGIN
    Randomize;
    MakeCosTable;
    GeneroEstrellas;
    AnguloZ := 0;
    Modo13h;
    GeneroPaleta(Blanco);
    Cls(0,VGA);
    Borro := False;
    Vel := 1;
    Termina := False;
    REPEAT
      EscriboEstrellas;
      Retraso;
      BorroEstrellas;
      MuevoEstrellas(True);
      IF KeyPressed THEN BEGIN
        Tecla := ReadKey;
        CASE Tecla OF
          '?' : Help;
          '+' : Inc (Vel);
          '-' : Dec (Vel);
          '0' : BEGIN
                  IF Color = Violeta THEN Color := Blanco ELSE Inc(Color);
                  GeneroPaleta(Color)
                END;
          '1' : Lluvia;
          '5' : RotoZ := True;
          '4' : RotoZ := False;
          ' ' : Vel := -Vel;
          '*' : BEGIN
                  WHILE NOT KEYPRESSED DO Bouncing;
                  Cls(0,VGA);
                  ReadKey;
                END;
          ELSE Termina := True;
        END;
      END;
    UNTIL Termina;
    IF Vel <> 0 THEN FOR I := 0 TO 50 DIV Abs(Vel) DO BEGIN
      EscriboEstrellas;
      Retraso;
      BorroEstrellas;
      MuevoEstrellas(False);
    END;
    {ModoTexto;}
  END ELSE IF ParamStr(1) = '1' THEN BEGIN
    SetGraphics($13);
    Init;
    DoRotation;
  END ELSE BEGIN
    ASM mov ax,13h; int 10h; END;
    FOR i := 0 to 255 DO BEGIN
      ctab[i] := Round(Cos(pi*i/128)*60);
      stab[i] := Round(Sin(pi*i/128)*45);
    END;
    FOR i := 0 TO 449 DO sintab2[i] := Round(Sin(2*pi*i/360)*divd);
    GetMem(virscr,64000);
    virseg := Seg(virscr^);
    cls2(virseg);
    x := 30; y := 90;
    REPEAT
      retrace;
      c := 22; lstep := 2; j := 10;
      WHILE j<220 DO BEGIN
        i := 0;
        WHILE i<360 DO BEGIN
          drawpolar(ctab[(x+(200-j)) MOD 255],stab[(y+(200-j)) MOD 255],j,i,c,virseg);
          Inc(i,astep);
        END;
        Inc(j,lstep);
        IF (j MOD 5) = 0 THEN BEGIN Inc(lstep); Inc(c); IF c>31 THEN c := 22; END;
      end;
      x := xst+x MOD 255;
      y := yst+y MOD 255;
      flip(virseg,vidseg);
      cls2(virseg);
    UNTIL KeyPressed;
    FreeMem(virscr,64000);
  END;
END.

