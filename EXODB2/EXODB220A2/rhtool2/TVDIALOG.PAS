{*
*
*   Copyright (c) 1992,93 by Richard W. Hansen
*
*   This source code will compile.
*   Full source code available to registered users.
*
*}
(* This file was mangled by Mangler 1.10 (c) Copyright 1993 by Berend de Boer *)
 UNIT TVDIALOG ;{$B+} {$X+} {$V-} {$I TVDEFS.INC} INTERFACE USES DOS , TVOBJECT , TVCONST , TVSTRING , TVTYPE ,
{$IFDEF USE_NEW_FILE_DIALOG} STDDLG , {$ENDIF} APP , DIALOGS , DRIVERS , MEMORY , MSGBOX , OBJECTS , VIEWS ;
CONST BARCHAR :CHAR ='�';BARFILLCHAR :CHAR ='�';CONST BUTTONS :ARRAY [ 0 .. 3 ]  OF STRING [ 8 ] =('~Y~es', '~N~o',
'O~K~', '~C~ancel');COMMANDS :ARRAY [ 0 .. 3 ]  OF WORD =(CMYES , CMNO , CMOK , CMCANCEL );TITLES :ARRAY [ 0 .. 3 ]
 OF STRING [ 11 ] =('Warning', 'Error', 'Information', 'Confirm');CONST MFMESSAGELINE =$1000 ;MFPAUSEBUTTON =$2000 ;
MFPAUSECANCEL =MFPAUSEBUTTON + MFCANCELBUTTON ;MFOKPAUSECANCEL =MFOKCANCEL + MFPAUSEBUTTON ;CONST VLCURRENT =$0001 ;
VLPREV =$0002 ;VLNEXT =$0003 ;VLMIN =$0004 ;VLMAX =$0005 ;VLLISTMAX =$0006 ;VLLISTMIN =$0007 ;
{$IFDEF USE_NEW_FILE_DIALOG} TYPE PSEARCHREC =^TSEARCHREC ;DRIVELETTERS ='A'.. 'Z';DRIVESET =SET  OF DRIVELETTERS ;
{$ENDIF} TYPE PBXRUNDIALOG =^TBXRUNDIALOG ;TBXRUNDIALOG =OBJECT (TDIALOG)MSG :PSTATICTEXT ;RUNSTATE :WORD ;
PFFLAGS :WORD ;BTNROW :BYTE ;SBUTTON :PBUTTON ;CBUTTON :PBUTTON ;CONSTRUCTOR INIT (VAR BOUNDS :TRECT ;
ATITLE :TTITLESTR ;AMESSAGE :STRING ;AOPTIONS :WORD ;BUTTONROW :BYTE );CONSTRUCTOR LOAD (VAR S :TSTREAM );
PROCEDURE CHANGEMESSAGE (AMESSAGE :STRING );FUNCTION EXECUTE :WORD ;VIRTUAL;PROCEDURE HANDLEEVENT (VAR EVENT :TEVENT );
VIRTUAL;PROCEDURE PROCESS ;VIRTUAL;PROCEDURE STORE (VAR S :TSTREAM );END ;PBXPERCENTDIALOG =^TBXPERCENTDIALOG ;
TBXPERCENTDIALOG =OBJECT (TBXRUNDIALOG)TOTAL :LONGINT ;COUNT :LONGINT ;STEP :WORD ;PCT :PSTATICTEXT ;BAR :PSTATICTEXT ;
CONSTRUCTOR INIT (ATITLE :TTITLESTR ;AMESSAGE :STRING ;ATOTAL :LONGINT ;AOPTIONS :WORD );CONSTRUCTOR LOAD
(VAR S :TSTREAM );PROCEDURE INCREMENT ;PROCEDURE INCREMENTBY (ASTEP :WORD );PROCEDURE STORE (VAR S :TSTREAM );END ;
PBXPRINTDIALOG =^TBXPRINTDIALOG ;TBXPRINTDIALOG =OBJECT (TBXRUNDIALOG)CONSTRUCTOR INIT (ATITLE :TTITLESTR ;
AMESSAGE :STRING ;AOPTIONS :WORD );END ;PBXLINKEDLINE =^TBXLINKEDLINE ;
TBXLINKEDLINE =OBJECT (TINPUTLINE)LINKEVENT :WORD ;CONSTRUCTOR INIT (VAR BOUNDS :TRECT ;AMAXLEN :INTEGER ;
EVENTCODE :WORD );CONSTRUCTOR LOAD (VAR S :TSTREAM );PROCEDURE HANDLEEVENT (VAR EVENT :TEVENT );VIRTUAL;PROCEDURE STORE
(VAR S :TSTREAM );END ;PBXLINKEDBOX =^TBXLINKEDBOX ;TBXLINKEDBOX =OBJECT (TLISTBOX)LINKEVENT :WORD ;CONSTRUCTOR INIT
(VAR BOUNDS :TRECT ;ANUMCOLS :WORD ;ASCROLLBAR :PSCROLLBAR ;EVENTCODE :WORD );CONSTRUCTOR LOAD (VAR S :TSTREAM );
PROCEDURE FOCUSITEM (ITEM :INTEGER );VIRTUAL;PROCEDURE STORE (VAR S :TSTREAM );END ;
PBXMESSAGEDIALOG =^TBXMESSAGEDIALOG ;TBXMESSAGEDIALOG =OBJECT (TDIALOG)SLIST :TBXUNSORTEDSTRINGCOLLECTION ;
DOPTIONS :WORD ;CONSTRUCTOR INIT (AOPTIONS :WORD );PROCEDURE ADDMESSAGE (ST :STRING );FUNCTION EXECUTE :WORD ;VIRTUAL;
END ;PBXLISTBOX =^TBXLISTBOX ;TBXLISTBOX =OBJECT (TLISTBOX)FUNCTION GETTEXT (ITEM :INTEGER ;MAXLEN :INTEGER ):STRING ;
VIRTUAL;END ;PBXCHECKLISTBOX =^TBXCHECKLISTBOX ;TBXCHECKLISTBOX =OBJECT (TBXLISTBOX)PROCEDURE GETSELECTSET
(VAR ASET :TBXBYTESET );FUNCTION GETTEXT (ITEM :INTEGER ;MAXLEN :INTEGER ):STRING ;VIRTUAL;PROCEDURE HANDLEEVENT
(VAR EVENT :TEVENT );VIRTUAL;FUNCTION ISSELECTED (ITEM :INTEGER ):BOOLEAN ;VIRTUAL;PROCEDURE SELECTITEM (ITEM :INTEGER );
VIRTUAL;PROCEDURE SETSELECTSET (ASET :TBXBYTESET );END ;PBXPAIREDLISTBOX =^TBXPAIREDLISTBOX ;
TBXPAIREDLISTBOX =OBJECT (TBXLISTBOX)PROCEDURE SELECTITEM (ITEM :INTEGER );VIRTUAL;PROCEDURE HANDLEEVENT
(VAR EVENT :TEVENT );VIRTUAL;END ;PBXPAIREDSTRLISTBOX =^TBXPAIREDSTRLISTBOX ;
TBXPAIREDSTRLISTBOX =OBJECT (TBXPAIREDLISTBOX)FUNCTION GETTEXT (ITEM :INTEGER ;MAXLEN :INTEGER ):STRING ;VIRTUAL;END ;
PBXVLISTBOX =^TBXVLISTBOX ;TBXVLISTBOX =OBJECT (TLISTBOX)ATMIN :BOOLEAN ;ATMAX :BOOLEAN ;CONSTRUCTOR INIT
(BOUNDS :TRECT ;ANUMCOLS :WORD ;AHSCROLLBAR :PSCROLLBAR ;AVSCROLLBAR :PSCROLLBAR );CONSTRUCTOR LOAD (VAR S :TSTREAM );
FUNCTION FILLBYPAGE (GOFORWARD :BOOLEAN ):INTEGER ;VIRTUAL;FUNCTION FILLFROM (FROMTOP :BOOLEAN ):INTEGER ;VIRTUAL;
PROCEDURE FOCUSITEM (ITEM :INTEGER );VIRTUAL;FUNCTION GETITEM (ACOMMAND :WORD ):POBJECT ;VIRTUAL;PROCEDURE HANDLEEVENT
(VAR EVENT :TEVENT );VIRTUAL;FUNCTION LOOKUP (P :POBJECT ):BOOLEAN ;VIRTUAL;FUNCTION MATCHITEM (P :POBJECT ):BOOLEAN ;
VIRTUAL;PROCEDURE NEWLIST (ALIST :PCOLLECTION );VIRTUAL;FUNCTION PAGESIZE :INTEGER ;VIRTUAL;PROCEDURE SETCOMMANDSTATE
(ENABLE :BOOLEAN );END ;{$IFDEF USE_NEW_FILE_DIALOG} PBXFILECOLLECTION =^TBXFILECOLLECTION ;
TBXFILECOLLECTION =OBJECT (TFILECOLLECTION)FUNCTION COMPARE (KEY1 ,KEY2:POINTER ):INTEGER ;VIRTUAL;END ;
PBXFILELIST =^TBXFILELIST ;TBXFILELIST =OBJECT (TFILELIST)CONSTRUCTOR INIT (VAR BOUNDS :TRECT ;AWILDCARD :PATHSTR ;
ASCROLLBAR :PSCROLLBAR );PROCEDURE HANDLEEVENT (VAR EVENT :TEVENT );VIRTUAL;PROCEDURE FOCUSITEM (ITEM :INTEGER );
VIRTUAL;PROCEDURE READDIRECTORY (AWILDCARD :PATHSTR );VIRTUAL;END ;PBXDRIVELIST =^TBXDRIVELIST ;
TBXDRIVELIST =OBJECT (TBXFILELIST)CONSTRUCTOR INIT (VAR BOUNDS :TRECT ;ASCROLLBAR :PSCROLLBAR );PROCEDURE GETDRIVES
(VAR DRIVES :DRIVESET );PROCEDURE READDIRECTORY (AWILDCARD :PATHSTR );VIRTUAL;FUNCTION GETKEY (VAR S :STRING ):POINTER ;
VIRTUAL;END ;PBXFILEINPUTLINE =^TBXFILEINPUTLINE ;TBXFILEINPUTLINE =OBJECT (TFILEINPUTLINE)PROCEDURE HANDLEEVENT
(VAR EVENT :TEVENT );VIRTUAL;END ;PBXFILEINFOPANE =^TBXFILEINFOPANE ;
TBXFILEINFOPANE =OBJECT (TFILEINFOPANE)PROCEDURE DRAW ;VIRTUAL;END ;PBXDIRECTORYINFOPANE =^TBXDIRECTORYINFOPANE ;
TBXDIRECTORYINFOPANE =OBJECT (TVIEW)CONSTRUCTOR INIT (VAR BOUNDS :TRECT );FUNCTION GETPALETTE :PPALETTE ;VIRTUAL;
PROCEDURE HANDLEEVENT (VAR EVENT :TEVENT );VIRTUAL;PROCEDURE DRAW ;VIRTUAL;END ;PBXFILEDIALOG =^TBXFILEDIALOG ;
TBXFILEDIALOG =OBJECT (TFILEDIALOG)DRIVELIST :PBXDRIVELIST ;CONSTRUCTOR INIT (AWILDCARD :TWILDSTR ;ATITLE :STRING ;
INPUTNAME :STRING ;AOPTIONS :WORD ;HISTORYID :BYTE );END ;{$ENDIF} PROCEDURE REGISTERTVDIALOG ;
CONST RBXRUNDIALOG :TSTREAMREC =(OBJTYPE :5050 ;VMTLINK :OFS (TYPEOF (TBXRUNDIALOG )^);LOAD :@ TBXRUNDIALOG . LOAD ;
STORE :@ TBXRUNDIALOG . STORE );CONST RBXPERCENTDIALOG :TSTREAMREC =(OBJTYPE :5051 ;
VMTLINK :OFS (TYPEOF (TBXPERCENTDIALOG )^);LOAD :@ TBXPERCENTDIALOG . LOAD ;STORE :@ TBXPERCENTDIALOG . STORE );
CONST RBXPRINTDIALOG :TSTREAMREC =(OBJTYPE :5052 ;VMTLINK :OFS (TYPEOF (TBXPRINTDIALOG )^);LOAD :@ TBXPRINTDIALOG .
LOAD ;STORE :@ TBXPRINTDIALOG . STORE );CONST RBXLINKEDLINE :TSTREAMREC =(OBJTYPE :5053 ;
VMTLINK :OFS (TYPEOF (TBXLINKEDLINE )^);LOAD :@ TBXLINKEDLINE . LOAD ;STORE :@ TBXLINKEDLINE . STORE );
CONST RBXLINKEDBOX :TSTREAMREC =(OBJTYPE :5054 ;VMTLINK :OFS (TYPEOF (TBXLINKEDBOX )^);LOAD :@ TBXLINKEDBOX . LOAD ;
STORE :@ TBXLINKEDBOX . STORE );CONST RBXLISTBOX :TSTREAMREC =(OBJTYPE :5055 ;VMTLINK :OFS (TYPEOF (TBXLISTBOX )^);
LOAD :@ TBXLISTBOX . LOAD ;STORE :@ TBXLISTBOX . STORE );CONST RBXCHECKLISTBOX :TSTREAMREC =(OBJTYPE :5056 ;
VMTLINK :OFS (TYPEOF (TBXCHECKLISTBOX )^);LOAD :@ TBXCHECKLISTBOX . LOAD ;STORE :@ TBXCHECKLISTBOX . STORE );
CONST RBXPAIREDLISTBOX :TSTREAMREC =(OBJTYPE :5057 ;VMTLINK :OFS (TYPEOF (TBXPAIREDLISTBOX )^);LOAD :@ TBXPAIREDLISTBOX .
LOAD ;STORE :@ TBXPAIREDLISTBOX . STORE );CONST RBXPAIREDSTRLISTBOX :TSTREAMREC =(OBJTYPE :5058 ;
VMTLINK :OFS (TYPEOF (TBXPAIREDSTRLISTBOX )^);LOAD :@ TBXPAIREDSTRLISTBOX . LOAD ;STORE :@ TBXPAIREDSTRLISTBOX . STORE );
CONST RBXVLISTBOX :TSTREAMREC =(OBJTYPE :5059 ;VMTLINK :OFS (TYPEOF (TBXVLISTBOX )^);LOAD :@ TBXVLISTBOX . LOAD ;
STORE :@ TBXVLISTBOX . STORE );{$IFDEF USE_NEW_FILE_DIALOG} CONST RBXFILECOLLECTION :TSTREAMREC =(OBJTYPE :5060 ;
VMTLINK :OFS (TYPEOF (TBXFILECOLLECTION )^);LOAD :@ TBXFILECOLLECTION . LOAD ;STORE :@ TBXFILECOLLECTION . STORE );
CONST RBXFILELIST :TSTREAMREC =(OBJTYPE :5061 ;VMTLINK :OFS (TYPEOF (TBXFILELIST )^);LOAD :@ TBXFILELIST . LOAD ;
STORE :@ TBXFILELIST . STORE );CONST RBXDRIVELIST :TSTREAMREC =(OBJTYPE :5062 ;VMTLINK :OFS (TYPEOF (TBXDRIVELIST )^);
LOAD :@ TBXDRIVELIST . LOAD ;STORE :@ TBXDRIVELIST . STORE );CONST RBXFILEINPUTLINE :TSTREAMREC =(OBJTYPE :5063 ;
VMTLINK :OFS (TYPEOF (TBXFILEINPUTLINE )^);LOAD :@ TBXFILEINPUTLINE . LOAD ;STORE :@ TBXFILEINPUTLINE . STORE );
CONST RBXFILEINFOPANE :TSTREAMREC =(OBJTYPE :5064 ;VMTLINK :OFS (TYPEOF (TBXFILEINFOPANE )^);LOAD :@ TBXFILEINFOPANE .
LOAD ;STORE :@ TBXFILEINFOPANE . STORE );CONST RBXDIRECTORYINFOPANE :TSTREAMREC =(OBJTYPE :5065 ;
VMTLINK :OFS (TYPEOF (TBXDIRECTORYINFOPANE )^);LOAD :@ TBXDIRECTORYINFOPANE . LOAD ;STORE :@ TBXDIRECTORYINFOPANE .
STORE );CONST RBXFILEDIALOG :TSTREAMREC =(OBJTYPE :5066 ;VMTLINK :OFS (TYPEOF (TBXFILEDIALOG )^);LOAD :@ TBXFILEDIALOG .
LOAD ;STORE :@ TBXFILEDIALOG . STORE );{$ENDIF} IMPLEMENTATION CONSTRUCTOR TBXRUNDIALOG.INIT (VAR BOUNDS:TRECT;
ATITLE:TTITLESTR;AMESSAGE:STRING ;AOPTIONS:WORD;BUTTONROW:BYTE);VAR OO1I:TRECT;BEGIN INHERITED INIT(BOUNDS , ATITLE );
PFFLAGS := AOPTIONS ;FLAGS := FLAGS AND NOT WFCLOSE ;BTNROW := BUTTONROW ;RUNSTATE := 0 ;IF ((PFFLAGS AND MFMESSAGELINE
)<> 0 )THEN BEGIN OO1I.ASSIGN (2 , 1 , 42 , 2 );MSG := NEW (PSTATICTEXT , INIT (OO1I , AMESSAGE ));INSERT (MSG );END ;IF
((PFFLAGS AND MFOKCANCEL )=MFOKCANCEL )THEN BEGIN OO1I.ASSIGN (11 , BTNROW , 20 , BTNROW + 2 );SBUTTON := NEW (PBUTTON ,
INIT (OO1I , 'Start', CMSTARTJOB , BFDEFAULT ));INSERT (SBUTTON );OO1I.ASSIGN (24 , BTNROW , 34 , BTNROW + 2 );CBUTTON :=
NEW (PBUTTON , INIT (OO1I , 'Cancel', CMCANCELJOB , BFNORMAL ));INSERT (CBUTTON );END ELSE IF ((PFFLAGS AND MFOKBUTTON
)<> 0 )THEN BEGIN OO1I.ASSIGN (17 , BTNROW , 26 , BTNROW + 2 );SBUTTON := NEW (PBUTTON , INIT (OO1I , 'Start', CMSTARTJOB
, BFDEFAULT ));INSERT (SBUTTON );CBUTTON := NIL ;END ELSE IF ((PFFLAGS AND MFCANCELBUTTON )<> 0 )THEN BEGIN OO1I.ASSIGN
(16 , BTNROW , 26 , BTNROW + 2 );CBUTTON := NEW (PBUTTON , INIT (OO1I , 'Cancel', CMCANCELJOB , BFDEFAULT ));INSERT
(CBUTTON );SBUTTON := NIL ;END ;SELECTNEXT (FALSE );END ;CONSTRUCTOR TBXRUNDIALOG.LOAD (VAR S:TSTREAM);
BEGIN INHERITED LOAD(S );GETSUBVIEWPTR (S , MSG );S.READ (RUNSTATE , SIZEOF (WORD ));S.READ (PFFLAGS , SIZEOF (WORD ));
S.READ (BTNROW , SIZEOF (BYTE ));GETSUBVIEWPTR (S , SBUTTON );GETSUBVIEWPTR (S , CBUTTON );END ;
PROCEDURE TBXRUNDIALOG.CHANGEMESSAGE (AMESSAGE:STRING );BEGIN IF (MSG <> NIL )THEN BEGIN DISPOSESTR (MSG ^. TEXT );MSG ^.
TEXT := NEWSTR (AMESSAGE );MSG ^. DRAWVIEW ;END ;END ;FUNCTION TBXRUNDIALOG.EXECUTE :WORD ;VAR OIOO0l010lO:TEVENT;
BEGIN IF ((PFFLAGS AND MFOKBUTTON )=0 )THEN RUNSTATE := CMSTARTJOB ;REPEAT GETEVENT (OIOO0l010lO );HANDLEEVENT
(OIOO0l010lO );PROCESS ;UNTIL (RUNSTATE > CMCONTINUEJOB );EXECUTE := RUNSTATE ;END ;PROCEDURE TBXRUNDIALOG.HANDLEEVENT
(VAR EVENT:TEVENT);VAR OO1I:TRECT;PROCEDURE OO10OO1l1I1 (OOllO00lIO0I:PBUTTON);BEGIN IF (OOllO00lIO0I <> NIL )THEN
BEGIN DELETE (OOllO00lIO0I );DISPOSE (OOllO00lIO0I , DONE );END ;END ;BEGIN TWINDOW.HANDLEEVENT (EVENT );CASE EVENT.WHAT
 OF EVKEYDOWN :CASE EVENT.KEYCODE  OF KBESC :BEGIN EVENT.WHAT := EVCOMMAND ;EVENT.COMMAND := CMCANCELJOB ;EVENT.INFOPTR
:= NIL ;PUTEVENT (EVENT );CLEAREVENT (EVENT );END ;KBENTER :BEGIN EVENT.WHAT := EVBROADCAST ;EVENT.COMMAND := CMDEFAULT ;
EVENT.INFOPTR := NIL ;PUTEVENT (EVENT );CLEAREVENT (EVENT );END ;END ;EVCOMMAND :CASE EVENT.COMMAND  OF CMCANCELJOB ,
CMJOBCOMPLETE , CMPAUSEJOB , CMCONTINUEJOB , CMSTARTJOB :BEGIN CASE EVENT.COMMAND  OF CMCONTINUEJOB , CMSTARTJOB
:BEGIN LOCK ;OO10OO1l1I1 (SBUTTON );OO10OO1l1I1 (CBUTTON );IF ((PFFLAGS AND MFPAUSECANCEL )=MFPAUSECANCEL )THEN
BEGIN OO1I.ASSIGN (11 , BTNROW , 20 , BTNROW + 2 );SBUTTON := NEW (PBUTTON , INIT (OO1I , 'Pause', CMPAUSEJOB , BFDEFAULT
));SBUTTON ^. STATE := SBUTTON ^. STATE OR SFACTIVE ;INSERT (SBUTTON );OO1I.ASSIGN (24 , BTNROW , 34 , BTNROW + 2 );
CBUTTON := NEW (PBUTTON , INIT (OO1I , 'Cancel', CMCANCELJOB , BFNORMAL ));INSERT (CBUTTON );CBUTTON ^. STATE := CBUTTON
^. STATE OR SFACTIVE ;END ELSE IF ((PFFLAGS AND MFPAUSEBUTTON )<> 0 )THEN BEGIN OO1I.ASSIGN (17 , BTNROW , 26 , BTNROW +
2 );SBUTTON := NEW (PBUTTON , INIT (OO1I , 'Pause', CMPAUSEJOB , BFDEFAULT ));INSERT (SBUTTON );CBUTTON := NIL ;SBUTTON
^. STATE := SBUTTON ^. STATE OR SFACTIVE ;END ELSE IF ((PFFLAGS AND MFCANCELBUTTON )<> 0 )THEN BEGIN OO1I.ASSIGN (16 ,
BTNROW , 26 , BTNROW + 2 );CBUTTON := NEW (PBUTTON , INIT (OO1I , 'Cancel', CMCANCELJOB , BFDEFAULT ));INSERT (CBUTTON );
SBUTTON := NIL ;CBUTTON ^. STATE := CBUTTON ^. STATE OR SFACTIVE ;END ;SELECTNEXT (FALSE );DRAWVIEW ;UNLOCK ;END ;
CMPAUSEJOB :BEGIN LOCK ;OO10OO1l1I1 (SBUTTON );OO10OO1l1I1 (CBUTTON );IF ((PFFLAGS AND MFPAUSECANCEL )=MFPAUSECANCEL
)THEN BEGIN OO1I.ASSIGN (10 , BTNROW , 22 , BTNROW + 2 );SBUTTON := NEW (PBUTTON , INIT (OO1I , 'Continue', CMCONTINUEJOB
, BFDEFAULT ));INSERT (SBUTTON );OO1I.ASSIGN (25 , BTNROW , 35 , BTNROW + 2 );CBUTTON := NEW (PBUTTON , INIT (OO1I ,
'Cancel', CMCANCELJOB , BFNORMAL ));INSERT (CBUTTON );SBUTTON ^. STATE := SBUTTON ^. STATE OR SFACTIVE ;CBUTTON ^. STATE
:= CBUTTON ^. STATE OR SFACTIVE ;END ELSE BEGIN OO1I.ASSIGN (15 , BTNROW , 27 , BTNROW + 2 );SBUTTON := NEW (PBUTTON ,
INIT (OO1I , 'Continue', CMCONTINUEJOB , BFDEFAULT ));INSERT (SBUTTON );CBUTTON := NIL ;SBUTTON ^. STATE := SBUTTON ^.
STATE OR SFACTIVE ;END ;SELECTNEXT (FALSE );DRAWVIEW ;UNLOCK ;END ;END ;RUNSTATE := EVENT.COMMAND ;CLEAREVENT (EVENT );
END ;END ;END ;END ;PROCEDURE TBXRUNDIALOG.PROCESS ;BEGIN END ;PROCEDURE TBXRUNDIALOG.STORE (VAR S:TSTREAM);
BEGIN INHERITED STORE(S );PUTSUBVIEWPTR (S , MSG );S.WRITE (RUNSTATE , SIZEOF (WORD ));S.WRITE (PFFLAGS , SIZEOF (WORD
));S.WRITE (BTNROW , SIZEOF (BYTE ));PUTSUBVIEWPTR (S , SBUTTON );PUTSUBVIEWPTR (S , CBUTTON );END ;
CONSTRUCTOR TBXPERCENTDIALOG.INIT (ATITLE:TTITLESTR;AMESSAGE:STRING ;ATOTAL:LONGINT;AOPTIONS:WORD);VAR OO1I:TRECT;
BEGIN OO1I.ASSIGN (0 , 0 , 44 , 10 );INHERITED INIT(OO1I , ATITLE , AMESSAGE , AOPTIONS , 7 );OPTIONS := OPTIONS OR
OFCENTERED ;TOTAL := ATOTAL ;STEP := TOTAL DIV 25 ;IF (TOTAL MOD 25 <> 0 )THEN INC (STEP );OO1I.ASSIGN (9 , 3 , 36 , 4 );
INSERT (NEW (PSTATICTEXT , INIT (OO1I , '�������������������������Ŀ')));OO1I.ASSIGN (9 , 4 , 36 , 5 );INSERT (NEW
(PSTATICTEXT , INIT (OO1I , '�                         �')));OO1I.ASSIGN (9 , 5 , 36 , 6 );INSERT (NEW (PSTATICTEXT ,
INIT (OO1I , '���������������������������')));OO1I.ASSIGN (20 , 2 , 25 , 3 );PCT := NEW (PSTATICTEXT , INIT (OO1I ,
'0%  '));INSERT (PCT );OO1I.ASSIGN (10 , 4 , 35 , 5 );BAR := NEW (PSTATICTEXT , INIT (OO1I , CHARS (25 , BARCHAR )));
INSERT (BAR );END ;CONSTRUCTOR TBXPERCENTDIALOG.LOAD (VAR S:TSTREAM);VAR OO1I:TRECT;BEGIN INHERITED LOAD(S );S.READ
(TOTAL , SIZEOF (LONGINT ));S.READ (COUNT , SIZEOF (LONGINT ));S.READ (STEP , SIZEOF (WORD ));GETSUBVIEWPTR (S , PCT );
GETSUBVIEWPTR (S , BAR );OO1I.ASSIGN (9 , 3 , 36 , 4 );INSERT (NEW (PSTATICTEXT , INIT (OO1I ,
'�������������������������Ŀ')));OO1I.ASSIGN (9 , 4 , 36 , 5 );INSERT (NEW (PSTATICTEXT , INIT (OO1I ,
'�                         �')));OO1I.ASSIGN (9 , 5 , 36 , 6 );INSERT (NEW (PSTATICTEXT , INIT (OO1I ,
'���������������������������')));END ;PROCEDURE TBXPERCENTDIALOG.STORE (VAR S:TSTREAM);BEGIN INHERITED STORE(S );S.WRITE
(TOTAL , SIZEOF (LONGINT ));S.WRITE (COUNT , SIZEOF (LONGINT ));S.WRITE (STEP , SIZEOF (WORD ));PUTSUBVIEWPTR (S , PCT );
PUTSUBVIEWPTR (S , BAR );END ;PROCEDURE TBXPERCENTDIALOG.INCREMENT ;BEGIN INCREMENTBY (1 );END ;
PROCEDURE TBXPERCENTDIALOG.INCREMENTBY (ASTEP:WORD);VAR O100lll0I1l:REAL;OOIO:WORD;OO0O:STRING [ 3 ] ;BEGIN IF (COUNT <
TOTAL )THEN BEGIN COUNT := COUNT + ASTEP ;IF (COUNT >= TOTAL )THEN BEGIN FILLCHAR (BAR ^. TEXT ^[ 1 ] , 25 , BARFILLCHAR
);BAR ^. DRAWVIEW ;PCT ^. TEXT ^:= '100%';PCT ^. DRAWVIEW ;END ELSE IF ((COUNT MOD STEP )=0 )THEN BEGIN O100lll0I1l :=
(COUNT / TOTAL )* 100 ;OOIO := ROUND (O100lll0I1l / 4 );FILLCHAR (BAR ^. TEXT ^[ 1 ] , OOIO , BARFILLCHAR );BAR ^.
DRAWVIEW ;STR (O100lll0I1l :3 :0 , OO0O );PCT ^. TEXT ^:= OO0O + '%';PCT ^. DRAWVIEW ;END ;END ;END ;
CONSTRUCTOR TBXPRINTDIALOG.INIT (ATITLE:TTITLESTR;AMESSAGE:STRING ;AOPTIONS:WORD);VAR OO1I:TRECT;BEGIN OO1I.ASSIGN (0 , 0
, 44 , 7 );INHERITED INIT(OO1I , ATITLE , AMESSAGE , AOPTIONS , 4 );OPTIONS := OPTIONS OR OFCENTERED ;END ;
CONSTRUCTOR TBXLINKEDBOX.INIT (VAR BOUNDS:TRECT;ANUMCOLS:WORD;ASCROLLBAR:PSCROLLBAR;EVENTCODE:WORD);
BEGIN INHERITED INIT(BOUNDS , ANUMCOLS , ASCROLLBAR );LINKEVENT := EVENTCODE ;END ;CONSTRUCTOR TBXLINKEDBOX.LOAD
(VAR S:TSTREAM);BEGIN INHERITED LOAD(S );S.READ (LINKEVENT , SIZEOF (WORD ));END ;PROCEDURE TBXLINKEDBOX.FOCUSITEM
(ITEM:INTEGER);BEGIN INHERITED FOCUSITEM(ITEM );MESSAGE (OWNER , EVBROADCAST , LINKEVENT , LIST ^. AT (ITEM ));END ;
PROCEDURE TBXLINKEDBOX.STORE (VAR S:TSTREAM);BEGIN INHERITED STORE(S );S.WRITE (LINKEVENT , SIZEOF (WORD ));END ;
CONSTRUCTOR TBXLINKEDLINE.INIT (VAR BOUNDS:TRECT;AMAXLEN:INTEGER;EVENTCODE:WORD);BEGIN INHERITED INIT(BOUNDS , AMAXLEN );
LINKEVENT := EVENTCODE ;EVENTMASK := EVENTMASK OR EVBROADCAST ;END ;CONSTRUCTOR TBXLINKEDLINE.LOAD (VAR S:TSTREAM);
BEGIN INHERITED LOAD(S );S.READ (LINKEVENT , SIZEOF (WORD ));END ;PROCEDURE TBXLINKEDLINE.HANDLEEVENT (VAR EVENT:TEVENT);
VAR OO1O:STRING ;BEGIN INHERITED HANDLEEVENT(EVENT );IF (EVENT.WHAT =EVBROADCAST )THEN IF (EVENT.COMMAND =LINKEVENT )THEN
IF (STATE AND SFSELECTED =0 )THEN BEGIN SETDATA (PSTRING (EVENT.INFOPTR )^);DRAWVIEW ;CLEAREVENT (EVENT );END ;END ;
PROCEDURE TBXLINKEDLINE.STORE (VAR S:TSTREAM);BEGIN INHERITED STORE(S );S.WRITE (LINKEVENT , SIZEOF (WORD ));END ;
CONSTRUCTOR TBXMESSAGEDIALOG.INIT (AOPTIONS:WORD);VAR OO1I:TRECT;BEGIN OO1I.ASSIGN (0 , 0 , 4 , 4 );INHERITED INIT(OO1I ,
TITLES [ AOPTIONS AND $3 ] );DOPTIONS := AOPTIONS ;SLIST.INIT (15 , 5 );END ;PROCEDURE TBXMESSAGEDIALOG.ADDMESSAGE
(ST:STRING );VAR OO10:PSTRING;BEGIN GETMEM (OO10 , LENGTH (ST )+ 1 );IF (OO10 <> NIL )THEN BEGIN OO10 ^:= ST ;
SLIST.INSERT (OO10 );END ;END ;FUNCTION TBXMESSAGEDIALOG.EXECUTE :WORD ;VAR OO10:POINTER;Ol0101I,Ol0101O:BYTE;
OOIO,OOIl:BYTE;OIlO:BYTE;OIOO101OlII:BYTE;OIIll0II0OO:INTEGER;OI11I1O1l00:INTEGER;OO1I:TRECT;BEGIN HIDE ;DESKTOP ^.
GETEXTENT (OO1I );OOIO := 0 ;FOR OIlO := 0 TO SLIST.COUNT - 1  DO BEGIN OO10 := SLIST.AT (OIlO );IF (BYTE (OO10 ^)>
OO1I.B.X )THEN BYTE (OO10 ^):= OO1I.B.X ;IF (BYTE (OO10 ^)> OOIO )THEN OOIO := BYTE (OO10 ^);END ;OIOO101OlII := 0 ;
FOR OIlO := 0 TO 3  DO IF (DOPTIONS AND ($0100 SHL OIlO )<> 0 )THEN INC (OIOO101OlII );IF ((OIOO101OlII * 11 + 1 )> OOIO
)THEN OOIO := OIOO101OlII * 11 + 1 ;OOIO := OOIO + 2 ;OOIl := SLIST.COUNT + 2 ;IF (BUTTONCOUNT > 0 )THEN OOIl := OOIl + 3
;IF (OOIl > OO1I.B.Y )THEN OOIl := OO1I.B.Y ;Ol0101I := (OO1I.B.X - OOIO )DIV 2 ;Ol0101O := (OO1I.B.Y - OOIl )DIV 2 ;
OO1I.ASSIGN (Ol0101I , Ol0101O , Ol0101I + OOIO , Ol0101O + OOIl );CHANGEBOUNDS (OO1I );IF (OIOO101OlII > 0 )THEN
BEGIN OIIll0II0OO := SIZE.X - (OIOO101OlII * 9 );OI11I1O1l00 := OIIll0II0OO DIV (OIOO101OlII + 1 );OOIO := OI11I1O1l00 +
(OIIll0II0OO MOD OIOO101OlII )SHR 1 ;FOR OIlO := 0 TO 3  DO IF (DOPTIONS AND ($0100 SHL OIlO )<> 0 )THEN
BEGIN OO1I.ASSIGN (OOIO , SIZE.Y - 3 , OOIO + 10 , SIZE.Y - 1 );INSERT (NEW (PBUTTON , INIT (OO1I , BUTTONS [ OIlO ] ,
COMMANDS [ OIlO ] , BFNORMAL )));INC (OOIO , OI11I1O1l00 + 8 );END ;SELECTNEXT (FALSE );END ;OOIO := SLIST.COUNT ;IF
(OOIO > OOIl - 4 )THEN OOIO := OOIl - 4 ;FOR OIlO := 0 TO OOIO - 1  DO BEGIN OO1I.ASSIGN (1 , OIlO + 1 , SIZE.X - 1 ,
OIlO + 2 );INSERT (NEW (PSTATICTEXT , INIT (OO1I , PSTRING (SLIST.AT (OIlO ))^)));END ;SLIST.DONE ;SHOW ;EXECUTE :=
INHERITED EXECUTE;END ;FUNCTION TBXLISTBOX.GETTEXT (ITEM:INTEGER;MAXLEN:INTEGER):STRING ;BEGIN GETTEXT := PBXOBJECT (LIST
^. AT (ITEM ))^. GETTEXT (MAXLEN );END ;PROCEDURE TBXCHECKLISTBOX.GETSELECTSET (VAR ASET:TBXBYTESET);VAR OIlO:BYTE;
OOIO:INTEGER;BEGIN OOIO := LIST ^. COUNT - 1 ;IF (OOIO > 255 )THEN OOIO := 255 ;ASET := [ ] ;FOR OIlO := 0 TO OOIO  DO IF
PBXSELECTOBJECT (LIST ^. AT (OIlO ))^. GETSELECT THEN ASET := ASET + [ OIlO ] ;END ;FUNCTION TBXCHECKLISTBOX.GETTEXT
(ITEM:INTEGER;MAXLEN:INTEGER):STRING ;BEGIN IF PBXSELECTOBJECT (LIST ^. AT (ITEM ))^. GETSELECT THEN GETTEXT := '[X] '+
PBXSELECTSTR (LIST ^. AT (ITEM ))^. GETTEXT (MAXLEN - 3 )ELSE GETTEXT := '[ ] '+ PBXSELECTSTR (LIST ^. AT (ITEM ))^.
GETTEXT (MAXLEN - 3 );END ;PROCEDURE TBXCHECKLISTBOX.HANDLEEVENT (VAR EVENT:TEVENT);VAR OI1I1O1lll10:TPOINT;
OIlIl0l11OO:WORD;OI1000l1II00:INTEGER;BEGIN IF (EVENT.WHAT =EVMOUSEDOWN )THEN BEGIN MAKELOCAL (EVENT.WHERE , OI1I1O1lll10
);IF MOUSEINVIEW (EVENT.WHERE )THEN BEGIN OIlIl0l11OO := SIZE.X DIV NUMCOLS + 1 ;OI1000l1II00 := OI1I1O1lll10.Y + (SIZE.Y
* (OI1I1O1lll10.X DIV OIlIl0l11OO ))+ TOPITEM ;SELECTITEM (OI1000l1II00 );END ;END ;INHERITED HANDLEEVENT(EVENT );END ;
FUNCTION TBXCHECKLISTBOX.ISSELECTED (ITEM:INTEGER):BOOLEAN ;BEGIN ISSELECTED := PBXSELECTOBJECT (LIST ^. AT (ITEM ))^.
GETSELECT ;END ;PROCEDURE TBXCHECKLISTBOX.SELECTITEM (ITEM:INTEGER);BEGIN PBXSELECTOBJECT (LIST ^. AT (ITEM ))^.
SETSELECT (NOT PBXSELECTOBJECT (LIST ^. AT (ITEM ))^. GETSELECT );DRAWVIEW ;END ;PROCEDURE TBXCHECKLISTBOX.SETSELECTSET
(ASET:TBXBYTESET);VAR OIlO:BYTE;OOIO:INTEGER;BEGIN OOIO := LIST ^. COUNT - 1 ;IF (OOIO > 255 )THEN OOIO := 255 ;FOR OIlO
:= 0 TO OOIO  DO PBXSELECTOBJECT (LIST ^. AT (OIlO ))^. SETSELECT (OIlO IN ASET );END ;
PROCEDURE TBXPAIREDLISTBOX.SELECTITEM (ITEM:INTEGER);VAR OO10:PBXITEMREC;BEGIN INHERITED SELECTITEM(ITEM );NEW (OO10 );
OO10 ^. ITEM := LIST ^. AT (ITEM );OO10 ^. OWNER := @ SELF ;LIST ^. ATDELETE (ITEM );SETRANGE (LIST ^. COUNT );MESSAGE
(OWNER , EVBROADCAST , CMTAKEITEM , OO10 );DRAWVIEW ;END ;PROCEDURE TBXPAIREDLISTBOX.HANDLEEVENT (VAR EVENT:TEVENT);
VAR OI1I1O1lll10:TPOINT;OIlIl0l11OO:WORD;OII0OO0lllO:INTEGER;BEGIN CASE EVENT.WHAT  OF EVBROADCAST :CASE EVENT.COMMAND
 OF CMTAKEITEM :IF (PBXITEMREC (EVENT.INFOPTR )^. OWNER <> @ SELF )THEN BEGIN LIST ^. INSERT (PBXITEMREC (EVENT.INFOPTR
)^. ITEM );SETRANGE (LIST ^. COUNT );DISPOSE (PBXITEMREC (EVENT.INFOPTR ));CLEAREVENT (EVENT );DRAWVIEW ;END ;END ;
EVMOUSEDOWN :BEGIN MAKELOCAL (EVENT.WHERE , OI1I1O1lll10 );IF MOUSEINVIEW (EVENT.WHERE )THEN BEGIN OIlIl0l11OO := SIZE.X
DIV NUMCOLS + 1 ;OII0OO0lllO := OI1I1O1lll10.Y + (SIZE.Y * (OI1I1O1lll10.X DIV OIlIl0l11OO ))+ TOPITEM ;IF (OII0OO0lllO <
LIST ^. COUNT )THEN BEGIN IF EVENT.DOUBLE THEN BEGIN SELECTITEM (OII0OO0lllO );CLEAREVENT (EVENT );END END ELSE
BEGIN CLEAREVENT (EVENT );END ;END ;END ;END ;INHERITED HANDLEEVENT(EVENT );END ;FUNCTION TBXPAIREDSTRLISTBOX.GETTEXT
(ITEM:INTEGER;MAXLEN:INTEGER):STRING ;BEGIN IF (LIST <> NIL )THEN GETTEXT := FTRUNCATESTR (PSTRING (LIST ^. AT (ITEM ))^,
MAXLEN )ELSE GETTEXT := '';END ;CONSTRUCTOR TBXVLISTBOX.INIT (BOUNDS:TRECT;ANUMCOLS:WORD;AHSCROLLBAR:PSCROLLBAR;
AVSCROLLBAR:PSCROLLBAR);BEGIN TLISTVIEWER.INIT (BOUNDS , ANUMCOLS , AHSCROLLBAR , AVSCROLLBAR );LIST := NIL ;SETRANGE (0
);ATMIN := FALSE ;ATMAX := FALSE ;SETCOMMANDSTATE (FALSE );END ;CONSTRUCTOR TBXVLISTBOX.LOAD (VAR S:TSTREAM);
BEGIN INHERITED LOAD(S );ATMIN := FALSE ;ATMAX := FALSE ;END ;FUNCTION TBXVLISTBOX.FILLBYPAGE (GOFORWARD:BOOLEAN):INTEGER
;VAR O10OOll1OlI01:INTEGER;OOIO,O1l1llO110:INTEGER;OI1000l1II00:POBJECT;O1OlOIlO010O:WORD;BEGIN FILLBYPAGE := 0 ;IF (LIST
^. COUNT > 0 )THEN BEGIN IF GOFORWARD THEN BEGIN OI1000l1II00 := GETITEM (VLLISTMAX );O1OlOIlO010O := VLNEXT ;O1l1llO110
:= 0 ;END ELSE BEGIN OI1000l1II00 := GETITEM (VLLISTMIN );O1OlOIlO010O := VLPREV ;O1l1llO110 := LIST ^. COUNT - 1 ;END ;
DISPOSE (OI1000l1II00 , DONE );OI1000l1II00 := GETITEM (O1OlOIlO010O );O10OOll1OlI01 := PAGESIZE ;OOIO := 0 ;
WHILE (OI1000l1II00 <> NIL )AND (OOIO < O10OOll1OlI01 ) DO BEGIN IF (LIST ^. COUNT =LIST ^. LIMIT )THEN LIST ^. FREE
(LIST ^. AT (O1l1llO110 ));IF GOFORWARD THEN LIST ^. INSERT (OI1000l1II00 )ELSE LIST ^. ATINSERT (0 , OI1000l1II00 );INC
(OOIO );IF (OOIO < O10OOll1OlI01 )THEN OI1000l1II00 := GETITEM (O1OlOIlO010O );END ;IF GOFORWARD THEN BEGIN ATMAX :=
(OOIO < O10OOll1OlI01 );IF ATMIN THEN ATMIN := (OOIO =0 );END ELSE BEGIN ATMIN := (OOIO < O10OOll1OlI01 );IF ATMAX THEN
ATMAX := (OOIO =0 );END ;FILLBYPAGE := OOIO ;SETCOMMANDSTATE (TRUE );DRAW ;END ;END ;FUNCTION TBXVLISTBOX.FILLFROM
(FROMTOP:BOOLEAN):INTEGER ;VAR OOIO:INTEGER;O1OlOIlO010O:WORD;OI1000l1II00:POBJECT;OOIOOI01l0:INTEGER;BEGIN IF FROMTOP
THEN BEGIN OI1000l1II00 := GETITEM (VLMIN );O1OlOIlO010O := VLNEXT END ELSE BEGIN OI1000l1II00 := GETITEM (VLMAX );
O1OlOIlO010O := VLPREV ;END ;OOIO := 0 ;OOIOOI01l0 := LIST ^. LIMIT ;LIST ^. FREEALL ;WHILE (OI1000l1II00 <> NIL )AND
(OOIO < OOIOOI01l0 ) DO BEGIN IF FROMTOP THEN LIST ^. INSERT (OI1000l1II00 )ELSE LIST ^. ATINSERT (0 , OI1000l1II00 );
INC (OOIO );IF (OOIO < OOIOOI01l0 )THEN OI1000l1II00 := GETITEM (O1OlOIlO010O );END ;IF FROMTOP THEN BEGIN ATMIN := TRUE
;ATMAX := (OOIO < OOIOOI01l0 );END ELSE BEGIN ATMAX := TRUE ;ATMIN := (OOIO < OOIOOI01l0 );END ;SETRANGE (LIST ^. COUNT
);SETCOMMANDSTATE (TRUE );DRAW ;FILLFROM := OOIO ;END ;PROCEDURE TBXVLISTBOX.FOCUSITEM (ITEM:INTEGER);
BEGIN INHERITED FOCUSITEM(ITEM );DRAW ;END ;FUNCTION TBXVLISTBOX.GETITEM (ACOMMAND:WORD):POBJECT ;BEGIN RUNERROR (211 );
END ;PROCEDURE TBXVLISTBOX.HANDLEEVENT (VAR EVENT:TEVENT);VAR OIlllI0OIOO:WORD;BEGIN CASE EVENT.WHAT  OF EVBROADCAST
:BEGIN CASE EVENT.COMMAND  OF CMPREVPAGE :IF NOT ATMIN THEN FILLBYPAGE (FALSE );CMNEXTPAGE :IF NOT ATMAX THEN FILLBYPAGE
(TRUE );CMFIRSTPAGE :IF NOT ATMIN THEN FILLFROM (TRUE );CMLASTPAGE :IF NOT ATMAX THEN FILLFROM (FALSE );END ;END ;END ;
INHERITED HANDLEEVENT(EVENT );END ;FUNCTION TBXVLISTBOX.LOOKUP (P:POBJECT):BOOLEAN ;VAR OOIOOI01l0:INTEGER;BEGIN LOOKUP
:= FALSE ;IF (P <> NIL )THEN IF MATCHITEM (P )THEN BEGIN OOIOOI01l0 := LIST ^. LIMIT ;LIST ^. FREEALL ;WHILE (P <> NIL
)AND (LIST ^. COUNT < LIST ^. LIMIT ) DO BEGIN LIST ^. INSERT (P );IF (LIST ^. COUNT < LIST ^. LIMIT )THEN P := GETITEM
(VLNEXT );END ;ATMAX := (P =NIL );ATMIN := FALSE ;LOOKUP := TRUE ;SETRANGE (LIST ^. COUNT );SETCOMMANDSTATE (TRUE );
FOCUSITEM (0 );END ;END ;FUNCTION TBXVLISTBOX.MATCHITEM (P:POBJECT):BOOLEAN ;BEGIN MATCHITEM := FALSE ;END ;
PROCEDURE TBXVLISTBOX.NEWLIST (ALIST:PCOLLECTION);BEGIN INHERITED NEWLIST(ALIST );SETCOMMANDSTATE (TRUE );END ;
FUNCTION TBXVLISTBOX.PAGESIZE :INTEGER ;BEGIN PAGESIZE := LIST ^. LIMIT DIV 3 ;END ;
PROCEDURE TBXVLISTBOX.SETCOMMANDSTATE (ENABLE:BOOLEAN);BEGIN IF ATMAX OR NOT ENABLE THEN DISABLECOMMANDS ([ CMNEXTPAGE ,
CMLASTPAGE ] )ELSE IF NOT ATMAX THEN ENABLECOMMANDS ([ CMNEXTPAGE , CMLASTPAGE ] );IF ATMIN OR NOT ENABLE THEN
DISABLECOMMANDS ([ CMPREVPAGE , CMFIRSTPAGE ] )ELSE IF NOT ATMIN THEN ENABLECOMMANDS ([ CMPREVPAGE , CMFIRSTPAGE ] );
END ;{$IFDEF USE_NEW_FILE_DIALOG} FUNCTION TBXFILECOLLECTION.COMPARE (KEY1,KEY2:POINTER):INTEGER ;BEGIN IF PSEARCHREC
(KEY1 )^. NAME =PSEARCHREC (KEY2 )^. NAME THEN COMPARE := 0 ELSE IF PSEARCHREC (KEY1 )^. NAME ='..'THEN COMPARE := - 1
ELSE IF PSEARCHREC (KEY2 )^. NAME ='..'THEN COMPARE := 1 ELSE IF (PSEARCHREC (KEY1 )^. ATTR AND VOLUMEID <> 0 )AND
(PSEARCHREC (KEY2 )^. ATTR AND VOLUMEID =0 )THEN COMPARE := 1 ELSE IF (PSEARCHREC (KEY2 )^. ATTR AND VOLUMEID <> 0 )AND
(PSEARCHREC (KEY1 )^. ATTR AND VOLUMEID =0 )THEN COMPARE := - 1 ELSE IF PSEARCHREC (KEY1 )^. NAME > PSEARCHREC (KEY2 )^.
NAME THEN COMPARE := 1 ELSE COMPARE := - 1 ;END ;CONSTRUCTOR TBXFILELIST.INIT (VAR BOUNDS:TRECT;AWILDCARD:PATHSTR;
ASCROLLBAR:PSCROLLBAR);BEGIN TSORTEDLISTBOX.INIT (BOUNDS , 1 , ASCROLLBAR );END ;PROCEDURE TBXFILELIST.HANDLEEVENT
(VAR EVENT:TEVENT);VAR OIOl:TEVENT;BEGIN IF (EVENT.WHAT =EVBROADCAST )AND (EVENT.COMMAND =CMRECEIVEDFOCUS )AND
(EVENT.INFOPTR =@ SELF )THEN BEGIN FOCUSITEM (FOCUSED )END ELSE BEGIN IF (EVENT.WHAT =EVMOUSEDOWN )AND (EVENT.DOUBLE
)THEN MESSAGE (OWNER , EVBROADCAST , CMRECORDHISTORY , NIL );INHERITED HANDLEEVENT(EVENT );END ;END ;
PROCEDURE TBXFILELIST.FOCUSITEM (ITEM:INTEGER);BEGIN IF (LIST ^. COUNT > 0 )THEN INHERITED FOCUSITEM(ITEM );END ;
PROCEDURE TBXFILELIST.READDIRECTORY (AWILDCARD:PATHSTR);VAR OO1O:SEARCHREC;OO10:PSEARCHREC;OIOO0l010lO:TEVENT;
O1lO110OOlI0:PBXFILECOLLECTION;OIOl00O1O1O:DIRSTR;OI111IlIOOl0:NAMESTR;OIl0OOl0ll1:EXTSTR;BEGIN PBXFILEDIALOG (OWNER )^.
DRIVELIST ^. READDIRECTORY (AWILDCARD );AWILDCARD := FEXPAND (AWILDCARD );FSPLIT (AWILDCARD , OIOl00O1O1O , OI111IlIOOl0
, OIl0OOl0ll1 );O1lO110OOlI0 := NEW (PBXFILECOLLECTION , INIT (5 , 5 ));FINDFIRST (AWILDCARD , READONLY + ARCHIVE , OO1O
);OO10 := @ OO10 ;WHILE (OO10 <> NIL )AND (DOSERROR =0 ) DO BEGIN IF (OO1O.ATTR AND DIRECTORY =0 )THEN BEGIN OO10 :=
MEMALLOC (SIZEOF (OO10 ^));IF (OO10 <> NIL )THEN BEGIN MOVE (OO1O.ATTR , OO10 ^, SIZEOF (OO10 ^));O1lO110OOlI0 ^. INSERT
(OO10 );END ;END ;FINDNEXT (OO1O );END ;IF (OO10 =NIL )THEN MESSAGEBOX ('Too many files.', NIL , MFOKBUTTON + MFWARNING
);NEWLIST (O1lO110OOlI0 );IF (LIST ^. COUNT > 0 )THEN BEGIN OIOO0l010lO.WHAT := EVBROADCAST ;OIOO0l010lO.COMMAND :=
CMFILEFOCUSED ;OIOO0l010lO.INFOPTR := LIST ^. AT (0 );OWNER ^. HANDLEEVENT (OIOO0l010lO );END ;END ;
CONSTRUCTOR TBXDRIVELIST.INIT (VAR BOUNDS:TRECT;ASCROLLBAR:PSCROLLBAR);BEGIN TSORTEDLISTBOX.INIT (BOUNDS , 1 , ASCROLLBAR
);END ;PROCEDURE TBXDRIVELIST.GETDRIVES (VAR DRIVES:DRIVESET);VAR OOII1I0OIOll:LONGINT;BEGIN ASM {} MOV AH , 19h {}
INT 21h {} PUSH AX {} {} MOV BX , 1 {} XOR CX , CX {} XOR DL , DL {} MOV WORD PTR [ OOII1I0OIOll] , 0 {}
MOV WORD PTR [ OOII1I0OIOll+ 2 ] , 0 {} {} @1 : MOV AH , 0Eh {} INT 21h {} MOV AH , 19h {} INT 21h {} CMP AL , DL {}
JNE @2 {} OR WORD PTR [ OOII1I0OIOll] , BX {} OR WORD PTR [ OOII1I0OIOll+ 2 ] , CX {} {} @2 : SHL BX , 1 {} RCL CX , 1 {}
INC DL {} CMP DL , 26 {} JB @1 {} {} MOV AH , 0Eh {} POP DX {} INT 21h {} {} SHL WORD PTR [ OOII1I0OIOll] , 1 {}
RCL WORD PTR [ OOII1I0OIOll+ 2 ] , 1 {} {} END;DRIVES := DRIVESET (OOII1I0OIOll );END ;FUNCTION TBXDRIVELIST.GETKEY
(VAR S:STRING ):POINTER ;CONST O11OOO00:TSEARCHREC=();PROCEDURE Ol00IO0I11ll (VAR OO1O:STRING );VAR OIlO:BYTE;
BEGIN FOR OIlO := 1 TO LENGTH (OO1O ) DO OO1O [ OIlO ] := UPCASE (OO1O [ OIlO ] );END ;BEGIN O11OOO00.ATTR := DIRECTORY ;
O11OOO00.NAME := S ;Ol00IO0I11ll (O11OOO00.NAME );GETKEY := @ O11OOO00 ;END ;PROCEDURE TBXDRIVELIST.READDIRECTORY
(AWILDCARD:PATHSTR);VAR OIOI:CHAR;O10O0lIO0O01l:DRIVESET;OO1O:SEARCHREC;OO10:PSEARCHREC;O1lO110OOlI0:PBXFILECOLLECTION;
OOlOO1OIOllO:DIRSTR;OI111IlIO11I:NAMESTR;OO01IOOlI0l:EXTSTR;BEGIN OO10 := @ OO10 ;O1lO110OOlI0 := NEW (PBXFILECOLLECTION
, INIT (5 , 5 ));AWILDCARD := FEXPAND (AWILDCARD );FSPLIT (AWILDCARD , OOlOO1OIOllO , OI111IlIO11I , OO01IOOlI0l );
AWILDCARD := OOlOO1OIOllO + '*.*';FINDFIRST (AWILDCARD , DIRECTORY , OO1O );WHILE (OO10 <> NIL )AND (DOSERROR =0
) DO BEGIN IF (OO1O.ATTR AND DIRECTORY <> 0 )AND (OO1O.NAME [ 1 ] <> '.')THEN BEGIN OO10 := MEMALLOC (SIZEOF (OO10 ^));
IF (OO10 <> NIL )THEN BEGIN MOVE (OO1O.ATTR , OO10 ^, SIZEOF (OO10 ^));O1lO110OOlI0 ^. INSERT (POBJECT (OO10 ));END ;
END ;FINDNEXT (OO1O );END ;IF LENGTH (OOlOO1OIOllO )> 4 THEN BEGIN OO10 := MEMALLOC (SIZEOF (OO10 ^));IF (OO10 <> NIL
)THEN BEGIN FINDFIRST (AWILDCARD , DIRECTORY , OO1O );FINDNEXT (OO1O );IF (DOSERROR =0 )AND (OO1O.NAME ='..')THEN
BEGIN MOVE (OO1O.ATTR , OO10 ^, SIZEOF (OO10 ^))END ELSE BEGIN OO10 ^. NAME := '..';OO10 ^. SIZE := 0 ;OO10 ^. TIME :=
$210000 ;OO10 ^. ATTR := DIRECTORY ;END ;O1lO110OOlI0 ^. INSERT (POBJECT (OO10 ));END ;END ;GETDRIVES (O10O0lIO0O01l );
FOR OIOI := 'A'TO 'Z' DO IF (OIOI IN O10O0lIO0O01l )THEN BEGIN OO10 := MEMALLOC (SIZEOF (OO10 ^));IF (OO10 <> NIL )THEN
BEGIN OO10 ^. NAME := OIOI + ':';OO10 ^. SIZE := 0 ;OO10 ^. TIME := $210000 ;OO10 ^. ATTR := DIRECTORY OR VOLUMEID ;
O1lO110OOlI0 ^. ATINSERT (O1lO110OOlI0 ^. COUNT , POBJECT (OO10 ));END ;END ;IF (OO10 =NIL )THEN MESSAGEBOX
('Too many directories.', NIL , MFOKBUTTON + MFWARNING );NEWLIST (O1lO110OOlI0 );END ;
PROCEDURE TBXFILEINPUTLINE.HANDLEEVENT (VAR EVENT:TEVENT);BEGIN INHERITED HANDLEEVENT(EVENT );IF (EVENT.WHAT =EVBROADCAST
)AND (EVENT.COMMAND =CMFILEFOCUSED )AND (STATE AND SFSELECTED =0 )THEN BEGIN IF (PSEARCHREC (EVENT.INFOPTR )^. ATTR AND
DIRECTORY <> 0 )THEN DATA ^:= PSEARCHREC (EVENT.INFOPTR )^. NAME + '\'+ PFILEDIALOG (OWNER )^. WILDCARD ELSE DATA ^:=
FEXPAND (PBXFILEDIALOG (OWNER )^. DIRECTORY ^)+ PSEARCHREC (EVENT.INFOPTR )^. NAME ;DRAWVIEW ;END ;END ;
PROCEDURE TBXFILEINFOPANE.DRAW ;VAR OOllOI000O1l:WORD;O10OI110Il0II:ARRAY [ 0 .. 7 ]  OF LONGINT;OI111O0100ll:DATETIME;
OIOO:STRING [ 5 ] ;OIIOIOII11I:STRING [ 60 ] ;OIOl01Il1Il:STRING [ 60 ] ;OIO1:TDRAWBUFFER;
CONST O10Ol1OII1lO1='%-12s  %-9s  %02d/%02d/%4d  %02d:%02d%cm';O1O1ll1I1='%-12s  %-9d  %02d/%02d/%4d  %02d:%02d%cm';
BEGIN OOllOI000O1l := GETCOLOR ($01 );MOVECHAR (OIO1 , ' ', OOllOI000O1l , SIZE.X );O10OI110Il0II [ 0 ] := LONGINT (@
S.NAME );IF ((S.ATTR AND DIRECTORY )<> 0 )THEN BEGIN OIIOIOII11I := O10Ol1OII1lO1 ;OIOO := '<Dir>';O10OI110Il0II [ 1 ] :=
LONGINT (@ OIOO );END ELSE BEGIN OIIOIOII11I := O1O1ll1I1 ;O10OI110Il0II [ 1 ] := S.SIZE ;END ;UNPACKTIME (S.TIME ,
OI111O0100ll );O10OI110Il0II [ 2 ] := OI111O0100ll.MONTH ;O10OI110Il0II [ 3 ] := OI111O0100ll.DAY ;O10OI110Il0II [ 4 ] :=
OI111O0100ll.YEAR ;IF (OI111O0100ll.HOUR >= 12 )THEN O10OI110Il0II [ 7 ] := BYTE ('p')ELSE O10OI110Il0II [ 7 ] := BYTE
('a');OI111O0100ll.HOUR := OI111O0100ll.HOUR MOD 12 ;IF (OI111O0100ll.HOUR =0 )THEN OI111O0100ll.HOUR := 12 ;
O10OI110Il0II [ 5 ] := OI111O0100ll.HOUR ;O10OI110Il0II [ 6 ] := OI111O0100ll.MIN ;FORMATSTR (OIOl01Il1Il , OIIOIOII11I ,
O10OI110Il0II );MOVESTR (OIO1 [ 1 ] , OIOl01Il1Il , OOllOI000O1l );WRITELINE (0 , 0 , SIZE.X , 1 , OIO1 );END ;
CONSTRUCTOR TBXDIRECTORYINFOPANE.INIT (VAR BOUNDS:TRECT);BEGIN INHERITED INIT(BOUNDS );EVENTMASK := EVENTMASK OR
EVBROADCAST ;END ;FUNCTION TBXDIRECTORYINFOPANE.GETPALETTE :PPALETTE ;CONST OO10:STRING [ LENGTH(CINFOPANE)] =CINFOPANE;
BEGIN GETPALETTE := @ OO10 ;END ;PROCEDURE TBXDIRECTORYINFOPANE.HANDLEEVENT (VAR EVENT:TEVENT);
BEGIN INHERITED HANDLEEVENT(EVENT );IF (EVENT.WHAT =EVBROADCAST )AND (EVENT.COMMAND =CMFILEFOCUSED )THEN DRAWVIEW ;END ;
PROCEDURE TBXDIRECTORYINFOPANE.DRAW ;VAR OIO1:TDRAWBUFFER;OOllOI000O1l:WORD;OIlIl0O0O00:PATHSTR;BEGIN OIlIl0O0O00 :=
FEXPAND (PBXFILEDIALOG (OWNER )^. DIRECTORY ^);OOllOI000O1l := GETCOLOR ($01 );MOVECHAR (OIO1 , ' ', OOllOI000O1l ,
SIZE.X );MOVESTR (OIO1 [ 1 ] , OIlIl0O0O00 , OOllOI000O1l );WRITELINE (0 , 0 , SIZE.X , 1 , OIO1 );END ;
CONSTRUCTOR TBXFILEDIALOG.INIT (AWILDCARD:TWILDSTR;ATITLE:STRING ;INPUTNAME:STRING ;AOPTIONS:WORD;HISTORYID:BYTE);
VAR OO1000011:PVIEW;OO1I:TRECT;OO1O:STRING ;OIl0OO0lO1O:WORD;OOO101ll0OO1:PATHSTR;BEGIN OO1I.ASSIGN (0 , 0 , 49 , 18 );
TDIALOG.INIT (OO1I , ATITLE );OPTIONS := OPTIONS OR OFCENTERED ;WILDCARD := AWILDCARD ;OO1I.ASSIGN (2 , 2 , 31 , 3 );
FILENAME := NEW (PBXFILEINPUTLINE , INIT (OO1I , 79 ));FILENAME ^. DATA ^:= WILDCARD ;INSERT (FILENAME );OO1I.ASSIGN (2 ,
1 , 3 + CSTRLEN (INPUTNAME ), 2 );OO1000011 := NEW (PLABEL , INIT (OO1I , INPUTNAME , FILENAME ));INSERT (OO1000011 );
OO1I.ASSIGN (31 , 2 , 34 , 3 );OO1000011 := NEW (PHISTORY , INIT (OO1I , FILENAME , HISTORYID ));INSERT (OO1000011 );
OO1I.ASSIGN (16 , 6 , 17 , 16 );OO1000011 := NEW (PSCROLLBAR , INIT (OO1I ));INSERT (OO1000011 );OO1I.ASSIGN (2 , 6 , 16
, 16 );FILELIST := NEW (PBXFILELIST , INIT (OO1I , WILDCARD , PSCROLLBAR (OO1000011 )));INSERT (FILELIST );OO1I.ASSIGN (2
, 5 , 8 , 6 );OO1000011 := NEW (PLABEL , INIT (OO1I , '~F~iles', FILELIST ));INSERT (OO1000011 );OO1I.ASSIGN (32 , 6 , 33
, 16 );OO1000011 := NEW (PSCROLLBAR , INIT (OO1I ));INSERT (OO1000011 );OO1I.ASSIGN (18 , 6 , 32 , 16 );DRIVELIST := NEW
(PBXDRIVELIST , INIT (OO1I , PSCROLLBAR (OO1000011 )));INSERT (DRIVELIST );OO1I.ASSIGN (18 , 5 , 30 , 6 );OO1000011 :=
NEW (PLABEL , INIT (OO1I , '~D~irectories', DRIVELIST ));INSERT (OO1000011 );OO1I.ASSIGN (35 , 2 , 46 , 4 );OIl0OO0lO1O
:= BFDEFAULT ;IF AOPTIONS AND FDOPENBUTTON <> 0 THEN BEGIN INSERT (NEW (PBUTTON , INIT (OO1I , '~O~pen', CMFILEOPEN ,
OIl0OO0lO1O )));OIl0OO0lO1O := BFNORMAL ;INC (OO1I.A.Y , 3 );INC (OO1I.B.Y , 3 );END ;IF AOPTIONS AND FDOKBUTTON <> 0
THEN BEGIN INSERT (NEW (PBUTTON , INIT (OO1I , 'O~K~', CMFILEOPEN , OIl0OO0lO1O )));OIl0OO0lO1O := BFNORMAL ;INC
(OO1I.A.Y , 3 );INC (OO1I.B.Y , 3 );END ;IF AOPTIONS AND FDREPLACEBUTTON <> 0 THEN BEGIN INSERT (NEW (PBUTTON , INIT
(OO1I , '~R~eplace', CMFILEREPLACE , OIl0OO0lO1O )));OIl0OO0lO1O := BFNORMAL ;INC (OO1I.A.Y , 3 );INC (OO1I.B.Y , 3 );
END ;IF AOPTIONS AND FDCLEARBUTTON <> 0 THEN BEGIN INSERT (NEW (PBUTTON , INIT (OO1I , '~C~lear', CMFILECLEAR ,
OIl0OO0lO1O )));OIl0OO0lO1O := BFNORMAL ;INC (OO1I.A.Y , 3 );INC (OO1I.B.Y , 3 );END ;INSERT (NEW (PBUTTON , INIT (OO1I ,
'Cancel', CMCANCEL , BFNORMAL )));INC (OO1I.A.Y , 3 );INC (OO1I.B.Y , 3 );IF AOPTIONS AND FDHELPBUTTON <> 0 THEN
BEGIN INSERT (NEW (PBUTTON , INIT (OO1I , 'Help', CMHELP , BFNORMAL )));INC (OO1I.A.Y , 3 );INC (OO1I.B.Y , 3 );END ;
OO1I.ASSIGN (2 , 4 , 31 , 5 );OO1000011 := NEW (PBXDIRECTORYINFOPANE , INIT (OO1I ));INSERT (OO1000011 );OO1I.ASSIGN (3 ,
3 , 12 , 4 );OO1000011 := NEW (PSTATICTEXT , INIT (OO1I , 'Directory'));INSERT (OO1000011 );OO1I.ASSIGN (2 , SIZE.Y - 2 ,
SIZE.X - 2 , SIZE.Y - 1 );OO1000011 := NEW (PBXFILEINFOPANE , INIT (OO1I ));INSERT (OO1000011 );SELECTNEXT (FALSE );IF
((AOPTIONS AND FDNOLOADDIR )=0 )THEN READDIRECTORY ;END ;{$ENDIF} PROCEDURE REGISTERTVDIALOG ;BEGIN REGISTERTYPE
(RBXRUNDIALOG );REGISTERTYPE (RBXPERCENTDIALOG );REGISTERTYPE (RBXPRINTDIALOG );REGISTERTYPE (RBXLINKEDLINE );
REGISTERTYPE (RBXLINKEDBOX );REGISTERTYPE (RBXLISTBOX );REGISTERTYPE (RBXVLISTBOX );REGISTERTYPE (RBXCHECKLISTBOX );
REGISTERTYPE (RBXPAIREDLISTBOX );REGISTERTYPE (RBXPAIREDSTRLISTBOX );REGISTERTYPE (RBXVLISTBOX );
{$IFDEF USE_NEW_FILE_DIALOG} REGISTERTYPE (RBXFILECOLLECTION );REGISTERTYPE (RBXFILELIST );REGISTERTYPE (RBXDRIVELIST );
REGISTERTYPE (RBXFILEINPUTLINE );REGISTERTYPE (RBXFILEINFOPANE );REGISTERTYPE (RBXDIRECTORYINFOPANE );REGISTERTYPE
(RBXFILEDIALOG );{$ENDIF} END ;END .
