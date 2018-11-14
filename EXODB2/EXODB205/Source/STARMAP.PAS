PROGRAM Plugin_Starmap;

USES Crt,Dos,Graph,Printer,RT_Watch;

VAR
  Fil             : ARRAY[0..20] OF STRING;
  Input           : Char;
  Control,i,n,
  Numb,Numb2,Numb3,
  grDriver,grMode : Integer;
  a,p,e,b,c,
  Zoom            : Real;
  regs            : Registers;
  Deklination2,
  Rectaszension2  : STRING;
  f               : Text;
  PlanetMass2,
  CentralStar,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Method,
  PlanetName,
  Remarks,
  SpectralType    : ARRAY[0..20] OF STRING;
  Coordinates,
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
  {$I-} Rewrite(f,1); {$I+}
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
    WriteLn(^j^j'Der Parameter als Anzahl der darzustellende DatensÑtze fehlt!');
    WriteLn('    -  STARMAP.EXE [anzahl] [dateiname]');
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
    WriteLn('    -  STARMAP.EXE [dateiname]');
    WriteLn(^j'Achten Sie darauf, dass die DatensÑtze im Verzeichnis "EXO"');
    WriteLn('des Hauptverzeichis liegen.');
    ReadKey;
  END ELSE BEGIN
    FOR i := 1 TO Numb DO BEGIN
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
    IF NOT(FileExists('stars.dat')) THEN BEGIN
      WriteLn(^j^j'Die Datei "stars.dat" wurde nicht gefunden!');
      WriteLn('Sie ist fÅr die Darstellung der Sterne wichtig.');
      ReadKey;
    END;
    IF NOT(FileExists('clines.dat')) THEN BEGIN
      WriteLn(^j^j'Die Datei "clines.dat" wurde nicht gefunden!');
      WriteLn('Sie ist fÅr die Darstellung der Sternbilder wichtig.');
      ReadKey;
    END;
    IF NOT(FileExists('eclip.dat')) THEN BEGIN
      WriteLn(^j^j'Die Datei "eclip.dat" wurde nicht gefunden!');
      WriteLn('Sie ist fÅr die Darstellung der Ekliptik wichtig.');
      ReadKey;
    END;
    IF ParamStr(2+i) <> '' THEN BEGIN
      Val(ParamStr(2+i),Numb3,Control);
      IF (Control <> 0) THEN BEGIN
        WriteLn(^j^j'Der eingegebene Zahlenwert ',ParamStr(2+i),' ist ungÅltig.');
        ReadKey;
        Numb3 := 0;
      END;
    END;
    grDriver := Detect;
    InitGraph(grDriver,grMode,'');
    Zoom := 1.71;
    SetFillStyle(SolidFill,Blue);
    Bar(0,0,Round(Zoom*360),Round(Zoom*180));
    SetFillStyle(SolidFill,Yellow);
    SetTextStyle(2,0,4);
    IF Numb3 >= 8 THEN BEGIN
      Dec(Numb3,8);
      SetColor(Black);
      SetLineStyle(1,0,1);
      Line(0,Round((Zoom*180)),Round(Zoom*360),Round((Zoom*180)));
      Line(0,Round(Zoom*(180-30)),Round(Zoom*360),Round(Zoom*(180-30)));
      Line(0,Round(Zoom*(180-60)),Round(Zoom*360),Round(Zoom*(180-60)));
      Line(0,Round(Zoom*(180-90)),Round(Zoom*360),Round(Zoom*(180-90)));
      Line(0,Round(Zoom*(180-120)),Round(Zoom*360),Round(Zoom*(180-120)));
      Line(0,Round(Zoom*(180-150)),Round(Zoom*360),Round(Zoom*(180-150)));
      Line(0,Round(Zoom*(180-180)),Round(Zoom*360),Round(Zoom*(180-180)));
      Line(Round(Zoom*0),0,Round(Zoom*0),Round(Zoom*180));
      Line(Round(Zoom*60),0,Round(Zoom*60),Round(Zoom*180));
      Line(Round(Zoom*120),0,Round(Zoom*120),Round(Zoom*180));
      Line(Round(Zoom*180),0,Round(Zoom*180),Round(Zoom*180));
      Line(Round(Zoom*240),0,Round(Zoom*240),Round(Zoom*180));
      Line(Round(Zoom*300),0,Round(Zoom*300),Round(Zoom*180));
      Line(Round(Zoom*360),0,Round(Zoom*360),Round(Zoom*180));
      SetColor(White);
      OutTextXY(Round(Zoom*361),Round((Zoom*(0-2))),'+90¯');
      OutTextXY(Round(Zoom*361),Round((Zoom*(30-2))),'+60¯');
      OutTextXY(Round(Zoom*361),Round((Zoom*(60-2))),'+30¯');
      OutTextXY(Round(Zoom*361),Round((Zoom*(90-2))),'  0¯');
      OutTextXY(Round(Zoom*361),Round((Zoom*(120-2))),'-30¯');
      OutTextXY(Round(Zoom*361),Round((Zoom*(150-2))),'-60¯');
      OutTextXY(Round(Zoom*361),Round((Zoom*(180-2))),'-90¯');
      OuttextXY(Round(Zoom*0),Round(Zoom*180),'24h');
      OuttextXY(Round(Zoom*60),Round(Zoom*180),'20h');
      OuttextXY(Round(Zoom*120),Round(Zoom*180),'16h');
      OuttextXY(Round(Zoom*180),Round(Zoom*180),'12h');
      OuttextXY(Round(Zoom*240),Round(Zoom*180),'8h');
      OuttextXY(Round(Zoom*300),Round(Zoom*180),'4h');
      OuttextXY(Round(Zoom*360),Round(Zoom*185),'0h');
    END;
    SetLineStyle(0,0,1);
    IF Numb3 >= 4 THEN BEGIN
      Dec(Numb3,4);
      SetColor(Green);
      Line(0,Round((Zoom*180)/2),Round(Zoom*360),Round((Zoom*180)/2));
      SetColor(Cyan);
      IF FileExists('eclip.dat') THEN BEGIN
        Assign(f,'eclip.dat');
        Reset(f);
        Rectaszension[0] := 0;
        Deklination[0]   := 0;
        Rectaszension[0] := 10*Rectaszension[0];
        Rectaszension[0] := (Rectaszension[0]*360)/240;
        Rectaszension[0] := 360-Rectaszension[0];
        Deklination[0]   := -(Deklination[0])+90;
        MoveTo(Round(Zoom*Rectaszension[0]),Round(Zoom*Deklination[0]));
        REPEAT
          Read(f,Rectaszension[0]);
          ReadLn(f,Deklination[0]);
          {Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor}
          Rectaszension[0] := 10*Rectaszension[0];
          Rectaszension[0] := (Rectaszension[0]*360)/240;
          Rectaszension[0] := 360-Rectaszension[0];
          Deklination[0]   := -(Deklination[0])+90;
          LineTo(Round(Zoom*Rectaszension[0]),Round(Zoom*Deklination[0]));
        UNTIL EoF(f);
        Close(f);
      END;
    END;
    IF Numb3 >= 2 THEN BEGIN
      Dec(Numb3,2);
      SetColor(DarkGray);
      IF FileExists('clines.dat') THEN BEGIN
        Assign(f,'clines.dat');
        Reset(f);
        REPEAT
          ReadLn(f,Numb2);
          FOR i := 1 TO 6 DO Read(f,Coordinates[i]);
          ReadLn(f);
          Rectaszension[0] := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
          Deklination[0] := Coordinates[4]+(Coordinates[5]/60)+(Coordinates[6]/3600);
          {Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor}
          Rectaszension[0] := 10*Rectaszension[0];
          Rectaszension[0] := (Rectaszension[0]*360)/240;
          Rectaszension[0] := 360-Rectaszension[0];
          Deklination[0]   := -(Deklination[0])+90;
          MoveTo(Round(Zoom*Rectaszension[0]),Round(Zoom*Deklination[0]));
          FOR n := 1 TO Numb2-1 DO BEGIN
            FOR i := 1 TO 6 DO Read(f,Coordinates[i]);
            ReadLn(f);
            Rectaszension[0] := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
            Deklination[0] := Coordinates[4]+(Coordinates[5]/60)+(Coordinates[6]/3600);
            {Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor}
            Rectaszension[0] := 10*Rectaszension[0];
            Rectaszension[0] := (Rectaszension[0]*360)/240;
            Rectaszension[0] := 360-Rectaszension[0];
            Deklination[0]   := -(Deklination[0])+90;
            LineTo(Round(Zoom*Rectaszension[0]),Round(Zoom*Deklination[0]));
          END;
        UNTIL EoF(f);
        Close(f);
      END;
    END;
    IF FileExists('stars.dat') THEN BEGIN
      SetColor(White);
      Assign(f,'stars.dat');
      Reset(f);
      REPEAT
        FOR i := 1 TO 6 DO Read(f,Coordinates[i]);
        ReadLn(f,Magnitude[0]);
        Rectaszension[0] := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
        Deklination[0] := Coordinates[4]+(Coordinates[5]/60)+(Round(Coordinates[6])/3600);
        {Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor}
        Rectaszension[0] := 10*Rectaszension[0];
        Rectaszension[0] := (Rectaszension[0]*360)/240;
        Rectaszension[0] := 360-Rectaszension[0];
        Deklination[0]   := -(Deklination[0])+90;
        CASE Round(Magnitude[0]) OF
          5: PutPixel(Round(Zoom*Rectaszension[0]),Round(Zoom*Deklination[0]),LightGray);
          4: PutPixel(Round(Zoom*Rectaszension[0]),Round(Zoom*Deklination[0]),Yellow);
          3: PieSlice(Round(Zoom*Rectaszension[0]),Round(Zoom*Deklination[0]),0,360,0);
          2: PieSlice(Round(Zoom*Rectaszension[0]),Round(Zoom*Deklination[0]),0,360,1);
          1: PieSlice(Round(Zoom*Rectaszension[0]),Round(Zoom*Deklination[0]),0,360,1);
          0: PieSlice(Round(Zoom*Rectaszension[0]),Round(Zoom*Deklination[0]),0,360,2);
         -1..-50: PieSlice(Round(Zoom*Rectaszension[0]),Round(Zoom*Deklination[0]),0,360,2);
        END
      UNTIL EoF(f);
      Close(f);
    END;
    FOR i := 1 TO Numb DO BEGIN
      Rectaszension[i] := 10*Rectaszension[i];
      Rectaszension[i] := (Rectaszension[i]*360)/240;
      Rectaszension[i] := 360-Rectaszension[i];
      Deklination[0]   := -(Deklination[i])+90;
      PutPixel(Round(Zoom*Rectaszension[i]),Round(Zoom*Deklination[0]),Red);
      SetColor(Red);
      Circle(Round(Zoom*Rectaszension[i]),Round(Zoom*Deklination[0]),2);
    END;
    SetTextStyle(2,0,5);
    SetColor(White);
    Numb2 := Numb;
    IF Numb < 11 THEN FOR i := 1 TO Numb DO BEGIN
      Str((Rectaszension[i]*24)/360:0:3,Rectaszension2);
      Str(Deklination[i]:0:3,Deklination2);
      OutTextXY(10,340+(10*i),PlanetName[i]+': '+Rectaszension2+'h '+Deklination2+'¯');
    END ELSE IF Numb < 21 THEN BEGIN
      FOR i := 1 TO 10 DO BEGIN
        Str((Rectaszension[i]*24)/360:0:3,Rectaszension2);
        Str(Deklination[i]:0:3,Deklination2);
        OutTextXY(10,340+(10*(i-1)),PlanetName[i]+': '+Rectaszension2+'h '+Deklination2+'¯');
      END;
      FOR i := 10 TO Numb DO BEGIN
        Str((Rectaszension[i]*24)/360:0:3,Rectaszension2);
        Str(Deklination[i]:0:3,Deklination2);
        OutTextXY(300,340+(10*(i-10)),PlanetName[i]+': '+Rectaszension2+'h '+Deklination2+'¯');
      END;
    END;
    SetColor(Cyan);
    SetTextStyle(2,0,4);
    OutTextXY(2,320,'(C) 1995-2003 EXO-DB2 Michael Johne * http://www.die-exoplaneten.de.vu');
    Input := ReadKey;
    IF Input IN ['S','s'] THEN BEGIN
      IF NOT(DirExists('STARMAP')) THEN MkDir('STARMAP');
      SavePCX('STARMAP/'+ParamStr(2)+'.PCX');
    END;
    CloseGraph;
  END;
END.
