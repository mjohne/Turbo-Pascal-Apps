{100 0 0 0 35 O M 1 2 51peg 47uma-1}
PROGRAM Plugin_Star3D;

USES Crt,Dos,Graph,Arithmos,RT_Watch,BmpLoad,BGI2PRN;

CONST
  Ln10 = 2.3025850930;
  BmpHead : ARRAY[1..118] OF Byte =
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
  Color           : Byte;
  Input,Swap      : Char;
  Control,i,x,y,
  grDriver,grMode : Integer;
  a,p,e,b,c,pc,t,
  Parsec_Min,
  Parsec_Max,
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
  Spec_Min,
  Spec_Max,
  Object_Centered,
  SpectralType    : STRING;
  Str4            : STRING[4];
  Str41           : STRING[41];
  Spec3           : STRING[10];
  Deklination,
  Distance,
  Eccentricity,
  Magnitude,
  Metalicity,
  Period,
  PlanetMass,
  Rectaszension,
  SemiMajorAxis,
  SpecR_Min,SpecR_Max,
  StarMass,x2,y2,z2,rv : Real;

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
    {Spezielle Paletten-EintrÑge}
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
        IF bi = BufSize THEN FlushIt; Inc(bi); buf[bi] := $C0 OR count;
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
      'O' : x := 020*2;
      'B' : x := 039*2;
      'A' : x := 063*2;
      'F' : x := 090*2;
      'G' : x := 115*2;
      'K' : x := 140*2;
      'M' : x := 165*2;
    END;
    CASE SpectralType[2] OF
      '0' : x := x+Round(((20*2)/10)+2*0);
      '1' : x := x+Round(((20*2)/10)+2*2.6);
      '2' : x := x+Round(((20*2)/10)+2*5.2);
      '3' : x := x+Round(((20*2)/10)+2*7.8);
      '4' : x := x+Round(((20*2)/10)+2*10.4);
      '5' : x := x+Round(((20*2)/10)+2*13);
      '6' : x := x+Round(((20*2)/10)+2*15.6);
      '7' : x := x+Round(((20*2)/10)+2*18.2);
      '8' : x := x+Round(((20*2)/10)+2*20.8);
      '9' : x := x+Round(((20*2)/10)+2*23.4);
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
    REPEAT
      SearchDir('exo\','*.exo');
    UNTIL DosError <> 0;
    SetColor(15);
    SetTextStyle(2,0,4);
    OutTextXY(10,2,'(C) 1995-2005 EXO-DB2 1.5 * Michael Johne * http://www.exodb.de.vu');
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
      IF ParamStr(1) = 'all' THEN OutTextXY(360,210,'STAR3D') ELSE OutTextXY(360,210,ParamStr(2));
      SetColor(LightGreen);
      OutTextXY(270,230,'1 - Format PCX');
      OutTextXY(270,240,'2 - Format BMP');
      OutTextXY(270,250,'0 - Abbruch');
      REPEAT
        Input := ReadKey;
      UNTIL Input IN ['0','1','2'];
      LoadImage(0+200,0+200,'image.tmp');
      IF NOT(DirExists('STAR3D')) THEN MkDir('STAR3D');
      CASE Input OF
        '1' : IF ParamStr(1) = 'all' THEN SavePCX('STAR3D/'+'STAR3D.PCX') ELSE SavePCX('STAR3D/'+ParamStr(2)+'.PCX');
        '2' : IF ParamStr(1) = 'all' THEN SaveBMP('STAR3D/'+'STAR3D') ELSE SaveBMP('STAR3D/'+ParamStr(2));
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
    END ELSE IF Input IN ['P','p'] THEN begin {GraftoPrint;} end;
    CloseGraph;
  END ELSE BEGIN
    IF ParamStr(1) = '' THEN BEGIN
      ClrScr;
      WriteLn(^j^j'Parameter fehlen!');
      ReadKey;
      Halt;
    END ELSE BEGIN
      Val(ParamStr(1),Zoom,Control);
      IF (Control <> 0){ OR (Zoom = 0)} THEN BEGIN
        WriteLn(^j^j'UngÅltige Zahl fÅr ZOOM+"',Zoom,'". Als Standard werden 50 verwendet!');
        ReadKey;
        Zoom := 50;
      END ELSE IF Zoom < 0 THEN Zoom := Abs(Zoom);
      IF ParamStr(2) = '' THEN BEGIN
        ClrScr;
        WriteLn(^j^j'Parameter fehlen!');
        ReadKey;
        Halt;
      END ELSE BEGIN
        Val(ParamStr(2),MX,Control);
        IF (Control <> 0) THEN BEGIN
          WriteLn(^j^j'UngÅltige Zahl fÅr MX. Als Standard werden 0 Pixel verwendet!');
          ReadKey;
          MX := 0;
        END;
        IF ParamStr(3) = '' THEN BEGIN
          WriteLn(^j^j'Parameter fehlen!');
          ReadKey;
          Halt;
        END ELSE BEGIN
          Val(ParamStr(3),MY,Control);
          IF (Control <> 0) THEN BEGIN
            WriteLn(^j^j'UngÅltige Zahl fÅr MY. Als Standard werden 0 Pixel verwendet!');
            ReadKey;
            MY := 0;
          END;
          IF ParamStr(4) = '' THEN BEGIN
            ClrScr;
            WriteLn(^j^j'Parameter fehlen!');
            ReadKey;
            Halt;
          END ELSE BEGIN
            Spec_Min := ParamStr(4);
{            IF (Spec_Min <> 'O') OR (Spec_Min <> 'B') OR
              (Spec_Min <> 'A') OR (Spec_Min <> 'F') OR
              (Spec_Min <> 'G') OR (Spec_Min <> 'K') OR
              (Spec_Min <> 'M') OR (Spec_Min <> 'L') OR
              (Spec_Min <> 'T') THEN BEGIN
              WriteLn(^j^j'UngÅltige Zeichenkette fÅr SPEC_MIN"'+Spec_min+'". Als Standard wird "O" verwendet!');
              ReadKey;
              Spec_Min := 'O';
            END;}
            IF ParamStr(7) = '' THEN BEGIN
              ClrScr;
              WriteLn(^j^j'Parameter fehlen!');
              ReadKey;
              Halt;
            END ELSE BEGIN
              Spec_Max := ParamStr(5);
{              IF (Spec_Max <> 'O') OR (Spec_Max <> 'B') OR
                (Spec_Max <> 'A') OR (Spec_Max <> 'F') OR
                (Spec_Max <> 'G') OR (Spec_Max <> 'K') OR
                (Spec_Max <> 'M') OR (Spec_Max <> 'L') OR
                (Spec_Max <> 'T') THEN BEGIN
                WriteLn(^j^j'UngÅltige Zeichenkette fÅr SPEC_MAX. Als Standard wird "M" verwendet!');
                ReadKey;
                Spec_Max := 'M';
              END;}
              {IF Ord(Spec_Min[1]) > Ord(Spec_Max[1])  THEN BEGIN END;
              vertauschte spektral}
              IF ParamStr(6) = '' THEN BEGIN
                ClrScr;
                WriteLn(^j^j'Parameter fehlen!');
                ReadKey;
                Halt;
              END ELSE BEGIN
                Val(ParamStr(6),Numb,Control);
                IF (Control <> 0) OR (Numb < 1) THEN BEGIN
                WriteLn(^j^j'UngÅltige Zahl fÅr NUMB. Die Aktion von STAR3D wird eingestellt!');
                ReadKey;
                Halt;
              END;
              FOR i := 1 TO Round(Numb) DO BEGIN
                IF NOT(FileExists('EXO/'+ParamStr(6+i)+'.EXO')) THEN BEGIN
                  ClrScr;
                  WriteLn(^j^j'Die Datei "','EXO/'+ParamStr(6+i)+'.EXO','" wurde nicht gefunden!');
                  WriteLn(^j'Achten Sie darauf, dass die DatensÑtze im Verzeichnis "EXO"');
                  WriteLn('des Hauptverzeichis liegen.');
                  ReadKey;
                  Halt;
                END;
                grDriver := Detect;
                InitGraph(grDriver,grMode,'');
                SetColor(White);
                Circle(600,50,20);
                Line(600,30,600,70);
                Line(580,50,620,50);
                SetTextStyle(2,0,5);
                OuttextXY(545,0,'Orientierung');
                SetTextStyle(2,0,4);
                OuttextXY(570,83,'Draufsicht');
                OuttextXY(625,45,'0¯');
                OuttextXY(595,17,'90¯');
                OuttextXY(555,45,'180¯');
                OuttextXY(590,73,'270¯');
                Assign(f2,'stars3.lst');
                Reset(f2);
                ReadLn(f2);
                REPEAT
                  Read(f2,Str41);
                  Read(f2,x2);
                  Read(f2,y2);
                  Read(f2,z2);
                  Read(f2,Str4);
                  Read(f2,Spec3);
                  Read(f2,t);
                  Read(f2,t);
                  Read(f2,pc);
                  ReadLn(f2);
                  Str(pc,Str4);
                  CASE Spec_Min[1] OF
                    'O' : SpecR_Min := 10;
                    'B' : SpecR_Min := 20;
                    'A' : SpecR_Min := 30;
                    'G' : SpecR_Min := 40;
                    'F' : SpecR_Min := 50;
                    'K' : SpecR_Min := 60;
                    'M' : SpecR_Min := 70;
                    'L' : SpecR_Min := 80;
                    'T' : SpecR_Min := 90;
                  END;
                  CASE Spec_Max[1] OF
                    'O' : SpecR_Max := 10;
                    'B' : SpecR_Max := 20;
                    'A' : SpecR_Max := 30;
                    'G' : SpecR_Max := 40;
                    'F' : SpecR_Max := 50;
                    'K' : SpecR_Max := 60;
                    'M' : SpecR_Max := 70;
                    'L' : SpecR_Max := 80;
                    'T' : SpecR_Max := 90;
                  END;
                  CASE Spec3[3] OF
                    'O' : IF (SpecR_Min <= 10) AND ((SpecR_Max >= 10)) THEN Color := Cyan ELSE Color := Black;
                    'B' : IF (SpecR_Min <= 20) AND ((SpecR_Max >= 20)) THEN Color := White ELSE Color := Black;
                    'A' : IF (SpecR_Min <= 30) AND ((SpecR_Max >= 30)) THEN Color := White ELSE Color := Black;
                    'G' : IF (SpecR_Min <= 40) AND ((SpecR_Max >= 40)) THEN Color := Yellow ELSE Color := Black;
                    'F' : IF (SpecR_Min <= 50) AND ((SpecR_Max >= 50)) THEN Color := Yellow ELSE Color := Black;
                    'K' : IF (SpecR_Min <= 60) AND ((SpecR_Max >= 60)) THEN Color := Brown ELSE Color := Black;
                    'M' : IF (SpecR_Min <= 70) AND ((SpecR_Max >= 70)) THEN Color := Red ELSE Color := Black;
                    'L' : IF (SpecR_Min <= 80) AND ((SpecR_Max >= 80)) THEN Color := Red ELSE Color := Black;
                    'T' : IF (SpecR_Min <= 90) AND ((SpecR_Max >= 90)) THEN Color := Red ELSE Color := Black;
                    ELSE Color := Black;
                  END;
                  IF z2 <> 0 THEN x2 := x2/z2;
                  IF z2 <> 0 THEN y2 := y2/z2;
                  PutPixel(320-Round(x2*Zoom)+Round(MX),240-Round(y2*Zoom)+Round(MY),Color);
                UNTIL EoF(f2);
                Close(f2);
                Circle(320+Round(MX),240+Round(MY),2);
                SetTextStyle(2,0,4);
                OutTextXY(325+Round(MX),230+Round(MY),'Sol');
                FOR i := 1 TO Round(Numb) DO BEGIN
                  Assign(f,'exo/'+ParamStr(6+i)+'.EXO');
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
                  Trigonomodus(deg);
                  x2 := Distance*Cos(Deklination)*Cos(Rectaszension);
                  y2 := Distance*Cos(Deklination)*Sin(Rectaszension);
                  z2 := Distance*Sin(Deklination);
                  IF z2 <> 0 THEN x2 := x2/z2;
                  IF z2 <> 0 THEN y2 := y2/z2;
                  CASE SpectralType[1] OF
                    'O'         : Color := Cyan;
                    'B','A'     : Color := White;
                    'G','F'     : Color := Yellow;
                    'K'         : Color := Brown;
                    'M','L','T' : Color := Red;
                    ELSE Color := Black;
                  END;
                  SetColor(Color);
                  Circle(320-Round(x2*Zoom)+Round(MX),240-Round(y2*Zoom)+Round(MY),2);
                  SetTextStyle(2,0,4);
                  OutTextXY(325-Round(x2*Zoom)+Round(MX),230-Round(y2*Zoom)+Round(MY),Centralstar);
                  SetTextStyle(2,0,5);
                  SetColor(White);
                  Str(Distance:0:3,Str4);
                  OutTextXY(5,420+(10*Round(Numb)),Centralstar+': '+Str4+' Parsec');
                END;
                SetColor(15);
                SetTextStyle(2,0,4);
                OutTextXY(10,2,'(C) 1995-2005 EXO-DB2 1.5 * Michael Johne * http://www.exodb.de.vu');
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
                  IF ParamStr(1) = 'all' THEN OutTextXY(360,210,'STAR3D') ELSE OutTextXY(360,210,ParamStr(6+i));
                    SetColor(LightGreen);
                    OutTextXY(270,230,'1 - Format PCX');
                    OutTextXY(270,240,'2 - Format BMP');
                    OutTextXY(270,250,'0 - Abbruch');
                    REPEAT
                      Input := ReadKey;
                    UNTIL Input IN ['0','1','2'];
                    LoadImage(0+200,0+200,'image.tmp');
                    IF NOT(DirExists('STAR3D')) THEN MkDir('STAR3D');
                      CASE Input OF
                        '1' : IF ParamStr(1) = 'all' THEN SavePCX('STAR3D/'+'STAR3D.PCX')
                              ELSE SavePCX('STAR3D/'+ParamStr(6+i)+'.PCX');
                        '2' : IF ParamStr(1) = 'all' THEN SaveBMP('STAR3D/'+'STAR3D') ELSE SaveBMP('STAR3D/'+ParamStr(6+i));
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
                     END{ ELSE IF Input IN ['P','p'] THEN GraftoPrint};
                   END;
                  CloseGraph;
                END;
              END;
            END;
          END;
        END;
      END;
    END;
END.
