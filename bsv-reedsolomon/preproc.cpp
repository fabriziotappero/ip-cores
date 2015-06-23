//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2008 Abhinav Agarwal, Alfred Man Cheuk Ng
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
#include <list>
#include <string>
#include <regex.h>
using namespace std;

#define mm  8
#define nn  255

int pp [mm + 1];
int alpha_to [255 + 2];
int index_of [255 + 2];

// --------------------------------------------------------------------
void generate_gf (int* pp)
{
   int mask = 1;

   alpha_to [mm] = 0 ;
   for (int i = 0; i < mm; ++ i)
   {  
      alpha_to [i] = mask;
      index_of [alpha_to [i]] = i;
      if (0 != pp [i])
         alpha_to[mm] ^= mask;
      mask <<= 1;
   }
   index_of [alpha_to [mm]] = mm;
   mask >>= 1;
   for (int i = mm + 1; i < nn; ++ i)
   { 
      if (alpha_to [i - 1] >= mask)
         alpha_to [i] = alpha_to [mm] ^ ((alpha_to [i - 1] ^ mask) << 1);
      else 
         alpha_to [i] = alpha_to [i - 1] << 1;
      index_of [alpha_to [i]] = i;
   }
   index_of [0] = -1;
}


// --------------------------------------------------------------------
unsigned char gfinv_lut (unsigned char a)
{
   unsigned char result = (nn - index_of [a]) % nn;
   return alpha_to[result];
}


// --------------------------------------------------------------------
void print (string& rLine)
{
   string sLine (rLine);
   string::size_type iLength = sLine.length ();
   for (string::size_type i = 0; i < iLength; ++ i)
      if ('\t' == sLine.at (i))
         sLine [i] = ' ';

   string::size_type iStart = sLine.find ("  ");
   while (string::npos != iStart)
   {
      string::size_type iEnd = iStart + 1;
      while ((iEnd < iLength) && (' ' == sLine.at (iEnd)))
         ++ iEnd;

      sLine.replace (iStart, iEnd - iStart, " ");
      iLength = sLine.length ();
      iStart = sLine.find ("  ");
   }
   if (' ' == sLine.at (0))
      sLine = sLine.substr (1);
   cout << sLine << endl;
}

// --------------------------------------------------------------------
int main (int argc, char* argv [])
{
   ifstream file;
   file.open (argv [1]);
   if (false == file.is_open ())
   {
      cerr << "Failed to open file '" << argv [1] << "'. Quitting." << endl;
      return 1;
   }
   cout << endl;

   string sPolynomial;

   list <string>   lstPotentialPolyDefs;
   //   while (false == file.eof ())
   //{
      char zLine [1000];
      file.getline (zLine, 1000);
      string sLine (zLine);
      if (0 != strstr (zLine, "Polynomial "))
      {
         // we've found a line that may have the primitive  
         // polynomial defined in it. Now we need to read   
         // till the end of the line (till a ;) and store   
         // all that for later...                           
         while (0 != strchr (zLine, ';'))
         {
            file.getline (zLine, 1000);
            sLine += zLine;
         }
         lstPotentialPolyDefs.push_back (sLine);
      }
//       else if (0 != strstr (zLine, "IReedSolomon "))
//       {
//          // we've found the line where the ReedSolomon      
//          // decoder is instantiated. The primitive          
//          // polynomial will be used here. We can use this   
//          // to extract it...                                
//          string sLine (zLine);
// 	 while (0 == strchr (zLine, ';'))
//          {
//             file.getline (zLine, 1000);
//             sLine += zLine;
//          }
//          cout << "Line with ReedSolomon decoder instantiation." << endl;
//          cout << endl << "\t";
//          print (sLine);
//          cout << endl;
//          // check that we have the correct line...          
//          if ((string::npos == sLine.find ("<-")) ||
//              (string::npos == sLine.find ("mkReedSolomon")))
//          {
//             cout << "Got the wrong line! Can't continue." << endl;
//             return 1;
//          }

//          // extract the polynomial used in the              
//          // mkReedSolomon line...                           
//          string::size_type iStart = sLine.find ("(");
//          string::size_type iEnd = sLine.rfind (")");
//          string sPolynomialVariable = sLine.substr (iStart + 1, iEnd - iStart - 1);

//          // check if the polynomial has been defined        
//          // in-place...                                     
//          regex_t regexp;
//          string sPattern = "[0-9]'[bdohBDOH][0-9]*";
//          int ret = regcomp (&regexp, sPattern.c_str (), REG_EXTENDED);
//          if (0 != ret)
//          {
//             char zError [1000];
//             regerror (ret, &regexp, zError, 1000);
//             cerr << "Regular expression " << sPattern 
//                  << " failed to compile. Error : " << zError << endl;
//             return 1;
//          }
//          if (0 == regexec (&regexp, sPolynomialVariable.c_str (), 0, NULL, 0))
//          {
//             // we have an in-line definition of the poly... 
//             sPolynomial = sPolynomialVariable;
//             cout << "Primitive polynomial found inline." << endl;
//             cout << "polynomial : " << sPolynomial << endl;
//             break;
//          }
//          else
//          {
            // we need to search through the lines we       
            // previously saved to find the location where  
            // the polynomial was defined...                
            cout << endl;
            cout << "ReedSolomon instantiation uses a polynomial declared elsewhere."
                 << endl << "Searching for the declaration." << endl << endl;

            bool bPolynomialFound = false;
            list <string>::iterator ite;
            for (ite = lstPotentialPolyDefs.begin ();
                ite != lstPotentialPolyDefs.end ();
                ++ ite)
            {
               string& rLine = *ite;
               cout << "\t";
               print (rLine);
               cout << endl;
//                if (string::npos != sLine.find ("primitive_polynomial"))
//                {
                  string::size_type iStart = rLine.find ("=");
                  string::size_type iEnd = rLine.rfind (";");
                  ++ iStart;
                  while (rLine.at (iStart) == ' ')
                     ++ iStart;

                  sPolynomial = rLine.substr (iStart, iEnd - iStart);
                  cout << endl;
                  cout << "Primitive polynomial found as a separate declaration." << endl;
                  cout << "polynomial : " << sPolynomial << endl;
                  bPolynomialFound = true;
                  break;
		  //               }
            }
            if (false == bPolynomialFound)
            {
               cerr << "Failed to find polynomial as a separate declaration, " << endl
                    << "and polynomial is not present inline. Cannot continue." << endl;
               return 1;
            }
	    //         }
	    //      }
	    //}


   // process extracted polynomial...           

   if (string::npos == sPolynomial.find ("b"))
   {
      cerr << "Currently only polynomials declared in the binary format are supported." 
           << "Quitting. " << endl;
      return 1;
   }
   int iLength = sPolynomial.length ();
   int j = 0;
   for (int i = iLength - 1; i > 2; -- i)
      pp [j++] = ('1' == sPolynomial.at (i))? 1 : 0;
   // The MSB of the primitive polynomial is always 1.
   // This bit is not included in the polynomial      
   // declared in mkReedSolomon.                      
   pp [j] = 1;

   generate_gf (pp);


   // generate the BlueSpec file with gf_inv... 
   cout << "Generating BlueSpec file with Galois field inversion code..." << endl;
   ofstream ofsGenerated (argv [2]);
   if (false == ofsGenerated.is_open ())
   {
      cerr << "Failed to open file '" << argv [2] << "' for writing. Quitting." << endl;
      return 1;
   }

//   ofsGenerated << "import GFTypes::*;" << endl;
//   ofsGenerated << endl << endl;
   ofsGenerated << "// ---------------------------------------------------------" << endl;
   ofsGenerated << "function Byte gf_inv (Byte a);" << endl;
   ofsGenerated << endl;
   ofsGenerated << "   case (a) matches" << endl;

   for (int i = 0; i < 256; ++ i)
   {
      unsigned char inv = gfinv_lut ((unsigned char) i);
      ofsGenerated << "        " << i << " : return " << (int) inv << ";" << endl;
   }

   ofsGenerated << "   endcase" << endl;
   ofsGenerated << "endfunction" << endl;
   ofsGenerated << endl;
   cout << "Done." << endl << endl;
}






