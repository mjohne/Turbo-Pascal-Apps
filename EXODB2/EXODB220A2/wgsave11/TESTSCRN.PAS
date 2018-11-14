{ TESTSCRN.PAS
  Program to demonstrate the ScrnSav Unit
  Written by Rutger van de GeVEL, 9 july 1993.

  W. Gross : Take care of checking boolean var ScreenSaverMode in
             your Idle routine (see below).
             Some 8-bit char's might get clobbered if this program
             is e-mailed.
}

Program TestScrn;

Uses
   Objects, Drivers, App, Views, Menus, Crt, ScrnSave, Dialogs, Gadgets;

Const
   cmAbout  = 1100;

Type
   PTestApp = ^TTestApp;
   TTestApp = Object (TScreenSaverApp)
              Heap: PHeapView; Clock : PClockView;
              Constructor Init;
              Procedure HandleEvent (Var Event: TEvent); Virtual;
              Procedure Idle; virtual;
              Procedure InitMenuBar; Virtual;
              Procedure ScreenSaver; Virtual;
              Procedure DoAboutDialog;
              End;


Var
   TestApp  : TTestApp;


Procedure PutXY (X, Y: Integer; S: String);

   Begin (* PutsXY *)
   GotoXY (X, Y);
   Write (S);
   End;  (* PutsXY *)


Function AboutDialog: PDialog;
Var
   Dialog : PDialog;
   R      : TRect;

   Begin (* AboutDialog *)
   R.Assign (0, 0, 46, 15);
   Dialog:= New (PDialog, Init (R, 'About'));
   With Dialog^ Do
        Begin
        Options:= Options Or ofCentered;
        HelpCtx:= $A000;
        R.Grow (-1, -1);
        Dec (R.B.Y, 3);
        Insert (New (PStaticText, Init (R,
                #13 + ^C'A ScreenSaver Demo'#13 +
                #13 + ^C'ScrnSav source-code by Wolfgang Gross'#13 +
                      ^C'Email: Gross@aecds.exchi.uni-heidelberg.de'#13 +
                #13 + ^C'Adapted by Rutger van de GeVEL'#13 +
                      ^C'E-mail: Rutger@kub.nl'#13 +
                #13 + ^C'ScreenSaver activates in 1 minute.')));
        R.Assign (18, 12, 28, 14);
        Insert (New (PButton, Init (R, '~O~k', cmOk, bfDefault)));
        End;
   AboutDialog:= Dialog;
   End;  (* AboutDialog *)


Constructor TTestApp.Init;
   VAR R : TRect;
   Begin (* TTestApp.Init *)
   Inherited Init;
   SleepTime:= 6000;                 { Start screen saver after 1 minute }

    GetExtent(R);
    R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
    Clock := New(PClockView, Init(R));
    Insert(Clock);

    GetExtent(R);
    Dec(R.B.X);
    R.A.X := R.B.X - 9; R.A.Y := R.B.Y - 1;
    Heap := New(PHeapView, Init(R));
    Insert(Heap);

   DoAboutDialog;
   End;  (* TTestApp.Init *)


Procedure TTestApp.HandleEvent (Var Event: TEvent);

   Begin (* TTestApp.HandleEvent *)
   Inherited HandleEvent (Event);
   Case (Event.What) Of
        evCommand: Case (Event.Command) Of
                        cmAbout : DoAboutDialog;
                     Else
                        Exit;
                     End;
     Else
        Exit;
     End;
   ClearEvent (Event);
   End;  (* TTestApp.HandleEvent *)

PROCEDURE TTestApp.Idle;
  BEGIN
    inherited Idle;                       {+++ do this in ScrnSaverMode ???}
    IF NOT ScreenSaverMode THEN
      BEGIN
        Heap^.Update; Clock^.Update;
      END;
  END;{PROC TTestApp.Idle}

Procedure TTestApp.InitMenuBar;
Var
   R: TRect;

   Begin (* TTestApp.InitMenuBar *)
   GetExtent (R);
   R.B.Y:= R.A.Y + 1;
   MenuBar:= New (PMenuBar, Init (R, NewMenu (
               NewItem ('~A~bout', '', kbAltSpace, cmAbout, hcNoContext,
               Nil))));
   End;  (* TTestApp.InitMenuBar *)


Procedure TTestApp.ScreenSaver;
Var
   X, Y: Integer;

   Begin (* TTestApp.ScreenSaver *)
   X:= Random (38) + 1;
   Y:= Random (17) + 1;
   PutXY (X, Y  , 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
   PutXY (X, Y+1, '³    Demo in ScreenSaver mode to    ³');
   PutXY (X, Y+2, '³        preserve the monitor       ³');
   PutXY (X, Y+3, '³    Move mouse or press any key    ³');
   PutXY (X, Y+4, '³           to continue ...         ³');
   PutXY (X, Y+5, 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
   LastTime:= Time;
   End;  (* TTestApp.ScreenSaver *)


Procedure TTestApp.DoAboutDialog;

   Begin (* TTestApp.DoAboutDialog *)
   ExecuteDialog (AboutDialog, Nil);
   End;  (* TTestApp.DoAboutDialog *)


Begin (* Main Program *)
TestApp.Init;
TestApp.Run;
TestApp.Done;
End.  (* Main Program *)

