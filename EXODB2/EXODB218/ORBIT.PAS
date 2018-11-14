PROGRAM Modul_Orbit;

USES Crt,Dos,Graph,Arithmos,RT_Watch,BGI2PRN;

CONST
  bmphead :array[1..118] of byte =
  { BM } (66,77,
          118,
          8,
          0,
          0,0,0,0,0,
          118,0,0,0,40,
          0,0,0,
  { br }  128,2,         { (2x256)+128 = 640 pixels }
          0,0,
  { ho }  224,1,         { (1x256)+224 = 480 pixels }
          0,0,1,0,4,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   { 0}   0,0,0,0,
   { 1}   170,0,0,0,
   { 2}   0,170,0,0,
   { 3}   170,170,0,0,
   { 4}   0,0,170,0,
   { 5}   170,0,170,0,
   { 6}   0,85,170,0,
   { 7}   170,170,170,0,
   { 8}   85,85,85,0,
   { 9}   255,0,0,0,
   {10}   0,255,0,0,
   {11}   255,255,0,0,
   {12}   0,0,255,0,
   {13}   255,0,255,0,
   {14}   0,255,255,0,
   {15}   255,255,255,0);

VAR
  Fil             : ARRAY[0..20] OF STRING;
  HZ              : Byte;
  Input           : Char;
  Control,i,
  grDriver,grMode : Integer;
  a,p,e,b,c,
  Luminosity,
  Numb,Zoom,mx,my : Real;
  regs            : Registers;
  TempStr         : STRING;
  f,f2            : Text;
  SemiMajorAxis2,
  Eccentricity2,
  CentralStar,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Method,
  PlanetName,
  {Remarks1,
  Remarks2,}
  SpectralType    : ARRAY[0..20] OF STRING;
  Deklination,
  Distance,
  Eccentricity,
  Magnitude,
  Metalicity,
  Period,
  PlanetMass,
  Rectaszension,
  SemiMajorAxis,
  StarMass        : ARRAY[0..20] OF Real;

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
  FileHandle : text;
BEGIN
  Assign(FileHandle,FileName);
  GetFAttr(FileHandle,FileAttr);
  IF (FileAttr AND ReadOnly) <> 0 THEN SetFAttr(FileHandle,FileAttr AND (NOT ReadOnly));
  Erase(FileHandle);
  DeleteFile := (IOResult=0);
END;

FUNCTION Power(variable,exponent : Real) : Real;
BEGIN
  IF (variable <= 0.0) THEN Power := 0.0 ELSE Power := Exp(exponent * Ln(variable));
END;


PROCEDURE LoadImage(X1,Y1 : Integer; FileName :STRING);
VAR
 F          : FILE;
 PointImage : Pointer;
 Size       : Word;
BEGIN
  Assign(f,FileName);
  {$I-} Reset(F,1); {$I+}
  IF IOResult = 0 THEN BEGIN
    Size := FileSize(f);
    GetMem(PointImage,Size);
    BlockRead(F,PointImage^,Size);
    PutImage(X1,Y1,PointImage^,CopyPut);
    FreeMem(PointImage,Size);
    Close(F);
  END;
END;

PROCEDURE SaveImage(X1,Y1,X2,Y2 : Integer; FileName : STRING);
VAR
  F          : FILE;
  PointImage : Pointer;
  Size       : Word;
BEGIN
  Assign(F,FileName);
  Size := ImageSize(X1,Y1,X2,Y2);
  Rewrite(F,Size);
  GetMem(PointImage,Size);
  GetImage(X1,Y1,X2,Y2,PointImage^);
  BlockWrite(F,PointImage^,1);
  FreeMem(PointImage,Size);
  Close(F);
END;

PROCEDURE Ellipse(mxe,mye,xa,xb,Color : Integer);
VAR
  e,mx1,mx2,my1,my2,
  l1,l2,l3,l4         : Integer;
  aq,bq,dx,dy,r,rx,ry : LongInt;
BEGIN
  l1 := mxe+xa;
  l2 := mxe-xa;
  l3 := mye;
  PutPixel(l1,l3,Color);
  PutPixel(l2,l3,Color);
  mx1 := mxe-xa; my1 := mye;
  mx2 := mxe+xa; my2 := mye;
  aq := Longint(xa)*xa;
  bq := Longint(xb)*xb;
  dx := aq SHL 1;
  dy := bq SHL 1;
  r  := xa*bq;
  rx := r SHL 1;
  ry := 0;
  e  := xa;
  WHILE e > 0 DO BEGIN
    IF r > 0 THEN BEGIN
      Inc(my1);
      Dec(my2);
      Inc(ry,dx);
      Dec(r,ry);
    END;
    IF r <= 0 THEN BEGIN
      Dec(e);
      Inc(mx1);
      Dec(mx2);
      Dec(rx,dy);
      Inc(r,rx);
    END;
    l1 := mx1;
    l2 := mx2;
    l3 := my1;
    l4 := my2;
    PutPixel(l1,l3,Color);
    PutPixel(l1,l4,Color);
    PutPixel(l2,l3,Color);
    PutPixel(l2,l4,Color);
  END;
END;

PROCEDURE GetRGB(Color : Integer; VAR r,g,b : Integer);
BEGIN
  r := (((Color AND $20) SHR 5) OR ((Color AND $04) SHR 1))*84;
  g := (((Color AND $10) SHR 4) OR ((Color AND $02)      ))*84;
  b := (((Color AND $08) SHR 3) OR ((Color AND $01) SHL 1))*84;
END;

PROCEDURE SavePCX(Filename : STRING);
TYPE HeaderRec = RECORD
           pcx_id  : Byte;     { 0) 0x0a = ZSoft .PCX file          }
           pcx_ver : Byte;     { 1) 0x05 = PC PaintBrush 3.0        }
           encode  : Byte;     { 2) 0x01 = RLE                      }
           bpp     : Byte;     { 3) 0x01 = bits/pixel why VGA16=1?  }
           left    : Word;     { 4-5) Window Left                   }
           top     : Word;     { 6-7) Window Top                    }
           right   : Word;     { 8-9) Window Right                  }
           bott    : Word;     { 10-11) Window Bottom               }
           xres    : Word;     { 12-13) Horizontal resolution       }
           yres    : Word;     { 14-15) Vertical resolution         }
           rgb     : ARRAY[0..15,1..3] OF Byte;    { (R-G-B) values }
           resv    : Byte;     { 64) Reserved                       }
           bplanes : Byte;     { 65) Number of bit planes, VGA16=4  }
           bpl     : Word;     { 66-67) # of bytes/line, VGA16=80   }
           ptype   : Word;     { 68-69) palette type, color=1       }
           unused  : ARRAY[70..127] OF Byte;
     END;
CONST BufSize = 256;
VAR
  Header : HeaderRec;
  pal    : PaletteType;
  r,g,b  : Integer;
  i,y,j  : Integer;
  f      : FILE;
  data   : ARRAY[0..319] OF Byte;
  buf    : ARRAY[1..BufSize] OF Byte;
  bi     : Integer;
  dta    : Byte;
  index  : Integer;
  count  : Integer;
LABEL Done;
PROCEDURE FlushIt;
BEGIN
  BlockWrite(f,buf,bi);
  bi := 0;
END;
PROCEDURE GetBitplaneInfoAtScanLine(plane,scanline : Word; VAR address);
BEGIN
  ASM
    cld
    mov bx,ds
    mov ax,0a000h
    mov ds,ax
    mov ax,80
    mul scanline
    mov si,ax
    mov dx,03ceh
    mov ax,0005h
    out dx,ax
    mov ax,plane
    mov ah,al
    mov al,04h
    out dx,ax
    mov cx,40
    les di,address
    rep movsw
    mov ax,1005h
    out dx,ax
    mov ax,0004h
    out dx,ax
    mov ds,bx
  END;
END;
BEGIN
  IF Filename = '' THEN Exit;
  FillChar(Header,SizeOf(Header),#0);
  WITH Header DO BEGIN
    pcx_id  := $0A;
    pcx_ver := $05;
    encode  := $01;
    bpp     := $01;
    left    := 0;
    top     := 0;
    right   := 639;
    bott    := 479;
    xres    := 640;
    yres    := 480;
    GetPalette(pal);
    FOR i := 0 TO 15 DO BEGIN
      GetRGB(pal.colors[i],r,g,b);
      rgb[i,1] := r;
      rgb[i,2] := g;
      rgb[i,3] := b;
    END;
    bplanes :=  4;
    bpl     := 80;
    ptype   :=  1;
  END;
  Assign(f,filename);
  {$i-} Rewrite(f,1); {$i+}
  IF IOResult <> 0 THEN Exit;
  BlockWrite(f,Header,SizeOf(Header));
  bi := 0;
  FOR y := 0 TO 479 DO BEGIN
    GetBitplaneInfoAtScanLine(0,y,data[0]);
    GetBitplaneInfoAtScanLine(1,y,data[80]);
    GetBitplaneInfoAtScanLine(2,y,data[160]);
    GetBitplaneInfoAtScanLine(3,y,data[240]);
    Index := 0;
    REPEAT
      count := 0;
      dta := data[index];
      REPEAT
        Inc(index);
        Inc(count);
        IF count > $3F THEN BEGIN
          IF bi = BufSize THEN FlushIt; Inc(bi); buf[bi] := $FF;
          IF bi = BufSize THEN FlushIt; Inc(bi); buf[bi] := dta;
          count := 1;
        END;
      UNTIL (index > 319) OR (data[index] <> dta);
      Done:
      IF count > 1 THEN BEGIN
        IF bi = BufSize THEN FlushIt; Inc(bi); buf[bi] := $C0 or count;
        IF bi = BufSize THEN FlushIt; Inc(bi); buf[bi] := dta;
      END ELSE BEGIN
        IF (dta AND $C0) = $C0 THEN BEGIN
          IF bi = BufSize THEN FlushIt; Inc(bi); buf[bi] := $C1;
          IF bi = BufSize THEN FlushIt; Inc(bi); buf[bi] := dta;
        END ELSE BEGIN
          IF bi = BufSize THEN flushIt; Inc(bi); buf[bi] := dta;
        END;
      END;
    UNTIL Index = 320;
  END;
  IF bi > 0 THEN FlushIt;
  Close(f);
END;

PROCEDURE SaveBMP(Filename : STRING);
VAR
  f        : FILE;
  x,y,p    : Integer;
  r,rr,pal : Byte;
BEGIN
  Assign(f,Filename+'.BMP');
  Rewrite(f,1);
  FOR p := 1 TO 118 DO BlockWrite(f,Bmphead[p],1);
  FOR y := 479 DOWNTO 0 DO BEGIN
    FOR x := 0 TO 639 DO BEGIN
      r   := GetPixel(x,y);
      rr  := GetPixel(x+1,y);
      pal := (r*16)+rr;
      BlockWrite(f,pal,1);
      Inc(x);
    END;
  END;
  Close(f);
END;

PROCEDURE SearchDir(Path : PathStr; fspec : STRING);
VAR
  f : SearchRec;
BEGIN
  FindFirst(Path+fspec,AnyFile,f);
  WHILE DosError = 0 DO BEGIN
    Assign(f2,'exo\'+f.name);
    Reset(f2);
    ReadLn(f2,Centralstar[0]);
    ReadLn(f2,SpectralType[0]);
    ReadLn(f2,Magnitude[0]);
    ReadLn(f2,StarMass[0]);
    ReadLn(f2,Metalicity[0]);
    ReadLn(f2,Distance[0]);
    ReadLn(f2,Rectaszension[0]);
    ReadLn(f2,Deklination[0]);
    ReadLn(f2,Constellation[0]);
    ReadLn(f2,PlanetName[0]);
    ReadLn(f2,PlanetMass[0]);
    ReadLn(f2,SemiMajorAxis[0]);
    ReadLn(f2,Period[0]);
    ReadLn(f2,Eccentricity[0]);
    ReadLn(f2,Method[0]);
    ReadLn(f2,DiscoveryDate[0]);
    ReadLn(f2,Discoverer[0]);
    {Notizen, Kommentare usw. werden nicht mitgelesen!!!}
    {ReadLn(f2,Remarks[0]);}
    Close(f2);
    a := SemiMajorAxis[0]*(149.6);
    e := Eccentricity[0];
    b := a*Sqrt(1-Sqr(e));
    c := (a*e);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightBlue);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom-1),Round(b*Zoom-1),LightBlue);
    Findnext(f);
  END;
END;

PROCEDURE SearchDir2(Path : PathStr; fspec : STRING);
VAR
  f : SearchRec;
  w : word;
  w2 : STRING;
BEGIN
  IF NOT(DirExists('ORBIT')) THEN MkDir('ORBIT');
  FindFirst(Path+fspec,AnyFile,f);
  WHILE DosError = 0 DO BEGIN
    Assign(f2,'exo\'+f.name);
    Reset(f2);
    ReadLn(f2,Centralstar[0]);
    ReadLn(f2,SpectralType[0]);
    ReadLn(f2,Magnitude[0]);
    ReadLn(f2,StarMass[0]);
    ReadLn(f2,Metalicity[0]);
    ReadLn(f2,Distance[0]);
    ReadLn(f2,Rectaszension[0]);
    ReadLn(f2,Deklination[0]);
    ReadLn(f2,Constellation[0]);
    ReadLn(f2,PlanetName[0]);
    ReadLn(f2,PlanetMass[0]);
    ReadLn(f2,SemiMajorAxis[0]);
    ReadLn(f2,Period[0]);
    ReadLn(f2,Eccentricity[0]);
    ReadLn(f2,Method[0]);
    ReadLn(f2,DiscoveryDate[0]);
    ReadLn(f2,Discoverer[0]);
    {Notizen, Kommentare usw. werden nicht mitgelesen!!!}
    {ReadLn(f2,Remarks[0]);}
    Close(f2);
    a := SemiMajorAxis[0]*(149.6);
    e := Eccentricity[0];
    b := a*Sqrt(1-Sqr(e));
    c := (a*e);
    SetFillStyle(SolidFill,White);
    Bar(0,0,640,480);
    PutPixel(320-1+Trunc(mx),240+Trunc(my),Black);
    PutPixel(320+Trunc(mx),240-1+Trunc(my),Black);
    PutPixel(320+1+Trunc(mx),240+Trunc(my),Black);
    PutPixel(320+Trunc(mx),240+1+Trunc(my),Black);
    PutPixel(320+Trunc(mx),240+Trunc(my),Black);
    SetColor(Black);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightBlue);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom-1),Round(b*Zoom-1),LightBlue);
    IF (Round(Numb) = 1) AND (HZ = 1) THEN BEGIN
      IF (StarMass[0] < 1.0) THEN Luminosity := 1.75*(StarMass[0]-0.1)+3.325 ELSE Luminosity := 0.5*(2.0-StarMass[0])+4.4;
      Luminosity := Power(StarMass[0],Luminosity);
      {Ñu·erer Rand der HZ}
      Ellipse(320+Trunc(mx),240+Trunc(my),Round(1.1*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom),
      Round(1.1*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom),Green);
      {innerer Rand der HZ}
      Ellipse(320+Trunc(mx),240+Trunc(my),Round(0.93*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom),
      Round(0.93*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom),Green);
      IF (Round(1.1*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom))-(Round(0.93*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom)) > 1 THEN BEGIN
        SetFillStyle(SolidFill,LightGreen);
        FloodFill(320+Round(0.93*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom)+1+Trunc(mx),240+Trunc(my),Green);
        FloodFill(320-Round(0.93*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom)-1+Trunc(mx),240+Trunc(my),Green);
      END;
    END;
    a := SemiMajorAxis[0]*(149.6);
    e := Eccentricity[0];
    b := a*Sqrt(1-Sqr(e));
    c := (a*e);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightBlue);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom-1),Round(b*Zoom-1),LightBlue);
    SetColor(Red);
    IF Zoom < 25/100 THEN SetTextStyle(2,HorizDir,2) ELSE SetTextStyle(2,HorizDir,4);
    OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),Planetname[0]);
    SetFillStyle(SolidFill,White);
    SetTextStyle(2,0,5);
    SetColor(Green);
    OutTextXY(5,440,'Bahnorbit: ');
    {SetColor(Blue);
    IF i = 1 THEN OutTextXY(80,410,Centralstar[0]);}
    SetColor(LightRed);
    Str(SemiMajorAxis[0]:0:3,SemiMajorAxis2[0]);
    Str(Eccentricity[0]:0:3,Eccentricity2[0]);
    OutTextXY(5,460,PlanetName[0]+': '+SemiMajorAxis2[0]+' AE - ecc '+Eccentricity2[0]);
    SetColor(Black);
    IF Zoom < 25/100 THEN SetTextStyle(2,HorizDir,2) ELSE SetTextStyle(2,HorizDir,4);
    {Merkur}
    a := 0.387*(149.6);
    e := 0.205;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(11.868);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Merkur');
    {Venus}
    a := 0.723*(149.6);
    e := 0.0067;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(0.724);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Venus');
    {Erde}
    a := 1.00*(149.6);
    e := 0.0167;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(2.498);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Erde');
    {Mars}
    a := 1.523*(149.6);
    e := 0.093;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(21.189);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Mars');
    {Jupiter}
    a := 5.203*(149.6);
    e := 0.048;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(37.362);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Jupiter');
    {Saturn}
    a := 9.55*(149.6);
    e := 0.05;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(71.434);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Saturn');
    {Uranus}
    a := 19.2*(149.6);
    e := 0.04;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(114.893);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Uranus');
    {Neptun}
    a := 30.1*(149.6);
    e := 0.01;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(45.029);
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Neptun');
    {Pluto}
    a := 39.5*(149.6);
    e := 0.25;
    b := a*Sqrt(1-Sqr(e));
    c := (a-b)*(9.875);{!!!}
    Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
    OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Pluto');
    SetColor(Cyan);
    SetTextStyle(2,0,4);
    OutTextXY(10,2,'(C) 1995-2006 EXODB2 1.8 * Michael Johne * http://www.exodb.de.vu');
    Inc(w);
    Str(w,w2);
    Fil[0] := '';
    FOR i := 1 TO Length(f.name)-4 DO BEGIN
      Fil[0] := Fil[0]+f.name[i];
    END;
    SavePCX('ORBIT/'+Fil[0]+'.PCX');
    Findnext(f);
  END;
END;

BEGIN
  TextBackground(Black);
  TextColor(White);
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF ParamStr(1) = '' THEN BEGIN
    ClrScr;
    WriteLn(^j^j'Der Parameter als Anzahl der darzustellende DatensÑtze fehlt!');
    WriteLn('    -  ORBIT.EXE [anzahl] [dateiname] [zoom]');
    WriteLn(^j'Achten Sie darauf, dass die DatensÑtze im Verzeichnis "EXO"');
    WriteLn('des Hauptverzeichis liegen.');
    ReadKey;
    Halt;
  END ELSE BEGIN
    IF ParamStr(1) = 'all' THEN BEGIN
      {do nothing}
    END ELSE BEGIN
      Val(ParamStr(1),Numb,Control);
      IF (Control <> 0) OR (Numb=0) THEN BEGIN
        ClrScr;
        WriteLn(^j^j'Der eingegebene Zahlenwert ',ParamStr(1),' ist ungÅltig.');
        WriteLn('Es sind alle Zahlen von 1 bis x erlebt; je nachdem wieviel');
        WriteLn('DatensÑtze vorliegen Im Verzeichnis "EXO" vorliegen.');
        ReadKey;
        Halt;
      END;
    END;
    IF ParamStr(2) = '' THEN BEGIN
      ClrScr;
      WriteLn(^j^j'Der Parameter fehlt! Aufruf des Datenansatz ohne [.EXO]:');
      WriteLn('    -  ORBIT.EXE [dateiname] [zoom]');
      WriteLn(^j'Achten Sie darauf, dass die DatensÑtze im Verzeichnis "EXO"');
      WriteLn('des Hauptverzeichis liegen.');
      ReadKey;
    END ELSE BEGIN
      FOR i := 1 TO Round(Numb) DO BEGIN
        IF NOT(FileExists('exo\'+ParamStr(1+i)+'.EXO')) THEN BEGIN
          ClrScr;
          WriteLn(^j^j'Die Datei "','exo\'+ParamStr(1+i)+'.EXO','" wurde nicht gefunden!');
          WriteLn(^j'Achten Sie darauf, dass die DatensÑtze im Verzeichnis "EXO"');
          WriteLn('des Hauptverzeichis liegen.');
          ReadKey;
          Halt;
        END;
      END;
      Val(ParamStr(2+Round(Numb)),Zoom,Control);
      IF Control <> 0 THEN BEGIN
        Zoom := 100;
        ClrScr;
        WriteLn(^j^j'Der eingegebene Zoom-Wert ',ParamStr(2+Round(Numb)),' ist ungÅltig.');
        WriteLn('Folgende Beispielwerte sind erlaubt: 100.0; 70.32; 25.32432...; etc.');
        WriteLn(^j'Als Stanardwert fÅr Zoom wird nun 100 genommen.');
        ReadKey;
      END;
      Val(ParamStr(3+Round(Numb)),mx,Control);
      IF Control <> 0 THEN BEGIN
        mx := 0;
        ClrScr;
        WriteLn(^j^j'Der eingegebene MX-Wert ',ParamStr(3+Round(Numb)),' ist ungÅltig.');
        WriteLn('Folgende Beispielwerte sind erlaubt: 100; -70; 25,...; etc.');
        WriteLn(^j'Als Stanardwert fÅr MX wird nun 0 genommen.');
        ReadKey;
      END;
      Val(ParamStr(4+Round(Numb)),my,Control);
      IF Control <> 0 THEN BEGIN
        my := 0;
        ClrScr;
        WriteLn(^j^j'Der eingegebene MY-Wert ',ParamStr(4+Round(Numb)),' ist ungÅltig.');
        WriteLn('Folgende Beispielwerte sind erlaubt: 100; -70; 25,...; etc.');
        WriteLn(^j'Als Stanardwert fÅr MY wird nun 0 genommen.');
        ReadKey;
      END;
      Val(ParamStr(5+Round(Numb)),HZ,Control);
      Zoom := Zoom/100;
      grDriver := Detect;
      InitGraph(grDriver,grMode,'');
      SetFillStyle(SolidFill,White);
      Bar(0,0,640,480);
      PutPixel(320-1+Trunc(mx),240+Trunc(my),Black);
      PutPixel(320+Trunc(mx),240-1+Trunc(my),Black);
      PutPixel(320+1+Trunc(mx),240+Trunc(my),Black);
      PutPixel(320+Trunc(mx),240+1+Trunc(my),Black);
      PutPixel(320+Trunc(mx),240+Trunc(my),Black);
      SetColor(Black);
      {Exoplanet}
      IF ParamStr(1) = 'all' THEN BEGIN
          SearchDir('exo\','*.exo');
      END ELSE FOR i := 1 TO Round(Numb) DO BEGIN
        SetFillStyle(SolidFill,White);
        SetTextStyle(2,0,5);
        Assign(f,'exo\'+ParamStr(1+i)+'.EXO');
        Reset(f);
        ReadLn(f,Centralstar[0]);
        ReadLn(f,SpectralType[0]);
        ReadLn(f,Magnitude[0]);
        ReadLn(f,StarMass[0]);
        ReadLn(f,Metalicity[0]);
        ReadLn(f,Distance[0]);
        ReadLn(f,Rectaszension[0]);
        ReadLn(f,Deklination[0]);
        ReadLn(f,Constellation[0]);
        ReadLn(f,PlanetName[0]);
        ReadLn(f,PlanetMass[0]);
        ReadLn(f,SemiMajorAxis[0]);
        ReadLn(f,Period[0]);
        ReadLn(f,Eccentricity[0]);
        ReadLn(f,Method[0]);
        ReadLn(f,DiscoveryDate[0]);
        ReadLn(f,Discoverer[0]);
        {Notizen, Kommentare usw. werden nicht mitgelesen!!!}
        {ReadLn(f,Remarks[0]);}
        Close(f);
        IF (Round(Numb) = 1) AND (HZ = 1) THEN BEGIN
          IF (StarMass[0] < 1.0) THEN Luminosity := 1.75*(StarMass[0]-0.1)+3.325 ELSE Luminosity := 0.5*(2.0-StarMass[0])+4.4;
          Luminosity := Power(StarMass[0],Luminosity);
          {Ñu·erer Rand der HZ}
          Ellipse(320+Trunc(mx),240+Trunc(my),Round(1.1*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom),
            Round(1.1*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom),Green);
          {innerer Rand der HZ}
          Ellipse(320+Trunc(mx),240+Trunc(my),Round(0.93*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom),
            Round(0.93*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom),Green);
          IF (Round(1.1*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom))-(Round(0.93*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom)) > 1 THEN BEGIN
            SetFillStyle(SolidFill,LightGreen);
            FloodFill(320+Round(0.93*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom)+1+Trunc(mx),240+Trunc(my),Green);
            FloodFill(320-Round(0.93*(Sqrt(Luminosity)+0.5)*(149.6)*Zoom)-1+Trunc(mx),240+Trunc(my),Green);
          END;
        END;
        a := SemiMajorAxis[0]*(149.6);
        e := Eccentricity[0];
        b := a*Sqrt(1-Sqr(e));
        c := (a*e);
        Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightBlue);
        Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom-1),Round(b*Zoom-1),LightBlue);
        SetColor(Red);
        IF Zoom < 25/100 THEN SetTextStyle(2,HorizDir,2) ELSE SetTextStyle(2,HorizDir,4);
        OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),Planetname[0]);
        SetFillStyle(SolidFill,White);
        SetTextStyle(2,0,5);
        SetColor(Green);
        OutTextXY(5,440-(10*Round(Numb)),'Bahnorbit: ');
        {SetColor(Blue);
        IF i = 1 THEN OutTextXY(80,410,Centralstar[0]);}
        SetColor(LightRed);
        Str(SemiMajorAxis[0]:0:3,SemiMajorAxis2[0]);
        Str(Eccentricity[0]:0:3,Eccentricity2[0]);
        OutTextXY(5,450+(10*i)-(10*Round(Numb)),PlanetName[0]+': '+SemiMajorAxis2[0]+' AE - ecc '+Eccentricity2[0]);
      END;
      SetColor(Black);
      IF Zoom < 25/100 THEN SetTextStyle(2,HorizDir,2) ELSE SetTextStyle(2,HorizDir,4);
      {Merkur}
      a := 0.387*(149.6);
      e := 0.205;
      b := a*Sqrt(1-Sqr(e));
      c := (a-b)*(11.868);
      Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
      OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Merkur');
      {Venus}
      a := 0.723*(149.6);
      e := 0.0067;
      b := a*Sqrt(1-Sqr(e));
      c := (a-b)*(0.724);
      Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
      OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Venus');
      {Erde}
      a := 1.00*(149.6);
      e := 0.0167;
      b := a*Sqrt(1-Sqr(e));
      c := (a-b)*(2.498);
      Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
      OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Erde');
      {Mars}
      a := 1.523*(149.6);
      e := 0.093;
      b := a*Sqrt(1-Sqr(e));
      c := (a-b)*(21.189);
      Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
      OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Mars');
      {Jupiter}
      a := 5.203*(149.6);
      e := 0.048;
      b := a*Sqrt(1-Sqr(e));
      c := (a-b)*(37.362);
      Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
      OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Jupiter');
      {Saturn}
      a := 9.55*(149.6);
      e := 0.05;
      b := a*Sqrt(1-Sqr(e));
      c := (a-b)*(71.434);
      Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
      OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Saturn');
      {Uranus}
      a := 19.2*(149.6);
      e := 0.04;
      b := a*Sqrt(1-Sqr(e));
      c := (a-b)*(114.893);
      Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
      OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Uranus');
      {Neptun}
      a := 30.1*(149.6);
      e := 0.01;
      b := a*Sqrt(1-Sqr(e));
      c := (a-b)*(45.029);
      Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
      OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Neptun');
      {Pluto}
      a := 39.5*(149.6);
      e := 0.25;
      b := a*Sqrt(1-Sqr(e));
      c := (a-b)*(9.875);{!!!}
      Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightGray);
      OutTextXY(310+Round(c*Zoom)+Trunc(mx),240+Round(b*Zoom)+Trunc(my),'Pluto');
      SetColor(Cyan);
      SetTextStyle(2,0,4);
      OutTextXY(10,2,'(C) 1995-2006 EXODB2 1.8 * Michael Johne * http://www.exodb.de.vu');
      Input := ReadKey;
      IF Input IN ['S','s'] THEN BEGIN
        SetTextStyle(2,HorizDir,4);
        SaveImage(0+200,0+200,640-200,480-200,'image.tmp');
        SetFillStyle(SolidFill,Blue);
        SetLineStyle(0,0,1);
        Bar(0+200,0+200,640-200,480-200);
        SetColor(DarkGray);
        Rectangle(0+200,0+200,640-200,480-200);
        SetColor(LightGray);
        Rectangle(0+201,0+201,640-201,480-201);
        SetColor(White);
        Rectangle(0+202,0+202,640-202,480-202);
        SetColor(LightGray);
        Rectangle(0+203,0+203,640-203,480-203);
        SetColor(DarkGray);
        Rectangle(0+204,0+204,640-204,480-204);
        SetColor(White);
        OutTextXY(210,210,'Speichern der Bilddatei:');
        SetColor(Yellow);
        IF ParamStr(1) = 'all' THEN OutTextXY(360,210,'ORBIT') ELSE OutTextXY(360,210,ParamStr(2));
        SetColor(White);
        OutTextXY(270,230,'1 - Format PCX');
        OutTextXY(270,240,'2 - Format BMP');
        OutTextXY(270,250,'0 - Abbruch');
        REPEAT
          Input := ReadKey;
        UNTIL Input IN ['0','1','2'];
        LoadImage(0+200,0+200,'image.tmp');
        IF NOT(DirExists('ORBIT')) THEN MkDir('ORBIT');
        CASE Input OF
          '1' : IF ParamStr(1) = 'all' THEN SavePCX('ORBIT/'+'ORBIT.PCX') ELSE SavePCX('ORBIT/'+ParamStr(2)+'.PCX');
          '2' : IF ParamStr(1) = 'all' THEN SaveBMP('ORBIT/'+'ORBIT') ELSE SaveBMP('ORBIT/'+ParamStr(2));
          '0' : Exit;
        END;
        Bar(0+200,0+200,640-200,480-200);
        SetColor(DarkGray);
        Rectangle(0+200,0+200,640-200,480-200);
        SetColor(LightGray);
        Rectangle(0+201,0+201,640-201,480-201);
        SetColor(White);
        Rectangle(0+202,0+202,640-202,480-202);
        SetColor(LightGray);
        Rectangle(0+203,0+203,640-203,480-203);
        SetColor(DarkGray);
        Rectangle(0+204,0+204,640-204,480-204);
        SetColor(LightGreen);
        SetTextStyle(2,HorizDir,5);
        OutTextXY(230,230,'Bilddatei gespeichert...');
        DeleteFile('image.tmp');
        Readkey;
      END ELSE IF Input IN ['P','p'] THEN GraftoPrint
      ELSE IF Input IN ['B','b'] THEN BEGIN
        SearchDir2('EXO\','*.exo');
      END;
      CloseGraph;
    END;
  END;
END.


