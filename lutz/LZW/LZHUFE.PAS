{$M 12000,0,0}  (* see notes to "decode" *)

PROGRAM lzhufe(infile, outfile, output);
(* Based on decode section of lzhuf.c               *)
(* Written by Haruyasu Yoshizaki 1988/11/20         *)
(* Some minor changes 1989/4/6                      *)
(* Comments translated by Haruhiko Okumura 1989/4/7 *)

(* Converted to Pascal by C.B. Falconer, 1989/4/25  *)
(* I have attempted to use only ISO constructs, but *)
(* some Turboisms have remained, especially in the  *)
(* file access area, and the use of inc/dec, hex    *)
(* constants, longints, bytes and words.  I have    *)
(* also attempted to use the maximum range checking *)

  (********** LZSS compression **********)

  CONST            (* These only take effect if 'dbg' is defined *)
    debuga         = false;     (* show recorded size *)
    debugb         = true;      (* display output chars *)

    iobuffsize     = 4096;      (* for Turbo block i/o only *)
    eofmark        = $1a;       (* textfile eof mark *)

    (* These constants are used by the file-handling *)
    (* procedures when opening and closing disk      *)
    (* files. The mode fields of Turbo Pascal's file *)
    (* variables will contain one of these values    *)
    fmclosed       = $d7b0;
    fminput        = $d7b1;     (* reference data *)
    fmoutput       = $d7b2;
    fminout        = $d7b3;

  TYPE
    iobuffer       = ARRAY[1..iobuffsize] OF byte;
    iobufptr       = 0..iobuffsize;  (* 0 = empty *)

    (* reference data, actual contents of FILE type *)
    filerec        = RECORD (* typed and untyped file record *)
      handle         : word;
      mode           : word;
      recsize        : word;
      private        : ARRAY[1..26] OF byte;
      userdata       : ARRAY[1..16] OF byte;
      name           : ARRAY[0..79] OF char;
      END; (* filerec *)

    fcb            = RECORD
      fid            : FILE;      (* Turbo untyped block i/o *)
      fwrtaccess     : boolean;
      feof           : boolean;
      bufflast,                   (* posn of last in buffer *)
      buffndx        : iobufptr;  (* last read from buffer *)
      buff           : iobuffer;  (*   0 = empty *)
      END; (* fcb *)

    (* Non-standard method of passing procedures *)
    putbproc       = PROCEDURE(b : byte);
    getbfunc       = FUNCTION(VAR b : byte) : boolean; 

  VAR
    infile,
    outfile        : fcb;
    endofinput     : boolean;

  (* 1---------------1 *)

  (* In this group we attempt to follow standard Pascal semantics *)
  (* i.e. output files always have feof true, and it is an error  *)
  (* to write to a file without this condition.                   *)
  (* The system is incomplete, intended for this program only.    *)

  FUNCTION freset(VAR f : fcb; fn : string) : boolean;
  (* equivalent to assign/reset pair *)

    BEGIN (* freset *)
    WITH f DO BEGIN
      buffndx := 0; bufflast := 0; (* mark empty *)
      fwrtaccess := false;
      assign(fid, fn);
{$i-} reset(fid, 1); {$i+}
      feof := ioresult <> 0;
      freset := NOT feof; END;
    END; (* freset *)

  (* 1---------------1 *)
{$F+}                      (* passed procs must be FAR *)
  FUNCTION readbyte(VAR c : byte) : boolean;
  (* assumes using infile. Returns false at eof *)
 
    BEGIN (* readbyte *)
    WITH infile DO BEGIN
      IF (buffndx >= bufflast) AND NOT feof THEN BEGIN (* reload *)
{$i-}   blockread(fid, buff, iobuffsize, bufflast); {$i+}
        buffndx := 0;
        feof := (ioresult <> 0) OR (bufflast = 0); END;
      IF feof THEN c := eofmark
      ELSE BEGIN
        buffndx := succ(buffndx); c := buff[buffndx]; END;
      readbyte := NOT feof; END;
    END; (* readbyte *)
{$F-}
  (* 1---------------1 *)

  FUNCTION frewrite(VAR f : fcb; fn : string) : boolean;
  (* equivalent to assign/rewrite pair *)

    BEGIN (* frewrite *)
    WITH f DO BEGIN
      buffndx := 0; bufflast := 0; (* mark empty *)
      fwrtaccess := true;
      assign(fid, fn);
{$i-} rewrite(fid, 1); {$i+}
      feof := ioresult = 0;
      frewrite := feof; END;
    END; (* frewrite *)

  (* 1---------------1 *)

  PROCEDURE fflush(VAR f : fcb);
  (* empty output buffers to disk. Not checking status *)

    BEGIN (* fflush *)
    WITH f DO BEGIN
      IF (bufflast > 0) AND feof AND fwrtaccess THEN BEGIN
{$i-}   blockwrite(fid, buff, bufflast, buffndx); {$i+}
        IF (ioresult <> 0) OR (buffndx <> bufflast) THEN
          feof := false;         (* no longer writeable *) END;
      buffndx := 0; bufflast := 0;  (* mark empty *)  END;
    END; (* fflush *)

  (* 1---------------1 *)
{$F+}                            (* passed procs must be FAR *)
  PROCEDURE putbyte(c : byte);
  (* assumes using outfile *)

    BEGIN (* putbyte *)
    WITH outfile DO
      IF fwrtaccess AND feof THEN BEGIN
        inc(bufflast); buff[bufflast] := c;
        IF bufflast = iobuffsize THEN fflush(outfile); END;
    (* buffer cannot be full on exit *)
    END; (* putbyte *)
{$F-}
  (* 1---------------1 *)

  PROCEDURE fclose(VAR f : fcb);

    VAR
      fr   : filerec ABSOLUTE f; (* depends on turbo alignments *)

    BEGIN (* fclose *)
    WITH f DO BEGIN
      IF ((fr.mode = fmoutput) OR (fr.mode = fminout)) AND feof THEN
        fflush(f);
      IF fr.mode <> fmclosed THEN close(fid); END;
    END; (* fclose *)

  (* 1---------------1 *)

  PROCEDURE error(message : string);

    BEGIN
    writeln; writeln(message); halt(1);
    END;

  (* 1---------------1 *)

  PROCEDURE decode(readbyte : getbfunc;    (* get data *)
                   putbyte  : putbproc;    (* put data *)
                   monitor  : boolean);    (* show activity *)
  (* This uses about 9k of stack space for local variables.   *)
  (* They might be better assigned on the heap.  However that *)
  (* reduces the clarity, and I wanted to isolate the decoder *)
  (* Unfortunately Turbos memory scheme does not allow the    *)
  (* stack to expand automatically.  A 16k stack suffices.    *)

    CONST
      n              = 4096;      (* buffer size. Power of 2 *)
      f              = 60;        (* lookahead buffer size *)
      encodemin      = 3;         (* min encode string length *)
      max_freq       = $8000;     (* updates tree when the root *)
                                  (* frequency reaches this value.*)

      (* derived constants. No expression for ISO compatibility *)
      threshold      = 2;         (* encodemin - 1 *)
      bufmax         = 4155;      (* n+f-1 *)
      codemax        = 313;       (* 256-encodemin+f *)
      n_char         = 314;       (* codemax + 1; kinds of chars *)

      (* Huffman coding *)
      tblsize        = 627;       (* 2*n_char - 1 *) (* was T *)
                                  (* Root at tblsize, others nodes *)
      huffroot       = 626;       (* tblsize - 1 *)  (* was R *)
      tblmax         = 628;       (* tblsize + 1 *)
      parentmax      = 941;       (* tblsize + n_char *)

    TYPE
      bufindex       = 0..bufmax;
      charindex      = 0..codemax;

    VAR
      i, j, k, r, c  : integer;
      count          : longint;
      textsize       : longint;
      printcount     : longint;
      getbuf         : word;
      getlen         : byte;

      (* Huffman coding *)

      (* table to encode/decode the upper 6 bits of position *)
      huffcode       : ARRAY[0..255] OF RECORD
        code, len      : byte;
        END; (* huffcode *)

      freq           : ARRAY[0..tblmax] OF word;  (* freq table *)

      (* pointers to parent nodes, except for    *)
      (* the elements[T..T + N_CHAR - 1] which   *)
      (* are used to get the positions of leaves *)
      (* corresponding to the codes.             *)
      parent         : ARRAY[0..parentmax] OF word;

      (* pointers to child nodes (son[], son[] + 1) *)
      son            : ARRAY[0..tblsize] OF integer;

      (* LZSS table *)
      histbuff       : ARRAY[bufindex] OF byte;

    (* 2---------------2 *)

    PROCEDURE starthuff;
    (* initialization of tree *)

      VAR
        i              : integer;
        j              : integer;

      (* 3---------------3 *)

      PROCEDURE ihuff;
      (* Form decoding tables huffcode.len and huffcode.code *)
      (* This replaces the original initialized data area,   *)
      (* and is compatible with standard Pascal.             *)

        VAR
          i, nxtcode   : integer;

        (* 4---------------4 *)

        PROCEDURE enter(ix, lgh : integer);

          BEGIN (* enter *)
          WITH huffcode[ix] DO BEGIN
            len := lgh; code := nxtcode; END;
          IF succ(ix) MOD (1 shl (8-lgh)) = 0 THEN
            nxtcode := succ(nxtcode);
          END; (* enter *)

        (* 4---------------4 *)

        BEGIN (* ihuff *)
        nxtcode := 0;
        FOR i :=   0 TO  31 DO enter(i, 3);
        FOR i :=  32 TO  79 DO enter(i, 4);
        FOR i :=  80 TO 143 DO enter(i, 5);
        FOR i := 144 TO 191 DO enter(i, 6);
        FOR i := 192 TO 239 DO enter(i, 7);
        FOR i := 240 TO 255 DO enter(i, 8);
        END; (* ihuff *)

      (* 3---------------3 *)

      BEGIN (* starthuff *)
      ihuff;
      FOR i := 0 TO pred(n_char) DO BEGIN
        freq[i] := 1;
        son[i] := i + tblsize; parent[i + tblsize] := i; END;
      i := 0; j := n_char;
      WHILE (j <= huffroot) DO BEGIN
        freq[j] := freq[i] + freq[succ(i)];
        son[j] := i; parent[i] := j; parent[succ(i)] := j;
        i := i + 2; j := succ(j); END;
      freq[tblsize] := $ffff; parent[huffroot] := 0;
      END; (* starthuff *)

    (* 2---------------2 *)

    PROCEDURE nextbyte;

      VAR
        c    : byte;

      BEGIN (* nextbyte *)
      IF endofinput THEN BEGIN
        fclose(outfile);
        error('Read past eof'); END;
      WHILE (getlen <= 8) DO BEGIN
        IF NOT readbyte(c) THEN BEGIN  (* delay eof for buffer *)
          endofinput := true; c := 0; END;
        getbuf := getbuf OR (c shl (8 - getlen));
        getlen := getlen + 8; END;
      END; (* nextbyte *)

    (* 2---------------2 *)

    FUNCTION getbit : boolean;      (* get one bit *)

      BEGIN (* getbit *)
      IF getlen <= 8 THEN nextbyte;
      getbit := (getbuf AND $8000) <> 0;
      getbuf := getbuf shl 1; getlen := pred(getlen);
      END; (* getbit *)

    (* 2---------------2 *)

    FUNCTION getbyte : integer;     (* get one byte *)

      BEGIN (* getbyte *)
      IF getlen <= 8 THEN nextbyte;
      getbyte := getbuf shr 8;
      getbuf := getbuf shl 8; getlen := getlen - 8;
      END; (* getbyte *)

    (* 2---------------2 *)

    FUNCTION decodechar : integer;

      VAR
        c              : word;

      (* 3---------------3 *)

      PROCEDURE update (c : integer);
      (* advance frequency of code c, and update tree *)

        VAR
          i, j, k, l     : integer;

        (* 4---------------4 *)

        PROCEDURE reconst;
        (* reconstruction of tree *)

          VAR
            i, j, k        : integer;
            f, l           : word;
      
          BEGIN (* reconst *)
          (* collect leaf nodes in the first half of the   *)
          (* table and replace the freq by (freq + 1) / 2. *)
          j := 0;
          FOR i := 0 TO huffroot DO BEGIN
            IF (son[i] >= tblsize) THEN BEGIN
              freq[j] := succ(freq[i]) shr 1 (* DIV 2 *);
              son[j] := son[i]; j := succ(j); END;
            END;

          (* begin constructing tree by connecting sons *)
          i := 0;
          FOR j := n_char TO huffroot DO BEGIN
            k := succ(i);
            f := freq[i] + freq[k]; freq[j] := f;
            k := pred(j);
            WHILE (f < freq[k]) DO k := pred(k);
            k:= succ(k); l := (j - k) * 2;
            move(freq[k], freq[k+1], l); freq[k] := f;
            move(son[k], son[k+1], l); son[k] := i;
            i := i + 2; END;
      
          (* connect parent *)
          FOR i := 0 TO huffroot DO BEGIN
            k := son[i]; parent[k] := i;
            IF k < tblsize THEN parent[succ(k)] := i; END;
          END; (* reconst *)

        (* 4---------------4 *)

        BEGIN (* update *)
        IF (freq[tblmax] = max_freq) THEN reconst;
        c := parent[c + tblsize];
        REPEAT
          k := succ(freq[c]); freq[c] := k;
          (* if the order is disturbed, exchange nodes *)
          l := succ(c);
          IF (k > freq[l]) THEN BEGIN
            REPEAT
              inc(l);
            UNTIL k <= freq[l];
            dec(l);

            freq[c] := freq[l]; freq[l] := k;

            i := son[c]; parent[i] := l;
            IF (i < tblsize) THEN parent[succ(i)] := l;
            j := son[l]; son[l] := i;

            parent[j] := c;
            IF (j < tblsize) THEN parent[succ(j)] := c;
            son[c] := j;

            c := l; END;
          c := parent[c];
        UNTIL c = 0;                 (* repeat up to root *)
        END; (* update *)

      (* 3---------------3 *)

      BEGIN (* decodechar *)
      c := son[huffroot];
      (* travel from root to leaf, choosing the smaller *)
      (* child node (son[]) if the read bit is 0, the   *)
      (* bigger (son[] +1; if the read bit is 1         *)
      WHILE (c < tblsize) DO c := son[c + ord(getbit)];
      c := c - tblsize;
      update(c); decodechar := c;
      END; (* decodechar *)

    (* 2---------------2 *)

    FUNCTION decodeposition : integer;

      VAR
        i, j, c        : word;

      BEGIN (* decodeposition *)
      (* recover upper 6 bits from table *)
      i := getbyte;
      WITH huffcode[i] DO BEGIN
        c := code shl 6; j := len; END;
      (* read lower 6 bits verbatim *) 
      (* comment/code dont match *)
      dec(j, 2);
      WHILE j <> 0 DO BEGIN
        dec(j); i := i + i + ord(getbit); END;
      decodeposition := c OR (i AND $3f);
      END; (* decodeposition *)

    (* 2---------------2 *)

    FUNCTION readlong : longint;
    (* Read 4 bytes, convert into LSByte 1st 32 bit integer *)

      VAR
        i         : integer;
        buff      : RECORD
          CASE boolean OF
false :   ( long    : longint);
true  :   (  bytes  : ARRAY[0..3] OF byte);
          END; (* buff record *)

      BEGIN (* readlong *)
      FOR i := 0 TO 3 DO 
        IF NOT readbyte(buff.bytes[i]) THEN buff.long := 0;
      readlong := buff.long;
      END; (* readlong *)

    (* 2---------------2 *)

    BEGIN (* decode *)
    textsize := 0; printcount := 0; count := 0;
    getbuf := 0; getlen := 0;
    textsize := readlong;              (* header is size of text *)
    IF textsize > 0 THEN BEGIN
{$IFDEF dbg}
      IF debuga THEN writeln('Size=', textsize);
{$ENDIF}
      starthuff;
      FOR i := 0 TO n - f - 1 DO (* prefill with common char *)
        histbuff[i] := ord(' ');
      r := n - f;

      WHILE count < textsize DO BEGIN
        c := decodechar;
        IF (c < 256) THEN BEGIN        (* a verbatim character *)
{$IFDEF dbg}
          IF debugb THEN write(chr(c));
{$ENDIF}
          putbyte(c);
          histbuff[r] := c;            (* record in history buff *)
          r := succ(r) AND pred(n);    (* advance MODULO n *)
          inc(count); END
        ELSE BEGIN                     (* posn/lgh in buffer *)
          i := pred(r - decodeposition) AND pred(n);
          j := c - 255 + threshold;
{$IFDEF dbg}
          IF debugb THEN write('<', j, '>');   (* show size *)
{$ENDIF}
          FOR k := 0 TO j - 1 DO BEGIN (* copy the string *)
            c := histbuff[(i + k) AND pred(n)];
{$IFDEF dbg}
            IF debugb THEN write(chr(c));
{$ENDIF}
            putbyte(c);
            histbuff[r] := c;          (* revising the buffer *)
            r := succ(r) AND pred(n); inc(count); END;
          END;
        IF monitor AND (count > printcount) THEN BEGIN
          write(count : 12, #13);      (* show progress *)
          printcount := printcount + 1024; END;
        END;
      END;
    IF monitor THEN writeln(count : 12);
    END; (* decode *)

  (* 1---------------1 *)

  BEGIN (* lzhufe *)
  filemode := 0;          (* so Turbo handles r/o files *)
  IF paramcount <> 2 THEN BEGIN
    writeln('Decodes files encoded by LZHUF');
    error('Usage: lzhufe infile outfile'); END
  ELSE IF NOT freset(infile, paramstr(1)) THEN
    error('Can''t open: ' + paramstr(1))
  ELSE BEGIN
    endofinput := false;
    IF NOT frewrite(outfile, paramstr(2)) THEN BEGIN
      error('Can''t create: ' + paramstr(2)); END
    ELSE BEGIN
      decode(readbyte, putbyte, true);      (* do the real work *)
      fclose(outfile); END;
    fclose(infile); END;
  END. (* lzhufe *)
ž\