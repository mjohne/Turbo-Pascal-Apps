PROGRAM Plugin_RV;

USES Crt,Dos,Graph,Printer,RT_Watch;

VAR
  Fil             : ARRAY[0..20] OF STRING;
  Input           : Char;
  Control,i,
  grDriver,grMode : Integer;
  a,p,e,b,c,
  Numb,Zoom,mx,my : Real;
  regs            : Registers;
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
  grDriver := Detect;
  InitGraph(grDriver,grMode,'');
  SetFillStyle(SolidFill,White);
  Bar(0,0,640,480);
  SetColor(Blue);
  MoveTo(100,150);
  FOR i := 1 TO 360 DO BEGIN
    PutPixel(i,Round(Sin(i)*(180/pi)*10),Red);
  END;


  SetColor(Cyan);
  SetTextStyle(2,0,4);
  OutTextXY(10,2,'(C) 1995-2005 EXO-DB2 Michael Johne * http://www.die-exoplaneten.de.vu');
  Input := ReadKey;
  IF Input IN ['S','s'] THEN BEGIN
    IF NOT(DirExists('RV')) THEN MkDir('RV');
    SavePCX('RV/'+ParamStr(2)+'.PCX');
  END;
  CloseGraph;

END.





BEGIN
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
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
      END;
    END;
    Val(ParamStr(2+Round(Numb)),Zoom,Control);
    IF Control <> 0 THEN BEGIN
      Zoom := 100;
      WriteLn(^j^j'Der eingegebene Zoom-Wert ',ParamStr(2+Round(Numb)),' ist ungÅltig.');
      WriteLn('Folgende Beispielwerte sind erlaubt: 100.0; 70.32; 25.32432...; etc.');
      WriteLn(^j'Als Stanardwert fÅr Zoom wird nun 100 genommen.');
      ReadKey;
    END;
    Val(ParamStr(3+Round(Numb)),mx,Control);
    IF Control <> 0 THEN BEGIN
      mx := 0;
      WriteLn(^j^j'Der eingegebene MX-Wert ',ParamStr(3+Round(Numb)),' ist ungÅltig.');
      WriteLn('Folgende Beispielwerte sind erlaubt: 100; -70; 25,...; etc.');
      WriteLn(^j'Als Stanardwert fÅr MX wird nun 0 genommen.');
      ReadKey;
    END;
    Val(ParamStr(4+Round(Numb)),my,Control);
    IF Control <> 0 THEN BEGIN
      my := 0;
      WriteLn(^j^j'Der eingegebene MY-Wert ',ParamStr(4+Round(Numb)),' ist ungÅltig.');
      WriteLn('Folgende Beispielwerte sind erlaubt: 100; -70; 25,...; etc.');
      WriteLn(^j'Als Stanardwert fÅr MY wird nun 0 genommen.');
      ReadKey;
    END;
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
    {Exoplanet}
    FOR i := 1 TO Round(Numb) DO BEGIN
      Assign(f,'exo/'+ParamStr(1+i)+'.EXO');
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
      ReadLn(f,Remarks[0]);
      Close(f);
      a := SemiMajorAxis[0]*(149.6);
      e := Eccentricity[0];
      b := a*Sqrt(1-Sqr(e));
      c := (a-b)*(2.498);
      Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom),Round(b*Zoom),LightBlue);
      Ellipse(320+Round(c*Zoom)+Trunc(mx),240+Trunc(my),Round(a*Zoom-1),Round(b*Zoom-1),LightBlue);
      SetTextStyle(2,0,5);
      SetColor(Green);
      OutTextXY(5,410,'Bahnorbit: ');
      SetColor(Blue);
      IF i = 1 THEN OutTextXY(80,410,Centralstar[0]);
      SetColor(LightRed);
      Str(SemiMajorAxis[0]:0:3,SemiMajorAxis2[0]);
      Str(Eccentricity[0]:0:3,Eccentricity2[0]);
      OutTextXY(5,420+(10*i),SemiMajorAxis2[0]+' AE - ecc '+Eccentricity2[0]);
    END;
    SetColor(Cyan);
    SetTextStyle(2,0,4);
    OutTextXY(10,2,'(C) 1995-2003 EXO-DB2 Michael Johne * http://www.die-exoplaneten.de.vu');
    Input := ReadKey;
    IF Input IN ['S','s'] THEN BEGIN
      IF NOT(DirExists('ORBIT')) THEN MkDir('ORBIT');
      SavePCX('ORBIT/'+ParamStr(2)+'.PCX');
    END;
    CloseGraph;
  END;
END.