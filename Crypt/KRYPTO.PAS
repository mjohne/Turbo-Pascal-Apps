{(c) 2001 Florian Frehmeyer}
{This program is free software; you can redistribute it and/or modify it 
under the terms of the GNU Gerneral Public License as published by the
Free Software Foundation; either version 2 of the License, or (at your 
option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT 
ANY WARRANTY; without even the impied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
for more details.
You should have received a copy of the GNU General Public License along with 
this program; if not, write to the Free Software Foundation, Inc.,
675 Mass Ave, Cambridge, MA 02139, USA}

program krypto;

uses crt;

function b_zeile(zeile:string):string;
var i:byte;
    ergebnis:string;
begin
     ergebnis:='';
     for i:=1 to length(zeile) do
     begin
          case zeile[i] of
          ' ':ergebnis:=ergebnis+'';
          'î','ô':ergebnis:=ergebnis+'OE';
          'Ñ','é':ergebnis:=ergebnis+'AE';
          'Å','ö':ergebnis:=ergebnis+'UE';
          '·':ergebnis:=ergebnis+'SS';
          'a'..'z','A'..'Z':ergebnis:=ergebnis+upcase(zeile[i]);
          end;{case}
     end;
     b_zeile:=ergebnis;
end;{b_zeile}

function caesar_chiff(klartext:string;schluessel:char):string;
var i,asciiwert:byte;
    ergebnis:string;
begin
     ergebnis:='';
     i:=0;
     for i:=1 to length(klartext) do
     begin
          asciiwert:=ord(klartext[i])+ord(schluessel)-ord('A');
          if asciiwert>ord('Z') then asciiwert:=asciiwert-26;
          ergebnis:=ergebnis+chr(asciiwert);
     end;
     caesar_chiff:=ergebnis;
end;{caesar_chiff}

function caesar_dechiff(kryptotext:string;schluessel:char):string;
var ergebnis:string;
    i,asciiwert:byte;
begin
     ergebnis:='';
     i:=0;
     for i:=1 to length(kryptotext) do
     begin
          asciiwert:=ord(kryptotext[i])-(ord(schluessel)-ord('A'));
          if asciiwert<ord('A') then asciiwert:=asciiwert+26;
          ergebnis:=ergebnis+chr(asciiwert);
     end;
     caesar_dechiff:=ergebnis;
end;{caesar_dechiff}

function caesar_chiff_ascii(klartext:string;schluessel:char):string;
var i:byte;
    ergebnis:string;
    asciiwert:integer;
begin
     ergebnis:='';
     i:=0;
     for i:=1 to length(klartext) do
     begin
          asciiwert:=ord(klartext[i])+ord(schluessel)-32;
          if asciiwert>254 then asciiwert:=asciiwert-223;
          ergebnis:=ergebnis+chr(asciiwert);
     end;
     caesar_chiff_ascii:=ergebnis;
end;{caesar_chiff_ascii}

function caesar_dechiff_ascii(kryptotext:string;schluessel:char):string;
var ergebnis:string;
    i:byte;
    asciiwert:integer;
begin
     ergebnis:='';
     i:=0;
     for i:=1 to length(kryptotext) do
     begin
          asciiwert:=ord(kryptotext[i])-(ord(schluessel)-32);
          if asciiwert<32 then asciiwert:=asciiwert+223;
          ergebnis:=ergebnis+chr(asciiwert);
     end;
     caesar_dechiff_ascii:=ergebnis;
end;{caesar_dechiff_ascii}

procedure caesar_chiff_file(klartextfile,kryptotextfile,schluesselw:string);
var quelle,ziel:text;
    kryptotext,zeile:string;
    i:byte;
begin
     assign(quelle,klartextfile);
     reset(quelle);
     assign(ziel,kryptotextfile);
     rewrite(ziel);
     i:=0;
     while not eof(quelle) do
     begin
          kryptotext:='';
          readln(quelle,zeile);
          for i:=1 to length(zeile) do
          begin
               kryptotext:=kryptotext+caesar_chiff_ascii(zeile[i],schluesselw[1]);
          end;
          writeln(ziel,kryptotext);
     end;
     close(quelle);
     close(ziel);
end;{caesar_chiff_file}

procedure caesar_dechiff_file(klartextfile,kryptotextfile,schluesselw:string);
var quelle,ziel:text;
    klartext,zeile:string;
    i:byte;
begin
     assign(quelle,kryptotextfile);
     reset(quelle);
     assign(ziel,klartextfile);
     rewrite(ziel);
     i:=0;
     while not eof(quelle) do
     begin
          klartext:='';
          readln(quelle,zeile);
          for i:=1 to length(zeile) do
          begin
               klartext:=klartext+caesar_dechiff_ascii(zeile[i],schluesselw[1]);
          end;
          writeln(ziel,klartext);
     end;
     close(quelle);
     close(ziel);
end;{caesar_dechiff_file}

function allg_zuordchiff(klartext,schluesselw:string):string;
var ergebnis:string;
    i:byte;
begin
     ergebnis:='';
     i:=0;
     for i:=1 to length(klartext) do
     begin
          ergebnis:=ergebnis+schluesselw[ord(klartext[i])-64];
     end;
     allg_zuordchiff:=ergebnis;
end;{allg_zuordchiff}

function allg_zuorddechiff(kryptotext,schluesselw:string):string;
var ergebnis:string;
    i,n:byte;
begin
     ergebnis:='';
     i:=0;
     for i:=1 to length(kryptotext) do
     begin
          n:=0;
          repeat
          inc(n);
          until kryptotext[i]=schluesselw[n];
          ergebnis:=ergebnis+chr(64+n);
     end;
     allg_zuorddechiff:=ergebnis;
end;{allg_zuorddechiff}

function vigenere_chiff(klartext,schluesselw:string;mode:string):string;
var i,n:byte;
    ergebnis:string;
begin
     ergebnis:='';
     i:=0;
     n:=0;
     for i:=1 to length(klartext) do
     begin
          inc(n);
          if mode='alphabet' then ergebnis:=ergebnis+caesar_chiff(klartext[i],schluesselw[n])
          else ergebnis:=ergebnis+caesar_chiff_ascii(klartext[i],schluesselw[n]);
          if n=length(schluesselw) then n:=0;
     end;
     vigenere_chiff:=ergebnis;
end;{vigenere_chiff}

function vigenere_dechiff(kryptotext,schluesselw:string;mode:string):string;
var i,n:byte;
    ergebnis:string;
begin
     ergebnis:='';
     i:=0;
     n:=0;
     for i:=1 to length(kryptotext) do
     begin
          inc(n);
          if mode='alphabet' then ergebnis:=ergebnis+caesar_dechiff(kryptotext[i],schluesselw[n])
          else ergebnis:=ergebnis+caesar_dechiff_ascii(kryptotext[i],schluesselw[n]);
          if n=length(schluesselw) then n:=0;
     end;
     vigenere_dechiff:=ergebnis;
end;{vigenere_dechiff}

procedure vigenere_chiff_file(klartextfile,kryptotextfile,schluesselw:string);
var quelle,ziel:text;
    zeile,kryptotext:string;
    i,j:byte;
begin
     assign(quelle,klartextfile);
     reset(quelle);
     assign(ziel,kryptotextfile);
     rewrite(ziel);
     i:=0;
     j:=0;
     while not eof(quelle) do
     begin
          readln(quelle,zeile);
          kryptotext:='';
          for i:=1 to length(zeile) do
          begin
               kryptotext:=kryptotext+caesar_chiff_ascii(zeile[i],schluesselw[j]);
               inc(j);
               if j>length(schluesselw) then j:=1;
          end;
          writeln(ziel,kryptotext);
     end;
     close(ziel);
     close(quelle);
end;{vigenere_chiff_file}

procedure vigenere_dechiff_file(klartextfile,kryptotextfile,schluesselw:string);
var quelle,ziel:text;
    zeile,klartext:string;
    i,j:byte;
begin
     assign(quelle,kryptotextfile);
     reset(quelle);
     assign(ziel,klartextfile);
     rewrite(ziel);
     i:=0;
     j:=0;
     while not eof(quelle) do
     begin
          readln(quelle,zeile);
          klartext:='';
          for i:=1 to length(zeile) do
          begin
               klartext:=klartext+caesar_dechiff_ascii(zeile[i],schluesselw[j]);
               inc(j);
               if j>length(schluesselw) then j:=1;
          end;
          writeln(ziel,klartext);
     end;
     close(ziel);
     close(quelle);
end;{vigenere_dechiff_file}

function schleppnetz_chiff(klartext,schluesselw:string;mode:string):string;
begin
     if mode='alphbet' then
     begin
          schleppnetz_chiff:=vigenere_chiff(klartext,schluesselw+klartext,'alphabet');
     end
     else
     begin
          schleppnetz_chiff:=vigenere_chiff(klartext,schluesselw+klartext,'ascii');
     end;
end;{schleppnetz_chiff}

function schleppnetz_dechiff(kryptotext,schluesselw:string;mode:string):string;
var i:byte;
    ergebnis:string;
begin
     ergebnis:='';
     i:=0;
     for i:=1 to length(kryptotext) do
     begin
          if mode='alphabet' then
          begin
               schluesselw:=schluesselw+caesar_dechiff(kryptotext[i],schluesselw[i]);
               ergebnis:=ergebnis+caesar_dechiff(kryptotext[i],schluesselw[i]);
          end
          else
          begin
               schluesselw:=schluesselw+caesar_dechiff_ascii(kryptotext[i],schluesselw[i]);
               ergebnis:=ergebnis+caesar_dechiff_ascii(kryptotext[i],schluesselw[i]);
          end;
     end;
     schleppnetz_dechiff:=ergebnis;
end;{schleppnezt_dechiff}

procedure schleppnetz_chiff_file(klartextfile,kryptotextfile,schluesselw:string);
var quelle,ziel:text;
    zeile,kryptotext:string;
begin
     assign(quelle,klartextfile);
     reset(quelle);
     assign(ziel,kryptotextfile);
     rewrite(ziel);
     while not eof(quelle) do
     begin
          readln(quelle,zeile);
          schluesselw:=schluesselw+Zeile;
          writeln(ziel,vigenere_chiff(zeile,schluesselw,''));
          delete(schluesselw,1,length(zeile));
     end;
     close(ziel);
     close(quelle);
end;{schleppnetz_chiff_file}

procedure schleppnetz_dechiff_file(klartextfile,kryptotextfile,schluesselw:string);
var quelle,ziel:text;
    zeile,klartext:string;
    i:byte;
begin
     assign(quelle,kryptotextfile);
     reset(quelle);
     assign(ziel,klartextfile);
     rewrite(ziel);
     while not eof(quelle) do
     begin
          readln(quelle,zeile);
          klartext:='';
          for i:=1 to length(zeile) do
          begin
               klartext:=klartext+caesar_dechiff_ascii(zeile[i],schluesselw[1]);
               schluesselw:=schluesselw+caesar_dechiff_ascii(zeile[i],schluesselw[1]);
               delete(schluesselw,1,1);
          end;
          writeln(ziel,klartext);
     end;
     close(quelle);
     close(ziel);
end;{schleppnetz_dechiff_file}

function verfahren(wahl:byte):string;
begin
     case wahl of
     1:
       begin
            verfahren:='Caesar';
       end;
     2:
       begin
            verfahren:='Vigenäre';
       end;
     3:
       begin
            verfahren:='Schleppnetz';
       end;
     end;{case}
end;{verfahren}

function gueltigkeitsbereich(klartext,kryptotext:string;schluessel:char;schluesselw:string;mode:string):string;
const y:array[1..8] of byte=(9,10,13,14,17,18,22,23);
var x:byte;
begin
     x:=33;
     if mode='alphabet' then
     begin
           gueltigkeitsbereich:='Alphabet (A-Z)';

           gotoxy(x,y[1]);clreol;
           if klartext='' then
           begin
                if schluessel=' ' then write('Schluessel fehlt!')
                else write('Klartext fehlt!');
           end
           else write(caesar_chiff(klartext,schluessel));
           gotoxy(x,y[2]);clreol;
           if kryptotext='' then
           begin
                if schluessel=' ' then write('Schluessel fehlt!')
                else write('Kryptogramm fehlt!');
           end
           else write(caesar_dechiff(kryptotext,schluessel));
           gotoxy(x,y[3]);clreol;
           if length(schluesselw)<length(klartext) then write('Schluesselwort zu kurz!')
           else
           begin
                if klartext='' then
                begin
                     if schluesselw='' then write('Schluesselwort fehlt')
                     else write('Klartext fehlt');
                end
                else write(allg_zuordchiff(klartext,schluesselw));
           end;
           gotoxy(x,y[4]);clreol;
           if length(schluesselw)<length(kryptotext) then write('Schluesselwort zu kurz!')
           else
           begin
                if kryptotext='' then
                begin
                     if schluesselw='' then write('Schluesselwort fehlt!')
                     else write('Kryptogramm fehlt!');
                end
                else write(allg_zuorddechiff(kryptotext,schluesselw));
           end;
           gotoxy(x,y[5]);clreol;
           if klartext='' then
           begin
                if schluesselw='' then write('Schluesselwort fehlt!')
                else write('Klartext fehlt!');
           end
           else write(vigenere_chiff(klartext,schluesselw,mode));
           gotoxy(x,y[6]);clreol;
           if kryptotext='' then
           begin
                if schluesselw='' then write('Schluesselwort fehlt!')
                else write('Kryptogramm fehlt!');
           end
           else write(vigenere_dechiff(kryptotext,schluesselw,mode));
           gotoxy(x,y[7]);clreol;
           if klartext='' then
           begin
                if schluesselw='' then write('Schluesselwort fehlt!')
                else write('Klartext fehlt!');
           end
           else write(schleppnetz_chiff(klartext,schluesselw,mode));
           gotoxy(x,y[8]);clreol;
           if kryptotext='' then
           begin
                if schluesselw='' then write('Schluesselwort fehlt!')
                else write('Kryptogramm fehlt!');
           end
           else write(schleppnetz_dechiff(kryptotext,schluesselw,mode));
      end
      else
      begin
           gueltigkeitsbereich:='ASCII-Zeichen 32-254';

           gotoxy(x,y[1]);clreol;
           if klartext='' then write('Klartext fehlt!')
           else write(caesar_chiff_ascii(klartext,schluessel));
           gotoxy(x,y[2]);clreol;
           if kryptotext='' then write('Kryptogramm fehlt!')
           else write(caesar_dechiff_ascii(kryptotext,schluessel));
           gotoxy(x,y[3]);clreol;
           write('|keine Ausgabe, da Schluesselwort|');
           gotoxy(x,y[4]);clreol;
           write('|222 Zeichen lang sein muesste!  |');
           gotoxy(x,y[5]);clreol;
           if klartext='' then
           begin
                if schluesselw='' then write('Schluesselwort fehlt!')
                else write('Klartext fehlt!');
           end
           else write(vigenere_chiff(klartext,schluesselw,mode));
           gotoxy(x,y[6]);clreol;
           if kryptotext='' then
           begin
                if schluesselw='' then write('Schluesselwort fehlt!')
                else write('Kryptogramm fehlt!');
           end
           else write(vigenere_dechiff(kryptotext,schluesselw,mode));
           gotoxy(x,y[7]);clreol;
           if klartext='' then
           begin
                if schluesselw='' then write('Schluesselwort fehlt!')
                else write('Klartext fehlt!');
           end
           else write(schleppnetz_chiff(klartext,schluesselw,mode));
           gotoxy(x,y[8]);clreol;
           if kryptotext='' then
           begin
                if schluesselw='' then write('Schluesselwort fehlt!')
                else write('Kryptogramm fehlt!');
           end
           else write(schleppnetz_dechiff(kryptotext,schluesselw,mode));
     end;
end;{gueltigkeitsbereich}

procedure ueberschrift(mode:string);
var i:byte;
begin
     clrscr;
     textbackground(0);
     textcolor(2);
     gotoxy(1,1);write('super-krypto');
     textcolor(4);
     gotoxy(14,1);write('--pro--');
     randomize;
     textcolor(random(15));
     gotoxy(36,1);write('''beta 4''');
     textcolor(2);
     gotoxy(68,1);write(mode);
     for i:=1 to 79 do
     begin
          gotoxy(i,2);write('-');
     end;
end;{ueberschrift}

procedure string_menue;
var klartext,kryptotext,schluesselw,gueltig,mode:string;
    wahl,schluessel:char;
    letztewahl,i:byte;
begin
     klartext:='';
     kryptotext:='';
     schluesselw:='';
     gueltig:='';
     mode:='';
     wahl:='G';
     schluessel:=' ';
     letztewahl:=0;{Voreistellung fuer Gueltigkeitsbereich ASCII-Code}
     i:=1;
     repeat
           ueberschrift('String-Modus');
           gueltig:=gueltigkeitsbereich(klartext,kryptotext,schluessel,schluesselw,mode);
           gotoxy(5,3);write('K(l)artext        ',klartext);
           gotoxy(5,4);write('K(r)yptogamm      ',kryptotext);
           gotoxy(5,5);write('(S)chluessel      ',schluessel);
           gotoxy(5,6);write('Schluessel(w)ort  ',schluesselw);
           gotoxy(38,7);write('(G)ueltigkeitsbereich: ',gueltig);
           gotoxy(1,8);write('À Caesar-Verfahren');
           gotoxy(1,9);write('Ã Klartext verschluesselt');
           gotoxy(1,10);write('» Kryptogramm entschluesselt');
           gotoxy(1,12);write('À Allgemeine Zuordnung');
           gotoxy(1,13);write('Ã Klartext verschluesselt');
           gotoxy(1,14);write('» Kryptogramm entschluesselt');
           gotoxy(1,16);write('À Vigenäre-Verfahren');
           gotoxy(1,17);write('Ã Klartext verschluesselt');
           gotoxy(1,18);write('»À Kryptogramm entschluesselt');
           gotoxy(1,19);write(' » (K)asiski-Test (*in Vorbereitung*)');
           gotoxy(1,21);write('À Schleppnetz-Verfahren');
           gotoxy(1,22);write('Ã Klartext verschluesselt');
           gotoxy(1,23);write('» Kryptogramm entschluesselt');
           textcolor(7);
           gotoxy(1,24);write('Beenden & Modus-Wahl (esc)');
           repeat
                 gotoxy(1,25);
                 clreol;
                 write('Welche Wahl?: ');
                 wahl:=readkey;
                 wahl:=upcase(wahl);
           until wahl in ['L','R','S','W','G'{,'K'},chr(027){esc}];
           gotoxy(1,25);
           clreol;
           case wahl of
                'L':
                    begin
                         klartext:='';
                         gotoxy(1,25);write('Klartext eingeben: ');readln(klartext);
                         repeat
                               gotoxy(1,26);clreol;
                               write('Klartext bereinigen?  (j-n)');
                               wahl:=readkey;
                               wahl:=upcase(wahl);
                         until wahl in ['J','N',chr(027{esc})];
                         if wahl='J'then klartext:=b_zeile(klartext);
                         wahl:=' ';
                    end;

                'R':
                     begin
                         kryptotext:='';
                         gotoxy(1,25);write('Kryptogramm eingeben: ');readln(kryptotext);
                         repeat
                               gotoxy(1,26);clreol;
                               write('Kryptogramm bereinigen?  (j-n)');
                               wahl:=readkey;
                               wahl:=upcase(wahl);
                         until wahl in ['J','N',chr(027{esc})];
                         if wahl='J'then kryptotext:=b_zeile(kryptotext);
                         wahl:=' ';
                    end;

                'S':
                    begin
                         schluessel:=' ';
                         gotoxy(1,25);write('Schluessel eingeben: ');readln(schluessel);
                         repeat
                               gotoxy(1,26);clreol;
                               write('Schluessel bereinigen?  (j-n)');
                               wahl:=readkey;
                               wahl:=upcase(wahl);
                         until wahl in ['J','N',chr(027{esc})];
                         if wahl='J'then schluessel:=upcase(schluessel);
                         wahl:=' ';
                    end;

                'W':
                    begin
                         schluesselw:=' ';
                         gotoxy(1,25);write('Schluesselwort eingeben: ');readln(schluesselw);
                         repeat
                               gotoxy(1,26);clreol;
                               write('Schluesselwort bereinigen?  (j-n)');
                               wahl:=readkey;
                               wahl:=upcase(wahl);
                         until wahl in ['J','N',chr(027{esc})];
                         if wahl='J'then schluesselw:=b_zeile(schluesselw);
                         wahl:=' ';
                    end;

                'G':
                    begin
                         if letztewahl=0 then
                         begin
                              letztewahl:=1;
                              mode:='alphabet';
                              wahl:=' ';
                         end
                         else
                         begin
                              letztewahl:=0;
                              mode:='';
                              wahl:=' ';
                         end;
                    end;
           end;{case}
     until wahl=chr(027{esc});{Programm beenden}
end;{string_menue}

procedure file_menue;
var klartextfile_dir,kryptotextfile_dir,schluesselw,akt_verfahren:string;
    wahl:char;
    akt_wahl:byte;
begin
     klartextfile_dir:='';
     kryptotextfile_dir:='';
     schluesselw:='';
     wahl:='G';
     akt_verfahren:='';
     akt_wahl:=1;
     repeat
           akt_verfahren:=verfahren(akt_wahl);
           ueberschrift('Datei-Modus');
           gotoxy(7,3);write('K(l)artextdatei        ',klartextfile_dir);
           gotoxy(7,4);write('K(r)yptogammdatei      ',kryptotextfile_dir);
           gotoxy(7,5);write('Schluessel(w)ort  ',schluesselw);
           gotoxy(1,7);write('À ',akt_verfahren,'-(V)erfahren');
           gotoxy(1,8);write('Ã Klartextdatei verschluesselt    (1)');
           gotoxy(1,9);write('» Kryptogrammdatei entschluesselt (2)');
           textcolor(7);
           gotoxy(1,11);write('Gueltigkeitsbereich: ASCII-Codes 31-222');
           gotoxy(1,12);write('Die Zieldatei wird ohne Abfragen ueberschrieben!');
           gotoxy(1,13);write('Beenden & Modus-Wahl (esc)');
           repeat
                 gotoxy(1,15);
                 clreol;
                 write('Welche Wahl?: ');
                 wahl:=readkey;
                 wahl:=upcase(wahl);
           until wahl in ['L','R','W','V','1','2',chr(027){esc}];
           gotoxy(1,15);
           clreol;
           case wahl of
                'L':
                    begin
                         klartextfile_dir:='';
                         gotoxy(1,15);write('vollstaendigen Klartextpfad eingeben(z.B.''c:\test\klartext.txt''): ');
                         gotoxy(1,16);readln(klartextfile_dir);
                         wahl:=' ';
                    end;

                'R':
                     begin
                         kryptotextfile_dir:='';
                         gotoxy(1,15);write('vollstaendigen Kryptogrammpfad eingeben(z.B.''c:\test\kryptogr.txt''): ');
                         gotoxy(1,16);readln(kryptotextfile_dir);
                         wahl:=' ';
                    end;

                'W':
                    begin
                         schluesselw:=' ';
                         gotoxy(1,15);write('Schluesselwort eingeben: ');
                         gotoxy(1,16);readln(schluesselw);
                         repeat
                               gotoxy(1,17);clreol;
                               write('Schluesselwort bereinigen?  (j-n)');
                               wahl:=readkey;
                               wahl:=upcase(wahl);
                         until wahl in ['J','N',chr(027{esc})];
                         if wahl='J'then schluesselw:=b_zeile(schluesselw);
                         wahl:=' ';
                    end;

                'V':
                    begin
                         if akt_wahl>3 then akt_wahl:=1
                         else
                         inc(akt_wahl);
                    end;

                '1':
                    begin
                         case akt_wahl of
                         1: caesar_chiff_file(klartextfile_dir,kryptotextfile_dir,schluesselw);
                         2: vigenere_chiff_file(klartextfile_dir,kryptotextfile_dir,schluesselw);
                         3: schleppnetz_chiff_file(klartextfile_dir,kryptotextfile_dir,schluesselw);
                         end;{case}
                         wahl:=' ';
                    end;

                '2':
                    begin
                         case akt_wahl of
                         1: caesar_dechiff_file(klartextfile_dir,kryptotextfile_dir,schluesselw);
                         2: vigenere_dechiff_file(klartextfile_dir,kryptotextfile_dir,schluesselw);
                         3: schleppnetz_dechiff_file(klartextfile_dir,kryptotextfile_dir,schluesselw);
                         end;{case}
                         wahl:=' ';
                    end;
                end;{case}
     until wahl=chr(027{esc});{file_menue beenden}
end;{file_menue}

procedure start;
var wahl:char;
begin
     clrscr;
     wahl:=' ';
     repeat
           repeat
                 ueberschrift('Modus-Wahl');
                 gotoxy(1,3);write('Welcher Modus soll gestartet werden?');
                 gotoxy(1,5);write('(S)tring-Modus');
                 gotoxy(1,6);write('(D)atei-Modus');
                 textcolor(7);
                 gotoxy(1,8);write('Beenden (esc)');
                 wahl:=readkey;
                 wahl:=upcase(wahl);
           until wahl in ['S','D',chr(027)];
           case wahl of
           'S':
               string_menue;
           'D':
               file_menue;
           chr(027):
                    end;
     until wahl=chr(027){Programm beenden};
end;{start}

begin
     start;
end.
