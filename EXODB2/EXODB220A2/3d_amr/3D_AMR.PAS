Program Graphics3D;

{
/**************************************************************************
 *       3D_AMR.PAS                                                       *
 *                                                                        *
 *   "3D_AMR" A 3D Modeling and Animation Graphics program implementing   *
 *    the z-buffer hidden face removal algorithm, and utilizing double    *
 *    buffering for fast real-time animation of 3D objects on the PC.     *
 *                                                                        *
 *                                                                        *
 *       This program uses the DOUBLE BUFFERING technique for             *
 *       animation. While you are watching the current frame on the       *
 *       VISUAL PAGE, the new frame is actually being drawn on the        *
 *       ACTIVE PAGE. This leads to smoother animations.                  *
 *                                                                        *
 *       You are allowed to use this source code, in part or in whole,    *
 *       But, please, would you kindly remeber to mention me.             *
 *                                                                        *
 *       I hope you benefit from it, and that it opens in front of you a  *
 *       a zillion gates for new creative ideas.                          *
 *                                                                        *
 *       Coded By:                                                        *
 *                  Amr A. Awadallah,            May 1992                 *
 *                  Computer Department,                                  *
 *                  Faculty Of Engineering,                               *
 *                  Cairo University,                                     *
 *                  Egypt.                                                *
 *                  e-mail : "amr@frcu.eun.eg" or "a.awadallah@ieee.org"  *
 *                  phone  : (202) 330-4738                               *
 *                                                                        *
 **************************************************************************/
}

{$R-,S-}

uses Crt,Graph,Dos;

const
	MaxPts          = 11;
	MaxPolys        = 30;
	DEG       = PI/180;

type
	xyzw                            = (x,y,z,w);
	Point                           = array[xyzw] of real;
	Point3DType   = array[x..z] of real;
	MatrixType              = array[1..4,1..4] of real;
	PolygonType             = array[1..MaxPts+1] of PointType;
	Polygon3DType = record
										numPts : word;
										coords : array[1..MaxPts] of Point3DType;
									end;
	Object3DType    = record
										numPolys : word;
										poly : array[1..MaxPolys] of Polygon3DType;
									end;
	DepthType = record
								num   : word;
								depth : real;
							end;
	DepthListType = array[1..MaxPolys] of DepthType;

const
	I               : MatrixType = ( (1,0,0,0) , (0,1,0,0) , (0,0,1,0) , (0,0,0,1) );

var
	Gd, Gm                          : Integer;
	MaxX,MaxY                       : integer;
	CenterX,CenterY : integer;
	Color,BkColor           : word;
	FillColor                               : word;

  VPN,VUP,COP,
  u,v,
  CENT,
  P,Pprime,
  VRPprime,
	tempvect,
	center                                  : Point;
  Tr,Rot,
  Sc,Sh,
  ViewMat                                       : MatrixType;
	scalar                                  : real;
	index                                           : xyzw;

	obj                                                     : Object3DType;
	FillFlag,flag     : Boolean;
	ObjectExists            : Boolean;
	DepthUpToDate   : Boolean;
	Parallel                                : Boolean;
	AnimOFF                                 : Boolean;
	ch                                                      : char;
	D                                                               : real;
	DepthList                               : DepthListType;

Function Dot_Prod(v1,v2 : Point) : real;
begin
	Dot_Prod := v1[x]*v2[x] + v1[y]*v2[y] + v1[z]*v2[z];
end;

Procedure Cross_Prod(v1,v2 : Point; var result : Point);
begin
	result[x] := v1[y]*v2[z] - v1[z]*v2[y];
  result[y] := v1[z]*v2[x] - v1[x]*v2[z];
  result[z] := v1[x]*v2[y] - v1[y]*v2[x];
end;

Procedure Normalize(var v1 : Point);
var
	length : real;
begin
	length := sqrt(Dot_Prod(v1,v1));
  for index := x to z do
	v1[index] := v1[index]/length;
end;

Procedure Multiply_Mat(A,B : MatrixType; var C : MatrixType);
var
	i,j,k : integer;
begin
	for i := 1 to 4 do
	for j := 1 to 4 do
    begin
	C[i,j] := 0;
      for k := 1 to 4 do
	C[i,j] := C[i,j] + A[i,k] * B[k,j];
    end;
end;

Procedure Multiply_Vec(A : MatrixType; v1 : Point; var v2 : Point);
var
	i : xyzw;
  j : integer;
begin
	for i := x to w do
  begin
	j := ord(i) + 1;
    v2[i] := v1[x]*A[1,j] + v1[y]*A[2,j] + v1[z]*A[3,j] + v1[w]*A[4,j];
  end;
end;

Procedure Subtract_Vec(v1,v2 : Point; var result : Point);
begin
	result[x] := v1[x] - v2[x];
	result[y] := v1[y] - v2[y];
	result[z] := v1[z] - v2[z];
	result[w] := 1;
end;

Procedure GetCenter(var p : Point3DType);
var
	i,j     : word;
	TotalNumPts : word;
begin
	TotalNumPts := 0;
	p[x] := 0; p[y] := 0;   p[z] := 0;
	with obj do
		for i := 1 to numPolys do
			with poly[i] do
			begin
				TotalNumPts := TotalNumPts + numPts;
				for j := 1 to numPts do
					for index := x to z do
						p[index] := p[index] + coords[j][index];
			end;
	for index := x to z do
		p[index] := p[index]/ TotalNumPts;
end;

Procedure Translate(Tx, Ty, Tz : real);
begin
	Tr := I;
	Tr[4,1] := Tx;
	Tr[4,2] := Ty;
	Tr[4,3] := Tz;
	Multiply_Mat(ViewMat,Tr,ViewMat);
end;

Procedure Rotate(Rx , Ry, Rz : real);
begin
	if ( Rx<>0 ) then
  begin
		Rot := I; Rx := Rx * DEG;
		Rot[2,2] := cos(Rx);
		Rot[2,3] := sin(Rx);
		Rot[3,2] := -Rot[2,3];
		Rot[3,3] := Rot[2,2];
		Multiply_Mat(ViewMat,Rot,ViewMat);
	end;

  if ( Ry<>0 ) then
  begin
		Rot := I; Ry := Ry * DEG;
		Rot[1,1] := cos(Ry);
		Rot[1,3] := sin(Ry);
		Rot[3,1] := -Rot[1,3];
		Rot[3,3] := Rot[1,1];
		Multiply_Mat(ViewMat,Rot,ViewMat);
	end;

  if ( Rz<>0 ) then
  begin
		Rot := I; Rz := Rz * DEG;
		Rot[1,1] := cos(Rz);
		Rot[1,2] := sin(Rz);
		Rot[2,1] := -Rot[1,2];
		Rot[2,2] := Rot[1,1];
		Multiply_Mat(ViewMat,Rot,ViewMat);
	end;
end;

Procedure Scale(Sx, Sy, Sz : real);
begin
	Sc := I;
	if Sx<>0 then Sc[1,1] := Sx;
	if Sy<>0 then Sc[2,2] := Sy;
	if Sz<>0 then Sc[3,3] := Sz;
	Multiply_Mat(ViewMat,Sc,ViewMat);
end;

Procedure Shear(dir : word; a,b : real);
begin
	Sh := I;
	case dir of
		0 : begin Sh[1,2] := a; Sh[1,3] := b; end;
		1 : begin Sh[2,1] := a; Sh[2,3] := b; end;
		2 : begin Sh[3,1] := a; Sh[3,2] := b; end;
	end;
	Multiply_Mat(ViewMat,Sh,ViewMat);
end;

Procedure TransformObject;
var
	i,j : word;
	p               : Point;
begin
	DepthUpToDate := FALSE;
	with obj do
		for i := 1 to numPolys do
			with poly[i] do
				for j := 1 to numPts do
				begin
					p[x] := coords[j][x]; p[y] := coords[j][y]; p[z] := coords[j][z];
					p[w] := 1;
					Multiply_Vec(ViewMat,p,p);
					coords[j][x] := p[x]; coords[j][y] := p[y]; coords[j][z] := p[z];
				end;
end;

procedure FillDepthList;
var i : word;
begin
	with obj do
	for i := 1 to numPolys do DepthList[i].num := i;
	DepthUpToDate := FALSE;
end;

procedure UpdateObject;

	function DepthOf( po : Polygon3DType) : real;
	var
		depth                           : real;
		i                                               : word;
	begin
		Depth := 0;
		with po do
		begin
			for i := 1 to numPts do
				Depth := Depth + coords[i][z];
			DepthOf := Depth/po.numPts;
		end;
	end;

	procedure UpdateDepthList;
	var     i : word;
	begin
		with obj do
			for i := 1 to numPolys do
			begin
				DepthList[i].num := i;
				DepthList[i].depth := DepthOf(poly[i]);
			end;
	end;

	procedure SortDepthList;
		procedure sort( l,r : word);
		var
			i,j     : word;
			x               : real;
			y               : DepthType;
		begin
			i := l; j := r; x := DepthList[(i+j) DIV 2].depth;
			repeat
				while DepthList[i].depth > x do i := i+1;
				while x > DepthList[j].depth do j := j-1;
				if i <= j then
				begin
					y := DepthList[i];
					DepthList[i] := DepthList[j];
					DepthList[j] := y;
					i := i + 1; j := j - 1;
				end;
			until i > j;
			if l < j then sort(l,j);
			if i < r then sort(i,r);
		end;
	begin
		sort(1,obj.numPolys);
	end;

	begin
		if(not DepthUpToDate) then
		begin
			UpdateDepthList;
			SortDepthList;
			DepthUpToDate := TRUE;
		end;
	end;

Procedure DrawObject;
var
	i,j                             : word;
	polygon         : PolygonType;
	pt                      : Point;
	s                                       : real;

begin
	if (FillFlag) then UpdateObject;
	with obj do
	for i := 1 to numPolys do
		with poly[DepthList[i].num] do
		begin
			for j := 1 to numPts do
			begin
				if (parallel) or (coords[j][z] = 0) then s:=1 else s:=D/coords[j][z];
				polygon[j].x := centerX + Round(coords[j][x]*s);
				polygon[j].y := centerY - Round(coords[j][y]*s);
			end;
			polygon[numPts+1] := polygon[1];{This line and the +1 could be removed}
			DrawPoly( numPts+1, Polygon );
			if (FillFlag) then FillPoly( numPts+1, Polygon );
		end;
	if (AnimOFF) then
	begin
		SetFillStyle(1,GREEN); SetColor(WHITE);
		Bar(170,14,470,47);
		Rectangle(170,14,470,47);
		OutTextxy(180,19,'3D-Graphics by Amr Awadallah (1992)');
		OutTextxy(230,32,'Press "H" for Help');
		SetFillStyle(1,FillColor); SetColor(Color);
	end;
end;

Procedure DisplayHeader;
begin
	clrscr;
	gotoxy(22,2);writeln('3D-GRAPHICS by Amr Awadallah (1992)');
	gotoxy(22,3);writeln('-----------------------------------');
	writeln;
end;

Procedure InputObject;
var
	i,j : word;
	center : Point3DType;
begin
	DisplayHeader;
	writeln('Object Creation Mode :-');
	writeln('-----------------------');
	writeln;
	writeln('Use SPACES to seperate co-ordinates of a point,');
	writeln('e.g. : Instead of  (23,4.5,-17)  enter   23 4.5 -17  .');
	writeln;writeln;
	with obj do
	begin
		write('Enter number of polygons (MAX = ',MaxPolys,' ) : ');
		readln(numPolys);
		if (numPolys > MaxPolys) then numPolys := MaxPolys;
		for i := 1 to numpolys do
			with poly[i] do
			begin
				writeln;
				writeln('Polygon ',i,' : ');
				write('Enter Number of points (MAX = ',MaxPts,' ) : '); readln(numPts);
				if (numPts > MaxPts) then numPts := MaxPts;
				for j := 1 to numPts do
				begin
					write('Enter point ',j,' : ');
					readln(coords[j][x],coords[j][y],coords[j][z]);
				end;
			end;
		if (numPolys <> 0) then
		begin
			ObjectExists := TRUE;
			FillDepthList;
			GetCenter(center);
			D := center[z]/2;
		end;
	end;
end;

Procedure SaveObject;
var
	f : file of Object3DType;
	objectname : string;
begin
	writeln;
	write('Enter Object filename to Save : '); readln(objectname);
	Assign(f,objectname);
	Rewrite(f);
	Write(f,obj);
	Close(f);
end;

Procedure LoadObject;
var
	f : file of Object3DType;
	objectname : string;
	ch      : char;
	center : Point3DType;

	function FileExists(FileName: string) : Boolean;
	var
		f: file;
	begin
		{$I-}
		Assign(f, FileName);
		Reset(f);
		Close(f);
    {I+}
		FileExists := (IOResult = 0) and (FileName <> '');
	end;

begin
	writeln;
	write('Enter Object filename to Load : ');
	readln(objectname);
	if(FileExists(objectname)) then
	begin
		Assign(f,objectname);
		Reset(f);
		Read(f,obj);
		Close(f);
		ObjectExists := TRUE;
		FillDepthList;
		GetCenter(center);
		D := center[z]/2;
	end
	else
	begin
		writeln;
		writeln('Sorry, Can''t Load Object. (FileName does not exist.)');
		writeln;
		writeln('Press any key to continue.');
		ch := readkey;
	end;
end;

Procedure Display;
var
	center  : Point3DType;
	ch                : char;
	page      : word;
	Col,Row : word;
	height  : word;

	Procedure Initialize;
	begin
		Gd := EGA; Gm := EGAHI;
		InitGraph(Gd, Gm, '');
		if GraphResult <> grOk then
		begin
			clrscr;
			writeln('This program requires an EGA or Higher card,');
			writeln('Also Check that the file EGAVGA.BGI is present.');
			Halt(1);
		end;
		SetColor(Color);
		SetBkColor(BkColor);
		SetFillStyle(1,FillColor);
		MaxX := GetMaxX; MaxY := GetMaxY;
		CenterX := MaxX shr 1; CenterY := MaxY shr 1;
		page := 0;
	end;

	Procedure Action;
	begin
		TransformObject;
		page := page + 1;
		SetActivePage(page and 1);
		ClearDevice;
		DrawObject;
		SetVisualPage(page and 1);
	end;

	Procedure Help;
	const
		vp : ViewPortType =
			(x1: 65; y1: 80; x2: 555; y2: 305; Clip : ClipOn);
	var
		ch               : char;

  procedure WriteOut(S : string);
	begin
		OutTextXY(Col, Row, S);
		Inc(Row, height);
	end;

	begin
		page := page + 1;
		SetActivePage(page and 1);
		ClearDevice;
		DrawObject;

		with vp do
		begin
			SetFillStyle(1,RED); SetColor(WHITE);
			Bar(x1-1,y1-1,x2+1,y2+1);
			Rectangle(x1-1,y1-1,x2+1,y2+1);
			SetViewPort(x1, y1, x2, y2, ClipOn);
			height := TextHeight('M')+2;
			Col := 5; Row := 8;
			WriteOut('Help :- ');
			WriteOut('--------');
			Col := 10; Row := 38;
			WriteOut('SPACE : Toggle between Solid And WireFrame.');
			WriteOut('ENTER : Toggle between Perspective and Parallel Projection.');
			WriteOut('3,6,9 : Change LineColor, Fill Color, Background Color.');
			WriteOut(' +/-  : Enlarge/Reduce Size.');
			WriteOut(' 7/8  : Rotation around the Z-axis.');
			WriteOut(' 4/5  : Rotation around the Y-axis.');
			WriteOut(' 1/2  : Rotation around the X-axis.');
			WriteOut(' Q/W  : Translation along the Z-axis.');
			WriteOut(' A/S  : Translation along the Y-axis.');
			WriteOut(' Z/X  : Translation along the X-axis.');
			WriteOut(' 0/.  : Change Position of Projection Window (D).');
			Inc(Row,Height);
			WriteOut('  R   : Run Animation with current settings.');
			Inc(Row,Height);
			WriteOut(' ESC  : Return to Main Menu.');
			Inc(Row,2*Height);
			if (Parallel) then WriteOut('Current Mode = Parallel Projection.')
										else WriteOut('Current Mode = Perspective Projection.')
		end;
		SetVisualPage(page);
		ch := readkey;
		SetViewPort(0, 0, MaxX, MaxY, ClipOn);
		SetFillStyle(1,FillColor); SetColor(Color);
	end;

	Procedure Animate;
	var ch : char;
	begin
		Rotate(5,7,9);
		Translate(center[x],center[y],center[z]);
		AnimOFF := TRUE;  { Could be AnimOFF := FALSE;}
		repeat Action until Keypressed;
		AnimOFF := TRUE;
		ViewMat := I;
		Action;
		ch := readkey;
	end;

begin
	Initialize;
	ViewMat := I;
	Action;
	repeat
		ViewMat := I;
		flag := FALSE;
		GetCenter(center);
		Translate(-center[x],-center[y],-center[z]);
		ch := readkey;
		case ch of
			'+' : begin Scale(1.1,1.1,1.1); flag := TRUE; end;
			'-' : begin Scale(1/1.1,1/1.1,1/1.1); flag := TRUE; end;
			'7' : begin Rotate(0,0,5); flag := TRUE; end;
			'8' : begin Rotate(0,0,-5); flag := TRUE; end;
			'4' : begin Rotate(0,5,0); flag := TRUE; end;
			'5' : begin Rotate(0,-5,0); flag := TRUE; end;
			'1' : begin Rotate(5,0,0); flag := TRUE; end;
			'2' : begin Rotate(-5,0,0); flag := TRUE; end;
			'0' : begin D := D - 10; flag := TRUE; end;
			'.' : begin D := D + 10; flag := TRUE; end;
			'W','w' : begin Translate(0,0,10); flag := TRUE; end;
			'Q','q' : begin Translate(0,0,-10); flag := TRUE; end;
			'S','s' : begin Translate(0,10,0); flag := TRUE; end;
			'A','a' : begin Translate(0,-10,0); flag := TRUE; end;
			'X','x' : begin Translate(10,0,0); flag := TRUE; end;
			'Z','z' : begin Translate(-10,0,0); flag := TRUE; end;
			' '     : begin FillFlag := not FillFlag; flag := TRUE; end;
			chr(13) : begin Parallel := not Parallel; flag := TRUE; end;
			'H','h' : begin Help; flag := TRUE; end;
			'R','r' : begin Animate; end;
			'3'                     : begin Color := (Color+1) and 15; SetColor(Color); flag := TRUE; end;
			'6'                     : begin FillColor := (FillColor+1) and 15; SetFillStyle(1,FillColor); flag := TRUE; end;
			'9'                     : begin BkColor := (BkColor+1) and 15; SetBkColor(BkColor); end;
		end;
		if (flag) then
		begin
			Translate(center[x],center[y],center[z]);
			Action;
		end;
	until ( ch = chr(27) );
	RestoreCrtMode;
end;

Procedure Status;
var
	center  : Point3DType;
	ch      :       char;
begin
	DisplayHeader;
	writeln('Status :-');
	writeln('---------');
	writeln;
	writeln(' Depth of Perspective Projection plane (D) = ',D:6:2);
	writeln;
	GetCenter(center);
	writeln(' Depth of Object Center = ',center[z]:6:2);
	writeln;writeln;
	writeln('If you want to change the current Depth of the Perspective Projection plane');
	writeln('then press ''D'' ,  else press any other key to return to the Main Menu.');
	writeln;writeln;
	ch := readkey;
	if (ch = 'D') or (ch = 'd') then
	begin
		write('Enter New Depth of Perspective Projection Plane ''D'' = ');
		readln(D);
	end;
end;

Procedure Transform;
var
	a,b,c : real;
	dir             : word;
	ch              : char;
begin
	ViewMat := I;
	repeat
		DisplayHeader;
		writeln('Transformations Menu :-');
		writeln('-----------------------');
		writeln;
		writeln('Select option :- ');
		writeln;
		Writeln('   (1) Translation.');
		Writeln('   (2) Rotation.');
		Writeln('   (3) Scale.');
		Writeln('   (4) Shear.');
		Writeln('   (5) Display. ');
		Writeln('   (6) Back to Main Menu.');
		writeln;
		ch := readkey;
		case ch of
			'1' : begin
							write('Enter Displacement ( DeltaX  DeltaY  DeltaZ ) = ');
							readln(a,b,c);
							Translate(a,b,c);
						end;
			'2' : begin
							write('Enter Angle in degrees ( ThetaX  ThetaY  ThetaZ ) = ');
							readln(a,b,c);
							Rotate(a,b,c);
						end;
			'3' : begin
							write('Enter Scale ( ScaleX  ScaleY  ScaleZ ) = ');
							readln(a,b,c);
							Scale(a,b,c);
						end;
			'4' : begin
							write('Enter Shear axis ( 0=X or 1=Y or 2=Z ) = ');
							readln(dir);
							write('Enter Shear Values : ( a b )  = ');
							readln(a,b);
							Shear(dir,a,b);
						end;
			'5' : begin
							TransformObject;
							Display;
							ViewMat := I;
						end;
		end;
	until ( ch = '6') or ( ch = chr(27) );
	TransformObject;
end;

Procedure Setup;
begin
	ObjectExists := FALSE;
	Parallel := FALSE;
	FillFlag := FALSE;
	AnimOFF := TRUE;
	Color := WHITE;
	BkColor := BLACK;
	FillColor := BLUE;
end;


begin {main}
	Setup;
	repeat
		DisplayHeader;
		writeln('Main Menu :-');
		writeln('------------');
		writeln;
		writeln('Select option :- ');
		writeln;
		Writeln('   (1) Create Object.');
		Writeln('   (2) Load Object.');
		Writeln('   (3) Save Object.');
		Writeln('   (4) Status.');
		Writeln('   (5) Display Object.');
		Writeln('   (6) Transform Object.');
		Writeln;
		Writeln('   (ESC) Quit.');
		writeln;
		flag := FALSE;
		ch := readkey;
		case ch of
			'1' : InputObject;
			'2' : LoadObject;
			'3' : if( ObjectExists ) then SaveObject else flag := TRUE;
			'4' : if( ObjectExists ) then Status else flag := TRUE;
			'5' : if( ObjectExists ) then Display else flag := TRUE;
			'6' : if( ObjectExists ) then Transform else flag := TRUE;
		end;
		if (flag) then
		begin
			writeln('Try Loading or Creating an Object first.');
			writeln;
			writeln('Press any key to continue.');
			ch := readkey; ch := ' ';
		end;
	until ( ch = chr(27) );
end.
