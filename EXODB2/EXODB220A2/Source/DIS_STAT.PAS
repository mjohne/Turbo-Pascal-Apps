unit DIS_STAT;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field20 : Word;
    Field21 : String[255];
    end;
  PDataRec = ^DataRec;

  { TDialogDiscoverStatus }

  PDialogDiscoverStatus = ^TDialogDiscoverStatus;
  TDialogDiscoverStatus = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogDiscoverStatus : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogDiscoverStatus)^);
    Load : @TDialogDiscoverStatus.Load;
    Store : @TDialogDiscoverStatus.Store);

implementation

{ TDialogDiscoverStatus }

constructor TDialogDiscoverStatus.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(19, 6, 58, 21);
inherited Init(R, 'Entdeckungsstatus');

R.Assign(7, 11, 17, 13);
Control := New(PButton, Init(R, 'O~K~', cmDiscoverStatusOK, bfDefault));
Insert(Control);

R.Assign(23, 11, 34, 13);
Control := New(PButton, Init(R, '~A~bbruch', cmDiscoverStatusAbort, bfNormal));
Insert(Control);

R.Assign(3, 3, 36, 10);
Control := New(PRadioButtons, Init(R,
  NewSItem('nicht bekannt',
  NewSItem('noch unbest„tigt',
  NewSItem('best„tigt',
  NewSItem('vermutet',
  NewSItem('zweifelhalft',
  NewSItem('widerrufen (Falscher Alarm)',
  NewSItem('sonstiges', Nil)))))))));
Insert(Control);

  R.Assign(2, 2, 36, 3);
  Insert(New(PLabel, Init(R, 'Entdeckungsstatus ausw„hlen      ', Control)));

R.Assign(18, 9, 36, 10);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

SelectNext(False);
end;

constructor TDialogDiscoverStatus.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogDiscoverStatus.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDiscoverStatusOK    : TDialog.Done;
    cmDiscoverStatusAbort : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogDiscoverStatus.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogDiscoverStatus.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogDiscoverStatus.Done;
begin
inherited Done;
end;

end.
