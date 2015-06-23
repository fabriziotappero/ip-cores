-- File Name    : dec_mode_10ns.pat
-- Version      : v1.1
-- Description  : test pattern for decoder mode
-- Purpose      : to verify the decoder mode block at frequency 50 Mhz
-- Author       : Sigit Dewantoro
-- Address      : IS Laboratory, Labtek VIII, ITB, Jl. Ganesha 10, Bandung, Indonesia
-- Email        : sigit@students.ee.itb.ac.id, sigit@ic.vlsi.itb.ac.id
-- Date         : August 16th, 2001

-- input / output list :

in vdd             B;;;
in vss             B;;;
in start           B;;;
in mode            (1 downto 0) B;;;
out ecb            B;;;
out cbc            B;;;
out cfb            B;;;
out ofb            B;;;

begin

-- Pattern description :

--                         v  v  s  m      e  c  c  o
--                         d  s  t  o      c  b  f  f
--                         d  s  a  d      b  c  b  b
--                               r  e
--                               t

-- Beware : unprocessed patterns

<0 ns>           pat     : 1  0  0  0  0  ?*  *  *  *;
<10 ns>          pat     : 1  0  0  0  0  ?*  *  *  *;

<20 ns>          pat     : 1  0  1  0  0  ?*  *  *  *;
<30 ns>          pat     : 1  0  1  0  0  ?*  *  *  *;

<40 ns>          pat     : 1  0  1  0  1  ?*  *  *  *;
<50 ns>          pat     : 1  0  1  0  1  ?*  *  *  *;

<60 ns>          pat     : 1  0  1  1  0  ?*  *  *  *;
<70 ns>          pat     : 1  0  1  1  0  ?*  *  *  *;

<80 ns>          pat     : 1  0  1  1  1  ?*  *  *  *;
<90 ns>          pat     : 1  0  1  1  1  ?*  *  *  *;

<100 ns>         pat     : 1  0  0  0  0  ?*  *  *  *;
<110 ns>         pat     : 1  0  0  0  0  ?*  *  *  *;

end;
