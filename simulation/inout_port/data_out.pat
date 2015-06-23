--  File Name     :  data_out.pat					--
--  Description   :  The test patterns of the data out block            --
--                   for the verification of the structural view        --
--  Purpose       :  To be used by ASIMUT				--
--  Date          :  Aug 30, 2001					--
--  Version       :  1.1						--
--  Author        :  Martadinata A.					--
--  Address       :  VLSI RG, Dept. of Electrical Engineering		--
--                   ITB, Bandung, Indonesia				--
--  E-mail	  :  marta@ic.vlsi.itb.ac.id				--

in   vdd;;
in   vss;;
in   data64out(63 downto 0) X;;
in   emp_bufout;;
in   cp_ready;;
in   clk;;
in   rst;;
out  req_cp spy;;
out  cp_sended spy;;    
out  dataout(31 downto 0) X spy;;


begin
-- sending the first 64-bit data : AAAABBBB00002222  
< 0 ns> init : 1 0 0000000000000000 0 0 0 1 ?* ?* ?********;
< 5 ns> s0   : 1 0 0000000000000000 0 0 1 0 ?* ?* ?********;
<10 ns> s0   : 1 0 AAAABBBB00002222 0 0 0 0 ?* ?* ?********; 
<15 ns> s0   : 1 0 AAAABBBB00002222 0 1 1 0 ?* ?* ?********; 
<20 ns> s0   : 1 0 AAAABBBB00002222 0 1 0 0 ?* ?* ?********; 
<25 ns> s1   : 1 0 AAAABBBB00002222 0 0 1 0 ?* ?* ?********; 
<30 ns> s1   : 1 0 AAAABBBB00002222 0 0 0 0 ?* ?* ?********; 
<35 ns> s2   : 1 0 AAAABBBB00002222 1 0 1 0 ?* ?* ?********; 
<40 ns> s2   : 1 0 AAAABBBB00002222 1 0 0 0 ?* ?* ?********; 
<45 ns> s3   : 1 0 AAAABBBB00002222 0 0 1 0 ?* ?* ?********;
<50 ns> s3   : 1 0 AAAABBBB00002222 0 0 0 0 ?* ?* ?********;
-- sending the second 64-bit data : 5555555577777777
<55 ns> s4   : 1 0 AAAABBBB00002222 1 0 1 0 ?* ?* ?********;
<60 ns> s4   : 1 0 5555555577777777 1 0 0 0 ?* ?* ?********;
<65 ns> s0   : 1 0 5555555577777777 0 1 1 0 ?* ?* ?********;
<70 ns> s0   : 1 0 5555555577777777 0 1 0 0 ?* ?* ?********;
<75 ns> s1   : 1 0 5555555577777777 0 0 1 0 ?* ?* ?********;
<80 ns> s1   : 1 0 5555555577777777 0 0 0 0 ?* ?* ?********;
<85 ns> s2   : 1 0 5555555577777777 1 0 1 0 ?* ?* ?********;
<90 ns> s2   : 1 0 5555555577777777 1 0 0 0 ?* ?* ?********;
<95 ns> s3   : 1 0 5555555577777777 0 0 1 0 ?* ?* ?********;
<100ns> s3   : 1 0 5555555577777777 0 0 0 0 ?* ?* ?********;
<105ns> s4   : 1 0 5555555577777777 0 0 1 0 ?* ?* ?********;
<110ns> s4   : 1 0 5555555577777777 0 0 0 0 ?* ?* ?********;
 



end; 
