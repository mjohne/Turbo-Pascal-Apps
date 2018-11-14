(***************************************************************************
  A Much Faster Terminal for Turbo Vision, v1.0
  PJB August 22, 1993
  Twice as fast, less code
  Free source - no warranty
  Send comments by Internet mail to d91-pbr@nada.kth.se
***************************************************************************)
unit TextVu;
{$O+,F+,X+,I-,S-}

interface

  uses Dos, Drivers, Objects, TextView, Views;

  type
    PFastTerminal = ^TFastTerminal;
    TFastTerminal = object (TTerminal)
      constructor Init(var Bounds:TRect; AHScrollBar, AVScrollBar: PScrollBar;
        ABufSize: Word);
      procedure AddLine(var Buf; Count:integer);
      function  CalcWidth: Integer;
      function  CanInsert(Amount: Word): Boolean;
      procedure Draw; virtual;
      function  NextLines(Pos, Count:word):word;
      procedure StrWrite(var S: TextBuf; Count: Byte); virtual;
    end;

(***************************************************************************
***************************************************************************)
implementation

  constructor TFastTerminal.Init(var Bounds:TRect; AHScrollBar,
    AVScrollBar: PScrollBar; ABufSize: Word);
  begin
    TTerminal.Init(Bounds, AHScrollBar, AVScrollBar, ABufSize);
    Limit.Y:=0;
    HideCursor;
  end;

  procedure TFastTerminal.AddLine(var Buf; Count:integer);
    var
      i : integer;
      ReCalcWidth : boolean;
  begin
    ReCalcWidth:=False;
    while not CanInsert(Count+1) do
    begin
      QueBack:=NextLines(QueBack,1);
      dec(Limit.Y);
      ReCalcWidth:=True;
    end;

    if ReCalcWidth then
      Limit.X:=CalcWidth;

    Buffer^[QueFront]:=Chr(Count);
    inc(QueFront);
    if QueFront>=BufSize then
      QueFront:=0;

    if BufSize-QueFront<Count then
    begin
      i:=BufSize-QueFront;
      Move(Buf,Buffer^[QueFront], i);
      Move(TByteArray(Buf)[i], Buffer^, Count-i);
      QueFront:=Count-i;
    end
    else
    begin
      Move(Buf, Buffer^[QueFront], Count);
      inc(QueFront, Count);
    end;

    if Count>Limit.X then
      Limit.X:=Count;
    inc(Limit.Y);
  end;

  function TFastTerminal.CalcWidth:integer;
  var
    i, Width : integer;
    CurPos   : integer;
  begin
    Width:=0;
    CurPos:=QueBack;
    for i:=1 to Limit.Y do
    begin
      if ord(Buffer^[CurPos])>Width then
        Width:=ord(Buffer^[CurPos]);
      CurPos:=NextLines(CurPos,1);
    end;
    CalcWidth:=Width;
  end;

  function TFastTerminal.CanInsert(Amount:word):boolean;
  var
    BufFree : word;
  begin
    if QueFront<QueBack then
      BufFree:=QueBack-QueFront
    else
      BufFree:=BufSize-QueFront+QueBack;
    CanInsert:=BufFree>Amount;
  end;

  procedure TFastTerminal.Draw;
  var
    Buf       : TDrawBuffer;
    Color     : byte;
    CurPos    : integer;
    i, LastY  : integer;
    Len, Len1 : integer;
  begin
    Color:=GetColor(1);

    if Size.Y>Limit.Y then
    begin
      MoveChar(Buf, ' ', Color, Size.X);
      WriteLine(0, Limit.Y, Size.X, Size.Y-Limit.Y, Buf);
      LastY:=Limit.Y;
    end
    else
      LastY:=Size.Y;

    CurPos:=NextLines(QueBack, Delta.Y);
    for i:=0 to LastY-1 do
    begin
      Len:=ord(Buffer^[CurPos])-Delta.X;
      if Len>Size.X then
        Len:=Size.X;
      if Len>0 then
        if BufSize-Len-Delta.X>CurPos+1 then
          MoveBuf(Buf, Buffer^[CurPos+1+Delta.X], Color, Len)
        else
        begin
          Len1:=BufSize-CurPos-1-Delta.X;
          MoveBuf(Buf, Buffer^[CurPos+1+Delta.X], Color, Len1);
          MoveBuf(Buf[Len1], Buffer^, Color, Len-Len1);
        end;
      if Len<0 then
        Len:=0;
      MoveChar(Buf[Len], ' ', Color, Size.X-Len);
      WriteLine(0, i, Size.X, 1, Buf);
      CurPos:=NextLines(CurPos,1);
    end;
  end;

  function TFastTerminal.NextLines(Pos, Count:word):word; assembler;
  asm
      mov  bx,Pos
      cmp  Count,0
      je   @Fin

      les  di,Self
      mov  dx,es:[di].BufSize

      les  di,es:[di].Buffer
      mov  ah,0

    @Loop:
      mov  al,es:[di+bx]
      stc
      adc  bx,ax
      jc   @Fix
      cmp  bx,dx
      jb   @OK

    @Fix:
      sub  bx,dx

    @OK:
      dec  Count
      jne  @Loop

    @Fin:
      mov  ax,bx
  end;

  procedure TFastTerminal.StrWrite(var S: TextBuf; Count: Byte);
  var
    i, j: Word;
  begin
    if Count>0 then
    begin
      j:=0;
      for i:=0 to Count-1 do
        if S[i]=#13 then
        begin
          AddLine(S[j], i-j);
          j:=i+2;
        end;

      Owner^.Lock;
      SetLimit(Limit.X, Limit.Y);
      ScrollTo(0, Limit.Y);
      if Limit.Y<=Size.Y then
        DrawView;
      Owner^.Unlock;
    end;
  end;


    (*******************************************************************
    *******************************************************************)

end.
