PROGRAM DLA;

USES Crt,Dos,Graph;

CONST DLA_Color = White;

VAR
  Track          : Boolean;
  Cluster,
  Distance       : Word;
  Size           : Byte;
  GraphicDriver,
  GraphicMode    : Integer;

PROCEDURE SetStickyPoint(X,Y : Word; Size,Color : Byte);
BEGIN
  SetFillStyle(1,Color);
  PieSlice(X,Y,0,360,Size);
  {Circle(X,Y,3);}
  {PutPixel(X,Y,Color);}
END;

FUNCTION CheckStickyPointAround(X,Y : Word; Color : Byte) : Boolean;
VAR n : Integer;
BEGIN
  CheckStickyPointAround := True;
  { Top left }
  IF GetPixel(X-1,Y-1) <> White THEN n := 7;
  { Top middle }
  IF GetPixel(X,Y-1) <> White THEN n := 8;
  { Top right }
  IF GetPixel(X+1,Y-1) <> White THEN n := 9;
  { Middle left }
  IF GetPixel(X-1,Y) <> White THEN n := 4;
  { Middle middle }
  {IF GetPixel(X,Y) <> White THEN n := 5;}
  { Middle right }
  IF GetPixel(X+1,Y) <> White THEN n := 6;
  { Down left }
  IF GetPixel(X-1,Y+1) <> White THEN n := 1;
  { Down middle }
  IF GetPixel(X,Y+1) <> White THEN n := 2;
  { Down Right }
  IF GetPixel(X+1,Y+1) <> White THEN n := 3;
  CASE n OF
    4,6 : CheckStickyPointAround := False;
    ELSE CheckStickyPointAround := True;
  END;
END;

PROCEDURE Generate_DLA_Cluster(NumberOfClusters : Word; StickyPointSize : Byte; VisitorPoitDistance : Word;
  VisitorTrack : Boolean; DLA_Color : Byte);
VAR
  DirectionFromPrimitive,
  DirectionFromPrimitive2   : Byte;
  NoStickyPointSurroundings : Boolean;
  DirectionFromX,
  DirectionFromY,
  Numerator                 : Word;
BEGIN
  FOR Numerator := 1 TO NumberOfClusters DO SetStickyPoint(Random(GetMaxX),Random(GetMaxY),StickyPointSize,DLA_Color);
  REPEAT

    DirectionFromX := Random(GetMaxX);
    DirectionFromY := Random(GetMaxY);{GetMaxY}

    REPEAT
      NoStickyPointSurroundings := CheckStickyPointAround(DirectionFromX,DirectionFromY,DLA_Color);
      IF NoStickyPointSurroundings = True THEN BEGIN

        DirectionFromPrimitive2 := Random(4);
        CASE DirectionFromPrimitive2 OF
          { Top }
          0 : BEGIN
            DirectionFromX := DirectionFromX+0;
            DirectionFromY := DirectionFromY-VisitorPoitDistance;
          END;
          { Left }
          1 : BEGIN
            DirectionFromX := DirectionFromX-VisitorPoitDistance;
            DirectionFromY := DirectionFromY+0;
          END;
          { Right }
           2 : BEGIN
            DirectionFromX := DirectionFromX+VisitorPoitDistance;
            DirectionFromY := DirectionFromY+0;
          END;
          { Bottom }
          3 : BEGIN
            DirectionFromX := DirectionFromX+0;
            DirectionFromY := DirectionFromY+VisitorPoitDistance;
          END;
        END;
        IF DirectionFromX < 0 THEN DirectionFromX := 0;
        IF DirectionFromX > GetMaxX THEN DirectionFromX := GetMaxX;
        IF DirectionFromY < 0 THEN DirectionFromY := 0;
        IF DirectionFromY > GetMaxY THEN DirectionFromY := GetMaxY;
      END;
      IF VisitorTrack THEN PutPixel(DirectionFromX,DirectionFromY,Red);
    UNTIL ((KeyPressed) OR (NoStickyPointSurroundings = False));
    SetStickyPoint(DirectionFromX,DirectionFromY,StickyPointSize,White);

  UNTIL KeyPressed;
END;

BEGIN
  Randomize;
  Cluster := 20;
  Size := 3;
  Distance := 5;
  Track := True;
  GraphicDriver := Detect;
  GraphicMode   := Detect;
  InitGraph(GraphicDriver,GraphicMode,'');

  Generate_DLA_Cluster(Cluster,Size,Distance,Track,DLA_Color);

  CloseGraph;
END.