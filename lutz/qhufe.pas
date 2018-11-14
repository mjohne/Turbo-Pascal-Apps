PROGRAM QHufe;

USES Crt,Dos;

type
  DataType=array [0..63999] of byte;

var
  Data:^DataType;
  DataSize:longint;
  SegmentIndex:longint;

  InputFile:file;
  OutputFile:file;

  FrequencyTable:array [1..256] of word;
  FrequencyTableSize:word;

  UsedCodeList,UnusedCodeList:array [1..256] of byte;
  UsedCode,UnusedCode:word;

  FrequentlyUsedCodeList:array [1..256] of byte;
  CodeMap:array [1..256] of longint;

  Counter:longint;
  Loop:word;
  Code:byte;
  Frequency:byte;
  CollectMode:boolean;
  Found:boolean;
  AccessStatus:word;
  FileDateTime:longint;

  P1,P2:PathStr;
  D1,D2:DirStr;
  N1,N2:NameStr;
  E1,E2:ExtStr;

function SqueezeFile(InputFileName,OutputFileName:string):byte;
{
  Status Code
  0 = Successful
  1 = Insufficient Memory
  2 = Unable to open input file
  3 = File access error
  4 = Unable to compress file
  5 = Unable to create output file
  255 = Undefined error
}

  function FetchCode(Index:longint):byte;
  var
    Refresh:boolean;

  begin
    FetchCode:=0;

    if Index-1>DataSize then
      Exit;

    Refresh:=False;

    if ((Index-1) div 64000)<>SegmentIndex then
    begin
      SegmentIndex:=(Index-1) div 64000;
      Refresh:=True;
    end;

    if Refresh then
    begin
      {$I-}
      Seek(InputFile,SegmentIndex*64000);
      BlockRead(InputFile,Data^,64000,AccessStatus);
      {$I+}
      if IOResult<>0 then
      begin
        SqueezeFile:=3;
        Exit;
      end;
    end;

    FetchCode:=Data^[(Index-1) mod 64000];
  end;

  procedure AnalyseUsedCode;
  var
    Counter:longint;
    Loop:word;
    Found:boolean;

  begin
    UsedCode:=0;
    FillChar(UsedCodeList,SizeOf(UsedCodeList),0);

    for Counter:=1 to DataSize do
    begin
      Code:=FetchCode(Counter);
      Inc(CodeMap[Code+1]);

      Found:=False;

      for Loop:=1 to UsedCode do
        if UsedCodeList[Loop]=Code then
        begin
          Found:=True;
          Break;
        end;

      if not Found then
      begin
        Inc(UsedCode);
        UsedCodeList[UsedCode]:=Code;
      end;
    end;
  end;

  procedure AnalyseUnusedCode;
  var
    Counter:word;
    Loop:word;
    Found:boolean;

  begin
    UnusedCode:=0;
    FillChar(UnusedCodeList,SizeOf(UnusedCodeList),0);

    for Counter:=0 to 255 do
    begin
      Found:=False;

      for Loop:=1 to UsedCode do
        if UsedCodeList[Loop]=Counter then
        begin
          Found:=True;
          Break;
        end;

      if not Found then
      begin
        Inc(UnusedCode);
        UnusedCodeList[UnusedCode]:=Counter;
      end;
    end;
  end;

  procedure AnalyseFrequentlyUsedCode;
  var
    Loop1,Loop2:word;
    Frequency:longint;
    Index:byte;
    Code:word;

  begin
    for Code:=1 to 256 do
      FrequentlyUsedCodeList[Code]:=Code-1;

    for Loop1:=2 to 256 do
    begin
      Frequency:=CodeMap[Loop1];
      Index:=FrequentlyUsedCodeList[Loop1];

      Loop2:=Loop1-1;

      while (Frequency>CodeMap[Loop2]) and (Loop2>0) do
      begin
        CodeMap[Loop2+1]:=CodeMap[Loop2];
        FrequentlyUsedCodeList[Loop2+1]:=FrequentlyUsedCodeList[Loop2];

        Loop2:=Loop2-1;
      end;

      CodeMap[Loop2+1]:=Frequency;
      FrequentlyUsedCodeList[Loop2+1]:=Index;
    end;
  end;

  function FindReferenceIndex(Code:byte):byte;
  var
    Loop:word;

  begin
    FindReferenceIndex:=0;

    for Loop:=1 to FrequencyTableSize do
      if FrequentlyUsedCodeList[Loop]=Code then
      begin
        FindReferenceIndex:=UnusedCodeList[Loop];
        Break;
      end;
  end;

  function FindCodeIndex(Code:byte):byte;
  var
    Loop:word;

  begin
    FindCodeIndex:=0;

    for Loop:=1 to FrequencyTableSize do
      if UnusedCodeList[Loop]=Code then
      begin
        FindCodeIndex:=FrequentlyUsedCodeList[Loop];
        Break;
      end;
  end;

  procedure StoreCode;
  begin
    Code:=FetchCode(Counter);

    BlockWrite(OutputFile,Code,1);
  end;

  procedure CompactCode;
  begin
    Code:=FindReferenceIndex(FetchCode(Counter-1));

    BlockWrite(OutputFile,Code,1);
    BlockWrite(OutputFile,Frequency,1);

    Frequency:=0;
  end;

begin
  SqueezeFile:=255;

  if MaxAvail<64000 then
  begin
    SqueezeFile:=1;
    Exit;
  end;

  {$I-}
  Assign(InputFile,InputFileName);
  Reset(InputFile,1);
  {$I+}
  if (IOResult<>0) or (FileSize(InputFile)=0) then
  begin
    SqueezeFile:=2;
    Exit;
  end;

  DataSize:=FileSize(InputFile);
  SegmentIndex:=0;

  New(Data);

  {$I-}
  Seek(InputFile,SegmentIndex*64000);
  BlockRead(InputFile,Data^,64000,AccessStatus);
  {$I+}
  if IOResult<>0 then
  begin
    SqueezeFile:=3;
    Exit;
  end;

  AnalyseUsedCode;
  AnalyseUnusedCode;
  AnalyseFrequentlyUsedCode;

  if UnusedCode=0 then
  begin
    SqueezeFile:=4;
    Exit;
  end;

  P1:=InputFileName;
  P2:=OutputFileName;
  FSplit(P1,D1,N1,E1);
  FSplit(P2,D2,N2,E2);

  if (D2='') and (D1<>'') then
  begin
    D2:=D1;
    P2:=D2+N2+E2;
  end;

  {$I-}
  Assign(OutputFile,P2);
  Rewrite(OutputFile,1);
  {$I+}
  if IOResult<>0 then
  begin
    SqueezeFile:=5;
    Exit;
  end;

  if UnusedCode>UsedCode then
    FrequencyTableSize:=UsedCode
  else
    FrequencyTableSize:=UnusedCode;

  for Counter:=1 to FrequencyTableSize do
    FrequencyTable[Counter]:=(UnusedCodeList[Counter] shl 8)+FrequentlyUsedCodeList[Counter];

  BlockWrite(OutputFile,FrequencyTableSize,2);
  BlockWrite(OutputFile,FrequencyTable,FrequencyTableSize*2);

  Counter:=1;
  Frequency:=0;
  CollectMode:=False;

  repeat
    Found:=False;

    for Loop:=1 to FrequencyTableSize do
      if FetchCode(Counter)=FrequentlyUsedCodeList[Loop] then
      begin
        Found:=True;
        Break;
      end;

    if CollectMode then
      if FetchCode(Counter)<>FetchCode(Counter-1) then
      begin
        CompactCode;
        CollectMode:=False;
      end;

    if (Found) or (CollectMode) then
    begin
      if Counter+2<DataSize then
      begin
        if (FetchCode(Counter)=FetchCode(Counter+1)) and (Frequency<252) then
        begin
          if (FetchCode(Counter+1)=FetchCode(Counter+2)) and (Frequency<252) then
          begin
            Inc(Frequency,3);
            Inc(Counter,3);

            CollectMode:=True;
          end
          else
          begin
            Inc(Frequency,2);
            Inc(Counter,2);

            CollectMode:=False;

            CompactCode;
          end;
        end
        else
          CollectMode:=False;
      end
      else
        CollectMode:=False;

      if not CollectMode then
        if Frequency>0 then
        begin
          Inc(Frequency);
          Inc(Counter);

          CompactCode;
        end
        else
        begin
          StoreCode;
          Inc(Counter);
        end;
    end
    else
    begin
      StoreCode;
      Inc(Counter);
    end;
  until (Counter>DataSize) and (Frequency=0);

  GetFTime(InputFile,FileDateTime);
  SetFTime(OutputFile,FileDateTime);

  Close(InputFile);
  Close(OutputFile);

  Dispose(Data);

  SqueezeFile:=0;
end;

function StretchFile(InputFileName,OutputFileName:string):byte;
{
  Status Code
  0 = Successful
  1 = Insufficient Memory
  2 = Unable to open input file
  3 = File access error
  5 = Unable to create output file
  255 = Undefined error
}

  function FetchCode(Index:longint):byte;
  var
    Refresh:boolean;
    SeekIndex:longint;

  begin
    FetchCode:=0;

    if Index-1>DataSize-((FrequencyTableSize*2)+2) then
      Exit;

    Refresh:=False;

    if ((Index-1) div 64000)<>SegmentIndex then
    begin
      SegmentIndex:=(Index-1) div 64000;
      Refresh:=True;
    end;

    if Refresh then
    begin
      SeekIndex:=((FrequencyTableSize*2)+2)+(SegmentIndex*64000);

      {$I-}
      Seek(InputFile,SeekIndex);
      BlockRead(InputFile,Data^,64000,AccessStatus);
      {$I+}
      if IOResult<>0 then
      begin
        StretchFile:=3;
        Exit;
      end;
    end;

    FetchCode:=Data^[(Index-1) mod 64000];
  end;

begin
  StretchFile:=255;

  if MaxAvail<64000 then
  begin
    StretchFile:=1;
    Exit;
  end;

  {$I-}
  Assign(InputFile,InputFileName);
  Reset(InputFile,1);
  {$I+}
  if (IOResult<>0) or (FileSize(InputFile)=0) then
  begin
    StretchFile:=2;
    Exit;
  end;

  DataSize:=FileSize(InputFile);
  SegmentIndex:=0;

  New(Data);

  {$I-}
  BlockRead(InputFile,FrequencyTableSize,2);
  BlockRead(InputFile,FrequencyTable,FrequencyTableSize*2);
  {$I+}
  if IOResult<>0 then
  begin
    StretchFile:=3;
    Exit;
  end;

  {$I-}
  BlockRead(InputFile,Data^,64000,AccessStatus);
  {$I+}
  if IOResult<>0 then
  begin
    StretchFile:=3;
    Exit;
  end;

  P1:=InputFileName;
  P2:=OutputFileName;
  FSplit(P1,D1,N1,E1);
  FSplit(P2,D2,N2,E2);

  if (D2='') and (D1<>'') then
  begin
    D2:=D1;
    P2:=D2+N2+E2;
  end;

  {$I-}
  Assign(OutputFile,P2);
  Rewrite(OutputFile,1);
  {$I+}
  if IOResult<>0 then
  begin
    StretchFile:=5;
    Exit;
  end;

  Counter:=1;

  repeat
    Found:=False;

    for Loop:=1 to FrequencyTableSize do
      if FetchCode(Counter)=Byte(FrequencyTable[Loop] shr 8) then
      begin
        Code:=Byte(FrequencyTable[Loop]);
        Frequency:=FetchCode(Counter+1);
        Inc(Counter,2);

        Found:=True;
        Break;
      end;

    if Found then
    begin
      for Loop:=1 to Frequency do
        BlockWrite(OutputFile,Code,1);
    end
    else
    begin
      Code:=FetchCode(Counter);
      BlockWrite(OutputFile,Code,1);
      Inc(Counter);
    end;
  until Counter>DataSize-((FrequencyTableSize*2)+2);

  GetFTime(InputFile,FileDateTime);
  SetFTime(OutputFile,FileDateTime);

  Close(InputFile);
  Close(OutputFile);

  Dispose(Data);

  StretchFile:=0;
end;

BEGIN
 SqueezeFile(paramstr(1),paramstr(2));
END.