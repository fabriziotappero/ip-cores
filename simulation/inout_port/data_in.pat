--  File Name     :  data_in.pat					--
--  Description   :  The test patterns of the data in block             --
--                   for the verification of the structural view        --
--  Purpose       :  To be used by ASIMUT				--
--  Date          :  Aug 21, 2001					--
--  Version       :  1.1						--
--  Author        :  Martadinata A.					--
--  Address       :  VLSI RG, Dept. of Electrical Engineering		--
--                   ITB, Bandung, Indonesia				--
--  E-mail	  :  marta@ic.vlsi.itb.ac.id				--

in   vdd;;
in   vss;;
in   datain(31 downto 0) X;;
in   emp_buf;;
in   dt_sended;;
in   clk;;
in   rst;;
out  req_dt spy;;
out  dt_ready spy;;    
out  data64in(63 downto 0) X spy;;


begin
-- requesting the first 64-bit data : AAAABBBB00002222  
< 0 ns> init : 1 0 00000000 0 0 0 1 ?* ?* ?****************;
< 5 ns> s0   : 1 0 00000000 0 0 1 0 ?* ?* ?****************;
<10 ns> s0   : 1 0 AAAABBBB 0 0 0 0 ?* ?* ?****************;
<15 ns> s0   : 1 0 AAAABBBB 0 1 1 0 ?* ?* ?****************;
<20 ns> s0   : 1 0 AAAABBBB 0 1 0 0 ?* ?* ?****************;
<25 ns> s1   : 1 0 AAAABBBB 0 0 1 0 ?* ?* ?****************;
<30 ns> s1   : 1 0 00002222 0 0 0 0 ?* ?* ?****************;
<35 ns> s2   : 1 0 00002222 0 1 1 0 ?* ?* ?****************;
<40 ns> s2   : 1 0 00002222 0 1 0 0 ?* ?* ?****************;
<45 ns> s3   : 1 0 00002222 0 0 1 0 ?* ?* ?****************;
<50 ns> s3   : 1 0 00002222 0 0 0 0 ?* ?* ?****************;
-- requesting the second 64-bit data : CCCC0000ABCD123
<55 ns> s4   : 1 0 00002222 1 0 1 0 ?* ?* ?****************;
<60 ns> s4   : 1 0 CCCC0000 1 0 0 0 ?* ?* ?****************;
<65 ns> s0   : 1 0 CCCC0000 1 1 1 0 ?* ?* ?****************;
<70 ns> s0   : 1 0 CCCC0000 1 1 0 0 ?* ?* ?****************;
<75 ns> s1   : 1 0 CCCC0000 1 0 1 0 ?* ?* ?****************;
<80 ns> s1   : 1 0 ABCD1234 1 0 0 0 ?* ?* ?****************;
<85 ns> s2   : 1 0 ABCD1234 1 1 1 0 ?* ?* ?****************;
<90 ns> s2   : 1 0 ABCD1234 1 1 0 0 ?* ?* ?****************;
<95 ns> s3   : 1 0 ABCD1234 0 0 1 0 ?* ?* ?****************;
<100ns> s3   : 1 0 ABCD1234 0 0 0 0 ?* ?* ?****************;
end; 
