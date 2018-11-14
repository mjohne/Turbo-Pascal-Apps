PROGRAM Plugin_HRD;

USES Crt,Dos,Graph,RT_Watch,BmpLoad,BGI2PRN;

CONST
  Ln10 = 2.3025850930;
  BmpHead : ARRAY[1..118] OF Byte =
         (66,77,         {Signatur 'BM'}
          118,
          8,
          0,
          0,0,0,0,0,
          118,0,0,0,40,
          0,0,0,
          128,2,         { (2x256)+128 = 640 pixels -breite}
          0,0,
          224,1,         { (1x256)+224 = 480 pixels -hîhe}
          0,0,1,0,4,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   { 0}   0,0,0,0,       {schwarz}
   { 1}   128,128,128,0, {dunkelgrau?}
   { 2}   0,0,0,0,       {hellgrau?}
   { 3}   0,0,255,0,     {rot}
   { 4}   192,192,192,0, {grau?}
   { 5}   255,255,255,0, {wei·}
   { 6}   0,0,0,0,
   { 7}   0,0,0,0,
   { 8}   0,0,0,0,
   { 9}   0,0,0,0,
   {10}   0,0,0,0,
   {11}   0,0,0,0,
   {12}   0,255,255,0,
   {13}   0,255,0,0,
   {14}   255,0,0,0,
   {15}   255,255,0,0);

VAR
  Input           : Char;
  Control,i,x,y,
  grDriver,grMode : Integer;
  a,p,e,b,c,
  Numb,Zoom,mx,my : Real;
  regs            : Registers;
  f,f2            : Text;
  TempStr,
  Magnitude2,
  CentralStar,
  Discoverer,
  DiscoveryDate,
  Constellation,
  Method,
  PlanetName,
  Remarks,
  SpectralType    : STRING;
  Deklination,
  Distance,
  Eccentricity,
  Magnitude,
  Metalicity,
  Period,
  PlanetMass,
  Rectaszension,
  SemiMajorAxis,
  StarMass        : Real;

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
    {Spezielle Paletten-EintrÑge}
    rgb[01,1] := 128; rgb[01,2] := 128; rgb[01,3] := 128;
    rgb[03,1] := 255; rgb[03,2] :=   0; rgb[03,3] :=   0;
    rgb[04,1] := 192; rgb[04,2] := 192; rgb[04,3] := 192;
    rgb[05,1] := 255; rgb[05,2] := 255; rgb[05,3] := 255;
    rgb[12,1] := 255; rgb[12,2] := 255; rgb[12,3] :=   0;
    rgb[13,1] :=   0; rgb[13,2] := 255; rgb[13,3] :=   0;
    rgb[14,1] :=   0; rgb[14,2] :=   0; rgb[14,3] := 255;
    rgb[15,1] :=   0; rgb[15,2] := 255; rgb[15,3] := 255;
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
    Inc(i);
    Assign(f2,'exo\'+f.name);
    Reset(f2);
    ReadLn(f2,Centralstar);
    ReadLn(f2,SpectralType);
    ReadLn(f2,Magnitude);
    ReadLn(f2,StarMass);
    ReadLn(f2,Metalicity);
    ReadLn(f2,Distance);
    ReadLn(f2,Rectaszension);
    ReadLn(f2,Deklination);
    ReadLn(f2,Constellation);
    ReadLn(f2,PlanetName);
    ReadLn(f2,PlanetMass);
    ReadLn(f2,SemiMajorAxis);
    ReadLn(f2,Period);
    ReadLn(f2,Eccentricity);
    ReadLn(f2,Method);
    ReadLn(f2,DiscoveryDate);
    ReadLn(f2,Discoverer);
    ReadLn(f2,Remarks);
    Close(f2);
    CASE SpectralType[1] OF
      'O' : BEGIN
              x := 020*2;
            END;
      'B' : BEGIN
              x := 039*2;
            END;
      'A' : BEGIN
              x := 063*2;
            END;
      'F' : BEGIN
              x := 090*2;
            END;
      'G' : BEGIN
              x := 115*2;
            END;
      'K' : BEGIN
              x := 140*2;
            END;
      'M' : BEGIN
              x := 165*2;
            END;
    END;
    CASE SpectralType[2] OF
      '0' : BEGIN
            x := x+Round(((20*2)/10)+2*0);
          END;
      '1' : BEGIN
              x := x+Round(((20*2)/10)+2*2.6);
            END;
      '2' : BEGIN
              x := x+Round(((20*2)/10)+2*5.2);
            END;
      '3' : BEGIN
              x := x+Round(((20*2)/10)+2*7.8);
            END;
      '4' : BEGIN
              x := x+Round(((20*2)/10)+2*10.4);
            END;
      '5' : BEGIN
              x := x+Round(((20*2)/10)+2*13);
            END;
      '6' : BEGIN
              x := x+Round(((20*2)/10)+2*15.6);
            END;
      '7' : BEGIN
              x := x+Round(((20*2)/10)+2*18.2);
            END;
      '8' : BEGIN
              x := x+Round(((20*2)/10)+2*20.8);
            END;
      '9' : BEGIN
              x := x+Round(((20*2)/10)+2*23.4);
            END;
    END;
    PutPixel(20+x,64+Round((((Magnitude*38))+200)/2.1),14);
    PutPixel(20+x,65+Round((((Magnitude*38))+200)/2.1),14);
    PutPixel(20+x,63+Round((((Magnitude*38))+200)/2.1),14);
    PutPixel(21+x,64+Round((((Magnitude*38))+200)/2.1),14);
    PutPixel(19+x,64+Round((((Magnitude*38))+200)/2.1),14);
    SetColor(14);
    Circle(20+x,64+Round((((Magnitude*38))+200)/2.1),5);
    Circle(20+x,64+Round((((Magnitude*38))+200)/2.1),6);
    Str(Magnitude:0:2,Magnitude2);
    SetColor(13);
    OutTextXY(410,70+(10*i),CentralStar);
    SetColor(15);
    OutTextXY(555,70+(10*i),Magnitude2);
    SetColor(12);
    OutTextXY(595,70+(10*i),SpectralType);
    Findnext(f);
  END;
END;

BEGIN
  TextBackground(Black);
  TextColor(White);
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF ParamStr(1) = 'all' THEN BEGIN
    grDriver := Detect;
    InitGraph(grDriver,grMode,'');
    ReadBMP('hrd.pic',True,65,20,400,500,x,y);
    SetRGBPalette(15,220,120,120);{15 - Cyan}
    SetRGBPalette(14,000,000,255);{14 - Blau}
    SetRGBPalette(13,000,255,000);{13 - GrÅn}
    SetRGBPalette(12,255,255,000);{12 - Gelb}
    SetTextStyle(2,0,5);
    SetColor(5);
    OutTextXY(410,30,'Sternname        H.vis. Spek-');
    OutTextXY(410,40,'                  mag  trum');
    OutTextXY(410,60,'----------------------------');
    SetTextStyle(2,0,4);
    REPEAT
      SearchDir('exo\','*.exo');
    UNTIL DosError <> 0;
    SetColor(15);
    SetTextStyle(2,0,4);
    OutTextXY(10,2,'(C) 1995-2005 EXO-DB2 Michael Johne * http://www.project-exo.de.vu');
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
      SetColor(LightGreen);
      OutTextXY(210,210,'Speichern der Bilddatei:');
      SetColor(Yellow);
      IF ParamStr(1) = 'all' THEN OutTextXY(360,210,'HRD') ELSE OutTextXY(360,210,ParamStr(2));
      SetColor(LightGreen);
      OutTextXY(270,230,'1 - Format PCX');
      OutTextXY(270,240,'2 - Format BMP');
      OutTextXY(270,250,'0 - Abbruch');
      REPEAT
        Input := ReadKey;
      UNTIL Input IN ['0','1','2'];
      LoadImage(0+200,0+200,'image.tmp');
      IF NOT(DirExists('HRD')) THEN MkDir('HRD');
      CASE Input OF
        '1' : IF ParamStr(1) = 'all' THEN SavePCX('HRD/'+'HRD.PCX') ELSE SavePCX('HRD/'+ParamStr(2)+'.PCX');
        '2' : IF ParamStr(1) = 'all' THEN SaveBMP('HRD/'+'HRD') ELSE SaveBMP('HRD/'+ParamStr(2));
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
    END ELSE IF Input IN ['P','p'] THEN GraftoPrint;
    CloseGraph;
  END ELSE BEGIN
    IF ParamStr(1) = '' THEN BEGIN
      ClrScr;
      WriteLn(^j^j'Der Parameter als Anzahl der darzustellende DatensÑtze fehlt!');
      WriteLn('    -  HRD.EXE [anzahl] [dateiname]');
      WriteLn(^j'Achten Sie darauf, dass die DatensÑtze im Verzeichnis "EXO"');
      WriteLn('des Hauptverzeichis liegen.');
      ReadKey;
      Halt;
    END ELSE BEGIN
      Val(ParamStr(1),Numb,Control);
      IF (Control <> 0) OR (Numb=0) THEN BEGIN
        ClrScr;
        WriteLn(^j^j'Der eingegebene Zahlenwert ',ParamStr(1),' ist ungÅltig.');
        ReadKey;
        Halt;
      END;
    END;
    IF ParamStr(2) = '' THEN BEGIN
      ClrScr;
      WriteLn(^j^j'Der Parameter fehlt! Aufruf des Datenansatz ohne [.EXO]:');
      WriteLn('    -  HRD.EXE [anzahl] [dateiname]');
      WriteLn(^j'Achten Sie darauf, dass die DatensÑtze im Verzeichnis "EXO"');
      WriteLn('des Hauptverzeichis liegen.');
      ReadKey;
    END ELSE BEGIN
      FOR i := 1 TO Round(Numb) DO BEGIN
        IF NOT(FileExists('exo/'+ParamStr(1+i)+'.EXO')) THEN BEGIN
          ClrScr;
          WriteLn(^j^j'Die Datei "','exo/'+ParamStr(1+i)+'.EXO','" wurde nicht gefunden!');
          WriteLn(^j'Achten Sie darauf, dass die DatensÑtze im Verzeichnis "EXO"');
          WriteLn('des Hauptverzeichis liegen.');
          ReadKey;
          Halt;
        END;
      END;
      grDriver := Detect;
      InitGraph(grDriver,grMode,'');
      ReadBMP('hrd.pic',True,65,20,400,500,x,y);
      SetRGBPalette(15,220,120,120);{15 - Cyan}
      SetRGBPalette(14,000,000,255);{14 - Blau}
      SetRGBPalette(13,000,255,000);{13 - GrÅn}
      SetRGBPalette(12,255,255,000);{12 - Gelb}
      SetTextStyle(2,0,5);
      SetColor(5);
      OutTextXY(410,30,'Sternname        H.vis. Spek-');
      OutTextXY(410,40,'                  mag  trum');
      OutTextXY(410,60,'----------------------------');
      FOR i := 1 TO Round(Numb) DO BEGIN
        Assign(f,'exo/'+ParamStr(1+i)+'.EXO');
        Reset(f);
        ReadLn(f,Centralstar);
        ReadLn(f,SpectralType);
        ReadLn(f,Magnitude);
        ReadLn(f,StarMass);
        ReadLn(f,Metalicity);
        ReadLn(f,Distance);
        ReadLn(f,Rectaszension);
        ReadLn(f,Deklination);
        ReadLn(f,Constellation);
        ReadLn(f,PlanetName);
        ReadLn(f,PlanetMass);
        ReadLn(f,SemiMajorAxis);
        ReadLn(f,Period);
        ReadLn(f,Eccentricity);
        ReadLn(f,Method);
        ReadLn(f,DiscoveryDate);
        ReadLn(f,Discoverer);
        ReadLn(f,Remarks);
        Close(f);
        Magnitude := Magnitude+5-5*(Ln(Distance)/Ln10);
        CASE SpectralType[1] OF
          'O' : BEGIN
                  x := 020*2;
                END;
          'B' : BEGIN
                  x := 039*2;
                END;
          'A' : BEGIN
                  x := 063*2;
                END;
          'F' : BEGIN
                  x := 090*2;
                END;
          'G' : BEGIN
                  x := 115*2;
                END;
          'K' : BEGIN
                  x := 140*2;
                END;
          'M' : BEGIN
                  x := 165*2;
                END;
         END;
         CASE SpectralType[2] OF
          '0' : BEGIN
                  x := x+Round(((20*2)/10)+2*0);
                END;
          '1' : BEGIN
                  x := x+Round(((20*2)/10)+2*2.6);
                END;
          '2' : BEGIN
                  x := x+Round(((20*2)/10)+2*5.2);
                END;
          '3' : BEGIN
                  x := x+Round(((20*2)/10)+2*7.8);
                END;
          '4' : BEGIN
                  x := x+Round(((20*2)/10)+2*10.4);
                END;
          '5' : BEGIN
                  x := x+Round(((20*2)/10)+2*13);
                END;
          '6' : BEGIN
                  x := x+Round(((20*2)/10)+2*15.6);
                END;
          '7' : BEGIN
                  x := x+Round(((20*2)/10)+2*18.2);
                END;
          '8' : BEGIN
                  x := x+Round(((20*2)/10)+2*20.8);
                END;
          '9' : BEGIN
                  x := x+Round(((20*2)/10)+2*23.4);
                END;
        END;
        PutPixel(20+x,64+Round((((Magnitude*38))+200)/2.1),14);
        PutPixel(20+x,65+Round((((Magnitude*38))+200)/2.1),14);
        PutPixel(20+x,63+Round((((Magnitude*38))+200)/2.1),14);
        PutPixel(21+x,64+Round((((Magnitude*38))+200)/2.1),14);
        PutPixel(19+x,64+Round((((Magnitude*38))+200)/2.1),14);
        SetColor(14);
        Circle(20+x,64+Round((((Magnitude*38))+200)/2.1),5);
        Circle(20+x,64+Round((((Magnitude*38))+200)/2.1),6);
        Str(Magnitude:0:2,Magnitude2);
        SetColor(13);
        OutTextXY(410,70+(10*i),CentralStar);
        SetColor(15);
        OutTextXY(555,70+(10*i),Magnitude2);
        SetColor(12);
        OutTextXY(595,70+(10*i),SpectralType);
      END;
      SetColor(15);
      SetTextStyle(2,0,4);
      OutTextXY(10,2,'(C) 1995-2005 EXO-DB2 Michael Johne * http://www.die-exoplaneten.de.vu');
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
        SetColor(LightGreen);
        OutTextXY(210,210,'Speichern der Bilddatei:');
        SetColor(Yellow);
        IF ParamStr(1) = 'all' THEN OutTextXY(360,210,'HRD') ELSE OutTextXY(360,210,ParamStr(2));
        SetColor(LightGreen);
        OutTextXY(270,230,'1 - Format PCX');
        OutTextXY(270,240,'2 - Format BMP');
        OutTextXY(270,250,'0 - Abbruch');
        REPEAT
          Input := ReadKey;
        UNTIL Input IN ['0','1','2'];
        LoadImage(0+200,0+200,'image.tmp');
        IF NOT(DirExists('HRD')) THEN MkDir('HRD');
        CASE Input OF
          '1' : IF ParamStr(1) = 'all' THEN SavePCX('HRD/'+'HRD.PCX') ELSE SavePCX('HRD/'+ParamStr(2)+'.PCX');
          '2' : IF ParamStr(1) = 'all' THEN SaveBMP('HRD/'+'HRD') ELSE SaveBMP('HRD/'+ParamStr(2));
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
      END ELSE IF Input IN ['P','p'] THEN GraftoPrint;
    END;
    CloseGraph;
  END;
END.
