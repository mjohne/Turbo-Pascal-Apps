unit FILTER;

interface

uses democmds,Drivers, Objects, Views, Dialogs;

type
  DataRec = record
    Field3 : String[255];
    Field5 : String[255];
    Field6 : String[255];
    Field7 : String[255];
    Field8 : String[255];
    Field9 : String[255];
    Field10 : String[255];
    Field11 : String[255];
    Field12 : String[255];
    Field13 : String[255];
    Field14 : String[255];
    Field16 : String[255];
    Field17 : String[255];
    Field18 : String[255];
    Field19 : String[255];
    Field20 : String[255];
    Field21 : String[255];
    Field22 : String[255];
    Field23 : String[255];
    Field24 : String[255];
    Field26 : String[255];
    Field27 : String[255];
    Field28 : String[255];
    Field29 : String[255];
    Field30 : String[255];
    Field31 : String[255];
    Field32 : String[255];
    Field33 : String[255];
    end;
  PDataRec = ^DataRec;

  { TDialogFilter }

  PDialogFilter = ^TDialogFilter;
  TDialogFilter = object(TDialog)
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
    function Valid(Command : word): boolean; virtual;
    destructor Done; virtual;
  end;

const
  RDialogFilter : TStreamRec = (
    ObjType: 12345;            {<--- Insert a unique number >= 100 here!!}
    VmtLink: Ofs(Typeof(TDialogFilter)^);
    Load : @TDialogFilter.Load;
    Store : @TDialogFilter.Store);

implementation

{ TDialogFilter }

constructor TDialogFilter.Init;
var
  R: TRect;
  Control : PView;
begin
R.Assign(1, 3, 79, 27);
inherited Init(R, 'Filter');

R.Assign(45, 20, 56, 22);
Control := New(PButton, Init(R, 'O~K~', cmFilter, bfDefault));
Insert(Control);

R.Assign(59, 20, 70, 22);
Control := New(PButton, Init(R, '~A~bbruch', cmFilterAbort, bfNormal));
Insert(Control);

R.Assign(4, 2, 15, 3);
Control := New(PStaticText, Init(R, 'Spektraltyp'));
Insert(Control);

R.Assign(10, 3, 18, 4);
Control := New(PInputLine, Init(R, 10));
Insert(Control);

  R.Assign(4, 3, 10, 4);
  Insert(New(PLabel, Init(R, 'Von:', Control)));

R.Assign(24, 3, 32, 4);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(18, 3, 24, 4);
  Insert(New(PLabel, Init(R, 'Bis:', Control)));

R.Assign(4, 5, 31, 6);
Control := New(PStaticText, Init(R, 'Scheinbare Helligkeit (mag)'));
Insert(Control);

R.Assign(10, 6, 18, 7);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(4, 6, 10, 7);
  Insert(New(PLabel, Init(R, 'Von:', Control)));

R.Assign(24, 6, 32, 7);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(18, 6, 24, 7);
  Insert(New(PLabel, Init(R, 'Bis:', Control)));

R.Assign(4, 8, 29, 9);
Control := New(PStaticText, Init(R, 'Zentralstern-Masse (MSol)'));
Insert(Control);

R.Assign(10, 9, 18, 10);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(4, 9, 10, 10);
  Insert(New(PLabel, Init(R, 'Von:', Control)));

R.Assign(24, 9, 32, 10);
Control := New(PInputLine, Init(R, 5));
Insert(Control);

  R.Assign(18, 9, 24, 10);
  Insert(New(PLabel, Init(R, 'Bis:', Control)));

R.Assign(4, 11, 16, 12);
Control := New(PStaticText, Init(R, 'Metallizit„t'));
Insert(Control);

R.Assign(10, 12, 18, 13);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(4, 12, 10, 13);
  Insert(New(PLabel, Init(R, 'Von:', Control)));

R.Assign(24, 12, 32, 13);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(18, 12, 24, 13);
  Insert(New(PLabel, Init(R, 'Bis:', Control)));

R.Assign(4, 14, 33, 15);
Control := New(PStaticText, Init(R, 'Entfernung zur Sonne (Parsec)'));
Insert(Control);

R.Assign(10, 15, 18, 16);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(4, 15, 10, 16);
  Insert(New(PLabel, Init(R, 'Von:', Control)));

R.Assign(24, 15, 32, 16);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(18, 15, 24, 16);
  Insert(New(PLabel, Init(R, 'Bis:', Control)));

R.Assign(4, 17, 25, 18);
Control := New(PStaticText, Init(R, 'Rektaszension (J2000)'));
Insert(Control);

R.Assign(10, 18, 18, 19);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(4, 18, 10, 19);
  Insert(New(PLabel, Init(R, 'Von:', Control)));

R.Assign(24, 18, 32, 19);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(18, 18, 24, 19);
  Insert(New(PLabel, Init(R, 'Bis:', Control)));

R.Assign(4, 20, 23, 21);
Control := New(PStaticText, Init(R, 'Deklination (J2000)'));
Insert(Control);

R.Assign(10, 21, 18, 22);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(4, 21, 10, 22);
  Insert(New(PLabel, Init(R, 'Von:', Control)));

R.Assign(24, 21, 32, 22);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(18, 21, 24, 22);
  Insert(New(PLabel, Init(R, 'Bis:', Control)));

R.Assign(35, 2, 55, 3);
Control := New(PStaticText, Init(R, 'Planetenmasse (MJup)'));
Insert(Control);

R.Assign(41, 3, 49, 4);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(35, 3, 41, 4);
  Insert(New(PLabel, Init(R, 'Von:', Control)));

R.Assign(55, 3, 63, 4);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(49, 3, 55, 4);
  Insert(New(PLabel, Init(R, 'Bis:', Control)));

R.Assign(35, 5, 55, 6);
Control := New(PStaticText, Init(R, 'Groáe Halbachse (AE)'));
Insert(Control);

R.Assign(41, 6, 49, 7);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(35, 6, 41, 7);
  Insert(New(PLabel, Init(R, 'Von:', Control)));

R.Assign(55, 6, 63, 7);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(49, 6, 55, 7);
  Insert(New(PLabel, Init(R, 'Bis:', Control)));

R.Assign(35, 8, 52, 9);
Control := New(PStaticText, Init(R, 'Umlaufzeit (Tage)'));
Insert(Control);

R.Assign(41, 9, 49, 10);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(35, 9, 41, 10);
  Insert(New(PLabel, Init(R, 'Von:', Control)));

R.Assign(55, 9, 63, 10);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(49, 9, 55, 10);
  Insert(New(PLabel, Init(R, 'Bis:', Control)));

R.Assign(35, 11, 53, 12);
Control := New(PStaticText, Init(R, 'Num. Enzentrizit„t'));
Insert(Control);

R.Assign(41, 12, 49, 13);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(35, 12, 41, 13);
  Insert(New(PLabel, Init(R, 'Von:', Control)));

R.Assign(55, 12, 63, 13);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(49, 12, 55, 13);
  Insert(New(PLabel, Init(R, 'Bis:', Control)));

R.Assign(35, 14, 51, 15);
Control := New(PStaticText, Init(R, 'Entdeckungsdatum'));
Insert(Control);

R.Assign(36, 15, 40, 16);
Control := New(PStaticText, Init(R, 'Von:'));
Insert(Control);

R.Assign(36, 16, 40, 17);
Control := New(PStaticText, Init(R, 'Bis:'));
Insert(Control);

R.Assign(46, 15, 53, 16);
Control := New(PInputLine, Init(R, 6));
Insert(Control);

  R.Assign(40, 15, 46, 16);
  Insert(New(PLabel, Init(R, 'Jahr', Control)));

R.Assign(60, 15, 64, 16);
Control := New(PInputLine, Init(R, 1));
Insert(Control);

  R.Assign(53, 15, 60, 16);
  Insert(New(PLabel, Init(R, 'Monat', Control)));

R.Assign(69, 15, 73, 16);
Control := New(PInputLine, Init(R, 1));
Insert(Control);

  R.Assign(64, 15, 69, 16);
  Insert(New(PLabel, Init(R, 'Tag', Control)));

R.Assign(46, 16, 53, 17);
Control := New(PInputLine, Init(R, 1));
Insert(Control);

  R.Assign(40, 16, 46, 17);
  Insert(New(PLabel, Init(R, 'Jahr', Control)));

R.Assign(60, 16, 64, 17);
Control := New(PInputLine, Init(R, 5));
Insert(Control);

  R.Assign(53, 16, 60, 17);
  Insert(New(PLabel, Init(R, 'Monat', Control)));

R.Assign(69, 16, 73, 17);
Control := New(PInputLine, Init(R, 2));
Insert(Control);

  R.Assign(64, 16, 69, 17);
  Insert(New(PLabel, Init(R, 'Tag', Control)));

SelectNext(False);
end;

constructor TDialogFilter.Load(var S: TStream);
begin
inherited Load(S);
end;

procedure TDialogFilter.HandleEvent(var Event: TEvent);
begin
if Event.What and evMessage <> 0 then
  case Event.Command of
    cmFilter : TDialog.Done;
    cmFilterAbort : TDialog.Done;
  end;

inherited HandleEvent(Event);
(*---
if Event.What and evMessage <> 0 then
  case Event.Command of
    end;    --*)

end;

procedure TDialogFilter.Store(var S: TStream);
begin
inherited Store(S);
end;

function TDialogFilter.Valid(Command : word): boolean;
var
  Result : boolean;
begin
Result := inherited Valid(Command);
Valid := Result;
end;

destructor TDialogFilter.Done;
begin
inherited Done;
end;

end.
