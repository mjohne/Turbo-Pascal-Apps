PROGRAM Planetoid_Stat;

USES Crt,Dos,Graph;

CONST MaxIndex = 1000;


VAR
  IndexR : ARRAY[1..8000] OF Word;
  Name : STRING[31];
  DataFile : Text;
  DataFileName : STRING;
  i,n : Word;
  Dr,Mo : Integer;
  a : Word;
  b : Real;

BEGIN
  ClrScr;
  Dr := Detect;

  InitGraph(Dr,Mo,'');
  OutTextXY(10,10,'Z�hlung der MITTLEREN ANOMALIE aller Planetoiden von 1 - 7136');
  SetColor(Cyan);
  Line(0,401,360,401);
  Line(361,401-50,361,401);
  SetColor(White);
  readKey;

  DataFileName := 'ASTR0001.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0002.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0003.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0004.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0005.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0006.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0007.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0008.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0009.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0010.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0011.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0012.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR00013.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0014.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);
  DataFileName := 'ASTR0015.DAT';
  Assign(DataFile,DataFileName);
  Reset(DataFile);
  FOR i := 1 TO 500 DO BEGIN
    Read(DataFile,a);
    Read(DataFile,Name);
    Read(DataFile,b);Read(DataFile,b);Read(DataFile,b);ReadLn(DataFile,b);
    Inc(IndexR[Round(b)]);
    FOR n := 1 TO 360 DO BEGIN
      Line(n,400,n,400-IndexR[n]);
    END;
  END;
  Close(DataFile);

  ReadKey;
  CloseGraph;
END.