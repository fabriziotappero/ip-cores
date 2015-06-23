-----------------------------------------------------------------------------
-- Entity: 	grfpushwx
-- File:	grfpushwx.vhd
-- Author:	Edvin Catovic - Gaisler Research
-- Description:	GRFPU (shared version) wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library gaisler;
use gaisler.leon3.all;


entity grfpushwx is
  generic (mul    : integer              := 0;
           nshare : integer range 0 to 8 := 0);
  port(
    clk     : in  std_logic;
    reset   : in  std_logic;
    fpvi    : in  grfpu_in_vector_type;
    fpvo    : out grfpu_out_vector_type    
    );
end;


architecture rtl of grfpushwx is

component grfpushw 
  generic (mul    : integer range 0 to 2 := 0;
           nshare : integer range 0 to 8 := 0);
  port(
    clk     : in  std_logic;
    reset   : in  std_logic;
    cpu0_start   : in std_logic;
    cpu0_nonstd  : in std_logic;
    cpu0_flop    : in std_logic_vector(8 downto 0);
    cpu0_op1     : in std_logic_vector(63 downto 0);
    cpu0_op2     : in std_logic_vector(63 downto 0);
    cpu0_opid    : in std_logic_vector(7 downto 0);
    cpu0_flush   : in std_logic;
    cpu0_flushid : in std_logic_vector(5 downto 0);
    cpu0_rndmode : in std_logic_vector(1 downto 0);
    cpu0_req     : in std_logic;
    cpu0_res     : out std_logic_vector(63 downto 0);
    cpu0_exc     : out std_logic_vector(5 downto 0);
    cpu0_allow   : out std_logic_vector(2 downto 0);
    cpu0_rdy     : out std_logic;
    cpu0_cc      : out std_logic_vector(1 downto 0);
    cpu0_idout   : out std_logic_vector(7 downto 0);
    cpu1_start   : in std_logic;
    cpu1_nonstd  : in std_logic;
    cpu1_flop    : in std_logic_vector(8 downto 0);
    cpu1_op1     : in std_logic_vector(63 downto 0);
    cpu1_op2     : in std_logic_vector(63 downto 0);
    cpu1_opid    : in std_logic_vector(7 downto 0);
    cpu1_flush   : in std_logic;
    cpu1_flushid : in std_logic_vector(5 downto 0);
    cpu1_rndmode : in std_logic_vector(1 downto 0);
    cpu1_req     : in std_logic;
    cpu1_res     : out std_logic_vector(63 downto 0);
    cpu1_exc     : out std_logic_vector(5 downto 0);
    cpu1_allow   : out std_logic_vector(2 downto 0);
    cpu1_rdy     : out std_logic;
    cpu1_cc      : out std_logic_vector(1 downto 0);
    cpu1_idout   : out std_logic_vector(7 downto 0);
    cpu2_start   : in std_logic;
    cpu2_nonstd  : in std_logic;
    cpu2_flop    : in std_logic_vector(8 downto 0);
    cpu2_op1     : in std_logic_vector(63 downto 0);
    cpu2_op2     : in std_logic_vector(63 downto 0);
    cpu2_opid    : in std_logic_vector(7 downto 0);
    cpu2_flush   : in std_logic;
    cpu2_flushid : in std_logic_vector(5 downto 0);
    cpu2_rndmode : in std_logic_vector(1 downto 0);
    cpu2_req     : in std_logic;
    cpu2_res     : out std_logic_vector(63 downto 0);
    cpu2_exc     : out std_logic_vector(5 downto 0);
    cpu2_allow   : out std_logic_vector(2 downto 0);
    cpu2_rdy     : out std_logic;
    cpu2_cc      : out std_logic_vector(1 downto 0);
    cpu2_idout   : out std_logic_vector(7 downto 0);
    cpu3_start   : in std_logic;
    cpu3_nonstd  : in std_logic;
    cpu3_flop    : in std_logic_vector(8 downto 0);
    cpu3_op1     : in std_logic_vector(63 downto 0);
    cpu3_op2     : in std_logic_vector(63 downto 0);
    cpu3_opid    : in std_logic_vector(7 downto 0);
    cpu3_flush   : in std_logic;
    cpu3_flushid : in std_logic_vector(5 downto 0);
    cpu3_rndmode : in std_logic_vector(1 downto 0);
    cpu3_req     : in std_logic;
    cpu3_res     : out std_logic_vector(63 downto 0);
    cpu3_exc     : out std_logic_vector(5 downto 0);
    cpu3_allow   : out std_logic_vector(2 downto 0);
    cpu3_rdy     : out std_logic;
    cpu3_cc      : out std_logic_vector(1 downto 0);
    cpu3_idout   : out std_logic_vector(7 downto 0);
    cpu4_start   : in std_logic;
    cpu4_nonstd  : in std_logic;
    cpu4_flop    : in std_logic_vector(8 downto 0);
    cpu4_op1     : in std_logic_vector(63 downto 0);
    cpu4_op2     : in std_logic_vector(63 downto 0);
    cpu4_opid    : in std_logic_vector(7 downto 0);
    cpu4_flush   : in std_logic;
    cpu4_flushid : in std_logic_vector(5 downto 0);
    cpu4_rndmode : in std_logic_vector(1 downto 0);
    cpu4_req     : in std_logic;
    cpu4_res     : out std_logic_vector(63 downto 0);
    cpu4_exc     : out std_logic_vector(5 downto 0);
    cpu4_allow   : out std_logic_vector(2 downto 0);
    cpu4_rdy     : out std_logic;
    cpu4_cc      : out std_logic_vector(1 downto 0);
    cpu4_idout   : out std_logic_vector(7 downto 0);
    cpu5_start   : in std_logic;
    cpu5_nonstd  : in std_logic;
    cpu5_flop    : in std_logic_vector(8 downto 0);
    cpu5_op1     : in std_logic_vector(63 downto 0);
    cpu5_op2     : in std_logic_vector(63 downto 0);
    cpu5_opid    : in std_logic_vector(7 downto 0);
    cpu5_flush   : in std_logic;
    cpu5_flushid : in std_logic_vector(5 downto 0);
    cpu5_rndmode : in std_logic_vector(1 downto 0);
    cpu5_req     : in std_logic;
    cpu5_res     : out std_logic_vector(63 downto 0);
    cpu5_exc     : out std_logic_vector(5 downto 0);
    cpu5_allow   : out std_logic_vector(2 downto 0);
    cpu5_rdy     : out std_logic;
    cpu5_cc      : out std_logic_vector(1 downto 0);
    cpu5_idout   : out std_logic_vector(7 downto 0);
    cpu6_start   : in std_logic;
    cpu6_nonstd  : in std_logic;
    cpu6_flop    : in std_logic_vector(8 downto 0);
    cpu6_op1     : in std_logic_vector(63 downto 0);
    cpu6_op2     : in std_logic_vector(63 downto 0);
    cpu6_opid    : in std_logic_vector(7 downto 0);
    cpu6_flush   : in std_logic;
    cpu6_flushid : in std_logic_vector(5 downto 0);
    cpu6_rndmode : in std_logic_vector(1 downto 0);
    cpu6_req     : in std_logic;
    cpu6_res     : out std_logic_vector(63 downto 0);
    cpu6_exc     : out std_logic_vector(5 downto 0);
    cpu6_allow   : out std_logic_vector(2 downto 0);
    cpu6_rdy     : out std_logic;
    cpu6_cc      : out std_logic_vector(1 downto 0);
    cpu6_idout   : out std_logic_vector(7 downto 0);
    cpu7_start   : in std_logic;
    cpu7_nonstd  : in std_logic;
    cpu7_flop    : in std_logic_vector(8 downto 0);
    cpu7_op1     : in std_logic_vector(63 downto 0);
    cpu7_op2     : in std_logic_vector(63 downto 0);
    cpu7_opid    : in std_logic_vector(7 downto 0);
    cpu7_flush   : in std_logic;
    cpu7_flushid : in std_logic_vector(5 downto 0);
    cpu7_rndmode : in std_logic_vector(1 downto 0);
    cpu7_req     : in std_logic;
    cpu7_res     : out std_logic_vector(63 downto 0);
    cpu7_exc     : out std_logic_vector(5 downto 0);
    cpu7_allow   : out std_logic_vector(2 downto 0);
    cpu7_rdy     : out std_logic;
    cpu7_cc      : out std_logic_vector(1 downto 0);
    cpu7_idout   : out std_logic_vector(7 downto 0)    
    );
end component;
  

begin

  x0 : grfpushw generic map ((mul mod 4), nshare)
    port map (
      clk  ,   
      reset ,  
      fpvi(0).start ,   
    fpvi(0).nonstd  ,
    fpvi(0).flop    ,
    fpvi(0).op1     ,
    fpvi(0).op2     ,
    fpvi(0).opid    ,
    fpvi(0).flush   ,
    fpvi(0).flushid ,
    fpvi(0).rndmode ,
    fpvi(0).req     ,
    fpvo(0).res     ,
    fpvo(0).exc     ,
    fpvo(0).allow   ,
    fpvo(0).rdy     ,
    fpvo(0).cc      ,
    fpvo(0).idout   ,
    fpvi(1).start   ,
    fpvi(1).nonstd  ,
    fpvi(1).flop    ,
    fpvi(1).op1     ,
    fpvi(1).op2     ,
    fpvi(1).opid    ,
    fpvi(1).flush   ,
    fpvi(1).flushid ,
    fpvi(1).rndmode ,
    fpvi(1).req     ,
    fpvo(1).res     ,
    fpvo(1).exc     ,
    fpvo(1).allow   ,
    fpvo(1).rdy     ,
    fpvo(1).cc      ,
    fpvo(1).idout   ,
    fpvi(2).start   ,
    fpvi(2).nonstd  ,
    fpvi(2).flop    ,
    fpvi(2).op1     ,
    fpvi(2).op2     ,
    fpvi(2).opid    ,
    fpvi(2).flush   ,
    fpvi(2).flushid ,
    fpvi(2).rndmode ,
    fpvi(2).req     ,
    fpvo(2).res     ,
    fpvo(2).exc     ,
    fpvo(2).allow   ,
    fpvo(2).rdy     ,
    fpvo(2).cc      ,
    fpvo(2).idout   ,
    fpvi(3).start   ,
    fpvi(3).nonstd  ,
    fpvi(3).flop    ,
    fpvi(3).op1     ,
    fpvi(3).op2     ,
    fpvi(3).opid    ,
    fpvi(3).flush   ,
    fpvi(3).flushid ,
    fpvi(3).rndmode ,
    fpvi(3).req     ,
    fpvo(3).res     ,
    fpvo(3).exc     ,
    fpvo(3).allow   ,
    fpvo(3).rdy     ,
    fpvo(3).cc      ,
    fpvo(3).idout   ,
    fpvi(4).start   ,
    fpvi(4).nonstd  ,
    fpvi(4).flop    ,
    fpvi(4).op1     ,
    fpvi(4).op2     ,
    fpvi(4).opid    ,
    fpvi(4).flush   ,
    fpvi(4).flushid ,
    fpvi(4).rndmode ,
    fpvi(4).req     ,
    fpvo(4).res     ,
    fpvo(4).exc     ,
    fpvo(4).allow   ,
    fpvo(4).rdy     ,
    fpvo(4).cc      ,
    fpvo(4).idout   ,
    fpvi(5).start   ,
    fpvi(5).nonstd  ,
    fpvi(5).flop    ,
    fpvi(5).op1     ,
    fpvi(5).op2     ,
    fpvi(5).opid    ,
    fpvi(5).flush   ,
    fpvi(5).flushid ,
    fpvi(5).rndmode ,
    fpvi(5).req     ,
    fpvo(5).res     ,
    fpvo(5).exc     ,
    fpvo(5).allow   ,
    fpvo(5).rdy     ,
    fpvo(5).cc      ,
    fpvo(5).idout   ,
    fpvi(6).start   ,
    fpvi(6).nonstd  ,
    fpvi(6).flop    ,
    fpvi(6).op1     ,
    fpvi(6).op2     ,
    fpvi(6).opid    ,
    fpvi(6).flush   ,
    fpvi(6).flushid ,
    fpvi(6).rndmode ,
    fpvi(6).req     ,
    fpvo(6).res     ,
    fpvo(6).exc     ,
    fpvo(6).allow   ,
    fpvo(6).rdy     ,
    fpvo(6).cc      ,
    fpvo(6).idout   ,
    fpvi(7).start   ,
    fpvi(7).nonstd  ,
    fpvi(7).flop    ,
    fpvi(7).op1     ,
    fpvi(7).op2     ,
    fpvi(7).opid    ,
    fpvi(7).flush   ,
    fpvi(7).flushid ,
    fpvi(7).rndmode ,
    fpvi(7).req     ,
    fpvo(7).res     ,
    fpvo(7).exc     ,
    fpvo(7).allow   ,
    fpvo(7).rdy     ,
    fpvo(7).cc      ,
    fpvo(7).idout);
                   
end;               
                   
                   
                   
                   
                   
                   
                   
                   
                   
                   
