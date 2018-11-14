{
        SCRSAV.PAS - A ScreenSaving unit (version 5) for TurboVision 2.0


        This ScreenSaving-unit for TurboVision 2.0 is (c) by Edwin Groothuis
        You are allowed to use this unit in your programs if you agree to
        these two rules:

        1. You give me proper credit in the documentation of the program.
        2. You tell me you're using this unit.

        If you don't agree with these two rules, you're not allowed to
        use it!

        How to use this ScreenSaving-unit:

        Initialisation:

        - Add the ScrSav-unit to the uses-command.
        - Make the (global) variable ScreenSaver as PScreenSaver
        - In the Initialisation of an Application, put the following
          line behind the Inherited Init:
            Inherited Init;
            ScreenSaver:=New(PScreenSaver,Init(0,1));

          The zero means ScreenSaver #0 and the one means that the timeout
          time is 1 minute.

        Heartbeat:
        To tell the ScreenSaver that the user isn't idle at this moment,
        put the following line in the Application^.GetEvent:
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

        CountDown:
        To let the ScreenSaver know the user is idle at this moment, put
        the following line in the Application^.Idle:
          Inherited Idle;
          if ScreenSaver<>nil then
            ScreenSaver^.CountDown;

        Options:
        What is a ScreenSaver without options? You can change the
        options by calling the ScreenSaver^.Options-procedure. The user
        gets a nice options-dialog and he can change some settings. If
        you have added more ScreenSaver-modules, please add them in the
        constants ScreenSaverNames and ScreenSaverProcs. Make sure you
        put them in alphabetic order!


        Now start your application. After 60 seconds your screen will
        go blank. There are several ScreenSavers designed by me, if
        you have created more, I would like to have a copy of them ;-)

        A small note about the use of a delay in the ScreenSaver^.Update:
        It's not nice to use the Delay-function of the Crt-unit. Instead
        of using that, you'd better check if a certain time (100 ms, 200 ms
        and so on) has elapsed. See the StarFieldScreenSaver.Update-function
        for an example of it.

        Send all your suggestions/money/cards (I love to get cards from
        people who are using my programs) to:

        Edwin Groothuis                ECA-BBS
        Johann Strausslaan 1           tel. +31-40-550352 (up to 14k4/V42b)
        5583ZA Aalst-Waalre            FTN: 2:284/205@fidonet
        The Netherlands                     115:3145/102@pascal-net
                                       request SCRSAV for the last version!
}


{$define WORM}
{$define MESSAGE}
{$define STANDARD}
{$define MOVINGSTAR}
{$define STARFIELD}


unit      ScrSav;

interface

uses      Views,Objects,Crt;

type      PScreenSaver=^TScreenSaver;
          TScreenSaver=object(TObject)
                         constructor Init(SaverNumber:Word;Time:word);
                         Constructor Load(Var S:TStream);
                         destructor Done; Virtual;
                         procedure Activate;
                         procedure Deactivate;
                         procedure HeartBeat;
                         procedure CountDown;
                         procedure Update;virtual;
                         function  Saving:boolean;
                         procedure Options;
                         procedure Enable(b:boolean);
                         Procedure Store(Var S:TStream); Virtual;
                       private
                         SaverNo:Word;
                         W:PView;
                         LastBeat:longint;
                         _Saving:boolean;
                         SavingTime:word;
                         WasEnabled,
                         Enabled:boolean;
                         Testing:boolean;
                       end;


type      PStandardScreenSaver=^TStandardScreenSaver;
          TStandardScreenSaver=object(TView)
                                 constructor Init;
                                 procedure Draw;virtual;
                               end;


Const
  RScreenSaver: TStreamRec = (
    ObjType: 23114;
    VmtLink: Ofs(TypeOf(TScreenSaver)^);
    Load: @TScreenSaver.Load;
    Store: @TScreenSaver.Store);

Procedure RegisterScreenSaver;

{$ifdef WORM}
function  MakeWormScreenSaver      :PStandardScreenSaver;
{$endif}
{$ifdef MESSAGE}
function  MakeMessageScreenSaver   :PStandardScreenSaver;
{$endif}
{$ifdef MOVINGSTAR}
function  MakeMovingStarScreenSaver:PStandardScreenSaver;
{$endif}
{$ifdef STARFIELD}
function  MakeStarFieldScreenSaver :PStandardScreenSaver;
{$endif}
{$ifdef STANDARD}
function  MakeStandardScreenSaver  :PStandardScreenSaver;
{$endif}


implementation

uses      Drivers,App,Dialogs,InpLong,MsgBox;

const     NumScreenSavers=
{$ifdef WORM}
          1+
{$endif}
{$ifdef MESSAGE}
          1+
{$endif}
{$ifdef MOVINGSTAR}
          1+
{$endif}
{$ifdef STARFIELD}
          1+
{$endif}
{$ifdef STANDARD}
          1+
{$endif}
          0;


{ Please note that the names of the screensaver must be in alphabetical
  order. This is because a TStringCollection is a derivative of a
  TSortedCollection. }
const     ScreenSaverNames:array[0..NumScreenSavers] of string[20]=
                            (
{$ifdef MESSAGE}
                             'Message',
{$endif}
{$ifdef MOVINGSTAR}
                             'Moving Star',
{$endif}
{$ifdef STANDARD}
                             'Standard',
{$endif}
{$ifdef STARFIELD}
                             'Starfield',
{$endif}
{$ifdef WORM}
                             'Worm',
{$endif}
                             ''
                             );
          ScreenSaverProcs:array[0..NumScreenSavers] of function:
                            PStandardScreenSaver=(
{$ifdef MESSAGE}
                                                  MakeMessageScreenSaver,
{$endif}
{$ifdef MOVINGSTAR}
                                                  MakeMovingStarScreenSaver,
{$endif}
{$ifdef STANDARD}
                                                  MakeStandardScreenSaver,
{$endif}
{$ifdef STARFIELD}
                                                  MakeStarfieldScreenSaver,
{$endif}
{$ifdef WORM}
                                                  MakeWormScreenSaver,
{$endif}
                                                  nil);

const     cmTest=1000;
          wdUp =0;
          wdUpRight=1;
          wdRight=2;
          wdDownRight=3;
          wdDown=4;
          wdDownLeft=5;
          wdLeft=6;
          wdUpLeft=7;

{----------------------------------------------------------------------------}
{ Object-definitions of the screensave-routines. Note that these are not the
  screensaverobject!                                                         }
{$ifdef MOVINGSTAR}
type      PMovingStarScreenSaver=^TMovingStarScreenSaver;
          TMovingStarScreenSaver=object(TStandardScreenSaver)
                                   constructor Init;
                                   procedure Draw;virtual;
                                 private
                                   dx,dy,x,y:array[1..10] of integer;
                                   LastUpdate:longint;
                                 end;
{$endif}

{$ifdef WORM}
          PWormScreenSaver=^TWormScreenSaver;
          TWormScreenSaver=object(TStandardScreenSaver)
                             constructor Init;
                             procedure Draw;virtual;
                           private
                             LastUpdate:longint;
                             Display:Array[1..40,1..25] Of Byte;
                             X,Y:Byte;
                             Direction:Byte;
                           end;
{$endif}

{$ifdef STARFIELD}
          PStarFieldScreenSaver=^TStarFieldScreenSaver;
          TStarFieldScreenSaver=object(TStandardScreenSaver)
                                   constructor Init;
                                   procedure Draw;virtual;
                                 private
                                   states:array[1..7] of char;
                                   starstate,x,y:array[1..10] of integer;
                                   LastUpdate:longint;
                                 end;
{$endif}

{$ifdef MESSAGE}
  PMessageScreenSaver=^TMessageScreenSaver;
  TMessageScreenSaver=object(TStandardScreenSaver)
                        constructor Init;
                        procedure Draw;virtual;
                        procedure SetMessage(Var s:string);
                      private
                        Message:string;
                        X,Y:integer;
                        LastUpdate:longInt;
                        Colour:byte;
                      end;
{$endif}

{----------------------------------------------------------------------------}
{ Object-definition of the screensaver                                       }
type      PScrSavDialog=^TScrSavDialog;
          TScrSavDialog=object(TDialog)
                          UserSavingTime:PInputLine;
                          LB:PListBox;
                          TestButton:PButton;
                          Timer:PRadioButtons;

                          procedure HandleEvent(var E:TEvent);virtual;
                        end;

var       CurrentScreenSaver:PScreenSaver;

{----------------------------------------------------------------------------}
{----------------------------------------------------------------------------}
{ Initialise the ScreenSaver.
  Notes:
    *18.2 is because the timertick goes 18.2 times/second                    }
constructor TScreenSaver.Init(SaverNumber:Word;Time:word);
begin
  Inherited Init;
  _Saving:=false;
  SavingTime:=round(Time*60*18.2);
  HeartBeat;
  W:=ScreenSaverProcs[SaverNumber];
  Enabled:=true;
  Testing:=false;
  CurrentScreenSaver:=@Self;
  SaverNo:=SaverNumber;
end;

{----------------------------------------------------------------------------}
{ Disposes the ScreenSaver                                                   }
destructor TScreenSaver.Done;
begin
  if W<>nil then
    Dispose(W,Done);
  CurrentScreenSaver:=nil;
end;

{----------------------------------------------------------------------------}
{ Activate the ScreenSaver
  First, allocate the memory for the Screen.
  Second, copy the contents of the screen to the allocated memory.           }
procedure TScreenSaver.Activate;
begin
  if Enabled then
  begin
    _Saving:=true;
    HideMouse;
    Asm             { hide cursor. It is automaticly unhidden by TurboVision }
      Mov Ah,1
      Mov CX,100h
      Int 010H
    End;
    if W<>nil then
      Application^.Insert(W);
    Update;
  end;
end;

{----------------------------------------------------------------------------}
{ Deactivate the ScreenSaver.
  Second, dispose the memory allocated
  Third, give the application a Redraw                                       }
procedure TScreenSaver.Deactivate;
begin
  if W<>nil then
    Application^.Delete(W);
  Application^.Redraw;
  _Saving:=false;
  if Testing then
  begin
    Testing:=false;
    Enabled:=WasEnabled;
  end;
  ShowMouse;
end;

{----------------------------------------------------------------------------}
{ The use is doing something, so stop the CountDown
  First, deactivate the ScreenSaver if Saving
  Second, update the timer                                                   }
procedure TScreenSaver.HeartBeat;
var       TT:longint absolute $40:$6c;
begin
  if Saving then
    Deactivate;
  LastBeat:=TT;
end;

{----------------------------------------------------------------------------}
{ CountDown to the SavingTime
  If not yet saving, look if it's time to save. If saving, update the screen }
procedure TScreenSaver.CountDown;
var       TT:longint absolute $40:$6c;
begin
  if not Saving then
  begin
    if (TT-LastBeat>SavingTime) then
      Activate;
  end else
    Update;
end;

{----------------------------------------------------------------------------}
{ Update
  Update the ScreenSaving-procedure. Override this one if you want a custom
  ScreenSaver                                                                }
procedure TScreenSaver.Update;
begin
  if Enabled then
    if W<>nil then
      W^.Draw;
end;

{----------------------------------------------------------------------------}
{ Saving
  Returns true if the Screen is being Saved.                                 }
function  TScreenSaver.Saving:boolean;
begin
  Saving:=_Saving;
end;


{----------------------------------------------------------------------------}
{ Read & Write the ScreenSaver-screens
  This part is added by Michael Turner (115:4401/4@PascalNet or
                                        2:254/80@FidoNet)
  Thanks Micheal!                                                            }
constructor TScreenSaver.Load;
begin
  S.Read(SaverNo,SizeOf(SaverNo));
  S.Read(Enabled,SizeOf(Enabled));
  S.Read(SavingTime,SizeOf(SavingTime));
  _Saving:=False;
  HeartBeat;
  W:=ScreenSaverProcs[SaverNo];
  Testing:=False;
  CurrentScreenSaver:=@Self;
end;

procedure TScreenSaver.Store;
begin
  S.Write(SaverNo,SizeOf(SaverNo));
  S.Write(Enabled,SizeOf(Enabled));
  S.Write(SavingTime,SizeOf(SavingTime));
end;

{----------------------------------------------------------------------------}
{----------------------------------------------------------------------------}
{ Handles the events for the options-dialog. The only exception that is
  really handled by this procedure is the command cmTest: Test the
  screensaver                                                                }
procedure TScrSavDialog.HandleEvent(var E:TEvent);
var       V:longint;
          W:Word;
begin
  if E.What<>evNothing then
  begin
    if Timer^.State and sfFocused<>0 then
    begin
      Inherited HandleEvent(E);
      Timer^.GetData(w);
      UserSavingTime^.SetState(sfDisabled,false);
      if W<>6 then
      begin
        case W of
          0: v:=60;
          1: v:=120;
          2: v:=180;
          3: v:=300;
          4: v:=600;
          5: v:=900;
        end;
        UserSavingTime^.SetData(v);
        UserSavingTime^.Draw;
        UserSavingTime^.SetState(sfDisabled,true);
      end;
    end;
    if E.What=evCommand then
      if E.Command=cmTest then
      begin
        MessageBox(ScreenSaverNames[LB^.Focused],nil,mfOkButton);
        Dispose(CurrentScreenSaver^.W,Done);
        CurrentScreenSaver^.W:=ScreenSaverProcs[LB^.Focused];
        CurrentScreenSaver^.WasEnabled:=CurrentScreenSaver^.Enabled;
        CurrentScreenSaver^.Enabled:=true;
        CurrentScreenSaver^.Testing:=true;
        CurrentScreenSaver^.Activate;
      end;
  end;
  Inherited HandleEvent(E);
end;


{----------------------------------------------------------------------------}
{ Options
  Pops up a dialogbox with several functions, like enable/disable, time to
  save, which screensaver etc                                                }
procedure TScreenSaver.Options;
 function  MakeDialog : PScrSavDialog;
 var       Dlg : PScrSavDialog;
           R : TRect;
           Control : PView;
 begin
   R.Assign(4, 1, 49, 16);
   New(Dlg, Init(R, 'Screen Saver'));
   Dlg^.Options:=Dlg^.Options or ofCentered;

   R.Assign(2, 3, 20, 10);
   Dlg^.Timer := New(PRadioButtons, Init(R,
   NewSItem('1 minute',NewSItem('2 minutes',
   NewSItem('3 minutes',NewSItem('5 minutes',
   NewSItem('10 minutes',NewSItem('15 minutes',
   NewSItem('user defined', Nil)))))))));
   Dlg^.Insert(Dlg^.Timer);

   R.Assign(1, 2, 13, 3);
   Dlg^.Insert(New(PLabel, Init(R, 'Saving time', Control)));

   R.Assign(6, 10, 20, 11);
   Dlg^.UserSavingTime := New(PInputLong, Init(R, 12, 0, 3600, 0));
   Dlg^.Insert(Dlg^.UserSavingTime);

   R.Assign(42, 3, 43, 7);
   Control := New(PScrollBar, Init(R));
   Dlg^.Insert(Control);

   R.Assign(22, 3, 42, 7);
   Dlg^.LB:= New(PListBox, Init(R, 1, PScrollbar(Control)));
   Dlg^.Insert(Dlg^.LB);

   R.Assign(21, 2, 33, 3);
   Dlg^.Insert(New(PLabel, Init(R, 'Which saver', Control)));

   R.Assign(22, 8, 42, 10);
   Control := New(PRadioButtons, Init(R,
   NewSItem('Enable saver',NewSItem('Disable saver', Nil))));
   Dlg^.Insert(Control);

   R.Assign(3, 12, 13, 14);
   Dlg^.Insert(New(PButton, Init(R, 'O~K~', cmOK, bfDefault)));

   R.Assign(17, 12, 27, 14);
   Dlg^.Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

   R.Assign(32, 12, 42, 14);
   Dlg^.TestButton := New(PButton, Init(R, 'Test', cmTest, bfNormal));
   Dlg^.Insert(Dlg^.TestButton);

   Dlg^.SelectNext(False);
   MakeDialog := Dlg;
 end;
type      TListBoxRec = record    {<-- omit if TListBoxRec is defined elsewhere}
                          PS : PStringCollection;
                          Selection : Integer;
                        end;
var       d:PScrSavDialog;
          DataRec : record
                      SavingTime : Word;
                      UserSavingTime : LongInt;
                      WhichSaver : TListBoxRec;
                      Enabled : Word;
                    end;
          s:string;
          i:word;
          Changed:Boolean;
begin
  d:=MakeDialog;
  DataRec.SavingTime:=6;
  DataRec.UserSavingTime:=round(SavingTime/(60*18.2));
  if Enabled then
    DataRec.Enabled:=0
  else
    DataRec.Enabled:=1;
  d^.UserSavingTime^.SetState(sfDisabled,true);
  DataRec.WhichSaver.PS:=New(PStringCollection,Init(5,5));
  for i:=0 to NumScreenSavers-1 do
    DataRec.WhichSaver.PS^.Insert(NewStr(ScreenSaverNames[i]));
  DataRec.WhichSaver.Selection:=0;
  d^.SetData(DataRec);
  d^.LB^.Draw;
  D^.LB^.FocusItem(SaverNo);
  if (SavingTime Shr 10)=0 Then
  begin
    SavingTime:=SavingTime Or 1024;
    Changed:=True;
  end else
    Changed:=False;
  if (desktop^.execview(d))=cmOk then
  begin
    d^.GetData(DataRec);
    SaverNo:=D^.LB^.Focused;
    SavingTime:=round(DataRec.UserSavingTime*60*18.2);
    Enabled:=DataRec.Enabled=0;
    Dispose(CurrentScreenSaver^.W,Done);
    CurrentScreenSaver^.W:=ScreenSaverProcs[d^.LB^.Focused];
  end else begin
    if Changed then
      SavingTime:=SavingTime and 255;
    Dispose(CurrentScreenSaver^.W,Done);
    CurrentScreenSaver^.W:=ScreenSaverProcs[SaverNo];
  end;
  dispose(DataRec.WhichSaver.PS,Done);
  dispose(d,done);
end;

{----------------------------------------------------------------------------}
{ Enable or disable the screensaver                                          }
procedure TScreenSaver.Enable(b:boolean);
begin
  if b then
    Enabled:=true
  else
    Enabled:=false;
end;


{$ifdef STANDARD}
{----------------------------------------------------------------------------}
{----------------------------------------------------------------------------}
function   MakeStandardScreenSaver:PStandardScreenSaver;
var        S:PStandardScreenSaver;
begin
  S:=new(PStandardScreenSaver,Init);
  MakeStandardScreenSaver:=S;
end;

{----------------------------------------------------------------------------}
constructor TStandardScreenSaver.Init;
var         R:TRect;
begin
  Application^.GetExtent(R);
  Inherited Init(R);
end;

{----------------------------------------------------------------------------}
procedure TStandardScreenSaver.Draw;
begin
  ClearScreen;
end;
{$endif}

{$ifdef MOVINGSTAR}
{----------------------------------------------------------------------------}
{ The rest are examples of different ScreenSavers.                           }
{----------------------------------------------------------------------------}
{----------------------------------------------------------------------------}
function   MakeMovingStarScreenSaver:PStandardScreenSaver;
var        S:PMovingStarScreenSaver;
begin
  S:=new(PMovingStarScreenSaver,Init);
  MakeMovingStarScreenSaver:=S;
end;

{----------------------------------------------------------------------------}
constructor TMovingStarScreenSaver.Init;
var         i:byte;
begin
  Inherited Init;
  Randomize;
  for i:=1 to 10 do
  begin
    x[i]:=random(ScreenWidth div 2)+(ScreenWidth div 4);
    y[i]:=random(ScreenHeight div 2)+(ScreenHeight div 4);
    dx[i]:=random(2);if dx[i]=0 then dx[i]:=-1;
    dy[i]:=random(2);if dy[i]=0 then dy[i]:=-1;
  end;
end;

{----------------------------------------------------------------------------}
procedure TMovingStarScreenSaver.Draw;
var       i:byte;
          TT:longint absolute $40:$6c;
          B:TDrawBuffer;
begin
  if TT-LastUpdate>2 then
  begin
    LastUpdate:=TT;
    ClearScreen;
    for i:=1 to 10 do
    begin
      if x[i] in [0,ScreenWidth-3]  then dx[i]:=-dx[i];
      if y[i] in [0,ScreenHeight-3] then dy[i]:=-dy[i];
      inc(x[i],dx[i]);inc(y[i],dy[i]);
      MoveChar(B,'*',i,1);
      WriteLine(x[i],y[i],1,1,B);
    end;
  end;
end;
{$endif}


{$ifdef WORM}
{----------------------------------------------------------------------------}
{----------------------------------------------------------------------------}
function   MakeWormScreenSaver:PStandardScreenSaver;
var        S:PWormScreenSaver;
begin
  S:=new(PWormScreenSaver,Init);
  MakeWormScreenSaver:=S;
end;

{----------------------------------------------------------------------------}
constructor TWormScreenSaver.Init;
begin
  Inherited Init;
  FillChar(Display,SizeOf(Display),0);
  Randomize;
  Direction:=Random(8);
  X:=20;
  Y:=13;
end;

{----------------------------------------------------------------------------}
procedure TWormScreenSaver.Draw;
  const     States                : Array [0..8] Of Char =
                                     (' ','°','°','±','±','²','²','Û','Û');
  var       TT:longint absolute $40:$6c;

  procedure Cycle;
  var       AX,AY:byte;
  begin
    for AX:=1 to 40 do
      for AY:=1 to 25 do
        if Display[AX,AY]>0 then Dec(Display[AX,AY]);
  end;

  procedure PutNewHead;
    procedure UpdateHead;
    begin
      case Direction of
        wdUp       : Dec(X);
        wdUpRight  : begin Dec(X);Inc(Y);end;
        wdRight    : Inc(Y);
        wdDownRight: begin Inc(X);Inc(Y);end;
        wdDown     : Inc(X);
        wdDownLeft : begin Inc(X);Dec(Y);end;
        wdLeft     : Dec(Y);
        wdUpLeft   : begin Dec(X);Dec(Y);end;
      end;
    end;

  var     StoreX,StoreY:byte;
          DOK:boolean;
          StoreDirection:byte;
  begin
    if (Y=1) or (X=1) or (Y=25) or (X=40) or (random(100)<5) then
    begin
      StoreX:=X;
      StoreY:=Y;
      StoreDirection:=Direction;
      repeat
        X:=StoreX;
        Y:=StoreY;
        Direction:=random(8);
        case StoreDirection of
          wdUp        : DOK:=Direction<>wdDown;
          wdUpRight   : DOK:=Direction<>wdDownLeft;
          wdRight     : DOK:=Direction<>wdLeft;
          wdDownRight : DOK:=Direction<>wdUpLeft;
          wdDown      : DOK:=Direction<>wdUp;
          wdDownLeft  : DOK:=Direction<>wdUpRight;
          wdLeft      : DOK:=Direction<>wdRight;
          wdUpLeft    : DOK:=Direction=wdDownRight;
        end;
        UpdateHead;
      until (Y<>0) and (X<>0) and (Y<>26) and (X<>41) and DOK;
    end else
      UpdateHead;
    Display[X,Y]:=8;
  end;

  procedure UpdateDisplay;
  var       D:TDrawBuffer;
            AX,AY:byte;
  begin
    if ScreenHeight=43 then
      ClearScreen;
    for AY:=0 to 24 do
    begin
      for AX:=0 to 39 do
      begin
        D[AX*2]:=Word(Ord(States[Display[Succ(AX),Succ(AY)]])) Or ($100);
        D[Succ(AX*2)]:=D[AX*2];
      end;
      if ScreenHeight<>50 then
        WriteLine(0,AY,ScreenWidth,1,D)
      else
        WriteLine(0,AY*2,ScreenWidth,2,D);
    end;
  end;

begin
  if TT-LastUpdate>2 then
  begin
    LastUpdate:=TT;
    Cycle;
    PutNewHead;
    UpdateDisplay;
  end;
end;
{$endif}


{$ifdef STARFIELD}
{----------------------------------------------------------------------------}
{----------------------------------------------------------------------------}
function   MakeStarfieldScreenSaver:PStandardScreenSaver;
var        S:PStarFieldScreenSaver;
begin
  S:=new(PStarFieldScreenSaver,Init);
  MakeStarfieldScreenSaver:=S;
end;

{----------------------------------------------------------------------------}
constructor TStarFieldScreenSaver.Init;
var         i:byte;
            R:TRect;
begin
  Inherited Init;
  Randomize;
  States[1]:='ú';States[2]:='ù';States[3]:='';
  States[4]:='o';States[5]:='*';States[6]:='';States[7]:=' ';
  for i:=1 to 10 do
  begin
    x[i]:=random(ScreenWidth-1)+2;
    y[i]:=random(ScreenHeight-1)+2;
    starstate[i]:=random(7)+1;
  end;
end;

{----------------------------------------------------------------------------}
procedure TStarFieldScreenSaver.Draw;
var       i:byte;
          TT:longint absolute $40:$6c;
          B:TDrawBuffer;
begin
  if TT-LastUpdate>2 then
  begin
    LastUpdate:=TT;
    ClearScreen;
    for i:=1 to 10 do
    begin
      MoveChar(B,States[StarState[i]],i,1);
      WriteLine(x[i],y[i],1,1,B);
      StarState[i]:=(StarState[i] mod 7)+1;
      if StarState[i]=1 then
      begin
        x[i]:=random(ScreenWidth)+1;
        y[i]:=random(ScreenHeight)+1;
      end;
    end;
  end;
end;
{$endif}


{$ifdef MESSAGE}
{----------------------------------------------------------------------------
  This part is added by Michael Turner (115:4401/4@PascalNet or
                                        2:254/80@FidoNet)
  Thanks Micheal!
{----------------------------------------------------------------------------}
function MakeMessageScreenSaver:PStandardScreenSaver;
var      S:PMessageScreenSaver;
begin
  S:=New(PMessageScreenSaver,Init);
  MakeMessageScreenSaver:=S;
end;


constructor TMessageScreenSaver.Init;
begin
  inherited Init;
  randomize;
  X:=ScreenWidth;
  Y:=Random(23);
  Message:='The screen is being saved. Press nearly any key or move the mouse to continue';
                         {This string must not be longer than the screen width}
  Colour:=LightGreen;
end;

procedure TMessageScreenSaver.Draw;
var       TT:longint absolute $40:$6c;
          B:TDrawBuffer;
begin
  if TT-LastUpdate>2 then
  begin
    LastUpdate:=TT;
    ClearScreen;
    if (Length(Message+' ')+X)>ScreenWidth then
    begin
      MoveStr(B,Copy(Message+' ',1,ScreenWidth-X),Colour);
      WriteLine(X,Y,ScreenWidth-X,1,B);
    end else
      if X<0 then
      begin
        MoveStr(B,Copy(Message+' ',Abs(X),Length(Message+' ')-Abs(X)),Colour);
        WriteLine(0,Y,Length(Message+' ')-Abs(X),1,B);
      end else begin
        MoveStr(B,Message+' ',Colour);
        WriteLine(X,Y,Length(Message+' '),1,B);
      end;
      Dec(X);
      if (X<0) and (Abs(X)>Length(Message+' ')) then
      begin
        X:=ScreenWidth;
        Y:=Random(23);
      end;
  end;
end;

procedure TMessageScreenSaver.SetMessage;
begin
  if Length(S)>76 then
    S[0]:=Chr(76);
  Message:=S;
end;
{$endif}

procedure RegisterScreenSaver;
begin
  RegisterType(RScreenSaver);
end;

begin
  CurrentScreenSaver:=nil;
end.
