#include <fstream>
#include <iostream>
#include <iomanip>
#include <math.h>
#include <stdlib.h>
#include <string>
#include <time.h>

using namespace std;

char ch,ch2;
unsigned int i,n,Characters[256] = {0}, Letters[26],MaxChars = 0;

ifstream IFile;
ofstream StatisticsFile;

string IFilename, StatisticsFilename;


int main()
{
  for (i = 1; i <= 26; i++)
  {
    Letters[i] = 0;
  }
  for (i = 1; i <= 256; i++)
  {
    Characters[i];
  }
  cout << "Datei zum Einlesen: ";
  getline(cin,IFilename);
  IFile.open(IFilename.c_str(),ios::binary | ios::in);
  if (!IFile) cout << "\nDatei nicht gefunden!!!\n";
  StatisticsFilename = "stat.txt";
  StatisticsFile.open(StatisticsFilename.c_str(),ios::out);
  if (!StatisticsFile) cout << "\nDatei nicht ausgegeben!!!\n";

  while(IFile.get(ch))
  {
    //StatisticsFile.put(ch);
    MaxChars++;
    if (ch >= 'a' && ch <= 'z')
    {
      n = int(ch)-96;
      Letters[n]++;
    }
  }
  
  for (i = 1; i <= 26; i++)
  {
    cout << char(i+96) << " (" << int(i+96) << ") " << Letters[i] << " " << MaxChars/Letters[i] << "%\n";
  }
  
  IFile.close(); IFile.clear();
  StatisticsFile.close(); StatisticsFile.clear();
  cout << "\n\n" << MaxChars; system("pause"); return 0;
}
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz