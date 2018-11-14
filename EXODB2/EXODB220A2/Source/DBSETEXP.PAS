unit DBSETEXP;

interface

uses Democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field1 : Word;
    end;
  PDataRec = ^DataRec;

  { TDialogDBSetExport }

  PDialogDBSetExport = ^TDialogDBSetExport;
  TDialogDBSetExport = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogDBSetExport : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogDBSetExport)^);
    Load : @TDialogDBSetExport.Load;
    Store : @TDialogDBSetExport.Store);

implementation

{ TDialogDBSetExport }

constructor TDialogDBSetExport.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(16, 13, 65, 24);
inherited Init(R, 'Datensatz exportieren');

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

R.Assign(36, 3, 47, 5);
Control := New(PButton, Init(R, 'O~K~', cmDBSetExport, bfDefault));
Insert(Control);

R.Assign(36, 6, 47, 8);
Control := New(PButton, Init(R, '~A~bbruch', cmDBSetExportAbort, bfNormal));
Insert(Control);

SelectNext(False);
end;

constructor TDialogDBSetExport.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogDBSetExport.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDBSetExport : BEGIN
      TDialog.Done;
      ClearEvent(Event);
    END;
    cmDBSetExportAbort : BEGIN
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

procedure TDialogDBSetExport.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogDBSetExport.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogDBSetExport.Done;
begin
inherited Done;
end;

end.
