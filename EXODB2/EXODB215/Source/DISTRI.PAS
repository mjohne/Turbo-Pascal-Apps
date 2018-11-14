PROGRAM Plugin_Distribution;

USES Crt,Dos,Graph,RT_Watch,BGI2PRN;

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
  DiscoveryDate2    : ARRAY[0..2100] OF Word;
  Input             : Char;
  Control,i,Numb,
  Zoom,n,
  grDriver,grMode   : Integer;
  a,p,e,b,c,
  regs              : Registers;
  SearchFile        : SearchRec;
  f                 : Text;
  DisYearCorr,
  DisYearSum,
  DisYearMin,
  DisYearMax        : Word;
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
  Dis_SpectralType,
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
  TextBackground(Black);
  TextColor(White);
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF ParamStr(1) = '' THEN BEGIN
    ClrScr;
    WriteLn(^j^j'Der Parameter als Anzahl der darzustellenden Distribution fehlt!');
    ReadKey;
    Halt;
  END ELSE BEGIN
    Val(ParamStr(1),Numb,Control);
    IF (Control <> 0) THEN BEGIN
      ClrScr;
      WriteLn(^j^j'Der eingegebene Zahlenwert ',ParamStr(1),' ist ungÅltig.');
      WriteLn('Es sind die Zahlen von 0 bis 4 erlebt.');
      ReadKey;
      Halt;
    END;
  END;
  DisYearMin := 2000;
  DisYearMax := 2000;
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
    CASE Numb OF
      0,4 : BEGIN
              IF (Numb = 4) OR (Numb = 0) THEN BEGIN
                Val(DiscoveryDate[1][1]+DiscoveryDate[1][2]+DiscoveryDate[1][3]+DiscoveryDate[1][4],DisYearCorr,Control);
                Inc(DiscoveryDate2[DisYearCorr]);
                IF DisYearCorr < DisYearMin THEN DisYearMin := DisYearCorr;
                IF DisYearCorr > DisYearMax THEN DisYearMax := DisYearCorr;
              END;
            END;
      1 : Inc(Dis_Eccentricity[Round(Eccentricity[1]*10)]);
      2 : Inc(Dis_PlanetMass[Round(PlanetMass[1])]);
      3 : Inc(Dis_SemiMajorAxis[Round(SemiMajorAxis[1])]);
      5 : BEGIN
            IF (SpectralType[1][1] = 'O') OR (SpectralType[1][1] = 'o') THEN Inc(Dis_SpectralType[1]) ELSE
            IF (SpectralType[1][1] = 'B') OR (SpectralType[1][1] = 'B') THEN Inc(Dis_SpectralType[2]) ELSE
            IF (SpectralType[1][1] = 'A') OR (SpectralType[1][1] = 'A') THEN Inc(Dis_SpectralType[3]) ELSE
            IF (SpectralType[1][1] = 'F') OR (SpectralType[1][1] = 'F') THEN Inc(Dis_SpectralType[4]) ELSE
            IF (SpectralType[1][1] = 'G') OR (SpectralType[1][1] = 'G') THEN Inc(Dis_SpectralType[5]) ELSE
            IF (SpectralType[1][1] = 'K') OR (SpectralType[1][1] = 'K') THEN Inc(Dis_SpectralType[6]) ELSE
            IF (SpectralType[1][1] = 'M') OR (SpectralType[1][1] = 'M') THEN Inc(Dis_SpectralType[7]) ELSE
            IF (SpectralType[1][1] = 'L') OR (SpectralType[1][1] = 'L') THEN Inc(Dis_SpectralType[8]) ELSE
            IF (SpectralType[1][1] = 'T') OR (SpectralType[1][1] = 'T') THEN Inc(Dis_SpectralType[9]) ELSE
              Inc(Dis_SpectralType[0]);
          END;
      6 : IF Distance[1] < 100 THEN Inc(Dis_PlanetMass[Round(Distance[1]/10)]) ELSE Inc(Dis_PlanetMass[10]);
      7 : IF Magnitude[1] < 10 THEN Inc(Dis_PlanetMass[Round(Magnitude[1])]) ELSE Inc(Dis_PlanetMass[10]);
      8 : BEGIN
            Metalicity[1] := Metalicity[1]*10;
            CASE Round(Metalicity[1]) OF
              -5 : Inc(Dis_PlanetMass[1]);
              -4 : Inc(Dis_PlanetMass[2]);
              -3 : Inc(Dis_PlanetMass[3]);
              -2 : Inc(Dis_PlanetMass[4]);
              -1 : Inc(Dis_PlanetMass[5]);
               0 : Inc(Dis_PlanetMass[6]);
               1 : Inc(Dis_PlanetMass[7]);
               2 : Inc(Dis_PlanetMass[8]);
               3 : Inc(Dis_PlanetMass[9]);
               4 : Inc(Dis_PlanetMass[10]);
               5 : Inc(Dis_PlanetMass[11]);
            END;
          END;
      9 : IF StarMass[1] < 1.5 THEN Inc(Dis_PlanetMass[Round(StarMass[1]*10)])
            ELSE Inc(Dis_PlanetMass[0]);
    END;
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
         Bar((i*30),420-Round(6*Dis_PlanetMass[i-1]),(i*30)+30,420);
         Rectangle((i*30),420-Round(6*Dis_PlanetMass[i-1]),(i*30)+30,420);
       END;
    3: FOR i := 1 TO 10 DO BEGIN
         Bar((i*40)+30,420-Round(4*Dis_SemiMajorAxis[i-1]),(i*40)+40+30,420);
         Rectangle((i*40)+30,420-Round(4*Dis_SemiMajorAxis[i-1]),(i*40)+40+30,420);
       END;
    0,4: BEGIN
         SetFillStyle(SolidFill,LightRed);
         n := Round(450/(DisYearMax-DisYearMin)+1);
         FOR i := 1 TO (DisYearMax-DisYearMin)+1 DO BEGIN
           IF Numb = 0 THEN BEGIN
             DisYearSum := DisYearSum+DiscoveryDate2[DisYearMin+i-1];
             SetColor(DarkGray);
             IF i <> 1 THEN
               Line(20+((i-1)*(n))-30,410-2*Round(1*DisYearSum-DiscoveryDate2[DisYearMin+i-1]),
                 20+(i*(n))-30,410-2*Round(1*DisYearSum));
           END;
           SetColor(Blue);
           IF Numb = 0 THEN BEGIN
             IF i <> 1 THEN
               Line(20+((i-1)*(n))-30,410-2*Round(DiscoveryDate2[DisYearMin-1+(i-1)]),
                 20+(i*(n))-30,410-2*Round(DiscoveryDate2[DisYearMin-1+i]));
             SetColor(Red);
             Bar(20+(i*(n))-30-1,410-2*Round(DiscoveryDate2[DisYearMin-1+i]+1),
               20+(i*(n))-30+2,410-2*Round(DiscoveryDate2[DisYearMin-1+i])+2);
           END ELSE BEGIN
             IF i <> 1 THEN
               Line(20+((i-1)*(n))-30,410-Round(10*DiscoveryDate2[DisYearMin-1+(i-1)]),
                 20+(i*(n))-30,410-Round(10*DiscoveryDate2[DisYearMin-1+i]));
             SetColor(Red);
             Bar(20+(i*(n))-30-1,410-Round(10*DiscoveryDate2[DisYearMin-1+i]+1),
               20+(i*(n))-30+2,410-Round(10*DiscoveryDate2[DisYearMin-1+i])+2);
           END;
           Str(i-1+DisYearMin,Strin[1]);
           Str(Discoverydate2[i-1+DisYearMin],Strin[2]);
           IF Numb = 0 THEN BEGIN
             Str(DisYearSum,Strin[3]);
             SetTextStyle(2,0,5);
             SetColor(LightGreen);
             OutTextXY(530,37+(i*10)+(3*i),Strin[1]+': '+Strin[2]+' ('+Strin[3]+')');
           END ELSE BEGIN
             Str(DisYearSum,Strin[3]);
             SetTextStyle(2,0,5);
             SetColor(LightGreen);
             OutTextXY(530,37+(i*10)+(3*i),Strin[1]+': '+Strin[2]);
           END;
           SetTextStyle(2,1,4);
           SetColor(White);
           OutTextXY(20+((i)*(n))-30,430,Strin[1]);
           SetTextStyle(2,0,5);
           OutTextXY(530,430,'Jahre');
         END;
       END;
    5: FOR i := 1 TO 9 DO BEGIN
         Bar((i*40)+30,420-Round(3*Dis_SpectralType[i]),(i*40)+40+30,420);
         Rectangle((i*40)+30,420-Round(3*Dis_SpectralType[i]),(i*40)+40+30,420);
       END;
    6: FOR i := 0 TO 10 DO BEGIN
         Bar((i*40)+30,420-Round(6*Dis_PlanetMass[i]),(i*40)+40+30,420);
         Rectangle((i*40)+30,420-Round(6*Dis_PlanetMass[i]),(i*40)+40+30,420);
       END;
    7: FOR i := 0 TO 10 DO BEGIN
         Bar((i*40)+30,420-Round(6*Dis_PlanetMass[i]),(i*40)+40+30,420);
         Rectangle((i*40)+30,420-Round(6*Dis_PlanetMass[i]),(i*40)+40+30,420);
       END;
    8: FOR i := 1 TO 11 DO BEGIN
         Bar((i*40)+30,420-Round(6*Dis_PlanetMass[i]),(i*40)+40+30,420);
         Rectangle((i*40)+30,420-Round(6*Dis_PlanetMass[i]),(i*40)+40+30,420);
       END;
    9: FOR i := 1 TO 15 DO BEGIN
         Bar((i*30),420-Round(6*Dis_PlanetMass[i-1]),(i*30)+30,420);
         Rectangle((i*30),420-Round(6*Dis_PlanetMass[i-1]),(i*30)+30,420);
       END;
  END;
  SetTextStyle(2,0,8);
  SetColor(Black);
  CASE Numb OF
    1: OutTextXY(40,40,'ZÑhlung: BahnexzentrizitÑt');
    2: OutTextXY(40,40,'ZÑhlung: Exoplaneten-Masse');
    3: OutTextXY(40,40,'ZÑhlung: Gro·e Halbachse');
    4,0: OutTextXY(40,40,'JÑhrliche Entdeckung');
    5: OutTextXY(40,40,'ZÑhlung: Spektralklasse');
    6: OutTextXY(40,40,'ZÑhlung: Distanz zu Sonne');
    7: OutTextXY(23,40,'ZÑhlung: Scheinbare Helligkeit');
    8: OutTextXY(40,40,'ZÑhlung: MetallizitÑt');
    9: OutTextXY(40,40,'ZÑhlung: Zentralstern-Masse');
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
    5: FOR i := 0 TO 9 DO BEGIN
         CASE i OF
           0 : Strin[1] := '-';
           1 : Strin[1] := 'O';
           2 : Strin[1] := 'B';
           3 : Strin[1] := 'A';
           4 : Strin[1] := 'F';
           5 : Strin[1] := 'G';
           6 : Strin[1] := 'K';
           7 : Strin[1] := 'M';
           8 : Strin[1] := 'L';
           9 : Strin[1] := 'T';
         END;
         Str(Dis_SpectralType[i],Strin[2]);
         OutTextXY(550,37+(i*10)+(3*i),Strin[1]+': '+Strin[2]);
       END;
    6: FOR i := 1 TO 11 DO BEGIN
         Str((i)-1,Strin[1]);
         Strin[1] := Strin[1]+'0';
         Str((i),Strin[2]);
         Strin[1] := Strin[1]+'-'+Strin[2]+'0';
         Str(Dis_PlanetMass[i-1],Strin[2]);
         IF i = 11 THEN OutTextXY(530,37+(i*10)+(3*i),'> 100 pc: '+Strin[2])
           ELSE OutTextXY(530,37+(i*10)+(3*i),Strin[1]+' pc: '+Strin[2]);
       END;
    7: FOR i := 1 TO 11 DO BEGIN
         Str((i)-1,Strin[1]);
         Strin[1] := Strin[1];
         Str((i),Strin[2]);
         Strin[1] := Strin[1]+'-'+Strin[2];
         Str(Dis_PlanetMass[i-1],Strin[2]);
         IF i = 11 THEN OutTextXY(530,37+(i*10)+(3*i),'> 10 mag: '+Strin[2])
           ELSE OutTextXY(530,37+(i*10)+(3*i),Strin[1]+' mag: '+Strin[2]);
       END;
    8: FOR i := 1 TO 11 DO BEGIN
         Str(((i)-6)/10:4:1,Strin[1]);
         Str(Dis_PlanetMass[i],Strin[2]);
         OutTextXY(530,37+(i*10)+(3*i),'Fe/H '+Strin[1]+': '+Strin[2]);
       END;
    9: FOR i := 1 TO 15 DO BEGIN
         Str((i*0.1):0:1,Strin[1]);
         Str(Dis_PlanetMass[i-1],Strin[2]);
         OutTextXY(530,37+(i*10)+(3*i),Strin[1]+' Msol: '+Strin[2]);
       END;
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
    5: FOR i := 1 TO 9 DO BEGIN
         CASE i OF
           1 : Strin[1] := 'O';
           2 : Strin[1] := 'B';
           3 : Strin[1] := 'A';
           4 : Strin[1] := 'F';
           5 : Strin[1] := 'G';
           6 : Strin[1] := 'K';
           7 : Strin[1] := 'M';
           8 : Strin[1] := 'L';
           9 : Strin[1] := 'T';
         END;
         OutTextXY(42+(i*37)+(3*i),430,Strin[1]);
         OutTextXY(500,430,'Spektraltyp');
       END;
    6: BEGIN
         SetTextStyle(2,0,4);
         FOR i := 1 TO 11 DO BEGIN
           Str((i)-1,Strin[1]);
           Strin[1] := Strin[1]+'0';
           Str((i),Strin[2]);
           Strin[1] := Strin[1]+'-'+Strin[2]+'0';
           IF i = 11 THEN OutTextXY((i*37)+(3*i)-5,430,' >100')
             ELSE OutTextXY((i*37)+(3*i)-5,430,Strin[1]);
         END;
         SetTextStyle(2,0,5);
         OutTextXY(400,460,'Distanz zur Sonne in Parsec');
       END;
    7: BEGIN
         SetTextStyle(2,0,4);
         FOR i := 1 TO 11 DO BEGIN
           Str((i)-1,Strin[1]);
           Strin[1] := Strin[1];
           Str((i),Strin[2]);
           Strin[1] := Strin[1]+'-'+Strin[2];
           IF i = 11 THEN OutTextXY((i*37)+(3*i)-5,430,' >10')
             ELSE OutTextXY((i*37)+(3*i)-5,430,Strin[1]);
         END;
         SetTextStyle(2,0,5);
         OutTextXY(400,460,'Scheinbare Helligkeit im mag');
       END;
    8: BEGIN
         SetTextStyle(2,0,4);
         FOR i := 1 TO 11 DO BEGIN
           Str(((i)-6)/10:4:1,Strin[1]);
           Str(Dis_PlanetMass[i],Strin[2]);
           OutTextXY((i*37)+(3*i)+40,430,Strin[1]);
         END;
         SetTextStyle(2,0,5);
         OutTextXY(400,460,'MetallizitÑt (Fe/H)');
       END;
    9: FOR i := 1 TO 15 DO BEGIN
         Str((i*0.1):0:1,Strin[1]);
         OutTextXY(7+(i*25)+(5*i),430,Strin[1]);
         OutTextXY(500,430,'in Sonnenmassen');
       END;
  END;
  SetColor(Cyan);
  SetTextStyle(2,0,4);
  OutTextXY(20,2,'(C) 1995-2005 EXODB2 1.5 * Michael Johne * http://www.exodb.de.vu');
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
      4: OutTextXY(360,210,'YEAR');
      0: OutTextXY(360,210,'YEAR2');
      5: OutTextXY(360,210,'SPEC');
      6: OutTextXY(360,210,'DISTANCE');
      7: OutTextXY(360,210,'VMAG');
      8: OutTextXY(360,210,'METAL');
      9: OutTextXY(360,210,'STARMASS');
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
          4: SavePCX('DISTRI/'+'YEAR'+'.PCX');
          0: SavePCX('DISTRI/'+'YEAR2'+'.PCX');
          5: SavePCX('DISTRI/'+'SPEC'+'.PCX');
          6: SavePCX('DISTRI/'+'DISTANCE'+'.PCX');
          7: SavePCX('DISTRI/'+'VMAG'+'.PCX');
          8: SavePCX('DISTRI/'+'METAL'+'.PCX');
          9: SavePCX('DISTRI/'+'STARMASS'+'.PCX');
        END;
      '2' :
        CASE Numb OF
          1: SaveBMP('DISTRI/'+'ECC');
          2: SaveBMP('DISTRI/'+'MASS');
          3: SaveBMP('DISTRI/'+'AXIS');
          4: SaveBMP('DISTRI/'+'YEAR');
          0: SaveBMP('DISTRI/'+'YEAR2');
          5: SaveBMP('DISTRI/'+'SPEC');
          6: SaveBMP('DISTRI/'+'DISTANCE');
          7: SaveBMP('DISTRI/'+'VMAG');
          8: SaveBMP('DISTRI/'+'METAL');
          9: SaveBMP('DISTRI/'+'STARMASS');
        END;
      '0' : BEGIN
              DeleteFile('image.tmp');
              Exit;
            END;
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
END.
