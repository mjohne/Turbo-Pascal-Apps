{*
*   TV Tool Box Version 2.0
*   Copyright (c) 1992, 1993 by Richard W. Hansen
*   All Rights Reserved
*
*
*   TvConst.pas
*   Turbo Vision command constants for Turbo Pascal 7.0.
*
*}

UNIT TvConst;

{$I TVDEFS.INC}

INTERFACE

{ Some keyboard constants Borland left out. }

CONST
  kbCtrlA = $1E01;
  kbCtrlB = $3002;
  kbCtrlC = $2E03;
  kbCtrlD = $2004;
  kbCtrlE = $1205;
  kbCtrlF = $2106;
  kbCtrlG = $2207;
  kbCtrlH = $2308;
  kbCtrlI = $1709;
  kbCtrlJ = $240A;
  kbCtrlK = $250B;
  kbCtrlL = $260C;
  kbCtrlM = $320D;
  kbCtrlN = $310E;
  kbCtrlO = $180F;
  kbCtrlP = $1910;
  kbCtrlQ = $1011;
  kbCtrlR = $1312;
  kbCtrlS = $1F13;
  kbCtrlT = $1414;
  kbCtrlU = $1615;
  kbCtrlV = $2F16;
  kbCtrlW = $1117;
  kbCtrlX = $2D18;
  kbCtrlY = $1519;
  kbCtrlZ = $2C1A;


CONST
  cmTVTtool1      = 246;
  cmFirstPage     = cmTVTtool1;
  cmLastPage      = cmFirstPage + 1;
  cmNextPage      = cmFirstPage + 2;
  cmPrevPage      = cmFirstPage + 3;
  cmMaximize      = cmFirstPage + 4;
  cmMinimize      = cmFirstPage + 5;
  cmStartJob      = cmFirstPage + 6;
  cmPauseJob      = cmFirstPage + 7;
  cmContinueJob   = cmFirstPage + 8;
  cmCancelJob     = cmFirstPage + 9;

  cmTVTtool2      = 10000;
  cmMarkStart     = cmTVTtool2;
  cmMarkEnd       = cmTVTtool2 + 1000;
  cmCursorMoved   = cmTVTtool2 + 1001;
  cmUpdateView    = cmTVTtool2 + 1002;
  cmEditView      = cmTVTtool2 + 1003;
  cmPrint         = cmTVTtool2 + 1004;
  cmJobComplete   = cmTVTtool2 + 1005;
  cmPopMenu       = cmTVTtool2 + 1006;
  cmTakeItem      = cmTVTtool2 + 1007;
  cmDisplayStr    = cmTVTtool2 + 1008;
  cmDisplayClr    = cmTVTtool2 + 1009;
  cmDragView      = cmTVTtool2 + 1010;
  cmIdentify      = cmTVTtool2 + 1011;
  cmSetId         = cmTVTtool2 + 1012;
  cmFieldError    = cmTVTtool2 + 1013;


CONST
  ofPosIndicator  = $1000;
  ofVScrollBar    = $2000;
  ofHScrollBar    = $4000;


  (*  Picture strings for TPxPictureValidators

   Type of character     Character    Description
   --------------------------------------------------------------------
   Special
                         #            Accept only a digit
                         ?            Accept only a letter
                                      (case-insensitive)
                         &            Accept only a letter, force to
                                      uppercase
                         @            Accept any character
                         !            Accept any character, force to
                                      uppercase
   Match
                         ;            Take next character literally
                         *            Repetition count
                         []           Option
                         {}           Grouping operators
                         ,            Set of alternatives
   All others                         Taken literally

  *)

CONST
  UnsignedPic1      = '#[#][#]*{[;,]###}';
    { unsigned int with optional commas }
CONST
  UnsignedPic2      = '#[#][#]*{;,###}';
    { unsigned int with commas }
CONST
  SignedPic1        = '[-]#[#][#]*{[;,]###}';
    { signed int with optional commas }
CONST
  SignedPic2        = '[-]#[#][#]*{;,###}';     {
    { signed int with commas }
CONST
  MoneyPic1         = '[$]*#.{##,00}';
    { dollars, with comma and optinal dollar sign }
CONST
  MoneyPic2         = '$*#{.##,.00}';
    { dollars, with comma and dollar sign }
CONST
  DatePic1          = '#[#]/#[#]/##';
    { date with 2 digit year (dd/mm/yy or mm/dd/yy) }
CONST
  DatePic2          = '#[#]/#[#]/##[##]';
    { date with 2 or 4 digit year (mm/dd/yy or mm/dd/yyyy) }
CONST
  DatePic3          = '#[#]/#[#]/####';
    { date with 4 digit year (mm/dd/yyyy) }
CONST
  TimePic1          = '{##}:{##}[:{##}]';
    { HH:MM:SS with optional seconds }
CONST
  TimePic2          = '{##}:{##}:{##}';
    { HH:MM:SS }
CONST
  PhonePic1         = '[(###) ]###-####';
    { phone number with optional area code }
CONST
  PhonePic2         = '(###) ###-####';
    { phone number with area code }
CONST
  SSNPic            = '###-##-####';
CONST
  FirstCharUpPic    = '*{&*? }';
    { uppercase the first char of every word }
CONST
  FilenamePic       = '{&*7[&]}.{*3[&]}';
    { filename (no path) with extension }


IMPLEMENTATION
END.
