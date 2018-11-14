unit THANKS;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type

  { TDialogThanks }

  PDialogThanks = ^TDialogThanks;
  TDialogThanks = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogThanks : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogThanks)^);
    Load : @TDialogThanks.Load;
    Store : @TDialogThanks.Store);

implementation

{ TDialogThanks }

constructor TDialogThanks.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(13, 5, 69, 30);
inherited Init(R, 'Danksagung');

R.Assign(24, 21, 34, 23);
Control := New(PButton, Init(R, 'O~K~', cmThanks, bfDefault));
Insert(Control);

R.Assign(2, 2, 53, 8);
Control := New(PStaticText, Init(R, '  Ohne die indirekte Hilfe vieler Men'+
     'schen wÑre'^M+
     '  EXO-DB2 nicht das geworden, was es nun ist.'^M+
     ''^M+
     '  Ich danke daher allen Wissenschaftlern und As-'^M+
     '  tronomen, die sich aktiv mit der Suche nach'^M+
     '  fremden Planeten beschÑftigen.'));
Insert(Control);

R.Assign(2, 8, 53, 13);
Control := New(PStaticText, Init(R, ''^M+
     '  Weiterhin danke ich auch allen anderen Interes-'^M+
     '  sierten, die sich mit Exoplaneten beschÑftigen'^M+
     '  und Webseiten im Internet zur Informierung be-'^M+
     '  reithalten.'));
Insert(Control);

R.Assign(2, 13, 53, 19);
Control := New(PStaticText, Init(R, ''^M+
     '  Besonderen Dank gebe ich den Ascherslebener'^M+
     '  Sternfreunden fÅr die EinfÅhrung in die As-'^M+
     '  tronomie und Peter Hochbaum (alias Matrix)'^M+
     '  fÅr seine "Neugier", die meine Arbeit an EXO-DB2'^M+
     '  wieder voran getrieben hat. :-)'));
Insert(Control);

SelectNext(False);
end;

constructor TDialogThanks.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogThanks.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmThanks : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogThanks.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogThanks.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogThanks.Done;
begin
inherited Done;
end;

end.
