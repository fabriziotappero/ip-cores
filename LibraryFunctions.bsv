// The MIT License
//
// Copyright (c) 2006 Nirav Dave (ndave@csail.mit.edu)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.




import Vector::*;

function Bit#(1) getParity(Bit#(n) v) provisos(Add#(1, k, n));
  function Bit#(1) _xor(Bit#(1) x, Bit#(1) y);
    return (x ^ y);
  endfunction

  Vector#(n,Bit#(1)) vv = unpack(v);
  Bit#(1) parity = Vector::fold(_xor, vv);
  return(parity);
endfunction

function Bit#(n) reverseBits(Bit#(n) x);
  Vector#(n, Bit#(1)) vx  = unpack(x);
  Vector#(n, Bit#(1)) rvx = Vector::reverse(vx);
  Bit#(n)            prvx = pack(rvx);
  return(prvx);
endfunction

function Bit#(1) signBit(Bit#(n) x) provisos(Add#(1,k,n));
  match {.signbit,.rest} = split(x);
  return(signbit); 
endfunction

function Vector#(sz, any_e) zipWith4(function any_e f(any_a a, any_b b, any_c c, any_d d),
	                    Vector#(sz, any_a) va, Vector#(sz, any_b) vb,
						Vector#(sz, any_c) vc, Vector#(sz, any_d) vd);

  Vector#(sz, any_e) ve = replicate(?);

  for(Integer i = 0; i < valueOf(sz); i = i + 1)
	  ve[i] = f(va[i],vb[i],vc[i],vd[i]);

  return(ve);

endfunction

function Vector#(n, Bit#(m)) bitBreak(Bit#(nm) x) provisos(Mul#(n,m,nm));
  return unpack(x);
endfunction

function Bit#(nm) bitMerge(Vector#(n, Bit#(m)) x) provisos(Mul#(n,m,nm));
  return pack(x);
endfunction
   
function Vector#(n, alpha) v_truncate(Vector#(m, alpha) in) provisos(Add#(n,k,m));
   Vector#(n, alpha) retval = newVector();
   for(Integer i = valueOf(n) - 1, Integer j = valueOf(m) - 1;  i >= 0; i = i - 1, j = j - 1)
      begin
	 retval[i] = in[j];
      end
       
   return (retval);
endfunction

function Vector#(n, alpha) v_rtruncate(Vector#(m, alpha) in) provisos(Add#(n,k,m));
   Vector#(n, alpha) retval = newVector();
   for(Integer i = 0; i < valueOf(n); i = i + 1)
      begin
	 retval[i] = in[i];
      end
   return (retval);
endfunction