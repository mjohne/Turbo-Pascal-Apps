{*
*
*   Copyright (c) 1992,93 by Richard W. Hansen
*
*   This source code will compile.
*   Full source code available to registered users.
*
*}
(* This file was mangled by Mangler 1.10 (c) Copyright 1993 by Berend de Boer *)
 UNIT TVMENUS ;{$B+} {$X+} {$V-} {$I TVDEFS.INC} INTERFACE USES TVCONST , APP , DRIVERS , MENUS , VIEWS , OBJECTS ;
CONST CHECKMARK :STRING [ 10 ] ='�';CHECKMARKNULL :STRING [ 10 ] =' ';CHECKMARKLEN :BYTE =1 ;
TYPE PBXMENUBAR =^TBXMENUBAR ;TBXMENUBAR =OBJECT (TMENUBAR)PROCEDURE CLEARMARKER (CMD :WORD );FUNCTION FINDCMD
(AMENU :PMENU ;CMD :WORD ):PMENUITEM ;PROCEDURE HANDLEEVENT (VAR E :TEVENT );VIRTUAL;FUNCTION MARKERISSET
(CMD :WORD ):BOOLEAN ;PROCEDURE RESETMARKERS (FIRSTCMD :WORD ;LASTCMD :WORD ;NEWCMD :WORD );PROCEDURE SETMARKER
(CMD :WORD );PROCEDURE TOGGLEMARKER (CMD :WORD );END ;FUNCTION NEWMARKEDITEM (NAME ,PARAM:TMENUSTR ;KEYCODE :WORD ;
COMMAND :WORD ;AHELPCTX :WORD ;NEXT :PMENUITEM ):PMENUITEM ;FUNCTION POPUPMENU (POPMENU :PMENUBOX ):WORD ;
FUNCTION MOUSEPOPUPMENU (POPMENU :PMENUBOX ):WORD ;PROCEDURE REGISTERTVMENUS ;
CONST RBXMENUBAR :TSTREAMREC =(OBJTYPE :5250 ;VMTLINK :OFS (TYPEOF (TBXMENUBAR )^);LOAD :@ TBXMENUBAR . LOAD ;STORE :@
TBXMENUBAR . STORE );IMPLEMENTATION FUNCTION POPUPMENU (POPMENU:PMENUBOX):WORD ;VAR OlIlOOOl0:WORD;OIOO0l010lO:TEVENT;
OOIO:INTEGER;OOIl:INTEGER;BEGIN OOIO := POPMENU ^. ORIGIN.X ;IF (OOIO + POPMENU ^. SIZE.X )> DESKTOP ^. SIZE.X THEN OOIO
:= DESKTOP ^. SIZE.X - POPMENU ^. SIZE.X ;OOIl := POPMENU ^. ORIGIN.Y ;IF (OOIl + POPMENU ^. SIZE.Y )> DESKTOP ^. SIZE.Y
THEN OOIl := DESKTOP ^. SIZE.Y - POPMENU ^. SIZE.Y ;IF (OOIO < 0 )THEN OOIO := 0 ;IF (OOIl < 0 )THEN OOIl := 0 ;POPMENU
^. MOVETO (OOIO , OOIl );POPUPMENU := DESKTOP ^. EXECVIEW (POPMENU );END ;FUNCTION MOUSEPOPUPMENU (POPMENU:PMENUBOX):WORD
;VAR OlIlOOOl0:WORD;OIOO0l010lO:TEVENT;OIOllI0O1OI:TPOINT;BEGIN REPEAT DESKTOP ^. GETEVENT (OIOO0l010lO );UNTIL
(OIOO0l010lO.WHAT =EVMOUSEUP );DESKTOP ^. MAKELOCAL (MOUSEWHERE , OIOllI0O1OI );IF (OIOllI0O1OI.X + POPMENU ^. SIZE.X )>
DESKTOP ^. SIZE.X THEN OIOllI0O1OI.X := DESKTOP ^. SIZE.X - POPMENU ^. SIZE.X ;IF (OIOllI0O1OI.Y + POPMENU ^. SIZE.Y )>
DESKTOP ^. SIZE.Y THEN OIOllI0O1OI.Y := DESKTOP ^. SIZE.Y - POPMENU ^. SIZE.Y ;IF (OIOllI0O1OI.X < 0 )THEN OIOllI0O1OI.X
:= 0 ;IF (OIOllI0O1OI.Y < 0 )THEN OIOllI0O1OI.Y := 0 ;POPMENU ^. MOVETO (OIOllI0O1OI.X , OIOllI0O1OI.Y );MOUSEPOPUPMENU
:= DESKTOP ^. EXECVIEW (POPMENU );END ;FUNCTION NEWMARKEDITEM (NAME,PARAM:TMENUSTR;KEYCODE:WORD;COMMAND:WORD;
AHELPCTX:WORD;NEXT:PMENUITEM):PMENUITEM ;VAR OIlO:BYTE;BEGIN IF (COPY (NAME , 1 , CHECKMARKLEN )<> CHECKMARK )THEN INSERT
(CHECKMARKNULL , NAME , 1 );IF (NAME [ CHECKMARKLEN + 1 ] <> ' ')THEN INSERT (' ', NAME , CHECKMARKLEN + 1 );
NEWMARKEDITEM := NEWITEM (NAME , PARAM , KEYCODE , COMMAND , AHELPCTX , NEXT );END ;PROCEDURE TBXMENUBAR.HANDLEEVENT
(VAR E:TEVENT);BEGIN IF (E.WHAT =EVCOMMAND )THEN IF (E.COMMAND >= CMMARKSTART )AND (E.COMMAND <= CMMARKEND )THEN
BEGIN TOGGLEMARKER (E.COMMAND );END ;INHERITED HANDLEEVENT(E );END ;PROCEDURE TBXMENUBAR.TOGGLEMARKER (CMD:WORD);
BEGIN IF MARKERISSET (CMD )THEN CLEARMARKER (CMD )ELSE SETMARKER (CMD );END ;PROCEDURE TBXMENUBAR.SETMARKER (CMD:WORD);
VAR OO10:PMENUITEM;OIlO:BYTE;BEGIN OO10 := FINDCMD (MENU , CMD );IF (OO10 <> NIL )THEN FOR OIlO := 1 TO CHECKMARKLEN
 DO OO10 ^. NAME ^[ OIlO ] := CHECKMARK [ OIlO ] ;END ;PROCEDURE TBXMENUBAR.CLEARMARKER (CMD:WORD);VAR OO10:PMENUITEM;
OIlO:BYTE;BEGIN OO10 := FINDCMD (MENU , CMD );IF (OO10 <> NIL )THEN FOR OIlO := 1 TO CHECKMARKLEN  DO OO10 ^. NAME ^[
OIlO ] := CHECKMARKNULL [ OIlO ] ;END ;FUNCTION TBXMENUBAR.MARKERISSET (CMD:WORD):BOOLEAN ;VAR OO10:PMENUITEM;
BEGIN MARKERISSET := FALSE ;OO10 := FINDCMD (MENU , CMD );IF (OO10 <> NIL )THEN MARKERISSET := (COPY (OO10 ^. NAME ^, 1 ,
CHECKMARKLEN )=CHECKMARK );END ;PROCEDURE TBXMENUBAR.RESETMARKERS (FIRSTCMD:WORD;LASTCMD:WORD;NEWCMD:WORD);
VAR OO10:PMENUITEM;OIlO:BYTE;BEGIN OO10 := FINDCMD (MENU , FIRSTCMD );WHILE (OO10 <> NIL ) DO BEGIN IF (OO10 ^. COMMAND
=NEWCMD )THEN FOR OIlO := 1 TO CHECKMARKLEN  DO OO10 ^. NAME ^[ OIlO ] := CHECKMARK [ OIlO ] ELSE IF (OO10 ^. COMMAND >=
FIRSTCMD )AND (OO10 ^. COMMAND <= LASTCMD )THEN FOR OIlO := 1 TO CHECKMARKLEN  DO OO10 ^. NAME ^[ OIlO ] := CHECKMARKNULL
[ OIlO ] ;OO10 := OO10 ^. NEXT ;END ;END ;FUNCTION TBXMENUBAR.FINDCMD (AMENU:PMENU;CMD:WORD):PMENUITEM ;
VAR OO10:PMENUITEM;OI1000l1II00:PMENUITEM;BEGIN OI1000l1II00 := NIL ;OO10 := AMENU ^. ITEMS ;WHILE (OO10 <> NIL )AND
(OI1000l1II00 =NIL ) DO BEGIN IF (OO10 ^. COMMAND =0 )AND (OO10 ^. NAME <> NIL )THEN OI1000l1II00 := FINDCMD (OO10 ^.
SUBMENU , CMD )ELSE IF (OO10 ^. COMMAND =CMD )AND NOT OO10 ^. DISABLED THEN OI1000l1II00 := OO10 ;OO10 := OO10 ^. NEXT ;
END ;FINDCMD := OI1000l1II00 ;END ;PROCEDURE REGISTERTVMENUS ;BEGIN REGISTERTYPE (RBXMENUBAR );END ;END .
