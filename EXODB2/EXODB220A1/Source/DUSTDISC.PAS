unit DUSTDISC;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field2 : String[255];
    Field7 : Word;
    Field9 : String[255];
    Field10 : String[255];
    Field11 : Word;
    Field12 : String[255];
    Field13 : String[255];
    Field14 : String[255];
    Field15 : String[255];
    Field16 : String[255];
    Field17 : String[255];
    Field18 : String[11];
    end;
  PDataRec = ^DataRec;

  { TDialogDustDisc }

  PDialogDustDisc = ^TDialogDustDisc;
  TDialogDustDisc = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogDustDisc : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogDustDisc)^);
    Load : @TDialogDustDisc.Load;
    Store : @TDialogDustDisc.Store);

implementation

{ TDialogDustDisc }

constructor TDialogDustDisc.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(6, 5, 73, 35);
inherited Init(R, 'Staubscheibe ausw„hlen');

R.Assign(5, 24, 62, 25);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(4, 23, 62, 24);
  Insert(New(PLabel, Init(R, 'Besonderheiten in der Staubscheibe (Notiz):              ', Control)));

R.Assign(21, 26, 31, 28);
Control := New(PButton, Init(R, 'O~K~', cmDustDiscOK, bfDefault));
Insert(Control);

R.Assign(37, 26, 48, 28);
Control := New(PButton, Init(R, '~A~bbruch', cmDustDiscAbort, bfNormal));
Insert(Control);

R.Assign(3, 3, 15, 5);
Control := New(PRadioButtons, Init(R, 
  NewSItem('Nein',
  NewSItem('Ja', Nil))));
Insert(Control);

  R.Assign(2, 2, 26, 3);
  Insert(New(PLabel, Init(R, 'Staubscheibe vorhanden?', Control)));

R.Assign(52, 3, 65, 4);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(27, 3, 52, 4);
  Insert(New(PLabel, Init(R, 'Minimaler Abstand (AE): ', Control)));

R.Assign(52, 4, 65, 5);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(27, 4, 52, 5);
  Insert(New(PLabel, Init(R, 'Maximaler Abstand (AE): ', Control)));

R.Assign(27, 2, 44, 3);
Control := New(PStaticText, Init(R, 'Gr”áe der Scheibe'));
Insert(Control);

R.Assign(3, 7, 14, 9);
Control := New(PRadioButtons, Init(R, 
  NewSItem('Nein',
  NewSItem('Ja', Nil))));
Insert(Control);

  R.Assign(2, 6, 36, 7);
  Insert(New(PLabel, Init(R, 'M”gliche "L”cher" in der Scheibe?', Control)));

R.Assign(23, 8, 28, 9);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(14, 8, 23, 9);
  Insert(New(PLabel, Init(R, 'Anzahl: ', Control)));

R.Assign(6, 10, 45, 11);
Control := New(PStaticText, Init(R, '1. "Loch" der Scheibe (falls vorhande'+
     'n)'));
Insert(Control);

R.Assign(31, 11, 44, 12);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(6, 11, 31, 12);
  Insert(New(PLabel, Init(R, 'Minimaler Abstand (AE): ', Control)));

R.Assign(31, 12, 44, 13);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(6, 12, 31, 13);
  Insert(New(PLabel, Init(R, 'Maximaler Abstand (AE): ', Control)));

R.Assign(6, 14, 45, 15);
Control := New(PStaticText, Init(R, '2. "Loch" der Scheibe (falls vorhande'+
     'n)'));
Insert(Control);

R.Assign(31, 15, 44, 16);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(6, 15, 31, 16);
  Insert(New(PLabel, Init(R, 'Minimaler Abstand (AE): ', Control)));

R.Assign(31, 16, 44, 17);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(6, 16, 31, 17);
  Insert(New(PLabel, Init(R, 'Maximaler Abstand (AE): ', Control)));

R.Assign(6, 18, 45, 19);
Control := New(PStaticText, Init(R, '3. "Loch" der Scheibe (falls vorhande'+
     'n)'));
Insert(Control);

R.Assign(31, 19, 44, 20);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

  R.Assign(6, 19, 31, 20);
  Insert(New(PLabel, Init(R, 'Minimaler Abstand (AE): ', Control)));

R.Assign(31, 20, 44, 21);
Control := New(PInputLine, Init(R, 11));
Insert(Control);

  R.Assign(6, 20, 31, 21);
  Insert(New(PLabel, Init(R, 'Maximaler Abstand (AE): ', Control)));

SelectNext(False);
end;

constructor TDialogDustDisc.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogDustDisc.HandleEvent(var Event: TEvent);
begin

if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDustDiscOK    : TDialog.Done;
    cmDustDiscAbort : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogDustDisc.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogDustDisc.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogDustDisc.Done;
begin
inherited Done;
end;

end.
