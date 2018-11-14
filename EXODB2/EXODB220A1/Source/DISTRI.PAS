unit DISTRI;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field1 : Word;
    Field3 : Word;
    end;
  PDataRec = ^DataRec;

  { TDialogDistribution }

  PDialogDistribution = ^TDialogDistribution;
  TDialogDistribution = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogDistribution : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogDistribution)^);
    Load : @TDialogDistribution.Load;
    Store : @TDialogDistribution.Store);

implementation

{ TDialogDistribution }

constructor TDialogDistribution.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(7, 9, 71, 25);
inherited Init(R, 'Distribution');

R.Assign(4, 4, 31, 13);
Control := New(PRadioButtons, Init(R, 
  NewSItem('Num. Exzentrizit„t',
  NewSItem('Masse des Exoplaneten',
  NewSItem('Groáe Halbachse',
  NewSItem('J„hrliche Entdeckung',
  NewSItem('Spektralklasse',
  NewSItem('Entfernung zur Sonne',
  NewSItem('Scheinbare Helligkeit',
  NewSItem('Metallizit„t',
  NewSItem('Zentralstern-Masse', Nil)))))))))));
Insert(Control);

  R.Assign(3, 2, 28, 3);
  Insert(New(PLabel, Init(R, 'Was soll gez„hlt werden:', Control)));

R.Assign(48, 10, 59, 12);
Control := New(PButton, Init(R, 'O~K~', cmDistribution, bfDefault));
Insert(Control);

R.Assign(48, 12, 59, 14);
Control := New(PButton, Init(R, '~A~bruch', cmDistributionAbort, bfNormal));
Insert(Control);

R.Assign(31, 7, 36, 8);
Control := New(PCheckboxes, Init(R, 
  NewSItem(' ', Nil)));
Insert(Control);

  R.Assign(36, 7, 59, 8);
  Insert(New(PLabel, Init(R, 'J„hrl. Zusammenfassung', Control)));

SelectNext(False);
end;

constructor TDialogDistribution.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogDistribution.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDistribution : TDialog.Done;
    cmDistributionAbort : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogDistribution.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogDistribution.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogDistribution.Done;
begin
inherited Done;
end;

end.
