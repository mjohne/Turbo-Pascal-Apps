unit DBOBJDEL;

interface

uses Democmds,Drivers, Objects, Views, Dialogs;

type

  { TDialogDBObjectErase }

  PDialogDBObjectErase = ^TDialogDBObjectErase;
  TDialogDBObjectErase = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogDBObjectErase : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogDBObjectErase)^);
    Load : @TDialogDBObjectErase.Load;
    Store : @TDialogDBObjectErase.Store);

implementation

{ TDialogDBObjectErase }

constructor TDialogDBObjectErase.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(23, 13, 59, 23);
inherited Init(R, 'Datenobjekt l”schen?');

R.Assign(4, 2, 32, 5);
Control := New(PStaticText, Init(R, 'Wollen Sie diese Datenobjekt wirklic'+
     'h l”schen?'));
Insert(Control);

R.Assign(7, 6, 17, 8);
Control := New(PButton, Init(R, '~J~a', cmDBObjectEraseYes, bfDefault));
Insert(Control);

R.Assign(20, 6, 30, 8);
Control := New(PButton, Init(R, '~N~ein', cmDBObjectEraseNo, bfNormal));
Insert(Control);

SelectNext(False);
end;

constructor TDialogDBObjectErase.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogDBObjectErase.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDBObjectEraseYes : BEGIN
      TDialog.Done;
      ClearEvent(Event);
    END;
    cmDBObjectEraseNo : BEGIN
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

procedure TDialogDBObjectErase.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogDBObjectErase.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogDBObjectErase.Done;
begin
inherited Done;
end;

end.
