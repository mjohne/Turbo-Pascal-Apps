PROGRAM XDEL;

USES Dos;

VAR
  Control,n : Integer;
  DelFile   : Text;

LABEL Back;

BEGIN
Back:
  WriteLn('XDEL - Extra Delete   (C) 2002 by Michael Johne');
  WriteLn;
  WriteLn('XDEL dient zum sicheren Lîschen von Dateien durch öberschreiben.');
  WriteLn;
  IF ParamCount <> 2 THEN BEGIN
    WriteLn('Aufruf: XDEL numb [Drive:\][Path\]Filename.Ext');
    WriteLn('        numb - Anzahl, wieviel mal die Datei Åberschrieben wird.');
    WriteLn('               Mîglich ist numb von 1 bis 32767.');
    WriteLn;
    Halt;
  END;
  Val(ParamStr(1),n,Control);
  IF Control <> 0 THEN GOTO Back;
  Assign(DelFile,ParamStr(2));
  FOR n := 1 TO n DO BEGIN
    Rewrite(DelFile);
    Close(DelFile);
  END;
  Erase(DelFile);
  WriteLn(ParamStr(2),' is sucessfully deleted!');
  WriteLn;
END.