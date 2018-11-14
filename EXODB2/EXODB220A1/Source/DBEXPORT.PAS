unit DBEXPORT;

interface

uses Democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field1 : Word;
    Field2 : Word;
    Field3 : Word;
    Field4 : Word;
    end;
  PDataRec = ^DataRec;

  { TDialogDBExport }

  PDialogDBExport = ^TDialogDBExport;
  TDialogDBExport = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogDBExport : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogDBExport)^);
    Load : @TDialogDBExport.Load;
    Store : @TDialogDBExport.Store);

implementation

{ TDialogDBExport }

constructor TDialogDBExport.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(2, 2, 77, 29);
inherited Init(R, 'Datenbank exportieren');

R.Assign(2, 4, 34, 9);
Control := New(PRadioButtons, Init(R, 
  NewSItem('Textdatei (TXT)',
  NewSItem('Comma-Seperated Value (CSV)',
  NewSItem('Hypertext-Dokument (HTM)',
  NewSItem('Sylk (SLK)',
  NewSItem('Rich Text Format (RTF)', Nil)))))));
Insert(Control);

  R.Assign(2, 2, 25, 3);
  Insert(New(PLabel, Init(R, 'W„hlen Sie ein Format:', Control)));

R.Assign(11, 36, 21, 38);
Control := New(PButton, Init(R, 'O~K~', cmOK, bfDefault));
Insert(Control);

R.Assign(24, 37, 34, 39);
Control := New(PButton, Init(R, 'O~K~', cmOK, bfDefault));
Insert(Control);

R.Assign(2, 13, 30, 25);
Control := New(PRadioButtons, Init(R, 
  NewSItem('Name des Zentralstern',
  NewSItem('Rektaszension',
  NewSItem('Deklination',
  NewSItem('Masse des Zentralstern',
  NewSItem('Radius des Zentralstern',
  NewSItem('Leuchtkraft',
  NewSItem('Alter',
  NewSItem('Entfernung zur Sonne',
  NewSItem('Metallizit„t',
  NewSItem('Radialgeschwindigkeit',
  NewSItem('Scheinbare Helligkeit',
  NewSItem('Absolute Helligkeit', Nil))))))))))))));
Insert(Control);

  R.Assign(1, 11, 34, 12);
  Insert(New(PLabel, Init(R, 'Sortiert nach Sterneigenschaften', Control)));

R.Assign(37, 13, 70, 23);
Control := New(PRadioButtons, Init(R, 
  NewSItem('Name des Exoplaneten',
  NewSItem('Masse des Exoplaneten',
  NewSItem('Radius des Exoplaneten',
  NewSItem('Groáe Halbachse',
  NewSItem('Exzentrizit„t',
  NewSItem('Bahnneigung',
  NewSItem('Periheldurchgang',
  NewSItem('L„nge d. aufst. Knoten',
  NewSItem('Radialgesch. d. Exoplaneten',
  NewSItem('Entdeckungsdatum', Nil))))))))))));
Insert(Control);

  R.Assign(36, 11, 73, 12);
  Insert(New(PLabel, Init(R, 'Sortiert nach Exoplaneteigenschaften', Control)));

R.Assign(37, 4, 54, 7);
Control := New(PRadioButtons, Init(R, 
  NewSItem('unsortiert',
  NewSItem('aufsteigend',
  NewSItem('absteigend', Nil)))));
Insert(Control);

  R.Assign(36, 2, 53, 3);
  Insert(New(PLabel, Init(R, 'Sortier-Richtung', Control)));

R.Assign(59, 4, 70, 6);
Control := New(PButton, Init(R, 'O~K~', cmDBExport, bfDefault));
Insert(Control);

R.Assign(59, 7, 70, 9);
Control := New(PButton, Init(R, '~A~bbruch', cmDBExportAbort, bfNormal));
Insert(Control);

SelectNext(False);
end;

constructor TDialogDBExport.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogDBExport.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDBExport : BEGIN
      TDialog.Done;
      ClearEvent(Event);
    END;
    cmDBExportAbort : BEGIN
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

procedure TDialogDBExport.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogDBExport.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogDBExport.Done;
begin
inherited Done;
end;

end.
