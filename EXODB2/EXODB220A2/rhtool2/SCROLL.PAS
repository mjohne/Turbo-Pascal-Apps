{*
*   TV Tool Box Version 2.0
*   Copyright 1992,93 by Richard W. Hansen, All Rights Reserved.
*
*
*   Demo.pas
*   A demo of TV TOOL BOX for Turbo Pascal 7.0.
*
*}

PROGRAM TV_SCROLL_TEST;
{$X+}

USES
  TvConst, TvScroll,
  Objects, Drivers, Views, Menus, Dialogs, App;


CONST
  cmTestW  = 100;
  cmTestD  = 101;

            {         1         2         3         4         5         6         7         8         9         0}
            {1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890}
  Line1   = 'ÚÄ These are Draggable and Resizable, press Tab to try some input lines.ÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄ¿';
  Line2   = '³    ³    ³    ³    ³    ³    ³    ³    ³    ³    ³    ³    ³    ³    ³    ³    ³    ³    ³    ³    ³';
  Line3   = 'ÃÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ´';


TYPE
  TMyApp = object(TApplication)
    Constructor Init;
    Procedure   HandleEvent(var Event: TEvent);           virtual;
    Procedure   InitMenuBar;                              virtual;
    Procedure   InitStatusLine;                           virtual;
    Procedure   TestWindow;
    Procedure   TestDialog;
  end;

  PMyView1 = ^TMyView1;
  TMyView1 = Object(TView)
    Procedure   Draw;                                     Virtual;
  end;

  PMyView2 = ^TMyView2;
  TMyView2 = Object(TView)
    Procedure   Draw;                                     Virtual;
  end;

  PMyView3 = ^TMyView3;
  TMyView3 = Object(TbxScrollView)
    Procedure   Draw;                                     Virtual;
    Procedure   SizeLimits(var Min, Max : TPoint);        Virtual;
  end;

  PMyWindow = ^TMyWindow;
  TMyWindow = Object(TbxScrollWindow)
    Function    InitBackground: PView;                    Virtual;
  end;


{ TMyView3 }
{ Scrolling, selectable views }
Procedure TMyView3.Draw;

  var
    B : TDrawBuffer;
    C : Word;

  begin
    { set colors for the various modes. }
    if (State AND sfDragging <> 0) and (State AND sfSelected <> 0) then
      C := 3
    else if (State AND sfFocused <> 0) then
      C := 2
    else
      C := 1;

    MoveChar(B, 'X', GetColor(C), Size.X);
    WriteLine(0, 0, Size.X, Size.Y, B);
  end;

Procedure TMyView3.SizeLimits(var Min, Max : TPoint);
  begin
    { only grow in X dimension }
    Min.X := 1;
    Min.Y := 1;
    Max.X := Owner^.Size.X;
    Max.Y := 1;
  end;


{ TMyView2 }
{ Scrolling background }
Procedure TMyView2.Draw;

  var
    C : Word;
    Y : Word;
    X : Word;
    I : Integer;
    T : String[5];
    S : String;

  begin
    if State and sfFocused <> 0 then
      C := $0002
    else
      C := $0001;

    { Display the currently visible portion of the background }
    Y := PbxScrollGroup(Owner)^.VScrollBar^.Value;
    X := PbxScrollGroup(Owner)^.HScrollBar^.Value + 1;

    for I := 0 to Size.Y - 1 do
    begin
      if (Y = 0) then
        S := Copy(Line1, X, Size.X)
      else if (Y MOD 3 = 0) then
        S := Copy(Line3, X, Size.X)
      else
        S := Copy(Line2, X, Size.X);

      Inc(Y);
      Str(Y:3, T);
      S[Length(S) - 1] := T[3];
      S[Length(S) - 2] := T[2];
      S[Length(S) - 3] := T[1];

      WriteStr(0, I, S, C);
    end;
  end;


{ TMyView1 }
{ Scrolling non-selectable views }
Procedure TMyView1.Draw;

  var
    B : TDrawBuffer;
    C : Word;

  begin
    if State and sfFocused <> 0 then
    begin
      C := $0002;
    end
    else
    begin
      C := $0001;
    end;

    MoveChar(B, '*', GetColor(C), Size.X);
    WriteLine(0, 0, Size.X, Size.Y, B);
  end;


Function TMyWindow.InitBackground: PView;

  var
    R : TRect;
    P : PView;

  begin
    Interior^.GetExtent(R);
    P := New(PMyView2, Init(R));
    P^.SetState(sfDisabled, True);
    P^.Options  := P^.Options AND not ofSelectable;
    P^.GrowMode := P^.GrowMode OR gfGrowHiX OR gfGrowHiY;
    InitBackground := P;
  end;


{ TMyApp }

Procedure TMyApp.HandleEvent(var Event: TEvent);
  begin
    TApplication.HandleEvent(Event);

    if Event.What = evCommand then
    begin
      case Event.Command of
        {cmTestW : TestWindow;}
        cmTestD : TestDialog;
        cmTestW : TestWindow;
      else
        Exit;
      end;

      ClearEvent(Event);
    end;
  end;

Procedure TMyApp.InitMenuBar;

  var
    R: TRect;

  begin
    GetExtent(R);
    R.B.Y := R.A.Y + 1;
    MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewSubMenu('~T~est', hcNoContext, NewMenu(
        NewItem('Test ~W~indow', 'F4', kbF4, cmTestW, hcNoContext,
        NewItem('Test ~D~ialog', 'F5', kbF4, cmTestD, hcNoContext,
        NewLine(
        NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext,
        nil))))),
      nil))
    ));
  end;

Procedure TMyApp.InitStatusLine;

  var
    R: TRect;

  begin
    GetExtent(R);
    R.A.Y := R.B.Y - 1;
    StatusLine := New(PStatusLine, Init(R,
      NewStatusDef(0, $FFFF,
        NewStatusKey('', kbF10, cmMenu,
        NewStatusKey('~Alt-X~ Exit',      kbAltX, cmQuit,
        NewStatusKey('~F2~ Resize Window',kbF2,   cmResize,
        NewStatusKey('~F3~ Resize Field', kbF3,   cmDragView,
        NewStatusKey('~F4~ New Window',   kbF4,   cmTestW,
        NewStatusKey('~F5~ New Dialog',   kbF5,   cmTestD,
        NewStatusKey('~F6~ Next Window',  kbF6,   cmNext,
        nil))))))),
      nil)
    ));
  end;

Procedure TMyApp.TestDialog;

  var
    Dlg : PbxScrollDialog;
    R   : TRect;
    P   : PView;
    i   : Integer;

  begin
    R.Assign(0,0,44,19);
    New(Dlg, Init(R, 'Test Dialog', ofVScrollBar or ofHScrollBar));

    with Dlg^ do
    begin
      Options := Options OR ofCentered;
      { Make sure to set the size limits so the scrolling can be controlled. }
      SetLimit(60, 30);

      { add a label }
      { any view can be inserted to scroll, just set the scroll flag }
      R.Assign(10,0,30,1);
      P := New(PStaticText, Init(R, 'Scrolling Data Entry'));
      InsertToScroll(P);

      { add some input lines }
      for i := 1 to 12 do
      begin
        R.Assign(5,i + 1, 20, i + 2);
        P := New(PInputLine, Init(R, 12));
        InsertToScroll(P);
      end;

      { add check boxes }
      R.Assign(23,2,34,6);
      P := New(PCheckBoxes, Init(R,
        NewSItem('~O~ne',
        NewSItem('~T~wo',
        NewSItem('Th~r~ee',
        NewSItem('~F~our',Nil))))));
      PCluster(P)^.Value := 0;
      InsertToScroll(P);

      { add radio buttons }
      R.Assign(23,8,34,12);
      P := New(PRadioButtons, Init(R,
        NewSItem('~O~ne',
        NewSItem('~T~wo',
        NewSItem('Th~r~ee',
        NewSItem('~F~our',Nil))))));
      PCluster(P)^.Value := 0;
      InsertToScroll(P);

      { add some more input lines }
      for i := 1 to 12 do
      begin
        R.Assign(38,i + 1, 53, i + 2);
        P := New(PInputLine, Init(R, 12));
        InsertToScroll(P);
      end;

      { add more radio buttons }
      R.Assign(23,13,34,17);
      P := New(PRadioButtons, Init(R,
        NewSItem('~O~ne',
        NewSItem('~T~wo',
        NewSItem('Th~r~ee',
        NewSItem('~F~our',Nil))))));
      PCluster(P)^.Value := 0;
      InsertToScroll(P);

      { Add some buttons, these can scroll too, as you see fit.
        It kind of depends on how your dialog box is layed out.
        But make sure to insert them into the scrolling group, not
        directly into the dialog box. If buttons are inserted into
        the dialog and not the scrolling group, the tab order gets
        messed up.
      }
      R.Assign(6,20,14,22);
      P := New(PButton, Init(R, 'O~K~', cmOK, bfDefault));
      InsertToScroll(P);

      R.Assign(26,20,38,22);
      P := New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal));
      InsertToScroll(P);

      Interior^.SelectNext(False);
    end;

    Desktop^.ExecView(Dlg);
    Dispose(Dlg, Done);
  end;

Procedure TMyApp.TestWindow;

  var
    Win : PMyWindow;
    i   : Integer;
    P   : PView;
    R   : TRect;
    S   : PScroller;

  begin
    R.Assign(0, 0, 40, 15);
    Win := New(PMyWindow, Init(R, 'Demo Window', wnNoNumber, ofVScrollBar or ofHScrollBar));
    { Make sure to set the size limits so the scrolling can be controlled. }
    Win^.SetLimit(100,30);
    {Win^.AutoPosition(False);}

    { Add some views that scroll, and can be resized and dragged. }
    for i := 1 to 7 do
    begin
      R.Assign(i,i, i + i * 2, i + 1);
      P := New(PMyView3, Init(R));
      Win^.InsertToScroll(P);
    end;

    { Add some views that scroll, but cannot be resized or dragged.
      You could also add views that do not scroll at all, just by
      cleared the gfGrowXYRel bit in the GrowMode.
    }
    for i := 1 to 7 do
    begin
      R.Assign(1,i + 9, i * i + 1, i + 10);
      P := New(PMyView1, Init(R));
      Win^.InsertToScroll(P);
    end;

    { add some scrolling input lines }
    for i := 1 to 2 do
    begin
      R.Assign(1,i + 18, 9, i + 19);
      P := New(PbxScrollInputLine, Init(R, 6));
      Win^.InsertToScroll(P);
    end;

    R.Assign(1,i + 20, 9, i + 21);
    P := New(PbxScrollInputLine, Init(R, 15));
    Win^.InsertToScroll(P);

    { Always insert the window after it is setup, (after first view
      has been inserted) this will avoid some unsightly screen displays on
      slower machines.
    }
    DeskTop^.Insert(Win);
  end;

Constructor TMyApp.Init;

  var
    E : TEvent;

  begin
    TApplication.Init;
    E.What := evCommand;
    E.Command := cmTestD;
    E.InfoPtr := nil;
    PutEvent(E);
  end;


VAR
  MyApp : TMyApp;

BEGIN
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
END.
