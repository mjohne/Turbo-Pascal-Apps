unit DBOBJEXP;

interface

uses Democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field1 : Word;
    end;
  PDataRec = ^DataRec;

  { TDialogDBObjectExport }

  PDialogDBObjectExport = ^TDialogDBObjectExport;
  TDialogDBObjectExport = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogDBObjectExport : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogDBObjectExport)^);
    Load : @TDialogDBObjectExport.Load;
    Store : @TDialogDBObjectExport.Store);

implementation

{ TDialogDBObjectExport }

constructor TDialogDBObjectExport.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(16, 13, 65, 24);
inherited Init(R, 'Datenobjekt exportieren');

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
Control := New(PButton, Init(R, 'O~K~', cmDBObjectExport, bfDefault));
Insert(Control);

R.Assign(36, 6, 47, 8);
Control := New(PButton, Init(R, '~A~bbruch', cmDBObjectExportAbort, bfNormal));
Insert(Control);

SelectNext(False);
end;

constructor TDialogDBObjectExport.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogDBObjectExport.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmDBObjectExport : BEGIN
      TDialog.Done;
      ClearEvent(Event);
    END;
    cmDBObjectExportAbort : BEGIN
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

procedure TDialogDBObjectExport.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogDBObjectExport.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogDBObjectExport.Done;
begin
inherited Done;
end;

end.
