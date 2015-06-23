//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2008 Kermin Fleming, kfleming@mit.edu 
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
// The following are magic, externally defined parameters in MD6
// Other important parameters are derived from them.
// These parameters are used at a global level


`ifdef BIT64
typedef 16   MD6_c;
typedef 512  MD6_d; // Bits in final hashvalue
typedef 64   MD6_b;
typedef 178  MD6_r;

typedef 89   MD6_n; // This can definitely be derived from other constants at 
                    // the top level
typedef 15   MD6_q;
typedef 8    MD6_k;
typedef 1    MD6_v;
typedef 1    MD6_u;

typedef 64   MD6_WordWidth;
`endif

// All that appears to change for 
// different word widths is the WordWidth. 
// Other fields seem to get dropped.
`ifdef BIT32
typedef 32   MD6_c;
typedef 128  MD6_b;
typedef 178  MD6_r;

typedef 178  MD6_n; // This can definitely be derived from other constants at 
                    // the top level
typedef 30   MD6_q;
typedef 16   MD6_k;

typedef 2    MD6_v;
typedef 2    MD6_u;

typedef 32   MD6_WordWidth;
`endif

`ifdef BIT16
typedef 64   MD6_c;
typedef 256  MD6_b;
typedef 178  MD6_r;

typedef 178  MD6_n; // This can definitely be derived from other constants at 
                    // the top level
typedef 30   MD6_q;
typedef 16   MD6_k;
typedef 2    MD6_v;
typedef 2    MD6_u;

typedef 16   MD6_WordWidth;
`endif

`ifdef BIT8
typedef 32   MD6_c;
typedef 128  MD6_b;
typedef 178  MD6_r;

typedef 178  MD6_n; // This can definitely be derived from other constants at 
                    // the top level
typedef 30   MD6_q;
typedef 16   MD6_k;
typedef 2    MD6_v;
typedef 2    MD6_u;

typedef 32   MD6_WordWidth;
`endif