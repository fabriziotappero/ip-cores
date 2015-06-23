-- File Name    : ofb_10ns.pat
-- Version      : v1.2
-- Description  : test pattern for ofb mode
-- Purpose      : to verify the ofb mode block at frequency 50 Mhz
-- Author       : Sigit Dewantoro
-- Address      : IS Laboratory, Labtek VIII, ITB, Jl. Ganesha 10, Bandung, Indonesia
-- Email        : sigit@students.ee.itb.ac.id, sigit@ic.vlsi.itb.ac.id
-- Date         : August 24th, 2001

-- input / output list :

in vdd             B;;;
in vss             B;;;
in clk             B;;;
in active          B;;;
in key_ready       B;;;
in dt_ready        B;;;
in finish          B;;;
out first_dt       B;;;
out E_mesin        B;;;
out s_mesin        B;;;
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

--                         v  v  c  a  k  d  f   f  E  s  e  c  c  e  e  e  e  s     s     s
--                         d  s  l  c  e  t  i   i  _  _  m  p  k  n  n  n  n  e     e     e
--                         d  s  k  t  y  _  n   r  m  m  p  _  e  _  _  _  _  l     l     l
--                                  i  _  r  i   s  e  e  _  r  _  i  i  r  o  1     2     3
--                                  v  r  e  s   t  s  s  b  e  b  n  v  c  u
--                                  e  e  a  h   _  i  i  u  a  _        b  t
--                                     d  d      d  n  n  f  d  m        c
--                                     y  y      t           y  o
--                                                              d
--                                                              e

-- Beware : unprocessed patterns

-- round 1

<0 ns>            pat    : 1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<10 ns>           pat    : 1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<20 ns>           pat    : 1  0  0  1  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<30 ns>           pat    : 1  0  1  1  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<40 ns>           pat    : 1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<50 ns>           pat    : 1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<60 ns>           pat    : 1  0  0  0  1  1  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<70 ns>           pat    : 1  0  1  0  1  1  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<80 ns>          pat    : 1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<90 ns>          pat    : 1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<100 ns>          pat    : 1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<110 ns>          pat    : 1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<120 ns>          pat    : 1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<130 ns>          pat    : 1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<140 ns>          pat    : 1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<150 ns>          pat    : 1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<160 ns>          pat    : 1  0  0  0  0  1  1  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<170 ns>          pat    : 1  0  1  0  0  1  1  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<180 ns>          pat    : 1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<190 ns>          pat    : 1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<200 ns>          pat    : 1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<210 ns>          pat    : 1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<220 ns>          pat    : 1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<230 ns>          pat    : 1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<240 ns>          pat    : 1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<250 ns>          pat    : 1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<260 ns>          pat    : 1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<270 ns>          pat    : 1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

<280 ns>          pat    : 1  0  0  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;
<290 ns>          pat    : 1  0  1  0  0  0  0  ?*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *;

end;
