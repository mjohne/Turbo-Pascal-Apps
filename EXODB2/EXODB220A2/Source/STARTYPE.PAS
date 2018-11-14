unit STARTYPE;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field1 : Word;
    Field2 : String[255];
    Field4 : String[55];
    Field5 : Word;
    end;
  PDataRec = ^DataRec;

  { TDialogStarType }

  PDialogStarType = ^TDialogStarType;
  TDialogStarType = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogStarType : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogStarType)^);
    Load : @TDialogStarType.Load;
    Store : @TDialogStarType.Store);

implementation

{ TDialogStarType }

constructor TDialogStarType.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(9, 9, 71, 31);
inherited Init(R, 'Sterntyp auswÑhlen');

R.Assign(5, 4, 27, 12);
Control := New(PRadioButtons, Init(R, 
  NewSItem('Hauptreihen-Stern',
  NewSItem('Brauner Zwerg',
  NewSItem('Roter Zwerg',
  NewSItem('Wei·er Zwerg',
  NewSItem('Unterriese',
  NewSItem('Riese',
  NewSItem('öberriese',
  NewSItem('Pulsar', Nil))))))))));
Insert(Control);

  R.Assign(4, 3, 27, 4);
  Insert(New(PLabel, Init(R, 'VerfÅgbare Sterntypen:', Control)));

R.Assign(3, 14, 60, 15);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(2, 13, 60, 14);
  Insert(New(PLabel, Init(R, 'Besonderheit am Sterntyp (Notiz):                        ', Control)));

R.Assign(55, 7, 59, 8);
Control := New(PInputLine, Init(R, 55));
Insert(Control);

  R.Assign(35, 7, 55, 8);
  Insert(New(PLabel, Init(R, 'Anzahl der Sterne: ', Control)));

R.Assign(31, 4, 59, 7);
Control := New(PRadioButtons, Init(R,
  NewSItem('Einzelstern-System',
  NewSItem('Doppelstern-System',
  NewSItem('Mehrfachstern-System', Nil)))));
Insert(Control);

  R.Assign(30, 3, 60, 4);
  Insert(New(PLabel, Init(R, 'Doppel-/Mehrfachstern-System?', Control)));

R.Assign(18, 17, 28, 19);
Control := New(PButton, Init(R, 'O~K~', cmStarTypeOK, bfDefault));
Insert(Control);

R.Assign(34, 17, 45, 19);
Control := New(PButton, Init(R, '~A~bbruch', cmStarTypeAbort, bfNormal));
Insert(Control);

SelectNext(False);
end;

constructor TDialogStarType.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogStarType.HandleEvent(var Event: TEvent);
begin

if Event.What and evMessage <> 0 then
  case Event.Command of
    cmStarTypeOK    : TDialog.Done;
    cmStarTypeAbort : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogStarType.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogStarType.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogStarType.Done;
begin
inherited Done;
end;

end.
