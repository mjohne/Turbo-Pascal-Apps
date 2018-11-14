unit DBERASE;

interface

uses Democmds,Drivers, Objects, Views, Dialogs;

type

  { TDialogDBErase }

  PDialogDBErase = ^TDialogDBErase;
  TDialogDBErase = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogDBErase : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogDBErase)^);
    Load : @TDialogDBErase.Load;
    Store : @TDialogDBErase.Store);

implementation

{ TDialogDBErase }

constructor TDialogDBErase.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(23, 13, 59, 23);
inherited Init(R, 'Datenbank l”schen?');

R.Assign(4, 2, 32, 5);
Control := New(PStaticText, Init(R, 'Wollen Sie diese Datenbank wirklich '+
     'l”schen?'));
Insert(Control);

R.Assign(7, 6, 17, 8);
Control := New(PButton, Init(R, '~J~a', cmDBEraseYes, bfDefault));
Insert(Control);

R.Assign(20, 6, 30, 8);
Control := New(PButton, Init(R, '~N~ein', cmDBEraseNo, bfNormal));
Insert(Control);

SelectNext(False);
end;

constructor TDialogDBErase.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogDBErase.HandleEvent(var Event: TEvent);
begin

if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDBEraseYes : BEGIN
      TDialog.Done;
      ClearEvent(Event);
    END;
    cmDBEraseNo : BEGIN
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

procedure TDialogDBErase.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogDBErase.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogDBErase.Done;
begin
inherited Done;
end;

end.
