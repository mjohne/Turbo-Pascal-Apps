(***************************************************************************
  TVHC2MSG program
  TVHC filter for using TVHC as an IDE tool
  PJB December 23, 1993, Internet mail to d91-pbr@nada.kth.se
  Copyright 1993, All Rights Reserved
  Free source, use at your own risk.
  If modified, please state so if you pass this around.

  This is TVHC filter for the IDE, but you can use TASM2MSG if you change
  TVHC a little. Unfortunately there is a filter bug in the BP 7.0 IDE
  which this filter bypasses, so you're better off with this filter if
  your IDE has the bug.

  Suggestion:
  Use the modified TVHC included in this package to get pin-pointing
  line references along with your help messages from TVHC.


  GRIPE:
    If you do NOT use a patched TVHC, this file will direct the IDE to
    the *.HLP file, not the .TXT one. This is a stupid TVHC bug, you can
    either change TVHC's PrntMsg or define ForceExtension (see below)
    before you compile this file.

  Defining ForceExtension tells the IDE that the help input file
  (usually .TXT) is the base name of the output help file (usually .HLP)
  but with the extension .TXT. THIS WILL NOT WORK IF YOUR OUTPUT FILE'S
  BASE NAME IS DIFFERENT THAN THAT OF YOUR INPUT FILE. In other words,
  this will fail (because the IDE will look for MYPROG.TXT):

    TVHC HELP.TXT MYPROG.HLP   { Won't work with Borland's TVHC and TVHC2MSG }


  Instructions:
  Compile this program, put the resulting EXE somewhere in your path,
  add a TVHC tool under Options³Tools if you haven't already done so and
  add this to the Tool's command line along with a help file name:

    $SAVE ALL $CAP MSG(TVHC2MSG) $NOSWAP

***************************************************************************)

(* Remove the first two spaces if you don't want to use a modified TVHC *)
{  $DEFINE ForceExtension}



{************************************************}
{                                                }
{   Grep message filter example                  }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program Grep2Msg;

{$M 4096,0,0}

{ Message filters read input from the target program (in this case, GREP)
  by way of StdIn (by using Read or ReadLn), filter the input, then write
  output back to StdOut (using Write or WriteLn). The IDE takes care of
  redirecting the transfer program's output to the filter program, as well
  as redirecting the filter program's output back to the IDE itself.
}

{$I-,S-}

uses
  Dos;

var
  LineNo, E: Word;
  Line: String;
  InputBuffer: array[0..4095] of Char;
  OutputBuffer: array[0..4095] of Char;


(*******************************************************************
  Force extension
*******************************************************************)
function ForceExtension(const FileName, Ext:String):String;
  var
    P: PathStr;
    D: DirStr;
    N: NameStr;
    E: ExtStr;
begin
  FSplit(FileName, D, N, E);
  E:=Ext;
  ForceExtension:=D+N+E;
end;


{ The first data passed back to the IDE by a message filter must always
  be the string 'BI#PIP#OK', followed by a null terminator.
}
procedure WriteHeader;
begin
  Write('BI#PIP#OK'#0);
end;

{ The beginning of a new file is marked by a #0, the file's name, terminated
  by a #0 character.
}
procedure WriteNewFile(const FileName: String);
begin
  Write(#0, FileName, #0);
end;

{ Each message line begins with a #1, followed the line number (in low/high 
  order), followed by the column number (in low/high order), then the
  message text itself, terminated with a #0 character.
}
procedure WriteMessage(Line, Col: Word; const Message: String);
begin
  Write(#1, Chr(Lo(Line)), Chr(Hi(Line)), Chr(Lo(Col)), Chr(Hi(Col)),
    Message, #0);
end;

{ The end of the input stream is marked by a #127 character }
procedure WriteEnd;
begin
  Write(#127);
end;

function TrimLeft(S:String): String;
var
  i: Integer;
  n: String;
begin
  i := 1;
  while (i <= Length(s)) and (s[i] = #32) do Inc(i);
  if i <= Length(s) then
  begin
    Move(s[i], n[1], Length(s) - i + 1);
    n[0] := Char(Length(s) - i + 1);
  end
  else n[0] := #0;
  TrimLeft := n;
end;

  var
    LPara, RPara, FirstColon : Integer;

begin
  SetTextBuf(Input, InputBuffer);
  SetTextBuf(Output, OutputBuffer);

  (* Skip banner msg *)
  if not Eof then
    ReadLn(Line);

  WriteHeader;
  while not Eof do
  begin
    ReadLn(Line);
    if Line <> '' then
    begin
      LPara:=Pos('(', Line);
      RPara:=Pos(')', Line);
      FirstColon:=Pos(':', Line);

      Val(Copy(Line, LPara+1, RPara-(LPara+1)), LineNo, E);
      if E = 0 then
      begin
        WriteNewFile(TrimLeft(Copy(Line, FirstColon+1, LPara-(FirstColon+1))));
       {$IFDEF ForceExtension}
        WriteNewFile(ForceExtension(
        TrimLeft(Copy(Line, FirstColon+1, LPara-(FirstColon+1))),
        '.TXT'));
       {$ELSE}
        WriteNewFile(TrimLeft(Copy(Line, FirstColon+1, LPara-(FirstColon+1))));
       {$ENDIF}
        WriteMessage(LineNo, 1, TrimLeft(Copy(Line, RPara+2, 255)));
      end
      else
        WriteMessage(0, 1, Line);
    end;
  end;
  WriteNewFile('');     (* This fixes a bug in the BP 7.0 IDE *)
  WriteEnd;
end.
