unit OBJLIST;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type
  TListBoxRec = record    {<-- omit if TListBoxRec is defined elsewhere}
    List: PCollection;
    Selection: Word;
  end;

  DataRec = record
    Field1 : TListBoxRec;
    end;
  PDataRec = ^DataRec;

  { TDialogObjectList }

  PDialogObjectList = ^TDialogObjectList;
  TDialogObjectList = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogObjectList : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogObjectList)^);
    Load : @TDialogObjectList.Load;
    Store : @TDialogObjectList.Store);

implementation

{ TDialogObjectList }

constructor TDialogObjectList.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(18, 10, 68, 26);
inherited Init(R, 'Objekt-Liste');

R.Assign(45, 3, 46, 11);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(4, 3, 45, 11);
Control := New(PListBox, Init(R, 1, PScrollbar(Control)));
Insert(Control);

  R.Assign(3, 2, 17, 3);
  Insert(New(PLabel, Init(R, 'Objekt w„hlen', Control)));

R.Assign(14, 12, 25, 14);
Control := New(PButton, Init(R, 'O~K~', cmObjectListOK, bfDefault));
Insert(Control);

R.Assign(28, 12, 39, 14);
Control := New(PButton, Init(R, '~A~bbruch', cmObjectListAbort, bfNormal));
Insert(Control);

SelectNext(False);
end;

constructor TDialogObjectList.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogObjectList.HandleEvent(var Event: TEvent);
begin

if Event.What and evMessage <> 0 then
  case Event.Command of
    cmObjectListOK    : TDialog.Done;
    cmObjectListAbort : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogObjectList.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogObjectList.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogObjectList.Done;
begin
inherited Done;
end;

end.
