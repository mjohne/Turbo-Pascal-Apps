PROGRAM Modul(Bubble);

USES Crt,Dos,Graph;

VAR
  A1,A2                  {RND[SortMethod] - Datenfelder; werden stets sortiert}
        : ARRAY[1..210] OF Integer;
  RND                  {RND[SortMethod] - Datenfelder; werden stets sortiert}
        : ARRAY[0..10,1..210] OF Integer;
  FieldStatus,               {FieldStatus - informiert ueber den Feldzustand}
  Mode,                          {Mode - Index fÅr die gewaehlte Darstellung}
  SortMethod,  {SortMethod - Index fÅr die Zusammenstellungen der Feldes RND}
  SortNumber,         {SortNumber - Index fÅr das gewaehlte Sortierverfahren}
  SortObject, {SortObject - Index fÅr die Darstellungsobjekte der Feldes RND}
  SortVersion {}
        : Byte;
  Finished,Okay                     {Finished - Flag fÅr ein sortiertes Feld}
        : Boolean;
  Input1,Input2,Input3                       {Input[1..3] - Eingabevariablen}
        : Char;
  Swap,                  {Swap - Temp-Variable zum Vertauschen zweier Zahlen}
  Max,                    {Max - speichert die Groesse der sortierten Feldes}
  GraphDriver,                 {GraphDriver - Variable fÅr den Grafiktreiber}
  GraphMode,                       {GraphMode - Variable fÅr den Grafikmodus}
  Control,   {Control - Kontroll-Variable fuer die Umwandlung String -> Zahl}
  i,j,l,r,m,n,a,b,k,q   {i,j,l,r,m,n,a,b,k,q - Zaehl- und Schleifenvariablen}
         : Integer;
  Vergleiche,              {Vergleiche - speichert die Anzahl der Vergleiche}
  Vertauschungen,  {Vertauschungen - speichert die Anzahl der Vertauschungen}
  StartZeit,                                {StartZeit - misst die Startzeit}
  EndZeit,                                  {EndZeit - speichert die Endzeit}
  Zeit                 {Zeit - errechnet die Laufzeit eines Sortierverfahren}
         : LongInt;
  MaxPercent, {MaxPercent - Angabe in Prozent vonm Ende des Sortierverfahren}
  Sec                                 {Sec - Angabe der Laufzeit in Sekunden}
         : Real;
  regs                                {regs - Variable fÅr Code mit Register}
         : Registers;
  SortName,            {SortName - speichert den Namen der Sortierverfahrens}
  TempStr                                       {TempStr - Temp-Zeichenkette}
         : STRING;
  Pic,     {Pic - dient zur nummerierten Benennung von gespeicherten Bildern}
  Waitting                     {Waitting - speichert die Verzîgerung (Pause)}
         : Word;

PROCEDURE ClearKeyBuffer;
{Diese Funktion lîscht den gesamten Tastaturspeicher.}
BEGIN
  ASM
    mov ax,$0C06;
    mov dl,$FF;
    int $21;
  END;
END;

PROCEDURE Wait(ms : Word); ASSEMBLER;
{Diese Funktion ist korrektere Alternative zu PROCEDURE Delay();.}
ASM
  mov ax, 1000;
  mul ms;
  mov cx, dx;
  mov dx, ax;
  mov ah, $86;
  Int $15;
END;

PROCEDURE StartTimer;
{Diese Funktion startet die Zeitmessung.}
BEGIN
  regs.ah := $00;
  Intr($1A,regs);
  StartZeit := regs.cx SHL 16+regs.dx;
END;

PROCEDURE GetTimer;
{Diese Funktion stoppt die gemessene Zeit.}
BEGIN
  regs.ah := $00;
  Intr($1A,regs);
  EndZeit := regs.cx SHL 16+regs.dx;
  Zeit := EndZeit-StartZeit;
  Sec  := Zeit/18.2;
END;

PROCEDURE SavePCX(Filename : STRING);
{Mit dieser Funktion lassen sich PCX-Grafiken der Bildschirms speichern.}
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
PROCEDURE GetRGB(Color : Integer; VAR r,g,b : Integer);
BEGIN
  r := (((Color AND $20) SHR 5) OR ((Color AND $04) SHR 1))*84;
  g := (((Color AND $10) SHR 4) OR ((Color AND $02)      ))*84;
  b := (((Color AND $08) SHR 3) OR ((Color AND $01) SHL 1))*84;
END;
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
        IF bi = BufSize THEN FlushIt; Inc(bi); buf[bi] := $C0 OR count;
        IF bi = BufSize THEN FlushIt; Inc(bi); buf[bi] := dta;
      END ELSE BEGIN
        IF (dta AND $C0) = $C0 THEN BEGIN
          IF bi = BufSize THEN FlushIt; Inc(bi); buf[bi] := $C1;
          IF bi = BufSize THEN FlushIt; Inc(bi); buf[bi] := dta;
        END ELSE BEGIN
          IF bi = BufSize THEN FlushIt; Inc(bi); buf[bi] := dta;
        END;
      END;
    UNTIL Index = 320;
  END;
  IF bi > 0 THEN FlushIt;
  Close(f);
END;

PROCEDURE Show;
{
  Diese Funktion dient der Ausgabe der aktuellen Datenfeldes
  auf den Bildschirm.
}
BEGIN
  IF Waitting <> 0 THEN Wait(Waitting);
  IF SortObject = 1 THEN BEGIN
    SetColor(White);
    FOR m := 1 TO Max DO BEGIN
      Line(11,RND[SortMethod][m],11+m,RND[SortMethod][m]);
      Line(11+m+1,RND[SortMethod][m],11+Max,RND[SortMethod][m]);
      PutPixel(11+m,RND[SortMethod][m],Blue);
    END
  END ELSE BEGIN
    FOR m := 1 TO Max DO BEGIN
      SetColor(White);
      Line(11,RND[SortMethod][m],11+Max,RND[SortMethod][m]);
      SetColor(Blue);
      Line(11,RND[SortMethod][m],11+m,RND[SortMethod][m]);
    END
  END;

  SetFillStyle(White,SolidFill);
  Bar(15+330,15+100,15+330+60,15+150);
  SetColor(Green);
  Str(Vergleiche,TempStr);
  OutTextXY(15+330,15+100,TempStr);
  Str(Vertauschungen,TempStr);
  OutTextXY(15+330,15+110,TempStr);
{  Str(Sec:0:2,TempStr);
  OutTextXY(15+530,200+15+120,TempStr+' ms');}
  Str(Vertauschungen/Vergleiche:0:2,TempStr);
  TempStr := TempStr+' - ';
  IF Vertauschungen/Vergleiche > 1 THEN TempStr := TempStr+'in';
  TempStr := TempStr+'stabil';
  OutTextXY(15+330,15+130,TempStr);
{  Str(MaxPercent:0:2,TempStr);
  IF MaxPercent < 0 THEN OutTextXY(15+530,200+15+140,'nicht moeglich')
    ELSE OutTextXY(15+530,200+15+140,TempStr+' %');}
END;

PROCEDURE CreateSortField;
{
 Mit dieser Funktion werden die Datenfelder der verschiedenen Sortier-
 methoden erstellt.
}
BEGIN
  FOR i := 1 TO Max DO BEGIN                            {Standard-Sortierung}
    RND[0][i] := i+10;
  END;
  FOR i := 1 TO Max DO BEGIN                          {zufaellige Sortierung}
    RND[1][i] := RND[0][i];
  END;
  FOR i := 1 TO MaxInt DO BEGIN
    l := Random(Max)+1;
    r := Random(Max)+1;
    Swap      := RND[1][l];
    RND[1][l] := RND[1][r];
    RND[1][r] := Swap;
  END;
  FOR i := 1 TO Max DO BEGIN                        {aufsteigende Sortierung}
    RND[2][i] := RND[0][i];
  END;
  FOR i := Max DOWNTO 1 DO BEGIN                     {absteigende Sortierung}
    RND[3][i] := RND[0][Max-i];
  END;
  FOR i := 1 TO (Max DIV 2) DO BEGIN                {quadratische Sortierung}
    IF Odd(i) THEN RND[4][i] := i+(Max DIV 2)
      ELSE RND[4][Max-i] := i+(Max DIV 2);
  END;
  FOR i := 1 TO (Max DIV 2) DO BEGIN
    IF Odd(i) THEN RND[4][i+(Max DIV 2)] := i
      ELSE RND[4][Max-(i+(Max DIV 2))] := i;
  END;
  FOR i := 1 TO Max DO RND[4][i] := RND[4][i]+11;
  FOR i := 1 TO Max DO BEGIN                           {kreuzende Sortierung}
    IF Odd(i) THEN RND[5][i] := i ELSE RND[5][i] := Max-i;
  END;
  FOR i := 1 TO Max DO RND[5][i] := RND[5][i]+11;
END;

PROCEDURE BubbleSort_v1;
BEGIN
  FOR i := Max DOWNTO 2 DO BEGIN
    FOR j := 1 TO i-1 DO BEGIN
      IF KeyPressed THEN BEGIN
        Exit;
      END;
      Inc(A1[RND[SortMethod][j]]);
      Inc(Vergleiche);
      IF Mode <> 3 THEN BEGIN
        PutPixel(11+j,RND[SortMethod][j]+235,Green);
        SetColor(Green);
        Line(430+j,343,430+j,343-(Round(A1[j]*100/Max)));
      END;
      IF (RND[SortMethod][j] > RND[SortMethod][j+1]) THEN BEGIN
        Swap                 := RND[SortMethod][j];
        RND[SortMethod][j]   := RND[SortMethod][j+1];
        RND[SortMethod][j+1] := Swap;
        Inc(Vertauschungen);
        Inc(A2[RND[SortMethod][j]]);
        IF Mode <> 3 THEN BEGIN
          PutPixel(11+j+210,RND[SortMethod][j]+235,Red);
          SetColor(Red);
          Line(430+j,446,430+j,446-(Round(A2[j]*100/Max)));
        END;
        IF Mode = 2 THEN Show;
      END;
    END;
    IF Mode = 1 THEN Show;
  END;
END;

PROCEDURE BubbleSort_v2;
BEGIN
  Finished := False;
  WHILE NOT Finished DO BEGIN
    Finished := True;
    FOR i := 1 TO Max-1 DO BEGIN
      IF KeyPressed THEN BEGIN
        Exit;
      END;
      Inc(A1[RND[SortMethod][i]]);
      Inc(Vergleiche);
      IF Mode <> 3 THEN BEGIN
        PutPixel(11+i,RND[SortMethod][i]+235,Green);
        SetColor(Green);
        IF NOT(Round(A1[i]*100/Max) < 0) THEN
          Line(430+i,343,430+i,343-(Round(A1[i]*100/Max)));
      END;
      IF (RND[SortMethod][i] > RND[SortMethod][i+1]) THEN BEGIN
        Swap                 := RND[SortMethod][i];
        RND[SortMethod][i]   := RND[SortMethod][i+1];
        RND[SortMethod][i+1] := Swap;
        Finished := False;
        Inc(A2[RND[SortMethod][i]]);
        Inc(Vertauschungen);
        IF Mode <> 3 THEN BEGIN
          PutPixel(11+i+210,RND[SortMethod][i]+235,Red);
          SetColor(Red);
          Line(430+i,446,430+i,446-(Round(A2[i]*100/Max)));
        END;
        IF Mode = 2 THEN Show;
      END;
    END;
    IF Mode = 1 THEN Show;
  END;
END;

BEGIN
  Randomize;                                {Zufallsgenerator initialisieren}

  Max := 201;                                          {Standard-Feldgroesse}
  Pic := 0;

  CreateSortField;                                    {Datenfelder erstellen}

  GraphDriver := Detect;                                {Grafikmodus oeffnen}
  InitGraph(GraphDriver,GraphMode,'');

  ClearDevice;                                          {Saeuberungsaktionen}
  ClearKeyBuffer;

  Max := 201;                                          {Standard-Feldgroesse}

  SetFillStyle(SolidFill,White);          {Fenster erstellen und beschriften}
  Bar(0,0,639,479);
  SetColor(Black);
  Rectangle(0+9,0+8,Max+13,Max+11);
  Rectangle(0+9,0+8+235,Max+13,Max+11+235);
  Rectangle(0+9+210,0+8+235,Max+13+210,Max+11+235);
  Rectangle(430,244,430+Max,244+100);
  Rectangle(430,347,430+Max,347+100);
  SetTextStyle(2,0,4);
  OutTextXY(15,Max+15,'Datenfeld');
  OutTextXY(15,Max+15+235,'Vergleiche');
  OutTextXY(15+215,Max+15+235,'Vertauschungen');
  SetColor(DarkGray);
  OutTextXY(15+220,15+030,'Sortierverfahren:');
  OutTextXY(15+220,15+040,'Darstellung:');
  OutTextXY(15+220,15+050,'Objekte');
  OutTextXY(15+220,15+060,'Feldgroesse:');
  OutTextXY(15+220,15+070,'Feldfuell-Methode:');
  OutTextXY(15+220,15+080,'Zeitverzoegerung:');
  OutTextXY(15+220,15+100,'Vergleiche:');
  OutTextXY(15+220,15+110,'Vertauschungen:');
  OutTextXY(15+220,15+120,'Gemessene Zeit:');
  OutTextXY(15+220,15+130,'Stabilitaet:');
  OutTextXY(15+220,15+140,'% erfÅllt:');

  SetColor(Black);                                  {Ausgabe der Einfuehrung}
  SetTextStyle(2,0,8);
  OutTextXY(380,12,'MYSORT 4.1');
  OutTextXY(381,12,'MYSORT 4.1');

  Val(ParamStr(1),SortNumber,Control); {Sortierverfahren}

  Val(ParamStr(2),SortVersion,Control); {Sortierverfahren-Version}

  Val(ParamStr(3),Mode,Control); {Sortierverfahren}

  Val(ParamStr(4),SortObject,Control);

  Val(ParamStr(5),Max,Control);

  Val(ParamStr(6),SortMethod,Control);

  Val(ParamStr(7),Waitting,Control);

  SetTextStyle(2,0,4);

  SortName := 'BubbleSort';
  CASE SortVersion OF
    1 : SortName := SortName + ', Original-Version';
    2 : SortName := SortName + ', verbesserte Version';
  END;
  SetColor(LightRed);
  OutTextXY(15+330,15+030,SortName);

  CASE Mode OF
    1 : OutTextXY(15+330,15+040,'einfach');
    2 : OutTextXY(15+330,15+040,'genau');
    3 : OutTextXY(15+330,15+040,'keine');
  END;

  CASE SortObject OF
    1 : OutTextXY(15+330,15+050,'Punkte');
    2 : OutTextXY(15+330,15+050,'Linien');
  END;

  Str(Max,TempStr);
  OutTextXY(15+330,15+060,TempStr+' ms');


  CASE SortMethod OF
    1 : OutTextXY(15+330,15+070,'zufaellig');
    2 : OutTextXY(15+330,15+070,'aufsteigend');
    3 : OutTextXY(15+330,15+070,'absteigend');
    4 : OutTextXY(15+330,15+070,'quadratisch');
    5 : OutTextXY(15+330,15+070,'kreuzend');
  END;

  Str(Waitting,TempStr);
  OutTextXY(15+330,15+080,TempStr);


  CreateSortField;

  StartTimer;
  CASE SortVersion OF
    1: BubbleSort_v1;
    2: BubbleSort_v2;
  END;

  GetTimer;

  Str(Sec:0:2,TempStr);
  OutTextXY(15+330,15+120,TempStr+' ms');

  ClearKeyBuffer;

  ReadKey;

  CloseGraph;


END.