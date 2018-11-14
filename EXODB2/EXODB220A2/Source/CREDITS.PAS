unit CREDITS;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type

  { TDialogCredits }

  PDialogCredits = ^TDialogCredits;
  TDialogCredits = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogCredits : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogCredits)^);
    Load : @TDialogCredits.Load;
    Store : @TDialogCredits.Store);

implementation

{ TDialogCredits }

constructor TDialogCredits.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(14, 12, 69, 30);
inherited Init(R, 'Credits');

R.Assign(24, 14, 34, 16);
Control := New(PButton, Init(R, 'O~K~', cmCredits, bfDefault));
Insert(Control);

R.Assign(2, 2, 53, 8);
Control := New(PStaticText, Init(R, '  Dieses Programm ist Freeware und ka'+
     'nn frei un-'^M+
     '  eingeschrÑnkt genutzt werden.'^M+
     ''^M+
     '  Die mit EXO-DB2 erstellten Grafiken kînnen ver-'^M+
     '  îffentlicht werden, sofern angegeben wird, dass'^M+
     '  sie mit EXO-DB2 erstellt worden sind.'));
Insert(Control);

R.Assign(2, 8, 53, 13);
Control := New(PStaticText, Init(R, ''^M+
     '  Die Informationen der DatensÑtze sind ebenfalls'^M+
     '  frei verwendar. Sie stammen ursprÅnglich von den'^M+
     '  Preprints der "PlanetenjÑger".'));
Insert(Control);

SelectNext(False);
end;

constructor TDialogCredits.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogCredits.HandleEvent(var Event: TEvent);
begin

if Event.What and evMessage <> 0 then
  case Event.Command of
    cmCredits : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogCredits.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogCredits.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogCredits.Done;
begin
inherited Done;
end;

end.
