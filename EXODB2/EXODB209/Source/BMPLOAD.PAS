{$R-}
UNIT BmpLoad;

INTERFACE

TYPE BMPInfoType = RECORD
       Width,Height,
       Colors           : LongInt;
       Palette          : ARRAY [0..255] OF RECORD
         Red,Green,Blue : Byte;
       END;
END;

PROCEDURE ReadBMP(FileName : STRING; pall : Boolean; x,y,xmax,ymax : Integer; VAR xxx,yyy : Integer);
FUNCTION  BMPResult : Integer;
FUNCTION  BMPErrorMsg(ErrorCode : Integer) : STRING;
PROCEDURE BMPInfo(VAR Info : BMPInfoType);

IMPLEMENTATION

USES Graph;

VAR
  B             : ARRAY[1..4] OF Byte;
  K             : Byte;
  BMPError      : Integer;
  I,J,
  Colors,
  MaxColor      : LongInt;
  CoreHeader    : Boolean;
  BMPFileHeader : RECORD
                         BfType      : Integer; { Signature "BM" ($4D $42) }
                         BfSize      : LongInt; { File size }
                         BfReserved1 : Integer; { Reserved }
                         BfReserved2 : Integer; { Reserved }
                         BfOffBits   : LongInt  { Data offset address: }
                  END;                          {    2 colors        $3E  }
                                                {   16 colors        $76  }
                                                {  256 colors       $436  }
                                                {  true color        $36  }
  BMPInfoHeader : RECORD
                         BiSize          : LongInt; { $28 - Header length in bytes }
                         BiWidth         : LongInt; { Picture width }
                         BiHeight        : LongInt; { Picture height }
                         BiPlanes        : Word;    { Number of planes }
                         BiBitCount      : Word;    { Bits per pixel }
                         BiCompression   : LongInt; { Compression type (0-none) }
                         BiSizeImage     : LongInt; { Picture size in bytes (can be 0 for no compression) }
                         BiXPelsPerMeter : LongInt;
                         BiYPelsPerMeter : LongInt;
                         BiClrUsed       : LongInt;
                         BiClrImportant  : LongInt
                  END;
  RGBColors : ARRAY[0..255] OF RECORD
                         RGBBlue,
                         RGBGreen,
                         RGBRed,
                         RGBReserved : Byte
                  END;

PROCEDURE PutPix(X,Y,Col,maxx,maxy : Longint);
BEGIN
  IF (x < maxx) AND (y < maxy) THEN PutPixel(x,y,Col);
END;

PROCEDURE ReadBMP(FileName : STRING; pall : Boolean; x,y,xmax,ymax : Integer; VAR xxx,yyy : Integer);
VAR
  F    : FILE;
  Size : longint;
Begin
Assign (F,FileName);
{$I-}
Reset (F,1);
{$I+}
If IOResult<>0 then
Begin
BMPError:=1;
Exit
End;
Size:=FileSize (F);
If Size<246 then
Begin
BMPError:=2;
Exit
End;
BlockRead (F,BMPFileHeader,14);
If BMPFileHeader.BfType<>$4D42 then
Begin
BMPError:=4;
Exit
End;
If Size<BMPFileHeader.BfSize then
Begin
BMPError:=2;
Exit
End;
xxx:=bmpinfoheader.BiWidth;
yyy:=bmpinfoheader.Biheight;
BlockRead (F,Size,4);
CoreHeader:=Size=$0C;
BMPInfoHeader.BiSize:=Size;
If Size=$28 then
BlockRead (F,BMPInfoHeader.BiWidth,$24)
else
If Size=$0C then
With BMPInfoHeader do
Begin
BlockRead (F,BiWidth,8);
BiCompression:=0;
BiSizeImage:=0;
BiXPelsPerMeter:=0;
BiYPelsPerMeter:=0;
BiClrUsed:=0;
BiClrImportant:=0
End
else
Begin
BMPError:=5;
Exit
End;
Case BMPInfoHeader.BiBitCount of
1  : Colors:=2;
4  : Colors:=16;
8  : Colors:=256;
24 : Colors:=16777216;
else
Begin
BMPError:=6;
Exit
End
End;
If GetGraphMode<0 then
Begin
BMPError:=7;
Exit
End;
If Colors<=256 then
For I:=0 to Colors-1 do
Begin
if pall=true then begin;
SetPalette (I,I); end;
If Colors=2 then
With RGBColors [I] do
Begin
 RGBBlue:=I*255;
 RGBGreen:=I*255;
  RGBRed:=I*255;
  RGBReserved:=0
  End
  else
  If CoreHeader then
  Begin
  BlockRead (F,RGBColors [I],3);
  RGBColors [I].RGBReserved:=0
  End
  else
  BlockRead (F,RGBColors [I],4);
  With RGBColors [I] do
  if pall=true then begin;
  SetRGBPalette (I,RGBRed div 4,RGBGreen div 4,RGBBlue div 4) end;
  End;
  If GetMaxColor+1<Colors then
  MaxColor:=1
  else
  MaxColor:=GetMaxColor;
  If MaxColor=1 then
  Begin
  if pall=true then begin;
  SetRGBPalette (0,0,0,0);
  SetRGBPalette (1,63,63,63) end;
  End;
  Seek (F,BMPFileHeader.BfOffBits);
  With BMPInfoHeader do
  For J:=BiHeight-1 downto 0 do
  Begin
  I:=0;
  Repeat
  If Colors<=256 then
  BlockRead (F,B [1],4)
  else
  BlockRead (F,B [1],3);
  Case BiBitCount of
  1  : Begin
  K:=1;
  Repeat
  If B [K] and $80>0 then
  PutPix (x+I,y+J,1,xmax,ymax)
  else
  PutPix (x+I,y+J,0,xmax,ymax);
  Inc (I);
  B [K]:=B [K] shl 1;
  If I mod 8=0 then Inc (K)
   Until K=5
   End;
   4  : For K:=1 to 4 do
   Begin
   PutPix (x+I,y+J,(B [K] and $F0) shr 4,xmax,ymax);
   Inc (I);
   PutPix (x+I,y+J,B [K] and $0F,xmax,ymax);
   Inc (I)
   End;
   8  : For K:=1 to 4 do
   Begin
   PutPix (x+I,y+J,B [K],xmax,ymax);
   Inc (I)
   End;
   24 : PutPix (x+I,y+J,longint (B [3])*65536+B [2]*256+B [1],xmax,ymax)
   End
   Until I>BiWidth-1;
   If Colors>256 then
   For K:=1 to (I*3) and 3 do
   BlockRead (F,B[1],1)
   End;
   BMPError:=0
   End;


   Function BMPResult : integer;
     Begin
       BMPResult:=BMPError;
       BMPError:=0
     End;

   Function BMPErrorMsg (ErrorCode : integer) : string;
     Var Temp : string;
       Begin
           Case ErrorCode of
             0 : Temp:='No error';
             1 : Temp:='Error opening file';
             2 : Temp:='File too short';
             3 : Temp:='File not loaded';
             4 : Temp:='Not a BMP file';
             5 : Temp:='Invalid header';
             6 : Temp:='Invalid number of colors';
             7 : Temp:='Graphics mode not initialized';
             else Temp:='Unknown error'
           End;
         BMPErrorMsg:=Temp;
       End;

   Procedure BMPInfo (var Info : BMPInfoType);
     Var I : integer;
       Begin
         With Info do
           Begin
             Width:=0;
             Height:=0;
             Colors:=0;
             If BMPError=0 then
               With BMPInfoHeader do
                 Begin
                   Width:=BiWidth;
                   Height:=BiHeight;
                     Case BiBitCount of
                       1  : Colors:=2;
                       4  : Colors:=16;
                       8  : Colors:=256;
                       24 : Colors:=16777216;
                       else Colors:=0
                     End;
                   For I:=0 to Info.Colors-1 do
                     With Palette [I], RGBColors [I] do
                       Begin
                         Red:=RGBRed;
                         Green:=RGBGreen;
                         Blue:=RGBBlue
                       End
                 End
           End
       End;

     Begin
       BMPError:=3
     End.