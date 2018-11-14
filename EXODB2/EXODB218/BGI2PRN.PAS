Unit BGI2PRN;

{ Print a 640x480x16 VGA screen on a 24-needle impact printer,
  NEC and Epson LQ, also works on many inkjet printers from Epson...
  MONOCHROME printing, convert colors to "grayscale".
  Each VGA pixel is converted to 4 printed pixels.
  Each printed row is sent to the printer as 3 bytes (24 pins).
  Not optimized for speed, plain Pascal, no ASM.
  TP 6, (c) 1986 (?!)  Franz Glaser, Austria }

Interface

Uses DOS,CRT,Graph {,MyGraph} ;

Procedure GrafToPrint;

Implementation


Var GraphDriver : Integer; {must be VGA}
    LPTnumber   : Integer; {0 = LPT1:}

Procedure FullPort; {usually defined elsewhere}
Begin
  SetViewPort(0, 0, 639, 479, ClipOn);
End;

Procedure GrafToPrint;   {on entry: graphics mode on}

Var PLine : Array[0..1279] of Array[0..2] of Byte ;
    Sp,Zl,Sp1,Sp2,Zl1,Zl2,Zl3,ZlB : Integer ;
{German: column = Spalte,
         row    = Zeile.  To explain the var names}
    Fb,Lastb : Byte ;
    Regs  : Registers ;
    Lnr   : Integer;

  Procedure WriteLst(S : String) ;
  Var I : Integer ;
  Begin
  with Regs do
    Begin
      For I := 1 to Length(S) do
        Begin        { repeat }
          AX := Ord(S[I]) ; {AH=0}
          DX := Lnr ;
          Intr($17,Regs) ;  {BIOS call to print routine}
        End ; { until (Regs.AH <> 1)  or (keypressed and (GetKey=#27)) ;}
    End ;{with Regs}
  End ;

Begin  { graph2print }
  if GraphDriver <> VGA then Exit; {no test for VGAhi here, you can do
that}
  Lnr := LPTNumber and 3;
  SetColor(lightgreen); {for the short success - strokes}
  SetLineStyle(SolidLn, 0, NormWidth);
  Fullport;
  Fillchar(PLine,Sizeof(PLine),#0) ;
  WriteLst(^M^J) ;
  Zl1 := $80 ; Zl2 := $40 ; Zl3 := $C0 ;
  ZlB := 0 ;
  For Zl := 0 to 479 do  {VGA lines}
    Begin {fortunately 480 can be divided by 12}
      For Sp := 0 to 639 do  {VGA columns}
        Begin
          Fb := GetPixel(Sp,Zl) ; {Farb-Byte   color byte}
          Sp1 := Sp*2 ; {2 PrtPxl / VGA-Pxl}
          Sp2 := Sp1+1; {gleich das n„chste    and the next one}
          Case Fb of
        { 0 : ; no pixel}
    {blu} 1 : PLine[Sp1,ZlB] := PLine[Sp1,ZlB] OR Zl1 ;
    {gre} 2 : PLine[Sp1,ZlB] := PLine[Sp1,ZlB] OR Zl2 ;
    {cya} 3 : Begin
                PLine[Sp1,ZlB] := PLine[Sp1,ZlB] OR Zl2 ;
                PLine[Sp2,ZlB] := PLine[Sp2,ZlB] OR Zl1 ; {diagonal}
              End ;
    {red} 4 : PLine[Sp2,ZlB] := PLine[Sp2,ZlB] OR Zl2 ;
    {mag} 5 : Begin
                PLine[Sp1,ZlB] := PLine[Sp1,ZlB] OR Zl1 ;
                PLine[Sp2,ZlB] := PLine[Sp2,ZlB] OR Zl2 ; {diagonal}
              End ;
    {bro} 6 : PLine[Sp2,ZlB] := PLine[Sp2,ZlB] OR Zl1 ;
          7 : Begin
                PLine[Sp1,ZlB] := PLine[Sp1,ZlB] OR Zl2 ;
                PLine[Sp2,ZlB] := PLine[Sp2,ZlB] OR Zl1 ; {diagonal}
              End ;
          8 : PLine[Sp2,ZlB] := PLine[Sp2,ZlB] OR Zl2 ;
 9,10,11,12 : Begin
                PLine[Sp2,ZlB] := PLine[Sp2,ZlB] OR Zl3 ;
                if (LastB=FB) or (LastB in [0..8,13..15]) then
                  PLine[Sp2,ZlB] := PLine[Sp2,ZlB] OR Zl2 ;
              End ;
   13       : Begin
                PLine[Sp1,ZlB] := PLine[Sp1,ZlB] OR Zl3 ;
                if (LastB=FB) or (LastB in [0..12]) then
                  PLine[Sp2,ZlB] := PLine[Sp2,ZlB] OR Zl3 ;
              End ;
      14,15 : Begin
                PLine[Sp1,ZlB] := PLine[Sp1,ZlB] OR Zl3 ;
                PLine[Sp2,ZlB] := PLine[Sp2,ZlB] OR Zl3 ;
              End ;
          End ;{case}
          LastB := Fb ; {used to enhance color changes}
        End ; {loop Spalte}
      Zl1 := Zl1 div 4 ; {bit shift right}
      if Zl1 < 2 then  {all shifted out right}
        Begin
          ZlB := ZlB + 1 ;
          Zl1 := $80 ;
          if ZlB > 2 then  {3 byte-rows ready}
            Begin
              WriteLst('     ') ; {left margin}
              WriteLst(^['*'#39 + Chr(Lo(1280)) + Chr(Hi(1280)));
              For Sp := 0 to 1279 do
                For ZlB := 0 to 2 do {3 bytes}
                 with Regs do
                  Begin
                    AX := PLine[Sp,ZlB] ; {AH=0}
                    DX := Lnr ;
                    Intr($17,Regs) ;
                  End ;
              WriteLst(^M^['J'#24) ; {CR 24/180"}
              Line(0,Zl,8,Zl) ; {display success on the CRT}
              Fillchar(PLine,sizeof(PLine),#0) ; {buffer empty}
              ZlB := 0 ;
              if Keypressed then
                if ReadKey in [^C,^[] then Exit ;
            End ;{print line}
        End ;
      Zl2 := Zl1 div 2 ; Zl3 := Zl1+Zl2 ; {prep for next loop}
    End ;{for Zl}
{note that the port clipping is off here}
End ;

End.
