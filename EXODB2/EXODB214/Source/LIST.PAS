(* ------------------------------------------------------ *)
(*                      LIST.PAS                          *)
(* Erweitert 2005 von Michael Johne auf Textmodus 80x50   *)
(* ------------------------------------------------------ *)
(*                      ZEIGE.PAS                         *)
(* Ersatz fÅr den Dos-Befehl "TYPE". Man kann damit jede  *)
(* beliebige ASCII-Datei anschauen und darin vorwÑrts     *)
(* und rÅckwÑrts blÑttern. Aufruf am besten mit dem       *)
(* Namen der zu lesenden Datei als Parameter, sonst wird  *)
(* ein Dateiname erfragt.                                 *)
(*       (c) 1989  Achim Bergmeister & TOOLBOX            *)
(* ------------------------------------------------------ *)

PROGRAM List;

USES Crt,Dos,Cursor,RT_Watch;

TYPE
  Str        = STRING;
  StrZeiger  = ^Str;

CONST
  maxzahl = 2000;      { maximale Zahl einzulesender Zeilen }

VAR
  zeile     : ARRAY [1..maxzahl] OF StrZeiger;
  aktzeile  : INTEGER;
  max, i, j : INTEGER;
  f         : TEXT;
  Name,z    : STRING;
  ch        : CHAR;
  Regs      : Registers;

PROCEDURE StringSpeichern(st : Str; VAR zeiger : StrZeiger);
{ Speichert die jeweils gelesene Zeile in einer          }
{ dynamischen Struktur                                   }
VAR
  x : BYTE ABSOLUTE st;
BEGIN
  GetMem(zeiger,Succ(x));
  Move(st,zeiger^,Succ(x));
END;

PROCEDURE StringLesen(zeiger : StrZeiger; VAR st : Str);
{ liest die dynamisch abgespeicherten Zeilen wieder in   }
{ eine normale Stringvariable ein.                       }
BEGIN
  st := zeiger^;
END;

PROCEDURE SpeicherFrei(st : StrZeiger);
{ gibt den belegten Speicherplatz frei                   }
BEGIN
  FreeMem(st,Succ(Ord(st^[0])));
END;

FUNCTION Kleiner(x,y : INTEGER) : INTEGER;
BEGIN
  IF x < y THEN Kleiner := x ELSE Kleiner := y;
END;

PROCEDURE Stellung;
{ gibt die Nummer der jeweils letzten auf dem Bildschirm }
{ dargestellten Zeile und die Gesamtzeilenzahl aus.      }
BEGIN
  Window(1,1,80,50); TextAttr := 112;
  GotoXY(36,1);
  Write(aktzeile:4,' von ', max);
  TextAttr := 10; Window(1,2,80,50);
END;

PROCEDURE Down;
BEGIN
  IF aktzeile < max THEN BEGIN
    Inc(aktzeile);
    StringLesen(zeile[aktzeile],z);
    GotoXY(1,49); WriteLn(z);
  END;
  Stellung;
END;

PROCEDURE Up;
BEGIN
  IF aktzeile > 48 THEN BEGIN
    Dec(aktzeile);
    StringLesen(zeile[aktzeile-47],z);
    GotoXY(1,1); InsLine; Write(z);
  END;
  Stellung;
END;

PROCEDURE Ende;
BEGIN
  IF max > 48 THEN BEGIN
    ClrScr;
    FOR j := max-48 TO max DO BEGIN
      StringLesen(zeile[j],z);
      WriteLn(z);
    END;
    aktzeile := max;
  END;
  Stellung;
END;

PROCEDURE Anfang;
BEGIN
  ClrScr;
  FOR j := 1 TO Kleiner(48,max) DO BEGIN
    StringLesen(zeile[j],z);
    WriteLn(z);
  END;
  aktzeile := Kleiner(48,max);
  Stellung;
END;

PROCEDURE PageDown;
BEGIN
  IF aktzeile < max - 49 THEN BEGIN
    ClrScr;
    FOR j := 1 TO 48 DO BEGIN
      Inc(aktzeile);
      StringLesen(zeile[aktzeile],z);
      WriteLn(z);
    END;
  END ELSE IF (aktzeile < max) AND (aktzeile >= max-49) THEN Ende;
  Stellung;
END;

PROCEDURE PageUp;
BEGIN
  IF aktzeile > 96 THEN BEGIN
    ClrScr; Dec(aktzeile,96);
    FOR j := 1 TO 48 DO BEGIN
      Inc(aktzeile);
      StringLesen(zeile[aktzeile],z);
      WriteLn(z);
    END;
  END ELSE IF (aktzeile > 48) AND (aktzeile < 96) THEN Anfang;
  Stellung;
END;

BEGIN
  TextMode(300);
  TextBackground(Black);
  ClrScr;
  IF ParamCount > 0 THEN
    Name := ParamStr(1)
  ELSE BEGIN
    Write('Dateiname: '); ReadLn (Name);
  END;
  IF Name <> '' THEN BEGIN
    Assign(f,Name);
    {$I-}
    Reset(f);
    {$I+}
    IF IOResult <> 0 THEN BEGIN
      Write('Lesefehler !'); Halt;
    END;
        { gewÅnschte Datei lesen und dynamisch abspeichern }
    i := 0;
    WHILE (NOT Eof(f)) AND (i < maxzahl) DO BEGIN
      Inc(i); ReadLn(f,z);
      StringSpeichern(z,zeile[i]);
    END;
    max := i;                          { Anzahl der Zeilen }
    Close(f); ClrScr;
    TextAttr := 112;                 { Titelzeile ausgeben }
    Write('Datei: ',Name);
    Write(' ':73-Length(Name));
    GotoXY(49,1);
    Write('≥Home≥END≥PgUp≥PgDn≥', Chr(24),
          '≥', Chr(25), '≥Esc=Ende');
    TextAttr := 10; Window (1,2,80,50);
    GotoXY(1,1);
    HideCursor;                        { Cursor verstecken }
    { ZunÑchst die ersten 48 -oder weniger- Zeilen zeigen. }
    FOR j := 1 TO Kleiner(48, max) DO BEGIN
      StringLesen(zeile[j], z);
      WriteLn(z);
    END;
    aktzeile := Kleiner(48,max);
    Stellung;
    REPEAT                  { Schleife mit Tastaturabfrage }
      ch := ReadKey;
      IF ch = #0 THEN BEGIN
        ch := ReadKey;
        CASE ch OF
          #80 : Down;
          #72 : Up;
          #73 : PageUp;
          #81 : PageDown;
          #71 : Anfang;
          #79 : Ende;
        END;
      END;
    UNTIL ch = #27;                     { bis Esc gedrÅckt }
    FOR i := 1 TO max DO { Speicherplatz wieder freimachen }
      SpeicherFrei(zeile[i]);
    Window(1,1,80,25); GotoXY(1,25);
    ShowCursor;                     { cursor wieder zeigen }
  END;
END.
