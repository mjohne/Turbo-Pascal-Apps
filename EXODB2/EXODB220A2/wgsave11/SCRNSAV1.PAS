{$A+,B-,D+,E+,F+,G-,I+,L+,N-,O-,R+,S+,V+,X-}
{$M 8192,0,655360}

{File : SCRNSAV1.PAS, Vs. 1.1, for TP 7.0.

 Test of screen saver.
 This is only a simple example, don't expect too much.
 Look for all lines with +++ comment.

 The GetEvent and Idle method of TApplication need changes.

 This program disables TV GetEvent while in screen saver mode,
 (but see SCRNSAV2.PAS). Screen saver mode is canceled by pressing
 any key. Mouse moves do nothing.

 If the mechanism to invoke the screen server is ok for you, then just
 put your favorite flashy wonderful screen saver into the ScreenSaver method.

 Warning: There is a call to Randomize at invocation of the screen
          saver. This might interfere with other parts of your program.


 Hacked on 30-JUN-93 by Wolfgang Gross, gross@aecds.exchi.uni-heidelberg.de
 Comments by Rutger van de GeVEL, rutger@kub.nl.

 Changed: 13-JUL-93  bugs, minor improvements

 }


program TestScreenSaver;
  uses CRT,DOS,Objects,memory,Drivers,Views,Menus,Dialogs,App,gadgets,msgbox;

  const
    cmAboutDialog = 101;
    cmTestDialog  = 102;

    {change these constants as convenient                            +++}
    ScrnSaverText : String = 'Screen saver test lurking ...' ;      {+++}
    GracePeriod : longint = 5000; {ask DOS time after graceperiod}  {+++}
    {time values in centiseconds                                     +++}
    {Invoke screen saver after program is idle for ScrnSaverDelay centisecs.
     Text stays on screen for ScnrSaverPeriod centisecs. }
    ScrnSaverDelay : longint = 50;                                 {+++}
    ScrnSaverPeriod: longint = 50;                                 {+++}

  type

    TMyApp = object(TApplication)
      KickTime : longint; {seconds}                                 {+++}
      GraceCounter : word; {ask DOS time only if > graceperiod}     {+++}

      Heap: PHeapView; Clock : PClockView;
      constructor init;
      procedure getevent( VAR event : TEvent ); virtual;
      procedure HandleEvent(var Event: TEvent); virtual;
      procedure InitMenuBar; virtual;
      procedure InitStatusLine; virtual;
      procedure AboutDialog;
      procedure TestDialog;
      procedure Idle;virtual;
      procedure ScreenSaver;                                        {+++}
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


CONSTRUCTOR TMyApp.Init;
  VAR R : TRect;
  BEGIN

    TApplication.Init;

    KickTime := 0; GraceCounter := 0;                                {+++}

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
    BEGIN
      inherited GetEvent(Event);
      {reset counter if events pending                         +++}
      IF Event.What<>evNothing THEN                           {+++}
        BEGIN GraceCounter := 0; KickTime := 0  END;          {+++}
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

            else

               Exit;
           end;
           ClearEvent(Event);
         end

    end;  {PROC TMyApp.HandleEvent}


PROCEDURE TMyApp.Idle;
  BEGIN
    inherited Idle;
    Heap^.Update; Clock^.Update;

    IF GraceCounter < GracePeriod       {start calling DOS time after +++}
      THEN Inc(GraceCounter)            {grace period since it's too  +++}
      ELSE                              {time consuming.              +++}
        BEGIN
          IF KickTime=0 THEN KickTime := Time;                       {+++}
          IF (Abs(Time-KickTime)>ScrnSaverDelay)                     {+++}
            THEN ScreenSaver;                                        {+++}
        END;

  END; {PROC TMyApp.Idle}

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
          #13 + ^C'GetEvent disabled.'#13 +
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
        c : word;
    begin
      c := messagebox ( 'This is just a dummy dialog.', nil,
                        mfinformation+mfOkbutton );
    end;  {PROC TMyApp.TestDialog}


   PROCEDURE TMyApp.ScreenSaver;                                  {+++}
     VAR LastTime : longint;  ch : char;                          {+++}
     BEGIN                                                        {+++}
       doneevents; donevideo; Randomize;                          {+++}
       LastTime := 0; TextBackGround(Black);                      {+++}
                                                                  {+++}
         REPEAT                                                   {+++}
           IF (Abs(Time-LastTime)>ScrnSaverPeriod) THEN           {+++}
             BEGIN                                                {+++}
               ClrScr;                                            {+++}
               TextColor(Random(14)+1);                           {+++}
               Gotoxy ( Random(80-length(ScrnSaverText)),         {+++}
                        Random(24));                              {+++}
               write ( ScrnSaverText ); LastTime := Time;         {+++}
             END;                                                 {+++}
         UNTIL KeyPressed;                                        {+++}
                                                                  {+++}
       ch := ReadKey; {eat char}                                  {+++}
       KickTime := 0; GraceCounter := 0;                          {+++}
       initevents; initvideo;                                     {+++}
       inherited redraw;                                          {+++}
                                                                  {+++}
     END; {PROC TMyApp.ScreenSaver}                               {+++}


  var
    MyApp : TMyApp;


begin {SCRNSAV1}
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.  {SCRNSAV1}