Unit StrProcs;

{ *****  Misc. String Functions ******************************************** }

Interface

Uses Dos;

Function Upper(StrIn : String) : String;
{ Convert a string to upper case }

Function PathOnly(FileName : String) : String;
{ Strip any filename information from a file specification }

Function NameOnly(FileName : String) : String;
{ Strip any path information from a file specification }

Function BaseNameOnly(FileName : String) : String;
{ Strip any path and extension information from a file specification }

Function ExtOnly(FileName : String) : String;
{ Return only the extension portion of a filename }

Function IntStr(Int : LongInt; Form : Integer) : String;
{ Convert an Integer variable to a string }

Function SameFile(File1, File2 : String) : Boolean;
{ Call to find out if File1 has a name equivalent to File2.  Both filespecs }
{ may contain wildcards.                                                    }

{ ************************************************************************** }

Implementation

Function Upper(StrIn : String) : String;
Begin
   Inline(                   { Thanks to Phil Burns for this routine }

      $1E/                   {         PUSH    DS                ; Save DS}
      $C5/$76/$06/           {         LDS     SI,[BP+6]         ; Get source string address}
      $C4/$7E/$0A/           {         LES     DI,[BP+10]        ; Get result string address}
      $FC/                   {         CLD                       ; Forward direction for strings}
      $AC/                   {         LODSB                     ; Get length of source string}
      $AA/                   {         STOSB                     ; Copy to result string}
      $30/$ED/               {         XOR     CH,CH}
      $88/$C1/               {         MOV     CL,AL             ; Move string length to CL}
      $E3/$0E/               {         JCXZ    Exit              ; Skip if null string}
                             {;}
      $AC/                   {UpCase1: LODSB                     ; Get next source character}
      $3C/$61/               {         CMP     AL,'a'            ; Check if lower-case letter}
      $72/$06/               {         JB      UpCase2}
      $3C/$7A/               {         CMP     AL,'z'}
      $77/$02/               {         JA      UpCase2}
      $2C/$20/               {         SUB     AL,'a'-'A'        ; Convert to uppercase}
                             {;}
      $AA/                   {UpCase2: STOSB                     ; Store in result}
      $E2/$F2/               {         LOOP    UpCase1}
                             {;}
      $1F);                  {Exit:    POP     DS                ; Restore DS}

end {Upper};

{ -------------------------------------------------------------------------- }

Function PathOnly(FileName : String) : String;
Var
   Dir  : DirStr;
   Name : NameStr;
   Ext  : ExtStr;
Begin
   FSplit(FileName, Dir, Name, Ext);
   PathOnly := Dir;
End {PathOnly};

{ --------------------------------------------------------------------------- }

Function NameOnly(FileName : String) : String;
{ Strip any path information from a file specification }
Var
   Dir  : DirStr;
   Name : NameStr;
   Ext  : ExtStr;
Begin
   FSplit(FileName, Dir, Name, Ext);
   NameOnly := Name + Ext;
End {NameOnly};

{ --------------------------------------------------------------------------- }

Function BaseNameOnly(FileName : String) : String;
{ Strip any path and extension from a file specification }
Var
   Dir  : DirStr;
   Name : NameStr;
   Ext  : ExtStr;
Begin
   FSplit(FileName, Dir, Name, Ext);
   BaseNameOnly := Name;
End {BaseNameOnly};

{ --------------------------------------------------------------------------- }

Function ExtOnly(FileName : String) : String;
{ Strip the path and name from a file specification.  Return only the }
{ filename extension.                                                 }
Var
   Dir  : DirStr;
   Name : NameStr;
   Ext  : ExtStr;
Begin
   FSplit(FileName, Dir, Name, Ext);
   If Pos('.', Ext) <> 0 then
      Delete(Ext, 1, 1);
   ExtOnly := Ext;
End {ExtOnly};

{ --------------------------------------------------------------------------- }

Function IntStr(Int : LongInt; Form : Integer) : String;
Var
   S : String;
Begin
   If Form = 0 then
      Str(Int, S)
   else
      Str(Int:Form, S);
   IntStr := S;
End {IntStr};

{ --------------------------------------------------------------------------- }

Function SameName(N1, N2 : String) : Boolean;
{
  Function to compare filespecs.

  Wildcards allowed in either name.
  Filenames should be compared seperately from filename extensions by using
     seperate calls to this function
        e.g.  FName1.Ex1
              FName2.Ex2
              are they the same?
              they are if SameName(FName1, FName2) AND SameName(Ex1, Ex2)

  Wildcards work the way DOS should've let them work (eg. *XX.DAT doesn't
  match just any file...only those with 'XX' as the last two characters of
  the name portion and 'DAT' as the extension).

  This routine calls itself recursively to resolve wildcard matches.

}
Var
   P1, P2 : Integer;
   Match  : Boolean;
Begin
   P1    := 1;
   P2    := 1;
   Match := TRUE;

   If (Length(N1) = 0) and (Length(N2) = 0) then
      Match := True
   else
      If Length(N1) = 0 then
         If N2[1] = '*' then
            Match := TRUE
         else
            Match := FALSE
      else
         If Length(N2) = 0 then
            If N1[1] = '*' then
               Match := TRUE
            else
               Match := FALSE;

   While (Match = TRUE) and (P1 <= Length(N1)) and (P2 <= Length(N2)) do
      If (N1[P1] = '?') or (N2[P2] = '?') then begin
         Inc(P1);
         Inc(P2);
      end {then}
      else
         If N1[P1] = '*' then begin
            Inc(P1);
            If P1 <= Length(N1) then begin
               While (P2 <= Length(N2)) and Not SameName(Copy(N1,P1,Length(N1)-P1+1), Copy(N2,P2,Length(N2)-P2+1)) do
                  Inc(P2);
               If P2 > Length(N2) then
                  Match := FALSE
               else begin
                  P1 := Succ(Length(N1));
                  P2 := Succ(Length(N2));
               end {if};
            end {then}
            else
               P2 := Succ(Length(N2));
         end {then}
         else
            If N2[P2] = '*' then begin
               Inc(P2);
               If P2 <= Length(N2) then begin
                  While (P1 <= Length(N1)) and Not SameName(Copy(N1,P1,Length(N1)-P1+1), Copy(N2,P2,Length(N2)-P2+1)) do
                     Inc(P1);
                  If P1 > Length(N1) then
                     Match := FALSE
                  else begin
                     P1 := Succ(Length(N1));
                     P2 := Succ(Length(N2));
                  end {if};
               end {then}
               else
                  P1 := Succ(Length(N1));
            end {then}
            else
               If UpCase(N1[P1]) = UpCase(N2[P2]) then begin
                  Inc(P1);
                  Inc(P2);
               end {then}
               else
                  Match := FALSE;

   If P1 > Length(N1) then begin
      While (P2 <= Length(N2)) and (N2[P2] = '*') do
         Inc(P2);
      If P2 <= Length(N2) then
         Match := FALSE;
   end {if};

   If P2 > Length(N2) then begin
      While (P1 <= Length(N1)) and (N1[P1] = '*') do
         Inc(P1);
      If P1 <= Length(N1) then
         Match := FALSE;
   end {if};

   SameName := Match;

End {SameName};

{ ---------------------------------------------------------------------------- }

Function SameFile(File1, File2 : String) : Boolean;
Var
   Path1, Path2 : String;
Begin

   File1 := FExpand(File1);
   File2 := FExpand(File2);
   Path1 := PathOnly(File1);
   Path2 := PathOnly(File2);

   SameFile := SameName(BaseNameOnly(File1), BaseNameOnly(File2)) AND
               SameName(ExtOnly(File1), ExtOnly(File2))           AND
               (Path1 = Path2);

End {SameFile};

{ ---------------------------------------------------------------------------- }

End {Unit StrProcs}.

