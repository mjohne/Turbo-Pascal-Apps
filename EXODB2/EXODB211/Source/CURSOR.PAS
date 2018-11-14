Unit Cursor;

Interface

Type
 CursorForm=(CuNone,CuLine,CuBlock,CuHalf);

procedure SetCursorForm(kind:CursorForm);
function  getCursorKind:word;
procedure HideCursor;
procedure ShowCursor;

Implementation
USES Dos;


Var   cursors : array [CursorForm] of word;
      cuform  : CursorForm;

function  getCursorKind:word; assembler;
  asm mov ah,$03; xor bh,bh; int $10; xchg ax,cx end;

procedure setCursorKnd(w:word); assembler;
  asm mov cx,w; mov ah,1; int 10h  end;

function ColorBoard:boolean;
  var cb:word;
  begin asm int $11; mov cb,ax end;
  ColorBoard:=cb and $30 <>$30
  end;

procedure InitCursor;
  begin
  cursors[cuNone]:=$0100;
  if ColorBoard then
    begin cursors[cuLine]:=$0607;
    cursors[cuBlock]:=$0007;
    cursors[cuHalf]:=$0407
    end
  else
    begin cursors[cuLine]:=$0c0d;
    cursors[cuBlock]:=$000d;
    cursors[cuHalf]:=$060d
    end;
  setCursorKnd(cursors[cuLine])
  end;

procedure SetCursorForm(kind:CursorForm);
  begin
  cuForm:=kind; setCursorKnd(cursors[kind])
  end;

{procedure HideCursor;
  begin
   SetCursorForm(CuNone)
  end;}

  PROCEDURE hideCursor;

  VAR r:registers;
   cursorlinestart,cursorlineend:INTEGER;

  BEGIN
      r.ah:=3;
      r.bh:=0;
      INTR($10,r);
      cursorlinestart:=r.ch;
      cursorlineend:=r.cl;
      r.ah:=1;
      r.ch:=$20;
      INTR($10,r);
  END;


procedure ShowCursor;
  begin
   SetCursorForm(CuLine)
  end;

Begin
InitCursor
End.
