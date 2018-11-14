PROGRAM Run_Length_Compression(RLC);

USES Crt,Dos,Graph;

LABEL Start;

CONST
  Menu : ARRAY[1..6] OF STRING[72] =
    (' 1. Old Compression (based on my first own created algorithm)          ',
     ' 2. New Compression (after a idea by Martin Fiedler)                   ',
     ' 3.  " and Improved Compression (Standard RLC-Compression)             ',
     ' 4. Special Compression (algorithm based on NEWRLE by The(c)King1980)  ',
     ' 5. Decompression                                                      ',
     ' 6. Exit                                                               ');

TYPE
  pl  = ^ple;
  ple = ARRAY[1..64005] OF Byte;

VAR
  Charset          : ARRAY[0..255] OF LongInt;
  IO_Bytes         : ARRAY[1..002] OF LongInt;
  NavKey           : ARRAY[1..002] OF Char;
  Character        : ARRAY[0..255] OF Char;
  ByteCount,byt,XY,
  XY2,n,Steuercode : Byte;
  Alarm,
  Stop,
  Compressable,
  YetCompressed    : Boolean;
  Lastbyte,
  CurrentByte,
  SpecialCode,
  Data,Option      : Char;
  Control1,
  Control2         : Integer;
  Compress3        : FILE;
  FileOfSize       : FILE OF Byte;
  PozIn,PozOut,
  i,Size,Size2     : LongInt;
  SavePtrHeapRoot  : Pointer;
  Pole,Out         : pl;
  CompressFile,
  DecompressFile,
  FileToCompress,
  FileToDecompress : STRING[12];
  Message          : STRING[40];
  Compress1,
  Compress2,
  Decompress1,
  Decompress2      : Text;
  w,
  ResultIn,
  ResultOut        : Word;

PROCEDURE ClearKeyBuff;
BEGIN
  ASM
    mov ax,$0C06;
    mov dl,$FF;
    int $21
  END;
END;

PROCEDURE Wait(ms : Word); ASSEMBLER;
ASM
  mov ax, 1000;
  mul ms;
  mov cx, dx;
  mov dx, ax;
  mov ah, $86;
  Int $15;
END;

PROCEDURE Blink(Attribut : Byte);
BEGIN
  IF Attribut = 1 THEN BEGIN
    ASM
      mov AH,10h
      mov AL,03h
      mov BL,1
      int 10h
    END;
  END ELSE IF Attribut = 0 THEN BEGIN
    ASM
      mov AH,10h
      mov AL,03h
      mov BL,0
      int 10h
    END;
  END ELSE BEGIN
    Blink(1);
    TextBackground(Black);
    TextColor(Red);
    WriteLn('Falscher Aufruf internen Prozedure BLINK');
    ReadKey;
    Release(SavePtrHeapRoot);
    ClrScr;
    Blink(1);
    TextBackGround(Black);
    TextColor(LightGray);
    Halt;
  END;
END;

PROCEDURE Cursor(Visible : Boolean);
VAR
  grDriver,grMode : Integer;
  BTXMEM	  : LongInt;
  regs            : Registers;
BEGIN
  grDriver := Detect;
  DetectGraph(grDriver,grMode);
  CASE grDriver OF
    1..6,8..9 : BTXMEM := $B800;
    -2,7,10   : BTXMEM := $B000;
  END;
  regs.ah := 1;
  IF Visible THEN BEGIN
    IF BTXMEM = $B800 THEN BEGIN
      regs.ch := 6;
      regs.cl := 7;
    END
    ELSE
    BEGIN
      regs.ch := 12;
      regs.cl := 13;
    END;
    Intr(16,regs);
  END
  ELSE
  BEGIN
    regs.ch := 32;
    regs.cl := 7;
    Intr(16,regs);
  END;
END;

PROCEDURE Box1(x1,y1,x2,y2,Color : Integer);
BEGIN
  Alarm := True;
  TextBackGround(Color);
  TextColor(Color+128);
  FOR i := x1 TO x2 DO BEGIN
    FOR n := y1 TO y2 DO BEGIN
      GotoXY(i,n);
      Write(' ');
    END;
  END;
  GotoXY(x1,y1);
  Write('‹');
  FOR i := x1+1 TO x2-1 DO Write('‹');
  Write('‹');
  FOR i := y1+1 TO y2-1 DO BEGIN
    GotoXY(x1,i);
    Write('€');
    GotoXY(x2,i);
    Write('€');
  END;
  GotoXY(x1,y2);
  Write('ﬂ');
  FOR i := x1+1 TO x2-1 DO Write('ﬂ');
  Write('ﬂ');
END;

PROCEDURE Box2(x1, y1, x2, y2 : Integer);
BEGIN
  GotoXY(x1,y1);
  TextColor(Black);
  Write('⁄');
  TextColor(White);
  FOR i := x1+1 TO x2-1 DO Write('ƒ');
  Write('ø');
  FOR i := y1+1 TO y2-1 DO BEGIN
    GotoXY(x1,i);
    TextColor(Black);
    Write('≥');
    GotoXY(x2,i);
    TextColor(White);
    Write('≥');
  END;
  GotoXY(x1,y2);
  TextColor(Black);
  Write('¿');
  FOR i := x1+1 TO x2-1 DO Write('ƒ');
  TextColor(White);
  Write('Ÿ');
END;

PROCEDURE Box3(x1, y1, x2, y2 : Integer);
BEGIN
  FOR i := x1 TO x2 DO BEGIN
    FOR n := y1 TO y2 DO BEGIN
      GotoXY(i,n);
      Write(' ');
    END;
  END;
  GotoXY(x1,y1);
  TextColor(White);
  Write('⁄');
  TextColor(Black);
  FOR i := x1+1 TO x2-1 DO Write('ƒ');
  Write('ø');
  FOR i := y1+1 TO y2-1 DO BEGIN
    GotoXY(x1,i);
    TextColor(White);
    Write('≥');
    GotoXY(x2,i);
    TextColor(Black);
    Write('≥');
  END;
  GotoXY(x1,y2);
  TextColor(White);
  Write('¿');
  FOR i := x1+1 TO x2-1 DO Write('ƒ');
  TextColor(Black);
  Write('Ÿ');
END;

PROCEDURE IO;
BEGIN
  TextColor(White);
  GotoXY(52,19);
  Write('read bytes:  ',IO_Bytes[1]-1:8);
  GotoXY(52,20);
  Write('write bytes: ',IO_Bytes[2]:8);
  IF (Control1) > Round(Size/20) THEN BEGIN
    Control1 := 0;
    Inc(XY);
    GotoXY(52+XY,17);
    Write('≤');
  END;
  TextColor(Black);
  IF Control2 > Round(Size/20) THEN BEGIN
    Control2 := 0;
    Inc(XY2);
    GotoXY(52+XY2,17);
    Write('≤');
  END;
END;

PROCEDURE IO2;
BEGIN
  TextColor(White);
  GotoXY(54,19);
  Write('read bytes:  ',IO_Bytes[1]:8);
  GotoXY(54,20);
  Write('write bytes: ',IO_Bytes[2]:8);
  IF (Control1) > Round(Size/20) THEN BEGIN
    Control1 := 0;
    Inc(XY);
    GotoXY(54+XY,17);
    Write('≤');
  END;
{  TextColor(Black);
  Size2 := Round(IO_Bytes[1]*100/IO_Bytes[2]);
  GotoXY(1,1);
  Write(' ',Size2);
  Size2 := Round((Size2*IO_Bytes[1])/100);
  Write(' ',Size2,' ',Control2,'         ');
  IF Control2 > 2*Round(Size2/20) THEN BEGIN
    Control2 := 0;
    Inc(XY2);
    GotoXY(54+XY2,17);
    Write('≤');
  END;
  Size := Size2;}
END;

PROCEDURE Center(Row: Integer; Str: String);
BEGIN
  Gotoxy(41-Length(Str) DIV 2,Row);
  Write(Str);
END;


PROCEDURE ExitProg;
BEGIN
  IF NavKey[2] <> 'K' THEN ReadKey;
  TextBackGround(Black);
  TextColor(LightGray);
  Blink(1);
  ClrScr;
  Release(SavePtrHeapRoot);
  Halt;
END;

PROCEDURE Compression;
BEGIN
  {$I-}
  {Speicher fÅr Special Compression bereitstellen}
  IF Option = '4' THEN BEGIN
    FOR i  :=  1 TO 64005 DO BEGIN
      Pole^[i]  :=  0;
      Out^[i]   :=  0;
    END;
  END;
  {Steuercode-Tabelle initialisieren}
  FOR Steuercode := 0 TO 255 DO Charset[Steuercode] := 0;
  GotoXY(6,16);
  TextBackground(Cyan);
  TextColor(Black);
  Write(' Name of file to compress:      ');
  Cursor(True);
  TextColor(White);
  TextBackground(Black);
  Write('            ');
  GotoXY(38,16);
  ReadLn(FileToCompress);
  Assign(FileOfSize,FileToCompress);
  Reset(FileOfSize);
  IF IOResult <> 0 THEN BEGIN
    Box1(24,8,57,13,Red);
    TextColor(Yellow+128);
    Message := 'file "'+FileToCompress+'" not found';
    Center(10,Message);
    TextColor(Black+128);
    Message := 'Press any key...';
    Center(11,Message);
    Exit;
  END;
  Size := FileSize(FileOfSize);
  Close(FileOfSize);
  Assign(Compress1,FileToCompress);
  Reset(Compress1);
  FOR n := 1 TO 12 DO FileToCompress[n] := UpCase(FileToCompress[n]);
  GotoXY(38,16);
  Write(FileToCompress);
  GotoXY(6,17);
  TextBackground(Cyan);
  TextColor(Black);
  Write(' Name of file to output [.RLC]: ');
  Cursor(True);
  TextColor(White);
  TextBackground(Black);
  Write('            ');
  GotoXY(38,17);
  ReadLn(CompressFile);
  IF Pos('.',CompressFile) = 0 THEN CompressFile := CompressFile+'.RLC';
  Assign(Compress2,CompressFile);
  Rewrite(Compress2);
  IF IOResult <> 0 THEN BEGIN
    Box1(24,8,57,13,Red);
    TextColor(Yellow+128);
    Message := 'file "'+CompressFile+'" not found';
    Center(10,Message);
    TextColor(Black+128);
    Message := 'Press any key...';
    Center(11,Message);
    Exit;
  END;
  FOR n := 1 TO 12 DO CompressFile[n] := UpCase(CompressFile[n]);
  GotoXY(38,17);
  Write(CompressFile);
  GotoXY(6,18);
  TextBackGround(Cyan);
  Compressable := False;
  {Steuercode ermitteln}
  FOR i := 1 TO Size DO BEGIN
    Read(Compress1,Data);
    Steuercode := Ord(Data);
    Inc(Charset[Steuercode]);
  END;
  Close(Compress1);
  FOR i := 0 TO 255 DO IF Charset[i] = 0 THEN BEGIN
    Steuercode := i;
    Compressable := True;
    Break;
  END;
  IF Option = '4' THEN BEGIN
    Assign(Compress3,FileToCompress);
    Reset(Compress3,1);
    BlockRead(Compress3,Pole^,SizeOf(Pole^),ResultIn);
    Close(Compress3);
  END;
  IF Compressable = False THEN BEGIN
    Box1(24,8,57,13,Red);
    TextColor(Yellow+128);
    WriteLn(' file not compressable');
    TextColor(Black+128);
    Message := 'Press any key...';
    Center(11,Message);
    Close(Compress2);
    Erase(Compress2);
    Close(Compress1);
    Exit;
  END;
  TextColor(Yellow);
  {Beginn der Kompression}
  IF Option = '4' THEN SpecialCode := Chr(1) ELSE SpecialCode := Chr(0);
  IF Option <> '4' THEN BEGIN
    Reset(Compress1);
    Write(Compress2,'RLC',SpecialCode,Chr(Steuercode));
  END;
  GotoXY(6,18);
  Write(' ˛ set signature RLC');
  GotoXY(6,19);
  Write(' ˛ set special code (',Ord(SpecialCode),')');
  GotoXY(6,20);
  Write(' ˛ set steuercode (',Steuercode,')');
  Cursor(False);
  IF Option <> '4' THEN IO_Bytes[2] := 5;
  GotoXY(52,16);
  TextColor(White);
  Write('√¬¬¬¬≈¬¬¬¬≈¬¬¬¬≈¬¬¬¬¥');
  GotoXY(52,17);
  Write('≥');
  GotoXY(72,17);
  Write('≥');
  GotoXY(52,18);
  Write('√¡¡¡¡≈¡¡¡¡≈¡¡¡¡≈¡¡¡¡¥');
  IO;
  IF Option = '1' THEN BEGIN
    {Alte Kompression}
    REPEAT
      ByteCount := 0;
      Read(Compress1,Character[1]);
      Read(Compress1,Character[2]);
      Read(Compress1,Character[3]);
      ByteCount := ByteCount+3;
      Inc(IO_Bytes[1],3);
      Inc(Control1,3);
      IO;
      IF (Character[1] = Character[2]) AND (Character[1] = Character[3]) THEN BEGIN
        REPEAT
          Inc(ByteCount);
          Read(Compress1,Character[ByteCount]);
          Inc(Control1);
          Inc(IO_Bytes[1]);
          IO;
        UNTIL (ByteCount = 255) OR (Character[ByteCount] <> Character[1]);
        IF ByteCount <> 255 THEN Write(Compress2,Chr(Steuercode),Chr(ByteCount-1),Character[1],Character[ByteCount])
                            ELSE Write(Compress2,Chr(Steuercode),Chr(ByteCount),Character[1]);
        IF ByteCount <> 255 THEN Inc(Control2,4)
                            ELSE Inc(Control2,3);
      END ELSE BEGIN
        Write(Compress2,Character[1],Character[2],Character[3]);
        Inc(Control2,3);
      END;
      IF (Character[1] = Character[2]) AND (Character[1] = Character[3]) THEN Inc(IO_Bytes[2],4)
                                                                         ELSE Inc(IO_Bytes[2],3);
      IO;
    UNTIL EoF(Compress1);
  END ELSE IF Option = '2' THEN BEGIN
    {Neue Kompression}
    REPEAT
      ByteCount := 0;
      Read(Compress1,LastByte);
      Read(Compress1,CurrentByte);
      Inc(IO_Bytes[1],2);
      Inc(Control1,2);
      ByteCount := 2;
      IO;
      IF LastByte <> CurrentByte THEN BEGIN
        Write(Compress2,LastByte,CurrentByte);
        Inc(IO_Bytes[2],2);
        Inc(Control2,2);
        ByteCount := 0;
        IO;
      END;
      IF LastByte = CurrentByte THEN BEGIN
        Read(Compress1,CurrentByte);
        Inc(ByteCount);
        Inc(IO_Bytes[1]);
        Inc(Control1);
        IO;
        IF CurrentByte <> LastByte THEN BEGIN
          ByteCount := 0;
          Write(Compress2,LastByte,LastByte,CurrentByte);
          Inc(IO_Bytes[2],3);
          Inc(Control2,3);
          IO;
        END;
        IF CurrentByte = LastByte THEN BEGIN
          REPEAT
            Read(Compress1,CurrentByte);
            Inc(IO_Bytes[1]);
            Inc(Control1);
            Inc(ByteCount);
            IO;
          UNTIL (CurrentByte <> LastByte) OR (ByteCount=255);
          IF ByteCount = 255 THEN Write(Compress2,Chr(Steuercode),Chr(ByteCount),LastByte)
                             ELSE Write(Compress2,Chr(Steuercode),Chr(ByteCount-1),LastByte,CurrentByte);
          IF ByteCount = 255 THEN BEGIN
            Inc(IO_Bytes[2],3);
            Inc(Control2,3);
          END ELSE BEGIN
            Inc(IO_Bytes[2],4);
            Inc(Control2,4);
          END;
          IO;
        END;
      END;
    UNTIL EoF(Compress1);
  END ELSE IF Option = '3' THEN BEGIN
    {Neue und verbesserte Kompression}
    YetCompressed := False;
    REPEAT
      ByteCount := 0;
      IF YetCompressed = False THEN BEGIN
        Read(Compress1,LastByte);
        Inc(IO_Bytes[1]);
        Inc(Control1);
        IO;
      END ELSE LastByte := CurrentByte;
      Read(Compress1,CurrentByte);
      ByteCount := 2;
      Inc(IO_Bytes[1]);
      Inc(Control1);
      IO;
      IF LastByte <> CurrentByte THEN BEGIN
        Write(Compress2,LastByte);
        ByteCount := 0;
        YetCompressed := True;
        Inc(IO_Bytes[2]);
        Inc(Control2);
        IO;
      END;
      IF LastByte = CurrentByte THEN BEGIN
        Read(Compress1,CurrentByte);
        Inc(IO_Bytes[1]);
        Inc(Control1);
        IO;
        Inc(ByteCount);
        YetCompressed := False;
        IF CurrentByte <> LastByte THEN BEGIN
          ByteCount := 0;
          Write(Compress2,LastByte,LastByte);
          Inc(IO_Bytes[2],2);
          Inc(Control2,2);
          IO;
          YetCompressed := True;
        END;
        IF CurrentByte = LastByte THEN BEGIN
          REPEAT
            Read(Compress1,CurrentByte);
            Inc(ByteCount);
            Inc(IO_Bytes[1]);
            Inc(Control1);
            IO;
          UNTIL (CurrentByte <> LastByte) OR (ByteCount=255);
          IF ByteCount = 255 THEN Write(Compress2,Chr(Steuercode),Chr(ByteCount),LastByte)
                             ELSE Write(Compress2,Chr(Steuercode),Chr(ByteCount-1),LastByte);
          Inc(IO_Bytes[2],3);
          Inc(Control2,3);
          IO;
          YetCompressed := True;
        END;
      END;
    UNTIL EoF(Compress1);
    Write(Compress2,CurrentByte);
    Inc(IO_Bytes[2]);
    Inc(Control2);
    IO;
  END ELSE BEGIN
    {Special Compression}
    FOR i := 1 TO Size DO BEGIN
      Inc(IO_Bytes[1]);
      Inc(Control1);
      IO;
    END;
    PozIn  := 0;
    PozOut := 5;
    Out^[1] := Ord('R');
    Out^[2] := Ord('L');
    Out^[3] := Ord('C');
    Out^[4] := Ord(SpecialCode);
    Out^[5] := Steuercode;
    WHILE NOT(PozIn = ResultIn) DO BEGIN
      IF (Pole^[PozIn+1] <> Pole^[PozIn+3]) OR ((Pole^[PozIn+1] = Pole^[PozIn+3]) AND (Pole^[PozIn+1] <> Pole^[PozIn+2]))
      THEN BEGIN
        Size2 := 0;
        Stop := FALSE;
        REPEAT
          Inc(PozIn);
          IF Pole^[PozIn] <> Pole^[PozIn+1] THEN Inc(Size2) ELSE IF Pole^[PozIn+2]=Pole^[PozIn] THEN BEGIN
            Dec(PozIn);
            Stop := True;
          END ELSE Inc(Size2);
        UNTIL (Stop) OR (Size2 = 127) OR (PozIn = ResultIn);
        Inc(PozOut);
        Out^[PozOut] := Size2+128;
        FOR i := 1 TO Size2 DO BEGIN
          Inc(PozOut);
          Out^[PozOut] := Pole^[PozIn-(Size2-i)];
        END;
      END ELSE BEGIN
        Size2 := 0;
        Stop := False;
        REPEAT
          Inc(PozIn);
          IF Pole^[PozIn]=Pole^[PozIn+1] THEN Inc(Size2) ELSE BEGIN
            Inc(Size2);
            Stop := True;
          END;
       UNTIL (Stop) OR (Size2 = 127) OR (PozIn = ResultIn);
        Inc(PozOut);
        Out^[PozOut] := Size2;
        Inc(PozOut);
        Out^[PozOut] := Pole^[PozIn-1];
      END;
    END;
    ResultOut := PozOut;
    Assign(Compress3,CompressFile);
    ReWrite(Compress3,1);
    BlockWrite(Compress3,Out^,ResultOut,w);
    Close(Compress3);
  END;
  IF Option <> '4' THEN BEGIN
    Close(Compress1);
    Close(Compress2);
  END;
  Assign(FileOfSize,CompressFile);
  Reset(FileOfSize);
  i := FileSize(FileOfSize);
  Close(FileOfSize);
  TextColor(LightBlue);
  IF Option = '4' THEN BEGIN
    FOR w := 1 TO i DO BEGIN
      Inc(IO_Bytes[2]);
      Inc(Control2);
      IO;
    END;
  END;
END;

PROCEDURE Decompression;
BEGIN
  {$I-}
  GotoXY(6,16);
  TextBackground(Green);
  TextColor(Black);
  Write(' Name of file to decompress [.RLC]: ');
  Cursor(True);
  TextColor(White);
  TextBackground(Black);
  Write('            ');
  GotoXY(42,16);
  ReadLn(FileToDecompress);
  IF Pos('.',FileToDecompress) = 0 THEN FileToDecompress := FileToDecompress+'.RLC';
  Assign(FileOfSize,FileToDecompress);
  Reset(FileOfSize);
  IF IOResult <> 0 THEN BEGIN
    Box1(24,8,57,13,Red);
    TextColor(Yellow+128);
    Message := 'file "'+FileToDecompress+'" not found';
    Center(10,Message);
    TextColor(Black+128);
    Message := 'Press any key...';
    Center(11,Message);
    Exit;
  END;
  Size := FileSize(FileOfSize);
  Close(FileOfSize);
  Assign(Decompress1,FileToDecompress);
  Reset(Decompress1);
  FOR n := 1 TO 12 DO FileToDecompress[n] := UpCase(FileToDecompress[n]);
  GotoXY(42,16);
  Write(FileToDecompress);
  GotoXY(6,17);
  TextBackground(Green);
  TextColor(Black);
  Write(' Name of file to output:            ');
  Cursor(True);
  TextColor(White);
  TextBackground(Black);
  Write('            ');
  GotoXY(42,17);
  ReadLn(DecompressFile);
  Assign(Decompress2,DecompressFile);
  Rewrite(Decompress2);
  IF IOResult <> 0 THEN BEGIN
    Box1(24,8,57,13,Red);
    TextColor(Yellow+128);
    WriteLn('file "',DecompressFile,'" not found');
    TextColor(Black+128);
    Message := 'Press any key...';
    Center(11,Message);
    Exit;
  END;
  FOR n := 1 TO 12 DO DecompressFile[n] := UpCase(DecompressFile[n]);
  GotoXY(42,17);
  Write(DecompressFile);
  {Signatur RLC und Steuercode lesen}
  Read(Decompress1,Character[1]);
  Read(Decompress1,Character[2]);
  Read(Decompress1,Character[3]);
  IF Character[1]+Character[2]+Character[3] <> 'RLC' THEN BEGIN
    Box1(24,8,57,13,Red);
    TextColor(Yellow+128);
    Message := 'incorrupted file header';
    Center(10,Message);
    TextColor(Black+128);
    Message := 'Press any key...';
    Center(11,Message);
    Close(Decompress2);
    Erase(Decompress2);
    Exit;
  END;
  Read(Decompress1,SpecialCode);
  Read(Decompress1,Data);
  Steuercode := Ord(Data);
  TextBackground(Green);
  TextColor(Yellow);
  GotoXY(6,18);
  Write(' ˛ signature RLC is okay');
  GotoXY(6,19);
  Write(' ˛ special code is ',Ord(SpecialCode));
  GotoXY(6,20);
  Write(' ˛ steuercode is ',Steuercode);
  IO_Bytes[1] := 0;
  IO_Bytes[2] := 1;
  Inc(IO_Bytes[1],3);
  Inc(Control1,3);
  Cursor(False);
  GotoXY(54,16);
  TextColor(White);
  Write('√¬¬¬¬≈¬¬¬¬≈¬¬¬¬≈¬¬¬¬¥');
  GotoXY(54,17);
  Write('≥');
  GotoXY(74,17);
  Write('≥');
  GotoXY(54,18);
  Write('√¡¡¡¡≈¡¡¡¡≈¡¡¡¡≈¡¡¡¡¥');
  IO2;
  {Beginn der Dekompression}
  IF SpecialCode = Chr(0) THEN BEGIN
    {keine Special Compression vorliegend}
    REPEAT
      ByteCount := 0;
      Read(Decompress1,Data);
      Inc(IO_Bytes[1]);
      Inc(Control1);
      IO2;
      IF Data = Chr(Steuercode) THEN BEGIN
        Read(Decompress1,Option);
        Read(Decompress1,Data);
        Inc(IO_Bytes[1],2);
        Inc(Control1,2);
        IO2;
        FOR n := 1 TO Ord(Option) DO BEGIN
	  Write(Decompress2,Data);
          Inc(IO_Bytes[2]);
          Inc(Control2);
          IO2;
        END;
        ByteCount := ByteCount+3;
      END ELSE BEGIN
        Write(Decompress2,Data);
        Inc(IO_Bytes[2]);
        Inc(Control2);
        IO2;
        Inc(ByteCount);
      END;
    UNTIL EoF(Decompress1);
  END ELSE BEGIN
    {Dekompression der Special Compression}
    Close(Decompress1);
    Close(Decompress2);
    FOR i :=  1 TO 64005 DO BEGIN
      Pole^[i] := 0;
      Out^[i]  := 0;
    END;
    Assign(Compress3,FileToDecompress);
    Reset(Compress3,1);
    BlockRead(Compress3,Pole^,SizeOf(Pole^),ResultIn);
    Close(Compress3);
    FOR i := 1 TO Size DO BEGIN
      Inc(IO_Bytes[1]);
      Inc(Control1);
      IO2;
    END;
    PozIn := 5;
    PozOut := 0;
    WHILE NOT(PozIn=ResultIn) DO BEGIN
      Inc(PozIn);
      ByteCount := Pole^[PozIn];
       IF ByteCount < 128 THEN BEGIN
        Inc(PozIn);
        byt := Pole^[PozIn];
        FOR n := 1 TO ByteCount DO BEGIN
          Inc(PozOut);
          Out^[PozOut] := byt;
        END;
      END ELSE BEGIN
        FOR n := 1 TO ByteCount-128 DO BEGIN
          Inc(PozIn);
          byt := Pole^[PozIn];
          Inc(PozOut);
          Out^[PozOut] := byt;
        END;
      END;
    END;
    ResultOut := PozOut;
    Assign(Compress3,DecompressFile);
    ReWrite(Compress3,1);
    BlockWrite(Compress3,Out^,ResultOut,w);
    Close(Compress3);
  END;
  IF SpecialCode = Chr(0) THEN BEGIN
    Close(Decompress1);
    Close(Decompress2);
  END;
  Assign(FileOfSize,DecompressFile);
  Reset(FileOfSize);
  i := FileSize(FileOfSize);
  Close(FileOfSize);
  IF SpecialCode = Chr(1) THEN BEGIN
    FOR w := 1 TO i DO BEGIN
      GotoXY(54,20);
      Write('write bytes: ',w:8);
    END;
  END;
END;

BEGIN
{$I-}
{$M 16384,0,655360}
  XY := 0;
  XY2 := 0;
  Mark(SavePtrHeapRoot);
  GetMem(Pole,SizeOf(Pole^));
  GetMem(Out,SizeOf(Out^));
  Blink(0);
  Cursor(False);
  TextbackGround(Black);
  ClrScr;
  TextbackGround(Blue);
  TextColor(White);
  FOR i := 2 TO 80-2 DO BEGIN
    FOR n := 2 TO 25-2 DO BEGIN
      GotoXY(i,n);
      Write(' ');
    END;
  END;
  Box2(3,3,80-3,25-3);
  Box2(4,4,80-4,10-4);
  GotoXY(6,5);
  Write('˛');
  TextColor(Yellow);
  Write('    RUN LENGTH COMPRESSION (RLC)   (c) 2002 Michael Johne et al.   ');
  TextColor(White);
  Write('˛');
  Start:
  Cursor(False);
  Alarm := False;
  n := 1;
  REPEAT
    TextBackGround(Blue);
    FOR i := 1 TO 6 DO BEGIN
      GotoXY(5,7+i);
      CASE i OF
        1..4 : TextColor(LightCyan);
        5    : TextColor(LightGreen);
        6    : TextColor(LightRed);
      END;
      Write(Menu[i]);
    END;
    IF n < 0 THEN n := 6;
    IF n < 1 THEN BEGIN
      n := 6;
      GotoXY(5,7+n);
      Write(Menu[n]);
    END;
    IF n > 6 THEN BEGIN
      n := 1;
      GotoXY(5,7+n);
      Write(Menu[n]);
    END;
    TextBackground(Blue);
    TextColor(Yellow+128);
    GotoXY(5,7+n);
    Write(Menu[n]);
    NavKey[1] := ReadKey;
    IF NavKey[1] = Chr(0) THEN BEGIN
      NavKey[2] := ReadKey;
      CASE NavKey[2] OF
        'H' : Dec(n);
        'P' : Inc(n);
        'I' : n := 1;
        'Q' : n := 6;
      END;
    END ELSE BEGIN
      CASE NavKey[1] OF
        '1' : n := 1;
        '2' : n := 2;
        '3' : n := 3;
        '4' : n := 4;
        '5' : n := 5;
        '6' : n := 6;
        Chr(27) : BEGIN
                    n := 6;
                    NavKey[1] := Chr(13);
                  END;
      END;
    END;
  UNTIL NavKey[1] = Chr(13);
  Option := Chr(n+48);
  TextColor(LightGray);
  IF Option <> '5' THEN TextbackGround(Cyan) ELSE TextbackGround(Green);
  IF Option <> '6' THEN Box3(5,15,75,21);
  CASE Option OF
    '1',
    '2',
    '3',
    '4'  : Compression;
    '5'  : Decompression;
    '6'  : BEGIN
             Box1(25,8,56,13,Red);
             TextColor(Yellow+128);
             Message := 'Are you sure, you want quit?';
             Center(10,Message);
             TextbackGround(Red);
             TextColor(Black+128);
             GotoXY(35,11);
             Write(' Yes ');
             TextbackGround(LightGray);
	     Write(' No ');
             REPEAT
               NavKey[1] := ReadKey;
               IF NavKey[1] = Chr(0) THEN BEGIN
                 NavKey[2] := Readkey;
                 CASE NavKey[2] OF
                   'K': BEGIN
                          TextbackGround(LightGray);
                          TextColor(Black+128);
                          GotoXY(35,11);
                          Write(' Yes ');
                          TextbackGround(Red);
			  Write(' No ');
                        END;
                   'M': BEGIN
                          TextbackGround(Red);
                          TextColor(Black+128);
                          GotoXY(35,11);
                          Write(' Yes ');
                          TextbackGround(LightGray);
			  Write(' No ');
                        END;
                 END;
               END;
             UNTIL NavKey[1] = Chr(13);
             IF NavKey[2] = 'K' THEN Exitprog ELSE GOTO Start;
           END;
  END;
  IF Alarm = False THEN BEGIN
    GotoXY(20,18);
    IF Option IN ['1','2','3','4'] THEN Message := 'C' ELSE Message := 'Dec';
    Message := Message+'ompress ratio';
    TextColor(White);
    Center(19,Message);
    Str((i*100/Size):0:2,Message);
    Message := Message+' %';
    TextColor(Black);
    Center(20,Message);
    IF Option <> '6' THEN BEGIN
      Box1(25,8,55,13,Green);
      TextColor(Black+128);
      Message := 'Press any key...';
      Center(11,Message);
      REPEAT
        GotoXY(35,10);
        TextColor(Black+128);
        Write('R E A D Y !');
        Wait(3*60);
        GotoXY(35,10);
        TextColor(Black+128);
        Write('           ');
        Wait(3*60);
      UNTIL KeyPressed; END;
      ClearKeyBuff;
      XY  := 0;
      XY2 := 0;
      IO_Bytes[1] := 0;
      IO_Bytes[2] := 0;
      Control1 := 0;
      Control2 := 0;
  END ELSE ReadKey;
  GOTO Start;
END.
