--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006-2009                           --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- Title       : DIVIDER                                                      --
-- Design      : Signed Pipelined Divider core                                --
-- Author      : Michal Krepa                                                 --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- File        : S_DIVIDER.VHD                                                --
-- Created     : Sat Aug 26 2006                                              --
-- Modified    : Thu Mar 12 2009                                              --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
--  Description : Signed Pipelined Divider                                    --
--                                                                            --
-- dividend allowable range of -2**SIZE_C to 2**SIZE_C-1 [SIGNED number]      --
-- divisor allowable range of 1 to (2**SIZE_C)/2-1 [UNSIGNED number]          --
-- pipeline latency is 2*SIZE_C+2 (time from latching input to result ready)  --
-- when pipeline is full new result is generated every clock cycle            --
-- Non-Restoring division algorithm                                           --
-- Use SIZE_C constant in divider entity to adjust bit width                  --
--------------------------------------------------------------------------------
   
--------------------------------------------------------------------------------
-- MAIN DIVIDER top level
--------------------------------------------------------------------------------
library IEEE;
  use IEEE.STD_LOGIC_1164.All;
  use IEEE.NUMERIC_STD.all;

entity s_divider is
  generic 
  ( 
       SIZE_C          : INTEGER := 32
  ) ;            -- SIZE_C: Number of bits
  port 
  (
       rst   : in  STD_LOGIC;
       clk   : in  STD_LOGIC;
       a     : in  STD_LOGIC_VECTOR(SIZE_C-1 downto 0) ;     
       d     : in  STD_LOGIC_VECTOR(SIZE_C-1 downto 0) ;     
       
       q     : out STD_LOGIC_VECTOR(SIZE_C-1 downto 0) ;     
       r     : out STD_LOGIC_VECTOR(SIZE_C-1 downto 0) ;
       round : out STD_LOGIC
  ) ;   
end s_divider ;

architecture str of s_divider is
  
  type S_ARRAY  is array(0 to SIZE_C+3) of unsigned(SIZE_C-1 downto 0);
  type S2_ARRAY is array(0 to SIZE_C+1) of unsigned(2*SIZE_C-1 downto 0);
  
  signal d_s          : S_ARRAY;
  signal q_s          : S_ARRAY;
  signal r_s          : S2_ARRAY;
  signal diff         : S_ARRAY;
  signal qu_s         : STD_LOGIC_VECTOR(SIZE_C-1 downto 0);
  signal ru_s         : unsigned(SIZE_C-1 downto 0);
  signal qu_s2        : STD_LOGIC_VECTOR(SIZE_C-1 downto 0);
  signal ru_s2        : unsigned(SIZE_C-1 downto 0);
  signal d_reg        : STD_LOGIC_VECTOR(SIZE_C-1 downto 0);
  signal pipeline_reg : STD_LOGIC_VECTOR(SIZE_C+3-1 downto 0);
  signal r_reg        : STD_LOGIC_VECTOR(SIZE_C-1 downto 0);
 
begin

 pipeline : process(clk,rst)
 begin
   if rst = '1' then
     for k in 0 to SIZE_C loop
       r_s(k) <= (others => '0');
       q_s(k) <= (others => '0');
       d_s(k) <= (others => '0');
     end loop;
     pipeline_reg <= (others => '0');
   elsif clk = '1' and clk'event then
   
     -- negative number
     if a(SIZE_C-1) = '1' then
       -- negate negative number to create positive
       r_s(0)       <= unsigned(resize(unsigned(not(SIGNED(a)) + TO_SIGNED(1,SIZE_C)),2*SIZE_C));
       -- left shift
       pipeline_reg <= pipeline_reg(pipeline_reg'high-1 downto 0) & '1';
     else
       r_s(0)       <= resize(unsigned(a),2*SIZE_C);
       -- left shift
       pipeline_reg <= pipeline_reg(pipeline_reg'high-1 downto 0) & '0';
     end if;
     d_s(0) <= unsigned(d);
     q_s(0) <= (others => '0');
   
     -- pipeline
     for k in 0 to SIZE_C loop
       -- test remainder if positive/negative
       if r_s(k)(2*SIZE_C-1) = '0' then
         -- shift r_tmp one bit left and subtract d_tmp from upper part of r_tmp 
         r_s(k+1)(2*SIZE_C-1 downto SIZE_C) <= r_s(k)(2*SIZE_C-2 downto SIZE_C-1) - d_s(k);
       else
         r_s(k+1)(2*SIZE_C-1 downto SIZE_C) <= r_s(k)(2*SIZE_C-2 downto SIZE_C-1) + d_s(k);
       end if;
       -- shift r_tmp one bit left (lower part)
       r_s(k+1)(SIZE_C-1 downto 0) <= r_s(k)(SIZE_C-2 downto 0) & '0';
       
       if diff(k)(SIZE_C-1) = '0' then
         q_s(k+1) <= q_s(k)(SIZE_C-2 downto 0) & '1';
       else
         q_s(k+1) <= q_s(k)(SIZE_C-2 downto 0) & '0';
       end if;
       
       d_s(k+1) <= d_s(k);
     end loop;
   end if;
 end process;  
 
 G_DIFF: for x in 0 to SIZE_C generate
   diff(x) <= r_s(x)(2*SIZE_C-2 downto SIZE_C-1) - d_s(x) when r_s(x)(2*SIZE_C-1) = '0'
              else r_s(x)(2*SIZE_C-2 downto SIZE_C-1) + d_s(x);
 end generate G_DIFF;
 
 qu_s <= STD_LOGIC_VECTOR( q_s(SIZE_C) );
 ru_s <= r_s(SIZE_C)(2*SIZE_C-1 downto SIZE_C);
 
 process(clk,rst)
 begin
   if rst = '1' then
     q     <= (others => '0'); 
     r_reg <= (others => '0');   
     round <= '0'; 
   elsif clk = '1' and clk'event then

     
     if ru_s(SIZE_C-1) = '0' then
       ru_s2 <= (ru_s);
     else
       ru_s2 <= (unsigned(ru_s) + d_s(SIZE_C));
     end if;
     qu_s2 <= qu_s;
     
     -- negative number
     if pipeline_reg(SIZE_C+1) = '1' then
       -- negate positive number to create negative
       q <= STD_LOGIC_VECTOR(not(SIGNED(qu_s2)) + TO_SIGNED(1,SIZE_C));
       r_reg <= STD_LOGIC_VECTOR(not(SIGNED(ru_s2)) + TO_SIGNED(1,SIZE_C));
     else
       q <= STD_LOGIC_VECTOR(qu_s2);
       r_reg <= STD_LOGIC_VECTOR(ru_s2);
     end if; 
     
     -- if 2*remainder >= divisor then add 1 to round to nearest integer
     if (ru_s2(SIZE_C-2 downto 0) & '0') >= d_s(SIZE_C+1) then
       round <= '1';
     else
       round <= '0';
     end if;
   end if;
 end process; 

 -- remainder
 r <= r_reg;
 
end str;


