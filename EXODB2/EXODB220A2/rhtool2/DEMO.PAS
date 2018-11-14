{*
*   TV Tool Box Version 2.0
*   Copyright 1992,93 by Richard W. Hansen, All Rights Reserved.
*
*
*   Demo.pas
*   A demo of TV TOOL BOX for Turbo Pascal 7.0.
*
*}

Program TV_TOOL_BOX_DEMO;
{$F-}
{$X+}
{$B+}
{$V-}
{$S+}
{$R+}
{$N+}

{$I TVDEFS.INC}


USES
  Crt, Dos,
  Objects, Drivers, Views, Menus, Dialogs, App, MsgBox, StdDlg, Validate,
  TvApp, TvConst, TvViews, TvDialog, TvMenus, TvInput, Tv3D,
  TvObject, TvString, TvType;


CONST
  MaxLines          = 500;        { max file buffer lines }
  MaxBuf            = 32768;      { max file buffer size  }

  cmFileOpen        = 100;
  cmNewText         = 101;
  cmNewWin          = 102;
  cmNewFormatText   = 103;
  cmNewAsciiHex     = 104;
  cmMsgDialog       = 105;
  cmNewEditLine     = 106;
  cmAbout           = 107;
  cmSetup           = 108;
  cmTestPct         = 109;
  cmTestPrt         = 110;
  cmTestWrite       = 111;
  cmTest3D          = 112;
  cmNone            = 113;
  cmTestBox1        = 114;
  cmTestBox2        = 115;
  cmTestBox3        = 116;
  cmTestPictures    = 117;
  cmSearch          = 999;
  cmTool1           = 1000;
  cmTool2           = cmTool1 + 1;
  cmTool3           = cmtool2 + 1;
  cmTool4           = cmTool3 + 1;
  cmTool5           = cmTool4 + 1;
  cmTool6           = cmTool5 + 1;
  cmTool7           = cmTool6 + 1;
  cmItem1           = cmMarkStart;
  cmItem2           = cmItem1 + 1;
  cmItem3           = cmItem2 + 1;
  cmItem4           = cmItem3 + 1;

  WinCount          : Integer =   0;
  MaxLong           = 99999;


TYPE
  { data entry test dialog data record }
  DataRec = record
    S1 : String[10];
    S2 : String[21];
    S3 : String[21];
    S4 : String[21];
    I1 : Word;
    I2 : Integer;
    H1 : LongInt;
    S5 : String[8];
    S6 : String[8];
    S7 : String[10];
    S8 : String[10];
    R1 : Real;
    {$IFOPT N+}
    D1 : Double;
    {$ENDIF}
    S9 : String[12];
    Dt1: TbxDateRec;
    Dt2: TbxDateRec;
    SX1: Integer;
    SX2: Integer;
    SX3: Integer;
    X  : Word;
  end;


TYPE
  { data object for the virtual list box }
  PLong = ^TLong;
  TLong = Object(TObject)
    Val : LongInt;
  end;


  { virtual list box }
  PVirtList  = ^TVirtList;
  TVirtList  = Object(TbxVListBox)
    Current : LongInt;

    Function    GetText(Item: Integer;
                        MaxLen: Integer): String;         Virtual;
    Function    GetItem(ACommand : Word): PObject;        Virtual;
    Function    MatchItem(P : PObject): Boolean;          Virtual;
  end;


  { dialog for virtual list box }
  PVirtDialog = ^TVirtDialog;
  TVirtDialog = Object(TDialog)
    VList : PCollection;
    VBox  : PVirtList;
    Long  : PbxLongEdit;

    Constructor Init;
    Destructor  Done;                                     Virtual;
    Procedure   HandleEvent(var Event : TEvent);          Virtual;
  end;


  PMyValidator  = ^TMyValidator;
  TMyValidator  = Object(TValidator)
    Function IsValid(const S : String): Boolean;           Virtual;
  end;


  PCityColl = ^TCityColl;
  TCityColl = object(TStringCollection)
    Constructor Init;
  end;


  { interior for standard file viewer }
  PFileView = ^TFileView;
  TFileView = object(TScroller)
    Constructor Init(var Bounds: TRect;
                         AHScrollBar,
                         AVScrollBar: PScrollBar);
    Procedure   Draw;                                     Virtual;
  end;


  { standard file viewer window }
  PFileWindow = ^TFileWindow;
  TFileWindow = Object(TbxWindow)
    Interior: PFileView;

    Constructor Init(Bounds: TRect; WinTitle: String; WindowNo: Word);
    Function    MakeInterior(Bounds: TRect): PFileView;
  end;


  PPctDialog  = ^TPctDialog;
  TPctDialog  = Object(TbxPercentDialog)
    Procedure   Process;                                Virtual;
  end;


  PPrtDialog  = ^TPrtDialog;
  TPrtDialog  = Object(TbxPrintDialog)
    X : Word;

    Procedure   Process;                                Virtual;
  end;


  PHeapView = ^THeapView;
  THeapView = object(TView)
    OldMem : LongInt;

    Constructor Init(var Bounds: TRect);
    Procedure   Draw;                                   Virtual;
    Procedure   Update;
  end;


  TMyApp = object(TbxApplication)
    HeapView  : PHeapView;      { a memory indicator }
    DlgData   : DataRec;

    Constructor Init;
    Procedure   About;
    Procedure   HandleEvent(var Event: TEvent);         Virtual;
    Procedure   InitMenuBar;                            Virtual;
    Procedure   InitStatusLine;                         Virtual;
    Procedure   InitDeskTop;                            Virtual;
    Procedure   Idle;                                   Virtual;
    Procedure   PercentTest;
    Procedure   PrintTest;
    Procedure   Setup;
    Procedure   Test3D;
    Procedure   TestSelectBox1;
    Procedure   TestSelectBox2;
    Procedure   MessageDialog;
    Procedure   NewWindow;
    Procedure   OpenFile;
    Procedure   ReadFile(FileToRead : PathStr);
    Procedure   WritelnText;
    Procedure   NewText;
    Procedure   NewFormatText;
    Procedure   NewAsciiHex;
    Procedure   NewDataEntry;
    Procedure   TestPictures;
    Procedure   TestVList;
  end;

VAR
  { global file buffer data, used by multiple windows }
  LineCount : Integer;
  Lines     : Array[0..MaxLines - 1] of PString;
  Buf       : PbxCharArray;
  BufSize   : Word;
  BufName   : PathStr;


{ TVirtDialog }

Constructor TVirtDialog.Init;

  var
    R   : TRect;
    Bar : PScrollBar;
    P   : PLong;
    i   : Integer;

  Begin
    { CONSTRUCT A VIRTUAL LIST BOX }
    R.Assign(14,1,66,16);
    Inherited Init(R, 'Virtual List Box');
    Options := $1143;

    R.Assign(24,3,25,13);
    Bar := New(PScrollbar, Init(R));
    Insert(Bar);

    R.Assign(4,3,24,13);
    VBox := New(PVirtList, Init(R, 1, nil, Bar));
    Insert(VBox);

    { build initial list }
    { for demo purposes just create a list of many integers }
    New(VList, Init(100, 0));

    for i := 1 to VList^.Limit do
    begin
      New(P, Init);
      P^.Val := i;
      VList^.Insert(P);
    end;

    { set some the flags and add list to list box }
    VBox^.AtMin := True;
    VBox^.AtMax := False;
    VBox^.NewList(VList);


    R.Assign(4,2,13,3);
    Insert(New(PLabel, Init(R, 'List Box', VBox)));

    { add buttons for paging up and down }
    R.Assign(27,3,38,5);
    Insert(New(PButton, Init(R, '~<~< More', cmPrevPage, bfBroadcast+bfNormal)));

    R.Assign(38,3,49,5);
    Insert(New(PButton, Init(R, 'More ~>~>', cmNextPage, bfBroadcast+bfNormal)));

    { add jump to first and last item buttons }
    R.Assign(27,5,38,7);
    Insert(New(PButton, Init(R, '~F~irst', cmFirstPage, bfBroadcast+bfNormal)));

    R.Assign(38,5,49,7);
    Insert(New(PButton, Init(R, '~L~ast', cmLastPage, bfBroadcast+bfNormal)));

    { add an input line for entering a search value }
    R.Assign(34,8,42,9);
    Long := New(PbxLongEdit, Init(R, '#####', 0, 0));
    Insert(Long);

    { add a search button }
    R.Assign(32,10,44,12);
    Insert(New(PButton, Init(R, '~S~earch', cmSearch, bfNormal)));

    R.Assign(32,12,44,14);
    Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;

Destructor TVirtDialog.Done;
  begin
    Inherited Done;
    Dispose(VList, Done);
  end;

Procedure TVirtDialog.HandleEvent(var Event : TEvent);

  var
    P : PLong;

  begin
    Inherited HandleEvent(Event);

    { handle the search button }
    if (Event.What = evCommand) and (Event.Command = cmSearch) then
    begin
      { create an object identical to the list box collection and
        equal to the search value from the input line
      }
      New(P, Init);
      Long^.GetData(P^.Val);

      { call the LookUp method, if found the list box is redrawn
        automatically
      }
      if not VBox^.Lookup(P) then
      begin
        Dispose(P, Done);
        MessageBox('Value not found', nil, mfInformation or mfOkButton);
      end;
    end;
  end;


{ TVirtList }

Function TVirtList.GetText(Item: Integer; MaxLen: Integer): String;

  var
    S : String[20];

  begin
    if (List <> nil) then
      Str(PLong(List^.At(Item))^.Val:MaxLen - 3, S)
    else
      S := '';

    GetText := S;
  end;

Function TVirtList.GetItem(ACommand : Word): PObject;

  var
    P : PLong;

  begin
    { This method is customized for each list box. It establishes
      position in the "file" retrieves the next item as specified by the
      ACommand parameter. This function returns a pointer to an object
      that can be inserted into the list box.

      Since the list is integers, the integer value  Current serves as
      a current position and value.
    }
    Case ACommand of
      vlListMin : { first item in the list }
      begin
        { set positioning }
        Current := PLong(List^.At(0))^.Val;
        { create a new item }
        New(P, Init);
        { set the item data }
        P^.Val := Current;
      end;

      vlListMax : { last item in the list }
      begin
        Current := PLong(List^.At(List^.Count - 1))^.Val;
        New(P, Init);
        P^.Val := Current;
      end;

      vlMin : { first item in the "file" }
      begin
        Current := 1;
        New(P, Init);
        P^.Val := Current;
      end;

      vlMax : { last item in the "file" }
      begin
        Current := MaxLong;
        New(P, Init);
        P^.Val := Current;
      end;

      vlNext : { next item, based on the last position }
      begin
        if (Current < MaxLong) then
        begin
          Inc(Current);
          New(P, Init);
          P^.Val := Current;
        end

        else
          P := nil
      end;

      vlPrev : { previous item, based on last position }
      begin
        if (Current > 1) then
        begin
          Dec(Current);
          New(P, Init);
          P^.Val := Current;
        end

        else
          P := nil
      end;

      vlCurrent : { item at the current position }
      begin
        New(P, Init);
        P^.Val := Current;
      end;
    end;

    GetItem := P;
  end;

Function TVirtList.MatchItem(P : PObject): Boolean;
  begin
    { This method attemps to match the item pointed by P to an item
      in the "file". P points to the same object type ast in the
      list box collection.
    }
    if (P <> nil) and (PLong(P)^.Val > 0) and (PLong(P)^.Val <= MaxLong) then
    begin
      Current := PLong(P)^.Val;
      MatchItem := True;
    end

    else
      MatchItem := False;
  end;


{ TMyValidator }

Function TMyValidator.IsValid(const S: string): Boolean;
  begin
    { This is a dummy function to demo how TV validators can be
      used to do post edit processing of a field.
    }
    MessageBox('TValiditors can be used for' + ^M +
               'post-edit control!', nil, mfInformation + mfOKButton);
    IsValid := True;
  end;


{ THeapView }

Constructor THeapView.Init(var Bounds: TRect);
  begin
    TView.Init(Bounds);
    OldMem := 0;
  end;

Procedure THeapView.Draw;
  var
    S: String;
    B: TDrawBuffer;
    C: Byte;

  begin
    OldMem := MemAvail;
    Str(OldMem:Size.X-1, S);
    C := GetColor(2);
    MoveChar(B, ' ', C, Size.X);
    MoveStr(B, S, C);
    WriteLine(0, 0, Size.X, 1, B);
  end;

Procedure THeapView.Update;
  begin
    if (OldMem <> MemAvail) then DrawView;
  end;


{ TCityColl }

Constructor TCityColl.Init;
  begin
    { create a collection of a few city names }
    Inherited Init(15, 10);
    Insert(NewStr('Scotts Valley'));
    Insert(NewStr('Sydney'));
    Insert(NewStr('Copenhagen'));
    Insert(NewStr('London'));
    Insert(NewStr('Paris'));
    Insert(NewStr('Munich'));
    Insert(NewStr('Milan'));
    Insert(NewStr('Tokyo'));
    Insert(NewStr('Stockholm'));
    Insert(NewStr('New York'));
    Insert(NewStr('Redmond'));
    Insert(NewStr('Zurich'));
    Insert(NewStr('Athens'));
    Insert(NewStr('Brussels'));
    Insert(NewStr('Chicago'));
  end;


{ TFileView }

Constructor TFileView.Init(var Bounds: TRect;
                               AHScrollBar, AVScrollBar: PScrollBar);
  begin
    TScroller.Init(Bounds, AHScrollBar, AVScrollBar);
    Options := Options or ofFramed;
    SetLimit(128, LineCount);
  end;

Procedure TFileView.Draw;

  var
    Color: Byte;
    I, Y: Integer;
    B: TDrawBuffer;

  begin
    Color := GetColor(1);

    for Y := 0 to Size.Y - 1 do
    begin
      MoveChar(B, ' ', Color, Size.X);
      i := Delta.Y + Y;

      if (I < LineCount) and (Lines[I] <> nil) then
        MoveStr(B, Copy(Lines[I]^, Delta.X + 1, Size.X), Color);

      WriteLine(0, Y, Size.X, 1, B);
    end;
  end;


{ TFileWindow }

Constructor TFileWindow.Init(Bounds: TRect; WinTitle: String; WindowNo: Word);
  begin
    TbxWindow.Init(Bounds, WinTitle, WindowNo);
    GetExtent(Bounds);
    Interior := MakeInterior(Bounds);
    Insert(Interior);
    Options := Options OR ofTileable;
  end;

Function TFileWindow.MakeInterior(Bounds: TRect): PFileView;

  var
    HScrollBar,
    VScrollBar: PScrollBar;
    R : TRect;
    P : PFileView;

  begin
    R.Assign(Bounds.B.X-1, Bounds.A.Y+1, Bounds.B.X, Bounds.B.Y-1);
    VScrollBar := New(PScrollBar, Init(R));
    VScrollBar^.Options := VScrollBar^.Options or ofPostProcess;
    Insert(VScrollBar);

    R.Assign(Bounds.A.X+1, Bounds.B.Y-1, Bounds.B.X-1, Bounds.B.Y);
    HScrollBar := New(PScrollBar, Init(R));
    HScrollBar^.Options := HScrollBar^.Options or ofPostProcess;
    Insert(HScrollBar);

    Bounds.Grow(-1,-1);
    P := New(PFileView, Init(Bounds, HScrollBar, VScrollBar));
    P^.GrowMode := gfGrowHiX + gfGrowHiY;
    MakeInterior := P;
  end;


{ TPctDialog }

Procedure TPctDialog.Process;
  begin
    { here is where the works gets done, in this case we just
      delay a bit then bump the counter
    }
    if (RunState > 0) and (RunState < cmCancelJob) then
    begin
      if (RunState <> cmPauseJob) then
      begin
        Delay(5);
        Increment;

        if (Count = 500) then
          ChangeMessage('Half way there')
        else if (Count >= Total) then
        begin
          RunState := cmJobComplete;
          Delay(1000);
        end;
      end;
    end;
  end;


{ TPrtDialog }

Procedure TPrtDialog.Process;

  var
    N : String[5];

  begin
    { Here is where the works gets done. In this case we pretend to print
      a line then exit.
    }
    Case RunState of
      cmStartJob : {DO SETUP AND START PRINTING}
        begin
          RunState := cmContinueJob;
        end;

      cmContinueJob : {PRINT NEXT LINE}
        begin
          Inc(X);
          Delay(100); {print line here}
          Str(X,N);
          ChangeMessage('Printing Line ' + N);

          if (X = 250) then
            RunState := cmJobComplete;
        end;

      cmPauseJob : {DO NOTHING}
        ;

      cmCancelJob : {SHUT DOWN}
        ;
    end;
  end;


{ TMyApp }

Constructor TMyApp.Init;

  var
    Event : TEVent;
    R     : TRect;

  begin
    Inherited Init;
    ReadFile('READ.ME');
    { make a heap viewer }
    GetExtent(R);
    R.A.X := R.B.X - 7;
    R.B.X := R.B.X - 1;
    R.B.Y := R.A.Y + 1;
    HeapView := New(PHeapView, Init(R));
    Insert(HeapView);
    FillChar(DlgData, SizeOf(DlgData), 0);
    NewFormatText;
    Event.What := evCommand;
    Event.Command := cmAbout;
    PutEvent(Event);
  end;

Procedure TMyApp.InitDesktop;

  var
    P : Pbx3DToolBar;
    R : TRect;

  begin
    Inherited InitDesktop;
    { setup a 3D tool bar }
    { TOOL BARS SHOULD ALWAYS BE THE FIRST THING INSERTED INTO THE
      DESKTOP!
    }
    R.Assign(0,0, 8,4);
    P := New(Pbx3DToolBar, Init(R, True));
    P^.AddTool('  Save  '^M+'File', CmTool1);
    P^.AddTool('  Open  '^M+'File', CmTool2);
    P^.AddTool('  New   '^M+'File', CmTool3);
    P^.AddTool('  Edit  ', CmTool4);
    P^.AddTool('  Cut   ', CmTool5);
    P^.AddTool(' Paste  ', CmTool6);
    Desktop^.Insert(P);
  end;

Procedure TMyApp.HandleEvent(var Event: TEvent);

  var
    R : TRect;

  begin
    Inherited HandleEvent(Event);

    if Event.What = evCommand then
    begin
      case Event.Command of
        cmNewEditLine   : NewDataEntry;
        cmNewAsciiHex   : NewAsciiHex;
        cmNewFormatText : NewFormatText;
        cmNewText       : NewText;
        cmTestWrite     : WritelnText;
        cmFileOpen      : OpenFile;
        cmNewWin        : NewWindow;
        cmMsgDialog     : MessageDialog;
        cmAbout         : About;
        cmTestPct       : PercentTest;
        cmTestPrt       : PrintTest;
        cmSetup         : Setup;
        cmTest3D        : Test3D;
        cmTestBox1      : TestSelectBox1;
        cmTestBox2      : TestSelectBox2;
        cmTestBox3      : TestVList;
        cmTestPictures  : TestPictures;
        cmTool1         : MessageBox('SAVE TOOL', nil, mfInformation+ mfOkButton);
        cmTool2         : MessageBox('OPEN TOOL', nil, mfInformation+ mfOkButton);
        cmTool3         : MessageBox('NEW TOOL', nil, mfInformation+ mfOkButton);
        cmTool4         : MessageBox('EDIT TOOL', nil, mfInformation+ mfOkButton);
        cmTool5         : MessageBox('CUT TOOL', nil, mfInformation+ mfOkButton);
        cmTool6         : MessageBox('PASTE TOOL', nil, mfInformation+ mfOkButton);
        cmTile          :
          begin
            Desktop^.GetExtent(R);
            Desktop^.Tile(R);
          end;
        cmCascade       :
          begin
            Desktop^.GetExtent(R);
            Desktop^.Cascade(R);
          end;
        cmItem1..cmItem4: { Check mark menu items }
          { set the selected menu item to checked }
          PbxMenuBar(MenuBar)^.ResetMarkers(cmItem1, cmItem4, Event.Command);
      else
        Exit;
      end;

      ClearEvent(Event);
    end;
  end;

Procedure TMyApp.Idle;
  begin
    Inherited Idle;
    HeapView^.Update;
  end;

Procedure TMyApp.InitMenuBar;

  var
    R : TRect;
    S : String[3];

  begin
    S := ' ';

    (* UNCOMMENT THIS TO TRY CHECK MARK MENUS WITH A DIFFERENT MARKER.

    TvMenus.Marker    := 'ON ';
    Tvmenus.NoMarker  := 'OFF';
    TvMenus.MarkerLen := 3;
    S := '   ';
    *)

    GetExtent(R);
    R.B.Y := R.A.Y + 1;
    MenuBar := New(PbxMenuBar, Init(R,
    NewMenu(
      NewSubMenu('~ð~', hcNoContext,
      NewMenu(
        NewItem('~A~bout...',               '',     kbNoKey,  cmAbout,          hcNoContext,
        nil)),
      NewSubMenu('~F~ile', hcNoContext,
      NewMenu(
        NewItem('~O~pen...',                'F3',   kbF3,     cmFileOpen,       hcNoContext,
        NewLine(
        NewItem('E~x~it',                   'Alt-X',kbAltX,   cmQuit,           hcNoContext,
        nil)))),
      NewSubMenu('~W~indow', hcNoContext,
      NewMenu(
        NewItem('~N~ext',                   'F6',   kbF6,     cmNext,           hcNoContext,
        NewItem('~Z~oom',                   'F5',   kbF5,     cmZoom,           hcNoContext,
        NewItem('~T~ile',                   '',     kbNoKey,  cmTile,           hcNoContext,
        NewItem('~C~ascade',                '',     kbNoKey,  cmCascade,        hcNoContext,
        nil))))),
      NewSubMenu('~T~est', hcNoContext,
      NewMenu(
        NewItem('~D~ata Entry...',          '',     kbNoKey,  cmNewEditLine,    hcNoContext,
        NewItem('Picture ~V~alidators...',  '',     kbNoKey,  cmTestPictures,   hcNoContext,
        NewItem('~M~essage Dialog...',      '',     kbNoKey,  cmMsgDialog,      hcNoContext,
        NewItem('Standard File ~V~iewer',   '',     kbNoKey,  cmNewWin,         hcNoContext,
        NewItem('~T~ext Display Window',    '',     kbNoKey,  cmNewText,        hcNoContext,
        NewItem('~F~ormatted File Viewer',  '',     kbNoKey,  cmNewFormatText,  hcNoContext,
        NewItem('~A~scii/Hex Editor',       '',     kbNoKey,  cmNewAsciiHex,    hcNoContext,
        NewItem('~P~rogress Dialog',        '',     kbNoKey,  cmTestPct,        hcNoContext,
        NewItem('P~r~int Dialog',           '',     kbNoKey,  cmTestPrt,        hcNoContext,
        NewItem('~3~D Controls',            '',     kbNoKey,  cmTest3D,         hcNoContext,
        NewItem('~W~riteln to Window',      '',     kbNoKey,  cmTestWrite,      hcNoContext,
        NewItem('Multi-Select ~L~ist Box',  '',     kbNoKey,  cmTestBox1,      hcNoContext,
        NewItem('Paired List ~B~oxes',      '',     kbNoKey,  cmTestBox2,      hcNoContext,
        NewItem('Virtual List Boxes',       '',     kbNoKey,  cmTestBox3,      hcNoContext,
        NewSubMenu('~C~heck Marks', hcNoContext,
        NewMenu(
          NewMarkedItem(S + 'Item 1',       '',     kbNoKey,  cmItem1,          hcNoContext,
          NewMarkedItem(S + 'Item 2',       '',     kbNoKey,  cmItem2,          hcNoContext,
          NewMarkedItem(S + 'Item 3',       '',     kbNoKey,  cmItem3,          hcNoContext,
          NewMarkedItem(S + 'Item 4',       '',     kbNoKey,  cmItem4,          hcNoContext,
          nil))))),
        nil)))))))))))))))),
      NewSubMenu('~O~ptions', hcNoContext,
      NewMenu(
        NewItem('~S~etup',                  '',     kbNoKey,  cmSetup,          hcNoContext,
        nil)),
      nil)))))
    )));

    PbxMenuBar(MenuBar)^.SetMarker(cmItem1);
  end;

Procedure TMyApp.InitStatusLine;

  var
    R : TRect;

  begin
    GetExtent(R);
    R.A.Y := R.B.Y - 1;
    StatusLine := New(PStatusLine, Init(R,
      NewStatusDef(0, $FFFF,
        NewStatusKey('', kbF10, cmMenu,
        NewStatusKey('~Alt-X~ Exit', kbAltX, cmQuit,
        NewStatusKey('~Alt-F3~ Close', kbAltF3, cmClose,
        nil))),
      nil)
    ));
  end;

Procedure TMyApp.ReadFile(FileToRead : PathStr);

  var
    F : Text;
    N : string[5];
    S : String;
    Err : Integer;

  begin
    ShowBusy;
    BufSize := 0;
    LineCount := 0;
    Assign(F, FileToRead);
    {$I-}
    Reset(F);
    Err := IOResult;
    {$I+}

    if (Err <> 0) then
    begin
      HideBusy;
      Str(Err, N);
      S := 'COULD NOT READ FILE ' + ^M +
           FileToRead + ^M +
           ' I/O ERROR #' + N;
      MessageBox(S, nil, mfError or mfOkButton);
      EXIT;
    end;

    BufName := FileToRead;
    GetMem(Buf, MaxBuf);
    FillChar(Buf^, MaxBuf, 0);

    while not Eof(F) and (LineCount < MaxLines) do
    begin
      Readln(F, S);
      Lines[LineCount] := NewStr(S);
      Inc(LineCount);

      if (BufSize + Length(S) < MaxBuf - 2) then
      begin
        if (S = '') then
        begin
          Buf^[BufSize-1]:= #13;
          Buf^[BufSize]  := #13;
          Inc(BufSize);
        end

        else
        begin
          Move(S[1], Buf^[BufSize], Byte(S[0]));
          Inc(BufSize, Length(S));
          Buf^[BufSize]  := #32;
          Inc(BufSize);
        end;
      end;
    end;

    Close(F);
    HideBusy;
  end;

Procedure TMyApp.OpenFile;

  var
    FileName  : PathStr;
    {$IFDEF USE_NEW_FILE_DIALOG}
    Dialog    : PbxFileDialog;
    {$ELSE}
    Dialog    : PFileDialog;
    {$ENDIF}

  begin
    {$IFDEF USE_NEW_FILE_DIALOG}
    Dialog := New(PbxFileDialog, Init('*.*', 'Open a File',
                                      'File~n~ame',
                                      fdOpenButton + fdHelpButton, 100));
    {$ELSE}
    Dialog := New(PFileDialog, Init('*.*', 'Open a File',
                                    'File~n~ame',
                                    fdOpenButton + fdHelpButton, 100));
    {$ENDIF}

    if ExecView(Dialog) <> cmCancel then
    begin
      Dialog^.GetFileName(FileName);
      EnableCommands([cmNewWin..cmNewAsciiHex]);
      DisableCommands([cmFileOpen]);
      ReadFile(FileName);
    end;

    Dispose(Dialog, Done);
  end;

procedure TMyApp.NewWindow;
  var
    Window : PFileWindow;
    R : TRect;

  begin
    Inc(WinCount);
    R.Assign(0, 0, 45, 13);
    R.Move(Random(34), Random(11));
    Window := New(PFileWindow, Init(R, 'Standard Viewer: ' + BufName, wnNoNumber));
    DeskTop^.Insert(Window);
  end;

Procedure TMyApp.MessageDialog;

  var
    Dialog : PbxMessageDialog;

  begin
    { All these messages will be displayed when the dialog is executed.
      The dialog will size it self to fit the buttons and all text.
    }
    New(Dialog, Init(mfInformation + mfOKButton));
    Dialog^.AddMessage('');
    Dialog^.AddMessage(' -------------- TMessageDialog -------------- ');
    Dialog^.AddMessage(' It is simple to add text, just make a call');
    Dialog^.AddMessage(' to the TMessageDialog.AddMessage method! The');
    Dialog^.AddMessage(' message box will size itself to the amount');
    Dialog^.AddMessage(' of text that is added.');
    Dialog^.AddMessage(' -------------------------------------------- ');
    ExecuteDialog(Dialog, nil);
  end;

Procedure TMyApp.Setup;

  var
    Dialog  : PDialog;
    R       : TRect;
    Control : PView;
    Command : Word;
    MState  : Word;

  begin
    { make a dialog box to get the mouse toggle option }
    R.Assign(0,0,53,12);
    New(Dialog, Init(R, 'Setup'));

    with Dialog^ do
    begin
      Options := Options OR ofCentered;
      R.Assign(2,2,51,3);
      Control := New(PCheckboxes, Init(R,
                   NewSItem('Turn mouse cursor off when keyboard is used',Nil)));
      PCluster(Control)^.Value := 0;
      Insert(Control);

      R.Assign(10,8,18,10);
      Insert(New(PButton, Init(R, '~O~K', cmOK, bfDefault)));

      R.Assign(29,8,41,10);
      Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));

      SelectNext(False);

      { get current state }
      if ToggleMouse then
        MState := 1
      else
        MState := 0;

      { execute the dialog and set mouse toggle flag as specified }
      if (ExecuteDialog(Dialog, @MState) <> cmCancel) then
      begin
        if (MState = 1) then
          SetMouseToggle(True)
        else
          SetMouseToggle(False);
      end;
    end;
  end;

Procedure TMyApp.PercentTest;

  var
    Dialog : PPctDialog;

  begin
    New(Dialog, Init('', 'Your Message Here', 1000,
                     mfOKPauseCancel OR mfMessageLine));
    ExecuteDialog(Dialog, nil);
  end;

Procedure TMyApp.PrintTest;

  var
    Dialog : PPrtDialog;

  begin
    New(Dialog, Init('PRINT', '', mfOKPauseCancel OR mfMessageLine));
    ExecuteDialog(Dialog, nil);
  end;

Procedure TMyApp.Test3D;

  var
    Dialog  : Pbx3DDialog;
    R       : TRect;
    P       : PView;
    Bar     : PScrollBar;
    List    : PCityColl;

  begin
    { create a 3D dialog box with all possible 3D controls }
    R.Assign(0,0,60,20);
    New(Dialog, Init(R, '3D Controls'));

    with Dialog^ do
    begin
      Options := Options or ofCentered;

      { 3D input lines }
      R.Assign(3,3, 14,4);
      P := New(PInputLine, Init(R, 15));
      P^.Options := P^.Options or ofFramed;
      Insert(P);

      R.Assign(3,2, 11,3);
      Insert(New(PLabel, Init(R, '~T~ext 2', P)));

      R.Assign(15,3, 18,4);
      Insert(New(Pbx3DHistory, Init(R, PInputLine(P), 10)));

      R.Assign(3,6, 14,7);
      P := New(PInputLine, Init(R, 15));
      P^.Options := P^.Options or ofFramed;
      Insert(P);

      R.Assign(3,5, 11,6);
      Insert(New(PLabel, Init(R, '~T~ext 1', P)));

      { 3D Check Boxes }
      R.Assign(3,9, 15,12);

      P := New(PCheckBoxes, Init(R,
        NewSItem('~R~ed',
        NewSItem('~G~reen',
        NewSItem('~B~lue', nil)))));
      P^.Options := P^.Options or ofFramed;
      Insert(P);
      PCheckBoxes(P)^.SetButtonState(1, False);

      R.Assign(3,8, 14,9);
      Insert(New(PLabel, Init(R, '~C~heck Box', P)));

      { 3D Radio Buttons }
      R.Assign(3,14, 15,18);

      P := New(PRadioButtons, Init(R,
        NewSItem('~N~orth',
        NewSItem('~E~ast',
        NewSItem('~S~outh',
        NewSItem('~W~est', nil))))));
      P^.Options := P^.Options or ofFramed;
      Insert(P);

      R.Assign(3,13, 14,14);
      Insert(New(PLabel, Init(R, '~R~adio Btn', P)));

      { 3D List Box }
      R.Assign(40,3, 41,10);
      New(Bar, Init(R));
      Insert(Bar);

      R.Assign(22,3, 39,10);
      P := New(PbxLinkedBox, Init(R, 1, Bar, 5001));
      P^.Options := P^.Options or ofFramed;
      Insert(P);
      List := New(PCityColl, Init);
      PListBox(P)^.NewList(List);

      R.Assign(22,2, 32,3);
      Insert(New(PLabel, Init(R, 'List Box', P)));

      R.Assign(22,12, 39,13);
      P := New(PbxLinkedLine, Init(R, 15, 5001));
      P^.Options := P^.Options or ofFramed;
      Insert(P);

      { Static Text }

      R.Assign(22,15, 39,16);
      P := New(PStaticText, Init(R, 'Static Text'));
      P^.Options := P^.Options or ofFramed;
      Insert(P);

      { 3D Buttons }
      R.Assign(46,2,58,5);
      Insert(New(Pbx3DButton, Init(R, 'OK', cmOK, bfDefault)));

      R.Assign(46,5,58,8);
      Insert(New(Pbx3DButton, Init(R, '~C~ancel', cmCancel, bfNormal)));

      R.Assign(46,8,58,12);
      Insert(New(Pbx3DButton, Init(R, '~O~pen'^M+'File', 5000, bfNormal)));

      R.Assign(46,12,58,16);
      Insert(New(Pbx3DButton, Init(R, '~S~ave'^M+'File', 5000, bfNormal)));

      { 3D Buttons }
      R.Assign(46,16,58,19);
      Insert(New(Pbx3DButton, Init(R, '~N~ew', cmNone, bfNormal)));
      Application^.DisableCommands([cmNone]);

      SelectNext(False);
    end;

    ExecuteDialog(Dialog, nil);
    Dispose(List, Done);
  end;

Procedure TMyApp.About;

  var
    Dialog : PbxMessageDialog;

  begin
    New(Dialog, Init(mfInformation + mfOKButton));

    with Dialog^ do
    begin
      AddMessage('');
      AddMessage('               ÉÍÍÍÍÍ»    ');
      AddMessage('           ÚÄÄÄÐÄÄÄÄÄÐÄÄÄ¿');
      AddMessage('           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
      AddMessage('           ³ TV TOOL BOX ³');
      AddMessage('           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
      AddMessage(^C + 'Version 2.0');
      AddMessage('');
      AddMessage('  Tools for Turbo Vision Programmers  ');
      AddMessage('');
      AddMessage(^C + 'Copyright 1992,1993 Richard Hansen');
      AddMessage(^C + 'All rights reserved.');
      AddMessage('');
    end;

    ExecuteDialog(Dialog, nil);
  end;

Procedure TMyApp.TestSelectBox1;

  var
    Dialog  : PDialog;
    ListBox : PbxCheckListBox;
    List    : PbxCollection;
    Bar     : PScrollBar;
    R       : TRect;

  begin
    { MULTI-SELECT LIST BOX }
    { Multi-select list boxes put [X] in front of each selected entry }
    R.Assign(13,5,50,18);
    Dialog := New(PDialog, Init(R, 'Multi-Select List Box'));

    R.Assign(34,1,35,9);
    Bar := New(PScrollBar, Init(R));
    Dialog^.Insert(Bar);

    List := New(PbxCollection, Init(15, 5));
    List^.Insert(New(PbxSelectStr, Init('Scotts Valley')));
    List^.Insert(New(PbxSelectStr, Init('Sydney')));
    List^.Insert(New(PbxSelectStr, Init('Copenhagen')));
    List^.Insert(New(PbxSelectStr, Init('London')));
    List^.Insert(New(PbxSelectStr, Init('Paris')));
    List^.Insert(New(PbxSelectStr, Init('Munich')));
    List^.Insert(New(PbxSelectStr, Init('Milan')));
    List^.Insert(New(PbxSelectStr, Init('Tokyo')));
    List^.Insert(New(PbxSelectStr, Init('Stockholm')));
    List^.Insert(New(PbxSelectStr, Init('New York')));
    List^.Insert(New(PbxSelectStr, Init('Redmond')));
    List^.Insert(New(PbxSelectStr, Init('Zurich')));
    List^.Insert(New(PbxSelectStr, Init('Athens')));
    List^.Insert(New(PbxSelectStr, Init('Brussels')));
    List^.Insert(New(PbxSelectStr, Init('Chicago')));

    R.Assign(2,1,34,9);
    ListBox := New(PbxCheckListBox, Init(R, 1, Bar));
    ListBox^.NewList(List);
    { select a couple of items, collections are numbered from zero }
    ListBox^.SetSelectSet([0,4]);
    Dialog^.Insert(ListBox);

    R.Assign(13,10,23,12);
    Dialog^.Insert(New(PButton, Init(R, 'OK', cmOK, bfDefault)));

    ExecuteDialog(Dialog, nil);
    Dispose(List, Done);
  end;

Procedure TMyApp.TestSelectBox2;

  var
    Dialog  : PDialog;
    ListBox : PbxPairedListBox;
    List1   : PbxCollection;
    List2   : PbxCollection;
    Bar     : PScrollBar;
    R       : TRect;
    i       : Word;
    S       : String;

  begin
    { PAIRED LIST BOXES }
    { paired list boxes move items from one box to the other }
    R.Assign(19,5,61,18);
    Dialog := New(PDialog, Init(R, 'Paired List Boxes'));

    R.Assign(19,1,20,9);
    Bar := New(PScrollBar, Init(R));
    Dialog^.Insert(Bar);
    R.Assign (2,1,19,9);
    ListBox := New(PbxPairedListBox, Init(R, 1, Bar));
    Dialog^.Insert(ListBox);
    List1 := New(PbxCollection, Init(15, 5));
    List1^.Insert(New(PbxSelectStr, Init('Scotts Valley')));
    List1^.Insert(New(PbxSelectStr, Init('Sydney')));
    List1^.Insert(New(PbxSelectStr, Init('Copenhagen')));
    List1^.Insert(New(PbxSelectStr, Init('London')));
    List1^.Insert(New(PbxSelectStr, Init('Paris')));
    List1^.Insert(New(PbxSelectStr, Init('Munich')));
    List1^.Insert(New(PbxSelectStr, Init('Milan')));
    List1^.Insert(New(PbxSelectStr, Init('Tokyo')));
    List1^.Insert(New(PbxSelectStr, Init('Stockholm')));
    List1^.Insert(New(PbxSelectStr, Init('New York')));
    List1^.Insert(New(PbxSelectStr, Init('Redmond')));
    List1^.Insert(New(PbxSelectStr, Init('Zurich')));
    List1^.Insert(New(PbxSelectStr, Init('Athens')));
    List1^.Insert(New(PbxSelectStr, Init('Brussels')));
    List1^.Insert(New(PbxSelectStr, Init('Chicago')));
    ListBox^.NewList(List1);

    R.Assign(39,1,40,9);
    Bar := New(PScrollBar, Init(R));
    Dialog^.Insert(Bar);
    R.Assign(22,1,39,9);
    ListBox := New(PbxPairedListBox, Init(R, 1, Bar));
    Dialog^.Insert(ListBox);
    List2 := New(PbxCollection, Init(15,5));
    ListBox^.NewList(List2);

    R.Assign(16,10,26,12);
    Dialog^.Insert(New(PButton, Init(R, 'OK', cmOK, bfDefault)));

    Dialog^.SelectNext (False);

    if ExecuteDialog(Dialog, nil) <> cmCancel then
    begin
      { Send the selected items to any TbxTextWindows open on the desktop }
      S := '';
      Message(Desktop, evBroadcast, cmDisplayStr, @S);
      S := '<<< HERE IS WHAT YOU JUST SELECTED >>>';
      Message(Desktop, evBroadcast, cmDisplayStr, @S);

      for i := 1 to List2^.Count do
      begin
        S := PbxObject(List2^.At(i - 1))^.GetText(255);
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
      end;
    end

    else
    begin
      S := '';
      Message(Desktop, evBroadcast, cmDisplayStr, @S);
      S := '<<< YOU PRESSED ESCAPE? >>>';
      Message(Desktop, evBroadcast, cmDisplayStr, @S);
    end;

    Dispose(List1, Done);
    Dispose(List2, Done);
  end;

Procedure TMyApp.WritelnText;

  var
    W : PbxTextWindow;
    R : TRect;

  begin
    { WRITELN TO A TEXT WINDOW }
    R.Assign(0, 0, 40, 13);
    W := New(PbxTextWindow, Init(R, 'Standard Output', wnNoNumber,
                                 ofVScrollBar or ofHScrollBar, 25));
    W^.Options := W^.Options or OfCentered;
    DeskTop^.Insert(W);

    { redirect standard writes }
    AssignOutput(Output, W);
    Rewrite(Output);
    Writeln('THIS TEXT IS DISPLAYED THROUGH THE STANDARD WRITE AND');
    Writeln('WRITELN STATEMENTS.');
    Writeln('THE STANDARD OUTPUT HAS BEEN REDIRECTED TO THIS WINDOW.');
    Writeln('OPEN THE PAIRED LIST BOX, SELECT ONE OR TWO ITEMS AND');
    Writeln('THEN PRESS THE "OK" BUTTON.');
    Writeln('');
    Writeln('IF YOU OPEN THE DATA ENTRY TEST DIALOG, YOUR ENTRIES');
    Writeln('WILL BE ECHOED HERE.');
    { restore standard output }
    Close(Output);
    Assign(Output, '');
    Rewrite(Output);
  end;

Procedure TMyApp.NewText;

  var
    R     : TRect;
    W     : PbxTextWindow;

  begin
    { A TEXT WINDOW FOR EASY OUTPUT }
    Inc(WinCount);
    R.Assign(0, 0, 60, 13);
    R.Move(Random(19), Random(10));
    W := New(PbxTextWindow, Init(R, 'Text Window', WinCount,
                                 ofVScrollBar or ofHScrollBar, 25));
    W^.Options := W^.Options OR ofTileable;
    DeskTop^.Insert(W);

    W^.Write('');
    W^.Write(' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ ');
    W^.Write(' ³ THIS MAY NOT LOOK LIKE MUCH HERE, BUT CHECK OUT THE   ³ ');
    W^.Write(' ³ EXAMPLE CODE AND YOU WILL SEE THAT THIS IS A TEXT     ³ ');
    W^.Write(' ³ DISPLAY WINDOW WITHOUT A CUSTOMIZED DRAW METHOD. JUST ³ ');
    W^.Write(' ³ THE THING FOR A LITTLE QUICK AND EASY TEXT DISPLAY!   ³ ');
    W^.Write(' ³ OPEN THE DATA ENTRY DIALOG, ENTER SOME DATA, AND HIT  ³ ');
    W^.Write(' ³ "OK" WHEN THIS WINDOW IS OPEN.                        ³ ');
    W^.Write(' ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ');
    W^.Write('');
  end;

Procedure TMyApp.NewFormatText;

  var
    W   : PbxWindow;
    R   : TRect;
    Bar : PScrollBar;

  begin
    { FORMATTED TEXT WINDOW }
    Inc(WinCount);
    R.Assign(0, 0, Desktop^.Size.X, Desktop^.Size.Y);
    W := New(PbxWindow, Init(R, 'Formatted Text Scroller: ' + BufName, WinCount));
    W^.Options := W^.Options OR ofTileable OR ofCentered;

    W^.GetExtent(R);
    R.Assign(R.B.X-1, R.A.Y+1, R.B.X, R.B.Y-1);
    Bar := New(PScrollBar, Init(R));
    Bar^.Options := Bar^.Options or ofPostProcess;
    W^.Insert(Bar);

    W^.GetExtent(R);
    R.Grow(-1, -1);
    W^.Insert(New(PbxFormattedTextScroller, Init(R, Bar, Buf, BufSize)));

    DeskTop^.Insert(W);
  end;


Procedure TMyApp.NewAsciiHex;

  var
    Window: PbxAsciiHexEditor;
    R     : TRect;

  begin
    { ASCII/HEX EDIT BUFFER }
    Inc(WinCount);
    R.Assign(1,1, 64,16);
    Window := New(PbxAsciiHexEditor, Init(R, 'Ascii/Hex Editor: ' + BufName,
                                          WinCount, ofPosIndicator,
                                          Buf, MaxBuf));
    Window^.Options := Window^.Options OR ofTileable;
    DeskTop^.Insert(Window);
  end;

Procedure TMyApp.NewDataEntry;

  var
    Dialog  : PbxEntryDialog;
    R       : TRect;
    E       : PbxEditLine;
    L       :  PLabel;
    S       : String;
    SpinBar : PbxSpinBar;
    Slider  : PbxSlider;

  begin
    { DATA ENTRY WITH EDIT MASKS }
    TvInput.SetDateDefaults;
    R.Assign(0,0, 75,17);
    Dialog := New(PbxEntryDialog, Init(R, 'Data Entry Test'));

    With Dialog^ do
    begin
      Options := Options or ofCentered;

      { date entry using string field }
      {S1}
      R.Assign(2,2, 14,3);
      E := New(PbxEditLine, Init(R, '99/99/9999'));
      Insert(E);
      R.Assign(2,1, 19,2);
      L := New(PLabel, Init(R, '~D~ate String', E));
      Insert(L);
      E^.AddLabel(L);

      { scrolling phone numbers }
      {S2}
      R.Assign(2,4, 19,5);
      E := New(PbxEditLine, Init(R, '(999) 999-9999 [9999]'));
      Insert(E);
      R.Assign(2,3, 19,4);
      L := New(PLabel, Init(R, 'Phone Number 1', E));
      Insert(L);
      E^.AddLabel(L);

      {S3}
      R.Assign(2,6, 26,7);
      E := New(PbxEditLine, Init(R, '(999) 999-9999 [9999]'));
      Insert(E);
      R.Assign(2,5, 19,6);
      L := New(PLabel, Init(R, 'Phone Number 2', E));
      Insert(L);
      E^.AddLabel(L);

      { locked phone number }
      {S4}
      R.Assign(2,8, 19,9);
      E := New(PbxEditLine, Init(R, '(999) 999-9999 [9999]'));
      Insert(E);
      R.Assign(2,7, 19,8);
      L := New(PLabel, Init(R, '~L~ocked Field', E));
      Insert(L);
      E^.AddLabel(L);
      E^.Lock;

      { unsigned integer, no range checking}
      {I1}
      R.Assign(2,10, 10,11);
      E := New(PbxWordEdit, Init(R, '99999', 0, 0));
      Insert(E);
      E^.SetEditFlag(dfLJustify, True);
      R.Assign(2,9, 19,10);
      L := New(PLabel, Init(R, 'U~n~signed Integer', E));
      Insert(L);
      E^.AddLabel(L);

      { signed integer, range -1000 to 1000 }
      {I2}
      R.Assign(2,12, 11,13);
      E := New(PbxIntegerEdit, Init(R, '#####', -1000, 1000));
      Insert(E);
      E^.SetEditFlag(dfRJustify, True);
      R.Assign(2,11,  19,12);
      L := New(PLabel, Init(R, '~S~igned Integer', E));
      Insert(L);
      E^.AddLabel(L);

      { hex integer }
      {H1}
      R.Assign(30,2, 37,3);
      E := New(PbxHexEdit, Init(R, '&&&&&', 0, 0));
      Insert(E);
      R.Assign(30,1,  47,2);
      Insert(New(PLabel, Init(R, '~H~exadecimal', E)));

      { password fields }
      {S5}
      R.Assign(30,4, 40,5);
      E := New(PbxEditLine, Init(R, 'XXXXXXXX'));
      E^.SetEditFlag(dfHide, True);
      Insert(E);
      R.Assign(30,3, 47,4);
      Insert(New(PLabel, Init(R, '~P~assword Fields', E)));

      { alternate padding chars }
      {S6}
      R.Assign(30,6, 40,7);
      E := New(PbxEditLine, Init(R, 'XXXXXXXX'));
      E^.PadChar := '_';
      E^.SetEditFlag(dfTrim, True);
      Insert(E);

      { upper case only }
      {S7}
      R.Assign(30,8, 42,9);
      E := New(PbxEditLine, Init(R, 'UUUUUUUUUU'));
      Insert(E);
      E^.SetEditFlag(dfRequired, True);
      R.Assign(30,7, 53,8);
      Insert(New(PLabel, Init(R, 'Any Char Force ~U~pper', E)));

      { alphanumeric upper case only }
      {S8}
      R.Assign(30,10, 42,11);
      E := New(PbxEditLine, Init(R, 'llllllllll'));
      Insert(E);
      E^.SetEditFlag(dfLJustify or dfTrim, True);
      R.Assign(30,9, 53,10);
      Insert(New(PLabel, Init(R, '~A~lphanumeric Force Lower', E)));

      { floating point (REAL) }
      {R1}
      R.Assign(30,12, 41,13);
      E := New(PbxRealEdit, Init(R, '####.###', 0.0, 0.0));
      Insert(E);
      R.Assign(30,11, 53,12);
      Insert(New(PLabel, Init(R, '~F~loating point', E)));

      { floating point (DOUBLE) as Money }
      {D1}
      {$IFOPT N+}
      R.Assign(55,2, 67,3);
      E := New(PbxDoubleEdit, Init(R, '$#####.##', 0.0, 50000.0));
      Insert(E);
      R.Assign(55,1, 68,2);
      Insert(New(PLabel, Init(R, '~M~oney', E)));
      {$ENDIF}

      R.Assign(55,4, 69,5);
      E := New(PbxEditLine, Init(R, 'XXXXXXXXXXXX'));
      Insert(E);
      E^.Options := E^.Options or ofValidate;
      E^.SetValidator(New(PMyValidator, Init));
      R.Assign(55,3, 70,4);
      Insert(New(PLabel, Init(R, 'With ~V~alidator', E)));

      { date entry using date field }
      R.Assign(55,6, 65,7);
      E := New(PbxDateEdit, Init(R, 'mm/dd/yy'));
      Insert(E);
      E^.SetEditFlag(dfDefaults, True);
      R.Assign(55,5, 63,6);
      L := New(PLabel, Init(R, 'Date 1', E));
      Insert(L);
      E^.AddLabel(L);

      R.Assign(55,8, 67,9);
      E := New(PbxDateEdit, Init(R, 'DD/MM/YYYY'));
      Insert(E);
      E^.Options := E^.Options or ofValidate;
      R.Assign(55,7, 63,8);
      L := New(PLabel, Init(R, 'Date 2', E));
      Insert(L);
      E^.AddLabel(L);

      { SX1 }
      { a slider }
      R.Assign(55,10, 67,12);
      Slider := New(PbxSlider, Init(R, 1, 50, 'Slow', 'Fast'));
      Insert(Slider);

      R.Assign(55,9, 70,10);
      Insert(New(PLabel, Init(R, 'Slider Control', Slider)));

      { SX2 }
      { a vertical spinner }
      R.Assign(61,14, 62,16);
      SpinBar := New(PbxSpinBar, Init(R));
      SpinBar^.SetParams(0, -50,50, 1,5);
      R.Assign(55,14, 60,15);
      Insert(New(PbxSpinEdit, Init(R, '###', SpinBar)));
      Insert(SpinBar);

      { SX3 }
      { a horizontal spinner }
      R.Assign(69,14, 71,15);
      SpinBar := New(PbxSpinBar, Init(R));
      SpinBar^.SetParams(0, -50,50, 1,1);
      R.Assign(63,14, 68,15);
      Insert(New(PbxSpinEdit, Init(R, '###', SpinBar)));
      Insert(SpinBar);

      R.Assign(55,13, 68,14);
      Insert(New(PStaticText, Init(R, 'Spin Controls')));

      R.Assign(15,14, 23,16);
      Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));

      R.Assign(30,14, 44,16);
      Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));

      SelectNext(False);
    end;

    if (DlgData.X = 0) then
    with DlgData do
    begin
      Inc(X);
      S1 := '06/01/1993';
      S2 := '(999) 999-9999 [9999]';
      S3 := '(999) 999-9999 [9999]';
      S4 := '(999) 999-9999 [9999]';
      I1 := 123;
      I2 := 456;
      H1 := $FF;
      S5 := 'DEMO';
      S6 := 'TEST';
      S7 := 'ABCDE';
      S8 := 'wxyz';
      R1 := 99.99;
      {$IFOPT N+}
      D1 := 12345.67;
      {$ENDIF}
      S9 := 'VALIDATE ME';
      Dt1.Year := 78;
      Dt1.Month:= 2;
      Dt1.Day  := 6;

      Dt2.Year := 1980;
      Dt2.Month:= 8;
      Dt2.Day  := 9;
      SX1 := 25;
      SX2 := -10;
      SX3 := 10;
    end;

    if (ExecuteDialog(Dialog, @DlgData) <> cmCancel) then
    begin
      with DlgData do
      begin
        { Dump all the data to any TbxTextWindows open on the desktop }
        Message(Desktop, evBroadcast, cmDisplayClr, nil);
        S := '<<< HERE IS WHAT YOU JUST ENTERED IN THE DIALOG BOX >>>';
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
        S := '';
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
        Message(Desktop, evBroadcast, cmDisplayStr, @S1);
        Message(Desktop, evBroadcast, cmDisplayStr, @S2);
        Message(Desktop, evBroadcast, cmDisplayStr, @S3);
        Str(I1, S);
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
        Str(I2, S);
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
        Str(H1, S);
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
        Message(Desktop, evBroadcast, cmDisplayStr, @S5);
        Message(Desktop, evBroadcast, cmDisplayStr, @S6);
        Message(Desktop, evBroadcast, cmDisplayStr, @S7);
        Message(Desktop, evBroadcast, cmDisplayStr, @S8);
        Str(R1:9:3, S);
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
        {$IFOPT N+}
        Str(D1:9:3, S);
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
        {$ENDIF}
        Message(Desktop, evBroadcast, cmDisplayStr, @S9);
        S := DateToDateString(Dt1, 'mm/dd/yy');
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
        S := DateToDateString(Dt2, 'DD/MM/YYYY');
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
        Str(SX1:3, S);
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
        Str(SX2:3, S);
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
        Str(SX3:3, S);
        Message(Desktop, evBroadcast, cmDisplayStr, @S);
      end;
    end;
  end;

Procedure TMyApp.TestPictures;
  var
    Dlg : PDialog;
    R   : TRect;
    Control : PInputLine;

  begin
    { TEST SOME PICTURES VALIDATORS }
    R.Assign(0,0,80,23);
    New(Dlg, Init(R, 'Picture Validator Test'));
    Dlg^.Options := Dlg^.Options or ofCentered;

    R.Assign(2,2,18,3);
    Control := New(PInputLine, Init(R, 14));
    Control^.Options := $1405;
    Dlg^.Insert(Control);
    Control^.SetValidator(New(PPXPictureValidator, Init(UnsignedPic2, True)));
    R.Assign(2,1,20,2);
    Dlg^.Insert(New(PLabel, Init(R, 'Number 1', Control)));
    R.Assign(19,2,48,3);
    Dlg^.Insert(New(PStaticText, Init(R, 'Unsigned Int, Commas Required')));

    R.Assign(2,4,18,5);
    Control := New(PInputLine, Init(R, 14));
    Control^.Options := $1405;
    Dlg^.Insert(Control);
    Control^.SetValidator(New(PPXPictureValidator, Init(SignedPic1, True)));
    R.Assign(2,3,20,4);
    Dlg^.Insert(New(PLabel, Init(R, 'Number 2', Control)));
    R.Assign(19,4,46,5);
    Dlg^.Insert(New(PStaticText, Init(R, 'Signed Int, Commas Optional')));

    R.Assign(2,6,18,7);
    Control := New(PInputLine, Init(R, 14));
    Control^.Options := $1005;
    Dlg^.Insert(Control);
    Control^.SetValidator(New(PPXPictureValidator, Init(MoneyPic2, True)));
    R.Assign(2,5,10,6);
    Dlg^.Insert(New(PLabel, Init(R, 'Money 1', Control)));
    R.Assign(19,6,30,7);
    Dlg^.Insert(New(PStaticText, Init(R, '$ Required')));


    R.Assign(2,8,18,9);
    Control := New(PInputLine, Init(R, 14));
    Control^.Options := $1405;
    Dlg^.Insert(Control);
    Control^.SetValidator(New(PPXPictureValidator, Init(MoneyPic1, True)));
    R.Assign(2,7,10,8);
    Dlg^.Insert(New(PLabel, Init(R, 'Money 2', Control)));
    R.Assign(19,8,48,9);
    Dlg^.Insert(New(PStaticText, Init(R, '$ Optional')));

    R.Assign(2,10,12,11);
    Control := New(PInputLine, Init(R, 8));
    Control^.Options := $1405;
    Dlg^.Insert(Control);
    Control^.SetValidator(New(PPXPictureValidator, Init(DatePic1, True)));
    R.Assign(2,9,9,10);
    Dlg^.Insert(New(PLabel, Init(R, 'Date 1', Control)));
    R.Assign(19,10,31,11);
    Dlg^.Insert(New(PStaticText, Init(R, '2 Digit Year')));

    R.Assign(2,12,14,13);
    Control := New(PInputLine, Init(R, 10));
    Control^.Options := $1405;
    Dlg^.Insert(Control);
    Control^.SetValidator(New(PPXPictureValidator, Init(DatePic2, True)));
    R.Assign(2,11,9,12);
    Dlg^.Insert(New(PLabel, Init(R, 'Date 2', Control)));
    R.Assign(19,12,36,13);
    Dlg^.Insert(New(PStaticText, Init(R, '2 or 4 Digit Year')));

    R.Assign(2,14,18,15);
    Control := New(PInputLine, Init(R, 14));
    Dlg^.Insert(Control);
    Control^.SetValidator(New(PPXPictureValidator, Init(TimePic1, True)));
    R.Assign(2,13,7,14);
    Dlg^.Insert(New(PLabel, Init(R, 'Time', Control)));
    R.Assign(19,14,45,15);
    Dlg^.Insert(New(PStaticText, Init(R, 'HH:MM:SS, Seconds Optional')));

    R.Assign(2,16,18,17);
    Control := New(PInputLine, Init(R, 14));
    Dlg^.Insert(Control);
    Control^.SetValidator(New(PPXPictureValidator, Init(PhonePic1, True)));
    R.Assign(2,15,10,16);
    Dlg^.Insert(New(PLabel, Init(R, 'Phone 1', Control)));
    R.Assign(19,16,37,17);
    Dlg^.Insert(New(PStaticText, Init(R, 'Area Code Optional')));

    R.Assign(2,18,18,19);
    Control := New(PInputLine, Init(R, 14));
    Dlg^.Insert(Control);
    Control^.SetValidator(New(PPXPictureValidator, Init(PhonePic2, True)));
    R.Assign(2,17,10,18);
    Dlg^.Insert(New(PLabel, Init(R, 'Phone 2', Control)));
    R.Assign(19,18,37,19);
    Dlg^.Insert(New(PStaticText, Init(R, 'Area Code Required')));

    R.Assign(49,2,62,3);
    Control := New(PInputLine, Init(R, 12));
    Dlg^.Insert(Control);
    Control^.SetValidator(New(PPXPictureValidator, Init(SSNPic, True)));
    R.Assign(49,1,67,2);
    Dlg^.Insert(New(PLabel, Init(R, 'Social Security #', Control)));

    R.Assign(49,4,64,5);
    Control := New(PInputLine, Init(R, 13));
    Dlg^.Insert(Control);
    Control^.SetValidator(New(PPXPictureValidator, Init(FilenamePic, True)));
    R.Assign(49,3,58,4);
    Dlg^.Insert(New(PLabel, Init(R, 'Filename', Control)));

    R.Assign(49,6,69,7);
    Control := New(PInputLine, Init(R, 35));
    Control^.Options := $1005;
    Dlg^.Insert(Control);
    Control^.SetValidator(New(PPXPictureValidator, Init(FirstCharUpPic, True)));
    R.Assign(49,5,68,6);
    Dlg^.Insert(New(PLabel, Init(R, 'Uppercase 1st Char', Control)));

    R.Assign(23,20,31,22);
    Dlg^.Insert(New(PButton, Init(R, '~O~K', cmCancel, bfDefault)));

    R.Assign(41,20,51,22);
    Dlg^.Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    Dlg^.SelectNext(False);
    ExecuteDialog(Dlg, nil);
  end;

Procedure TMyApp.TestVList;
  begin
    { VIRTUAL LIST BOX }
    ExecuteDialog(New(PVirtDialog, Init), nil);
  end;


VAR
  MyApp : TMyApp;

begin
  MyApp.Init;
  MyApp.Run;
  MyApp.Done;
end.

