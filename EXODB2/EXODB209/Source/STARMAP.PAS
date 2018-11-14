PROGRAM Plugin_Starmap;

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
   {br}   128,2,         { (2x256)+128 = 640 pixels }
          0,0,
   {ho}   224,1,         { (1x256)+224 = 480 pixels }
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
  Input           : Char;
  Control,i,n,
  Numb,Numb2,Numb3,
  grDriver,grMode : Integer;
  a,p,e,b,c,x,y,
  Zoom,x2,y2      : Real;
  regs            : Registers;
  TempStr,
  Declination2,
  Rectaszension2  : STRING;
  f,f2            : Text;
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
  Declination,
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
    ReadLn(f2,Centralstar[0]);
    ReadLn(f2,SpectralType[0]);
    ReadLn(f2,Magnitude[0]);
    ReadLn(f2,StarMass[0]);
    ReadLn(f2,Metalicity[0]);
    ReadLn(f2,Distance[0]);
    ReadLn(f2,Rectaszension[0]);
    ReadLn(f2,Declination[0]);
    ReadLn(f2,Constellation[0]);
    ReadLn(f2,PlanetName[0]);
    ReadLn(f2,PlanetMass[0]);
    ReadLn(f2,SemiMajorAxis[0]);
    ReadLn(f2,Period[0]);
    ReadLn(f2,Eccentricity[0]);
    ReadLn(f2,Method[0]);
    ReadLn(f2,DiscoveryDate[0]);
    ReadLn(f2,Discoverer[0]);
    ReadLn(f2,Remarks[0]);
    Close(f2);
    Rectaszension[0] := 10*Rectaszension[0];
    Rectaszension[0] := (Rectaszension[0]*360)/240;
    Rectaszension[0] := 360-Rectaszension[0];
    Declination[0]   := -(Declination[0])+90;
    PutPixel(Round(Zoom*Rectaszension[0]),Round(Zoom*Declination[0]),Red);
    SetColor(Red);
    Circle(Round(Zoom*Rectaszension[0]),Round(Zoom*Declination[0]),2);
    Findnext(f);
  END;
END;

BEGIN
  Zoom := 1.72;
  IF NOT(DirExists('EXO')) THEN MkDir('EXO');
  IF ParamStr(1) = '' THEN BEGIN
    WriteLn(^j^j'Der Parameter als Anzahl der darzustellende DatensÑtze fehlt!');
    WriteLn('    -  STARMAP.EXE [anzahl] [dateiname]');
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
        WriteLn(^j^j'Der eingegebene Zahlenwert ',ParamStr(1),' ist ungÅltig.');
        WriteLn('Es sind alle Zahlen von 1 bis x erlebt; je nachdem wieviel');
        WriteLn('DatensÑtze vorliegen Im Verzeichnis "EXO" vorliegen.');
        ReadKey;
        Halt;
      END;
    END;
    IF (ParamStr(3+Numb) = '1') AND (ParamStr(1) = '1') THEN Zoom := 7;
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
          ReadLn(f,Declination[i]);
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
          x2 := Rectaszension[i];
          y2 := Declination[i];
          Rectaszension[i] := 10*Rectaszension[i];
          Rectaszension[i] := (Rectaszension[i]*360)/240;
          Rectaszension[i] := 360-Rectaszension[i];
          Declination[i]   := -(Declination[i])+90;
          IF (Numb = 1) AND (ParamStr(3+Numb) = '1') THEN BEGIN
            x := (640/2)-(Zoom*Rectaszension[i]);
            y := (480/2)-(Zoom*Declination[i]);
            IF (Zoom*Rectaszension[i]) < 640/2 THEN x := 0;
            IF (Zoom*Declination[i]) < 480/2 THEN y := 0;
            IF x2 < 3 THEN x := -Zoom*268;
            IF y2 < -40 THEN y := -Zoom*110;
          END;
        END;
      END;
      IF NOT(FileExists('stars.lst')) THEN BEGIN
        WriteLn(^j^j'Die Datei "stars.lst" wurde nicht gefunden!');
        WriteLn('Sie ist fÅr die Darstellung der Sterne wichtig.');
        ReadKey;
      END;
      IF NOT(FileExists('stars2.lst')) THEN BEGIN
        WriteLn(^j^j'Die Datei "stars2.lst" wurde nicht gefunden!');
        WriteLn('Sie ist fÅr die Darstellung der Sterne bei Vergrîsserung wichtig.');
        ReadKey;
      END;
      IF NOT(FileExists('clines.lst')) THEN BEGIN
        WriteLn(^j^j'Die Datei "clines.lst" wurde nicht gefunden!');
        WriteLn('Sie ist fÅr die Darstellung der Sternbilder wichtig.');
        ReadKey;
      END;
      IF NOT(FileExists('eclip.lst')) THEN BEGIN
        WriteLn(^j^j'Die Datei "eclip.lst" wurde nicht gefunden!');
        WriteLn('Sie ist fÅr die Darstellung der Ekliptik wichtig.');
        ReadKey;
      END;
      IF NOT(FileExists('cnames.lst')) THEN BEGIN
        WriteLn(^j^j'Die Datei "cnames.lst" wurde nicht gefunden!');
        WriteLn('Sie ist fÅr die Benennung der Sternbilder wichtig.');
        ReadKey;
      END;
      IF NOT(FileExists('starname.lst')) THEN BEGIN
        WriteLn(^j^j'Die Datei "starname.lst" wurde nicht gefunden!');
        WriteLn('Sie ist fÅr die Benennung der Sterne wichtig.');
        ReadKey;
      END;
{      IF NOT(FileExists('cbounds.lst')) THEN BEGIN
        WriteLn(^j^j'Die Datei "cbounds.lst" wurde nicht gefunden!');
        WriteLn('Sie ist fÅr die Darstellung der Sternbilder wichtig.');
        ReadKey;
      END;}
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
      SetFillStyle(SolidFill,Blue);
      Bar(0,0,Round(Zoom*360),Round(Zoom*180));
      SetFillStyle(SolidFill,Yellow);
      SetTextStyle(2,0,4);
      IF Numb3 >= 8 THEN BEGIN
        IF (ParamStr(3+Numb) <> '1') THEN BEGIN
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
      END;
      SetLineStyle(0,0,1);
      IF Numb3 >= 4 THEN BEGIN
        Dec(Numb3,4);
        SetColor(Green);
        IF (ParamStr(3+Numb) <> '1') THEN Line(0,Round((Zoom*180)/2),Round(Zoom*360),Round((Zoom*180)/2));
        SetColor(Cyan);
        IF FileExists('eclip.lst') THEN BEGIN
          Assign(f,'eclip.lst');
          Reset(f);
          Rectaszension[0] := 0;
          Declination[0]   := 0;
          Rectaszension[0] := 10*Rectaszension[0];
          Rectaszension[0] := (Rectaszension[0]*360)/240;
          Rectaszension[0] := 360-Rectaszension[0];
          Declination[0]   := -(Declination[0])+90;
          MoveTo(Round(Zoom*Rectaszension[0]+x),Round(Zoom*Declination[0]+y));
          REPEAT
            Read(f,Rectaszension[0]);
            ReadLn(f,Declination[0]);
            {Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor}
            Rectaszension[0] := 10*Rectaszension[0];
            Rectaszension[0] := (Rectaszension[0]*360)/240;
            Rectaszension[0] := 360-Rectaszension[0];
            Declination[0]   := -(Declination[0])+90;
            LineTo(Round(Zoom*Rectaszension[0]+x),Round(Zoom*Declination[0]+y));
          UNTIL EoF(f);
          Close(f);
        END;
      END;
      IF Numb3 >= 2 THEN BEGIN
        Dec(Numb3,2);
        SetColor(DarkGray);
        IF FileExists('clines.lst') THEN BEGIN
          Assign(f,'clines.lst');
          Reset(f);
          REPEAT
            ReadLn(f,Numb2);
            FOR i := 1 TO 6 DO Read(f,Coordinates[i]);
            ReadLn(f);
            Rectaszension[0] := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
            Declination[0] := Coordinates[4]+(Coordinates[5]/60)+(Coordinates[6]/3600);
            {Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor}
            Rectaszension[0] := 10*Rectaszension[0];
            Rectaszension[0] := (Rectaszension[0]*360)/240;
            Rectaszension[0] := 360-Rectaszension[0];
            Declination[0]   := -(Declination[0])+90;
            MoveTo(Round((Zoom*Rectaszension[0]+x)),Round((Zoom*Declination[0]+y)));
            FOR n := 1 TO Numb2-1 DO BEGIN
              FOR i := 1 TO 6 DO Read(f,Coordinates[i]);
              ReadLn(f);
              Rectaszension[0] := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
              Declination[0] := Coordinates[4]+(Coordinates[5]/60)+(Coordinates[6]/3600);
              {Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor}
              Rectaszension[0] := 10*Rectaszension[0];
              Rectaszension[0] := (Rectaszension[0]*360)/240;
              Rectaszension[0] := 360-Rectaszension[0];
              Declination[0]   := -(Declination[0])+90;
              LineTo(Round((Zoom*Rectaszension[0]+x)),Round((Zoom*Declination[0])+y));
            END;
          UNTIL EoF(f);
          Close(f);
        END;
      END;
{        SetColor(LightGray);
        IF FileExists('cbounds.lst') THEN BEGIN
          Assign(f,'cbounds.lst');
          Reset(f);
          REPEAT
            FOR i := 1 TO 3 DO Read(f,Coordinates[i]);
            ReadLn(f);
            Rectaszension[0] := Coordinates[2]/1000;
            Declination[0] := Coordinates[3]/100;
            Rectaszension[0] := 10*Rectaszension[0];
            Rectaszension[0] := (Rectaszension[0]*360)/240;
            Rectaszension[0] := 360-Rectaszension[0];
            Declination[0]   := -(Declination[0])+90;
            IF Coordinates[1] = 0 THEN MoveTo(Round((Zoom*Rectaszension[0]+x)),Round((Zoom*Declination[0]+y)))
            ELSE IF Coordinates[1] = 1 THEN LineTo(Round((Zoom*Rectaszension[0]+x)),Round((Zoom*Declination[0]+y)));
          UNTIL EoF(f);
          Close(f);readkey;
        END;}
      IF ParamStr(3+Numb) = '1' THEN TempStr := 'stars2.lst' ELSE TempStr := 'stars.lst';
      IF FileExists(TempStr) THEN BEGIN
        SetColor(White);
        Assign(f,TempStr);
        Reset(f);
        REPEAT
          FOR i := 1 TO 6 DO Read(f,Coordinates[i]);
          ReadLn(f,Magnitude[0]);
          Rectaszension[0] := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
          Declination[0] := Coordinates[4]+(Coordinates[5]/60)+(Round(Coordinates[6])/3600);
          {Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor}
          Rectaszension[0] := 10*Rectaszension[0];
          Rectaszension[0] := (Rectaszension[0]*360)/240;
          Rectaszension[0] := 360-Rectaszension[0];
          Declination[0]   := -(Declination[0])+90;
          CASE Round(Magnitude[0]) OF
            7..10:
               PutPixel(Round((Zoom*Rectaszension[0])+x),Round((Zoom*Declination[0]+y)),LightGray);
            5..6:
               PutPixel(Round((Zoom*Rectaszension[0])+x),Round((Zoom*Declination[0]+y)),White);
            4: PutPixel(Round((Zoom*Rectaszension[0])+x),Round((Zoom*Declination[0]+y)),Yellow);
            3: IF ParamStr(3+Numb) = '1' THEN PieSlice(Round((Zoom*Rectaszension[0])+x),Round((Zoom*Declination[0]+y)),0,360,1)
               ELSE PieSlice(Round((Zoom*Rectaszension[0])+x),Round((Zoom*Declination[0]+y)),0,360,0);
            2: PieSlice(Round((Zoom*Rectaszension[0])+x),Round((Zoom*Declination[0]+y)),0,360,1);
            1: IF ParamStr(3+Numb) = '1' THEN PieSlice(Round((Zoom*Rectaszension[0])+x),Round((Zoom*Declination[0]+y)),0,360,2)
               ELSE PieSlice(Round((Zoom*Rectaszension[0])+x),Round((Zoom*Declination[0]+y)),0,360,1);
            0: PieSlice(Round((Zoom*Rectaszension[0])+x),Round((Zoom*Declination[0]+y)),0,360,2);
           -1..-50: PieSlice(Round((Zoom*Rectaszension[0])+x),Round(Zoom*Declination[0]+y),0,360,2);
          END;
        UNTIL EoF(f);
        Close(f);
      END;
      IF (Numb = 1) AND (ParamStr(3+Numb+1) = '1') THEN BEGIN
        SetTextStyle(2,0,5);
        SetColor(Yellow);
        IF FileExists('cnames.lst') THEN BEGIN
          Assign(f,'cnames.lst');
          Reset(f);
          REPEAT
            FOR i := 1 TO 2 DO Read(f,Coordinates[i]);
            Read(f,TempStr);
            ReadLn(f);
            Rectaszension[0] := Coordinates[1]/1000;
            Declination[0] := Coordinates[2]/100;
            {Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor}
            Rectaszension[0] := 10*Rectaszension[0];
            Rectaszension[0] := (Rectaszension[0]*360)/240;
            Rectaszension[0] := 360-Rectaszension[0];
            Declination[0]   := -(Declination[0])+90;
            OutTextXY(Round((Zoom*Rectaszension[0]+x)),Round((Zoom*Declination[0]+y)),TempStr);
          UNTIL EoF(f);
          Close(f);
        END;
      END;
      IF (Numb = 1) AND (ParamStr(3+Numb+2) = '1') THEN BEGIN
        SetTextStyle(2,0,4);
        SetColor(White);
        IF FileExists('starname.lst') THEN BEGIN
          Assign(f,'starname.lst');
          Reset(f);
          REPEAT
            FOR i := 1 TO 6 DO Read(f,Coordinates[i]);
            Read(f,TempStr);
            ReadLn(f);
            Rectaszension[0] := Coordinates[1]+(Coordinates[2]/60)+(Coordinates[3]/3600);
            Declination[0] := Coordinates[4]+(Coordinates[5]/60)+(Round(Coordinates[6])/3600);
            {Umrechung, Entspiegelung und Korrektur -> Anpassung an Monitor}
            Rectaszension[0] := 10*Rectaszension[0];
            Rectaszension[0] := (Rectaszension[0]*360)/240;
            Rectaszension[0] := 360-Rectaszension[0];
            Declination[0]   := -(Declination[0])+90;
            OutTextXY(Round((Zoom*Rectaszension[0]+x)),Round((Zoom*Declination[0]+y)),TempStr);
          UNTIL EoF(f);
          Close(f);
        END;
      END;
      IF ParamStr(1) = 'all' THEN BEGIN
        REPEAT
          SearchDir('exo\','*.exo');
        UNTIL DosError <> 0;
      END ELSE FOR i := 1 TO Numb DO BEGIN
        IF ParamStr(3+Numb) = '1' THEN BEGIN
          PutPixel(Round((Zoom*Rectaszension[i])+x),Round((Zoom*Declination[i])+y),Red);
          PutPixel(1+Round((Zoom*Rectaszension[i])+x),Round((Zoom*Declination[i])+y),Red);
          PutPixel(Round((Zoom*Rectaszension[i])+x),1+Round((Zoom*Declination[i])+y),Red);
          SetColor(Red);
          Circle(Round((Zoom*Rectaszension[i])+x),Round((Zoom*Declination[i])+y),5);
          Circle(Round((Zoom*Rectaszension[i])+x),Round((Zoom*Declination[i])+y),6);
        END ELSE BEGIN
          PutPixel(Round((Zoom*Rectaszension[i])+x),Round((Zoom*Declination[i])+y),Red);
          SetColor(Red);
          Circle(Round((Zoom*Rectaszension[i])+x),Round((Zoom*Declination[i])+y),2);
        END;
      END;
      SetTextStyle(2,0,5);
      SetColor(White);
      Numb2 := Numb;
      IF ParamStr(3+Numb) = '1' THEN n := 80;
      IF Numb < 11 THEN FOR i := 1 TO Numb DO BEGIN
        Str(24-(Rectaszension[i]*24)/360:0:3,Rectaszension2);
        Str(90-Declination[i]:0:3,Declination2);
        OutTextXY(10,340+(10*i)+n,PlanetName[i]+': '+Rectaszension2+'h '+Declination2+'¯');
      END ELSE IF Numb < 21 THEN BEGIN
        FOR i := 1 TO 10 DO BEGIN
          Str(24-(Rectaszension[i]*24)/360:0:3,Rectaszension2);
          Str(90-Declination[i]:0:3,Declination2);
          OutTextXY(10,340+(10*(i-1))+n,PlanetName[i]+': '+Rectaszension2+'h '+Declination2+'¯');
        END;
        FOR i := 10 TO Numb DO BEGIN
          Str(24-(Rectaszension[i]*24)/360:0:3,Rectaszension2);
          Str(90-Declination[i]:0:3,Declination2);
          OutTextXY(300,340+(10*(i-10))+n,PlanetName[i]+': '+Rectaszension2+'h '+Declination2+'¯');
        END;
      END;
      SetTextStyle(2,0,4);
      IF ParamStr(3+Numb) = '1' THEN BEGIN
        SetColor(LightGreen);
        OutTextXY(2,460,'(C) 1995-2005 EXO-DB2 Michael Johne * http://www.die-exoplaneten.de.vu');
      END ELSE BEGIN
        SetColor(Cyan);
        OutTextXY(2,320,'(C) 1995-2005 EXO-DB2 Michael Johne * http://www.die-exoplaneten.de.vu');
      END;
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
        IF ParamStr(1) = 'all' THEN OutTextXY(360,210,'STARMAP') ELSE OutTextXY(360,210,ParamStr(2));
        SetColor(White);
        OutTextXY(270,230,'1 - Format PCX');
        OutTextXY(270,240,'2 - Format BMP');
        OutTextXY(270,250,'0 - Abbruch');
        REPEAT
          Input := ReadKey;
        UNTIL Input IN ['0','1','2'];
        LoadImage(0+200,0+200,'image.tmp');
        IF NOT(DirExists('STARMAP')) THEN MkDir('STARMAP');
        CASE Input OF
          '1' : IF ParamStr(1) = 'all' THEN SavePCX('STARMAP/'+'STARMAP.PCX') ELSE SavePCX('STARMAP/'+ParamStr(2)+'.PCX');
          '2' : IF ParamStr(1) = 'all' THEN SaveBMP('STARMAP/'+'STARMAP') ELSE SaveBMP('STARMAP/'+ParamStr(2));
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
    END;
  END;
END.
