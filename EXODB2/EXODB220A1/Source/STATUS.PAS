unit STATUS;

interface

uses democmds,Drivers, Objects, Views, Dialogs, ColorTxt;

type

  { TDialogPlanetStatus }

  PDialogPlanetStatus = ^TDialogPlanetStatus;
  TDialogPlanetStatus = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogPlanetStatus : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogPlanetStatus)^);
    Load : @TDialogPlanetStatus.Load;
    Store : @TDialogPlanetStatus.Store);

implementation

{ TDialogPlanetStatus }

constructor TDialogPlanetStatus.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(6, 7, 74, 30);
inherited Init(R, 'Planetenstatus');

R.Assign(28, 19, 39, 21);
Control := New(PButton, Init(R, 'O~K~', cmPlanetStatus, bfDefault));
Insert(Control);

R.Assign(2, 3, 29, 4);
Control := New(PColoredText, Init(R, 'Sortiert nach Planetenmasse', $71));
Insert(Control);

R.Assign(34, 3, 58, 4);
Control := New(PColoredText, Init(R, 'Sortiert nach Bahn-Orbit', $71));
Insert(Control);

R.Assign(3, 6, 25, 8);
Control := New(PStaticText, Init(R, 'Uranus/Neptun-„hnlich:'^M+
     ' (Masse < 0.2 MJup)'));
Insert(Control);

R.Assign(3, 8, 25, 10);
Control := New(PStaticText, Init(R, 'Saturn-„hnlich:'^M+
     ' (Masse 0.2..0.5 MJup)'));
Insert(Control);

R.Assign(3, 10, 25, 12);
Control := New(PStaticText, Init(R, 'Jupiter-„hnlich:'^M+
     ' (Masse 0.5..5.0 MJup)'));
Insert(Control);

R.Assign(3, 12, 26, 15);
Control := New(PStaticText, Init(R, 'Superjupiter-„hnlich:'^M+
     ' (Masse 5.0..10.0 MJup)'));
Insert(Control);

R.Assign(3, 14, 26, 16);
Control := New(PStaticText, Init(R, 'Brauner Zwerg-„hnlich:'^M+
     ' (Masse > 10.0 MJup)'));
Insert(Control);

R.Assign(35, 6, 63, 8);
Control := New(PStaticText, Init(R, 'kreisf”rmig, kurzperiodisch:'^M+
     ' (e < 0.25; T < 88 d)'));
Insert(Control);

R.Assign(35, 8, 63, 10);
Control := New(PStaticText, Init(R, 'exzentrisch, kurzperiodisch:'^M+
     ' (e > 0.25; T < 88 d)'));
Insert(Control);

R.Assign(35, 10, 63, 12);
Control := New(PStaticText, Init(R, 'kreisf”rmig, langperiodisch:'^M+
     ' (e < 0.25; T > 88 d)'));
Insert(Control);

R.Assign(35, 12, 63, 14);
Control := New(PStaticText, Init(R, 'exzentrisch, langperiodisch:'^M+
     ' (e > 0.25; T > 88 d)'));
Insert(Control);

SelectNext(False);
end;

constructor TDialogPlanetStatus.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogPlanetStatus.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmPlanetStatus : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogPlanetStatus.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogPlanetStatus.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogPlanetStatus.Done;
begin
inherited Done;
end;

end.
