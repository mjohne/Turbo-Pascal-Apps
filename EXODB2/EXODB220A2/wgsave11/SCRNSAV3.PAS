{$A+,B-,D+,E+,F+,G-,I+,L+,N-,O-,R+,S+,V+,X-}
{$M 8192,0,655360}

{File : SCRNSAV3.PAS, Vs. 1.1, for TP 7.0.

 Test of screen saver.
 This is only a simple example, don't expect too much.
 Look for all lines with +++ comment.

 The Init, GetEvent, HandleEvent and Idle method of TApplication
 need changes.

 This program does not disable TV GetEvent while in screen saver mode,
 but see SCRNSAV1.PAS. It also works if modal dialogs are pending.
 In some cases people might want to eat away key strokes which revoked
 the program from screen saver mode. Do this in GetEvent.

 Problem:  If a subview of TApplication has its own GetEvent then the
           screen saver might not know when to stop!! This demo
           shows how to cope with such a situation.

 If the mechanism to invoke the screen server is ok for you, then just
 put your favorite flashy wonderful screen saver into the Idle method.

 Warning: There is a call to Randomize at invocation of the screen
          saver. This might interfere with other parts of your program.
          Take care of checking boolean var ScreenSaverMode in
          your Idle routine (see below).

 Hacked on 30-JUN-93 by Wolfgang Gross, gross@aecds.exchi.uni-heidelberg.de
 Comments by Rutger van de GeVEL, rutger@kub.nl.

 Changed: 13-JUL-93   bugs, minor improvements

 }


program TestScreenSaver;
  uses CRT,DOS,Objects,memory,Drivers,Views,Menus,Dialogs,App,gadgets;

  const
    cmAboutDialog = 101;
    cmTestDialog  = 102;
    cmDummy       = 110;

    {change these constants as convenient                            +++}
    cmStartScrnSaver = 200;                                         {+++}
    cmStopScrnSaver  = 201;                                         {+++}
    {your favorite text here}
    ScrnSaverText : String = 'Screen saver test lurking ...' ;      {+++}
    GracePeriod : longint = 5000; {ask DOS time after graceperiod}  {+++}
    {all time values in centiseconds                                 +++}
    {Invoke screen saver after program is idle for ScrnSaverDelay centisecs}
    ScrnSaverDelay  : longint = 50;                                {+++}
    ScrnSaverPeriod : longint = 50;                                {+++}

  type

    {sample TDialog object to show how the getevent mechanism takes care
     of the screen saver activity. This works also in a different unit.}
    PMyDialog = ^TMyDialog;
    TMyDialog = object(TDialog)
      StartTime : longint;
      CONSTRUCTOR Init ( VAR R : TRect; Atitle: TTitleStr);
      procedure getevent(VAR Event : TEvent ); virtual;
      procedure handleevent(VAR Event : TEvent ); virtual;
      END;

    TMyApp = object(TApplication)
      ScrnSaverKickTime,                                            {+++}
      ScrnSaverLastTime : longint; {centiseconds}                   {+++}
      ScrnSaverMode : boolean;                                      {+++}
      GraceCounter : word; {ask DOS time only if > GracePeriod}     {+++}

      Heap: PHeapView; Clock : PClockView;
      constructor init;
      procedure getevent( VAR event : TEvent ); virtual;
      procedure HandleEvent(var Event: TEvent); virtual;
      procedure InitMenuBar; virtual;
      procedure InitStatusLine; virtual;
      procedure AboutDialog;
      procedure TestDialog;
      procedure Idle;virtual;
    end;


FUNCTION Time:longint;                     {+++ we need this function +++}
  {Return real day time in centiseconds. One might get in trouble with
   measurements spanning midnight. Smallest reliable interval: 55 msec}
  VAR Hour,Minute,Second,Sec100: WORD;                               {+++}
  BEGIN                                                              {+++}
    GetTime(Hour,Minute,Second,Sec100);                              {+++}
    Time:=longint(Sec100)+100*(longint(Second)                       {+++}
          +60*(longint(Minute)+60*longint(hour)));                   {+++}
  END;                                                               {+++}


    {----------------------------------------------------------}

CONSTRUCTOR TMyDialog.Init ( VAR R : TRect; Atitle: TTitleStr);
  BEGIN
    inherited Init ( R, Atitle );
    StartTime := time;
  END;

PROCEDURE TMyDialog.GetEvent(VAR Event : TEvent );
  VAR SEvent : TEvent;
  BEGIN
    IF (Time-StartTime)>2000 THEN
      BEGIN
        {Stop screen saver. This method works also if TMyDialog is
         defined in a different unit which uses APP. }
        SEvent.What := evcommand;                                    {+++}
        SEvent.command := cmStopScrnSaver;                           {+++}
        Application^.HandleEvent(SEvent);                            {+++}

        StartTime := Time;
        Event.What := evCommand;
        Event.command := cmDummy;
        Exit; {We must not call the inherited GetEvent}
      END;

    inherited GetEvent(Event);
  END;

PROCEDURE TMyDialog.HandleEvent(VAR Event : TEvent );
  BEGIN
    inherited HandleEvent(Event);

    IF (Event.What=evCommand) AND (Event.command=cmDummy) THEN
      ClearEvent(Event);
  END;

  {------------------------------------------------------------------}

CONSTRUCTOR TMyApp.Init;
  VAR R : TRect;
  BEGIN

    TApplication.Init;

    ScrnSaverKickTime := 0;                                          {+++}
    ScrnSaverLastTime := 0;                                          {+++}
    ScrnSaverMode := false;                                          {+++}
    GraceCounter :=0;                                                {+++}

    GetExtent(R);
    R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
    Clock := New(PClockView, Init(R));
    Insert(Clock);

    GetExtent(R);
    Dec(R.B.X);
    R.A.X := R.B.X - 9; R.A.Y := R.B.Y - 1;
    Heap := New(PHeapView, Init(R));
    Insert(Heap);

  END; {PROC TMyApp.Init}


  procedure TMyApp.GetEvent ( VAR Event : TEvent );
    VAR p : pointer; SEvent : TEvent;
    BEGIN
      {BEFORE: Your events before TV, eg. COM input. Don't call the
               inherited GetEvent in this case but proceed directly
               to the AFTER: line}
      inherited GetEvent(Event);
      {AFTER:  Your events after TV}

      {We must call HandleEvent explicitly since a pending modal dialog
       will otherwise eat the cmStart/StopScrnSaver event. We don't use
       methods like StartScrnSaver or StopScrnSaver since this is not
       callable by other units while the virtual HandleEvent can be
       called via Application^.HandleEvent.}

      {Reset counter if event pending but do not kill this event      +++}
      IF Event.What<>evNothing THEN                                  {+++}
        BEGIN                                                        {+++}
          GraceCounter := 0; ScrnSaverKickTime := 0;                 {+++}
          IF ScrnSaverMode THEN                                      {+++}
            BEGIN                                                    {+++}
              SEvent.What := evcommand;                              {+++}
              SEvent.command := cmStopScrnSaver;                     {+++}
              HandleEvent(SEvent);                                   {+++}
              Exit;                                                  {+++}
            END;                                                     {+++}
        END;                                                         {+++}

      IF NOT ScrnSaverMode THEN                                      {+++}
       IF GraceCounter < GracePeriod    {start calling DOS time after +++}
        THEN Inc(GraceCounter)          {grace period since it's too  +++}
        ELSE                            {time consuming.              +++}
          BEGIN
            IF ScrnSaverKickTime=0 THEN ScrnSaverKickTime := Time;   {+++}
            IF (Abs(Time-ScrnSaverKickTime)>ScrnSaverDelay) THEN     {+++}
              BEGIN                                                  {+++}
                SEvent.What := evcommand;                            {+++}
                SEvent.command := cmStartScrnSaver;                  {+++}
                HandleEvent(SEvent);                                 {+++}
                Exit;                                                {+++}
             END;                                                    {+++}
          END;                                                       {+++}

    END; {PROC TMyApp.GetEvent}


  procedure TMyApp.HandleEvent(var Event: TEvent);

    begin {HandleEvent}

      inherited HandleEvent(Event);

      if (Event.What = evCommand) then
         begin
           case Event.Command of
            cmAboutDialog :
               AboutDialog;
            cmTestDialog :
               TestDialog;
            cmStartScrnSaver :                                   {+++}
               BEGIN                                             {+++}
                 Randomize;                                      {+++}
                 ScrnSaverLastTime := 0;                         {+++}
                 ScrnSaverMode := true;                          {+++}
                 TextBackGround(Black);                          {+++}
               END;                                              {+++}
            cmStopScrnSaver :                                    {+++}
               IF ScrnSaverMode THEN                             {+++}
                 BEGIN                                           {+++}
                   ScrnSaverMode := false;                       {+++}
                   ScrnSaverKickTime := 0; GraceCounter := 0;    {+++}
                   inherited redraw;                             {+++}
                 END;                                            {+++}
            else

               Exit;
           end;
           ClearEvent(Event);
         end

    end;  {HandleEvent}


PROCEDURE TMyApp.Idle;
  BEGIN
    inherited Idle;                       {+++ do this in ScrnSaverMode ???}

    IF ScrnSaverMode                                                   {+++}
      THEN                                                             {+++}
        BEGIN                                                          {+++}
          IF (Abs(Time-ScrnSaverLastTime)>ScrnSaverPeriod) THEN        {+++}
            BEGIN                                                      {+++}
              ClrScr;                                                  {+++}
              TextColor(Random(14)+1);                                 {+++}
              Gotoxy ( Random(80-length(ScrnSaverText)), Random(24));  {+++}
              write ( ScrnSaverText ); ScrnSaverLastTime := Time;      {+++}
            END;                                                       {+++}
        END                                                            {+++}
      ELSE                                                             {+++}
        BEGIN                                                          {+++}
          Heap^.Update; Clock^.Update;                                 {+++}
        END;                                                           {+++}

  END;{PROC TMyApp.Idle}


  procedure TMyApp.InitMenuBar;
    VAR R : TRect;
    begin {InitMenuBar}
      GetExtent(R);
      R.B.Y := R.A.Y+1;
      MenuBar := New(PMenuBar, Init(R, NewMenu(
        NewSubMenu('~'#240'~', 1000, NewMenu(
          NewItem('~A~bout', '', kbNoKey, cmAboutDialog, 1001,nil)),
        NewSubMenu('~F~ile', 1100, NewMenu(
          NewItem('~T~estDialog', '', kbF3, cmTestDialog, 1010,
          NewLine(
          NewItem('E~x~it', '', kbAltx, cmquit, 1020,nil)))),
      nil)))));
    end;  {PROC TMyApp.InitMenuBar}


  procedure TMyApp.InitStatusLine;
    var   R : TRect;
    begin  {InitStatusLine}
      GetExtent(R);
      R.A.Y := R.B.Y - 1;
      StatusLine := New(PStatusLine,Init(R,
        NewStatusDef(0,$FFFF,
          NewStatusKey('',kbF10,cmMenu,
          NewStatusKey('~Alt-X~ Exit',kbAltX,cmQuit,
          NewStatusKey('~F3~ Testbox',kbF3,cmTestDialog,
          nil))),
        nil)
      ));
    end; {PROC TMyApp.InitStatusLine}


  procedure TMyApp.AboutDialog;
    var  D : PDialog;
         R : TRect;
         Control : PView;
         C : word;
    begin {AboutDialog}
      R.Assign(0, 0, 40, 11);
      D := New(PDialog, Init(R, 'About'));
      with D^ do
        begin
          Options := Options or ofCentered;

          R.Grow(-1, -1);
          Dec(R.B.Y, 3);
          Insert(New(PStaticText, Init(R,
          #13 + ^C'Turbo Vision Screen Saver Demo'#13 +
          #13 + ^C'GetEvent in effect.'#13 +
          #13 + ^C'W. Gross 1993'#13 )));

          R.Assign(15, 8, 25, 10);
          Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
         end;
      if ValidView(D) <> nil then
        begin
          c := Desktop^.ExecView(D);
          Dispose(D, Done);
        end;
    end;  {PROC TMyApp.AboutDialog}

  procedure TMyApp.TestDialog;
    var D: PDialog;
        R : TRect;
        c : word;
    begin
      R.Assign(0, 0, 40, 11);
      D := New(PMyDialog, Init(R, 'Test Dialog'));
      with D^ do
        begin
          Options := Options or ofCentered;

          R.Grow(-1, -1);
          Dec(R.B.Y, 3);
          Insert(New(PStaticText, Init(R,
          #13 + ^C'Turbo Vision Screen Saver Demo'#13 +
          #13 + ^C'Test dialog creates events after '#13 +
          #13 + ^C'a given time interval.'#13 )));

          R.Assign(15, 8, 25, 10);
          Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
         end;
      if ValidView(D) <> nil then
        begin
          c := Desktop^.ExecView(D);
          Dispose(D, Done);
        end;
    end;  {PROC TMyApp.TestDialog}


  var
    MyApp : TMyApp;


begin {SCRNSAV3}
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.  {SCRNSAV3}
