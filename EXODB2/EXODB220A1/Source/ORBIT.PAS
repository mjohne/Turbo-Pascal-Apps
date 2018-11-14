unit ORBIT;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field1 : String[10];
    Field2 : String[10];
    Field3 : String[10];
    Field7 : Word;
    Field8 : Word;
    Field9 : Word;
    end;
  PDataRec = ^DataRec;

  { TDialogOrbit }

  PDialogOrbit = ^TDialogOrbit;
  TDialogOrbit = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogOrbit : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogOrbit)^);
    Load : @TDialogOrbit.Load;
    Store : @TDialogOrbit.Store);

implementation

{ TDialogOrbit }

constructor TDialogOrbit.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(13, 9, 69, 25);
inherited Init(R, 'Orbit');

R.Assign(12, 3, 24, 4);
Control := New(PInputLine, Init(R, 10));
Insert(Control);

  R.Assign(3, 3, 12, 4);
  Insert(New(PLabel, Init(R, 'Zoom ', Control)));

R.Assign(3, 5, 26, 6);
Control := New(PStaticText, Init(R, 'Mittelpunktverschiebung'));
Insert(Control);

R.Assign(12, 6, 24, 7);
Control := New(PInputLine, Init(R, 10));
Insert(Control);

  R.Assign(3, 6, 12, 7);
  Insert(New(PLabel, Init(R, 'X-Achse ', Control)));

R.Assign(12, 7, 24, 8);
Control := New(PInputLine, Init(R, 10));
Insert(Control);

  R.Assign(3, 7, 12, 8);
  Insert(New(PLabel, Init(R, 'Y-Achse ', Control)));

R.Assign(42, 8, 53, 10);
Control := New(PButton, Init(R, 'O~K~', cmOrbit, bfDefault));
Insert(Control);

R.Assign(42, 11, 53, 13);
Control := New(PButton, Init(R, '~A~bbruch', cmOrbitAbort, bfNormal));
Insert(Control);

R.Assign(3, 9, 39, 10);
Control := New(PCheckboxes, Init(R, 
  NewSItem('Vergleich mit Sonnensystem', Nil)));
Insert(Control);

R.Assign(3, 10, 39, 11);
Control := New(PCheckboxes, Init(R, 
  NewSItem('Bewohnbare Zone (HZ) anzeigen', Nil)));
Insert(Control);

R.Assign(3, 11, 39, 12);
Control := New(PCheckboxes, Init(R,
  NewSItem('L„nge d. aufst. Knoten anzeigen', Nil)));
Insert(Control);

R.Assign(29, 3, 53, 5);
Control := New(PButton, Init(R, '~W~eitere Objekte...', cmMoreObjects, bfNormal));
Insert(Control);

SelectNext(False);
end;

constructor TDialogOrbit.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogOrbit.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
  cmOrbit : TDialog.Done;
  cmOrbitAbort : TDialog.Done;
  cmMoreObjects : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogOrbit.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogOrbit.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogOrbit.Done;
begin
inherited Done;
end;

end.
