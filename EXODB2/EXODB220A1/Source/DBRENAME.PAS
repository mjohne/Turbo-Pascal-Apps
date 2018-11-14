unit DBRENAME;

interface

uses Democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field2 : String[10];
    end;
  PDataRec = ^DataRec;

  { TDialogDBRename }

  PDialogDBRename = ^TDialogDBRename;
  TDialogDBRename = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogDBRename : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogDBRename)^);
    Load : @TDialogDBRename.Load;
    Store : @TDialogDBRename.Store);

implementation

{ TDialogDBRename }

constructor TDialogDBRename.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(23, 13, 59, 24);
inherited Init(R, 'Datenbank umbenennen?');

R.Assign(2, 2, 35, 4);
Control := New(PStaticText, Init(R, 'Geben einen neuen Dateinamen fÅr die'+
     ' Datenbank ein:'));
Insert(Control);

R.Assign(7, 7, 17, 9);
Control := New(PButton, Init(R, '~O~K', cmDBRename, bfDefault));
Insert(Control);

R.Assign(20, 7, 30, 9);
Control := New(PButton, Init(R, '~N~ein', cmDBRenameAbort, bfNormal));
Insert(Control);

R.Assign(11, 5, 21, 6);
Control := New(PInputLine, Init(R, 10));
Insert(Control);

  R.Assign(21, 5, 26, 6);
  Insert(New(PLabel, Init(R, '.EXO', Control)));

SelectNext(False);
end;

constructor TDialogDBRename.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogDBRename.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDBRename      : TDialog.Done;
    cmDBRenameAbort : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogDBRename.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogDBRename.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogDBRename.Done;
begin
inherited Done;
end;

end.
