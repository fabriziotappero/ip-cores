//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2010 Abhinav Agarwal, Alfred Man Cheuk Ng
// Contact: abhiag@gmail.com
// 
// Permission is hereby granted, free of charge, to any person 
// obtaining a copy of this software and associated documentation 
// files (the "Software"), to deal in the Software without 
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------//

#include <iostream>
#include <fstream>
using namespace std;


extern "C"
{
   void loadByteStream (void);
   char getNextStreamByte (void);
   void storeByteStream (void);
   void putNextStreamByte (unsigned char byte);
   void putMACData (unsigned char n, unsigned char t);
   unsigned char isStreamActive (void);
   void closeOutputFile ();
}


ifstream ifs_Input;
ofstream ofs_Output;


//---------------------------------------------------------------------
void loadByteStream (void)
{
   cout << "  reading from file '" << DATA_FILE_PATH << "'" << endl;
   ifs_Input.open (DATA_FILE_PATH);
   if (false == ifs_Input.is_open ())
      cout << "[ERROR]  failed to open input file." << endl;
}


//---------------------------------------------------------------------
char getNextStreamByte (void)
{
   int byte;
   ifs_Input >> byte;

   if (true == ifs_Input.eof ())
      cout << "  end of file reached." << endl;

   return (unsigned char) byte;
}


//---------------------------------------------------------------------
void storeByteStream (void)
{
   cout << "  writing to file '" << OUT_DATA_FILE_PATH << "'" << endl;
   ofs_Output.open (OUT_DATA_FILE_PATH);
   if (false == ofs_Output.is_open ())
      cout << "[ERROR]  failed to open output file." << endl;
}


//---------------------------------------------------------------------
void putNextStreamByte (unsigned char byte)
{
   ofs_Output << (int) byte << endl;
}


//---------------------------------------------------------------------
void putMACData (unsigned char n, unsigned char t)
{
   ofs_Output << (int) n << ' ' << (int)t << endl;
}


//---------------------------------------------------------------------
unsigned char isStreamActive (void)
{
   return ((true == ifs_Input.is_open ()) && (false == ifs_Input.eof ()));
}


//---------------------------------------------------------------------
void closeOutputFile ()
{
   ofs_Output.flush ();
   ofs_Output.close ();
}
