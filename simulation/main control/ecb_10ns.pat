-- File Name    : ecb_10ns.pat
-- Version      : v1.2
-- Description  : test pattern for ecb mode
-- Purpose      : to verify the ecb mode block at frequency 50 Mhz
-- Author       : Sigit Dewantoro
-- Address      : IS Laboratory, Labtek VIII, ITB, Jl. Ganesha 10, Bandung, Indonesia
-- Email        : sigit@students.ee.itb.ac.id, sigit@ic.vlsi.itb.ac.id
-- Date         : August 24th, 2001

-- input / output list :

in vdd             B;;;
in vss             B;;;
in clk             B;;;
in active          B;;;
in cke   	   B;;;
in key_ready       B;;;
in finish          B;;;
in req_cp          B;;;
in E               B;;;
out E_mesin        B;;;
out s_mesin        B;;;
out s_gen_key      B;;;
out emp_buf        B;;;
out cp_ready       B;;;
out cke_b_mode     B;;;
out en_in          B;;;
out en_iv          B;;;
out en_rcbc        B;;;
out en_out         B;;;
out sel1           (1 downto 0) B;;;
out sel2           (1 downto 0) B;;;
out sel3           (1 downto 0) B;;;

begin

-- Pattern description :

--                         v  v  c  a  c  k  f  r  E   E  s  s  e  c  c  e  e  e  e  s     s     s
--                         d  s  l  c  k  e  i  e      _  _  _  m  p  k  n  n  n  n  e     e     e
--                         d  s  k  t  e  y  n  q      m  m  g  p  _  e  _  _  _  _  l     l     l
--                                  i     _  i  _      e  e  e  _  r  _  i  i  r  o  1     2     3
--                                  v     r  s  c      s  s  n  b  e  b  n  v  c  u
--                                  e     e  h  p      i  i  _  u  a  _        b  t
--                                        d            n  n  k  f  d  m        c
--                                        y                  e     y  o
--                                                           y        d
--                                                                    e

-- Beware : unprocessed patterns

-- round 1

<0 ns>             pat    : 1  0  0  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<10 ns>            pat    : 1  0  1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<20 ns>            pat    : 1  0  0  1  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<30 ns>            pat    : 1  0  1  1  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<40 ns>            pat    : 1  0  0  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<50 ns>            pat    : 1  0  1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<60 ns>            pat    : 1  0  0  0  0  1  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<70 ns>            pat    : 1  0  1  0  0  1  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<80 ns>            pat    : 1  0  0  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<90 ns>            pat    : 1  0  1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<100 ns>           pat    : 1  0  0  0  0  0  1  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<110 ns>           pat    : 1  0  1  0  0  0  1  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<120 ns>           pat    : 1  0  0  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<130 ns>           pat    : 1  0  1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<140 ns>           pat    : 1  0  0  0  0  0  0  1  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<150 ns>           pat    : 1  0  1  0  0  0  0  1  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<160 ns>           pat    : 1  0  0  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<170 ns>           pat    : 1  0  1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

end;
