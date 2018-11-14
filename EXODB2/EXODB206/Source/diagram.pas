PROGRAM Plugin_Diagram;

USES Crt,Dos,Graph,Printer,RT_Watch;

VAR
  Fil               : ARRAY[1..3] OF STRING;
  Input             : Char;
  Control,i,Numb,
  grDriver,grMode   : Integer;
  a,p,e,b,c,
  regs              : Registers;
  SearchFile        : SearchRec;
  f                 : Text;
  PlanetMass2,
  CentralStar,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Method,
  PlanetName,
  Remarks,
  Strin,
  SpectralType      : ARRAY[1..3] OF STRING;
  Deklination,
  Distance,
  Eccentricity,
  Magnitude,
  Metalicity,
  Period,
  PlanetMass,
  Rectaszension,
  SemiMajorAxis,
  StarMass          : ARRAY[1..3] OF Real;
  Dis_Eccentricity,
  Dis_PlanetMass,
  Dis_SemiMajorAxis : ARRAY[0..20] OF Byte;



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
  end;
  if bi > 0 THEN FlushIt;
  Close(f);
END;

BEGIN
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF ParamStr(1) = '' THEN BEGIN
    WriteLn(^j^j'Der Parameter als Anzahl des darzustellenden Diagrammes fehlt!');
    ReadKey;
    Halt;
  END ELSE BEGIN
    Val(ParamStr(1),Numb,Control);
    IF (Control <> 0) OR (Numb=0) THEN BEGIN
      WriteLn(^j^j'Der eingegebene Zahlenwert ',ParamStr(1),' ist ungÅltig.');
      WriteLn('Es sind alle Zahlen von 1 bis 3 erlebt.');
      ReadKey;
      Halt;
    END;
  END;
  grDriver := Detect;
  InitGraph(grDriver,grMode,'');
  SetFillStyle(SolidFill,White);
  Bar(20,20,520,420);
  SetLineStyle(1,0,1);
  SetTextStyle(2,0,4);
  SetColor(LightGray);
  CASE Numb OF
    1: BEGIN
         FOR i := 1 TO 8 DO BEGIN
           Line(Round((i-1)*70)+20,20,Round((i-1)*70)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round((i-1)*70)+20,430,Strin[1]+' AE');
           SetColor(LightGray);
         END;
         FOR i := 1 TO 10 DO BEGIN
           Line(20,Round((i*0.1)*420),520,Round((i*0.1)*420));
           SetColor(White);
           Str(1-(i*0.1):0:1,Strin[1]);
           OutTextXY(530,Round((i*0.1)*420)-6,Strin[1]);
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Gro·e Halbachse');
         SetTextStyle(2,1,5);
         OutTextXY(550,286,'Num. ExzentrizitÑt');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(600,0,'Diagramm "Gro·e Halbachse / Num. ExzentrizitÑt"');
       END;
    2: BEGIN
         FOR i := 1 TO 8 DO BEGIN
           Line(Round((i-1)*70)+20,20,Round((i-1)*70)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round((i-1)*70)+20,430,Strin[1]+' AE');
           SetColor(LightGray);
         END;
         FOR i := 1 TO 15 DO BEGIN
           Line(20,420-Round(i*22),520,420-Round(i*22));
           SetColor(White);
           Str(i,Strin[1]);
           OutTextXY(530,420-Round(i*22)-6,Strin[1]+' Mjup');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Gro·e Halbachse');
         SetTextStyle(2,1,5);
         OutTextXY(567,286,'Exoplaneten-Masse');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(600,0,'Diagramm "Gro·e Halbachse / Exoplaneten-Masse"');
       END;
    3: BEGIN
         FOR i := 1 TO 10 DO BEGIN
           Line(Round((i-1)*50)+20,20,Round((i-1)*50)+20,420);
           SetColor(White);
           Str(i-1,Strin[1]);
           OutTextXY(Round((i-1)*50)+20,430,'0.'+Strin[1]);
           SetColor(LightGray);
         END;
         FOR i := 1 TO 15 DO BEGIN
           Line(20,420-Round(i*22),520,420-Round(i*22));
           SetColor(White);
           Str(i,Strin[1]);
           OutTextXY(530,420-Round(i*22)-6,Strin[1]+' Mjup');
           SetColor(LightGray);
         END;
         SetColor(LightCyan);
         SetTextStyle(2,0,5);
         OutTextXY(20,440,'Num. ExzentrizitÑt');
         SetTextStyle(2,1,5);
         OutTextXY(567,286,'Exoplaneten-Masse');
         SetColor(LightGreen);
         SetTextStyle(2,1,6);
         OutTextXY(600,0,'Diagramm "Num. ExzentrizitÑt / Exoplaneten-Masse"');
       END;
  END;

  SetColor(Red);
  FindFirst('EXO\*.EXO',AnyFile,SearchFile);
  WHILE DosError = 0 DO BEGIN
    Assign(f,'EXO/'+SearchFile.Name);
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
    Inc(Dis_Eccentricity[Round(Eccentricity[1]*10)]);
    Inc(Dis_PlanetMass[Round(PlanetMass[1])]);
    Inc(Dis_SemiMajorAxis[Round(SemiMajorAxis[1])]);
    CASE Numb OF
      1: BEGIN
           PutPixel(Round(SemiMajorAxis[1]*70)+20,420-Round(Eccentricity[1]*400),Red);
           Circle(Round(SemiMajorAxis[1]*70)+20,420-Round(Eccentricity[1]*400),3);
         END;
      2: BEGIN
           PutPixel(Round(SemiMajorAxis[1]*70)+20,420-Round(PlanetMass[1]*22),Red);
           Circle(Round(SemiMajorAxis[1]*70)+20,420-Round(PlanetMass[1]*22),3);
         END;
      3: BEGIN
           PutPixel(Round(Eccentricity[1]*445)+20,420-Round(PlanetMass[1]*22),Red);
           Circle(Round(Eccentricity[1]*445)+20,420-Round(PlanetMass[1]*22),3);
         END;
    END;
    FindNext(SearchFile);
  END;
  SetColor(Cyan);
  SetTextStyle(2,0,4);
  OutTextXY(20,2,'(C) 1995-2003 EXO-DB2 Michael Johne * http://www.die-exoplaneten.de.vu');
  Input := ReadKey;
  IF Input IN ['S','s'] THEN BEGIN
    IF NOT(DirExists('DIAGRAM')) THEN MkDir('DIAGRAM');
    CASE Numb OF
      1: SavePCX('DIAGRAM/'+'AXIS_ECC'+'.PCX');
      2: SavePCX('DIAGRAM/'+'AXIS_MAS'+'.PCX');
      3: SavePCX('DIAGRAM/'+'ECC_MASS'+'.PCX');
    END;
  END;
  CloseGraph;
END.


  SetFillStyle(SolidFill,LightBlue);
  SetColor(Black);
  CASE Numb OF
    1: FOR i := 1 TO 10 DO BEGIN
         Bar((i*40)+30,420-Round(10*Dis_Eccentricity[i-1]),(i*40)+40+30,420);
         Rectangle((i*40)+30,420-Round(10*Dis_Eccentricity[i-1]),(i*40)+40+30,420);
       END;
    2: FOR i := 1 TO 10 DO BEGIN
         Bar((i*40)+30,420-Round(10*Dis_PlanetMass[i-1]),(i*40)+40+30,420);
         Rectangle((i*40)+30,420-Round(10*Dis_PlanetMass[i-1]),(i*40)+40+30,420);
       END;
    3: FOR i := 1 TO 10 DO BEGIN
         Bar((i*40)+30,420-Round(6*Dis_SemiMajorAxis[i-1]),(i*40)+40+30,420);
         Rectangle((i*40)+30,420-Round(6*Dis_SemiMajorAxis[i-1]),(i*40)+40+30,420);
       END;
  END;
  SetTextStyle(2,0,8);
  SetColor(Black);
  CASE Numb OF
    1: OutTextXY(50,40,'Distribution: BahnexzentrizitÑt');
    2: OutTextXY(50,40,'Distribution: Exoplaneten-Masse');
    3: OutTextXY(60,40,'Distribution: Gro·e Halbachse');
  END;
  SetTextStyle(2,0,5);
  SetColor(LightGreen);
  CASE Numb OF
    1: FOR i := 1 TO 10 DO BEGIN
         Str((i*0.1)-0.1:0:1,Strin[1]);
         Str(Dis_Eccentricity[i-1],Strin[2]);
         OutTextXY(550,37+(i*10)+(3*i),Strin[1]+': '+Strin[2]);
       END;
    2: FOR i := 1 TO 10 DO BEGIN
         Str((i)-1,Strin[1]);
         Str(Dis_PlanetMass[i-1],Strin[2]);
         OutTextXY(550,37+(i*10)+(3*i),Strin[1]+' Mjup: '+Strin[2]);
       END;
    3: FOR i := 1 TO 10 DO BEGIN
         Str((i)-1,Strin[1]);
         Str(Dis_SemiMajorAxis[i-1],Strin[2]);
         OutTextXY(550,37+(i*10)+(3*i),Strin[1]+' AE: '+Strin[2]);
       END;
  END;
  SetColor(White);
  CASE Numb OF
    1: FOR i := 1 TO 10 DO BEGIN
         Str((i*0.1)-0.1:0:1,Strin[1]);
         OutTextXY(42+(i*37)+(3*i),430,Strin[1]);
       END;
    2: FOR i := 1 TO 10 DO BEGIN
         Str(i-1,Strin[1]);
         OutTextXY(46+(i*37)+(3*i),430,Strin[1]);
         OutTextXY(500,430,'Jupitermassen');
       END;
    3: FOR i := 1 TO 10 DO BEGIN
         Str(i-1,Strin[1]);
         OutTextXY(46+(i*37)+(3*i),430,Strin[1]);
         OutTextXY(500,430,'Astron. Einheiten');
       END;
  END;
