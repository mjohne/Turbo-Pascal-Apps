PROGRAM Plugin_Distribution;

USES Crt,Dos,Graph,Printer,RT_Watch;

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
  Fil               : ARRAY[1..3] OF STRING;
  Input             : Char;
  Control,i,Numb,
  Zoom,
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
  Dis_Metalicity,
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

BEGIN
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF ParamStr(1) = '' THEN BEGIN
    WriteLn(^j^j'Der Parameter als Anzahl der darzustellenden Distribution fehlt!');
    ReadKey;
    Halt;
  END ELSE BEGIN
    Val(ParamStr(1),Numb,Control);
    IF (Control <> 0) OR (Numb=0) THEN BEGIN
      WriteLn(^j^j'Der eingegebene Zahlenwert ',ParamStr(1),' ist ung�ltig.');
      WriteLn('Es sind die Zahlen von 1 bis 3 erlebt.');
      ReadKey;
      Halt;
    END;
  END;
  FindFirst('EXO\*.EXO',AnyFile,SearchFile);
  WHILE DosError = 0 DO BEGIN
    Assign(f,'exo/'+SearchFile.Name);
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
    IF Metalicity[1] <> -0 THEN Metalicity[1] := Metalicity[1]+1;
    Inc(Dis_Eccentricity[Round(Eccentricity[1]*10)]);
    Inc(Dis_PlanetMass[Round(PlanetMass[1])]);
    Inc(Dis_SemiMajorAxis[Round(SemiMajorAxis[1])]);
    IF Metalicity[1] <> -0 THEN Inc(Dis_Metalicity[Round(Metalicity[1]*10)]);
    ClrEol;
    Write(^m,SearchFile.Name);
    FindNext(SearchFile);
  END;
  grDriver := Detect;
  InitGraph(grDriver,grMode,'');
  SetFillStyle(SolidFill,White);
  Bar(20,20,520,420);
  SetFillStyle(SolidFill,LightBlue);
  SetColor(Black);
  CASE Numb OF
    1: FOR i := 1 TO 10 DO BEGIN
         Bar((i*40)+30,420-Round(8*Dis_Eccentricity[i-1]),(i*40)+40+30,420);
         Rectangle((i*40)+30,420-Round(8*Dis_Eccentricity[i-1]),(i*40)+40+30,420);
       END;
    2: FOR i := 1 TO 15 DO BEGIN
         Bar((i*30),420-Round(8*Dis_PlanetMass[i-1]),(i*30)+30,420);
         Rectangle((i*30),420-Round(8*Dis_PlanetMass[i-1]),(i*30)+30,420);
       END;
    3: FOR i := 1 TO 10 DO BEGIN
         Bar((i*40)+30,420-Round(4*Dis_SemiMajorAxis[i-1]),(i*40)+40+30,420);
         Rectangle((i*40)+30,420-Round(4*Dis_SemiMajorAxis[i-1]),(i*40)+40+30,420);
       END;
{    4: FOR i := 1 TO 1000 DO BEGIN
         SetColor(Blue);
         Bar((i*20)+10,420-Round(8*Dis_Metalicity[i-1]),(i*20)+10+10,420);
         Rectangle((i*20)+10,420-Round(8*Dis_Metalicity[i-1]),(i*20)+10+10,420);
       END;}
  END;
  SetTextStyle(2,0,8);
  SetColor(Black);
  CASE Numb OF
    1: OutTextXY(50,40,'Distribution: Bahnexzentrizit�t');
    2: OutTextXY(50,40,'Distribution: Exoplaneten-Masse');
    3: OutTextXY(60,40,'Distribution: Gro�e Halbachse');
    {4: OutTextXY(60,40,'Distribution: Metallizit�t [Fe/H]');}
  END;
  SetTextStyle(2,0,5);
  SetColor(LightGreen);
  CASE Numb OF
    1: FOR i := 1 TO 10 DO BEGIN
         Str((i*0.1)-0.1:0:1,Strin[1]);
         Str(Dis_Eccentricity[i-1],Strin[2]);
         OutTextXY(550,37+(i*10)+(3*i),Strin[1]+': '+Strin[2]);
       END;
    2: FOR i := 1 TO 15 DO BEGIN
         Str((i)-1,Strin[1]);
         Str(Dis_PlanetMass[i-1],Strin[2]);
         OutTextXY(550,37+(i*10)+(3*i),Strin[1]+' Mjup: '+Strin[2]);
       END;
    3: FOR i := 1 TO 10 DO BEGIN
         Str((i)-1,Strin[1]);
         Str(Dis_SemiMajorAxis[i-1],Strin[2]);
         OutTextXY(550,37+(i*10)+(3*i),Strin[1]+' AE: '+Strin[2]);
       END;
{    4: FOR i := 1 TO 1000 DO BEGIN
         Str((i)-1,Strin[1]);
         Str(Dis_Metalicity[i-1],Strin[2]);
         OutTextXY(550,-1200+(i*10)+(3*i),Strin[1]+': '+Strin[2]);
       END;}
  END;
  SetColor(White);
  CASE Numb OF
    1: FOR i := 1 TO 10 DO BEGIN
         Str((i*0.1)-0.1:0:1,Strin[1]);
         OutTextXY(42+(i*37)+(3*i),430,Strin[1]);
       END;
    2: FOR i := 1 TO 15 DO BEGIN
         Str(i-1,Strin[1]);
         OutTextXY(10+(i*25)+(5*i),430,Strin[1]);
         OutTextXY(500,430,'Jupitermassen');
       END;
    3: FOR i := 1 TO 10 DO BEGIN
         Str(i-1,Strin[1]);
         OutTextXY(46+(i*37)+(3*i),430,Strin[1]);
         OutTextXY(500,430,'Astron. Einheiten');
       END;
{    4: FOR i := 1 TO 10 DO BEGIN
         Str(i-1,Strin[1]);
         OutTextXY(46+(i*37)+(3*i),430,Strin[1]);
         OutTextXY(500,430,'Astron. Einheiten');
       END;}
  END;
  SetColor(Cyan);
  SetTextStyle(2,0,4);
  OutTextXY(20,2,'(C) 1995-2005 EXODB2 Michael Johne * http://www.die-exoplaneten.de.vu');
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
    CASE Numb OF
      1: OutTextXY(360,210,'ECC');
      2: OutTextXY(360,210,'MASS');
      3: OutTextXY(360,210,'AXIS');
    END;
    SetColor(White);
    OutTextXY(270,230,'1 - Format PCX');
    OutTextXY(270,240,'2 - Format BMP');
    OutTextXY(270,250,'0 - Abbruch');
    REPEAT
      Input := ReadKey;
    UNTIL Input IN ['0','1','2'];
    LoadImage(0+200,0+200,'image.tmp');
    IF NOT(DirExists('DISTRI')) THEN MkDir('DISTRI');
    CASE Input OF
      '1' :
        CASE Numb OF
          1: SavePCX('DISTRI/'+'ECC'+'.PCX');
          2: SavePCX('DISTRI/'+'MASS'+'.PCX');
          3: SavePCX('DISTRI/'+'AXIS'+'.PCX');
        END;
      '2' :
        CASE Numb OF
          1: SaveBMP('DISTRI/'+'ECC');
          2: SaveBMP('DISTRI/'+'MASS');
          3: SaveBMP('DISTRI/'+'AXIS');
        END;
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
  END;
  CloseGraph;
END.
