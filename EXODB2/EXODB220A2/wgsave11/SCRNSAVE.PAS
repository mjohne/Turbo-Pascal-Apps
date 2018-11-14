{
  Hacked on 30 june 1993 by Wolfgang Gross
  Email: Gross@aecds.exchi.uni-heidelberg.de

  Modified on 8 july 1993 by Rutger van de GeVEL
  Email: Rutger@kub.nl

  Compiler:
  - Turbo/Borland Pascal, Version >= 6.0

  - Turbo Vision, Version >= 1.0

  Warning: You may need to change the cmStart/StopScreenSaver constants.
           Randomize might interfere with other parts of your program.
           Take care of checking ScreenSaverMode in your Idle routine
           (see test program TESTSCRN.PAS).
}

Unit ScrnSave;

Interface

Uses
   Objects, Drivers, App;

Const
   cmStartScreenSaver    = 65534;
   cmStopScreenSaver     = 65535;

   GracePeriod:  LongInt = 5000;           { ask Dos time after graceperiod }

Type
   PScreenSaverApp = ^TScreenSaverApp;
   TScreenSaverApp = Object (TApplication)
                     KickTime       : LongInt; { in Sec100 }
                     LastTime       : LongInt; { in Sec100 }
                     SleepTime      : LongInt; { in Sec100 }
                     FlashDelay     : LongInt; { in Sec100 }
                     ScreenSaverMode: Boolean;
                     GraceCounter   : LongInt;
                     Constructor Init;
                     Procedure Idle; Virtual;
                     Procedure GetEvent (Var Event: TEvent); Virtual;
                     Procedure HandleEvent (Var Event: TEvent); Virtual;
                     Procedure ScreenSaver; Virtual;
                     End;


Function Time: LongInt;


Implementation

Uses
   Dos, Crt;


Function Time: LongInt;
Var
   Hour, Minute, Second, Sec100: Word;

   Begin (* Time *)
   GetTime (Hour, Minute, Second, Sec100);
   Time:= LongInt (Sec100) + 100 *                                    { ! }
          (LongInt (Second) + 60 * LongInt (Minute + 60 * Hour));     { ! }
   End;  (* Time *)


Constructor TScreenSaverApp.Init;
Var
   R: TRect;

   Begin (* TScreenSaverApp.Init *)
   Inherited Init;
   Randomize;                                                         { ! }
   KickTime:= 0;
   LastTime:= 0;
   SleepTime:= 0;                     { ScreenSaver is disabled by default }
   FlashDelay:= 500;
   ScreenSaverMode:= False;
   GraceCounter:= 0;
   End;  (* TScreenSaverApp.Init *)


Procedure TScreenSaverApp.Idle;

   Begin (* TScreenSaverApp.Idle *)
   Inherited Idle;
   If ScreenSaverMode Then
      Begin
      If (Abs (Time - LastTime) > FlashDelay) Then                    { ! }
         Begin
         ClrScr;
         ScreenSaver;
         End;
      End;
   End;  (* TScreenSaverApp.Idle *)


Procedure TScreenSaverApp.GetEvent (Var Event: TEvent);
Var
   SEvent: TEvent;

   Begin (* TScreenSaverApp.GetEvent *)
   Inherited GetEvent (Event);
   {
   We must call HandleEvent explicitly since a pending modal dialog
   will otherwise eat the cmStartScreenSaver/cmStopScreenSaver event.
   Reset counter if event pending but do not kill this event
   }
   If (Event.What <> evNothing) Then
      Begin
      GraceCounter:= 0;
      KickTime:= 0;
      If (ScreenSaverMode) Then
         Begin
         SEvent.What:= evCommand;
         SEvent.Command:= cmStopScreenSaver;
         HandleEvent (SEvent);
         Exit;
         End;
      End;
   If (Not ScreenSaverMode) Then
      If (GraceCounter < GracePeriod) Then
         Inc (GraceCounter)
      Else
         Begin
         If (KickTime = 0) Then
            KickTime:= Time;
         If (SleepTime > 0) Then                                      { ! }
            If (Abs (Time - KickTime) > SleepTime) Then               { ! }
               Begin
               SEvent.What:= evCommand;
               SEvent.Command:= cmStartScreenSaver;
               HandleEvent (SEvent);
               Exit;
               End;
         End;
   End;  (* TScreenSaverApp.GetEvent *)


Procedure TScreenSaverApp.HandleEvent (Var Event: TEvent);

   Begin (* TScreenSaverApp.HandleEvent *)
   Inherited HandleEvent (Event);
   If (Event.What = evCommand) Then
      Case Event.Command Of
           cmStartScreenSaver: Begin
                               LastTime:= 0;
                               ScreenSaverMode:= True;
                               End;
           cmStopScreenSaver : Begin
                               ScreenSaverMode:= False;
                               KickTime:= 0;
                               GraceCounter:= 0;
                               ReDraw;
                               End;
        Else
           Exit;
        End;
   ClearEvent (Event);
   End;  (* TScreenSaverApp.HandleEvent *)


Procedure TScreenSaverApp.ScreenSaver;

   Begin (* TScreenSaverApp.ScreenSaver *)
   Abstract;                                                          { ! }
   {
     Forces to override this virtual method
   }
   End;  (* TScreenSaverApp.ScreenSaver *)


End. (* Implementation *)
