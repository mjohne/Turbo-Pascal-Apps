unit DIAGRAM;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field1 : Word;
    end;
  PDataRec = ^DataRec;

  { TDialogDiagram }

  PDialogDiagram = ^TDialogDiagram;
  TDialogDiagram = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogDiagram : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogDiagram)^);
    Load : @TDialogDiagram.Load;
    Store : @TDialogDiagram.Store);

implementation

{ TDialogDiagram }

constructor TDialogDiagram.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(10, 7, 70, 23);
inherited Init(R, 'Diagramme');

R.Assign(4, 4, 46, 14);
Control := New(PRadioButtons, Init(R, 
  NewSItem('Groáe Halbachse / Num. Exzentrizit„t',
  NewSItem('Groáe Halbachse / Planetenmasse',
  NewSItem('Num. Exzentrizit„t / Planetenmasse',
  NewSItem('Groáe Halbachse / Periode',
  NewSItem('Entdeckungsjahr / Groáe Halbachse',
  NewSItem('Entdeckungsjahr / Planetenmasse',
  NewSItem('Sternmasse / Metallizit„t',
  NewSItem('Spektraltyp / Metallizit„t',
  NewSItem('Sternmasse / Absolute Helligkeit',
  NewSItem('Sternmasse / Planetenmasse', Nil))))))))))));
Insert(Control);

  R.Assign(3, 2, 36, 3);
  Insert(New(PLabel, Init(R, 'Folgende Diagramme sind w„hlbar:', Control)));

R.Assign(47, 4, 58, 6);
Control := New(PButton, Init(R, 'O~K~', cmDiagram, bfDefault));
Insert(Control);

R.Assign(47, 6, 58, 8);
Control := New(PButton, Init(R, '~A~bruch', cmDiagramAbort, bfNormal));
Insert(Control);

SelectNext(False);
end;

constructor TDialogDiagram.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogDiagram.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDiagram : TDialog.Done;
    cmDiagramAbort : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogDiagram.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogDiagram.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogDiagram.Done;
begin
inherited Done;
end;

end.
