PROGRAM SplashScreen;

USES Crt,Dos,Graph,Arithmos,Basic,BMPLoad,Cursor,RT_Watch,Scan_Exo,ConstVar,LZSSUnit;

VAR
  x,y             : Integer;
  InFile,OutFile  : FILE;

FUNCTION ToUpper(S : STRING) : STRING; ASSEMBLER;
ASM
  PUSH DS
  CLD
  LDS SI,S
  LES DI,@Result
  LODSB
  STOSB
  XOR AH,AH
  XCHG AX,CX
  JCXZ @@3
@@1:
  LODSB
  CMP AL,'a'
  JB  @@2
  CMP AL,'z'
  JA  @@2
  SUB AL,20h
@@2:
  STOSB
  LOOP @@1
@@3:
  POP DS
END;

FUNCTION ReadProc(VAR ReadBuf; VAR NumRead : Word) : Word; FAR;
BEGIN
  BlockRead(InFile,ReadBuf,LZRWBufSize,NumRead);
{  Write(#13,FilePos(InFile),' -> ')}
END;

FUNCTION WriteProc(VAR WriteBuf; Count : Word; VAR NumWritten : Word) : Word; FAR;
BEGIN
  BlockWrite(OutFile,WriteBuf,Count,NumWritten);
{  Write(FilePos(OutFile), #13)}
END;

PROCEDURE SearchDir(Path : PathStr; fspec : STRING);
VAR
  f : SearchRec;
BEGIN
  FindFirst(Path+fspec,AnyFile,f);
  WHILE DosError = 0 DO BEGIN
    Inc(b);
    ExoFile[b] := f.name;
    Findnext(f);
  END;
END;

BEGIN
  Randomize;
  GraphDriver := Detect;
  IF ParamCount < 2 THEN BEGIN
    IF FileExists('splash.pic') THEN BEGIN
      InitGraph(GraphDriver,GraphMode,'');
      ReadBMP('splash.pic',True,1,1,640,480,x,y);
      SetColor(White+2);
      SetTextStyle(2,HorizDir,10);
      OutTextXY(200,30,'EXO-DB2 1.8');
      OutTextXY(201,30,'EXO-DB2 1.8');
      OutTextXY(202,30,'EXO-DB2 1.8');
      SetTextStyle(2,HorizDir,5);
      OutTextXY(130,80,'(C) 1995-2006 Michael Johne * http://www.exodb.de.vu');
      Line(200,70,450,70);
      Line(200,71,450,71);
      OutTextXY(330,450,'>> DrÅcken Sie eine Taste fÅr WEITER <<');
      Readkey;
      CloseGraph;
      Halt(0);
    END;
  END;
  IF NOT LZInit THEN BEGIN
    IF FileExists('splash.pic') THEN BEGIN
      InitGraph(GraphDriver,GraphMode,'');
      ReadBMP('splash.pic',True,1,1,640,480,x,y);
      SetColor(White+2);
      SetTextStyle(2,HorizDir,10);
      OutTextXY(200,30,'EXO-DB2 1.8');
      OutTextXY(201,30,'EXO-DB2 1.8');
      OutTextXY(202,30,'EXO-DB2 1.8');
      SetTextStyle(2,HorizDir,5);
      OutTextXY(130,80,'(C) 1995-2006 Michael Johne * http://www.exodb.de.vu');
      Line(200,70,450,70);
      Line(200,71,450,71);
      OutTextXY(330,450,'>> DrÅcken Sie eine Taste fÅr WEITER <<');
      Readkey;
      CloseGraph;
      Halt(0);
    END;
  END;
  Assign(InFile,ParamStr(1));
  Reset(InFile, 1);
  IF IOResult = 0 THEN BEGIN
    Assign(OutFile, ParamStr(2));
    Rewrite(OutFile,1);
    IF IOResult = 0 THEN BEGIN
      IF ToUpper(ParamStr(3)) = 'UNSQUASH' THEN LZUnSquash(ReadProc,WriteProc)
        ELSE LZSquash(ReadProc,WriteProc);
      Close(OutFile)
    END ELSE BEGIN
      IF FileExists('splash.pic') THEN BEGIN
        InitGraph(GraphDriver,GraphMode,'');
        ReadBMP('splash.pic',True,1,1,640,480,x,y);
        SetColor(White+2);
        SetTextStyle(2,HorizDir,10);
        OutTextXY(200,30,'EXO-DB2 1.8');
        OutTextXY(201,30,'EXO-DB2 1.8');
        OutTextXY(202,30,'EXO-DB2 1.8');
        SetTextStyle(2,HorizDir,5);
        OutTextXY(130,80,'(C) 1995-2006 Michael Johne * http://www.exodb.de.vu');
        Line(200,70,450,70);
        Line(200,71,450,71);
        OutTextXY(330,450,'>> DrÅcken Sie eine Taste fÅr WEITER <<');
        Readkey;
        CloseGraph;
        Halt(0);
      END;
    END;
    Close(InFile)
  END ELSE BEGIN
    IF FileExists('splash.pic') THEN BEGIN
      InitGraph(GraphDriver,GraphMode,'');
      ReadBMP('splash.pic',True,1,1,640,480,x,y);
      SetColor(White+2);
      SetTextStyle(2,HorizDir,10);
      OutTextXY(200,30,'EXO-DB2 1.8');
      OutTextXY(201,30,'EXO-DB2 1.8');
      OutTextXY(202,30,'EXO-DB2 1.8');
      SetTextStyle(2,HorizDir,5);
      OutTextXY(130,80,'(C) 1995-2006 Michael Johne * http://www.exodb.de.vu');
      Line(200,70,450,70);
      Line(200,71,450,71);
      OutTextXY(330,450,'>> DrÅcken Sie eine Taste fÅr WEITER <<');
      Readkey;
      CloseGraph;
      Halt(0);
    END;
  END;
  LZDone;
  IF FileExists('splash\temp.pic') THEN BEGIN
    InitGraph(GraphDriver,GraphMode,'');
    ReadBMP('splash\temp.pic',True,1,1,640,480,x,y);
    SetColor(White+2);
    SetTextStyle(2,HorizDir,10);
    OutTextXY(200,30,'EXO-DB2 1.8');
    OutTextXY(201,30,'EXO-DB2 1.8');
    OutTextXY(202,30,'EXO-DB2 1.8');
    SetTextStyle(2,HorizDir,5);
    OutTextXY(130,80,'(C) 1995-2006 Michael Johne * http://www.exodb.de.vu');
    Line(200,70,450,70);
    Line(200,71,450,71);
    OutTextXY(330,450,'>> DrÅcken Sie eine Taste fÅr WEITER <<');
    Readkey;
    CloseGraph;
    Assign(InFile,'splash\temp.pic');
    Erase(InFile);
  END;
END.
