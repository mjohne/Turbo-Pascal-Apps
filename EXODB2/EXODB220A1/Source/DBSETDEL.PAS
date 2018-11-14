unit DBSETDEL;

interface

uses Democmds,Drivers, Objects, Views, Dialogs;

type

  { TDialogDBSetErase }

  PDialogDBSetErase = ^TDialogDBSetErase;
  TDialogDBSetErase = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogDBSetErase : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogDBSetErase)^);
    Load : @TDialogDBSetErase.Load;
    Store : @TDialogDBSetErase.Store);

implementation

{ TDialogDBSetErase }

constructor TDialogDBSetErase.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(23, 13, 59, 23);
inherited Init(R, 'Datensatz l”schen?');

R.Assign(4, 2, 32, 5);
Control := New(PStaticText, Init(R, 'Wollen Sie diese Datensatz wirklich '+
     'l”schen?'));
Insert(Control);

R.Assign(7, 6, 17, 8);
Control := New(PButton, Init(R, '~J~a', cmDBSetEraseYes, bfDefault));
Insert(Control);

R.Assign(20, 6, 30, 8);
Control := New(PButton, Init(R, '~N~ein', cmDBSetEraseNo, bfNormal));
Insert(Control);

SelectNext(False);
end;

constructor TDialogDBSetErase.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogDBSetErase.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDBSetEraseYes : BEGIN
      TDialog.Done;
      ClearEvent(Event);
    END;
    cmDBSetEraseNo : BEGIN
      TDialog.Done;
      ClearEvent(Event);
    END;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogDBSetErase.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogDBSetErase.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogDBSetErase.Done;
begin
inherited Done;
end;

end.
