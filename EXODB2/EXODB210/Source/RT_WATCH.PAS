UNIT RT_Watch;

INTERFACE

FUNCTION Hex(Value : Byte) : STRING;

IMPLEMENTATION

USES Crt;

VAR OldExit : Pointer;

{====================================================================}
FUNCTION Hex(Value:byte) : STRING;

CONST HexTable : ARRAY[0..15] OF Char=('0','1','2','3','4','5','6','7',
                                       '8','9','A','B','C','D','E','F');

VAR HexStr : STRING;

BEGIN
  HexStr[2] := HexTable[Value AND $0F];
  HexStr[1] := HexTable[Value AND $F0 DIV 16];
  HexStr[0] := #2;
  Hex := HexStr;
END;

PROCEDURE RunTimeExitProc; FAR;

VAR Message : STRING;

BEGIN
  IF ErrorAddr <> NIL THEN BEGIN
    ClrScr;
    TextColor(LightRed);
    WriteLn(^j^j^j^j'RUNTIME WATCHER v1.0 MJ (C) 2003');
    TextColor(Red+Blink);
    WriteLn('Fehler gefunden...');
    TextColor(White);
    CASE ExitCode OF
        2 : Message := 'Datei wurde nicht gefunden';
        3 : Message := 'Verzeichnispfad wurde nicht gefunden';
        4 : Message := 'Zu viele ge�ffnete Dateien';
        5 : Message := 'Ben�tige Dateizugriff';
        6 : Message := 'Falscher Dateizugriff';
        8 : Message := 'Ungen�gend Speicher';
       12 : Message := 'Ung�ltiger Dateizugriffscode';
       15 : Message := 'Ung�ltige Laufwerksangabe';
       16 : Message := 'Datei kann nicht bewegt werden';
       17 : Message := 'Datei kann nicht umbenannt werden';
      100 : Message := 'Lesefehler';
      100 : Message := 'Schreibfehler';
      102 : Message := 'Datei nicht zugewiesen';
      103 : Message := 'Datei nicht ge�ffnet';
      104 : Message := 'Datei nur f�r Schreibzugriffe ge�ffnet';
      105 : Message := 'Datei nur f�r Lesezugriffe ge�ffnet';
      106 : Message := 'Ung�ltiges Zahlenformat';
      150 : Message := 'Datentr�ger ist schreibgesch�tzt';
      151 : Message := 'Unbekannte Einheit';
      152 : Message := 'Datentr�ger nicht fertig';
      153 : Message := 'Ungekannter Befehl';
      154 : Message := 'CRC Fehler in Daten';
      155 : Message := 'Datentr�ger m�glicherweise besch�digt';
      156 : Message := 'Schreibfehler';
      157 : Message := 'Unbekannter Datentr�ger';
      158 : Message := 'Sektor nicht gefunden';
      159 : Message := 'Papier fehlt im Drucker';
      160 : Message := 'Allgemeiner Schreibfehler';
      161 : Message := 'Allgemeiner Lesefehler';
      162 : Message := 'Allgemeiner Hardware-Fehler';
      200 : Message := 'Division durch Null';
      201 : Message := 'Range check error';
      202 : Message := 'Stack-�berlauf';
      203 : Message := 'Heap-�berlauf';
      204 : Message := 'Ung�ltiger Zeiger-Ausf�hrung';
      205 : Message := 'Kommazahlen-�berlauf';
      206 : Message := 'Kommazahlen-Unterlauf';
      207 : Message := 'Ung�ltiger Rechen-Operation';
      208 : Message := 'Overlay manager not installed';
      209 : Message := 'Overlay file read error';
      210 : Message := 'Object not initialized';
      211 : Message := 'Call to abstract method';
      212 : Message := 'Stream register error';
      213 : Message := 'Collection index out of range';
      214 : Message := 'Collection overflow error';
    END;
    Writeln('Error: ',ExitCode,
            ' Segment: ',Hex(Seg(ErrorAddr^)),
            ' Offset: ',Hex(Ofs(ErrorAddr^)),
            ' ',Message);
    ErrorAddr := NIL;
    ExitCode  := 1;
  END;
  ExitProc := OldExit;
END;

BEGIN
  OldExit  := ExitProc;
  ExitProc := @RunTimeExitProc;
END.
