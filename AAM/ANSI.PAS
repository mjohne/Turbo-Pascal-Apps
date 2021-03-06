PROGRAM ANSI;

USES Crt,DOS;

Procedure Draw_Ansi(Name:String);
{gibt ein Ansi-File auf dem Bildschirm aus (ANSI.SYS erforderlich !)}
Var Ansi:File;                  {Ansi-Datei}
    StdOut:File;                {Standard-Ausgabe Datei (Int 21h)}
    Puffer:Pointer;             {Zwischenpuffer f�r Bildschirm}
    Groesse:Word;               {Dateigr��e}
Begin
  Assign(Ansi,Name);            {Ansi-File �ffnen}
  Assign(StdOut,'CON');         {Ausgabe-File �ffnen}

  Reset(Ansi,1);                {Ansi-File mit Blockgr��e 1 Byte init.}
  Groesse:=FileSize(Ansi);      {Gr��e (in Byte) bestimmen}
  Reset(Ansi,Groesse);          {Datei mit dieser Gr��e erneut initialisieren}
  Reset(StdOut,Groesse);        {Ausgabe-Datei initialisieren}

  GetMem(Puffer,Groesse);       {Puffer allokieren}
  BlockRead(Ansi,Puffer^,1);    {File lesen ...}
  BlockWrite(StdOut,Puffer^,1); {... und ausgeben}
  FreeMem(Puffer,Groesse);      {Puffer freigeben}
  Close(Ansi);                  {Dateien schlie�en}
  Close(StdOut);
End;

BEGIN
  Draw_ANSI(ParamStr(1));
  Readkey;
END.


Unit Tools;

Interface

procedure sin_gen(var tabelle:Array of word;periode,amplitude,offset:word);
Procedure Draw_Ansi(Name:String);


Implementation

procedure sin_gen(var tabelle:Array of word;periode,amplitude,offset:word);
{berechet eine Sinus-Tabelle der L�nge periode vor,
 legt diese im Array tabelle ab.
 Dabei wird die "H�he" in der Variablen Amplitude und
 die Lage des Nullpunkts in offset verlangt}
Var i:Word;
Begin
  for i:=0 to periode-1 do
    tabelle[i]:=round(sin(i*2*pi/periode)*amplitude)+offset;
End;

Procedure Draw_Ansi(Name:String);
{gibt ein Ansi-File auf dem Bildschirm aus (ANSI.SYS erforderlich !)}
Var Ansi:File;                  {Ansi-Datei}
    StdOut:File;                {Standard-Ausgabe Datei (Int 21h)}
    Puffer:Pointer;             {Zwischenpuffer f�r Bildschirm}
    Groesse:Word;               {Dateigr��e}
Begin
  Assign(Ansi,Name);            {Ansi-File �ffnen}
  Assign(StdOut,'CON');         {Ausgabe-File �ffnen}

  Reset(Ansi,1);                {Ansi-File mit Blockgr��e 1 Byte init.}
  Groesse:=FileSize(Ansi);      {Gr��e (in Byte) bestimmen}
  Reset(Ansi,Groesse);          {Datei mit dieser Gr��e erneut initialisieren}
  Reset(StdOut,Groesse);        {Ausgabe-Datei initialisieren}

  GetMem(Puffer,Groesse);       {Puffer allokieren}
  BlockRead(Ansi,Puffer^,1);    {File lesen ...}
  BlockWrite(StdOut,Puffer^,1); {... und ausgeben}
  FreeMem(Puffer,Groesse);      {Puffer freigeben}
  Close(Ansi);                  {Dateien schlie�en}
  Close(StdOut);
End;

Begin
End.
