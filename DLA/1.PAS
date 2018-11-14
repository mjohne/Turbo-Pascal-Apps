  CheckStickyPointAround := False;
  { Top left }
  IF GetPixel(X-1,Y-1) <> White THEN CheckStickyPointAround := True ELSE CheckStickyPointAround := False;
  { Top middle }
  IF GetPixel(X,Y-1) <> White THEN CheckStickyPointAround := True ELSE CheckStickyPointAround := False;
  { Top right }
  IF GetPixel(X+1,Y-1) <> White THEN CheckStickyPointAround := True ELSE CheckStickyPointAround := False;
  { Middle left }
  IF GetPixel(X-1,Y) <> White THEN CheckStickyPointAround := True ELSE CheckStickyPointAround := False;
  { Middle middle }
{  IF GetPixel(X,Y) <> White THEN CheckStickyPointAround := True ELSE CheckStickyPointAround := False;}
  { Middle right }
  IF GetPixel(X+1,Y) <> White THEN CheckStickyPointAround := True ELSE CheckStickyPointAround := False;
  { Down left }
  IF GetPixel(X-1,Y+1) <> White THEN CheckStickyPointAround := True ELSE CheckStickyPointAround := False;
  { Down middle }
  IF GetPixel(X,Y+1) <> White THEN CheckStickyPointAround := True ELSE CheckStickyPointAround := False;
  { Down Right }
  IF GetPixel(X+1,Y+1) <> White THEN CheckStickyPointAround := True ELSE CheckStickyPointAround := False;
