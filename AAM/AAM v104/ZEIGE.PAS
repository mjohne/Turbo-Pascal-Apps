
(* ------------------------------------------------------ *)
(*                      ZEIGE.PAS                         *)
(* Ersatz fÅr den Dos-Befehl "TYPE". Man kann damit jede  *)
(* beliebige ASCII-Datei anschauen und darin vorwÑrts     *)
(* und rÅckwÑrts blÑttern. Aufruf am besten mit dem       *)
(* Namen der zu lesenden Datei als Parameter, sonst wird  *)
(* ein Dateiname erfragt.                                 *)
(*       (c) 1989  Achim Bergmeister & TOOLBOX            *)
(* ------------------------------------------------------ *)
PROGRAM Zeige;

USES Crt, Dos;

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

  PROCEDURE StringSpeichern(st: Str; VAR zeiger: StrZeiger);
  { Speichert die jeweils gelesene Zeile in einer          }
  { dynamischen Struktur                                   }
  VAR
    x : BYTE ABSOLUTE st;
  BEGIN
    GetMem(zeiger, Succ(x));
    Move(st, zeiger^, Succ(x));
  END;

  PROCEDURE StringLesen(zeiger: StrZeiger; VAR st: Str);
  { liest die dynamisch abgespeicherten Zeilen wieder in   }
  { eine normale Stringvariable ein.                       }
  BEGIN
    st := zeiger^;
  END;

  PROCEDURE SpeicherFrei(st: StrZeiger);
  { gibt den belegten Speicherplatz frei                   }
  BEGIN
    FreeMem(st, Succ(Ord(st^[0])));
  END;

  FUNCTION Kleiner(x, y: INTEGER) : INTEGER;
  BEGIN
    IF x < y THEN Kleiner := x ELSE Kleiner := y;
  END;

  PROCEDURE Stellung;
  { gibt die Nummer der jeweils letzten auf dem Bildschirm }
  { dargestellten Zeile und die Gesamtzeilenzahl aus.      }
  BEGIN
    Window(1,1,80,25);  TextAttr := 112;
    GotoXY(36,1);
    Write(aktzeile:4, ' von ', max);
    TextAttr := 10;     Window (1,2,80,25);
  END;

  PROCEDURE Down;
  BEGIN
    IF aktzeile < max THEN BEGIN
      Inc(aktzeile);
      StringLesen(zeile[aktzeile], z);
      GotoXY(1,24);  WriteLn(z);
    END;
    Stellung;
  END;

  PROCEDURE Up;
  BEGIN
    IF aktzeile > 23 THEN BEGIN
      Dec(aktzeile);
      StringLesen(zeile[aktzeile - 22], z);
      GotoXY(1,1);  InsLine;  Write(z);
    END;
    Stellung;
  END;

  PROCEDURE Ende;
  BEGIN
    IF max > 23 THEN BEGIN
      ClrScr;
      FOR j := max-23 TO max DO BEGIN
        StringLesen(zeile[j], z);
        WriteLn (z);
      END;
      aktzeile := max;
    END;
    Stellung;
  END;

  PROCEDURE Anfang;
  BEGIN
    ClrScr;
    FOR j := 1 TO Kleiner(23, max) DO BEGIN
      StringLesen(zeile[j], z);
      WriteLn(z);
    END;
    aktzeile := Kleiner(23, max);
    Stellung;
  END;

  PROCEDURE PageDown;
  BEGIN
    IF aktzeile < max - 24 THEN BEGIN
      ClrScr;
      FOR j := 1 TO 23 DO BEGIN
        Inc(aktzeile);
        StringLesen(zeile[aktzeile], z);
        WriteLn(z);
      END;
    END ELSE
      IF (aktzeile < max) AND (aktzeile >= max - 24) THEN
        Ende;
    Stellung;
  END;

  PROCEDURE PageUp;
  BEGIN
    IF aktzeile > 46 THEN BEGIN
      ClrScr;  Dec(aktzeile, 46);
      FOR j := 1 TO 23 DO BEGIN
        Inc(aktzeile);
        StringLesen(zeile[aktzeile], z);
        WriteLn(z);
      END;
    END ELSE
      IF (aktzeile > 23) AND (aktzeile < 47) THEN
        Anfang;
    Stellung;
  END;

BEGIN
  IF ParamCount > 0 THEN
    Name := ParamStr(1)
  ELSE BEGIN
    Write ('Dateiname: '); ReadLn (Name);
  END;
  IF Name <> '' THEN BEGIN
    Assign(f, Name);
{$I-}
    Reset(f);
{$I+}
    IF IOResult <> 0 THEN BEGIN
      Write('Lesefehler !');  Halt;
    END;
        { gewÅnschte Datei lesen und dynamisch abspeichern }
    i := 0;
    WHILE (NOT Eof (f)) AND (i < maxzahl) DO BEGIN
      Inc(i);  ReadLn(f, z);
      StringSpeichern(z, zeile[i]);
    END;
    max := i;                          { Anzahl der Zeilen }
    Close(f);  ClrScr;
                                     { Titelzeile ausgeben }
    TextAttr := 112;
    Write('Datei: ', Name);
    Write(' ':73 - Length(Name));
    GotoXY(49, 1);
    Write('≥Home≥END≥PgUp≥PgDn≥', Chr(24),
          '≥', Chr(25), '≥Esc=Ende');
    TextAttr := 10;  Window (1,2,80,25);
    GotoXY(1,1);
                                       { Cursor verstecken }
    Regs.ah := 1;   Regs.ch := 30;
    Regs.cl := 30;  Intr ($10,Regs);

    { ZunÑchst die ersten 23 -oder weniger- Zeilen zeigen. }
    FOR j := 1 TO Kleiner (23, max) DO BEGIN
      StringLesen(zeile[j], z);
      WriteLn(z);
    END;
    aktzeile := Kleiner(23, max);
    Stellung;
                            { Schleife mit Tastaturabfrage }
    REPEAT
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
                         { Speicherplatz wieder freimachen }
    FOR i := 1 TO max DO
      SpeicherFrei(zeile[i]);
    Window(1,1,80,25);   GotoXY(1,25);
                                    { cursor wieder zeigen }
    Regs.ah := 1;   Regs.ch := 11;
    Regs.cl := 12;  Intr ($10,Regs);
  END;
END.
(* ------------------------------------------------------ *)
(*                  Ende von ZEIGE.PAS                    *)