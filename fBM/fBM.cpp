#include <fstream>
#include <iostream>
#include <iomanip>
#include <math.h>
#include <stdlib.h>
#include <string>
#include <time.h>
//#include "console.h"


//CConsole console;

// ä = \x84
// ö = \x94
// ü = \x81

const long MaxRange = 4096;

long
  a,b,c,i,n,
  StartX,StartY,   // Startwerte im Feld
  MaxX,MaxY,       // Größe des Felds
  X,Y,             // Koordinaten
  Move,            // Bewegung
  LanscapeHP[MaxRange][MaxRange] = {0}; // Feld für die Höhenwerte

string LandscapeName;
//ofstream LandscapeFile;
//ofstream ScriptFile;


int main()
{
  srand((unsigned)time(NULL));
  std::cout << "Landscape Maker\n\n";
  std::cout << "Landscape Maker ist ein randomisierter, fraktaler Landschaftsgenerator. Diese\n";
  std::cout << "Programm erstellt ein zweidimensionales Feld, das ein komplettes H\x94henprofil\n";
  std::cout << "für eine definierte Fl\x84" << "che enth\x84lt. Diese Werte werden zur weiteren\n";
  std::cout << "Verarbeitung (z. B. visuelle Pr\x84sentation, 3D-Renderer) in einer Datei abge-\n";
  std::cout << "speichert.\n\n";
  std::cout << "Gr\x94sse der Landschaft\n";
  MaxX = MaxRange+1;
    while(MaxX > MaxRange)
  {
    std::cout << "   X-Achse (max. 4096): "; std::cin >> MaxX;
    if(MaxX > MaxRange) std::cout << "   X ist leider gr\x94sser als 4096!!!\n";
  }
  MaxY = MaxRange+1;
  while(MaxY > MaxRange)
  {
    std::cout << "   Y-Achse (max. 4096): "; std::cin >> MaxY;
    if(MaxY > MaxRange) std::cout << "   Y ist leider gr\x94sser als 4096!!!\n";
  }
  // Startwerte können später selbst bestimmt werden
  StartX = (rand() % MaxX)+1; StartY = (rand() % MaxY)+1;

  n = 1;

  while(n <= MaxRange)
  {
    Move = (rand() % 10)+1;
    switch(Move)
    {
      case 1 : { X--; Y++; break; }
      case 2 : { Y++; break; }
      case 3 : { X++; Y++; break; }
      case 4 : { X--; break; }
      case 6 : { X++; break; }
      case 7 : { X--; Y--; break; }
      case 8 : { Y--; break; }
      case 9 : { X++; Y--; break; }
    }
    if(X < 1) X = X+MaxX;
    if(Y < 1) Y = Y+MaxY;
    if(X > MaxX) X = X-MaxX;
    if(Y > MaxY) Y = Y-MaxY;
    if(Move != 0) LanscapeHP[X][Y]++;
    n++;

    std::cout << n << "\n";

    /*FOR a := 1 TO MaxX DO BEGIN
      {GotoXY(5,4+a);}
      FOR b := 1 TO MaxY DO BEGIN
        {TextColor(Matrix[a][b] MOD 16);
        Write(Matrix[a][b]:3);}
        PutPixel(a,b,Matrix[a][b]);
      END;
      {WriteLn;}
    END;*/
  }
  LandscapeName = "test.txt";
  //LandscapeFile.open(LandscapeName.c_str(),ios::binary | ios::out);


  return EXIT_SUCCESS;
}
