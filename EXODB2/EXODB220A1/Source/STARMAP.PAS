unit STARMAP;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field1 : Word;
    Field2 : Word;
    Field3 : Word;
    Field6 : Word;
    Field7 : Word;
    Field8 : Word;
    Field11 : Word;
    end;
  PDataRec = ^DataRec;

  { TDialogStarmap }

  PDialogStarmap = ^TDialogStarmap;
  TDialogStarmap = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogStarmap : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogStarmap)^);
    Load : @TDialogStarmap.Load;
    Store : @TDialogStarmap.Store);

implementation

{ TDialogStarmap }

constructor TDialogStarmap.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(10, 11, 70, 23);
inherited Init(R, 'Sternkarte');

R.Assign(36, 2, 58, 4);
Control := New(PButton, Init(R, 'Weitere Objekte...', cmMoreObjects, bfNormal));
Insert(Control);

R.Assign(47, 5, 58, 7);
Control := New(PButton, Init(R, 'O~K~', cmStarmap, bfDefault+bfGrabFocus));
Insert(Control);

R.Assign(47, 8, 58, 10);
Control := New(PButton, Init(R, '~A~bbruch', cmStarmapAbort, bfNormal));
Insert(Control);

R.Assign(2, 2, 36, 3);
Control := New(PCheckboxes, Init(R, 
  NewSItem('Vergrî·erung?', Nil)));
Insert(Control);

R.Assign(2, 3, 36, 4);
Control := New(PCheckboxes, Init(R, 
  NewSItem('Gradnetz?', Nil)));
Insert(Control);

R.Assign(2, 4, 36, 5);
Control := New(PCheckboxes, Init(R, 
  NewSItem('Ekliptik u. HimmelsÑquator?', Nil)));
Insert(Control);

R.Assign(2, 5, 36, 6);
Control := New(PCheckboxes, Init(R, 
  NewSItem('Sternbilder-Konstellationen?', Nil)));
Insert(Control);

R.Assign(2, 6, 36, 7);
Control := New(PCheckboxes, Init(R, 
  NewSItem('Begrenzung fÅr Sternbilder?', Nil)));
Insert(Control);

R.Assign(2, 7, 36, 8);
Control := New(PCheckboxes, Init(R, 
  NewSItem('Bezeichnung fÅr Sternbilder?', Nil)));
Insert(Control);

R.Assign(2, 8, 36, 9);
Control := New(PCheckboxes, Init(R,
  NewSItem('Bezeichung fÅr Sterne?', Nil)));
Insert(Control);

SelectNext(False);
end;

constructor TDialogStarmap.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogStarmap.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmStarmap : TDialog.Done;
    cmStarmapAbort : TDialog.Done;
    cmMoreObjects : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogStarmap.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogStarmap.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogStarmap.Done;
begin
inherited Done;
end;

end.
