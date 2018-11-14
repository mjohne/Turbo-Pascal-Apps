uses      app,drivers,scrsav,Objects,gadgets;
type      TMainApp=object(TApplication)
                     constructor Init;
                     destructor Done;virtual;
                     procedure Idle;virtual;
                     procedure GetEvent(var E:TEvent);virtual;
                     procedure HandleEvent(var E:Tevent);virtual;
                   end;
var        ScreenSaver:PScreenSaver;
           Heap:PHeapView;
           Clock:PClockView;

{----------------------------------------------------------------------------}
constructor TMainApp.Init;
var         St:PDosStream;
            R:TRect;
begin
  Inherited Init;
  RegisterScreenSaver;
  New(St,Init('SCREEN.SAV',stOpenRead));
  if St^.Status<>stOK then
  begin
    St^.Reset;
    Dispose(St,Done);
    ScreenSaver:=New(PScreenSaver,Init(0,1));
    New(St,Init('SCREEN.SAV',stCreate));
    if St^.Status=stOK then
      St^.Put(ScreenSaver)
    else
      St^.Reset;
    Dispose(St,Done);
  end else begin
    ScreenSaver:=PScreenSaver(St^.Get);
    Dispose(St,Done);
  end;

  GetExtent(R);
  R.A.X:=R.B.X-9;R.A.Y:=R.B.Y-1;
  Heap:=New(PHeapView,Init(R));
  Insert(Heap);
  GetExtent(R);
  R.A.X:=R.B.X-9;R.B.Y:=R.A.Y+1;
  Clock:=New(PClockView,Init(R));
  Insert(Clock);

  ScreenSaver^.Options;
end;

{----------------------------------------------------------------------------}
destructor TMainApp.Done;
var        St:PDosStream;
begin
  New(St,Init('SCREEN.SAV',stCreate));
  if St^.Status=stOK then
    St^.Put(ScreenSaver)
  else
    St^.Reset;
  Dispose(St,Done);
  Dispose(ScreenSaver,Done);
  Inherited Done;
end;

{----------------------------------------------------------------------------}
procedure TMainApp.Idle;
var       E:TEvent;
begin
  Inherited Idle;
  if ScreenSaver<>nil then
    ScreenSaver^.CountDown;
  Heap^.Update;
  Clock^.Update;
end;

{----------------------------------------------------------------------------}
procedure TMainApp.GetEvent(var E:TEvent);
begin
  Inherited GetEvent(E);
  if E.What<>evNothing then
    if ScreenSaver<>nil then
      if E.What=evKeyDown then
      begin
        if ScreenSaver^.Saving then
          E.What:=evNothing;
        ScreenSaver^.HeartBeat;
      end else
        if E.What and evMouse<>0 then
          ScreenSaver^.HeartBeat;
end;

{----------------------------------------------------------------------------}
procedure TMainApp.HandleEvent(var E:TEvent);
begin
  Inherited HandleEvent(E);
  if E.What=evKeyDown then
    if E.KeyCode=GetAltCode('A') then
      if ScreenSaver<>nil then
        ScreenSaver^.Options;
end;

{----------------------------------------------------------------------------}
var       MainApp:TMainApp;

begin
  MainApp.Init;
  MainApp.Run;
  MainApp.Done;
end.