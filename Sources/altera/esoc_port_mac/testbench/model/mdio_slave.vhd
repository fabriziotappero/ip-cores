-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: $
-- $Source: $
--
-- $Revision: #1 $
-- $Date: 2008/08/09 $
-- Check in by : $Author: sc-build $
-- Author      : SKNg/TTChong
--
-- Project     : Triple Speed Ethernet - 10/100/1000 MAC
--
-- Description : (Simulation only)
--
-- MDIO slave's register interface controller 
-- Instantiated in top_mdio_slave (top_mdio_slave.vhd)
--
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------



library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;


entity mdio_slave is port (
      
        reset           : in std_logic;                         -- asynch reset
        mdc             : in std_logic;                         -- system clock
        mdio            : inout std_logic;                      -- Data Bus
        dev_addr        : in  std_logic_vector(4 downto 0);     -- Device address
        reg_addr        : out std_logic_vector(4 downto 0);     -- Address register
        reg_read        : out std_logic;                        -- Read register         
        reg_write       : out std_logic;                        -- Write register         
        reg_dout        : out std_logic_vector(15 downto 0);    -- Data Bus OUT
        reg_din         : in  std_logic_vector(15 downto 0)) ;  -- Data Bus IN

end mdio_slave;        

architecture rtl of mdio_slave is
 
        signal phy_add            : std_logic_vector(4 downto 0);   -- Phy Address
        signal reg_add            : std_logic_vector(4 downto 0);   -- Register Address
        signal reg_out            : std_logic_vector(15 downto 0);  -- Register data out
        signal reg_in             : std_logic_vector(15 downto 0);  -- Register data in
        signal en_phy_add         : std_logic;                      -- Write phy Address
        signal en_reg_add         : std_logic;                      -- Write register Address
        signal en_data_out        : std_logic;                      -- Write register data out
        signal en_data_in         : std_logic;                      -- Write register data in
        signal shift_data_in      : std_logic;                      -- Send register data in
        signal phy_add_ok         : std_logic;                      -- Phy Address correct
        signal cnt_32             : std_logic_vector(4 downto 0);   -- Frame Bit counter
        signal run_cnt_32         : std_logic;                      -- Run Frame Bit counter
        signal ok_32              : std_logic;                      -- Preambule length reached
        signal ok_16              : std_logic;                      -- Data length reached
        signal ok_10              : std_logic;                      -- Reg address length reach
        signal ok_5               : std_logic;                      -- Phy address length reach
        signal cd_oe              : std_logic;                      -- Output Enable command
        signal mux_0              : std_logic;                      -- Mux zero
        signal mdio_wait          : std_logic;                      -- Wait state of State machine
        signal mdio_run           : std_logic_vector(16 downto 0);  -- State machine core

begin
   
     

--=====================================================================
-- Data logic structure  
--=====================================================================
p_data:process(mdc,reset)
begin
if (reset='1') then
  
    phy_add            <= (others=>'0');   -- Phy Address
    reg_add            <= (others=>'0');   -- Register Address
    reg_out            <= (others=>'0');   -- Register data out
    reg_in             <= (others=>'0');    -- Register data in
    --
    cnt_32             <= (others=>'0');   -- Frame Bit counter
    --
    
 elsif (mdc'event and mdc='1') then

     
     ------------------------
     -- Phy Address
     ------------------------
     if (en_phy_add='1')
         then phy_add(4 downto 0) <= (phy_add(3 downto 0) & mdio);
         else phy_add <= phy_add;
     end if;
     ------------------------
                                                     
     
     -------------------------
     -- Register Address 
     -------------------------  
     if (en_reg_add='1')
         then reg_add(4 downto 0) <= (reg_add(3 downto 0) & mdio);
         else reg_add <= reg_add;
     end if;
     -------------------------


     -------------------------
     -- Register data out 
     -------------------------  
     if (en_data_out='1')
         then reg_out(15 downto 0) <= (reg_out(14 downto 0) & mdio);
         else reg_out <= reg_out;
     end if;
     -------------------------
           
     
     -------------------------------------------
     -- Register data in
     -------------------------------------------
     if (en_data_in='1')
         then reg_in(15 downto 0) <= reg_din;
     elsif (shift_data_in='1')
      then reg_in(15 downto 1) <= reg_in(14 downto 0);
     else   reg_in              <= reg_in;
     end if;
     --    
     --------------------------------------------


     ----------------------
     -- Frame Bit counter
     ---------------------
     if (run_cnt_32='1')
        then cnt_32 <= cnt_32 + 1;   
        else cnt_32 <= "00000";
     end if;
     ---------------------
     

end if;
end process;
--
----------------------------
-- Phy Address correct
----------------------------
phy_add_ok <= '1' when  (phy_add = dev_addr) else '0';                      
--
-----------------------------
-- Preambule length reached
-----------------------------
ok_32  <= '1' when  (cnt_32 = "11110") else '0';
--  
----------------------------
-- Data length reached
----------------------------
ok_16  <= '1' when  (cnt_32 = "01111") else '0';
-- 
----------------------------
-- Reg address length reach
----------------------------
ok_10  <= '1' when  (cnt_32 = "01010") else '0';
--  
----------------------------
-- Phy address length reach
----------------------------
ok_5  <= '1' when  (cnt_32 = "00101") else '0';
--                      
------------------------
-- -- Address register
------------------------
reg_addr <= reg_add;  
--
------------------------
-- Data Bus OUT
------------------------
reg_dout <=  reg_out;                     
--
------------------------
-- Mux zero
------------------------
mux_0 <= '0' when (mdio_run(8)='1') else (reg_in(15));                      
--
------------------------
-- Data Bus
------------------------
mdio <= mux_0 after 20 ns when (cd_oe='0') else 'Z' after 20 ns ;                   
--        
--=====================================================================
    



--=====================================================================
-- State machine body  
--=====================================================================
p_state:process(mdc,reset)
begin
if (reset='1') then
  
    mdio_wait          <= '1';             -- Wait state of State machine
    mdio_run           <= (others=>'0');   -- State machine core
    --
    cd_oe              <= '1';             -- Output Enable command
    --
    en_phy_add         <= '0';             -- Write phy Address
    en_reg_add         <= '0';             -- Write register Address
    en_data_out        <= '0';             -- Write register data out
    --
    -- 
        
    
 elsif (mdc'event and mdc='1') then

  
    ----------------------------------------
    -- wait for a frame
    ----------------------------------------
    if (mdio_wait='1'    and mdio='0') or
       (mdio_run(0)='1'  and mdio='0') or         
       (mdio_run(2)='1'  and mdio='0') or
       (mdio_run(4)='1'  and mdio='1') or
       (mdio_run(6)='1'  and phy_add_ok='0') or
       (mdio_run(7)='1'  and mdio='0') or
       (mdio_run(9)='1'  and ok_16='1') or
       (mdio_run(10)='1' and mdio='0') or
       (mdio_run(12)='1' and phy_add_ok='0') or
       (mdio_run(13)='1' and mdio='0') or
       (mdio_run(14)='1' and mdio='1') or
       (mdio_run(16)='1') or
       (mdio_run(0)='0' and mdio_run(1)='0' and mdio_run(2)='0' and mdio_run(3)='0' and
        mdio_run(4)='0' and mdio_run(5)='0' and mdio_run(6)='0' and mdio_run(7)='0' and                         
        mdio_run(8)='0' and mdio_run(9)='0' and mdio_run(10)='0' and mdio_run(11)='0' and    
        mdio_run(12)='0' and mdio_run(13)='0' and mdio_run(14)='0' and mdio_run(15)='0' and
        mdio_run(16)='0')     
      then mdio_wait <= '1';
      else mdio_wait <= '0';
     end if;
     --
    ----------------------------------------------
    -- Check preambule
    ----------------------------------------------
    if (mdio_wait='1'   and mdio='1') or
         (mdio_run(0)='1' and mdio='1' and ok_32='0')
         then mdio_run(0) <= '1';
         else mdio_run(0) <= '0';
     end if;
     --
    if (mdio_run(0)='1' and mdio='1' and ok_32='1') or
         (mdio_run(1)='1'  and mdio='1') 
          then mdio_run(1) <= '1';
         else mdio_run(1) <= '0';
     end if;
     ----------------------------------------------
    -- Check ST
    ----------------------------------------------
     if (mdio_run(1)='1'  and mdio='0')
         then mdio_run(2) <= '1';
         else mdio_run(2) <= '0';
     end if;
     --   
     if (mdio_run(2)='1'  and mdio='1')
         then mdio_run(3) <= '1';
         else mdio_run(3) <= '0';
     end if;
     ----------------------------------------------
    -- Check OP
    ----------------------------------------------      
     if (mdio_run(3)='1'  and mdio='1')
         then mdio_run(4) <= '1';
         else mdio_run(4) <= '0';
     end if;
     ----------------------------------------------
    -- Read OP
    ----------------------------------------------              
     if (mdio_run(4)='1'  and mdio='0') or
         (mdio_run(5)='1' and ok_5='0')
         then mdio_run(5) <= '1';
         else mdio_run(5) <= '0';
     end if;
     -- 
     if (mdio_run(5)='1' and ok_5='1') or
          (mdio_run(6)='1' and ok_10='0' and phy_add_ok='1')
         then mdio_run(6) <= '1';
         else mdio_run(6) <= '0';
     end if;
     --
     if (mdio_run(6)='1' and ok_10='1' and phy_add_ok='1')
         then mdio_run(7) <= '1';
         else mdio_run(7) <= '0';
     end if;
     --
     if (mdio_run(7)='1'  and mdio/='0') 
        then mdio_run(8) <= '1';
         else mdio_run(8) <= '0';
     end if;
     --
    if (mdio_run(8)='1') or
          (mdio_run(9)='1' and ok_16='0')
         then mdio_run(9) <= '1';
         else mdio_run(9) <= '0';
     end if;
     --
     ----------------------------------------------
    -- Write OP
    ----------------------------------------------                   
    if (mdio_run(3)='1' and mdio='0')
         then mdio_run(10) <= '1';
         else mdio_run(10) <= '0';
     end if;
     -- 
     if (mdio_run(10)='1' and mdio='1') or
          (mdio_run(11)='1' and ok_5='0')
         then mdio_run(11) <= '1';
         else mdio_run(11) <= '0';
     end if;
     -- 
      if (mdio_run(11)='1' and ok_5='1') or
           (mdio_run(12)='1' and ok_10='0' and phy_add_ok='1')
         then mdio_run(12) <= '1';
         else mdio_run(12) <= '0';
     end if;
     --
     if (mdio_run(12)='1' and ok_10='1' and phy_add_ok='1')
         then mdio_run(13) <= '1';
         else mdio_run(13) <= '0';
     end if;
     --
     if (mdio_run(13)='1' and mdio='1')
         then mdio_run(14) <= '1';
         else mdio_run(14) <= '0';
     end if;
     -- 
     if (mdio_run(14)='1' and mdio='0') or
        (mdio_run(15)='1' and ok_16='0')
         then mdio_run(15) <= '1';
         else mdio_run(15) <= '0';
     end if;
     --
     if (mdio_run(15)='1' and ok_16='1')
         then mdio_run(16) <= '1';
         else mdio_run(16) <= '0';
     end if;
     --
    ------------------------------    

                   

     ----------------------
    -- Write phy Address    
     ----------------------          
    if (mdio_run(4)='1'  and mdio='0') or
         (mdio_run(5)='1' and ok_5='0') or
         
         (mdio_run(10)='1' and mdio='1') or
          (mdio_run(11)='1' and ok_5='0')

         then en_phy_add <= '1';
         else en_phy_add <= '0';
     end if;
     --            
    ---------------------
              

    ----------------------------           
    -- Write register Address
     ----------------------------
     if (mdio_run(5)='1' and ok_5='1') or
          (mdio_run(6)='1' and ok_10='0') or

         (mdio_run(11)='1' and ok_5='1') or
          (mdio_run(12)='1' and ok_10='0')
          
        then en_reg_add <= '1';
        else en_reg_add <= '0';
     end if;
     -----------------------------


    ----------------------------           
    -- Write register data out
     ----------------------------
     if (mdio_run(14)='1' and mdio='0') or
        (mdio_run(15)='1' and ok_16='0')          
        then en_data_out <= '1';
        else en_data_out <= '0';
     end if;
     -----------------------------
  

    ----------------------------           
    -- Output Enable command
     ----------------------------
     if (mdio_run(7)='1' and mdio/='0') or
         (mdio_run(8)='1') or
          (mdio_run(9)='1' and ok_16='0')  
        then cd_oe <= '0' ;
        else cd_oe <= '1' ;
     end if;
     -----------------------------
                  
    
end if;
end process;
--
---------------------------
-- Write register data in
---------------------------
en_data_in <= mdio_run(8);
--
---------------------------
-- Send register data in   
---------------------------          
shift_data_in <= mdio_run(9);             
--    
---------------------------          
-- Read register 
---------------------------          
reg_read <= '1' when (mdio_run(7)='1' and mdio/='0') or (mdio_run(8)='1') else '0';
--                             
---------------------------  
-- Write register
---------------------------
reg_write <= mdio_run(16);                             
--      
----------------------------------
-- Run Frame Bit counter
-----------------------------------
run_cnt_32 <= '1' when   (mdio_wait='1'   and mdio='1') or
                           (mdio_run(0)='1' and mdio='1' and ok_32='0')  or

                               (mdio_run(4)='1'  and mdio='0') or
                                 (mdio_run(5)='1' and ok_5='0') or

                               (mdio_run(5)='1' and ok_5='1') or
                                  (mdio_run(6)='1' and ok_10='0') or
                                 
                                 (mdio_run(9)='1') or
                                   
                               (mdio_run(10)='1' and mdio='1') or
                                  (mdio_run(11)='1' and ok_5='0') or

                               (mdio_run(11)='1' and ok_5='1') or
                                (mdio_run(12)='1' and ok_10='0') or

                               (mdio_run(15)='1' and ok_16='0')

                       else '0';
-----------------------------------
--
--=====================================================================
    
     
       

end rtl;
