unit RECORDS;

interface

uses democmds,Drivers, Objects, Views, Dialogs, ColorTxt;

type

  { TDialogRecords }

  PDialogRecords = ^TDialogRecords;
  TDialogRecords = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogRecords : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogRecords)^);
    Load : @TDialogRecords.Load;
    Store : @TDialogRecords.Store);

implementation

{ TDialogRecords }

constructor TDialogRecords.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(1, 2, 78, 30);
inherited Init(R, 'Rekorde');

R.Assign(34, 24, 45, 26);
Control := New(PButton, Init(R, 'O~K~', cmRecords, bfDefault));
Insert(Control);

R.Assign(2, 3, 13, 4);
Control := New(PColoredText, Init(R, 'Exoplaneten', $71));
Insert(Control);

R.Assign(43, 3, 57, 4);
Control := New(PColoredText, Init(R, 'Zentralgestirn', $71));
Insert(Control);

R.Assign(3, 6, 26, 7);
Control := New(PStaticText, Init(R, 'Kleinste Planetenmasse:'));
Insert(Control);

R.Assign(3, 8, 24, 9);
Control := New(PStaticText, Init(R, 'Grî·te Planetenmasse:'));
Insert(Control);

R.Assign(3, 10, 26, 11);
Control := New(PStaticText, Init(R, 'Kleinste Halbachse (a):'));
Insert(Control);

R.Assign(3, 12, 24, 13);
Control := New(PStaticText, Init(R, 'Grî·te Halbachse (a):'));
Insert(Control);

R.Assign(3, 14, 30, 15);
Control := New(PStaticText, Init(R, 'Kleinste BahnexzentrizitÑt:'));
Insert(Control);

R.Assign(3, 16, 28, 17);
Control := New(PStaticText, Init(R, 'Grî·te BahnexzentrizitÑt:'));
Insert(Control);

R.Assign(3, 18, 31, 19);
Control := New(PStaticText, Init(R, 'Zuerst entdeckter Exoplanet:'));
Insert(Control);

R.Assign(3, 20, 32, 21);
Control := New(PStaticText, Init(R, 'Neuester entdeckte Exoplanet:'));
Insert(Control);

R.Assign(44, 6, 68, 7);
Control := New(PStaticText, Init(R, 'FrÅheste Spektralklasse:'));
Insert(Control);

R.Assign(44, 8, 68, 9);
Control := New(PStaticText, Init(R, 'SpÑteste Spektralklasse:'));
Insert(Control);

R.Assign(44, 10, 64, 11);
Control := New(PStaticText, Init(R, 'Kleinste Sternmasse:'));
Insert(Control);

R.Assign(44, 12, 62, 13);
Control := New(PStaticText, Init(R, 'Grî·te Sternmasse:'));
Insert(Control);

R.Assign(44, 14, 63, 15);
Control := New(PStaticText, Init(R, 'NÑheste Entfernung:'));
Insert(Control);

R.Assign(44, 16, 64, 17);
Control := New(PStaticText, Init(R, 'Weiteste Entfernung:'));
Insert(Control);

R.Assign(44, 18, 62, 19);
Control := New(PStaticText, Init(R, 'Grî·te Helligkeit:'));
Insert(Control);

R.Assign(44, 20, 64, 21);
Control := New(PStaticText, Init(R, 'Kleinste Helligkeit:'));
Insert(Control);

SelectNext(False);
end;

constructor TDialogRecords.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogRecords.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmrecords : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogRecords.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogRecords.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogRecords.Done;
begin
inherited Done;
end;

end.
