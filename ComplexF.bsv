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




typedef struct{
  Bit#(n) i;
  Bit#(n) q;
}
 ComplexF#(numeric type n) deriving(Eq, Bits);


function Int#(n)  toInt(Bit#(n) x)= unpack(x);
function Bit#(n) toBit(Int#(n) x)= pack(x);

instance Literal#(ComplexF#(n));
  function ComplexF#(n) fromInteger(Integer x);
    return error("Can't use Literal");
  endfunction
endinstance


instance Bounded#(ComplexF#(n));
  function ComplexF#(n) minBound();
    Int#(n) mb = minBound;
    return ComplexF{i: pack(mb),q: pack(mb)};
  endfunction
  function ComplexF#(n) maxBound();
    Int#(n) mb = maxBound;
    return ComplexF{i: pack(mb),q: pack(mb)};
  endfunction
endinstance

instance BitExtend#(n,m, ComplexF) provisos(Add#(k,n,m));
     function ComplexF#(m) zeroExtend(ComplexF#(n) x);
       return ComplexF{
                i: zeroExtend(x.i),
                q: zeroExtend(x.q)                 
              };
     endfunction
     function ComplexF#(m) signExtend(ComplexF#(n) x);
       return ComplexF{
                i: signExtend(x.i),
                q: signExtend(x.q)                 
              };
     endfunction
     function ComplexF#(n) truncate(ComplexF#(m) x);
       Nat rmax = fromInteger(valueOf(m) -1);
       Nat rmin = fromInteger(valueOf(m) - valueOf(n));
       return ComplexF{
                i: x.i[rmax:rmin],
                q: x.q[rmax:rmin]                 
              };
     endfunction
endinstance
   
function Bit#(n) complex_add(Bit#(n) x, Bit#(n) y) provisos(Add#(1,k,n), Add#(1,n, TAdd#(1,n)));
  Nat              si = fromInteger(valueOf(n) - 1);
  Nat          si_p_1 = fromInteger(valueOf(n));
  Bit#(1)          sx = pack(x)[si];
  Bit#(1)          sy = pack(y)[si];
  Int#(TAdd#(1,n)) ix = unpack({sx,x});
  Int#(TAdd#(1,n)) iy = unpack({sy,y});
  Int#(TAdd#(1,n)) ir = ix + iy + 1;
  Bit#(n)         res = (pack(ir))[si_p_1:1];
return  res;
endfunction

function Bit#(n) complex_sub(Bit#(n) x, Bit#(n) y) provisos(Add#(1,k,n), Add#(1,n, TAdd#(1,n)));
  Nat              si = fromInteger(valueOf(n) - 1);
  Nat          si_p_1 = fromInteger(valueOf(n));
  Bit#(1)          sx = pack(x)[si];
  Bit#(1)          sy = pack(y)[si];
  Int#(TAdd#(1,n)) ix = unpack({sx,x});
  Int#(TAdd#(1,n)) iy = unpack({sy,y});
  Int#(TAdd#(1,n)) ir = ix - iy + 1;
  Bit#(n)         res = (pack(ir))[si_p_1:1];
  return  res;
endfunction
   
   
function Bit#(n) complex_mult(Bit#(n) x, Bit#(n) y) provisos(Add#(k,n,TAdd#(n,n)));
  Nat                si = fromInteger(valueOf(n) - 1) ; 
  Nat               si2 = fromInteger(2*(valueOf(n) - 1));
  Nat              si_1 = fromInteger(valueOf(n) - 2); // 14 for 16
  Bit#(TAdd#(n,n)) half = 1 << (si_1);

  Int#(TAdd#(n,n)) ix = unpack(signExtend(x));
  Int#(TAdd#(n,n)) iy = unpack(signExtend(y));

  Bit#(TAdd#(n,n)) t1 = pack(ix*iy);
  Bit#(TAdd#(n,n)) t2 = t1 + half;
  Bit#(n)          t3 = t2[si2:si];
  Int#(n)         it3 = unpack(t3);
  Bit#(n)         res = pack((it3 == minBound) ? maxBound : it3);

  return  res;
endfunction


instance Arith#(ComplexF#(n)) provisos(Add#(1,k,n), Add#(k2,n,TAdd#(n,n)), Add#(1,n,TAdd#(1,n)));

  function ComplexF#(n) \+ (ComplexF#(n) x, ComplexF#(n) y);
     return ComplexF{
              i: complex_add(x.i, y.i),
              q: complex_add(x.q, y.q)
             };
  endfunction     

  function ComplexF#(n) \- (ComplexF#(n) x, ComplexF#(n) y);
     return ComplexF{
              i: complex_sub(x.i, y.i),
              q: complex_sub(x.q, y.q)
             };
  endfunction

  function ComplexF#(n) \* (ComplexF#(n) x, ComplexF#(n) y) provisos(Add#(k2,n,TAdd#(n,n)));
    Bit#(n) ii = complex_mult(x.i, y.i);
    Bit#(n) qq = complex_mult(x.q, y.q);
    Bit#(n) iq = complex_mult(x.i, y.q);
    Bit#(n) qi = complex_mult(x.q, y.i);

    return ComplexF{
             i: complex_add(ii, qq),
             q: complex_sub(qi, iq)
            };
  endfunction
  
  function ComplexF#(n) negate (ComplexF#(n) x);
    return ComplexF{
              i: negate(x.i),
              q: negate(x.q)
            };
  endfunction

endinstance
