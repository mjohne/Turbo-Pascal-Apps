unit METHOD;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec2 = record
    Field20 : Word;
    Field21 : String[255];
    end;
  PDataRec2 = ^DataRec2;
  { TDialogDiscoverMethod }
  PDialogDiscoverMethod = ^TDialogDiscoverMethod;
  TDialogDiscoverMethod = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogDiscoverMethod : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogDiscoverMethod)^);
    Load : @TDialogDiscoverMethod.Load;
    Store : @TDialogDiscoverMethod.Store);

implementation

{ TDialogDiscoverMethod }
constructor TDialogDiscoverMethod.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(19, 6, 59, 25);
inherited Init(R, 'Entdeckungsmethode');

R.Assign(6, 15, 16, 17);
Control := New(PButton, Init(R, 'O~K~', cmDiscoverMethodOK, bfDefault));
Insert(Control);

R.Assign(22, 15, 33, 17);
Control := New(PButton, Init(R, '~A~bbruch', cmDiscoverMethodAbort, bfNormal));
Insert(Control);

R.Assign(3, 3, 37, 14);
Control := New(PRadioButtons, Init(R,
  NewSItem('nicht bekannt',
  NewSItem('Radialgeschwindigkeit',
  NewSItem('Transit',
  NewSItem('Astrometrie',
  NewSItem('Microlensing-Effekt',
  NewSItem('Pulsar-Timing',
  NewSItem('Transit-Timing',
  NewSItem('Staubscheiben-Assymetrie',
  NewSItem('Direkte Abbildung (infrarot)',
  NewSItem('Direkte Abbildung (optisch)',
  NewSItem('Sonstiges', Nil)))))))))))));
Insert(Control);

  R.Assign(2, 2, 37, 3);
  Insert(New(PLabel, Init(R, 'Entdeckungsmethode ausw„hlen      ', Control)));

R.Assign(18, 13, 37, 14);
Control := New(PInputLine, Init(R, 255));
Insert(Control);

SelectNext(False);
end;

{FUNCTION TDialogDiscoverMethod.GetPalette;
CONST P : STRING[Length(CGrayDialog)] = CCyanDialog;
Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+
  Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+
  Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00)+Chr(00);
BEGIN
  GetPalette := @P;
END;}

constructor TDialogDiscoverMethod.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogDiscoverMethod.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDiscoverMethodOK : BEGIN
      TDialog.Done;
      ClearEvent(Event);
    END;
    cmDiscoverMethodAbort : BEGIN
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

procedure TDialogDiscoverMethod.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogDiscoverMethod.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogDiscoverMethod.Done;
begin
inherited Done;
end;

end.
