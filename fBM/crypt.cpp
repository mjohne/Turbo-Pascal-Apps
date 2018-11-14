#include <fstream>
#include <iostream>
#include <iomanip>
#include <math.h>
#include <stdlib.h>
#include <string>
#include <time.h>
#include "console.h"

using namespace std;

const int
  nnBlack       = 0,  // Bezeichner für Textfarben
  nBlue         = 1,  // der Hintergrund wird schwarz gehalten
  nGreen        = 2,
  nCyan         = 3,
  nRed          = 4,
  nMagenta      = 5,
  nBrown        = 6,
  nLightGrey    = 7,
  nDarkGrey     = 8,
  nLightBlue    = 9,
  nLightGreen   = 10,
  nLightCyan    = 11,
  nLightRed     = 12,
  nLightMagenta = 13,
  nYellow       = 14,
  nWhite        = 15;

char ch,ch2;
unsigned int FS,KeyCsr,i,n,CryptAlg,CryptMode,CryptWhat;
CConsole console;
ifstream IFile;
ifstream KIFile;
ofstream KOFile;
ofstream OFile;
string Plaintext,KeyVig,KeyOTP,CipherTextCsr,CipherTextVig,CipherTextOTP,
  IFileName,OFileName,KFileName;

void Error(int);
void OpenIFile();
void OpenOFile();
void OpenKIFile();
void OpenKOFile();
char Rng();
void CaesarAlg();
void VigenereAlg();
void OTPAlg();

int main()
{
  srand((unsigned)time(NULL));
  console.Box(0,0,79,23);  // "Fenster"-Kasten
  console.Box(1,1,78,3);   // oberer Kasten
  console.Box(1,4,39,15);  // linker Kasten
  console.Box(40,4,78,15); // rechter Kasten
  console.Box(1,16,78,22); // unterer Kasten
  console.SetTextAttribute(nLightCyan);
  console.GotoXY(20,2); cout << "CRYPT - (c) Michael Johne 2006 v1.0";
  console.SetTextAttribute(nYellow);
  console.GotoXY(43,6); cout << "Algorithmus  :";
  console.GotoXY(43,7); cout << "Modus        :";
  console.GotoXY(43,8); cout << "Verarbeitung :";
  console.GotoXY(3,6); cout << "Verschl\x81sselungsalgorithmus?";
  console.GotoXY(6,7); cout << "1.  C\x84sar";
  console.GotoXY(6,8); cout << "2.  Vigen\x8are";
  console.GotoXY(6,9); cout << "3.  One Time Pad";
  CryptAlg = 0;
  while(CryptAlg < 1 || CryptAlg > 3)
  {
    console.GotoXY(26,11); cout << "             ";
    console.SetTextAttribute(nYellow);
    console.GotoXY(3,11); cout << "Eingabe (Ziffern 1-3): ";
    console.SetTextAttribute(nWhite);
    cin >> CryptAlg; cin.get(); // CR abfangen
    if (CryptAlg < 1 || CryptAlg > 3) {Error(5);}
  }
  console.GotoXY(58,6);
  switch(CryptAlg)
  {
    case 1 : {cout << "C\x84sar"; break;}
    case 2 : {cout << "Vigen\x8are"; break;}
    case 3 : {cout << "One Time Pad"; break;}
    default : {cout << "nicht definiert"; break;}
  }
  console.ClrBox(1,4,39,15); console.SetTextAttribute(nYellow);
  console.GotoXY(3,6); cout << "Ver- | Entschl\x81sseln?";
  console.GotoXY(6,7); cout << "1.  verschl\x81sseln";
  console.GotoXY(6,8); cout << "2.  entschl\x81sseln";
  console.GotoXY(6,9); cout << "Eingabe (Ziffern 1-2): ";
  CryptMode = 0;
  while(CryptMode < 1 || CryptMode > 2)
  {
    console.GotoXY(26,11); cout << "             ";
    console.SetTextAttribute(nYellow);
    console.GotoXY(3,11); cout << "Eingabe (Ziffern 1-2): ";
    console.SetTextAttribute(nWhite);
    cin >> CryptMode; cin.get(); // CR abfangen
    if (CryptMode < 1 || CryptMode > 2) {Error(5);}
  }
  console.GotoXY(58,7);
  switch(CryptMode)
  {
    case 1 : {cout << "Verschl\x81sseln"; break;}
    case 2 : {cout << "Entschl\x81sseln"; break;}
    default : {cout << "nicht definiert"; break;}
  }
  console.ClrBox(1,4,39,15); console.SetTextAttribute(nYellow);
  console.GotoXY(3,6); cout << "String-Eingabe oder Datei";
  console.GotoXY(6,7); cout << "1.  String-Eingabe\n";
  console.GotoXY(6,8); cout << "2.  Datei\n";
  console.GotoXY(6,9); cout << "Eingabe (Ziffern 1-2): ";
  CryptWhat = 0;
  while(CryptWhat < 1 || CryptWhat > 2)
  {
    console.GotoXY(27,11); cout << "          ";
    console.SetTextAttribute(nYellow);
    console.GotoXY(3,11); cout << "Eingabe (Ziffern 1-2): ";
    console.SetTextAttribute(nWhite);
    cin >> CryptWhat; cin.get(); // CR abfangen
    if (CryptWhat < 1 || CryptWhat > 2) {Error(5);}
  }
  console.GotoXY(58,8);
  switch(CryptWhat)
  {
    case 1 : {cout << "direkte Eingabe"; break;}
    case 2 : {cout << "Datei-Verarbeitung"; break;}
    default : {cout << "nicht definiert"; break;}
  }
  switch(CryptAlg)
  {
    case 1 : {CaesarAlg(); break;}
    case 2 : {VigenereAlg(); break;}
    case 3 : {OTPAlg(); break;}
  }
  cout << "   "; system("PAUSE"); return EXIT_SUCCESS;
}

void Error(int ErrCode)
{
  console.ClrBox(1,16,78,22);
  console.GotoXY(3,18);
  console.SetTextAttribute(nLightRed);
  switch(ErrCode)
  {
    case 1 :
    {
      cerr << "Quelldatei kann nicht ge\x94" << "ffnet werden!";
      console.GotoXY(3,19); console.SetTextAttribute(nLightGrey);
      system("pause"); exit(-1); break;
    }
    case 2 :
    {
      cerr << "Zieldatei kann nicht ge\x94" << "ffnet werden!";
      console.GotoXY(3,19); console.SetTextAttribute(nLightGrey);
      system("pause"); exit(-1); break;
    }
    case 3 :
    {
      cerr << "Schl\x81sseldatei kann nicht ge\x94" << "ffnet werden!";
      console.GotoXY(3,19); console.SetTextAttribute(nLightGrey);
      system("pause"); exit(-1); break;
    }
    case 4 :
    {
      cerr << "Die L\x84nge des Schl\x81ssels stimmt nicht mit der L\x84nge des"
        << " verschl\x81sselten";
      console.GotoXY(3,19);
      cerr << "Texts \x81" << "berein!!!";
      console.GotoXY(3,20); console.SetTextAttribute(nLightGrey);
      system("pause"); exit(-1); break;
    }
    case 5 :
    {
      cerr << "Falsche Eingabe!!!"; break;
    }
    default :
    {
      cerr << "Unbekannter Fehler!!!"; break;
      console.GotoXY(3,19); console.SetTextAttribute(nLightGrey);
      system("pause"); exit(-1); break;
    }
  }
  console.GotoXY(3,19); console.SetTextAttribute(nLightGrey);
  system("pause"); console.ClrBox(1,16,78,22);
}

void OpenIFile()
{
  console.SetTextAttribute(nLightCyan);
  cout << "Name der Datei zum ";
  if (CryptWhat == 1) cout << "Ver";
    else if (CryptWhat == 2) cout << "Ent";
  cout << "schl\x81sseln: ";
  console.SetTextAttribute(nWhite);
  getline(cin,IFileName);
  IFile.open(IFileName.c_str(),ios::binary | ios::in);
  if (!IFile) {Error(1);}
}

void OpenOFile()
{
  console.SetTextAttribute(nLightCyan);
  cout << "Name der Ausgabedatei: ";
  console.SetTextAttribute(nWhite);
  getline(cin,OFileName);
  OFile.open(OFileName.c_str(),ios::binary | ios::out);
  if (!OFile) {Error(2);}
}

void OpenKIFile()
{
  console.SetTextAttribute(nLightCyan);
  cout << "Name der Schl\x81sseldatei: ";
  console.SetTextAttribute(nWhite);
  getline(cin,KFileName);
  KIFile.open(KFileName.c_str(),ios::binary | ios::out);
  if (!KIFile) {Error(3);}
}

void OpenKOFile()
{
  console.SetTextAttribute(nLightCyan);
  cout << "Name der Schl\x81sseldatei: ";
  console.SetTextAttribute(nWhite);
  getline(cin,KFileName);
  KOFile.open(KFileName.c_str(),ios::binary | ios::out);
  if (!KOFile) {Error(3);}
}

char Rng()
{
  return char(((rand() % 256)+1)-((rand() % 256)+1)+((rand() % 256)+1)*((rand()
    % 256)+1) ^ ((rand() % 256)+1) & ((rand() % 256)+1));
}

void CaesarAlg()
{
  if(CryptMode == 1)
  {
    if (CryptWhat == 1)
    {
      console.GotoXY(3,18);
      console.SetTextAttribute(nLightCyan);
      cout << "Eingabe des Klartexts: ";
      console.SetTextAttribute(nWhite);
      getline(cin,Plaintext);
      CipherTextCsr = Plaintext;
      console.GotoXY(3,19);
    } if (CryptWhat == 2) {
      console.GotoXY(3,18); OpenIFile();
      console.GotoXY(3,19); OpenOFile();
      console.GotoXY(3,20);
    }
    console.SetTextAttribute(nLightCyan);
    cout << "C\x84sar-Verschiebung: ";
    console.SetTextAttribute(nWhite);
    cin >> KeyCsr; cin.get(); // CR abfangen
    if (CryptWhat == 1)
    {
      for (i = 0; i <= CipherTextCsr.length(); i++)
      {
        CipherTextCsr[i] = char(int(CipherTextCsr[i])+KeyCsr);
      }
      console.GotoXY(3,20); console.SetTextAttribute(nLightGreen);
      cout << "Ciphertext: ";
      console.SetTextAttribute(nWhite); cout << CipherTextCsr;
    } else if (CryptWhat == 2) {
      while(IFile.get(ch))
      {
        OFile.put(char(int(ch)+KeyCsr));
      }
      IFile.close(); IFile.clear();
      OFile.close(); OFile.clear();
    }
  } else if(CryptMode == 2) {
    if (CryptWhat == 1)
    {
      console.GotoXY(3,18); console.SetTextAttribute(nLightCyan);
      cout << "Eingabe des Ciphertexts: ";
      console.SetTextAttribute(nWhite); getline(cin,CipherTextCsr);
      Plaintext = CipherTextCsr;
      console.GotoXY(3,19);
    } else if (CryptWhat == 2) {
      console.GotoXY(3,19); OpenIFile();
      console.GotoXY(3,19); OpenOFile();
      console.GotoXY(3,20);
    }
    console.SetTextAttribute(nLightCyan);
    cout << "C\x84sar-Verschiebung: ";
    console.SetTextAttribute(nWhite);
    cin >> KeyCsr; cin.get(); // CR abfangen
    if (CryptWhat == 1)
    {
      for (i = 0; i <= Plaintext.length(); i++)
      {
        Plaintext[i] = char(int(Plaintext[i])-KeyCsr);
      }
      console.GotoXY(3,20); console.SetTextAttribute(nLightGreen);
      cout << "Klartext: ";
      console.SetTextAttribute(nWhite); cout << Plaintext;
    } else if (CryptWhat == 2) {
      while(IFile.get(ch))
      {
        OFile.put(char(int(ch)-KeyCsr));
      }
      IFile.close(); IFile.clear();
      OFile.close(); OFile.clear();
    }
  }
}

void VigenereAlg()
{
  if(CryptMode == 1)
  {
    if (CryptWhat == 1)
    {
      console.GotoXY(3,18); console.SetTextAttribute(nLightCyan);
      cout << "Eingabe des Klartexts: ";
      console.SetTextAttribute(nWhite); getline(cin,Plaintext);
      CipherTextVig = Plaintext;
      console.GotoXY(3,19);
    } else if (CryptWhat == 2) {
      console.GotoXY(3,18); OpenIFile();
      console.GotoXY(3,19); OpenOFile();
      console.GotoXY(3,20);
    }
    console.SetTextAttribute(nLightCyan);
    cout << "Vigen\x8are-Verschl\x81sselungsphrase: ";
    console.SetTextAttribute(nWhite); getline(cin,KeyVig);
    if (CryptWhat == 1)
    {
      n = 0;
      for (i = 0; i <= CipherTextVig.length(); i++)
      {
        CipherTextVig[i] = char(int(CipherTextVig[i])+int(KeyVig[n]));
        if (n = KeyVig.length()) n = 0; else n++;
      }
      console.GotoXY(3,20); console.SetTextAttribute(nLightGreen);
      cout << "Ciphertext: ";
      console.SetTextAttribute(nWhite); cout << CipherTextVig;
    } if (CryptWhat == 2) {
      n = 0;
      while(IFile.get(ch))
      {
        OFile.put(char(int(ch)+int(KeyVig[n])));
        if (n = KeyVig.length()) n = 0; else n++;
      }
      IFile.close(); IFile.clear();
      OFile.close(); OFile.clear();
    }
  } else if(CryptMode == 2) {
    if (CryptWhat == 1)
    {
      console.GotoXY(3,18);console.SetTextAttribute(nLightCyan);
      cout << "Eingabe des Ciphertexts: ";
      console.SetTextAttribute(nWhite); getline(cin,CipherTextVig);
      Plaintext = CipherTextVig;
      console.GotoXY(3,19);
    } if (CryptWhat == 2) {
      console.GotoXY(3,18); OpenIFile();
      console.GotoXY(3,19); OpenOFile();
      console.GotoXY(3,20);
    }
    console.SetTextAttribute(nLightCyan);
    cout << "Vigen\x8are-Verschl\x81sselungsphrase: ";
    console.SetTextAttribute(nWhite); getline(cin,KeyVig);
    if (CryptWhat == 1)
    {
      n = 0;
      for (i = 0; i <= Plaintext.length(); i++)
      {
        Plaintext[i] = char(int(Plaintext[i])-int(KeyVig[n]));
        if (n = KeyVig.length()) n = 0; else n++;
      }
      console.GotoXY(3,20); console.SetTextAttribute(nLightGreen);
      cout << "Klartext: ";
      console.SetTextAttribute(nLightGreen); cout << Plaintext;
    } if (CryptWhat == 2) {
      n = 0;
      while(IFile.get(ch))
      {
        OFile.put(char(int(ch)-int(KeyVig[n])));
        if (n = KeyVig.length()) n = 0; else n++;
      }
      IFile.close(); IFile.clear();
      OFile.close(); OFile.clear();
    }
  }
}

void OTPAlg()
{
  if(CryptMode == 1)
  {
    if (CryptWhat == 1)
    {
      console.GotoXY(3,17); console.SetTextAttribute(nLightCyan);
      cout << "Eingabe des Klartexts: ";
      console.SetTextAttribute(nWhite); getline(cin,Plaintext);
      CipherTextOTP = Plaintext;
      KeyOTP = CipherTextOTP;
      console.GotoXY(3,18);
    } else if (CryptWhat == 2) {
      console.GotoXY(3,17); OpenIFile();
      FS = 0;
      while(IFile.get(ch)) {FS++;} //Get FS
      IFile.close(); IFile.clear();
      IFile.open(IFileName.c_str(),ios::binary | ios::in);
      console.GotoXY(3,18); OpenOFile();
      console.GotoXY(3,19);
    }
    console.SetTextAttribute(nLightCyan);
    cout << "Erzeuge OTP-Schl\x81ssel... ";
    if (CryptWhat == 1)
    {
      console.SetTextAttribute(nWhite);
      for (i = 0; i <= CipherTextOTP.length(); i++)
      {
        KeyOTP[i] = Rng();
        cout << KeyOTP[i];
        CipherTextOTP[i] = char(int(CipherTextOTP[i])+int(KeyOTP[i]));
      }
      console.GotoXY(3,19); console.SetTextAttribute(nLightGreen);
      cout << "Ciphertext: ";
      console.SetTextAttribute(nWhite); cout << CipherTextOTP;
    } else if (CryptWhat == 2) {
      console.GotoXY(3,20); OpenKOFile();
      for (i = 0; i <= FS; i++)
      {
        KOFile.put(Rng());
      }
      KOFile.close(); KOFile.clear();
      KIFile.open(KFileName.c_str(),ios::binary | ios::out);
      while(IFile.get(ch))
      {
        KIFile.get(ch2);
        OFile.put(char(int(ch)+int(ch2)));
      }
      IFile.close(); IFile.clear();
      OFile.close(); OFile.clear();
      KIFile.close(); KIFile.clear();
    }
  } else if(CryptMode == 2) {
    if (CryptWhat == 1)
    {
      console.GotoXY(3,17); console.SetTextAttribute(nLightCyan);
      cout << "Eingabe des Ciphertexts: ";
      console.SetTextAttribute(nWhite); getline(cin,CipherTextOTP);
      Plaintext = CipherTextOTP;
      console.GotoXY(3,18); console.SetTextAttribute(nLightCyan);
      cout << "Eingabe des OTP-Schlüssels: ";
      console.SetTextAttribute(nWhite); getline(cin,KeyOTP);
      if (Plaintext.length() != KeyOTP.length())
      {
        Error(4);
      } else {
        for (i = 0; i <= Plaintext.length(); i++)
        {
          KeyOTP[i] = char((rand() % 256)+1);
          cout << KeyOTP[i];
          Plaintext[i] = char(int(Plaintext[i])-int(KeyOTP[i]));
        }
        console.GotoXY(3,19); console.SetTextAttribute(nLightGreen);
        cout << "Klartext: ";
        console.SetTextAttribute(nRed); cout << Plaintext;
      }
    } else if (CryptWhat == 2) {
      console.GotoXY(3,17); OpenIFile();
      console.GotoXY(3,18); OpenOFile();
      console.GotoXY(3,19); OpenKIFile();
      while(IFile.get(ch))
      {
        KIFile.get(ch2);
        OFile.put(char(int(ch)-int(ch2)));
      }
      IFile.close(); IFile.clear();
      OFile.close(); OFile.clear();
      KIFile.close(); KIFile.clear();
    }
  }
}
