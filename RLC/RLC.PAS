{$A+ $B- $D- $E- $F- $G- $I+ $N- $P- $Q- $R- $S+ $T- $V- $X- $Y-}
{$C MOVEABLE DEMANDLOAD DISCARDABLE}
{$M 16384,0,655360}

PROGRAM Run_Length_Compression(RLC);

USES Crt, Dos;

TYPE
  pl  = ^ple;
  ple = ARRAY[1..64005] OF Byte;

VAR
  Charset          : ARRAY[0..255] OF LongInt;
  Character        : ARRAY[0..255] OF Char;
  ByteCount,byt,
  n,Steuercode     : Byte;
  Stop,
  Compressable,
  YetCompressed    : Boolean;
  Lastbyte,
  CurrentByte,
  SpecialCode,
  Data,Option      : Char;
  Compress3        : FILE;
  FileOfSize       : FILE OF Byte;
  PozIn,PozOut,
  i,Size           : LongInt;
  SavePtrHeapRoot  : Pointer;
  Pole,Out         : pl;
  CompressFile,
  DecompressFile,
  FileToCompress,
  FileToDecompress : STRING[12];
  Compress1,
  Compress2,
  Decompress1,
  Decompress2      : Text;
  w,
  ResultIn,
  ResultOut        : Word;


PROCEDURE Compression;
BEGIN
  {Speicher fÅr Special Compression bereitstellen}
  IF Option = '4' THEN BEGIN
    GetMem(Pole,SizeOf(Pole^));
    GetMem(Out,SizeOf(Out^));
    FOR i  :=  1 TO 64005 DO BEGIN
      Pole^[i]  :=  0;
      Out^[i]   :=  0;
    END;
  END;
  Write(' Name of file to compress: ');
  TextColor(White);
  ReadLn(FileToCompress);
  TextColor(LightGray);
  Write(' Name of file to output [.RLC]: ');
  TextColor(White);
  ReadLn(CompressFile);
  {Steuercode-Tabelle initialisieren}
  FOR Steuercode := 0 TO 255 DO Charset[Steuercode] := 0;
  {Dateigrî·e ermitteln}
  Assign(FileOfSize,FileToCompress);
  Reset(FileOfSize);
  Size := FileSize(FileOfSize);
  Close(FileOfSize);
  {Dateien îffnen bzw. erstellen}
  Assign(Compress1,FileToCompress);
  IF Pos('.',CompressFile) = 0 THEN CompressFile := CompressFile+'.RLC';
  Assign(Compress2,CompressFile);
  Reset(Compress1);
  Rewrite(Compress2);
  {Steuercode ermitteln}
  Compressable := False;
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
    TextColor(LightRed);
    WriteLn(' file not compressable');
    Close(Compress2);
    Erase(Compress2);
    Close(Compress1);
    Halt;
  END;
  {Steuercode-Tabelle neu initialisieren}
  FOR i := 0 TO 255 DO Charset[Steuercode] := 0;
  {Beginn der Kompression}
  TextColor(Yellow);
  IF Option = '4' THEN SpecialCode := Chr(1) ELSE SpecialCode := Chr(0);
  IF Option <> '4' THEN BEGIN
    Reset(Compress1);
    Write(Compress2,'RLC',SpecialCode,Chr(Steuercode));
  END;
  WriteLn;
  WriteLn(' ˛ set signature RLC');
  WriteLn(' ˛ set special code (',Ord(SpecialCode),')');
  WriteLn(' ˛ set steuercode (',Steuercode,')');
  IF Option = '1' THEN BEGIN
    {Alte Kompression}
    REPEAT
      ByteCount := 0;
      Read(Compress1,Character[1]);
      Read(Compress1,Character[2]);
      Read(Compress1,Character[3]);
      ByteCount := ByteCount+3;
      IF (Character[1] = Character[2]) AND (Character[1] = Character[3]) THEN BEGIN
        REPEAT
          Inc(ByteCount);
          Read(Compress1,Character[ByteCount]);
        UNTIL (ByteCount = 255) OR (Character[ByteCount] <> Character[1]);
        IF ByteCount <> 255 THEN Write(Compress2,Chr(Steuercode),Chr(ByteCount-1),Character[1],Character[ByteCount])
                            ELSE Write(Compress2,Chr(Steuercode),Chr(ByteCount),Character[1]);
      END ELSE Write(Compress2,Character[1],Character[2],Character[3]);
    UNTIL EoF(Compress1);
  END ELSE IF Option = '2' THEN BEGIN
    {Neue Kompression}
    REPEAT
      ByteCount := 0;
      Read(Compress1,LastByte);
      Read(Compress1,CurrentByte);
      ByteCount := 2;
      IF LastByte <> CurrentByte THEN BEGIN
        Write(Compress2,LastByte,CurrentByte);
        ByteCount := 0;
      END;
      IF LastByte = CurrentByte THEN BEGIN
        Read(Compress1,CurrentByte);
        Inc(ByteCount);
        IF CurrentByte <> LastByte THEN BEGIN
          ByteCount := 0;
          Write(Compress2,LastByte,LastByte,CurrentByte);
        END;
        IF CurrentByte = LastByte THEN BEGIN
          REPEAT
            Read(Compress1,CurrentByte);
            Inc(ByteCount);
          UNTIL (CurrentByte <> LastByte) OR (ByteCount=255);
          IF ByteCount = 255 THEN Write(Compress2,Chr(Steuercode),Chr(ByteCount),LastByte)
                             ELSE Write(Compress2,Chr(Steuercode),Chr(ByteCount-1),LastByte,CurrentByte);
        END;
      END;
    UNTIL EoF(Compress1);
  END ELSE IF Option = '3' THEN BEGIN
    {Neue und verbesserte Kompression}
    YetCompressed := False;
    REPEAT
      ByteCount := 0;
      IF YetCompressed = False THEN Read(Compress1,LastByte) ELSE LastByte := CurrentByte;
      Read(Compress1,CurrentByte);
      ByteCount := 2;
      IF LastByte <> CurrentByte THEN BEGIN
        Write(Compress2,LastByte);
        ByteCount := 0;
        YetCompressed := True;
      END;
      IF LastByte = CurrentByte THEN BEGIN
        Read(Compress1,CurrentByte);
        Inc(ByteCount);
        YetCompressed := False;
        IF CurrentByte <> LastByte THEN BEGIN
          ByteCount := 0;
          Write(Compress2,LastByte,LastByte);
          YetCompressed := True;
        END;
        IF CurrentByte = LastByte THEN BEGIN
          REPEAT
            Read(Compress1,CurrentByte);
            Inc(ByteCount);
          UNTIL (CurrentByte <> LastByte) OR (ByteCount=255);
          IF ByteCount = 255 THEN Write(Compress2,Chr(Steuercode),Chr(ByteCount),LastByte)
                             ELSE Write(Compress2,Chr(Steuercode),Chr(ByteCount-1),LastByte);
          YetCompressed := True;
        END;
      END;
    UNTIL EoF(Compress1);
    Write(Compress2,CurrentByte);
  END ELSE BEGIN
    {Special Compression}
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
        Size := 0;
        Stop := FALSE;
        REPEAT
          Inc(PozIn);
          IF Pole^[PozIn] <> Pole^[PozIn+1] THEN Inc(Size) ELSE IF Pole^[PozIn+2]=Pole^[PozIn] THEN BEGIN
            Dec(PozIn);
            Stop := True;
          END ELSE Inc(Size);
        UNTIL (Stop) OR (Size = 127) OR (PozIn = ResultIn);
        Inc(PozOut);
        Out^[PozOut] := Size+128;
        FOR i := 1 TO Size DO BEGIN
          Inc(PozOut);
          Out^[PozOut] := Pole^[PozIn-(Size-i)];
        END;
      END ELSE BEGIN
        Size := 0;
        Stop := False;
        REPEAT
          Inc(PozIn);
          IF Pole^[PozIn]=Pole^[PozIn+1] THEN Inc(Size) ELSE BEGIN
            Inc(Size);
            Stop := True;
          END;
       UNTIL (Stop) OR (Size = 127) OR (PozIn = ResultIn);
        Inc(PozOut);
        Out^[PozOut] := Size;
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
  {Kompressionsrate anzeigen}
  Assign(FileOfSize,CompressFile);
  Reset(FileOfSize);
  i := FileSize(FileOfSize);
  Close(FileOfSize);
  TextColor(LightBlue);
  IF Option = '4' THEN BEGIN
    Assign(FileOfSize,FileToCompress);
    Reset(FileOfSize);
    Size := FileSize(FileOfSize);
    Close(FileOfSize);
  END;
  WriteLn;
  WriteLn(' ',FileToCompress,' to ',CompressFile,': ',Size,' -> ',i,' = ',(i*100/Size):0:2,' %');
END;

PROCEDURE Decompression;
BEGIN
  Write(' Name of file to decompress [.RLC]: ');
  TextColor(White);
  ReadLn(FileToDecompress);
  TextColor(LightGray);
  Write(' Name of file to output: ');
  TextColor(White);
  ReadLn(DecompressFile);
  TextColor(LightGray);
  {Datei erîffnen bzw. erstellen}
  IF Pos('.',DecompressFile) = 0 THEN FileToDecompress := FileToDecompress+'.RLC';
  Assign(FileOfSize,FileToDecompress);
  Reset(FileOfSize);
  Size := FileSize(FileOfSize);
  Close(FileOfSize);
  Assign(DeCompress1,FileToDecompress);
  Reset(Decompress1);
  Assign(Decompress2,DecompressFile);
  Rewrite(Decompress2);
  {Signatur RLC und Steuercode lesen}
  Read(Decompress1,Character[1]);
  Read(Decompress1,Character[2]);
  Read(Decompress1,Character[3]);
  IF Character[1]+Character[2]+Character[3] <> 'RLC' THEN BEGIN
    TextColor(LightRed);
    Write('incorrupted file header');
    Close(Decompress2);
    Erase(Decompress2);
    Halt;
  END;
  Read(Decompress1,SpecialCode);
  Read(Decompress1,Data);
  Steuercode := Ord(Data);
  TextColor(Yellow);
  WriteLn;
  WriteLn(' ˛ signature RLC is okay');
  WriteLn(' ˛ special code is ',Ord(SpecialCode));
  WriteLn(' ˛ steuercode is ',Steuercode);
  {Beginn der Dekompression}
  IF SpecialCode = Chr(0) THEN BEGIN
    {keine Special Compression vorliegend}
    REPEAT
      ByteCount := 0;
      Read(Decompress1,Data);
      IF Data = Chr(Steuercode) THEN BEGIN
        Read(Decompress1,Option);
        Read(Decompress1,Data);
        FOR n := 1 TO Ord(Option) DO Write(Decompress2,Data);
        ByteCount := ByteCount+3;
      END ELSE BEGIN
        Write(Decompress2,Data);
        Inc(ByteCount);
      END;
    UNTIL EoF(Decompress1);
  END ELSE BEGIN
    {Dekompression der Special Compression}
    {Speicher fÅr Dekompression der Special Compression bereitstellen}
    Close(Decompress1);
    Close(Decompress2);
    GetMem(Pole,SizeOf(Pole^));
    GetMem(Out,SizeOf(Out^));
    FOR i :=  1 TO 64005 DO BEGIN
      Pole^[i] := 0;
      Out^[i]  := 0;
    END;
    Assign(Compress3,FileToDecompress);
    Reset(Compress3,1);
    BlockRead(Compress3,Pole^,SizeOf(Pole^),ResultIn);
    Close(Compress3);
    PozIn := 5;{5}
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
  {Dekompressionsrate anzeigen}
  Assign(FileOfSize,DecompressFile);
  Reset(FileOfSize);
  i := FileSize(FileOfSize);
  Close(FileOfSize);
  TextColor(LightBlue);
  WriteLn;
  WriteLn(' ',FileToDecompress,' to ',DecompressFile,': ',Size,' -> ',i,' = ',(i*100/Size):0:2,' %');
END;

BEGIN
  Mark(SavePtrHeapRoot);
  ClrScr;
  TextColor(White);
  WriteLn('Run Length Compression (RLC)   (c) 2002 Michael Johne et al.');
  WriteLn('============================   -----------------------------');
  WriteLn;
  WriteLn;
  TextColor(LightCyan);
  WriteLn('   1 - Old Compression (based on my first own created algorithm)');
  WriteLn('   2 - New Compression (after a idea by Martin Fiedler)');
  WriteLn('   3 -  " and Improved Compression (Standard RLC-Compression)');
  WriteLn('   4 -  Special Compression (algorithm based on NEWRLE by The(c)King1980)');
  TextColor(LightGreen);
  WriteLn('   5 - Decompression');
  TextColor(LightRed);
  WriteLn('   6 - Exit');
  WriteLn;
  TextColor(LightGray);
  Write(' Choose your option: ');
  TextColor(White);
  REPEAT
    Option := ReadKey;
  UNTIL Option IN ['1'..'6'];
  WriteLn(Ord(Option)-48);
  TextColor(LightGray);
  CASE Option OF
    '1',
    '2',
    '3',
    '4'  : Compression;
    '5'  : Decompression;
    '6'  : BEGIN
             TextColor(LightGray);
             Release(SavePtrHeapRoot);
             Halt;
           END;
  END;
  Release(SavePtrHeapRoot);
END.
