PROGRAM My_Sort;

USES Crt,Dos,Graph;

CONST Max = 924;

TYPE
  Aptr  = 1..Max;
  Aptr2 = 0..Max+1;

VAR
  RND1,RND2         : ARRAY[1..Max] OF Char;
  SortNumber,Mode   : Byte;
  Finished          : Boolean;
  Swap              : Char;
  i,j,l,r,m,n       : Integer;
  StartZeit,
  EndZeit,
  Zeit              : LongInt;
  Sec               : Real;
  regs              : Registers;
  Waitting          : Word;

PROCEDURE Quit;
BEGIN
  TextMode(LastMode);
  Halt;
END;

PROCEDURE Wait(ms : Word); ASSEMBLER;
ASM
  mov ax, 1000;
  mul ms;
  mov cx, dx;
  mov dx, ax;
  mov ah, $86;
  Int $15;
END;

PROCEDURE StartTimer;
BEGIN
  regs.ah := $00;
  Intr($1A,regs);
  StartZeit := regs.cx SHL 16+regs.dx;
END;

PROCEDURE GetTimer;
BEGIN
  regs.ah := $00;
  Intr($1A,regs);
  EndZeit := regs.cx SHL 16+regs.dx;
  Zeit := EndZeit-StartZeit;
  Sec  := Zeit/18.2;
END;

PROCEDURE Cursor(Visible : Boolean);
VAR
  grDriver,grMode : Integer;
  BTXMEM          : LongInt;
BEGIN
  grDriver := Detect;
  DetectGraph(grDriver,grMode);
  CASE grDriver OF
    1..6,8..9 : BTXMEM := $B800;
    -2,7,10   : BTXMEM := $B000;
  END;
  regs.ah := 1;
  IF Visible THEN BEGIN
    IF BTXMEM = $B800 THEN BEGIN
      regs.ch := 6;
      regs.cl := 7;
    END
    ELSE
    BEGIN
      regs.ch := 12;
      regs.cl := 13;
    END;
    Intr(16,regs);
  END
  ELSE
  BEGIN
    regs.ch := 32;
    regs.cl := 7;
    Intr(16,regs);
  END;
END;

PROCEDURE Anzeige;
BEGIN
  GotoXY(1,1);
  FOR m := 1 TO Max DO Write(RND2[m]);
END;

PROCEDURE Box(x1, y1, x2, y2 : Integer);
BEGIN
  GotoXY(x1,y1);
  Write('⁄');
  FOR i := x1+1 TO x2-1 DO Write('ƒ');
  Write('ø');
  FOR i := y1+1 TO y2-1 DO BEGIN
    GotoXY(x1,i);
    Write('≥');
    GotoXY(x2,i);
    Write('≥');
  END;
  GotoXY(x1,y2);
  Write('¿');
  FOR i := x1+1 TO x2-1 DO Write('ƒ');
  Write('Ÿ');
END;

PROCEDURE BozoSort;
BEGIN
  Finished := False;
  WHILE NOT(finished) DO BEGIN
    i := Random(MAX)+1;
    j := Random(MAX)+1;
    Swap    := RND2[j];
    RND2[j] := RND2[i];
    RND2[i] := Swap;
    IF Mode = 2 THEN Anzeige;
    IF Waitting <> 0 THEN Wait(Waitting);
    Finished := True;
    FOR n := 1 TO MAX DO BEGIN
    IF RND2[n-1] > RND2[n] THEN BEGIN
      IF Mode = 1 THEN Anzeige;
      Finished := False;
      Break;
    END;
    END;
  END;
END;

PROCEDURE BubbleSort;
BEGIN
  Finished := False;
  WHILE NOT Finished DO BEGIN
    Finished := True;
    FOR i := 1 TO MAx - 1 DO BEGIN
      IF (RND2[i] > RND2[i+1]) THEN BEGIN
        Swap      := RND2[i];
        RND2[i]   := RND2[i+1];
        RND2[i+1] := Swap;
        Finished := False;
        IF Mode = 2 THEN Anzeige;
        IF Waitting <> 0 THEN Wait(Waitting);
      END;
    END;
    IF Mode = 1 THEN Anzeige;
  END;
END;

PROCEDURE ShakerSort;
BEGIN
  l := 2;
  r := Max;
  n := Max;
  REPEAT
    FOR j := r DOWNTO l DO BEGIN
      IF (RND2[j] < RND2[j-1]) THEN BEGIN
        Swap      := RND2[j];
        RND2[j]   := RND2[j-1];
        RND2[j-1] := Swap;
        n := j;
        IF Mode = 2 THEN Anzeige;
        IF Waitting <> 0 THEN Wait(Waitting);
      END;
    END;
    IF Mode = 1 THEN Anzeige;
    l := n+1;
    FOR j := l TO r DO BEGIN
      IF (RND2[j] < RND2[j-1]) THEN BEGIN
        Swap      := RND2[j];
        RND2[j]   := RND2[j-1];
        RND2[j-1] := Swap;
        n := j;
        IF Mode = 2 THEN Anzeige;
        IF Waitting <> 0 THEN Wait(Waitting);
      END;
    END;
    IF Mode = 1 THEN Anzeige;
    r := n-1;
  UNTIL l >= r;
END;

PROCEDURE MaxSort;
BEGIN
  FOR i := Max DOWNTO 2 DO BEGIN
    FOR j := 1 TO i DO BEGIN
      IF RND2[i] < RND2[j] THEN BEGIN
        swap    := RND2[i];
        RND2[i] := RND2[j];
        RND2[j] := swap;
        IF Mode = 2 THEN Anzeige;
        IF Waitting <> 0 THEN Wait(Waitting);
      END;
    END;
    IF Mode = 1 THEN Anzeige;
  END;
END;

PROCEDURE ExchangeSort;
BEGIN
  FOR i := 1 TO Max DO BEGIN
    FOR j := i+1 TO Max DO BEGIN
      IF RND2[i] > RND2[j] THEN BEGIN
        Swap    := RND2[i];
        RND2[i] := RND2[j];
        RND2[j] := Swap;
        IF Mode = 2 THEN Anzeige;
        IF Waitting <> 0 THEN Wait(Waitting);
      END;
    END;
    IF Mode = 1 THEN Anzeige;
  END;
END;

PROCEDURE SelectSort;
BEGIN
  FOR i := 1 TO Max-1 DO BEGIN
    Swap := RND2[i];
    n := i;
    FOR j := i+1 TO Max DO BEGIN
      IF RND2[j] < Swap THEN BEGIN
        Swap := RND2[j];
        n := j;
        IF Mode = 2 THEN Anzeige;
        IF Waitting <> 0 THEN Wait(Waitting);
      END;
    END;
    RND2[n] := RND2[i];
    RND2[i] := Swap;
    IF Mode = 1 THEN Anzeige;
  END;
END;

PROCEDURE InsertSort;
BEGIN
  FOR i := 1 TO Max-1 DO BEGIN
    FOR j := 1 TO i DO BEGIN
      IF RND2[j] > RND2[i+1] THEN BEGIN
        Swap := RND2[i+1];
        FOR n := i+1 DOWNTO j+1 DO RND2[n] := RND2[n-1];
        RND2[j] := Swap;
        IF Mode = 2 THEN Anzeige;
        IF Waitting <> 0 THEN Wait(Waitting);
      END;
    END;
    IF Mode = 1 THEN Anzeige;
  END;
END;

PROCEDURE HeapSort;
PROCEDURE Sift;
BEGIN
  i:= l;
  j:= 2*i;
  Swap := RND2[i];
  WHILE j < r DO BEGIN
    IF i < r THEN IF RND2[j] < RND2[j+1] THEN Inc(j);
    IF Swap < RND2[j] THEN BEGIN
      RND2[i] := RND2[j];
      i := j;
      j := 2*i;
      IF Mode = 2 THEN Anzeige;
      IF Waitting <> 0 THEN Wait(Waitting);
    END ELSE j:= r+1;
  END;
  RND2[i]:= Swap;
END;
BEGIN
  r := Max;
  FOR l := (Max DIV 2) DOWNTO 1 DO Sift;
  WHILE r > 1 DO BEGIN
    l := 1;
    Swap    := RND2[l];
    RND2[l] := RND2[r];
    RND2[r] := Swap;
    Dec(r);
    Sift;
    IF Mode = 1 THEN Anzeige;
  END;
END;

PROCEDURE ShellSort;
BEGIN
  n := (Max-1) DIV 2;
  WHILE (n >= 1) DO BEGIN
    FOR j := n TO Max DO BEGIN
      i := j-n;
      WHILE ((i >= 1) AND (RND2[i] > RND2[i+n])) DO BEGIN
        Swap      := RND2[i];
        RND2[i]   := RND2[i+n];
        RND2[i+n] := Swap;
        IF Mode = 2 THEN Anzeige;
        IF Waitting <> 0 THEN Wait(Waitting);
        i := i-n;
      END;
    END;
    n := n DIV 2;
    IF Mode = 1 THEN Anzeige;
  END;
END;

PROCEDURE MergeSort(N : Aptr);
VAR
  Aux           : ARRAY[1..Max] OF Char;
  lb2, ub1, ub2 : Aptr;
  lb1, I, J, K  : Aptr2;
  Size          : Integer;
BEGIN
  Size := 1;
  WHILE Size < N DO BEGIN
    lb1 :=1;
    K := 1;
    WHILE lb1+Size <= N DO BEGIN
      lb2 := lb1+Size;
      ub1 := lb2-1;
      IF lb2+Size-1 > N THEN ub2 := N ELSE ub2 := lb2+Size-1;
      I := lb1;
      J := lb2;
      WHILE (I <= ub1) AND (J <= ub2) DO BEGIN
        IF RND2[I] <= RND2[J] THEN BEGIN
          Aux[K] := RND2[I];
          I := I+1;
        END ELSE BEGIN
          Aux[K] := RND2[J];
          J := J+1;
        END;
        K := K+1;
      END;
      WHILE I <= ub1 DO BEGIN
        Aux[K] := RND2[I];
        I := I+1;
        K := K+1;
      END;
      WHILE J <= ub2 DO BEGIN
        Aux[K] := RND2[J];
        J := J+1;
        K := K+1;
      END;
      lb1 := ub2+1;
      IF Mode = 2 THEN Anzeige;
      IF Waitting <> 0 THEN Wait(Waitting);
    END;
    I := lb1;
    WHILE K <= N DO BEGIN
      Aux[K] := RND2[I];
      K := K+1;
      I := I+1;
    END;
    FOR K := 1 TO N DO RND2[K] := Aux[K];
    IF Mode = 1 THEN Anzeige;
    Size:=Size*2;
  END;
END;

PROCEDURE QuickSort(li,re : Integer);
VAR w : Char;
BEGIN
  i := li;
  j := re;
  Swap := RND2[((li+re) DIV 2)];
  IF Mode = 1 THEN Anzeige;
  REPEAT
    WHILE RND2[i] < Swap DO Inc(i);
    WHILE Swap < RND2[j] DO Dec(j);
    IF i<=j THEN BEGIN
      w       := RND2[i];
      RND2[i] := RND2[j];
      RND2[j] := w;
      Inc(i);
      Dec(j);
      IF Mode = 2 THEN Anzeige;
      IF Waitting <> 0 THEN Wait(Waitting);
    END;
  UNTIL i > j;
  IF li < j THEN QuickSort(li,j);
  IF i < re THEN QuickSort(i,re);
END;

PROCEDURE BucketSort;
VAR
  Bucket : ARRAY[0..255] OF Byte;
BEGIN
  FOR j := 0 TO 255 DO Bucket[j] := 0;
  FOR i := 1 TO Max DO Inc(Bucket[Ord(RND2[i])]);
  i := 1;
  j := 0;
  WHILE i <= Max DO BEGIN
    WHILE Bucket[j] = 0 DO Inc(j);
    RND2[i] := Chr(j);
    Dec(Bucket[j]);
    Inc(i);
    IF Mode = 2 THEN Anzeige;
    IF Waitting <> 0 THEN Wait(Waitting);
  END;
  IF Mode = 1 THEN Anzeige;
END;

BEGIN
  ClrScr;
  Randomize;
  TextMode(300);
  FOR i := 1 TO Max DO BEGIN
    RND1[i] := Chr(Random(25)+65);
  END;
  GotoXY(47,1);
  Write('MY SORT v2.0 (C) 2002-03-03');
  GotoXY(45,2);
  Write('-------------------------------');
  GotoXY(37,4);
  Write('Willkommen zur 2. Runde. Dieses Programm ist');
  GotoXY(37,5);
  Write('die zweite Version meines selbstentwickelt-');
  GotoXY(37,6);
  Write('em Demonstrationsprogrammes der bekannten');
  GotoXY(37,7);
  Write('Sortierverfahren.');
  GotoXY(37,8);
  Write('Ich habe es nun geschafft, viel mehr Åber');
  GotoXY(37,9);
  Write('einige Sortierverfahren in Erfahrung zu');
  GotoXY(37,10);
  Write('bringen und ihre Algorithmen durch Quellen');
  GotoXY(37,11);
  Write('aus dem WWW in meine eigene Implementier-');
  GotoXY(37,12);
  Write('ung modifiziert und angepasst.');
  GotoXY(37,13);
  Write('Neben den sehr bekannten und einfachen Sor-');
  GotoXY(37,14);
  Write('tierverfahren, die man oft in BÅchern fin-,');
  GotoXY(37,15);
  Write('det, bin ich auch auf sehr exotische und');
  GotoXY(37,16);
  Write('ausssergewîhnliche Verfahren gesto·en, "die');
  GotoXY(37,17);
  Write('nie zuvor ein Mensch je gesehen hat".');
  GotoXY(37,18);
  Write('Zwei oder drei dieser Exoten wird man in');
  GotoXY(37,19);
  Write('diesen Programm wiederfinden. Insgesamt be-');
  GotoXY(37,20);
  Write('inhaltet das Programm 12 Sortierverfahren.');
  GotoXY(37,21);
  Write('Der Sinn und Zweck dieses Programmes ist es,');
  GotoXY(37,22);
  Write('eine visuelle Darstellung der Sortierverfah-');
  GotoXY(37,23);
  Write('ren zu zeigen, wodurch sich das VerstÑndnis');
  GotoXY(37,24);
  Write('und die FunktionalitÑt der Sortierverfahren');
  GotoXY(37,25);
  Write('leichter verstehen lÑsst.');
  GotoXY(37,26);
  Write('Die gesamten Sortierverfahren sind nach der');
  GotoXY(37,27);
  Write('durchschnittlichen Laufzeit geordnet, wobei');
  GotoXY(37,28);
  Write('mit den langsamten Verfahren begonnen wird.');
  GotoXY(37,29);
  Write('Es gibt zudem eine normale (visuelle) Be-');
  GotoXY(37,30);
  Write('trachtung, eine genaue oder eben dann keine.');
  GotoXY(1,35);
  Write(  '     Sortierverfahren   normale Darstell.   genaue Darstell.   keine Darstell.');
  GotoXY(1,36);
  FOR i := 1 TO 79 DO Write('-');
  GotoXY(1,37);
  WriteLn('01.  BozoSort');
  WriteLn('02.  BubbleSort');
  WriteLn('03.  ShakerSort');
  WriteLn('04.  MaxSort');
  WriteLn('05.  ExchangeSort');
  WriteLn('06.  SelectSort');
  WriteLn('07.  InsertSort');
  WriteLn('08.  HeapSort');
  WriteLn('09.  ShellSort');
  WriteLn('10.  MergeSort');
  WriteLn('11.  QuickSort');
  WriteLn('12.  BucketSort');
  REPEAT
    Window(2,2,34,30);
    ClrScr;
    Window(1,1,80,50);
    Box(1,1,35,30);
    GotoXY(4,7);
    Write('WéHLEN SIE EINE NUMMER EINES');
    GotoXY(4,8);
    Write('SORTIERVERFAHRENS AUS!');
    GotoXY(4,9);
    Write('[1-12, 0 fÅr Quit]: ');
    ReadLn(SortNumber);
    IF SortNumber = 0 THEN Quit;
    GotoXY(4,11);
    Write('SOLL ES EINE NORMALE, EINE GE-');
    GotoXY(4,12);
    Write('NAUE ODER KEINE DARSTELLUNG');
    GotoXY(4,13);
    Write('WERDEN? [1-3, 0 fÅr Quit]: ');
    ReadLn(Mode);
    IF Mode = 0 THEN Quit;
    GotoXY(4,15);
    Write('FALLS SIE EINEN SCHNELLEN PC');
    GotoXY(4,16);
    Write('BESITZEN; WéRE EINE SCHNELLE');
    GotoXY(4,17);
    Write('DARSTELLUNG NICHT IMMER ANGE-');
    GotoXY(4,18);
    Write('BRACHT. GEBEN SIE DESHALB EINE');
    GotoXY(4,19);
    Write('KLEINE WARTEDAUER IN MILLISEK-');
    GotoXY(4,20);
    Write('UNDEN AN: ');
    ReadLn(Waitting);
    IF SortNumber <> 1 THEN BEGIN
      GotoXY(4,22);
      Write('DRöCKEN SIE NUN EINE TASTE,');
      GotoXY(4,23);
      Write('DAMIT DIE SORTIERUNG ERFOLGT.');
      ReadKey;
    END ELSE BEGIN
      GotoXY(4,22);
      Write('SIE HABEN BozoSort GEWéHLT.');
      GotoXY(4,23);
      Write('DIESE SORTIERUNG WIRD SEHR');
      GotoXY(4,24);
      Write('LANGE DAUERN UND KAUM EIN');
      GotoXY(4,25);
      Write('ENDE NEHMEN: DRöCKEN SIE');
      GotoXY(4,26);
      Write('DANN IM NOTFALL Strg+Break,');
      GotoXY(4,27);
      Write('UM DAS PROGRAMM ABZUBRECHEN.');
      ReadKey;
    END;
    Window(2,2,34,30);
    FOR i := 1 TO Max DO RND2[i] := RND1[i];
    IF Mode = 3 THEN BEGIN
      ClrScr;
      GotoXY(7,13);
      Write('KEINE ANZEIGE GEWéHLT!');
      Window(1,1,80,50);
      Box(1,1,35,30);
    END;
    Cursor(False);
    StartTimer;
    CASE SortNumber OF
      00 : Quit;
      01 : BozoSort;
      02 : BubbleSort;
      03 : ShakerSort;
      04 : MaxSort;
      05 : ExchangeSort;
      06 : SelectSort;
      07 : InsertSort;
      08 : HeapSort;
      09 : ShellSort;
      10 : MergeSort(Max);
      11 : QuickSort(1,Max);
      12 : BucketSort;
    END;
    GetTimer;
    Cursor(True);
    IF Mode <> 3 THEN Anzeige;
    Window(1,1,80,50);
    CASE Mode OF
      1 : i := 1;
      2 : i := 21;
      3 : i := 39;
    END;
    GotoXY(29+i,36+SortNumber);
    Write(Sec:5:2);
    Readkey;
  UNTIL SortNumber = 0;
END.
