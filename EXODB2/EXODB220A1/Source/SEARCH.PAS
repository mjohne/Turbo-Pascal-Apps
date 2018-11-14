unit SEARCH;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field1 : String[2];
    end;
  PDataRec = ^DataRec;

  { TDialogSearch }

  PDialogSearch = ^TDialogSearch;
  TDialogSearch = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogSearch : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogSearch)^);
    Load : @TDialogSearch.Load;
    Store : @TDialogSearch.Store);

implementation

{ TDialogSearch }

constructor TDialogSearch.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(10, 7, 70, 17);
inherited Init(R, 'Suchen');

R.Assign(10, 4, 49, 5);
Control := New(PInputLine, Init(R, 2));
Insert(Control);

R.Assign(10, 2, 49, 3);
Control := New(PStaticText, Init(R, 'Eingabe der gesuchten Zahl bzw. Worte'+
     's:'));
Insert(Control);

R.Assign(19, 6, 30, 8);
Control := New(PButton, Init(R, 'O~K~', cmSearch, bfDefault));
Insert(Control);

R.Assign(31, 6, 42, 8);
Control := New(PButton, Init(R, '~A~bbruch', cmSearchAbort, bfNormal));
Insert(Control);

SelectNext(False);
end;

constructor TDialogSearch.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogSearch.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmSearch : TDialog.Done;
    cmSearchAbort : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogSearch.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogSearch.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogSearch.Done;
begin
inherited Done;
end;

end.
