unit STAR3D;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field1 : String[10];
    Field2 : String[10];
    Field3 : String[10];
    Field12 : String[10];
    Field14 : String[10];
    end;
  PDataRec = ^DataRec;

  { TDialogStar3D }

  PDialogStar3D = ^TDialogStar3D;
  TDialogStar3D = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogStar3D : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogStar3D)^);
    Load : @TDialogStar3D.Load;
    Store : @TDialogStar3D.Store);

implementation

{ TDialogStar3D }

constructor TDialogStar3D.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(10, 8, 66, 24);
inherited Init(R, 'Star3D');

R.Assign(12, 3, 24, 4);
Control := New(PInputLine, Init(R, 10));
Insert(Control);

  R.Assign(3, 3, 12, 4);
  Insert(New(PLabel, Init(R, 'Zoom ', Control)));

R.Assign(3, 6, 26, 7);
Control := New(PStaticText, Init(R, 'Mittelpunktverschiebung'));
Insert(Control);

R.Assign(12, 7, 24, 8);
Control := New(PInputLine, Init(R, 10));
Insert(Control);

  R.Assign(3, 7, 12, 8);
  Insert(New(PLabel, Init(R, 'X-Achse ', Control)));

R.Assign(12, 8, 24, 9);
Control := New(PInputLine, Init(R, 10));
Insert(Control);

  R.Assign(3, 8, 12, 9);
  Insert(New(PLabel, Init(R, 'Y-Achse ', Control)));

R.Assign(42, 8, 53, 10);
Control := New(PButton, Init(R, 'O~K~', cmStar3D, bfDefault));
Insert(Control);

R.Assign(42, 11, 53, 13);
Control := New(PButton, Init(R, '~A~bbruch', cmStar3DAbort, bfNormal));
Insert(Control);

R.Assign(29, 3, 53, 5);
Control := New(PButton, Init(R, '~W~eitere Objekte...', cmMoreObjects, bfNormal));
Insert(Control);

R.Assign(9, 4, 24, 5);
Control := New(PStaticText, Init(R, '(Standard = 50)'));
Insert(Control);

R.Assign(25, 7, 39, 8);
Control := New(PStaticText, Init(R, '(Standard = 0)'));
Insert(Control);

R.Assign(25, 8, 39, 9);
Control := New(PStaticText, Init(R, '(Standard = 0)'));
Insert(Control);

R.Assign(3, 10, 27, 11);
Control := New(PStaticText, Init(R, 'Spektraltyp-Beschr„nkung'));
Insert(Control);

R.Assign(3, 11, 9, 12);
Control := New(PStaticText, Init(R, ' Von: '));
Insert(Control);

R.Assign(3, 12, 9, 13);
Control := New(PStaticText, Init(R, ' Bis: '));
Insert(Control);

R.Assign(9, 11, 12, 12);
Control := New(PInputLine, Init(R, 10));
Insert(Control);

R.Assign(9, 12, 12, 13);
Control := New(PInputLine, Init(R, 10));
Insert(Control);

R.Assign(13, 11, 37, 12);
Control := New(PStaticText, Init(R, '(Standard = O) [OBAFGKM]'));
Insert(Control);

R.Assign(13, 12, 37, 13);
Control := New(PStaticText, Init(R, '(Standard = M) [OBAFGKM]'));
Insert(Control);

SelectNext(False);
end;

constructor TDialogStar3D.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogStar3D.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmStar3D : TDialog.Done;
    cmStar3DAbort : TDialog.Done;
    cmMoreObjects : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogStar3D.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogStar3D.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogStar3D.Done;
begin
inherited Done;
end;

end.
