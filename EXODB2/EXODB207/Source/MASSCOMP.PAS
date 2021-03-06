PROGRAM Plugin_MassCompare;

USES Crt,Dos,Graph,Printer,RT_Watch;

VAR
  Fil             : ARRAY[1..20] OF STRING;
  Input           : Char;
  Control,i,
  grDriver,grMode : Integer;
  a,p,e,b,c,
  Numb            : Real;
  regs            : Registers;
  f               : Text;
  PlanetMass2,
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
    WriteLn(^j^j'Der Parameter als Anzahl der darzustellende Datens�tze fehlt!');
    WriteLn('    -  MASSCOMP.EXE [anzahl] [dateiname]');
    WriteLn(^j'Achten Sie darauf, dass die Datens�tze im Verzeichnis "EXO"');
    WriteLn('des Hauptverzeichis liegen.');
    ReadKey;
    Halt;
  END ELSE BEGIN
    Val(ParamStr(1),Numb,Control);
    IF (Control <> 0) OR (Numb=0) THEN BEGIN
      WriteLn(^j^j'Der eingegebene Zahlenwert ',ParamStr(1),' ist ung�ltig.');
      WriteLn('Es sind alle Zahlen von 1 bis x erlebt; je nachdem wieviel');
      WriteLn('Datens�tze vorliegen Im Verzeichnis "EXO" vorliegen.');
      ReadKey;
      Halt;
    END;
  END;
  IF ParamStr(2) = '' THEN BEGIN
    WriteLn(^j^j'Der Parameter fehlt! Aufruf des Datenansatz ohne [.EXO]:');
    WriteLn('    -  MASSCOMP.EXE [dateiname] [zoom]');
    WriteLn(^j'Achten Sie darauf, dass die Datens�tze im Verzeichnis "EXO"');
    WriteLn('des Hauptverzeichis liegen.');
    ReadKey;
  END ELSE BEGIN
    FOR i := 1 TO Round(Numb) DO BEGIN
      IF NOT(FileExists('exo/'+ParamStr(1+i)+'.EXO')) THEN BEGIN
        WriteLn(^j^j'Die Datei "','exo/'+ParamStr(1+i)+'.EXO','" wurde nicht gefunden!');
        WriteLn(^j'Achten Sie darauf, dass die Datens�tze im Verzeichnis "EXO"');
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
    grDriver := Detect;
    InitGraph(grDriver,grMode,'');
    SetFillStyle(SolidFill,White);
    Bar(0,0,640,480);
    SetFillStyle(SolidFill,LightBlue);
    SetColor(Black);
    Bar(080,300-Round(35*1.000),080+40,300);
    FOR i := 1 TO Trunc(1.0)+1 DO BEGIN
      Line(080,300-Round(35*i),080+40,300-Round(35*i));
    END;
    Bar(140,300-Round(35*0.299),140+40,300);
    FOR i := 1 TO Trunc(0.299)+1 DO BEGIN
      Line(140,300-Round(35*i),140+40,300-Round(35*i));
    END;
    Bar(200,300-Round(35*0.046),200+40,300);
    FOR i := 1 TO Trunc(0.046)+1 DO BEGIN
      Line(200,300-Round(35*i),200+40,300-Round(35*i));
    END;
    Bar(260,300-Round(35*0.054),260+40,300);
    FOR i := 1 TO Trunc(0.054)+1 DO BEGIN
      Line(260,300-Round(35*i),260+40,300-Round(35*i));
    END;
    SetColor(LightBlue);
    SetTextStyle(2,0,5);
    OutTextXY(80,320+(10*1),'Jupiter: 1.000 Mjup');
    OutTextXY(80,320+(10*2),'Saturn: 0.299 Mjup');
    OutTextXY(80,320+(10*3),'Uranus: 0.046 Mjup');
    OutTextXY(80,320+(10*4),'Neptun: 0.054 Mjup');
    SetFillStyle(SolidFill,LightRed);
    SetColor(Black);
    Bar(340,300-Round(35*PlanetMass[1]),340+40,300);
    FOR i := 1 TO Trunc(PlanetMass[1])+1 DO BEGIN
      Line(340,300-Round(35*i),340+40,300-Round(35*i));
    END;
    IF Numb = 2 THEN BEGIN
      Bar(400,300-Round(35*PlanetMass[2]),400+40,300);
      FOR i := 1 TO Trunc(PlanetMass[2])+1 DO BEGIN
        Line(400,300-Round(35*i),400+40,300-Round(35*i));
      END;
    END;
    IF Numb = 3 THEN BEGIN
      Bar(400,300-Round(35*PlanetMass[2]),400+40,300);
      FOR i := 1 TO Trunc(PlanetMass[2])+1 DO BEGIN
        Line(400,300-Round(35*i),400+40,300-Round(35*i));
      END;
      Bar(460,300-Round(35*PlanetMass[3]),460+40,300);
      FOR i := 1 TO Trunc(PlanetMass[3])+1 DO BEGIN
        Line(460,300-Round(35*i),460+40,300-Round(35*i));
      END;
    END;
    IF Numb = 4 THEN BEGIN
      Bar(400,300-Round(35*PlanetMass[2]),400+40,300);
      FOR i := 1 TO Trunc(PlanetMass[2])+1 DO BEGIN
        Line(400,300-Round(35*i),400+40,300-Round(35*i));
      END;
      Bar(460,300-Round(35*PlanetMass[3]),460+40,300);
      FOR i := 1 TO Trunc(PlanetMass[3])+1 DO BEGIN
        Line(460,300-Round(35*i),460+40,300-Round(35*i));
      END;
      Bar(520,300-Round(35*PlanetMass[4]),520+40,300);
      FOR i := 1 TO Trunc(PlanetMass[4])+1 DO BEGIN
        Line(520,300-Round(35*i),520+40,300-Round(35*i));
      END;
    END;
    IF Numb = 5 THEN BEGIN
      Bar(400,300-Round(35*PlanetMass[2]),400+40,300);
      FOR i := 1 TO Trunc(PlanetMass[2])+1 DO BEGIN
        Line(400,300-Round(35*i),400+40,300-Round(35*i));
      END;
      Bar(460,300-Round(35*PlanetMass[3]),460+40,300);
      FOR i := 1 TO Trunc(PlanetMass[3])+1 DO BEGIN
        Line(460,300-Round(35*i),460+40,300-Round(35*i));
      END;
      Bar(520,300-Round(35*PlanetMass[4]),520+40,300);
      FOR i := 1 TO Trunc(PlanetMass[4])+1 DO BEGIN
        Line(520,300-Round(35*i),520+40,300-Round(35*i));
      END;
      Bar(580,300-Round(35*PlanetMass[5]),580+40,300);
      FOR i := 1 TO Trunc(PlanetMass[5])+1 DO BEGIN
        Line(580,300-Round(35*i),580+40,300-Round(35*i));
      END;
    END;
    FOR i := 1 TO Round(Numb) DO BEGIN
      SetColor(LightRed);
      Str(PlanetMass[i]:0:3,PlanetMass2[i]);
      OutTextXY(340,320+(10*i),PlanetName[i]+': '+PlanetMass2[i]+' Mjup');
    END;
    SetTextStyle(2,0,8);
    SetColor(Black);
    OutTextXY(225,430,'Masse-Vergleich');
    SetColor(Cyan);
    SetTextStyle(2,0,4);
    OutTextXY(10,2,'(C) 1995-2005 EXODB2 Michael Johne * http://www.die-exoplaneten.de.vu');
    SetColor(Cyan);
    SetTextStyle(2,0,6);
    OutTextXY(10,2,'');
    Input := ReadKey;
    IF Input IN ['S','s'] THEN BEGIN
      IF NOT(DirExists('MASSCOMP')) THEN MkDir('MASSCOMP');
      SavePCX('MASSCOMP/'+ParamStr(2)+'.PCX');
    END;
    CloseGraph;
  END;
END.
