PROGRAM A_fractal_Brownian_motion_sound_generator_AFBMSG;

USES Crt,Dos;

VAR
  PSS_File : Text;
  Filename : STRING;
  i,n,a,b,
  HzDiff,
  DefaultHzLen,
  MinHzDiff,
  MaxHzDiff,
  MinSoundDiff,
  MaxSoundDiff,
  Sounds,
  SoundLen : Word;

BEGIN
  ClrScr;
  Randomize;
  Write('Anzahl der T”ne: ');
  ReadLn(Sounds);
  Write('Frequenzbeginn (in Hz): ');
  ReadLn(HzDiff);
  Write('Minimale Frequenzdifferenz (in Hz): ');
  ReadLn(MinHzDiff);
  Write('Maximale Frequenzdifferenz (in Hz): ');
  ReadLn(MaxHzDiff);
  Write('Minimale Tonl„nge (in ms): ');
  ReadLn(MinSoundDiff);
  Write('Maximale Tonl„nge (in ms): ');
  ReadLn(MaxSoundDiff);
  Write('Name der PSS-Datei zum Abspeichern: ');
  ReadLn(Filename);
  Assign(PSS_File,Filename);
  Rewrite(PSS_File);
  Write(PSS_File,'PSS');
  FOR i := 1 TO Sounds DO BEGIN
    REPEAT n := Random(MaxHzDiff+1); UNTIL n > MinHzDiff;
    a := Random(2);
    CASE a OF
      0 : HzDiff := HzDiff-n;
      1 : HzDiff := HzDiff+n;
    END;
    REPEAT n := Random(MaxSoundDiff+1); UNTIL n > MinSoundDiff;
    SoundLen := n;
    Write(PSS_File,Chr(Hi(HzDiff)),Chr(Lo(HzDiff)));
    Write(PSS_File,Chr(Hi(SoundLen)),Chr(Lo(SoundLen)));


  END;

  Close(PSS_File);
END.


CONST
  Blank = 'ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ';
{ s = 50; o = 100; q = 200; tq = 300; h = 400; th = 500; w = 800;

       sixteenth,eighth,quarter,half,whole

  lC =  262; lD = 294; lE = 330; lF = 350; lG = 392; lA = 440; lB = 494;
  lCs=  277; lDs= 311;           lFs= 370; lGs= 415; lAs= 466;

  C  =  523; D  = 587; E  = 659; F  = 698; G  = 784; A  = 880; B  = 988;
  Cs =  554; Ds = 622;           Fs = 740; Gs = 830; As = 932;

  hC = 1046;      two octaves       constants for Play procedure }

VAR
  i : Byte;
  s_w : ARRAY[1..4] OF Char;
  f1     : Text;
  f0 : FILE OF Byte;
  x : Char;
  c,Time_,Timer,Size : LongInt;
  p1,w1,s1 : Word;

PROCEDURE Center(Row: Integer; Str: STRING);
BEGIN
  Gotoxy(41-Length(Str) DIV 2,Row);
  Write(Str);
END;

PROCEDURE Wait(ms : LongInt);
VAR
  Hour,Minute,Second,Sec100 : Word;
  MilliSec,MilliSec1,MilliSec2 : LongInt;
BEGIN
  ms := ms DIV 10;
  GetTime(Hour,Minute,Second,Sec100);
  MilliSec1 := (144000*Hour)+(6000*Minute)+(100*Second)+Sec100;
  REPEAT
    gotoXY(1,1);
    GetTime(Hour,Minute,Second,Sec100);
    MilliSec2 := (144000*Hour)+(6000*Minute)+(100*Second)+Sec100;
  UNTIL ((MilliSec2-MilliSec1) >= ms);
END;

FUNCTION MyHi(h : Word) : Byte;
BEGIN
  MyHi := Trunc(h DIV 256);
END;

FUNCTION MyLo(l : Word) : Byte;
BEGIN
  MyLo := l-MyHi(l);
END;

PROCEDURE OutPut(Str1 : STRING; a : Word; Str2 : STRING);
BEGIN
  TextColor(LightGreen);
  Write(Str1);
  TextColor(White);
  Write(a:7);
  TextColor(LightCyan);
  Write(Str2);
END;

PROCEDURE Time;
VAR t : ARRAY[1..2] OF Char;
BEGIN
  Timer := 0;
  Assign(f1,ParamStr(1));
  Reset(f1);
  FOR i := 1 TO 3 DO Read(f1,x);
  REPEAT
    FOR i := 1 TO 2 DO Read(f1,x);
    FOR i := 1 TO 2 DO Read(f1,t[i]);
    Timer := Timer+(Ord(t[1])*256)+Ord(t[2])+Ord(t[1]);
  UNTIL EoF(f1);
  Close(f1);
END;

PROCEDURE Play(Note,Value : Integer );
BEGIN
  Sound(Note);
  Delay(Value);
  NoSound;
  Delay(20);
END;

BEGIN
  ClrScr;
  TextColor(White);
  Center(2,'PC SPEAKER SOUND (PSS) Player v1.0  þ  (c) 2003 Michael Johne');
  Center(3,'---------------------------------------------------------------');
  TextColor(LightGray);
  GotoXY(1,4);
  IF ParamStr(1) = '' THEN BEGIN
    WriteLn('file not found - input Parameter');
    WriteLn('for example: play_pss.exe demo.pss');
    Halt(2);
	END ELSE Time;
  TextColor(LightGray);
	Write('load file:   ');
	TextColor(LightBlue);
	WriteLn(ParamStr(1));
  Assign(f0,ParamStr(1));
  Reset(f0);
  Size := FileSize(f0);
  TextColor(LightGray);
	Write('file size:   ');
	TextColor(Yellow);
	Write(Size);
  TextColor(White);
	WriteLn(' bytes');
  TextColor(LightGray);
	Write('records:     ');
	TextColor(Yellow);
	Write((Size DIV 4)-1);
  TextColor(White);
	WriteLn(' counts');
  Close(f0);
  GotoXY(30,4);
	Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  GotoXY(30,5); Write('³');
  GotoXY(65,5); Write('³');
  GotoXY(30,6);
  Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  GotoXY(20,8);
  Write('³');
  GotoXY(20,10);
  Write('³');
  GotoXY(20,9);
  Write('ÃÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅÄÅ');
  TextColor(LightGreen);
  Assign(f1,ParamStr(1));
  Reset(f1);
  FOR i := 1 TO 3 DO Read(f1,x);
  REPEAT
    FOR i := 1 TO 4 DO Read(f1,s_w[i]);
    s1 := (Ord(s_w[1])*256)+Ord(s_w[2])+Ord(s_w[1]);
    w1 := (Ord(s_w[3])*256)+Ord(s_w[4])+Ord(s_w[3]);
    Inc(c);
    IF c > (Size DIV 4)-1 THEN c := (Size DIV 4)-1;
    p1 := Round((100*c)/((Size DIV 4)-1));
    IF p1 > 100 THEN p1 := 100;
    Time_ := Time_+w1;
    GotoXY(1,8);  Output('Count: ',c,'');
    TextColor(LightCyan);
    Write('->');
    TextColor(White);
f		Write((Size DIV 4)-1);
    GotoXY(1,9); Output('Hertz: ',s1,'  hz');
    GotoXY(1,10);  Output('Delay: ',w1,'  ms');
    GotoXY(67,4); TextColor(White); Write(p1); TextColor(LightCyan); Write(' %');
    GotoXY(67,5); TextColor(White); Write((Time_)/1000:0:2); TextColor(LightCyan); Write(' sec');
    GotoXY(67,6); TextColor(White); Write((Timer)/1000:0:2); TextColor(LightCyan); Write(' sec');
    TextColor(Blue);
    GotoXY(31,5);
    FOR i := 0 TO Round(p1/3) DO Write('²');
		TextColor(Black);
    GotoXY(21,8);
    Write(Blank);
    GotoXY(21,10);
    Write(Blank);
    GotoXY(21,8);
    FOR i := 0 TO Round(s1/20) DO BEGIN
      IF i IN [00..20] THEN TextColor(LightGreen);
      IF i IN [21..40] THEN TextColor(Yellow);
      IF i IN [41..60] THEN TextColor(LightRed);
      Write('þ');
    END;
    GotoXY(21,10);
    TextColor(LightCyan);
    FOR i := 0 TO Round(w1/20) DO BEGIN
      IF i IN [00..10] THEN TextColor(Blue);
      IF i IN [11..20] THEN TextColor(LightBlue);
      IF i IN [21..30] THEN TextColor(Cyan);
      IF i IN [31..40] THEN TextColor(LightCyan);
      IF i IN [41..50] THEN TextColor(White);
      IF i IN [51..60] THEN TextColor(White);
      Write('þ');
    END;
    Play(s1,w1);
    IF KeyPressed THEN BEGIN
      NoSound;
      WriteLn;
      Halt(0);
    END;
  UNTIL EoF(f1);
  Close(f1);
  NoSound;
END.
