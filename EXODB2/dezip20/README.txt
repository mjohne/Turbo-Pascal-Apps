

   DeZip v2.0 (C) Copyright 1989 by R. P. Byrne

   The DeZip program included in this package is a Turbo Pascal (v5.0)
   implementation of a decompressor for ZIP format archives created with
   PKWare's PKZIP program.

   The syntax for the DeZip program is:

      DeZip [d:][\path\]zipname[.zip] [d:][\outpath] [filespec [...]]

   where 'zipname' is the name of the ZIP file from which members are to be
   extracted, 'outpath' is the name of a subdirectory into which all
   extracted members will be placed, and 'filespec' represents a DOS file
   specification (wildcards are allowed) limiting the extraction to one or
   more matching file names.

   The only command line parameter that is required is the name of the ZIP
   file to be processed.  If no filename extension is supplied, '.ZIP' is
   assumed.  If no outpath is specified, the current drive/subdirectory
   will be used.  If no filespec(s) are entered, '*.*' will be assumed.

   Examples:

      *  Extract all '.pas' files from the OneFile.Zip archive.  Place each
         extracted member into the subdirectory e:\work:

                     DeZip OneFile.Zip e:\work *.pas

      *  Extract all files from the OneFile.Zip archive.  Place all
         extracted members into the current subdirectory:

                     DeZip OneFile

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                               LICENSE

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

     The DEZIP source and binaries ("software") are copyrighted.  However,
I am distributing this software for free and you are licensed to use this
software without any charge.

     Redistribution of this software is encouraged.  Please do share it
with your friends, upload it to bulletin board systems, etc.  However,
as I am making this software available for free, you must do the same.
You are not permitted by this license to request or accept any
remuneration of any kind for this software.  This prohibition extends to
including my software with any other product or service for which money
is charged.

     The only exceptions to this "don't charge for what I'm giving away
for free" restriction are as follows:

     (1) Bulletin board systems or other electronic information services
are permitted to make this software available for download and charge
their customary fees, if any, for access to the service.

     (2) Users groups and other not-for-profit organizations that
distribute this software may charge a reasonable fee to cover
duplication and related costs.

     (3) There may be other situations not covered by this license where
some charge for distribution would be appropriate.  Contact me and we'll
talk about it.  But, this license does not authorize any such
distribution without express, written permission from me in advance.

     You may distribute modified copies of my source and resulting
executables (including programs derived from mine in other languages or
for other operating systems) so long as you do so for free and pursuant
to a license no more restrictive than this one.  You must state that
your software was derived from mine.  But, please take credit for your
improvements and blame for your mistakes by making it as clear as
possible what changes you have made.

     Except as provided above, if you do wish to charge for my software
or for any software derived from mine, then you must contact me for
prior permission.  In short, if you're going to ask for money, then
we're going to share in whatever you receive.  That's only fair.

     This software is distributed without warranties of any kind,
express or implied, including, but not limited to, the implied
warranties of merchantability and fitness for a particular purpose.

     Should you wish to contact me, I can be reached via U.S. Mail at
the following address:

               R. P. Byrne
               5 Twin Elm Terrace
               Sparta, NJ 07871

                                                            rpb
                                                          07/31/89


