PROGRAM EXODB_20_Alpha1;

USES
  Crt,Dos,Graph,
  Objects,Drivers,Memory,Views,Menus,Dialogs,StdDlg,HistList,OutLine,MsgBox,App,Gadgets,TextView,ColorSel,MouseDlg,
  DemoCmds,Puzzle,{Calendar,}AsciiTab, Calc,HelpFile,DemoHelp,Editors,CalUnit,XViews,
  Records,Credits,Thanks,Orbit,Star3D,Starmap,Distri,Diagram,Filter,Search,Status,
  EXODB,DBObjDel,DBObjExp,DBSetDel,DBSetExp,DBRename,DBExport,DBErase,
  Method,Startype,Dis_Stat,Dustdisc,ObjList;

TYPE
  PTyp = Array[apColor..apMonochrome] Of String[127];
  TNeuApp = OBJECT(TApplication)
    baum: PNode;
    OutlineWindow: PWindow;
    CONSTRUCTOR Init;
    PROCEDURE Idle; VIRTUAL;
    PROCEDURE InitMenuBar;    VIRTUAL;
    PROCEDURE InitStatusLine; VIRTUAL;
    PROCEDURE AboutBox;
    PROCEDURE Database_Open;
    FUNCTION GetPalette: PPalette; VIRTUAL;
    PROCEDURE HandleEvent(VAR Event: TEvent); VIRTUAL;
    PROCEDURE ColFrageBox;
    PROCEDURE OutOfMemory; VIRTUAL;
    PROCEDURE HelpFenster(DateiName,Tittel:String);
    PROCEDURE SystemHierarchie;
    PROCEDURE MakeHierarchie;
    PROCEDURE InitOutlineWindow;
  END;

CONST
  wurzel = 'System';
  ebene1 : ARRAY[1..2] OF STRING =
           ('Stern A','Stern B');
  ebene2 : ARRAY[1..2,1..3] OF STRING =
           (('Planet A b','Planet A c',''),
            ('Planet B b','Planet B c','Planet B d'));
  SignatureLen = 21;
  DSKSignature : STRING[SignatureLen] = 'TV Demo Desktop File'#26;
  HeapSize = 48*(1024 DIV 16);  { Save 48k heap for main program }
  palette  : PTyp = (CAppColor, CAppBlackWhite, CAppMonochrome);
  urpalette: PTyp = (CAppColor, CAppBlackWhite, CAppMonochrome);
  cmColor  = 206;
  cmStdCol = 207;
  dpGrayDialog = 0;
  dpBlueDialog = 1;
  dpCyanDialog = 2;
  wpBlueWindow = 0;
  wpCyanWindow = 1;
  wpGrayWindow = 2;

VAR
  lC        : Boolean;
  ObjectListPointer : PDialogObjectList;
  DiscoverMethodPointer : PDialogDiscoverMethod;
  DiscoverStatusPointer : PDialogDiscoverStatus;
  StartypePointer : PDialogStartype;
  DustdiscPointer : PDialogDustdisc;
  EXODB2Pointer : PDialogEXODB2;
  DBErasePointer : PDialogDBErase;
  DBExportPointer : PDialogDBExport;
  DBRenamePointer : PDialogDBRename;
  DBSetErasePointer : PDialogDBSetErase;
  DBSetExportPointer : PDialogDBSetExport;
  DBObjectErasePointer : PDialogDBObjectErase;
  DBObjectExportPointer : PDialogDBObjectExport;
  CreditsPointer : PDialogCredits;
  ThanksPointer : PDialogThanks;
  OrbitPointer : PDialogOrbit;
  StarmapPointer : PDialogStarmap;
  Star3DPointer : PDialogStar3D;
  DistributionPointer : PDialogDistribution;
  DiagramPointer : PDialogDiagram;
  RecordsPointer : PDialogRecords;
  FilterPointer : PDialogFilter;
  SearchPointer : PDialogSearch;
  PlanetStatusPointer : PDialogPlanetStatus;


PROCEDURE TNeuApp.MakeHierarchie;
VAR
  ast,ast1,ast2 : PNode;
BEGIN
  ast1 := NewNode(ebene2[1,1],NIL,NewNode(ebene2[1,2],NIL,NIL));
  ast2 := NewNode(ebene2[2,1],NIL,NewNode(ebene2[2,2],NIL,
          NewNode(ebene2[2,3],NIL,NIL)));
  ast  := NewNode(ebene1[1],ast1,NewNode(ebene1[2],ast2,NIL));
  baum := NewNode(wurzel,ast,NIL);
END;

PROCEDURE TNeuApp.InitOutlineWindow;
VAR
  R       : TRect;
  VertiBar: PScrollBar;
  HierBaum: POutline;
BEGIN
  R.Assign(0, 0, 40, 12);
  OutlineWindow := New(PWindow, Init(R,'Struktur der System-Hierarchie',0));
  WITH OutlineWindow^ DO BEGIN
    Palette := dpBlueDialog;
    Options := Options Or ofCentered;
    VertiBar:= StandardScrollBar(sbVertical Or sbHandleKeyboard);
    Insert(VertiBar);
    R.Grow(-1, -1);
    HierBaum := New(POutline, Init(R, nil, VertiBar, baum));
    Insert(HierBaum);
  END;
END;

PROCEDURE TNeuApp.SystemHierarchie;
BEGIN
  MakeHierarchie;
  InitOutlineWindow;
  InsertWindow(OutlineWindow);
END;

PROCEDURE TNeuApp.Database_Open;
VAR
  FileDialog : PFileDialog;
  Filename   : FNameStr;
  Result     : Word;
BEGIN
  FileDialog := New(PFileDialog,Init('*.*','Datenbank îffnen','~N~ame',fdOpenButton,100));
  {$ifDEF VER70}
  Result := ExecuteDialog(FileDialog,@Filename);
  {$endif}
  {$ifDEF VER60}
  Result := cmCancel;
  IF ValidView(FileDialog) <> NIL THEN Result := Desktop^.ExecView(FileDialog);
  IF Result <> cmCancel THEN FileDialog^.GetFilename(Filename);
  Dispose(FileDialog, Done);
  {$endif}
  IF Result <> cmCancel THEN MessageBox(^C'Datenbank ausgewÑhlt: '+Filename+'.',NIL,mfInFormation+mfOkButton);
END;

CONSTRUCTOR TNeuApp.Init;
VAR R : TRect;
BEGIN
  TApplication.Init;
  SetScreenMode(BW80+Font8x8);
  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterApp;
  RegisterHelpFile;
  RegisterPuzzle;
  RegisterAsciiTab;
  RegisterCalc;
  RegisterEditors;
  GetExtent(R);
  EXODB2Pointer := New(PDialogEXODB2,Init);
  DeskTop^.Insert(EXODB2Pointer);
  R.A.X := R.B.X-20;
  R.A.Y := R.B.Y-1;
  Date := New(PDate,Init(R));
  Insert(Date);
  GetExtent(R);
  R.A.X := R.B.X-9;
  R.A.Y := R.B.Y-1;
  Clock := New(PClock,Init(R));
  Insert(Clock);
  GetExtent(R);
  R.A.X := R.B.X-13;
  R.B.Y := R.A.Y+1;
  Heap := New(PHeap,Init(R));
  Insert(Heap);
END;

PROCEDURE TNeuApp.HelpFenster(DateiName,Tittel : STRING);
CONST BufferSize : Word = 40000;
VAR
  R : TRect;
  Fenster2 : PWindow;
  Inneres : PTerminal;
  Datei,FensterText : Text;
  Zeile : STRING;
BEGIN
 R.Assign(1,1,80,49);
 Fenster2 := New(PWindow,Init(R,Tittel,wnNoNumber));
 WITH Fenster2^ DO BEGIN
   Options := Options OR ofCentered;
   GetExtent(R);
   R.Grow(-1,-1);
   Inneres := New(PTerminal,Init(R,
     StandardScrollBar(sbHorizontal+sbHandleKeyBoard),
     StandardScrollBar(sbVertical+sbHandleKeyBoard),
     BufferSize));
   Insert(Inneres);
 END;
 Desktop^.Insert(Fenster2);
 Assign(Datei,DateiName);
 Reset(Datei);
 AssignDevice(FensterText,Inneres);
 Rewrite(FensterText);
 REPEAT
   ReadLn(Datei,Zeile);
   WriteLn(FensterText,Zeile);
 UNTIL EoF(Datei);
 Inneres^.ScrollTo(0,0);
 Close(Datei);
 Close(FensterText);
END;

PROCEDURE TNeuApp.Idle;
VAR Event : TEvent;
BEGIN
  TApplication.Idle;
  Date^.Update;
  Clock^.Update;
  Heap^.Update;
END;

PROCEDURE TNeuApp.OutOfMemory;
BEGIN
  MessageBox('Not enough memory available to complete operation.',NIL,mfError+mfOkButton);
END;

FUNCTION TNeuApp.GetPalette : PPalette;
{const
  CNewColor = CAppColor + CHelpColor;
  CNewBlackWhite = CAppBlackWhite + CHelpBlackWhite;
  CNewMonochrome = CAppMonochrome + CHelpMonochrome;
  P: array[apColor..apMonochrome] of string[Length(CNewColor)] =
    (CNewColor, CNewBlackWhite, CNewMonochrome);}
BEGIN
{  GetPalette := @P[AppPalette];}
  GetPalette:=@palette;
END;

PROCEDURE TNeuApp.AboutBox;
BEGIN
  MessageBox(#3'EXODB2 2.0 Alpha 1'#13+
    #3'Copyright 1995-2005 Michael Johne'#13+
    #3'WWW: http://www.exodb.de.vu'#13+
    #3'Mail: michael-johne@gmx.de',
    NIL,mfInformation OR mfOKButton);
END;

PROCEDURE SaveColors;
VAR
  f : Text;
BEGIN
  Assign(f,'PAL001.TVC');
  ReWrite(f);
  WriteLn(f,palette[apcolor]);
  Close(f);
END;

FUNCTION LoadColors: STRING;
VAR
  f : FILE OF Char;
  i : Integer;
  ch: Char;
  loadCols : STRING[127];
BEGIN
  Assign(f,'PAL001.TVC');
  Reset(f);
  loadCols := '';
  FOR i := 1 TO 127 DO BEGIN
    Read(f,ch);
    loadCols := loadCols+ch;
  END;
  Close(f);
  LoadColors := loadCols;
END;

PROCEDURE TNeuApp.ColFrageBox;
VAR
  Dialog  : PDialog;
  commando: Word;
  R       : TRect;
BEGIN
  R.Assign(0, 0, 34, 7);
  Dialog := New(PDialog, Init(R, 'Frage-Box'));
  WITH Dialog^ DO
  BEGIN
    R.Assign(4, 4, 14, 6);
    Insert(New(PButton, Init(R, '  ~J~a  ', cmYes, bfDefault)));
    R.Assign(20, 4, 30, 6);
    Insert(New(PButton, Init(R, ' ~N~ein ', cmNo, bfNormal)));
    R.Assign(5, 2, 30, 3);
    Insert(New(PLabel, Init(R, 'Farbeinstellung laden?', nil)));
    Options := Options Or ofCentered;
  END;
  commando := ExecView(Dialog);
  IF commando = cmYes THEN BEGIN
    palette[apcolor] := LoadColors;
    lC := True;
    ReDraw;
    DeskTop^.ReDraw;
  END ELSE
    lC := False;
  Dispose(Dialog, Done);
END;

PROCEDURE TNeuApp.HandleEvent(VAR Event : TEvent);
VAR
  R : TRect;

  PROCEDURE Colors;
  var D : PColorDialog;
  BEGIN
    D := New(PColorDialog,Init('Farben wechseln',
    ColorGroup('Desktop',      DesktopColorItems(nil),
    ColorGroup('MenÅleiste',   MenuColorItems(nil),
    ColorGroup('Std.-Fenster', WindowColorItems(wpBlueWindow,nil),
    ColorGroup('View-Box',     WindowColorItems(wpGrayWindow,nil),
    ColorGroup('Dialog-Box',   DialogColorItems(dpGrayDialog,
                ColorItem('Fehlermeldung', 62, nil)),
      {ColorGroup('Kalendar',
      WindowColorItems(wpCyanWindow,
      ColorItem('current day',22,NIL)),}
    NIL))))))){)};
    IF ExecuteDialog(D,Application^.GetPalette) <> cmCancel THEN BEGIN
      DoneMemory;
      ReDraw;
    END;
  END;

  PROCEDURE ShowEXODB2;
  BEGIN
    EXODB2Pointer := New(PDialogEXODB2,Init);
    DeskTop^.Insert(EXODB2Pointer);
  END;

  PROCEDURE Mouse;
  VAR D: PDialog;
  BEGIN
    D := New(PMouseDialog,Init);
    ExecuteDialog(D,@MouseReverse);
  END;

  PROCEDURE ShowDBErase;
  BEGIN
    DBErasePointer := New(PDialogDBErase,Init);
    DeskTop^.Insert(DBErasePointer);
  END;

  PROCEDURE ShowDiscoverMethod;
  BEGIN
    DiscoverMethodPointer := New(PDialogDiscoverMethod,Init);
    DeskTop^.Insert(DiscoverMethodPointer);
  END;

  PROCEDURE ShowDiscoverStatus;
  BEGIN
    DiscoverStatusPointer := New(PDialogDiscoverStatus,Init);
    DeskTop^.Insert(DiscoverStatusPointer);
  END;

  PROCEDURE ShowStartype;
  BEGIN
    StartypePointer := New(PDialogStartype,Init);
    DeskTop^.Insert(StartypePointer);
  END;

  PROCEDURE ShowDustdisc;
  BEGIN
    DustdiscPointer := New(PDialogDustdisc,Init);
    DeskTop^.Insert(DustdiscPointer);
  END;

  PROCEDURE ShowObjectList;
  BEGIN
    ObjectListPointer := New(PDialogObjectList,Init);
    DeskTop^.Insert(ObjectListPointer);
  END;

  PROCEDURE ShowDBExport;
  BEGIN
    DBExportPointer := New(PDialogDBExport,Init);
    DeskTop^.Insert(DBExportPointer);
  END;

  PROCEDURE ShowDBRename;
  BEGIN
    DBRenamePointer := New(PDialogDBRename,Init);
    DeskTop^.Insert(DBRenamePointer);
  END;

  PROCEDURE ShowDBSetExport;
  BEGIN
    DBSetExportPointer := New(PDialogDBSetExport,Init);
    DeskTop^.Insert(DBSetExportPointer);
  END;

  PROCEDURE ShowDBSetErase;
  BEGIN
    DBSetErasePointer := New(PDialogDBSetErase,Init);
    DeskTop^.Insert(DBSetErasePointer);
  END;

  PROCEDURE ShowDBObjectExport;
  BEGIN
    DBObjectExportPointer := New(PDialogDBObjectExport,Init);
    DeskTop^.Insert(DBObjectExportPointer);
  END;

  PROCEDURE ShowDBObjectErase;
  BEGIN
    DBObjectErasePointer := New(PDialogDBObjectErase,Init);
    DeskTop^.Insert(DBObjectErasePointer);
  END;

  PROCEDURE ShowRecords;
  BEGIN
    RecordsPointer := New(PDialogRecords,Init);
    DeskTop^.Insert(RecordsPointer);
  END;

  PROCEDURE ShowPlanetStatus;
  BEGIN
    PlanetStatusPointer := New(PDialogPlanetStatus,Init);
    DeskTop^.Insert(PlanetStatusPointer);
  END;

  PROCEDURE ShowStarmap;
  BEGIN
    StarmapPointer := New(PDialogStarmap,Init);
    DeskTop^.Insert(StarmapPointer);
  END;

  PROCEDURE ShowDistribution;
  BEGIN
    DistributionPointer := New(PDialogDistribution,Init);
    DeskTop^.Insert(DistributionPointer);
  END;

  PROCEDURE ShowDiagram;
  BEGIN
    DiagramPointer := New(PDialogDiagram,Init);
    DeskTop^.Insert(DiagramPointer);
  END;

  PROCEDURE ShowStar3D;
  BEGIN
    Star3DPointer := New(PDialogStar3D,Init);
    DeskTop^.Insert(Star3DPointer);
  END;

  PROCEDURE ShowSearch;
  BEGIN
    SearchPointer := New(PDialogSearch,Init);
    DeskTop^.Insert(SearchPointer);
  END;

  PROCEDURE ShowFilter;
  BEGIN
    FilterPointer := New(PDialogFilter,Init);
    DeskTop^.Insert(FilterPointer);
  END;

  PROCEDURE ShowCredits;
  BEGIN
    CreditsPointer := New(PDialogCredits,Init);
    DeskTop^.Insert(CreditsPointer);
  END;

  PROCEDURE ShowThanks;
  BEGIN
    ThanksPointer := New(PDialogThanks,Init);
    DeskTop^.Insert(ThanksPointer);
  END;

  PROCEDURE ShowOrbit;
  BEGIN
    OrbitPointer := New(PDialogOrbit,Init);
    DeskTop^.Insert(OrbitPointer);
  END;

  PROCEDURE Calendar;
  VAR CalendarWindow: PCalendarWindow;
  BEGIN
    CalendarWindow := New(PCalendarWindow,Init(New(PDayDialog,Init)));
    DeskTop^.Insert(CalendarWindow);
  END;

  PROCEDURE Calculator;
  VAR P : PCalculator;
  BEGIN
    P := New(PCalculator,Init);
    DeskTop^.Insert(P);
  END;

  PROCEDURE Puzzle;
  VAR P : PPuzzleWindow;
  BEGIN
    P := New(PPuzzleWindow,Init);
    DeskTop^.Insert(P);
  END;

  PROCEDURE AsciiTab;
  VAR P: PAsciiChart;
  BEGIN
    P := New(PAsciiChart,Init);
    DeskTop^.Insert(P);
  END;

BEGIN
  INHERITED HandleEvent(Event);
  IF Event.What = evCommand THEN BEGIN
    CASE Event.Command OF
      slOptionColor : BEGIN
        ColFrageBox;
        IF Not lC THEN Colors;
        SaveColors;
      END;
      cmStdCol: BEGIN
        palette := urpalette;
        ReDraw;
        Desktop^.ReDraw;
      END;
      slDBOpen : BEGIN
        Database_Open;
        ClearEvent(Event);
      END;
      slDBExport : BEGIN
        ShowDBExport;
        ClearEvent(Event);
      END;
      slDBErase : BEGIN
        ShowDBErase;
        ClearEvent(Event);
      END;
      slDBRename : BEGIN
        ShowDBRename;
        ClearEvent(Event);
      END;
      slDBSetExport : BEGIN
        ShowDBSetExport;
        ClearEvent(Event);
      END;
      slDBSetErase : BEGIN
        ShowDBSetErase;
        ClearEvent(Event);
      END;
      slDBObjectExport : BEGIN
        ShowDBObjectExport;
        ClearEvent(Event);
      END;
      slDBObjectErase : BEGIN
        ShowDBObjectErase;
        ClearEvent(Event);
      END;
      cmDBStarList : BEGIN
        ShowObjectList;
      END;
      cmDBPlanetList : BEGIN
        ShowObjectList;
      END;
      cmDBPlanetDisMethod : BEGIN
        ShowDiscoverMethod;
      END;
      cmDBPlanetDisStatus : BEGIN
        ShowDiscoverStatus;
      END;
      cmDBDustdisc : BEGIN
        ShowDustdisc;
      END;
      cmDBStartype : BEGIN
        ShowStartype;
      END;
      slMiscHelp : BEGIN
        HelpFenster('HELP.MAN','Hilfe zu EXO-DB2 2.0');
      END;
      slModuleStatus : BEGIN
        ShowPlanetStatus;
        ClearEvent(Event);
      END;
      slModuleSysHierarchie : BEGIN
        TNeuApp.SystemHierarchie;
        ClearEvent(Event);
      END;
      slModuleRecords : BEGIN
        ShowRecords;
        ClearEvent(Event);
      END;
      slModuleOrbit : BEGIN
        ShowOrbit;
        ClearEvent(Event);
      END;
      slModuleStarmap : BEGIN
        ShowStarmap;
        ClearEvent(Event);
      END;
      slModuleDistri : BEGIN
        ShowDistribution;
        ClearEvent(Event);
      END;
      slModuleDiagram : BEGIN
        ShowDiagram;
        ClearEvent(Event);
      END;
      slModuleDiagram : BEGIN
        ShowDiagram;
        ClearEvent(Event);
      END;
      slModuleStar3D : BEGIN
        ShowStar3D;
        ClearEvent(Event);
      END;
{      slOptionColor : BEGIN
        Colors;
        ClearEvent(Event);
      END;}
      slOptionFind : BEGIN
        ShowSearch;
        ClearEvent(Event);
      END;
      slOptionFilter : BEGIN
        ShowFilter;
        ClearEvent(Event);
      END;
      slOptionMouse : BEGIN
        Mouse;
        ClearEvent(Event);
      END;
{      slOptionDesktopSave : BEGIN
        SaveDesktop;
        ClearEvent(Event);
      END;
      slOptionDesktopRetrieve : BEGIN
        RetrieveDesktop;
        ClearEvent(Event);
      END;}
      slMiscInfo : BEGIN
        AboutBox;
        ClearEvent(Event);
      END;
      slMiscCredits : BEGIN
        ShowCredits;
        ClearEvent(Event);
      END;
      slMiscThanks : BEGIN
        ShowThanks;
        ClearEvent(Event);
      END;
      slMiscCalendar : BEGIN
        Calendar;
        ClearEvent(Event);
      END;
      slMiscCalculator : BEGIN
        Calculator;
        ClearEvent(Event);
      END;
      slMiscPuzzle : BEGIN
        Puzzle;
        ClearEvent(Event);
      END;
      slMiscAsciiTab : BEGIN
        AsciiTab;
        ClearEvent(Event);
      END ELSE Exit;
    END;
  END;
END;

PROCEDURE TNeuApp.InitMenuBar;
VAR
  R: TRect;
BEGIN
  GetExtent(R);
  R.B.Y := R.A.Y+1;
  MenuBar:=New(PMenuBar,Init(R,NewMenu(
    NewSubMenu('~D~atenbank',slDB,NewMenu(
      NewSubMenu('~E~rstellen',slDBCreate,NewMenu(
        NewItem('~M~anuell erstellen','F1',kbF1,slDBCreateManual,hcNoContext,
        NewItem('Per ~Z~ufall erstellen','F2',kbF2,slDBCreateRandom,hcNoContext,
      NIL))),
      NewItem('ô~f~fnen','F3',kbF3,slDBOpen,hcNoContext,
      NewItem('~U~mbenennen','F4',kbF4,slDBRename,hcNoContext,
      NewItem('E~x~portieren','F5',kbF5,slDBExport,hcNoContext,
      NewItem('~L~îschen', 'F6',kbF6,slDBErase,hcNoContext,
      NewLine(
      NewSubMenu('~D~atensatz',slDBSet,NewMenu(
        NewItem('~H~inzufÅgen','F7',kbF7,slDBSetAdd,hcNoContext,
        NewItem('~é~ndern','F8',kbF8,slDBSetChange,hcNoContext,
        NewItem('~E~xportieren','F9',kbF9,slDBSetExport,hcNoContext,
        NewItem('~L~îschen','F10',kbF10,slDBSetErase,hcNoContext,
        NewSubMenu('~S~tern',slDBSet,NewMenu(
          NewItem('~H~inzufÅgen','',kbNoKey,slDBObjectAdd,hcNoContext,
          NewItem('~é~ndern','',kbNoKey,slDBObjectChange,hcNoContext,
          NewItem('~E~xportieren','',kbNoKey,slDBObjectExport,hcNoContext,
          NewItem('~L~îschen','',kbNoKey,slDBObjectErase,hcNoContext,
        NIL))))),
        NewSubMenu('~E~xoplanet',slDBSet,NewMenu(
          NewItem('~H~inzufÅgen','',kbNoKey,slDBObjectAdd,hcNoContext,
          NewItem('~é~ndern','',kbNoKey,slDBObjectChange,hcNoContext,
          NewItem('~E~xportieren','',kbNoKey,slDBObjectExport,hcNoContext,
          NewItem('~L~îschen','',kbNoKey,slDBObjectErase,hcNoContext,
        NIL))))),
      NIL))))))),
      NewLine(
      NewItem('~E~nde','Alt-X',kbAltX,cmQuit,hcNoContext,
    NIL)))))))))),
    NewSubMenu('~M~odule',slModule,NewMenu(
      NewItem('~R~ekorde','Alt+F1',kbAltF1,slModuleRecords,hcNoContext,
      NewItem('~P~laneten-Status','Alt+F2',kbAltF2,slModuleStatus,hcNoContext,
      NewItem('S~y~stem-Hierachie','Alt+F3',kbAltF3,slModuleSysHierarchie,hcNoContext,
      NewLine(
      NewItem('~O~rbit-Abbild','Alt+F4',kbAltF4,slModuleOrbit,hcNoContext,
      NewItem('M~a~sse-Vergleich','Alt+F5',kbAltF5,slModuleMass,hcNoContext,
      NewItem('~S~ternkarte','Alt+F6',kbAltF6,slModuleStarmap,hcNoContext,
      NewItem('~Z~Ñhlungen','Alt+F7',kbAltF7,slModuleDistri,hcNoContext,
      NewItem('~D~iagramme','Alt+F8',kbAltF8,slModuleDiagram,hcNoContext,
      NewItem('~H~RD','Alt+F9',kbAltF9,slModuleHRD,hcNoContext,
      NewItem('So~n~nenumbegung','Alt+F10',kbAltF10,slModuleStar3D,hcNoContext,
    NIL)))))))))))),
    NewSubMenu('~O~ptionen',slOption,NewMenu(
      NewItem('~S~uchen','Ctrl+F1',kbCtrlF1,slOptionFind,hcNoContext,
      NewItem('~F~ilter','Ctrl+F2',kbCtrlF2,slOptionFilter,hcNoContext,
      NewLine(
{      NewItem('~K~onfigurationen','Ctrl+F3',kbCtrlF3,slOptionConfig,hcNoContext,}
      NewItem('F~a~rbeinstellungen','Ctrl+F3',kbCtrlF3,slOptionColor,hcNoContext,
      NewItem('~M~aus-Steuerung','Ctrl+F3',kbCtrlF4,slOptionMouse,hcNoContext,
{      NewLine(
      NewItem('Desktop s~p~eichern','Ctrl+F6',kbCtrlF6,slOptionDesktopSave,hcNoContext,
      NewItem('Desktop ~w~iederherstellen','Ctrl+F7',kbCtrlF7,slOptionDesktopRetrieve,hcNoContext,}
    NIL)))))),
    NewSubMenu('~F~enster',slWindow,NewMenu(
      NewItem('~B~ewegen','Alt+1',kbAlt1,cmResize,hcNoContext,
      NewItem('~V~ergrî·ern','Alt+2',kbAlt2,cmZoom,hcNoContext,
      NewItem('V~o~rheriges','Alt+3',kbAlt3,cmNext,hcNoContext,
      NewItem('~N~Ñchstes','Alt+4',kbAlt4,cmNext,hcNoContext,
      NewItem('~S~chlie·en','Alt+5',kbAlt5,cmClose,hcNoContext,
      NewItem('~G~ekachelt','Alt+6',kbAlt6,cmTile,hcNoContext,
      NewItem('~K~askadiert','Alt+7',kbAlt7,cmCascade,hcNoContext,
    NIL)))))))),
    NewSubMenu('~S~onstiges',slMisc,NewMenu(
      NewItem('~I~nfo','Strg+F1',kbShiftF1,slMiscInfo,hcNoContext,
      NewItem('~C~redits','Strg+F2',kbShiftF2,slMiscCredits,hcNoContext,
      NewItem('~D~anksagung','Strg+F3',kbShiftF3,slMiscThanks,hcNoContext,
      NewItem('~H~ilfe','Strg+F4',kbShiftF4,slMiscHelp,hcNoContext,
      NewLine(
      NewItem('~K~alender','Strg+F5',kbShiftF5,slMiscCalendar,hcNoContext,
      NewItem('~T~aschenrechner','Strg+F6',kbShiftF6,slMiscCalculator,hcNoContext,
      NewItem('~P~uzzle','Strg+F7',kbShiftF7,slMiscPuzzle,hcNoContext,
      NewItem('~A~scii Tabelle','Strg+F8',kbShiftF8,slMiscAsciiTab,hcNoContext,
      NewLine(
      NewItem('D~O~S Shell','Strg+F9',kbShiftF9,cmDosShell,hcNoContext,
      NewItem('~E~nde','Alt-X',kbAltX,cmQuit,hcNoContext,
    NIL))))))))))))),
  NIL))))))));
END;

PROCEDURE TNeuApp.InitStatusLine;
VAR R: TRect;
BEGIN
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine:=New(PStatusLine,Init(R,
    NewStatusDef(0,0,
      NewStatusKey('M~e~nu',kbAltE,cmMenu,
      NewStatusKey('~H~ilfe',kbAltH,slMiscHelp,
      NewStatusKey('~Alt+F3~-Schliessen',kbAltF3,cmClose,
      NewStatusKey('E~x~it',kbAltX,cmQuit,
    NIL)))),
    NewStatusDef(1000,1000,
      NewStatusKey('Verwalten von Datenbank & DatensÑtze',0,slNil,
    NIL),
    NewStatusDef(1010,1010,
      NewStatusKey('Erstellen einer Datenbank',0,slNil,
    NIL),
    NewStatusDef(1060,1060,
      NewStatusKey('Verwalten von DatensÑtze',0,slNil,
    NIL),
    NewStatusDef(1100,1100,
      NewStatusKey('Aufrufen und AusfÅhren von Modulen',0,slNil,
    NIL),
    NewStatusDef(1200,1200,
      NewStatusKey('Einstellungen diverser Optionen',0,slNil,
    NIL),
    NewStatusDef(1300,1300,
      NewStatusKey('Sonstige Features',0,slNil,
    NIL),
    NewStatusDef(1400,1400,
      NewStatusKey('Verwalten der Fenster-Grî·e',0,slNil,
    NIL),
  NIL))))))))));
END;

VAR
  Application : TNeuApp;

BEGIN
  Application.Init;
  Application.Run;
  Application.Done;
END.
