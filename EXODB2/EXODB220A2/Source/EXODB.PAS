unit EXODB;

interface

uses democmds,{Method,Startype,Dustdisc,Dis_Stat,}
  Drivers, Objects, Views, Dialogs, ColorTxt,textview;

{VAR
  DiscoverMethodPointer : PDialogDiscoverMethod;
  DiscoverStatusPointer : PDialogDiscoverStatus;}


type
  DataRec = record
    Field5 : String[255];
    Field7 : String[255];
    Field11 : String[255];
    Field19 : String[255];
    Field20 : String[255];
    Field23 : String[255];
    Field24 : String[255];
    Field25 : String[255];
    Field26 : String[255];
    Field35 : String[255];
    Field40 : String[255];
    Field41 : String[255];
    Field42 : String[255];
    Field45 : String[255];
    Field47 : String[255];
    Field48 : String[255];
    Field49 : String[255];
    Field50 : String[255];
    Field51 : String[255];
    Field53 : String[255];
    Field54 : String[255];
    Field55 : String[255];
    Field56 : String[255];
    Field57 : String[255];
    Field58 : String[255];
    Field59 : String[255];
    Field61 : String[255];
    Field63 : String[255];
    Field65 : String[255];
    Field66 : String[255];
    Field71 : String[255];
    Field72 : String[255];
    Field74 : String[255];
    Field76 : String[255];
    Field77 : String[255];
    Field78 : String[255];
    Field79 : String[255];
    Field80 : String[255];
    Field82 : String[255];
    Field83 : String[255];
    Field84 : String[255];
    Field86 : String[255];
    Field89 : String[6];
    Field90 : String[255];
    Field91 : String[255];
    Field92 : String[255];
    Field93 : String[255];
    Field94 : String[255];
    Field95 : String[255];
    Field96 : String[255];
    Field97 : String[255];
    Field98 : String[255];
    end;


  { TDialogEXODB2 }
  PDialogEXODB2 = ^TDialogEXODB2;
  TDialogEXODB2 = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
    Procedure HelpFenster(DateiName,Tittel:String);
    Procedure HelpFenster2(DateiName,Tittel:String);
  end;

const
  RDialogEXODB2 : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogEXODB2)^);
    Load : @TDialogEXODB2.Load;
    Store : @TDialogEXODB2.Store);

implementation


{ TDialogEXODB2 }
constructor TDialogEXODB2.Init;

var
  R: TRect;
  Control : PView;
begin
R.Assign(0, 0, 80, 48);
inherited Init(R, 'EXO-DB2 Datenbank-Fenster');
Palette := dpBlueDialog;
Flags := Flags and not wfClose;

R.Assign(10, 9, 26, 11);
Control := New(PButton, Init(R, '~A~uswÑhlen...', cmDBStartype, bfNormal));
Insert(Control);

R.Assign(3, 2, 9, 4);
Control := New(PButton, Init(R, '˛>', cmDBBegin, bfNormal));
Insert(Control);

R.Assign(9, 2, 15, 4);
Control := New(PButton, Init(R, '<<', cmDBminus10, bfNormal));
Insert(Control);

R.Assign(15, 2, 20, 4);
Control := New(PButton, Init(R, '<', cmDBminus1, bfNormal));
Insert(Control);

R.Assign(20, 2, 25, 4);
Control := New(PButton, Init(R, '>', cmDBplus1, bfNormal));
Insert(Control);

R.Assign(25, 2, 31, 4);
Control := New(PButton, Init(R, '>>', cmDBplus10, bfNormal));
Insert(Control);

R.Assign(31, 2, 37, 4);
Control := New(PButton, Init(R, '<˛', cmDBEnd, bfNormal));
Insert(Control);

R.Assign(48, 2, 54, 3);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(38, 2, 48, 3);
  Insert(New(PLabel, Init(R, 'Gehe zu: ', Control)));

R.Assign(33, 6, 38, 8);
Control := New(PButton, Init(R, '<', cmDBStarlistBack, bfNormal));
Insert(Control);

R.Assign(38, 6, 43, 8);
Control := New(PButton, Init(R, '>', cmDBStarlistForward, bfNormal));
Insert(Control);

R.Assign(2, 12, 42, 13);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 11, 42, 12);
  Insert(New(PLabel, Init(R, 'Name des Zentralstern                   ', Control)));

R.Assign(2, 9, 10, 10);
Control := New(PColoredText, Init(R, 'Sterntyp', $1F));
Insert(Control);

R.Assign(14, 16, 26, 17);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 16, 14, 17);
  Insert(New(PLabel, Init(R, 'Spektraltyp ', Control)));

R.Assign(2, 18, 15, 19);
Control := New(PColoredText, Init(R, 'Rektaszension', $1F));
Insert(Control);

R.Assign(1, 5, 79, 6);
Control := New(PColoredText, Init(R, 'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ'+
     'ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ', $1B));
Insert(Control);

R.Assign(22, 18, 33, 19);
Control := New(PColoredText, Init(R, 'Deklination', $1F));
Insert(Control);

R.Assign(21, 21, 29, 22);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 21, 21, 22);
  Insert(New(PLabel, Init(R, 'Masse (Sun=1)      ', Control)));

R.Assign(34, 21, 39, 22);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(29, 21, 34, 22);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(21, 23, 29, 24);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 23, 21, 24);
  Insert(New(PLabel, Init(R, 'Radius (Sun=1)     ', Control)));

R.Assign(34, 23, 39, 24);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(29, 23, 34, 24);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(38, 21, 43, 23);
Control := New(PButton, Init(R, '?', cmDBStarmassNil, bfNormal));
Insert(Control);

R.Assign(38, 23, 43, 25);
Control := New(PButton, Init(R, '?', cmDBStarradiusNil, bfNormal));
Insert(Control);

R.Assign(21, 25, 29, 26);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 25, 21, 26);
  Insert(New(PLabel, Init(R, 'Leuchtkraft (Sun=1)', Control)));

R.Assign(34, 25, 39, 26);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(29, 25, 34, 26);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(38, 25, 43, 27);
Control := New(PButton, Init(R, '?', cmDBLuminosityNil, bfNormal));
Insert(Control);

R.Assign(38, 27, 43, 29);
Control := New(PButton, Init(R, '?', cmDBAgeNil, bfNormal));
Insert(Control);

R.Assign(38, 29, 43, 31);
Control := New(PButton, Init(R, '?', cmDBDistanceNil, bfNormal));
Insert(Control);

R.Assign(38, 31, 43, 33);
Control := New(PButton, Init(R, '?', cmDBMetalicityNil, bfNormal));
Insert(Control);

R.Assign(38, 33, 43, 35);
Control := New(PButton, Init(R, '?', cmDBStarRVNil, bfNormal));
Insert(Control);

R.Assign(28, 35, 37, 36);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 35, 28, 36);
  Insert(New(PLabel, Init(R, 'Scheinb. Helligkeit (mag) ', Control)));

R.Assign(38, 35, 43, 37);
Control := New(PButton, Init(R, '?', cmDBMagVisNil, bfNormal));
Insert(Control);

R.Assign(38, 37, 43, 39);
Control := New(PButton, Init(R, '?', cmDBMagAbsNil, bfNormal));
Insert(Control);

R.Assign(28, 39, 37, 40);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 39, 28, 40);
  Insert(New(PLabel, Init(R, '*Gro·e Halbachse (AE)     ', Control)));

R.Assign(38, 39, 43, 41);
Control := New(PButton, Init(R, '?', cmDBStarAxisNil, bfNormal));
Insert(Control);

R.Assign(28, 41, 37, 42);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 41, 28, 42);
  Insert(New(PLabel, Init(R, '*Num. ExzentrizitÑt       ', Control)));

R.Assign(38, 41, 43, 43);
Control := New(PButton, Init(R, '?', cmDBStarEccNil, bfNormal));
Insert(Control);

R.Assign(2, 14, 25, 15);
Control := New(PColoredText, Init(R, 'Staubscheibe vorhanden?', $1F));
Insert(Control);

R.Assign(25, 14, 41, 16);
Control := New(PButton, Init(R, 'A~u~swÑhlen...', cmDBDustdisc, bfNormal));
Insert(Control);

R.Assign(12, 43, 43, 44);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 43, 12, 44);
  Insert(New(PLabel, Init(R, 'Sternbild ', Control)));

R.Assign(10, 45, 43, 46);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 45, 10, 46);
  Insert(New(PLabel, Init(R, 'Notizen ', Control)));

R.Assign(28, 6, 33, 8);
Control := New(PButton, Init(R, '^', cmDBStarList, bfNormal));
Insert(Control);

R.Assign(43, 5, 44, 47);
Control := New(PColoredText, Init(R, '¬'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥'^M+
     '≥', $1B));
Insert(Control);

R.Assign(64, 6, 69, 8);
Control := New(PButton, Init(R, '^', cmDBPlanetList, bfNormal));
Insert(Control);

R.Assign(69, 6, 74, 8);
Control := New(PButton, Init(R, '<', cmDBPlanetlistBack, bfNormal));
Insert(Control);

R.Assign(74, 6, 79, 8);
Control := New(PButton, Init(R, '>', cmDBPlanetlistForward, bfNormal));
Insert(Control);

R.Assign(45, 10, 78, 11);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(44, 9, 78, 10);
  Insert(New(PLabel, Init(R, 'Name des Exoplaneten             ', Control)));

R.Assign(57, 12, 65, 13);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(44, 12, 57, 13);
  Insert(New(PLabel, Init(R, 'Masse       ', Control)));

R.Assign(70, 12, 74, 13);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(65, 12, 70, 13);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(74, 12, 79, 14);
Control := New(PButton, Init(R, '?', cmDBPlanetmassNil, bfNormal));
Insert(Control);

R.Assign(57, 14, 65, 15);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(44, 14, 57, 15);
  Insert(New(PLabel, Init(R, 'Radius      ', Control)));

R.Assign(70, 14, 74, 15);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(65, 14, 70, 15);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(46, 13, 57, 14);
Control := New(PColoredText, Init(R, '(Jup=1)', $1F));
Insert(Control);

R.Assign(46, 15, 57, 16);
Control := New(PColoredText, Init(R, '(Jup=1)', $1F));
Insert(Control);

R.Assign(74, 14, 79, 16);
Control := New(PButton, Init(R, '?', cmDBPlanetradiusNil, bfNormal));
Insert(Control);

R.Assign(58, 16, 66, 17);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(44, 16, 58, 17);
  Insert(New(PLabel, Init(R, 'Gr. Halbachse', Control)));

R.Assign(70, 16, 74, 17);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(65, 16, 70, 17);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(74, 16, 79, 18);
Control := New(PButton, Init(R, '?', cmDBPlanetAxisNil, bfNormal));
Insert(Control);

R.Assign(46, 17, 57, 18);
Control := New(PColoredText, Init(R, '(AE)', $1F));
Insert(Control);

R.Assign(58, 18, 65, 19);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(44, 18, 58, 19);
  Insert(New(PLabel, Init(R, 'ExzentrizitÑt', Control)));

R.Assign(70, 18, 74, 19);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(65, 18, 70, 19);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(74, 18, 79, 20);
Control := New(PButton, Init(R, '?', cmDBPlanetEccNil, bfNormal));
Insert(Control);

R.Assign(57, 20, 65, 21);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(44, 20, 57, 21);
  Insert(New(PLabel, Init(R, 'Bahnneigung ', Control)));

R.Assign(70, 20, 74, 21);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(65, 20, 70, 21);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(74, 20, 79, 22);
Control := New(PButton, Init(R, '?', cmDBInclinationNil, bfNormal));
Insert(Control);

R.Assign(46, 21, 57, 22);
Control := New(PColoredText, Init(R, '(¯)', $1F));
Insert(Control);

R.Assign(62, 22, 74, 23);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(44, 22, 62, 23);
  Insert(New(PLabel, Init(R, 'Periheldurchgang ', Control)));

R.Assign(74, 22, 79, 24);
Control := New(PButton, Init(R, '?', cmDBTPeriNil, bfNormal));
Insert(Control);

R.Assign(46, 23, 57, 24);
Control := New(PColoredText, Init(R, '(JD)', $1F));
Insert(Control);

R.Assign(57, 25, 65, 26);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(44, 24, 74, 25);
  Insert(New(PLabel, Init(R, 'LÑnge d. aufst. Knoten       ', Control)));

R.Assign(70, 25, 74, 26);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(65, 25, 70, 26);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(74, 25, 79, 27);
Control := New(PButton, Init(R, '?', cmDBOmegaNil, bfNormal));
Insert(Control);

R.Assign(46, 25, 57, 26);
Control := New(PColoredText, Init(R, '(¯)', $1F));
Insert(Control);

R.Assign(57, 27, 65, 28);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(44, 27, 57, 28);
  Insert(New(PLabel, Init(R, 'Radialgesch.', Control)));

R.Assign(70, 27, 74, 28);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(65, 27, 70, 28);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(74, 27, 79, 29);
Control := New(PButton, Init(R, '?', cmDBPlanetRVNil, bfNormal));
Insert(Control);

R.Assign(46, 28, 57, 29);
Control := New(PColoredText, Init(R, '(km/s)', $1F));
Insert(Control);

R.Assign(45, 30, 63, 31);
Control := New(PColoredText, Init(R, 'Entdeckungsmethode', $1F));
Insert(Control);

R.Assign(63, 30, 79, 32);
Control := New(PButton, Init(R, 'Au~s~wÑhlen...', cmDBPlanetDisMethod, bfNormal));
Insert(Control);

R.Assign(45, 33, 63, 34);
Control := New(PColoredText, Init(R, 'Entdeckunsgsstatus', $1F));
Insert(Control);

R.Assign(63, 33, 79, 35);
Control := New(PButton, Init(R, 'Aus~w~Ñhlen...', cmDBPlanetDisStatus, bfNormal));
Insert(Control);

R.Assign(45, 35, 61, 36);
Control := New(PColoredText, Init(R, 'Entdeckunsgdatum', $1F));
Insert(Control);

R.Assign(45, 39, 78, 40);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(44, 38, 78, 39);
  Insert(New(PLabel, Init(R, 'Entdecker                        ', Control)));

R.Assign(45, 42, 78, 43);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(44, 41, 78, 42);
  Insert(New(PLabel, Init(R, 'Notizen                          ', Control)));

R.Assign(67, 1, 78, 5);
Control := New(PButton, Init(R, 'E~x~it', cmQuit, bfNormal));
Insert(Control);

R.Assign(59, 1, 67, 3);
Control := New(PButton, Init(R, '~M~enÅ', cmMenu, bfNormal));
Insert(Control);

R.Assign(51, 36, 56, 37);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(45, 36, 51, 37);
  Insert(New(PLabel, Init(R, 'Jahr ', Control)));

R.Assign(63, 36, 68, 37);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(56, 36, 63, 37);
  Insert(New(PLabel, Init(R, 'Monat ', Control)));

R.Assign(73, 36, 78, 37);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(68, 36, 73, 37);
  Insert(New(PLabel, Init(R, 'Tag ', Control)));

R.Assign(45, 7, 64, 8);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(44, 6, 64, 7);
  Insert(New(PLabel, Init(R, 'Anzahl der Planeten', Control)));

R.Assign(2, 7, 19, 8);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 6, 19, 7);
  Insert(New(PLabel, Init(R, 'Anzahl der Sterne', Control)));

R.Assign(28, 37, 37, 38);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 37, 28, 38);
  Insert(New(PLabel, Init(R, 'Absolute Helligkeit (mag) ', Control)));

R.Assign(34, 27, 38, 28);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(29, 27, 34, 28);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(34, 29, 38, 30);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(29, 29, 34, 30);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(34, 31, 38, 32);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(29, 31, 34, 32);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(34, 33, 38, 34);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(29, 33, 34, 34);
  Insert(New(PLabel, Init(R, '+/- ', Control)));

R.Assign(21, 31, 29, 32);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(1, 31, 21, 32);
  Insert(New(PLabel, Init(R, 'MetallizitÑt       ', Control)));

R.Assign(21, 29, 29, 30);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 29, 21, 30);
  Insert(New(PLabel, Init(R, 'Entfernung (Parsec)', Control)));

R.Assign(21, 27, 29, 28);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 27, 21, 28);
  Insert(New(PLabel, Init(R, 'Alter (Gyr=1)      ', Control)));

R.Assign(21, 33, 29, 34);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(1, 33, 21, 34);
  Insert(New(PLabel, Init(R, 'Radialgesch. (km/s)', Control)));

R.Assign(5, 19, 8, 20);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(2, 19, 5, 20);
  Insert(New(PLabel, Init(R, 'h ', Control)));

R.Assign(11, 19, 14, 20);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(8, 19, 11, 20);
  Insert(New(PLabel, Init(R, 'm ', Control)));

R.Assign(17, 19, 20, 20);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(14, 19, 17, 20);
  Insert(New(PLabel, Init(R, 's ', Control)));

R.Assign(25, 19, 28, 20);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(22, 19, 25, 20);
  Insert(New(PLabel, Init(R, '¯ ', Control)));

R.Assign(31, 19, 34, 20);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(28, 19, 31, 20);
  Insert(New(PLabel, Init(R, ''' ', Control)));

R.Assign(37, 19, 40, 20);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(34, 19, 37, 20);
  Insert(New(PLabel, Init(R, '" ', Control)));

R.Assign(58, 3, 67, 5);
Control := New(PButton, Init(R, '~H~ilfe', slMiscHelp, bfNormal));
Insert(Control);

SelectNext(False);
end;

constructor TDialogEXODB2.Load(var S: TStream);
begin
inherited Load(S);
end;


Procedure TDialogEXODB2.HelpFenster(DateiName,Tittel:String);
Const BufferSize:Word=65535;
Var R:TRect;
    Fenster2:PWindow;
    Inneres:PTerminal;
    Datei,FensterText : Text;
    Zeile:String;
Begin
 R.Assign(1,1,80,49);
 Fenster2:=New(PWindow,Init(R,Tittel,wnNoNumber));
 With Fenster2^ do Begin
                    Options:=Options or ofCentered;
                    GetExtent(R);
                    R.Grow(-1,-1);
                    Inneres:=New(PTerminal,Init(
                     R,
                     StandardScrollBar(sbHorizontal + sbHandleKeyBoard),
                     StandardScrollBar(sbVertical   + sbHandleKeyBoard),
                     BufferSize));
                   Insert(Inneres);
                  End;
 {Desktop^.}Insert(Fenster2);
 Assign(Datei,DateiName);
 Reset(Datei);
 AssignDevice(FensterText,Inneres);
 Rewrite(FensterText);
 Repeat
  ReadLn(Datei,Zeile);
  WriteLn(FensterText,Zeile);
 Until EoF(Datei);
 Close;
 Close;
 Inneres^.ScrollTo(0,0);
End;

Procedure TDialogEXODB2.HelpFenster2(DateiName,Tittel:String);
Const BufferSize:Word=65535;
Var R:TRect;
    Fenster2:PWindow;
    Inneres:PTerminal;
    Datei,FensterText : Text;
    Zeile:String;
  Control : PView;
Begin
R.Assign(19, 6, 59, 25);
inherited Init(R, 'Entdeckungsmethode');

R.Assign(6, 15, 16, 17);
Control := New(PButton, Init(R, 'O~K~', cmDiscoverMethodOK, bfDefault));
Insert(Control);

R.Assign(22, 15, 33, 17);
Control := New(PButton, Init(R, '~A~bbruch', cmDiscoverMethodAbort, bfNormal));
Insert(Control);

R.Assign(3, 3, 37, 14);
Control := New(PRadioButtons, Init(R,
  NewSItem('nicht bekannt',
  NewSItem('Radialgeschwindigkeit',
  NewSItem('Transit',
  NewSItem('Astrometrie',
  NewSItem('Microlensing-Effekt',
  NewSItem('Pulsar-Timing',
  NewSItem('Transit-Timing',
  NewSItem('Staubscheiben-Assymetrie',
  NewSItem('Direkte Abbildung (infrarot)',
  NewSItem('Direkte Abbildung (optisch)',
  NewSItem('Sonstiges', Nil)))))))))))));
Insert(Control);

  R.Assign(2, 2, 37, 3);
  Insert(New(PLabel, Init(R, 'Entdeckungsmethode auswÑhlen      ', Control)));

R.Assign(18, 13, 37, 14);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

SelectNext(False);





{ R.Assign(1,1,80,49);
 Fenster2:=New(PWindow,Init(R,Tittel,wnNoNumber));
 With Fenster2^ do Begin
                    Options:=Options or ofCentered;
                    GetExtent(R);
                    R.Grow(-1,-1);
                    Inneres:=New(PTerminal,Init(
                     R,
                     StandardScrollBar(sbHorizontal + sbHandleKeyBoard),
                     StandardScrollBar(sbVertical   + sbHandleKeyBoard),
                     BufferSize));
                   Insert(Inneres);
                  End;
 Insert(Fenster2);
 Assign(Datei,DateiName);
 Reset(Datei);
 AssignDevice(FensterText,Inneres);
 Rewrite(FensterText);
 Repeat
  ReadLn(Datei,Zeile);
  WriteLn(FensterText,Zeile);
 Until EoF(Datei);
 Close;
 Close;
 Inneres^.ScrollTo(0,0);}
End;


procedure TDialogEXODB2.HandleEvent(var Event: TEvent);
begin
{if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDBPlanetDisMethod : BEGIN
      TDialogEXODB2.HelpFenster2('a','a');
    END;
    cmDBPlanetDisStatus : BEGIN
      TDialogEXODB2.ShowDiscoverStatus;
    END;
  end;}

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogEXODB2.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogEXODB2.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogEXODB2.Done;
begin
inherited Done;
end;

end.
