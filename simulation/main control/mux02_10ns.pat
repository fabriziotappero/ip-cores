-- File Name    : mux02.pat
-- Version      : v1.1
-- Description  : test pattern for 2 bit multiplexer 4 to 1
-- Purpose      : to verify the 2 bit multiplexer 4 to 1 block at frequency 50 Mhz
-- Author       : Sigit Dewantoro
-- Address      : IS Laboratory, Labtek VIII, ITB, Jl. Ganesha 10, Bandung, Indonesia
-- Email        : sigit@students.ee.itb.ac.id, sigit@ic.vlsi.itb.ac.id
-- Date         : August 16th, 2001

-- input / output list :

in vdd             B;;;
in vss             B;;;
in a               (1 downto 0)B;;;
in b               (1 downto 0)B;;;
in c               (1 downto 0)B;;;
in d               (1 downto 0)B;;;
in sel             (1 downto 0)B;;;
out o              (1 downto 0)B;;;

begin

-- Pattern description :

--                        v  v  a     b     c     d     s      o
--                        d  s                          e
--                        d  s                          l
--

-- Beware : unprocessed patterns

<0 ns>          pat     : 1  0  0  0  0  1  1  0  1  1  0  0  ?*  *;
<10 ns>         pat     : 1  0  0  0  0  1  1  0  1  1  0  0  ?*  *;
<20 ns>         pat     : 1  0  0  0  0  1  1  0  1  1  0  1  ?*  *;
<30 ns>         pat     : 1  0  0  0  0  1  1  0  1  1  0  1  ?*  *;
<40 ns>         pat     : 1  0  0  0  0  1  1  0  1  1  1  0  ?*  *;
<50 ns>         pat     : 1  0  0  0  0  1  1  0  1  1  1  0  ?*  *;
<60 ns>         pat     : 1  0  0  0  0  1  1  0  1  1  1  1  ?*  *;
<70 ns>         pat     : 1  0  0  0  0  1  1  0  1  1  1  1  ?*  *;
<80 ns>         pat     : 1  0  0  0  0  1  1  0  1  1  0  0  ?*  *;
<90 ns>         pat     : 1  0  0  0  0  1  1  0  1  1  0  0  ?*  *;

end;
