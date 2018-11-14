PROGRAM Secret_Splitting;

USES Crt,Dos;

VAR
  Choice,Data1,Data2,Data3 : Char;
  SoM                      : FILE OF Byte;
  SizeOfMessage,i          : LongInt;
  Message,Key,Secret_Split : STRING;
  M,K,S                    : Text;

BEGIN
  ClrScr;
  Randomize;
  WriteLn('Secret Splitting');
  WriteLn('================');
  WriteLn;
  WriteLn('(1)-Construct or (2)-Reconstruct');
  REPEAT
    Choice := Readkey;
  UNTIL Choice IN ['1','2'];
  IF Choice = '1' THEN BEGIN
    Write('message file: ');
    ReadLn(Message);
    Assign(SoM,Message);
    Reset(SoM);
    SizeOfMessage := FileSize(SoM);
    Close(SoM);
    Assign(M,Message);
    Reset(M);
    Write('name of file to save the random key: ');
    ReadLn(Key);
    Assign(K,Key);
    Rewrite(K);
    WriteLn('random key will creat...');
    FOR i := 1 TO SizeOfMessage DO Write(K,Chr(Random(255)));
    Close(K);
    Reset(K);
    Write('name of file for secret split: ');
    ReadLn(Secret_Split);
    Assign(S,Secret_Split);
    Rewrite(S);
    FOR i := 1 TO SizeOfMessage DO BEGIN
      Read(M,Data1);
      Read(K,Data2);
      Data3 := Chr(Ord(Data1) XOR Ord(Data2));
      Write(S,Data3);
      Write(^m,i,' of ',SizeOfMessage);
    END;
    WriteLn;
    Close(M);
    Close(K);
    Close(S);
    Write('message file will delete...');
    Rewrite(M);
    Close(M);
    Erase(M);
  END ELSE BEGIN
    Write('file by secret split: ');
    ReadLn(Secret_Split);
    Assign(SoM,Secret_Split);
    Reset(SoM);
    SizeOfMessage := FileSize(SoM);
    Close(SoM);
    Assign(S,Secret_Split);
    Reset(S);
    Write('file by random key: ');
    ReadLn(Key);
    Assign(K,Key);
    Reset(K);
    Write('name of message file to reconstruct: ');
    ReadLn(Message);
    Assign(M,Message);
    Rewrite(M);
    FOR i := 1 TO SizeOfMessage DO BEGIN
      Read(S,Data3);
      Read(K,Data2);
      Data1 := Chr(Ord(Data2) XOR Ord(Data3));
      Write(M,Data1);
      Write(^m,i,' of ',SizeOfMessage);
    END;
    WriteLn;
    Close(M);
    Close(K);
    Close(S);
    WriteLn('key file will delete...');
    Rewrite(K);
    Close(K);
    Erase(K);
    WriteLn('file by secret split will delete...');
    Rewrite(S);
    Close(S);
    Erase(S);
  END;
END.