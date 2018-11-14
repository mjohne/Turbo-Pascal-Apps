{+-------------------------------------------------------------------------+}
{|                                                                         |}
{|                             MYSORT 4.1                                  |}
{|                             ----------                                  |}
{|                                                                         |}
{+-------------------------------------------------------------------------+}
{|                                                                         |}
{|  Name:                      MYSORT                                      |}
{|  Version:                   4.1                                         |}
{|  Sprache:                   Turbo Pascal 7.0 (Borland Inc.)             |}
{|  Fertigstellung:            xx xxxx 2004                                |}
{|                                                                         |}
{|                                                                         |}
{|  Author:                    Michael Johne                               |}
{|  Kurzbeschreibung:          Demonstration verschiedener Sortier-        |}
{|                             verfahren                                   |}
{|                                                                         |}
{|                                                                         |}
{|  Credits:                   * Peter Weigel; www.peter-weigel.de,        |}
{|                               www.sortieralgorithmen.de                 |}
{|                                                                         |}
{|                                                                         |}
{|  Copyrights:                (C) 2002-2004; MYSORT, RandomSort,          |}
{|                                 BruteSort by Michael Johne              |}
{|                                                                         |}
{|                             Eine freie Weitergabe, Verwendung und Ver-  |}
{|                             vielfÑltigung ist erwÅnscht!                |}
{|                                                                         |}
{+-------------------------------------------------------------------------+}
{|                                                                         |}
{|  Hinzufuegungen:            * Sortierverfahren: PlaselSort              |}
{|                                                                         |}
{|  Verbesserungen:            * Fehler in den Feldfuell-Methoden 'ab-     |}
{|                               steigend','quadratisch' und 'kreuzend'    |}
{|                               beseitigt                                 |}
{|                                                                         |}
{|  Bekannte Fehler:           * Fehler in den Feldfuell-Methode 'quad-    |}
{|                               ratisch'                                  |}
{|                                                                         |}
{+-------------------------------------------------------------------------+}

PROGRAM My_Sort_41;

USES Crt,Dos,Graph;

TYPE
  Aptr  = 1..210;    {Aptr - Feld von RND[x] fÅr PROCEDURE MergeSort(1,Max);}
  Aptr2 = 0..210+1;   {Aptr2 - Feld von Aptr fÅr PROCEDURE MergeSort(1,Max);}

VAR
  RND                  {RND[SortMethod] - Datenfelder; werden stets sortiert}
        : ARRAY[0..10,1..210] OF Integer;
  FieldStatus,               {FieldStatus - informiert ueber den Feldzustand}
  Mode,                          {Mode - Index fÅr die gewaehlte Darstellung}
  SortMethod,  {SortMethod - Index fÅr die Zusammenstellungen der Feldes RND}
  SortNumber,         {SortNumber - Index fÅr das gewaehlte Sortierverfahren}
  SortObject  {SortObject - Index fÅr die Darstellungsobjekte der Feldes RND}
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

LABEL Retro;                                      {Retro - Ruecksprung-Marke}

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
      PutPixel(11+m,RND[SortMethod][m],Red);
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
  Bar(15+530,200+15+100,15+530+40,200+15+150);
  SetColor(Green);
  Str(Vergleiche,TempStr);
  OutTextXY(15+530,200+15+100,TempStr);
  Str(Vertauschungen,TempStr);
  OutTextXY(15+530,200+15+110,TempStr);
{  Str(Sec:0:2,TempStr);
  OutTextXY(15+530,200+15+120,TempStr+' ms');}
  Str(Vertauschungen/Vergleiche:0:2,TempStr);
  TempStr := TempStr+' - ';
  IF Vertauschungen/Vergleiche > 1 THEN TempStr := TempStr+'in';
  TempStr := TempStr+'stabil';
  OutTextXY(15+530,200+15+130,TempStr);
{  Str(MaxPercent:0:2,TempStr);
  IF MaxPercent < 0 THEN OutTextXY(15+530,200+15+140,'nicht moeglich')
    ELSE OutTextXY(15+530,200+15+140,TempStr+' %');}
END;

BEGIN
  Randomize;                                {Zufallsgenerator initialisieren}

  Max := 201;                                          {Standard-Feldgroesse}
  Pic := 0;

  GraphDriver := Detect;                                {Grafikmodus oeffnen}
  InitGraph(GraphDriver,GraphMode,'');

  Retro:                                                   {Ruecksprungmarke}

  ClearDevice;                                          {Saeuberungsaktionen}
  ClearKeyBuffer;

  Max := 201;                                          {Standard-Feldgroesse}

  SetFillStyle(SolidFill,White);          {Fenster erstellen und beschriften}
  Bar(0,0,639,479);
  SetColor(Black);
  Rectangle(0+9,0+8,Max+13,Max+11);
  Rectangle(0+9,0+8+235,Max+13,Max+11+235);
  Rectangle(0+9+210,0+8+235,Max+13+210,Max+11+235);
  SetTextStyle(2,0,4);
  OutTextXY(15,Max+15,'Datenfeld');
  OutTextXY(15,Max+15+235,'Vergleiche');
  OutTextXY(15+215,Max+15+235,'Vertauschungen');
  OutTextXY(15+435,Max+15+235,'Statistik');
  SetColor(DarkGray);
  OutTextXY(15+420,Max+15+030,'Sortierverfahren:');
  OutTextXY(15+420,Max+15+040,'Darstellung:');
  OutTextXY(15+420,Max+15+050,'Objekte');
  OutTextXY(15+420,Max+15+060,'Feldgroesse:');
  OutTextXY(15+420,Max+15+070,'Feldfuell-Methode:');
  OutTextXY(15+420,Max+15+080,'Zeitverzoegerung:');
  OutTextXY(15+420,Max+15+100,'Vergleiche:');
  OutTextXY(15+420,Max+15+110,'Vertauschungen:');
  OutTextXY(15+420,Max+15+120,'Gemessene Zeit:');
  OutTextXY(15+420,Max+15+130,'Stabilitaet:');
  OutTextXY(15+420,Max+15+140,'% erfÅllt:');

  SetColor(Black);                                  {Ausgabe der Einfuehrung}
  SetTextStyle(2,0,8);
  OutTextXY(380,12,'MYSORT 4.1');
  OutTextXY(381,12,'MYSORT 4.1');
  SetTextStyle(2,0,4);
  SetColor(DarkGray);
  OutTextXY(230,050,'MYSORT 4.1 ist die vierte Version meiner bekannten'
    +' Sortierverfahren-');
  OutTextXY(230,060,'Demonstration.');
  OutTextXY(230,070,'Da leider die 3. Version verloren gegangen ist, habe '
    +'ich beschlossen,');
  OutTextXY(230,080,'eine 4. - nun `graphische` - Version zu erstellen. Das '
    +'Ergebnis sehen');
  OutTextXY(230,090,'Sie hier.');
  OutTextXY(230,100,'GegenÅber der textmodus-basierten Darstellung kann nun '
    +'im Graphik-');
  OutTextXY(230,110,'Modus mehrere Details auf einmal und genauer angezeigt '
    +'werden. So gibt');
  OutTextXY(230,120,'es zum Beispiel nun die beiden neuen Fenster `Verglei'
    +'che` und `Ver-');
  OutTextXY(230,130,''
    +'tauschungen`.');
  OutTextXY(230,140,'Natuerlich kann man mehrere Sortierverfahren in versch'
    +'iedenen Darstel-');
  OutTextXY(230,150,'lungen anzeigen lassen, die Zeit messen oder eine Stati'
    +'stik anzeigen.');
  OutTextXY(230,180,'(C) 2004   -   MfG, Michael Johne!');
  OutTextXY(340,210,'<<< Eine beliebige Taste drÅcken >>>');
  ReadKey;

  SetFillStyle(SolidFill,White);       {1. Eingabe: Sortierverfahren waehlen}
  Bar(220,40,640,230);
  SetColor(DarkGray);
  OutTextXY(230,050,'1 - 2 - 3 - 4 - 5 - 6');
  SetColor(LightGreen);
  OutTextXY(230,050,'1');
  SetColor(DarkGray);
  OutTextXY(375,050,'Sortierverfahren aussuchen');
  OutTextXY(260,080,'01. BozoSort');
  OutTextXY(260,090,'02. RandomSort');
  OutTextXY(260,100,'03. BruteSort');
  OutTextXY(260,110,'04. TrippelSort');
  OutTextXY(260,120,'05. BubbleSort');
  OutTextXY(260,130,'06. RippleSort');
  OutTextXY(260,140,'07. ShakerSort');
  OutTextXY(260,150,'08. OetSort');
  OutTextXY(260,160,'09. SelectSort');
  OutTextXY(400,080,'10. SimpleSort');
  OutTextXY(400,090,'11. ExchangeSort');
  OutTextXY(400,100,'12. InsertSort');
  OutTextXY(400,110,'13. PlaselSort');
  OutTextXY(400,120,'14. JumpSort');
  OutTextXY(400,130,'15. ShellSort');
  OutTextXY(400,140,'16. HeapSort');
  OutTextXY(400,150,'17. QuickSort');
  OutTextXY(400,160,'18. MergeSort');
  OutTextXY(400,170,'19. BucketSort');
  OutTextXY(230,190,'Ihre Eingabe:');
  SetColor(LightBlue);
  REPEAT
    Input1 := ReadKey;
  UNTIL Input1 IN ['0','1'];
  OutTextXY(310,190,Input1);
  REPEAT
    Input2 := ReadKey;
  UNTIL Input2 IN ['0','1','2','3','4','5','6','7','8','9'];
  OutTextXY(315,190,Input2);
  CASE Input1 OF
    '0' : BEGIN
      CASE Input2 OF
       '0' : Exit;
       '1' : SortNumber := 01;
       '2' : SortNumber := 02;
       '3' : SortNumber := 03;
       '4' : SortNumber := 04;
       '5' : SortNumber := 05;
       '6' : SortNumber := 06;
       '7' : SortNumber := 07;
       '8' : SortNumber := 08;
       '9' : SortNumber := 09;
      END;
    END;
    '1' : BEGIN
      CASE Input2 OF
       '0' : SortNumber := 10;
       '1' : SortNumber := 11;
       '2' : SortNumber := 12;
       '3' : SortNumber := 13;
       '4' : SortNumber := 14;
       '5' : SortNumber := 15;
       '6' : SortNumber := 16;
       '7' : SortNumber := 17;
       '8' : SortNumber := 18;
       '9' : SortNumber := 19;
      END;
    END;
  END;
  CASE SortNumber OF
    01 : SortName := 'BozoSort';
    02 : SortName := 'RandomSort';
    03 : SortName := 'BruteSort';
    04 : SortName := 'TrippelSort';
    05 : SortName := 'BubbleSort';
    06 : SortName := 'RippleSort';
    07 : SortName := 'ShakerSort';
    08 : SortName := 'OetSort';
    09 : SortName := 'SelectSort';
    10 : SortName := 'SimpleSort';
    11 : SortName := 'ExchangeSort';
    12 : SortName := 'InsertSort';
    13 : SortName := 'PlaselSort';
    14 : SortName := 'JumpSort';
    15 : SortName := 'ShellSort';
    16 : SortName := 'HeapSort';
    17 : SortName := 'QuickSort';
    18 : SortName := 'MergeSort';
    19 : SortName := 'BucketSort';
  END;
  SetColor(LightRed);
  OutTextXY(15+530,200+15+030,SortName);

  SetFillStyle(SolidFill,White);         {2. Eingabe: Darstellung auswaehlen}
  Bar(220,40,640,230);
  SetColor(DarkGray);
  OutTextXY(230,050,'1 - 2 - 3 - 4 - 5 - 6');
  SetColor(LightGreen);
  OutTextXY(254,050,'2');
  SetColor(DarkGray);
  OutTextXY(375,050,'Darstellung auswaehlen');
  OutTextXY(260,080,'1. einfach');
  OutTextXY(260,090,'2. genau');
  OutTextXY(260,100,'3. keine');
  OutTextXY(230,160,'Ihre Eingabe:');
  SetColor(LightBlue);
  REPEAT
    Input1 := ReadKey;
  UNTIL Input1 IN ['0','1','2','3'];
  OutTextXY(310,160,Input1);
  SetColor(LightRed);
  CASE Input1 OF
    '0' : Exit;
    '1' : BEGIN
      Mode := 1;
      OutTextXY(15+530,200+15+040,'einfach');
    END;
    '2' : BEGIN
      Mode := 2;
      OutTextXY(15+530,200+15+040,'genau');
    END;
    '3' : BEGIN
      Mode := 3;
      OutTextXY(15+530,200+15+040,'keine');
    END;
  END;

  SetFillStyle(SolidFill,White);  {3. Eingabe: Darstellungsobjekt auswaehlen}
  Bar(220,40,640,230);
  SetColor(DarkGray);
  OutTextXY(230,050,'1 - 2 - 3 - 4 - 5 - 6');
  SetColor(LightGreen);
  OutTextXY(278,050,'3');
  SetColor(DarkGray);
  OutTextXY(375,050,'Darstellungsobjekt auswaehlen');
  OutTextXY(260,080,'1. Punkte');
  OutTextXY(260,090,'2. Linien');
  OutTextXY(230,160,'Ihre Eingabe:');
  SetColor(LightBlue);
  REPEAT
    Input1 := ReadKey;
  UNTIL Input1 IN ['0','1','2'];
  OutTextXY(310,160,Input1);
  SetColor(LightRed);
  CASE Input1 OF
    '0' : Exit;
    '1' : BEGIN
      SortObject := 1;
      OutTextXY(15+530,200+15+050,'Punkte');
    END;
    '2' : BEGIN
      SortObject := 2;
      OutTextXY(15+530,200+15+050,'Linien');
    END;
  END;

  SetFillStyle(SolidFill,White);          {4. Eingabe: Feldgroesse bestimmen}
  Bar(220,40,640,230);
  SetColor(DarkGray);
  OutTextXY(230,050,'1 - 2 - 3 - 4 - 5 - 6');
  SetColor(LightGreen);
  OutTextXY(302,050,'4');
  SetColor(DarkGray);
  OutTextXY(375,050,'Feldgroesse bestimmen');
  OutTextXY(230,080,'Die Feldgroesse muss zwischen 0..200 liegen!');
  OutTextXY(230,160,'Ihre Eingabe (ENTER = 200):');
  SetColor(LightBlue);
  REPEAT
    Input1 := ReadKey;
  UNTIL Input1 IN ['0','1','2','3','4','5','6','7','8','9',Chr(13)];
  IF Input1 = Chr(13) THEN Max := 200 ELSE BEGIN
    OutTextXY(395,160,Input1);
    REPEAT
      Input2 := ReadKey;
    UNTIL Input2 IN ['0','1','2','3','4','5','6','7','8','9',Chr(13)];
    IF Input2 = Chr(13) THEN BEGIN
      Val(Input1,Max,Control);
    END ELSE BEGIN
      OutTextXY(400,160,Input2);
      REPEAT
        Input3 := ReadKey;
      UNTIL Input3 IN ['0','1','2','3','4','5','6','7','8','9',Chr(13)];
      IF Input3 = Chr(13) THEN BEGIN
        Val(Input1+Input2,Max,Control);
      END ELSE BEGIN
        OutTextXY(405,160,Input3);
        Val(Input1+Input2+Input3,Max,Control);
      END;
    END;
  END;
  IF (Max < 0) OR (Max > 200) THEN Max := 200;
  SetColor(LightRed);
  Str(Max,TempStr);
  OutTextXY(15+530,200+15+060,TempStr);

  SetFillStyle(SolidFill,White);    {5. Eingabe: Feldfuell-Methode bestimmen}
  Bar(220,40,640,230);
  SetColor(DarkGray);
  OutTextXY(230,050,'1 - 2 - 3 - 4 - 5 - 6');
  SetColor(LightGreen);
  OutTextXY(326,050,'5');
  SetColor(DarkGray);
  OutTextXY(375,050,'Feldfuell-Methode bestimmen');
  OutTextXY(260,080,'1. zufaellig');
  OutTextXY(260,090,'2. aufsteigend');
  OutTextXY(260,100,'3. absteigend');
  OutTextXY(260,110,'4. quadratisch');
  OutTextXY(260,120,'5. kreuzend');
  OutTextXY(230,160,'Ihre Eingabe (ENTER = 1):');
  SetColor(LightBlue);
  REPEAT
    Input1 := ReadKey;
  UNTIL Input1 IN ['0','1','2','3','4','5',Chr(13)];
  IF Input1 = Chr(13) THEN BEGIN
    SortMethod := 1;
    TempStr := 'zufaellig';
    SetColor(LightRed);
    OutTextXY(15+530,Max+15+070,TempStr);
  END ELSE BEGIN
    OutTextXY(395,160,Input1);
    CASE Input1 OF
      '0' : Exit;
      '1' : BEGIN
        SortMethod := 1;
        TempStr := 'zufaellig';
      END;
      '2' : BEGIN
        SortMethod := 2;
        TempStr := 'aufsteigend';
      END;
      '3' : BEGIN
        SortMethod := 3;
        TempStr := 'absteigend';
      END;
      '4' : BEGIN
        SortMethod := 4;
        TempStr := 'quadratisch';
      END;
      '5' : BEGIN
        SortMethod := 5;
        TempStr := 'kreuzend';
      END;
    END;
  END;
  SetColor(LightRed);
  OutTextXY(15+530,200+15+070,TempStr);

  SetFillStyle(SolidFill,White);     {6. Eingabe: Zeitverzoergerung eingeben}
  Bar(220,40,640,230);
  SetColor(DarkGray);
  OutTextXY(230,050,'1 - 2 - 3 - 4 - 5 - 6');
  SetColor(LightGreen);
  OutTextXY(350,050,'6');
  SetColor(DarkGray);
  OutTextXY(375,050,'Zeitverzoergerung eingeben');
  OutTextXY(230,080,'Die Zeitverzoergerung (in ms) muss zwischen 0..999 liegen!');
  OutTextXY(230,160,'Ihre Eingabe (ENTER = 0):');
  SetColor(LightBlue);
  REPEAT
    Input1 := ReadKey;
  UNTIL Input1 IN ['0','1','2','3','4','5','6','7','8','9',Chr(13)];
  IF Input1 = Chr(13) THEN Waitting := 0 ELSE BEGIN
    OutTextXY(395,160,Input1);
    REPEAT
      Input2 := ReadKey;
    UNTIL Input2 IN ['0','1','2','3','4','5','6','7','8','9',Chr(13)];
    IF Input2 = Chr(13) THEN BEGIN
      Val(Input1,Waitting,Control);
    END ELSE BEGIN
      OutTextXY(400,160,Input2);
      REPEAT
        Input3 := ReadKey;
      UNTIL Input3 IN ['0','1','2','3','4','5','6','7','8','9',Chr(13)];
      IF Input3 = Chr(13) THEN BEGIN
        Val(Input1+Input2,Waitting,Control);
      END ELSE BEGIN
        OutTextXY(405,160,Input3);
        Val(Input1+Input2+Input3,Waitting,Control);
      END;
    END;
  END;
  IF (Waitting < 0) OR (Waitting > 999) THEN Waitting := 0;
  SetColor(LightRed);
  Str(Waitting,TempStr);
  OutTextXY(15+530,200+15+080,TempStr+' ms');

  StartTimer;                                                 {Timer starten}

  CASE SortNumber OF                               {Sortierverfahren starten}
    01 : BozoSort;
    02 : RandomSort;
    03 : BruteSort;
    04 : TrippelSort(1,Max);
    05 : BubbleSort;
    06 : RippleSort;
    07 : ShakerSort;
    08 : OetSort;
    09 : SelectSort;
    10 : SimpleSort;
    11 : ExchangeSort;
    12 : InsertSort;
    13 : PlaselSort;
    14 : JumpSort;
    15 : ShellSort;
    16 : HeapSort;
    17 : QuickSort(1,Max);
    18 : MergeSort(Max);
    19 : BucketSort;
  END;

  GetTimer;                                                   {Timer stoppen}

  ClearKeyBuffer;                                {Tastaturenspeicher lîschen}

  SetColor(Green);                                    {Ausgabe der Statistik}
  Str(Vergleiche,TempStr);
  OutTextXY(15+530,200+15+100,TempStr);
  Str(Vertauschungen,TempStr);
  OutTextXY(15+530,200+15+110,TempStr);
  Str(Sec:0:2,TempStr);
  OutTextXY(15+530,200+15+120,TempStr+' ms');
  Str(Vertauschungen/Vergleiche:0:2,TempStr);
  TempStr := TempStr+' - ';
  IF Vertauschungen/Vergleiche > 1 THEN TempStr := TempStr+'in';
  TempStr := TempStr+'stabil';
  OutTextXY(15+530,200+15+130,TempStr);

  SetFillStyle(SolidFill,White);                       {Anfrage auf Neustart}
  Bar(220,40,640,230);
  SetColor(DarkGray);
  OutTextXY(230,050,'Wollen Sie einen neuen Versuch starten?');
  OutTextXY(230,080,'Ihre Eingabe [j/n]:');
  REPEAT
    Input1 := ReadKey;
    Input1 := UpCase(Input1);

    IF Input1 = 'S' THEN BEGIN                 {Geheim: Screenshot erstellen}
      Inc(Pic);
      Str(Pic,TempStr);
      SavePCX(TempStr+'.pcx');
    END;

  UNTIL Input1 IN ['J','Z','Y','N'];
  SetColor(Blue);
  OutTextXY(350,080,Input1);

  IF Input1 = 'N' THEN BEGIN                               {Programm beenden}
    CloseGraph;
    Halt;
  END;

  Max:= 200;
  CreateSortField;                                {Datenfelder neu erstellen}

  GOTO Retro;                                                      {Neustart}
END.
