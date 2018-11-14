{*
*   TV Tool Box Version 2.0
*   Copyright (c) 1992, 1993 by Richard W. Hansen
*   All Rights Reserved
*
*
*   TvString.pas
*   Turbo Vision string routines for Turbo Pascal 7.0.
*
*}

UNIT TvString;
{$B+}
{$X+}
{$V-}
{.$N+}

{$I TVDEFS.INC}

INTERFACE


USES
  TvConst, TvType;


CONST
  HexDigits   : Array[0..$F] of Char = '0123456789ABCDEF';


TYPE
  TbxNumberMask  = String[30];


Procedure Pad(var S   : String;
                  Len : Byte);
  {- pad S to Len characters with spaces  }

Procedure LeftPad(var S   : String;
                      Len : Byte);
  {- left pad S to Len characters with spaces  }

Procedure PadCh(var S   : String;
                    Len : Byte;
                    Ch  : Char);
  {- pad S to Len characters with Ch  }

Procedure LeftPadCh(var S   : String;
                        Len : Byte;
                        Ch  : Char);
  {- left pad S to Len characters with Ch }

Procedure Trim(var S : String);
  {- trim leading and trailing spaces from S }

Procedure TrimLead(var S : String);
  {- remove leading spaces from S }

Procedure TrimTrail(var S : String);
  {- remove trailing spaces from S }

Procedure TrimCh(var S  : String;
                     Ch : Char);
  {- trim leading and trailing Ch chars from S }

Procedure Strip(var   S     : String;
                const Chars : TbxCharSet);
  {- remove the characters in Chars from S }

Procedure TrimLeadZero(var S : String);
  {- remove leading zeros from S }

Procedure TruncateStr(var S   : String;
                          Len : Byte);
  {- Truncate S to the given length }

Procedure CopyInto(const InStr  : String;
                         Column : Byte;
                     var OutStr : String);
  {- copy InStr into OutStr beginning at Col }



Function FTrim(S : String): String;

Function FTrimLead(S : String): String;

Function FTrimTrail(S : String): String;

Function FTrimCh(S  : String;
                 Ch : Char): String;

Function FPad(S   : String;
              Len : Byte): String;

Function FLeftPad(S   : String;
                  Len : Byte): String;

Function FPadCh(S   : String;
                Len : Byte;
                Ch  : Char): String;

Function FLeftPadCh(S   : String;
                    Len : Byte;
                    Ch  : Char): String;

Function FStrip(S : String;
                const Chars : TbxCharSet): String;

Function FTrimLeadZero(S : String): String;

Function FTruncateStr(S   : String;
                      Len : Byte): String;

Function FCopyInto(const InStr  : String;
                         Column : Byte;
                         OutStr : String): String;



Function Blanks(Len : Byte): String;
  {- return a string of Len spaces in S }

Function Chars(Len : Byte;
               Ch  : Char): String;
  {- return a string of Ch characters of Length Len in S }

Function AllBlanks(const S : String): Boolean;
  {- test for an empty string (null or all spaces) }

Function HexString(I : LongInt): String;
  {- return I as a Hexadecimal string }

{$IFOPT N+}
Function FormatF(const Mask : TbxNumberMask;
                       Flt  : Double;
                       DP   : Integer): String;
{$ELSE}
Function FormatF(const Mask : TbxNumberMask;
                       Flt  : Real;
                       DP   : Integer): String;
{$ENDIF}

Function FormatI(const Mask : TbxNumberMask;
                       Long : LongInt): String;



IMPLEMENTATION


{*
* Name       : Pad
* Purpose    : Return a string right-padded to length Len with blanks.
* Parameters : S - string to pad
*              Len - length to pad to
*}
Procedure Pad(var S   : String;
                  Len : Byte);
  begin
    if (Byte(S[0]) < Len) then
    begin
      FillChar(S[Byte(S[0]) + 1], Len - Byte(S[0]), ' ');
      Byte(S[0]) := Len;
    end;
  end;

Function FPad(S   : String;
              Len : Byte): String;
  begin
    Pad(S, Len);
    FPad := S;
  end;

{*
* Name       : LeftPad
* Purpose    : Return a string left-padded to length Len with blanks.
* Parameters : S - string to pad
*              Len - length to pad to
*}
Procedure LeftPad(var S   : String;
                      Len : Byte);

  var
    X : Byte;

  begin
    if (Byte(S[0]) < Len) then
    begin
      X := Len - Byte(S[0]);
      Move(S[1], S[X + 1], Byte(S[0]));
      FillChar(S[1], X, ' ');
      Byte(S[0]) := Len;
    end;
  end;

Function FLeftPad(S   : String;
                  Len : Byte): String;
  begin
    LeftPad(S, Len);
    FLeftPad := S;
  end;

{*
* Name       : PadCh
* Purpose    : Return a string right-padded to length Len with Ch.
* Parameters : S - string to pad
*              Len - length to pad to
*              Ch - the character to pad with
*}
Procedure PadCh(var S   : String;
                    Len : Byte;
                    Ch  : Char);
  begin
    if (Byte(S[0]) < Len) then
    begin
      FillChar(S[Byte(S[0]) + 1], Len - Byte(S[0]), Ch);
      Byte(S[0]) := Len;
    end;
  end;

Function FPadCh(S   : String;
                Len : Byte;
                Ch  : Char): String;
  begin
    PadCh(S, Len, Ch);
    FPadCh := S;
  end;

{*
* Name       : LeftPadCh
* Purpose    : Return a string left-padded to length Len with Ch.
* Parameters : S - string to pad
*              Len - length to pad to
*              Ch - the character to pad with
*}
Procedure LeftPadCh(var S   : String;
                        Len : Byte;
                        Ch  : Char);

  var
    X : Byte;

  begin
    if (Byte(S[0]) < Len) then
    begin
      X := Len - Byte(S[0]);
      Move(S[1], S[X + 1], Byte(S[0]));
      FillChar(S[1], X, Ch);
      Byte(S[0]) := Len;
    end;
  end;

Function FLeftPadCh(S   : String;
                    Len : Byte;
                    Ch  : Char): String;
  begin
    LeftPadCh(S, Len, Ch);
    FLeftPadCh := S;
  end;

{*
* Name       : Trim
* Purpose    : Return a string with leading and trailing blanks removed.
* Parameters : S - string to trim
*}
Procedure Trim(var S : String);

  var
    i : Byte;

  begin
    while (Byte(S[0]) > 0) and (S[Byte(S[0])] = ' ') do
      Dec(Byte(S[0]));

    i := 1;

    while (i <= Byte(S[0])) and (S[i] = ' ') do
      Inc(i);

    if (i > 1) then
    begin
      Byte(S[0]) := Byte(S[0]) - i + 1;
      Move(S[i], S[1], Byte(S[0]));
    end;
  end;

Function FTrim(S : String): String;
  begin
    Trim(S);
    FTrim := S;
  end;

{*
* Name       : TrimLead
* Purpose    : Return a string with leading blanks removed.
* Parameters : S - string to trim
*}
Procedure TrimLead(var S : String);

  var
    i : Byte;

  begin
    i := 1;

    while (i <= Byte(S[0])) and (S[i] = ' ') do
      Inc(i);

    if (i > 1) then
    begin
      Byte(S[0]) := Byte(S[0]) - i + 1;
      Move(S[i], S[1], Byte(S[0]));
    end;
  end;

Function FTrimLead(S : String): String;
  begin
    TrimLead(S);
    FTrimLead := S;
  end;

{*
* Name       : TrimTrail
* Purpose    : Return a string with trailing blanks removed.
* Parameters : S - string to trim
*}
Procedure TrimTrail(var S : String);
  begin
    while (Byte(S[0]) > 0) and (S[Byte(S[0])] = ' ') do
      Dec(Byte(S[0]));
  end;

Function FTrimTrail(S : String): String;
  begin
    TrimTrail(S);
    FTrimTrail := S;
  end;

{*
* Name       : TrimCh
* Purpose    : Return a string with trailing characters of Ch removed.
* Parameters : S - string to trim
*              Ch - the character to be trimmed
*}
Procedure TrimCh(var S  : String;
                     Ch : Char);

  var
    i : Byte;

  begin
    while (Byte(S[0]) > 0) and (S[Byte(S[0])] = Ch) do
      Dec(Byte(S[0]));

    i := 1;

    while (i <= Byte(S[0])) and (S[I] = Ch) do
      Inc(i);

    if (i > 1) then
    begin
      Byte(S[0]) := Byte(S[0]) - i + 1;
      Move(S[i], S[1], Byte(S[0]));
    end;
  end;

Function FTrimCh(S  : String;
                 Ch : Char): String;
  begin
    TrimCh(S, Ch);
    FTrimCh := S;
  end;

{*
* Name       : Blanks
* Purpose    : Return a string of Len blanks.
* Parameters : Len - how many spaces
* Notes      : Always seem to need a blank strings, so it is worth a
*              separate routine.
*}
Function Blanks(Len : Byte): String;

  var
    S : String;

  begin
    FillChar(S[1], Len, ' ');
    Byte(S[0]) := Len;
    Blanks := S;
  end;

{*
* Name       : Chars
* Purpose    : Return a string of Len char of Ch.
* Parameters : Len - how many chars
*              Ch - the desired character
*}
Function Chars(Len : Byte;
               Ch  : Char): String;

  var
    S : String;

  begin
    FillChar(S[1], Len, Ch);
    Byte(S[0]) := Len;
    Chars := S;
  end;

{*
* Name       : CopyInto
* Purpose    : Copy InStr into OutStr at column Col.
* Parameters : InStr - the string to be inserted
*              Col   - where to insert
*              OutStr- the string to insert into, and result
* Notes      : This routine is great for for creating formated output.
*              This is not just another INSERT. It does not move any chars
*              like insert, it just overwrites the existing string. Will
*              not copy beyond the end of the Destination string.
*              Basically, you just make a string of all blanks the desired
*              length, then copy other strings into it at fixed columns.
*}
Procedure CopyInto(const InStr  : String;
                         Column : Byte;
                     var OutStr : String);

  begin
    if (Byte(InStr[0]) <> 0) then
    begin
      if (Column > Byte(OutStr[0])) then
        EXIT
      else if (Column + Byte(InStr[0]) - 1 > Byte(OutStr[0])) then
        Move(InStr[1], OutStr[Column], Byte(OutStr[0]) - Column + 1)
      else
        Move(InStr[1], OutStr[Column], Byte(InStr[0]));
    end;
  end;

Function FCopyInto(const InStr  : String;
                         Column : Byte;
                         OutStr : String): String;
  begin
    CopyInto(InStr, Column, OutStr);
    FCopyInto := OutStr;
  end;

{*
* Name       : Strip
* Purpose    : Remove the characters in Chars from S.
* Parameters : S - the input string
*              Chars - set of characters to be removed
*}
Procedure Strip(var   S     : String;
                const Chars : TbxCharSet);

  var
    i,j  : Byte;

  begin
    j := 0;

    for i := 1 to Byte(S[0]) do
      if not (S[i] in Chars) then
      begin
        Inc(j);
        S[j] := S[i];
      end;

    Byte(S[0]) := j;
  end;

Function FStrip(S : String;
                const Chars : TbxCharSet): String;
  begin
    Strip(S, Chars);
    FStrip := S;
  end;

{*
* Name       : TrimLeadZero
* Purpose    : Return a string with leading zeros "0" removed.
* Parameters : S - string to trim
*}
Procedure TrimLeadZero(var S : String);

  var
    i : Byte;

  begin
    i := 1;

    while (i <= Byte(S[0])) and (S[i] = '0') do
      Inc(i);

    if (i > 1) then
    begin
      Byte(S[0]) := Byte(S[0]) - i + 1;
      Move(S[i], S[1], Byte(S[0]));
    end;
  end;

Function FTrimLeadZero(S : String): String;
  begin
    TrimLeadZero(S);
    FTrimLeadZero := S;
  end;

{*
* Name       : AllBlanks
* Purpose    : Test for an emtpy string.
* Parameters : S - the string to test.
* Notes      : Tests for both spaces and a null string.
*}
Function AllBlanks(const S : String): Boolean;

  var
    i : Byte;

  begin
    i := Byte(S[0]);

    While (i > 0) and (S[i] = ' ') do
      Dec(i);

    AllBlanks := (i = 0);
  end;

{*
* Name       : TruncateStr
* Purpose    : Truncate a string to the given length.
* Parameters : S - the string to chop
*              Len - the desired string length
* Notes      : Only shortens does not lengthen.
*}
Procedure TruncateStr(var S   : String;
                          Len : Byte);
  begin
    if (Byte(S[0]) > Len) then
      Byte(S[0]) := Len;
  end;

Function FTruncateStr(S   : String;
                      Len : Byte): String;
  begin
    TruncateStr(S, Len);
    FTruncateStr := S;
  end;

{*
* Name       : HexString
* Purpose    : Convert a LongInt to a hexadecimal string.
* Parameters : I - the number to convert
*}
Function HexString(I : LongInt): String;

  var
    S : String;

  begin
    With TbxLong(I) do
    begin
      S[0] := #9;
      S[1] := '$';
      S[2] := HexDigits[Hi(High) shr $4];
      S[3] := HexDigits[Hi(High) and $F];
      S[4] := HexDigits[Lo(High) shr $4];
      S[5] := HexDigits[Lo(High) and $F];
      S[6] := HexDigits[Hi(Low)  shr $4];
      S[7] := HexDigits[Hi(Low)  and $F];
      S[8] := HexDigits[Lo(Low)  shr $4];
      S[9] := HexDigits[Lo(Low)  and $F];
    end;

    { this will remove leading zeros
    while (S[2] = '0') and (Length(S) > 2) do
      Delete(S, 2, 1);
    }

    HexString := S;
  end;

{*
* Name       : FormatF
* Purpose    : Create a formatted string from a floating point number.
* Parameters : Mask - the output formatting mask
*              Dbl  - the number to format
*              DP   - Number of digits to the left of decimal place to
*                     retain in the output. If DP is negative the number of
*                     the digits to the left is determined strictly for the
*                     output mask.
* Notes      : The maximum mask size is 30 characters.
*
*              The three characters #,@,& serve as place holders in the
*              mask for the digits in the output. All other characters are
*              copied from the mask to the output unchanged.
*
*              In the output any unused # is replaced by a space, any
*              unused @ is replaced by zero, and any unused & is deleted.
*              The #,@,& can be mixed as desired in the mask. Given the
*              same mask, calls to FormatF with different valuse of DP will
*              return strings with the decimal point aligned.
*
*              If a number is too large to fit in the given mask, all
*              digits in the output will be set to *.
*
*              Some examples :
*
*              Input                                     Output
*              컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
*              FormatF('#####.####', 12345.6789, 4))     12345.6789
*              FormatF('#####.####', 12345.6789, 3))     12345.679
*              FormatF('#####.####', 1234.5678, 3))       1234.568
*              FormatF('#####.####', 12345.6789, -1))    12345.6789
*              FormatF('##,###.###,#', 12345.6789, 4)    12,345.678,9
*              FormatF('$ ##,###.####', 12345.6789, 4)   $ 12,345.6789
*              FormatF('$ ##,###.####', 123.4, 2)        $    123.4
*              FormatF('$ ##,###.@@@@', 12345.6, 1)      $ 12,345.6000
*              FormatF('$ &&,&&&.@@@@', 1234.56, 2)      $ 1,234.5600
*              FormatF('$ &&,&&&.@@@@', 123.4, 2)        $ 123.4000
*              FormatF('#####.####', 9999999.9999, 4)    *****.****
*
*}
{$IFOPT N+}
Function FormatF(const Mask : TbxNumberMask;
                       Flt  : Double;
                       DP   : Integer): String;
{$ELSE}
Function FormatF(const Mask : TbxNumberMask;
                       Flt  : Real;
                       DP   : Integer): String;
{$ENDIF}

  var
    RDigits : Byte;
    LDigits : Byte;
    DPos    : Byte;
    Width   : Byte;
    i       : Integer;
    j       : Integer;
    Left    : Boolean;
    Num     : TbxNumberMask;
    Temp    : TbxNumberMask;

  begin
    Temp    := Mask;
    { count digits to left and right of decimal point }
    Left    := True;
    RDigits := 0;
    LDigits := 0;
    DPos    := 0;

    for i := 1 to Length(Mask) do
    begin
      Case Mask[i] of
        '@', '#', '&' :
          begin
            if Left then
              Inc(LDigits)
            else
              Inc(RDigits);
          end;

        '.' :
          begin
            Left := False;
            DPos := i;
          end;
      end; {CASE}
    end; {FOR}

    { adjust digits to right as needed  }
    if (DP < 0) or (DP > RDigits) then
      DP := RDigits;

    { calculate the total width, including decimal point  }
    Width := LDigits + DP;

    if (DP > 0) then
      Inc(Width);

    { convert value to string }
    Str(Flt:Width:DP, Num);

    { copy the the digits left of decimal point,
      from the decimal point and proceeding to the left
    }
    j := DPos - 1;
    i := Length(Num) - DP;

    if (DP <> 0) then
      Dec(i);

    While (i > 0) and (j > 0) do
    begin
      Case Temp[j] of
        '@', '#', '&' :
          begin
            if (Num[i] = ' ') then
            begin
              i := 0;
            end

            else
            begin
              Temp[j] := Num[i];
              Dec(i);
            end;
          end;
      end; {CASE}

      Dec(j);
    end; {WHILE}


    if (i = 0) then
    begin
      { copy the the digits right of decimal point,
        from the decimal point and proceeding to the right
      }
      j := DPos + 1;
      i := Length(Num) - DP + 1;

      While (i <= Length(Num)) and (j <= Length(Temp)) do
      begin
        Case Temp[j] of
          '@', '#', '&' :
            begin
              Temp[j] := Num[i];
              Inc(i);
            end;
        end; {CASE}

        Inc(j);
      end; {WHILE}

      { get rid of any unneeded commas and formatting chars }
      j := 0;
      Num := '';

      for i := 1 to Length(Temp) do
        Case Temp[i] of
          '#' :
            begin
              Inc(j);
              Num[j] := ' ';
            end;

          '@' :
            begin
              Inc(j);
              Num[j] := '0';
            end;

          ',' :
            begin
              if (i > 1) and (i < Length(Temp)) then
              begin
                if ((Temp[i - 1] = '#') or (Temp[i + 1] = '#')) then
                begin
                  Inc(j);
                  Num[j] := ' '
                end

                else if (Temp[i - 1] <> '&') and (Temp[i + 1] <> '&') then
                begin
                  Inc(j);
                  Num[j] := Temp[i];
                end;
              end

              else if (i < Length(Temp)) and (Temp[i + 1] <> '&') then
              begin
                Inc(j);
                Num[j] := ' '
              end

              else if (i > 1) and (Temp[i - 1] <> '&') then
              begin
                Inc(j);
                Num[j] := ' '
              end;
            end;

          '&' :
            begin
            end;

          else
          begin
            Inc(j);
            Num[j] := Temp[i];
          end;
        end; {CASE}

      Byte(Num[0]) := j;
    end

    else  { ERROR!!!! - the number was to big for the mask  }
    begin
      Num := '';

      for i := 1 to Length(Mask) do
        Case Mask[i] of
          '@', '#', '&' :
            Num[i] := '*';
          else
            Num[i] := Mask[i];
        end; {CASE}

      Byte(Num[0]) := Length(Mask);
    end;

    FormatF := Num;
  end;

{*
* Name       : FormatI
* Purpose    : Create a formatted string from an integer number.
* Parameters : Mask - the output formatting mask
*              long - the number to format
* Notes      : The maximum mask size is 30 characters.
*
*              The three characters #,@,& serve as place holders in the
*              mask for the digits in the output. All other characters are
*              copied from the mask to the output unchanged.
*
*              In the output any unused # is replaced by a space, any
*              unused @ is replaced by zero, and any unused & is deleted.
*              The #,@,& can be mixed as desired in the mask.
*
*              If a number is too large to fit in the given mask, all
*              digits in the output will be set to *.
*
*              Some examples :
*
*              Input                                     Output
*              컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
*              FormatI('#####', 999)                      999
*              FormatI('@@@@@', 999)                     0999
*              FormatI('&&&&&', 999)                     999
*              FormatI('##,###', 9999)                    9,999
*              FormatI('&&,&&&', 9999)                   9,999
*              FormatI('##,###', 999999)                 **,***
*
*}
Function FormatI(const Mask : TbxNumberMask;
                       Long : LongInt): String;

  var
    Width   : Byte;
    i       : Integer;
    j       : Integer;
    Num     : TbxNumberMask;
    Temp    : TbxNumberMask;

  begin
    Temp  := Mask;
    { find the width of the output }
    Width := 0;

    for i := 1 to Length(Mask) do
    begin
      Case Mask[i] of
        '@', '#', '&' :
          begin
            Inc(Width)
          end;
      end; {CASE}
    end; {FOR}

    { convert }
    Str(Long:Width, Num);

    { Copy to output from right to left }
    i := Length(Num);
    j := Length(Temp);

    While (i > 0) and (j > 0) do
    begin
      Case Temp[j] of
        '@', '#', '&' :
          begin
            if (Num[i] = ' ') then
            begin
              i := 0;
            end

            else
            begin
              Temp[j] := Num[i];
              Dec(i);
            end;
          end;
      end; {CASE}

      Dec(j);
    end; {WHILE}

    if (i = 0) then
    begin
      { get rid of any unneeded commas and formatting chars }
      j := 0;
      Num := '';

      for i := 1 to Length(Temp) do
        Case Temp[i] of
          '#' :
            begin
              Inc(j);
              Num[j] := ' ';
            end;

          '@' :
            begin
              Inc(j);
              Num[j] := '0';
            end;

          ',' :
            begin
              if (i > 1) and (i < Length(Temp)) then
              begin
                if ((Temp[i - 1] = '#') or (Temp[i + 1] = '#')) then
                begin
                  Inc(j);
                  Num[j] := ' '
                end

                else if (Temp[i - 1] <> '&') and (Temp[i + 1] <> '&') then
                begin
                  Inc(j);
                  Num[j] := Temp[i];
                end;
              end

              else if (i < Length(Temp)) and (Temp[i + 1] <> '&') then
              begin
                Inc(j);
                Num[j] := ' '
              end

              else if (i > 1) and (Temp[i - 1] <> '&') then
              begin
                Inc(j);
                Num[j] := ' '
              end;
            end;

          '&' :
            begin
            end;

          else
          begin
            Inc(j);
            Num[j] := Temp[i];
          end;
        end; {CASE}

      Byte(Num[0]) := j;
    end

    else  { ERROR!!!! - the number was to big for the mask  }
    begin
      Num := '';

      for i := 1 to Length(Mask) do
        Case Mask[i] of
          '@', '#', '&' :
            Num[i] := '*';
          else
            Num[i] := Mask[i];
        end; {CASE}

      Byte(Num[0]) := Length(Mask);
    end;

    FormatI := Num;
  end;


END.
