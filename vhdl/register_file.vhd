-- File: register_file.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Entity implementing register file.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

use WORK.RISE_PACK.all;
use work.RISE_PACK_SPECIFIC.all;

entity register_file is
  
  port (
    clk   : in std_logic;
    reset : in std_logic;

    rx_addr : in REGISTER_ADDR_T;
    ry_addr : in REGISTER_ADDR_T;
    rz_addr : in REGISTER_ADDR_T;

    rx_read : out REGISTER_T;
    ry_read : out REGISTER_T;
    rz_read : out REGISTER_T;

    dreg_addr   : in REGISTER_ADDR_T;
    dreg_write  : in REGISTER_T;
    dreg_enable : in std_logic;

    sr_read   : out SR_REGISTER_T;
    sr_write  : in  SR_REGISTER_T;
    sr_enable : in  std_logic;

    lr_write  : in PC_REGISTER_T;
    lr_enable : in std_logic;

    pc_write : in  PC_REGISTER_T;
    pc_read  : out PC_REGISTER_T);

end register_file;

architecture register_file_rtl of register_file is
  
  
  signal reg_0, reg_1, reg_2, reg_3, reg_4              : REGISTER_T;
  signal reg_5, reg_6, reg_7, reg_8, reg_9              : REGISTER_T;
  signal reg_10, reg_11, reg_12, reg_13, reg_14, reg_15 : REGISTER_T;
  

begin  -- register_file_rtl

  SYNC : process(clk, reset, dreg_enable, sr_enable, lr_enable)
  begin
    
    if reset = '0' then
      
      reg_0  <= (others => '0');
      reg_1  <= (others => '0');
      reg_2  <= (others => '0');
      reg_3  <= (others => '0');
      reg_4  <= (others => '0');
      reg_5  <= (others => '0');
      reg_6  <= (others => '0');
      reg_7  <= (others => '0');
      reg_8  <= (others => '0');
      reg_9  <= (others => '0');
      reg_10 <= (others => '0');
      reg_11 <= (others => '0');
      reg_12 <= (others => '0');
      reg_13 <= (others => '0');
      reg_14 <= (others => '0');
      reg_15 <= (others => '0');


    elsif clk'event and clk = '1' then
      
      
      if dreg_addr = "0000" and dreg_enable = '1' then
        reg_0 <= dreg_write;
        
      elsif dreg_addr = "0001" and dreg_enable = '1' then
        reg_1 <= dreg_write;
        
      elsif dreg_addr = "0010" and dreg_enable = '1' then
        reg_2 <= dreg_write;
        
      elsif dreg_addr = "0011" and dreg_enable = '1' then
        reg_3 <= dreg_write;
        
      elsif dreg_addr = "0100" and dreg_enable = '1' then
        reg_4 <= dreg_write;
        
      elsif dreg_addr = "0101" and dreg_enable = '1' then
        reg_5 <= dreg_write;
        
      elsif dreg_addr = "0110" and dreg_enable = '1' then
        reg_6 <= dreg_write;
        
      elsif dreg_addr = "0111" and dreg_enable = '1' then
        reg_7 <= dreg_write;
        
      elsif dreg_addr = "1000" and dreg_enable = '1' then
        reg_8 <= dreg_write;
        
      elsif dreg_addr = "1001" and dreg_enable = '1' then
        reg_9 <= dreg_write;
        
      elsif dreg_addr = "1010" and dreg_enable = '1' then
        reg_10 <= dreg_write;
        
      elsif dreg_addr = "1011" and dreg_enable = '1' then
        reg_11 <= dreg_write;
        
      elsif dreg_addr = "1100" and dreg_enable = '1' then
        reg_12 <= dreg_write;
        
      end if;

      if dreg_addr = "1101" and dreg_enable = '1' then
        reg_13 <= dreg_write;
      elsif lr_enable = '1' then
        reg_13 <= lr_write;
      end if;

      if dreg_addr = "1110" and dreg_enable = '1' then
        reg_14 <= dreg_write;
      else
        reg_14 <= pc_write;
      end if;

      if dreg_addr = "1111" and dreg_enable = '1' then
        reg_15 <= dreg_write;
      elsif sr_enable = '1' then
        reg_15 <= sr_write;
      end if;

    end if;
    
  end process SYNC;

  SPECIAL_READ_PROC : process (reset, reg_14, reg_15)
  begin
    
    sr_read <= reg_15;
    pc_read <= reg_14;
    
  end process SPECIAL_READ_PROC;


  RX_READ_PROC : process(reset, rx_addr,
                        reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7,
                        reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15)
  begin
    
    if reset = '0' then
      
      rx_read <= (others => '0');
    else
      
      case rx_addr is
        when "0000" => rx_read <= reg_0;
        when "0001" => rx_read <= reg_1;
        when "0010" => rx_read <= reg_2;
        when "0011" => rx_read <= reg_3;
        when "0100" => rx_read <= reg_4;
        when "0101" => rx_read <= reg_5;
        when "0110" => rx_read <= reg_6;
        when "0111" => rx_read <= reg_7;
        when "1000" => rx_read <= reg_8;
        when "1001" => rx_read <= reg_9;
        when "1010" => rx_read <= reg_10;
        when "1011" => rx_read <= reg_11;
        when "1100" => rx_read <= reg_12;
        when "1101" => rx_read <= reg_13;
        when "1110" => rx_read <= reg_14;
        when "1111" => rx_read <= reg_15;
        when others => rx_read <= "XXXXXXXXXXXXXXXX";
      end case;
      
    end if;

  end process RX_READ_PROC;
  
  
  RY_READ_PROC : process(reset, ry_addr,
                        reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7,
                        reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15)
  begin
    
    if reset = '0' then
      
      ry_read <= (others => '0');
    else
      
      case ry_addr is
        when "0000" => ry_read <= reg_0;
        when "0001" => ry_read <= reg_1;
        when "0010" => ry_read <= reg_2;
        when "0011" => ry_read <= reg_3;
        when "0100" => ry_read <= reg_4;
        when "0101" => ry_read <= reg_5;
        when "0110" => ry_read <= reg_6;
        when "0111" => ry_read <= reg_7;
        when "1000" => ry_read <= reg_8;
        when "1001" => ry_read <= reg_9;
        when "1010" => ry_read <= reg_10;
        when "1011" => ry_read <= reg_11;
        when "1100" => ry_read <= reg_12;
        when "1101" => ry_read <= reg_13;
        when "1110" => ry_read <= reg_14;
        when "1111" => ry_read <= reg_15;
        when others => ry_read <= "XXXXXXXXXXXXXXXX";
      end case;
      
    end if;

  end process RY_READ_PROC;
  
  
  
  RZ_READ_PROC : process(reset, rz_addr,
                        reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7,
                        reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15)
  begin
    
    if reset = '0' then
      
      rz_read <= (others => '0');
    else
      
      case rz_addr is
        when "0000" => rz_read <= reg_0;
        when "0001" => rz_read <= reg_1;
        when "0010" => rz_read <= reg_2;
        when "0011" => rz_read <= reg_3;
        when "0100" => rz_read <= reg_4;
        when "0101" => rz_read <= reg_5;
        when "0110" => rz_read <= reg_6;
        when "0111" => rz_read <= reg_7;
        when "1000" => rz_read <= reg_8;
        when "1001" => rz_read <= reg_9;
        when "1010" => rz_read <= reg_10;
        when "1011" => rz_read <= reg_11;
        when "1100" => rz_read <= reg_12;
        when "1101" => rz_read <= reg_13;
        when "1110" => rz_read <= reg_14;
        when "1111" => rz_read <= reg_15;
        when others => rz_read <= "XXXXXXXXXXXXXXXX";
      end case;
      
    end if;

  end process RZ_READ_PROC;

  

end register_file_rtl;

