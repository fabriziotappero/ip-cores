
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class pcie_init
--! 
--!
--! @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
--!              Frans Schreuder (frans.schreuder@nikhef.nl)
--!
--!
--! @date        07/01/2015    created
--!
--! @version     1.0
--!
--! @brief 
--! Contains a process to initialize some registers in the PCI express Gen3 core.
--! Additionally it reads the BAR0..2 registers and outputs their values to be 
--! used by dma_control. 
--!
--! @detail
--!
--!-----------------------------------------------------------------------------
--! @TODO
--!  
--!
--! ------------------------------------------------------------------------------
--! Virtex7 PCIe Gen3 DMA Core
--! 
--! \copyright GNU LGPL License
--! Copyright (c) Nikhef, Amsterdam, All rights reserved. <br>
--! This library is free software; you can redistribute it and/or
--! modify it under the terms of the GNU Lesser General Public
--! License as published by the Free Software Foundation; either
--! version 3.0 of the License, or (at your option) any later version.
--! This library is distributed in the hope that it will be useful,
--! but WITHOUT ANY WARRANTY; without even the implied warranty of
--! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--! Lesser General Public License for more details.<br>
--! You should have received a copy of the GNU Lesser General Public
--! License along with this library.
--! 
-- 
--! @brief ieee



library ieee, UNISIM, work;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use work.pcie_package.all;

entity pcie_init is
  port (
    bar0                     : out    std_logic_vector(31 downto 0);
    bar1                     : out    std_logic_vector(31 downto 0);
    bar2                     : out    std_logic_vector(31 downto 0);
    cfg_fc_cpld              : in     std_logic_vector(11 downto 0);
    cfg_fc_cplh              : in     std_logic_vector(7 downto 0);
    cfg_fc_npd               : in     std_logic_vector(11 downto 0);
    cfg_fc_nph               : in     std_logic_vector(7 downto 0);
    cfg_fc_pd                : in     std_logic_vector(11 downto 0);
    cfg_fc_ph                : in     std_logic_vector(7 downto 0);
    cfg_fc_sel               : out    std_logic_vector(2 downto 0);
    cfg_mgmt_addr            : out    std_logic_vector(18 downto 0);
    cfg_mgmt_byte_enable     : out    std_logic_vector(3 downto 0);
    cfg_mgmt_read            : out    std_logic;
    cfg_mgmt_read_data       : in     std_logic_vector(31 downto 0);
    cfg_mgmt_read_write_done : in     std_logic;
    cfg_mgmt_write           : out    std_logic;
    cfg_mgmt_write_data      : out    std_logic_vector(31 downto 0);
    clk                      : in     std_logic;
    reset                    : in     std_logic);
end entity pcie_init;



architecture rtl of pcie_init is

    signal s_cfg_fc_cpld              :     std_logic_vector(11 downto 0);
    signal s_cfg_fc_cplh              :     std_logic_vector(7 downto 0);
    signal s_cfg_fc_npd               :     std_logic_vector(11 downto 0);
    signal s_cfg_fc_nph               :     std_logic_vector(7 downto 0);
    signal s_cfg_fc_pd                :     std_logic_vector(11 downto 0);
    signal s_cfg_fc_ph                :     std_logic_vector(7 downto 0);

    attribute dont_touch : string;
    --attribute dont_touch of s_cfg_fc_cpld : signal is "true";
    --attribute dont_touch of s_cfg_fc_cplh : signal is "true";
    --attribute dont_touch of s_cfg_fc_npd : signal is "true";
    --attribute dont_touch of s_cfg_fc_nph : signal is "true";
    --attribute dont_touch of s_cfg_fc_pd : signal is "true";
    --attribute dont_touch of s_cfg_fc_ph : signal is "true";

    signal bar0_s: std_logic_vector(31 downto 0);
    signal bar1_s: std_logic_vector(31 downto 0);
    signal bar2_s: std_logic_vector(31 downto 0);
    signal write_cfg_done_1: std_logic;
    signal bar_index : std_logic_vector(2 downto 0);
    
    signal uncor_err_stat: std_logic_vector(31 downto 0); --config register 104
    signal cor_err_stat:   std_logic_vector(31 downto 0); --config register 110
    signal adv_err_cap:    std_logic_vector(31 downto 0); --config register 118
    
    attribute dont_touch of uncor_err_stat : signal is "true";
    attribute dont_touch of cor_err_stat   : signal is "true";
    attribute dont_touch of adv_err_cap    : signal is "true";
    
    
    
    --COMPONENT vio_0
    --  PORT (
    --    clk : IN STD_LOGIC;
    --    probe_in0 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    --    probe_in1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    --    probe_in2 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    --    probe_in3 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    --    probe_in4 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    --    probe_in5 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    --    probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    --    probe_out1 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    --  );
    --END COMPONENT;
begin

    --vio_inst : vio_0
    --  PORT MAP (
    --    clk => clk,
    --    probe_in0 => s_cfg_fc_pd,
    --    probe_in1 => s_cfg_fc_ph,
    --    probe_in2 => s_cfg_fc_npd,
    --    probe_in3 => s_cfg_fc_nph,
    --    probe_in4 => s_cfg_fc_cpld,
    --    probe_in5 => s_cfg_fc_cplh,
    --    probe_out0(0) => vio_rst_n,
    --    probe_out1    => cfg_fc_sel
    --  );

    cfg_fc_sel <= "100";

    s_cfg_fc_cpld <= cfg_fc_cpld ;
    s_cfg_fc_cplh <= cfg_fc_cplh ;
    s_cfg_fc_npd  <= cfg_fc_npd  ;
    s_cfg_fc_nph  <= cfg_fc_nph  ;
    s_cfg_fc_pd   <= cfg_fc_pd   ;
    s_cfg_fc_ph   <= cfg_fc_ph   ;

    cfg_write_skp_nolfsr : process(clk)
    begin
      if(rising_edge(clk)) then
        bar0 <= bar0_s;
        bar1 <= bar1_s;
        bar2 <= bar2_s;
        bar0_s <= bar0_s;
        bar1_s <= bar1_s;
        bar2_s <= bar2_s;
        
        uncor_err_stat <= uncor_err_stat;
        cor_err_stat   <= cor_err_stat;
        adv_err_cap    <= adv_err_cap;
          
        if (reset = '1') then
          cfg_mgmt_addr        <= "000"&x"0000";
          cfg_mgmt_write_data  <= x"00000000";
          cfg_mgmt_byte_enable <= x"0";
          cfg_mgmt_write       <= '0';
          cfg_mgmt_read        <= '0';
          write_cfg_done_1     <= '0';
          bar_index            <= "000"; 
        elsif(write_cfg_done_1 = '1') then
          case(bar_index) is
            when "000" =>
              --Addresses in cfg_mgmt_addr are the same as addresses in PCIe configuration space, however divided by 4
              cfg_mgmt_addr <= "000"&x"0004"; --read BAR0
              if(cfg_mgmt_read_write_done = '1') then
                bar0_s <= cfg_mgmt_read_data;
                bar_index <= "001";
              end if;
            when "001" =>
              cfg_mgmt_addr <= "000"&x"0005"; --read BAR1
              if(cfg_mgmt_read_write_done = '1') then
                bar1_s <= cfg_mgmt_read_data;
                bar_index <= "010";
              end if;
            when "010" =>
              cfg_mgmt_addr <= "000"&x"0006"; --read BAR2
              if(cfg_mgmt_read_write_done = '1') then
                bar2_s <= cfg_mgmt_read_data;
                bar_index <= "011";
              end if;
            when "011" =>
              cfg_mgmt_addr <= "000"&x"0041"; --read Uncorrectable error status register
              if(cfg_mgmt_read_write_done = '1') then
                uncor_err_stat <= cfg_mgmt_read_data;
                bar_index <= "100";
              end if;
            when "100" =>
              cfg_mgmt_addr <= "000"&x"0044"; --read Correctable error status register
              if(cfg_mgmt_read_write_done = '1') then
                cor_err_stat <= cfg_mgmt_read_data;
                bar_index <= "101";
              end if;
            when "101" =>
              cfg_mgmt_addr <= "000"&x"0046"; --read Advanced error cap and control register
              if(cfg_mgmt_read_write_done = '1') then
                adv_err_cap <= cfg_mgmt_read_data;
                bar_index <= "000";
              end if;
            
            when others =>
              bar_index <= "000";
          end case;
          cfg_mgmt_write_data  <= (others => '0');
          cfg_mgmt_byte_enable <= x"F";
          cfg_mgmt_write       <= '0';
          cfg_mgmt_read        <= '1'; 
        elsif((cfg_mgmt_read_write_done = '1') and (write_cfg_done_1 = '0')) then
          cfg_mgmt_addr        <= "100"&x"0082";
          cfg_mgmt_write_data(31 downto 28) <= cfg_mgmt_read_data(31 downto 28);
          cfg_mgmt_write_data(27)    <= '1'; 
          cfg_mgmt_write_data(26 downto 0)  <= cfg_mgmt_read_data(26 downto 0);
          cfg_mgmt_byte_enable <= x"F";
          cfg_mgmt_write       <= '1';
          cfg_mgmt_read        <= '0';
          write_cfg_done_1     <= '1';
        elsif (write_cfg_done_1 = '0') then
          cfg_mgmt_addr        <= "100"&x"0082";
          cfg_mgmt_write_data  <= (others => '0');
          cfg_mgmt_byte_enable <= x"F";
          cfg_mgmt_write       <= '0';
          cfg_mgmt_read        <= '1';  
        end if;
      end if;
    end process;

end architecture rtl ; -- of pcie_init

