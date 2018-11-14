(* ----------------------------------------------------- *)
(*                     COM2INL.PAS                       *)
(*      Programm zur Umwandlung von COM-Dateien in       *)
(*      Turbo-Pascal INLINE-Prozeduren/Funktionen.       *)
(*          (C) 1989, 2001 G. Meier & M. Johne           *)
(* ----------------------------------------------------- *)
(* Mit besten Dank an das Programmlisting von G. Meier.  *)
(* Aus seinem Programm INLASM.EXE konnte ich die Umrech- *)
(* nung einen ASCII-Zeichen in ein hexadezimalen String  *)
(* ausfÅhren, weil meine selbsterstellte Umrechnung Feh- *)
(* ler aufwies.                                          *)
(* ----------------------------------------------------- *)

PROGRAM Com2Inline;
(* Das ist der vollstÑndige Programmname;  also  so  wie *)
(* das Programm offiziell heisst.                        *)

USES Crt,Dos;          (* Das sind die benîtigten Units. *)

CONST
  COM : ExtStr = '.COM';
  INL : ExtStr = '.INL';
(* Diese beiden Konstanten wwerden gebraucht,  um an den *)
(* Eingaben der benîtigen Dateien die Erweiterung  anzu- *)
(* hÑngen,   damit es der Benutzer nicht machen braucht. *)
(* Beide Konstanten sind typerisiert und als ExtStr  de- *)
(* klariert.  Die typerisierte ExtStr wurde aus der Unit *)
(* Dos vordeklariert  und entspricht dem Typ  STRING[4]. *)
(* "COM" wird als Extension fÅr eine Com-Datei gebraucht *)
(* "INL" steht fÅr eine Datei der INLINE-Prozedur.       *)

VAR
  Timer     : Byte;
(* Dies ist eine Variable  fÅr  das Messen des Plazieren *)
(* der jeweiligen hexadezimalen Wert aus einer COM-Datei *)
(* in eine INLINE-Prozedur.                              *)
  Data      : Char;
(* Diese kleine Variable  dient  zum Lesen des einzelnen *)
(* Zeichen in einer COM-File. SpÑter wird sie zum Anzei- *)
(* gen der fertig erstellten INLINE-Prozedur verwendet.  *)
  ComFile,
  InlProc   : NameStr;
(* Bei diesen beiden Variablen handelt es sich um Zeich- *)
(* enkettenvariablen des  Typs  STRING[8],  die von  der *)
(* Unit Dos als typerisierte Variable  "NameStr"  vorde- *)
(* klariert worden.  "ComFile"  ist als spÑtere  Eingabe *)
(* vom User fÅr eine COM-Datei zugeordnet und  "InlProc" *)
(* benîtigt man fÅr eine Datei der INLINE-Prozedur.      *)
  CF,IP     : Text;
(* Mit diesen beiden Variablen wird den beiden  Zeichen- *)
(* ketten der jeweiligen  benutzten  Dateien ein weitere *)
(* Dateivariable zugeordnet. Der Syntax von TURBO PASCAL *)
(* 7.0 schreibt diesen Aufbau vor. "CF" ist fÅr die COM- *)
(* Datei jeweilig zugestellt und  "IP"  wird fÅr die IN- *)
(* LINE-Prozedur gebraucht.    Beide Dateivarialben sind *)
(* Akronyme fÅr die Variablen der Zeichenketten der  Da- *)
(* teien:                                                *)
(*       CF steht fÅr ComFile                            *)
(*                    ^  ^    und                        *)
(*       IP steht fÅr InlProc                            *)
(*                    ^  ^    .                          *)

PROCEDURE DeziToHexa(ConvertByte : Byte);
CONST
  HexDigits : ARRAY[0..15] OF Char
              =('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
VAR
  Digit       : Byte;
  FirstDigit,
  SecondDigit : Char;
  HexStr      : STRING[3];
BEGIN
  Digit  := ConvertByte DIV 16;
  FirstDigit  := HexDigits[Digit];
  Digit  := ConvertByte MOD 16;
  SecondDigit := HexDigits[Digit];
  HexStr := '$'+FirstDigit+SecondDigit;
  Write(IP,HexStr);
  IF Not(EoF(CF)) THEN IF Timer = 15 THEN BEGIN
    WriteLn(IP,'/');
    Timer := 0;
    Write(IP,'         ');
  END ELSE Write(IP,'/');
END;

BEGIN
  ClrScr;
  TextColor(LightCyan);
  Write('Com2Inline v1.0');
  TextColor(LightGray);
  Write(' converts a ');
  TextColor(White);
  Write('COM-File');
  TextColor(LightGray);
  Write(' into a ');
  TextColor(White);
  Write('INLINE-PROCEDURE');
  TextColor(LightGray);
  WriteLn(' for PAS-File.'^j^m);
  TextColor(LightBlue);
  Write('     COM-File without extension:      ');
  ReadLn(ComFile);
  Write('     INL-Procedure without extension: ');
  ReadLn(InlProc);
  Assign(CF,ComFile+COM);
  Assign(IP,InlProc+INL);
  Reset(CF);
  Rewrite(IP);
  WriteLn(IP,'PROCEDURE ',InlProc,';');
  WriteLn(IP,'BEGIN');
  Write(IP,'  INLINE(');
  Timer := 0;
  REPEAT
    Inc(Timer);
    Read(CF,Data);
    DeziToHexa(Ord(Data));
  UNTIL EoF(CF);
  WriteLn(IP,');');
  WriteLn(IP,'END;');
  Close(CF);
  Close(IP);
  Reset(IP);
  TextColor(Yellow);
  Window(1,7,80,20);
  REPEAT
    Read(IP,Data);
    Write(Data);
  UNTIL EoF(IP);
  Close(IP);
  Window(1,1,80,25);
  GotoXY(1,22);
  TextColor(White+Blink);
  WriteLn(InlProc+INL,' sucessfully created...');
  ReadKey;
  TextColor(White);
END.