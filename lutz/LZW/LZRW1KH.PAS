

{    ###################################################################   }
{    ##                                                               ##   }
{    ##      ##    ##### #####  ##   ##  ##      ## ##  ## ##  ##     ##   }
{    ##      ##      ### ##  ## ## # ## ###     ##  ## ##  ##  ##     ##   }
{    ##      ##     ###  #####  #######  ##    ##   ####   ######     ##   }
{    ##      ##    ###   ##  ## ### ###  ##   ##    ## ##  ##  ##     ##   }
{    ##      ##### ##### ##  ## ##   ## #### ##     ##  ## ##  ##     ##   }
{    ##                                                               ##   }
{    ##   EXTREMELY FAST AND EASY TO UNDERSTAND COMPRESSION ALGORITM  ##   }
{    ##                                                               ##   }
{    ###################################################################   }
{    ##                                                               ##   }
{    ##   This unit implements the updated LZRW1/KH algoritm which    ##   }
{    ##   also implements  some RLE coding  which is usefull  when    ##   }
{    ##   compress files  containing  a lot  of consecutive  bytes    ##   }
{    ##   having the same value.   The algoritm is not as good  as    ##   }
{    ##   LZH, but can compete with Lempel-Ziff.   It's the fasted    ##   }
{    ##   one I've encountered upto now.                              ##   }
{    ##                                                               ##   }
{    ##                                                               ##   }
{    ##                                                               ##   }
{    ##                                                Kurt HAENEN    ##   }
{    ##                                                               ##   }
{    ###################################################################   }

UNIT LZRW1KH;

INTERFACE

CONST     BufferMaxSize  = 32768;
          BufferMax      = BufferMaxSize-1;
          FLAG_Copied    = $80;
          FLAG_Compress  = $40;

TYPE BufferIndex    = 0..BufferMax;
     BufferSize     = 0..BufferMaxSize;
     BufferArray    = ARRAY [BufferIndex] OF BYTE;
     BufferPtr      = ^BufferArray;

FUNCTION  Compression    (    Source,Dest    : BufferPtr;
                              SourceSize     : BufferSize   )    : BufferSize;

FUNCTION  Decompression  (    Source,Dest    : BufferPtr;
                              SourceSize     : BufferSize   )    : BufferSize;

IMPLEMENTATION

TYPE HashTable      = ARRAY [0..4095] OF INTEGER;

FUNCTION  GetMatch       (    Source         : BufferPtr;
                              X              : BufferIndex;
                              SourceSize     : BufferSize;
                          VAR Hash           : HashTable;
                          VAR Size           : WORD;
                          VAR Pos            : BufferIndex  )    : BOOLEAN;
VAR  HashValue      : WORD;
BEGIN
     HashValue := (40543*((((Source^[X] SHL 4) XOR Source^[X+1]) SHL 4) XOR
                 Source^[X+2]) SHR 4) AND $0FFF;
     GetMatch := FALSE;
     IF (Hash[HashValue] <> -1) AND (X-Hash[HashValue] < 4096) THEN
          BEGIN
               Pos := Hash[HashValue];
               Size := 0;
               WHILE ((Size < 18) AND (Source^[X+Size] = Source^[Pos+Size])
                    AND (X+Size < SourceSize)) DO
                    INC(Size);
               GetMatch := (Size >= 3)
          END;
     Hash[HashValue] := X
END;


FUNCTION  Compression    (    Source,Dest    : BufferPtr;
                              SourceSize     : BufferSize   )    : BufferSize;
VAR  Hash                     : HashTable;
     Key,Bit,Command,Size     : WORD;
     X,Y,Z,Pos                : BufferIndex;
BEGIN
     FOR Key := 0 TO 4095 DO Hash[Key] := -1;
     Dest^[0] := FLAG_Compress;
     X := 0;
     Y := 3;
     Z := 1;
     Bit := 0;
     Command := 0;
     WHILE (X < SourceSize) AND (Y <= SourceSize) DO
          BEGIN
               IF (Bit > 15) THEN
                    BEGIN
                         Dest^[Z] := HI(Command);
                         Dest^[Z+1] := LO(Command);
                         Z := Y;
                         Bit := 0;
                         INC(Y,2)
                    END;
               Size := 1;
               WHILE ((Source^[X] = Source^[X+Size]) AND (Size < $FFF)
                    AND (X+Size < SourceSize)) DO
                         INC(Size);
               IF (Size >= 16)
                    THEN BEGIN
                              Dest^[Y] := 0;
                              Dest^[Y+1] := HI(Size-16);
                              Dest^[Y+2] := LO(Size-16);
                              Dest^[Y+3] := Source^[X];
                              INC(Y,4);
                              INC(X,Size);
                              Command := (Command SHL 1) + 1
                         END
                    ELSE IF (GetMatch(Source,X,SourceSize,Hash,Size,Pos))
                              THEN BEGIN
                                        Key := ((X-Pos) SHL 4) + (Size-3);
                                        Dest^[Y] := HI(Key);
                                        Dest^[Y+1] := LO(Key);
                                        INC(Y,2);
                                        INC(X,Size);
                                        Command := (Command SHL 1) + 1
                                   END
                              ELSE BEGIN
                                        Dest^[Y] := Source^[X];
                                        INC(Y);
                                        INC(X);
                                        Command := Command SHL 1
                                   END;
               INC(Bit);
          END;
     Command := Command SHL (16-Bit);
     Dest^[Z] := HI(Command);
     Dest^[Z+1] := LO(Command);
     IF (Y > SourceSize) THEN
          BEGIN
               MOVE(Source^[0],Dest^[1],SourceSize);
               Dest^[0] := FLAG_Copied;
               Y := SUCC(SourceSize)
          END;
     Compression := Y
END;

FUNCTION  Decompression  (    Source,Dest    : BufferPtr;
                              SourceSize     : BufferSize   )    : BufferSize;
VAR  X,Y,Pos                  : BufferIndex;
     Command,Size,K           : WORD;
     Bit                      : BYTE;
BEGIN
     IF (Source^[0] = FLAG_Copied)
          THEN FOR Y := 1 TO PRED(SourceSize) DO
                    Dest^[PRED(Y)] := Source^[Y]
          ELSE BEGIN
                    Y := 0;
                    X := 3;
                    Command := (Source^[1] SHL 8)+Source^[2];
                    Bit := 16;
                    WHILE (X < SourceSize) DO
                         BEGIN
                              IF (Bit = 0) THEN
                                   BEGIN
                                        Command := (Source^[X] SHL 8)
                                                      +Source^[X+1];
                                        Bit := 16;
                                        INC(X,2)
                                   END;
                              IF ((Command AND $8000) = 0)
                                   THEN BEGIN
                                             Dest^[Y] := Source^[X];
                                             INC(X);
                                             INC(Y)
                                        END
                                   ELSE BEGIN
                                             Pos := ((Source^[X] SHL 4)
                                                    +(Source^[X+1] SHR 4));
                                             IF (Pos = 0)
                                                  THEN BEGIN
{----------------------------------------------------------------}
     Size := (Source^[X+1] SHL 8) + Source^[X+2] + 15;
     FOR K := 0 TO Size DO
          Dest^[Y+K] := Source^[X+3];
     INC(X,4);
     INC(Y,Size+1)
{----------------------------------------------------------------}
                                                       END
                                                  ELSE BEGIN
{----------------------------------------------------------------}
     Size := (Source^[X+1] AND $0F)+2;
     FOR K := 0 TO Size DO
          Dest^[Y+K] := Dest^[Y-Pos+K];
     INC(X,2);
     INC(Y,Size+1)
{----------------------------------------------------------------}
                                                       END;
                                        END;
                              Command := Command SHL 1;
                              DEC(Bit)
                         END
               END;
     Decompression := Y
END;

END.

-------------------------------------------------------------------
End of File # 1



File #2 : A small demonstration
-------------------------------


{    ###################################################################   }
{    ##                                                               ##   }
{    ##      ##    ##### #####  ##   ##  ##      ## ##  ## ##  ##     ##   }
{    ##      ##      ### ##  ## ## # ## ###     ##  ## ##  ##  ##     ##   }
{    ##      ##     ###  #####  #######  ##    ##   ####   ######     ##   }
{    ##      ##    ###   ##  ## ### ###  ##   ##    ## ##  ##  ##     ##   }
{    ##      ##### ##### ##  ## ##   ## #### ##     ##  ## ##  ##     ##   }
{    ##                                                               ##   }
{    ##   EXTREMELY FAST AND EASY TO UNDERSTAND COMPRESSION ALGORITM  ##   }
{    ##                                                               ##   }
{    ###################################################################   }
{    ##                                                               ##   }
{    ##   In an earlier posting I've already presented a 680x0        ##   }
{    ##   assembler routine to implement optimized LZRW1 compression. ##   }
{    ##   I've chosen then name LZRW1/KH for this optimized           ##   }
{    ##   algoritm, to distinguish it from the original one.  The     ##   }
{    ##   changes can be found in the maximum length for a match,     ##   }
{    ##   which is 16 in the original algoritm, but 18 in the         ##   }
{    ##   optimized one.  This is not a big change, but nevertheless  ##   }
{    ##   it can increase the compression by 1/8.  Another thing      ##   }
{    ##   I've tried to do is to make this program easy to            ##   }
{    ##   understand.  Although I have some knowledge of C, I always  ##   }
{    ##   find it difficult to understand someone else his programs.  ##   }
{    ##   Especially if they depend on the SHORT CIRCUIT BOOLEAN      ##   }
{    ##   evaluation of C : Test || Test || Test will only be         ##   }
{    ##   executed fully if Test was TRUE the first three times ...   ##   }
{    ##   Took me awhile to figure it out, although it seems quite    ##   }
{    ##   natural now ... Enough of this, let's see some code ...     ##   }
{    ##                                                               ##   }
{    ##   Sorry, no list of people to thank this time ... It hasn't   ##   }
{    ##   changed since my last posting.                              ##   }
{    ##                                                Kurt Haenen    ##   }
{    ##                                                               ##   }
{    ###################################################################   }

PROGRAM   CompressionDemo(input,output);

USES LZRW1KH;

CONST     CompIdentifier : LONGINT      = (((((((ORD('L') SHL 8)+ORD('Z'))
                                   SHL 8)+ORD('R')) SHL 8)+ORD('W')) SHL 8);

VAR  SRCFP,DSTFP         : FILE;
     SRCBuf,DSTBuf       : ARRAY [0..16390] OF BYTE;
     SRCSize,DSTSize     : WORD;
     Tmp                 : WORD;
     Identifier          : LONGINT;
     InSize,OutSize      : LONGINT;

BEGIN
     IF ((PARAMCOUNT <> 2) AND ((PARAMCOUNT <> 3) OR (PARAMSTR(1) <> '-D')))
             THEN
          BEGIN
               WRITELN;
               WRITELN('USAGE : COMPRESS [-D] <Source File> <Dest File>');
               WRITELN('        (The -D option is case sensitive !)');
               WRITELN;
               HALT
          END;
     IF (PARAMCOUNT = 2)
          THEN BEGIN
                    WRITELN('TRYING TO COMPRESS ',PARAMSTR(1),' TO ',
                                    PARAMSTR(2),'.');
                    ASSIGN(SRCFP,PARAMSTR(1));
                    ASSIGN(DSTFP,PARAMSTR(2));
                    RESET(SRCFP,1);
                    IF (IOResult <> 0) THEN
                         BEGIN
                              WRITELN;
                              WRITELN('FILE ',PARAMSTR(1),' NOT FOUND !');
                              WRITELN;
                              HALT
                         END;
                    REWRITE(DSTFP,1);
                    IF (IOResult <> 0) THEN
                         BEGIN
                              CLOSE(SRCFP);
                              WRITELN;
                              WRITELN('FILE ',PARAMSTR(2),' COULD NOT '+
                                                   'BE OPENED !');
                              WRITELN;
                              HALT
                         END;
                    BLOCKWRITE(DSTFP,CompIdentifier,SIZEOF(LONGINT),Tmp);
                    IF (Tmp <> SIZEOF(LONGINT)) THEN
                         BEGIN
                              CLOSE(SRCFP);
                              CLOSE(DSTFP);
                              ERASE(DSTFP);
                              WRITELN;
                              WRITELN('ERROR WRITING TO ',PARAMSTR(2),' !');
                              WRITELN;
                              HALT
                         END;
                    SRCSize := 16384;
                    InSize := 0;
                    OutSize := SIZEOF(LONGINT);
                    WHILE (SRCSize = 16384) DO
                         BEGIN
                              BLOCKREAD(SRCFP,SRCBuf[0],16384,SRCSize);
                              INC(InSize,SRCSize);
                              WRITE('READ : ',InSize,'  WRITTEN : ',
                                            OutSize,#13);
                              DSTSize := Compression(ADDR(SRCBuf[0]),
                                              ADDR(DSTBuf[0]),SRCSize);
                              BLOCKWRITE(DSTFP,DSTSize,SIZEOF(WORD),Tmp);
                              INC(OutSize,Tmp);
                              WRITE('READ : ',InSize,'  WRITTEN : ',
                                             OutSize,#13);
                              IF (Tmp <> SIZEOF(WORD)) THEN
                                   BEGIN
                                        CLOSE(SRCFP);
                                        CLOSE(DSTFP);
                                        ERASE(DSTFP);
                                        WRITELN;
                                        WRITELN('ERROR WRITING TO ',
                                               PARAMSTR(2),' !');
                                        WRITELN;
                                        HALT
                                   END;
                              BLOCKWRITE(DSTFP,DSTBuf[0],DSTSize,Tmp);
                              INC(OutSize,Tmp);
                              WRITE('READ : ',InSize,'  WRITTEN : ',
                                   OutSize,#13);
                              IF (Tmp <> DSTSize) THEN
                                   BEGIN
                                        CLOSE(SRCFP);
                                        CLOSE(DSTFP);
                                        ERASE(DSTFP);
                                        WRITELN;
                                        WRITELN('ERROR WRITING TO ',
                                                   PARAMSTR(2),' !');
                                        WRITELN;
                                        HALT
                                   END;
                         END;
                    WRITELN;
                    WRITELN('FILE SUCCESFULLY COMPRESSED !');
                    CLOSE(SRCFP);
                    CLOSE(DSTFP)
               END
          ELSE BEGIN
                    WRITELN('TRYING TO DECOMPRESS ',PARAMSTR(2),' TO ',
                                       PARAMSTR(3),'.');
                    ASSIGN(SRCFP,PARAMSTR(2));
                    ASSIGN(DSTFP,PARAMSTR(3));
                    RESET(SRCFP,1);
                    IF (IOResult <> 0) THEN
                         BEGIN
                              WRITELN;
                              WRITELN('FILE ',PARAMSTR(2),' NOT FOUND !');
                              WRITELN;
                              HALT
                         END;
                    REWRITE(DSTFP,1);
                    IF (IOResult <> 0) THEN
                         BEGIN
                              CLOSE(SRCFP);
                              WRITELN;
                              WRITELN('FILE ',PARAMSTR(3),' COULD NOT '+
                                                      'BE OPENED !');
                              WRITELN;
                              HALT
                         END;
                    BLOCKREAD(SRCFP,Identifier,SIZEOF(LONGINT),Tmp);
                    IF (Tmp <> SIZEOF(LONGINT)) THEN
                         BEGIN
                              CLOSE(SRCFP);
                              CLOSE(DSTFP);
                              ERASE(DSTFP);
                              WRITELN;
                              WRITELN('ERROR READING FROM ',PARAMSTR(2),' !');
                              WRITELN;
                              HALT
                         END;
                    IF (Identifier <> CompIdentifier) THEN
                         BEGIN
                              CLOSE(SRCFP);
                              CLOSE(DSTFP);
                              ERASE(DSTFP);
                              WRITELN;
                              WRITELN('FILE ',PARAMSTR(2),
                                            ' IS NOT A COMPRESSED FILE !');
                              WRITELN;
                              HALT
                         END;
                    DSTSize := 16384;
                    InSize := SIZEOF(LONGINT);
                    OutSize := 0;
                    WHILE (DSTSize = 16384) DO
                         BEGIN
                              BLOCKREAD(SRCFP,SRCSize,SIZEOF(WORD),Tmp);
                              IF (Tmp <> SIZEOF(WORD)) THEN
                                   BEGIN
                                        CLOSE(SRCFP);
                                        CLOSE(DSTFP);
                                        ERASE(DSTFP);
                                        WRITELN;
                                        WRITELN('ERROR READING FROM ',
                                              PARAMSTR(2),' !');
                                        WRITELN;
                                        HALT
                                   END;
                              BLOCKREAD(SRCFP,SRCBuf[0],SRCSize,Tmp);
                              INC(InSize,Tmp+SIZEOF(WORD));
                              WRITE('READ : ',InSize,'  WRITTEN : ',
                                        OutSize,#13);
                              IF (Tmp <> SRCSize) THEN
                                   BEGIN
                                        CLOSE(SRCFP);
                                        CLOSE(DSTFP);
                                        ERASE(DSTFP);
                                        WRITELN;
                                        WRITELN('ERROR READING FROM ',
                                                  PARAMSTR(2),' !');
                                        WRITELN;
                                        HALT
                                   END;
                              DSTSize := Decompression(ADDR(SRCBuf[0]),
                                               ADDR(DstBuf[0]),SRCSize);
                              BLOCKWRITE(DSTFP,DSTBuf[0],DSTSize,Tmp);
                              INC(OutSize,Tmp);
                              WRITE('READ : ',InSize,'  WRITTEN : ',
                                            OutSize,#13);
                              IF (Tmp <> DSTSize) THEN
                                   BEGIN
                                        CLOSE(SRCFP);
                                        CLOSE(DSTFP);
                                        ERASE(DSTFP);
                                        WRITELN;
                                        WRITELN('ERROR WRITING TO ',
                                                   PARAMSTR(3),' !');
                                        WRITELN;
                                        HALT
                                   END;
                         END;
                    WRITELN;
                    WRITELN('FILE SUCCESFULLY DECOMPRESSED !');
                    CLOSE(SRCFP);
                    CLOSE(DSTFP)
               END
END.

-------------------------------------------------------------------
End of file # 2


Ok, that was the listing ...   I hope everything is ok.  Some of
you may get some word-wraps etc. because of the long lines I used
in the source.  I tried to make them as readable as possible, but
sometime I had to include some backwards indented blocks, which
are separated from the rest of the program by {----}.  I hope this
still remains readable ... Hope to hear from you all soon ...

                                                    Kurt Haenen


