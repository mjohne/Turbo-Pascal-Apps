{ Turbo Calendar }
{ Copyright (c) 1990 by Borland International, Inc. }

{$F+,O+,X+}
Unit CalUnit;

{ This unit provide a objects for creating a simple calendar.  Common
  usage in a aplication would be:

  Procedure ShowCalendar;
    Var
      CalendarWindow: PCalendarWindow;
    Begin
      CalendarWindow := New(PCalendarWindow, Init(New(PDayDialog,Init)));
      DeskTop^.Insert(CalendarWindow);
    End;

 The DayDialog object has four virtual methods that me wish to be change
to fit the needs of a specific users application.

    Function IsSpecial(Day, Month, Year: Word): Boolean;
    Procedure GetActiveDays;
    Function ReadDay: PCollection;
    Procedure WriteDay(Collection: PCollection);

}
 Interface
   uses Drivers, Objects, App, Views, Dos, Dialogs;
   Const
{ Default file name use to hold appointments.                       }
     CalendarFile = 'calendar.dat';
     DaysInMonth:Array[1..12] of byte =
       (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
     MonthStr:Array[1..12] of String =
       ('Januar    ',
        'Februar   ',
        'M„rz      ',
        'April     ',
        'Mai       ',
        'Juni      ',
        'Juli      ',
        'August    ',
        'September ',
        'Oktober   ',
        'November  ',
        'Dezember  ');
     BaseCommand      = 150;
     brHourFocused    = 1 + BaseCommand;
     brMessageSelect  = 2 + BaseCommand;
   Type
   St = String[80];
   TString = ^St;
   RDate = Record
     KeyDate: String[10];
     Message: Array[1..24] of String[80];
   End;

   PMessageInputLine = ^TMessageInputLine;
   TMessageInputLine = Object(TInputLine)
     Constructor Init(var R: Trect; AMaxLen: Integer; Parent: PDialog);
     Procedure HandleEvent(var Event: TEvent); Virtual;
   End;

   PHourCollection = ^THourCollection;
   THourCollection = Object(TCollection)
     Constructor Init;
     Procedure FreeItem(Item: Pointer); Virtual;
   End;

   PHourListBox = ^THourListBox;
   THourListBox = Object(TListBox)
     Procedure FocusItem(Item: Integer); Virtual;
     Procedure HandleEvent(var Event: TEvent); Virtual;
     Destructor Done; Virtual;
   End;

   PDayDialog = ^TDayDialog;
   TDayDialog = Object(TDialog)
{ ActiveCollection hold all dates that have appointments.                }
     ActiveCollection: PStringCollection;

     HourListBox: PHourListBox;
     MessageInputLine: PMessageInputLine;
     Constructor Init;
     Destructor Done; Virtual;

{ IsSpecial returns true if there is a appointment associated with       }
{  the date.                                                             }
     Function IsSpecial(Day, Month, Year: Word): Boolean; Virtual;

{ GetActiveDays enters all active days into ActiveCollections.           }
     Procedure GetActiveDays; Virtual;

{ ReadDay reads all appointments for one day into a Collection.          }
{ ReadDay is called by SetNewDay.                                        }
     Function ReadDay: PCollection; Virtual;

     Procedure SetNewDay(Day, Month, Year: Word);

{ WriteDay saves all appointments for one day to Calendar.Dat}
      Procedure WriteDay(Collection: PCollection); Virtual;

     Private
     Function FStr(I: Integer): String;
   End;

   PCalendarView = ^TCalendarView;
   TCalendarView = object(TView)
     Year, Month, Days : Word;
     CurYear, CurMonth, CurDay : Word;
     DayDialog: PDayDialog;
     Constructor Init(Bounds: TRect; D: PDayDialog);
     Destructor Done; Virtual;
     procedure HandleEvent(var Event: TEvent); Virtual;
     Procedure Draw; Virtual;
   end;

   PCalendarWindow = ^TCalendarWindow;
   TCalendarWindow = object(TWindow)
     CalendarView: PCalendarView;
     Constructor Init(DayDialog:PDayDialog);
   End;

 Implementation

{-------------- TMessageInputLine ------}
      Constructor TMessageInputLine.Init(var R: Trect; AMaxLen: Integer; Parent: PDialog);
        Begin
          Inc(R.A.X,5);
          TInputLine.Init(R, AMaxLen);
          GrowMode := gfGrowHiX;
          EventMask := EventMask or evBroadcast;
        End;

      Procedure TMessageInputLine.HandleEvent(var Event: TEvent);
        Const
          UpOrDown = [80, 81, 72, 73];  {A set of UP, PgUp, Down, PgDn}
        Begin
          if ((Event.What = evBroadcast) and (Event.Command = brHourFocused)) or
             ((Event.What = evKeyDown) and ((Event.KeyCode = kbEnter) or (Event.ScanCode in UpOrDown))) then
            Begin
              Message(Owner, evBroadcast, brMessageSelect, Data);
              Owner^.Delete(@Self);  {Remove Self from the Dialog Box}
              If (Event.What = evKeyDown) and (Event.ScanCode in UpOrDown) then
                Message(TopView, Event.What, Event.Command, Event.InfoPtr);
            End;
          TInputLine.HandleEvent(Event);
        End;

{-------------- THourCollection --------}
      Constructor THourCollection.Init;
        Begin
          TCollection.Init(24,1);
        End;

      Procedure THourCollection.FreeItem(Item: Pointer);
        Begin
          Dispose(TString(Item));  {This procedure must be used if using a }
        End;                       {collection on non Objects.             }

{-------------- THourListBox -----------}
      Destructor THourListBox.Done;
        Begin
          If List<>Nil then
            Dispose(List, Done);
          TListBox.Done;
        End;

      Procedure THourListBox.FocusItem(Item: Integer);
        Begin
         { Send message to notify TMessageInputLine that an item has been }
         { focused. (see TMessageInputLine.HandleEvent)                   }
          Message(Owner, evBroadcast, brHourFocused, List^.At(Item));
          TListBox.FocusItem(Item);
        End;

     Procedure THourListBox.HandleEvent(var Event: TEvent);
       Const
         LeftOrRight = [75, 77]; {Set of Left and Right arrow keys }
       Var
         R, R1: TRect;
       Begin
         If (Event.What=evKeyDown) and ((Event.CharCode<>#0) or (Event.ScanCode in LeftOrRight)) then
           Begin
             GetBounds(R);
             With PDayDialog(Owner)^.MessageInputLine^ do
               Begin
                 { Assign the inputline with the data in the collection of }
                 { the listbox.  The copy is used to ignore the first 6    }
                 { charaters.                                              }
                 Data^ := Copy(TString(List^.At(Focused))^, 6, 80);
                 { Change the location of the inputline to be at the same  }
                 { position as the highlight bar of the listbox.           }
                 R.A.Y:=Focused-TopItem+1;
                 R.B.Y:=R.A.Y+1;
                 R.A.X:=R.A.X+5;
                 ChangeBounds(R);
               end;
             If (Event.ScanCode in LeftOrRight) or (Event.KeyCode=KbEnter) then
               Event.KeyCode:=kbHome;
             { Display the inputline by inserting it into the dialog box   }
             Owner^.Insert(PDayDialog(Owner)^.MessageInputLine);
             { Send the message whether to inputline                       }
             Message(TopView, Event.What, Event.Command, Event.InfoPtr);
             Exit;
           End;
         TListBox.HandleEvent(Event);
         If (Event.What=evBroadCast) and (Event.Command=brMessageSelect) then
           Begin
             { If the inputline is finish replace the currently focused    }
             { item with the newly enter information from the inputline.   }
             { see TMessageInputLine.HandleEvent for the sending of this   }
             { message.                                                    }
             TString(List^.At(Focused))^:=Copy(TString(List^.At(Focused))^, 1, 5)+TString(Event.InfoPtr)^;
             { Redraw the view after the change.                           }
             DrawView;
           End;
       End;

{-------------- TDayDialog -------------}
      Constructor TDayDialog.Init;
        Var
           R:TRect;
           ScrollBar: PScrollBar;
        Begin
          R.Assign(10,10,43,21);
          TDialog.Init(R, ' ');
          Flags := Flags or (wfZoom+wfGrow); {Allow dialog to be resizeable}
          GetExtent(R);
          R.A.X:=1;
          R.A.Y:=1;
          R.B.Y:=2;
          Dec(R.B.X,2);
          MessageInputLine:=New(PMessageInputLine, Init(R, 80, @Self));
          GetExtent(R);
          Inc(R.A.Y);
          Dec(R.B.X);
          Dec(R.B.Y);
          R.A.X:=R.B.X-1;
          Scrollbar := New(PScrollBar, Init(R));
          Insert(Scrollbar);
          GetExtent(R);
          Inc(R.A.X);
          Inc(R.A.Y);
          Dec(R.B.X,2);
          Dec(R.B.Y);
          HourListBox := New(PHourListBox, Init(R, 1, ScrollBar));
          HourListBox^.GrowMode:=gfGrowHiX+gfGrowHiY;
          Insert(HourListBox);
          GetActiveDays;
        End;

      Destructor TDayDialog.Done;
        Begin
          Dispose(ActiveCollection, Done);
          TDialog.Done;
        End;

      Function TDayDialog.IsSpecial(Day, Month, Year: Word): Boolean;
        Var
          DateStr: String;
          Index: Integer;
        Begin
          DateStr:=FStr(Month)+'/'+FStr(Day)+'/'+FStr(Year);
          IsSpecial:= ActiveCollection^.Search(@DateStr, Index);
        End;

       Function TDayDialog.FStr(I: Integer): String;
         Var
           S: String;
         Begin
           Str(I:2, S);
           FStr:=S;
         End;

      Procedure TDayDialog.SetNewDay(Day, Month, Year: Word);
         Var
           DateTitle: String;
           Hour, Minute, Second, hSecond: Word;
         Begin
           DateTitle:='Tag - '+FStr(Day)+'.'+FStr(Month)+'.'+FStr(Year);
           DisposeStr(Title);        { DisposeStr and NewStr must be used  }
           Title:=NewStr(DateTitle); { when changing the Title of a dialog.}
           GetTime(Hour, Minute, Second, hSecond);
           HourListBox^.NewList(ReadDay);
           HourListBox^.FocusItem(Hour-1); { Focus on current time.        }
           DeskTop^.ExecView(@Self);
           WriteDay(HourListBox^.List);    { Save the appointments.        }
           DeskTop^.Delete(@Self);         { Hide the dialog box.          }
         End;

      Procedure TDayDialog.GetActiveDays;
        Var
          F: File Of RDate;
          Date: RDate;
        Begin
          ActiveCollection:=New(PStringCollection, Init(50,10));
          Assign(F,CalendarFile);
          {$I-}Reset(F);{$I+}
          If IOResult=0 then
            Begin
              While Not Eof(F) do
                Begin
                  Read(F, Date);
                  ActiveCollection^.Insert(NewStr(Date.KeyDate));
                End;
              System.Close(F);
            End;
        End;

      Function TDayDialog.ReadDay: PCollection;
        Var
          F: File Of RDate;
          Date: RDate;
          HourCollection: PHourCollection;
          I: Integer;
          S: TString;
          FileDate: String;
        Begin
          HourCollection:=New(PHourCollection, Init);
          Assign(F,CalendarFile);
          {$I-}Reset(F);{$I+}
          FileDate:=Copy(Title^,7,10);
          { If not dos errors and the data is found in ActiveCollection   }
          If (IOResult=0) and (ActiveCollection^.Search(@FileDate, I)) then
            Begin
              Read(F, Date);
              While Date.KeyDate<>FileDate do
                Read(F, Date);
              For I:=1 to 24 do { Insert each hour into the Collections }
                Begin
                  New(S);
                  S^:=Date.Message[I];
                  HourCollection^.Insert(S);
                End;
            End
           Else
             Begin
               For I:=1 to 24 do
                 Begin
                   New(S);
                   FillChar(S^, SizeOf(S^), ' ');
                   If I<13 then
                     Begin
                       Str(I, S^);
                       S^:=S^+'am ';
                     End
                   Else
                     Begin
                       Str(I-12, S^);
                       S^:=S^+'pm ';
                     End;
                   S^[0]:=#5;
                   HourCollection^.Insert(S);
                 End;
             End;
          ReadDay:= HourCollection;
        End;

      Procedure TDayDialog.WriteDay(Collection: PCollection);
        Var
          F:File of RDate;
          Date, SearchDate: RDate;
          I: Integer;
          S: TString;
        Begin
          Assign(F,CalendarFile);
          {$I-}Reset(F);{$I+}
          If IOResult<>0 then
            ReWrite(F);
          For I:=1 to 24 do  { Copy all appointments into a record.        }
             Date.Message[I]:=TString(Collection^.At(I-1))^;
          Date.KeyDate:=Copy(Title^,7,10);
          { If the day already existed                                     }
          If ActiveCollection^.Search(@Date.KeyDate, I) then
            Begin
              Read(F, SearchDate);
              { Find entry in file.                                        }
              While SearchDate.KeyDate<>Date.KeyDate do
                Read(F, SearchDate);
              Seek(F,FilePos(F)-1);
              Write(F, Date);
            End
          Else
            Begin
              { Add new entry to file.                                     }
              Seek(F, FileSize(F));
              Write(F, Date);
              New(S);
              S^:=Date.KeyDate;
              ActiveCollection^.Insert(S);
            End;
          System.Close(F);
        End;
{-------------- TCalendarWindow --------}
      Constructor TCalendarWindow.Init(DayDialog: PDayDialog);
         Var
           R:TRect;
         Begin
           R.Assign(1,1,23,11);
           TWindow.Init(R, 'Kalender', 0);
           Flags := Flags and Not(wfZoom+wfGrow); { Do not allow window to }
           GrowMode :=0;                          { be resizeable.         }
           GetExtent(R);
           Inc(R.A.X);
           Inc(R.A.Y);
           Dec(R.B.X);
           Dec(R.B.Y);
           CalendarView := New(PCalendarView,Init(R, DayDialog));
           Insert(CalendarView);
         End;

{-------------- TCalendarView ----------}
      Constructor TCalendarView.Init(Bounds: TRect; D: PDayDialog);
         Var
           H: Word;
         Begin
           TView.Init(Bounds);
           DayDialog:=D;
           Options := Options or ofSelectable;
           GetDate(CurYear, CurMonth, CurDay, H);
           Year:=CurYear;
           Month:=CurMonth;
           DrawView;
         End;

       Destructor TCalendarView.Done;
         Begin
           Dispose(DayDialog, Done);
           TView.Done;
         End;

       Function DayOfWeek (day, month, year: integer) : integer;
           var
             century, yr, dw: integer;
           begin
             if month < 3 then
               begin
                 Inc(month, 10);
                 Dec(year);
               end
             else
                Dec(month, 2);
             century := year div 100;
             yr := year mod 100;
             dw := (((26*month - 2) div 10)+day+yr+(yr div 4)+(century div 4) - (2*century)) mod 7;
             if dw < 0 then
               DayOfWeek := dw + 7
             else
               DayOfWeek := dw;
           end;

     Procedure TCalendarView.Draw;
       Const
         Width = 20;
       Var
         i,j,DayOf,CurDays:Integer;
         S: String;
         B: Array[0..Width] of Word;
         Color, BoldColor, SpecialColor: Byte;

         Function Num2Str(I :integer): String;
           Var
             S:String;
           Begin
             Str(i:2,S);
             Num2Str := S+' ';
           End;

       Begin
         Color:= GetColor($01);
         BoldColor:= GetColor($02);
         SpecialColor:= GetColor($03);
         DayOf:=DayOfWeek(1, Month, Year);
         Days := DaysInMonth[Month] + Byte((Year mod 4=0) and (Month=2));
         Str(Year:4,S);
         MoveChar(B, ' ', Color, Width);
         MoveStr(B, MonthStr[Month]+S+' '#30'  '#31,Color);
         WriteLine(0,0,Width,1,B);
         MoveChar(B, ' ', Color, Width);
         MoveStr(B, 'So Mo Di Mi Do Fr Sa', Color);
         WriteLine(0,1,Width,1,B);
         CurDays := 1-DayOf;
         For i:=1 to 6 do
           Begin
             MoveChar(B, ' ', Color, Width);
             For j:=0 to 6 do
               Begin
                 If (CurDays<1) or (CurDays>Days) then
                    MoveStr(B[J*3],'   ',Color)
                 else
                    { If it is the current day.                           }
                    If (Year=CurYear) and (Month=CurMonth) and (CurDays=CurDay) Then
                      MoveStr(B[J*3],Num2Str(CurDays),BoldColor)
                    { If there is an appointment for this day.            }
                    Else If DayDialog^.IsSpecial(CurDays, Month, Year) Then
                      MoveStr(B[J*3],Num2Str(CurDays),SpecialColor)
                    Else
                      MoveStr(B[J*3],Num2Str(CurDays),Color);
                 Inc(CurDays);
               End;
           WriteLine(0,i+1, Width,1,B);
           End;
       End;

       procedure TCalendarView.HandleEvent(var Event: TEvent);
         Var
           Point:TPoint;
           SelectDay: Word;
         begin
           TView.HandleEvent(Event);
           if (State and sfSelected <> 0) then
             Begin
               if (Event.What=evMouseDown) then
                 If Event.Double then
                   Begin
                     MakeLocal(Event.Where,Point);
                     If (Point.Y>1) then
                       Begin
                         SelectDay :=((Point.X div 3)+1)-DayOfWeek(1, Month, Year)+(Point.Y-2)*7;
                         If (SelectDay>0) and (SelectDay-1<Days) then
                           Begin
                             { Display the dialog box.                    }
                             DayDialog ^.SetNewDay(SelectDay, Month, Year);
                             DrawView;
                           End;
                       End;
                   End
                 Else
                 begin
                   MakeLocal(Event.Where,Point);
                   If ((Point.X=15) and (Point.Y = 0)) Then
                     Begin
                       inc(Month);
                       If Month>12 then
                         Begin
                           inc(Year);
                           Month :=1;
                         End;
                         DrawView;
                       End;
                   If ((Point.X=18) and (Point.Y=0)) Then
                     Begin
                       dec(Month);
                       If Month<1 then
                         Begin
                           dec(Year);
                           Month :=12;
                         End;
                         DrawView;
                       End;
                 end
               else if Event.What=evKeyDown then
                   Begin
                     If (lo(Event.KeyCode) = byte('+')) or
                        (Event.KeyCode = kbDown)
                       Then
                          Begin
                            inc(Month);
                            If Month>12 then
                              Begin
                                inc(Year);
                                Month :=1;
                              End;
                          End;
                     If (lo(Event.KeyCode) = byte('-')) or
                        (Event.KeyCode = kbUp)
                       Then
                          Begin
                            dec(Month);
                            If Month<1 then
                              Begin
                                dec(Year);
                                Month :=12;
                              End;
                          End;
                      DrawView;
                   End;
             End;
         end;
 End.

