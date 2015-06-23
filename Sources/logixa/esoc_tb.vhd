--------------------------------------------------------------------------------
----                                                                        ----
---- Ethernet Switch on Configurable Logic IP Core                          ----
----                                                                        ----
---- This file is part of the ESoCL project                                 ----
---- http://www.opencores.org/cores/esoc/                                   ----
----                                                                        ----
---- Description: see design description ESoCL_dd_71022001.pdf              ----
----                                                                        ----
---- To Do: see roadmap description ESoCL_dd_71022001.pdf                   ----
----        and/or release bulleting ESoCL_rb_71022001.pdf                  ----
----                                                                        ----
---- Author(s): L.Maarsen                                                   ----
---- Bert Maarsen, lmaarsen@opencores.org                                   ----
----                                                                        ----
--------------------------------------------------------------------------------
----                                                                        ----
---- Copyright (C) 2009 Authors and OPENCORES.ORG                           ----
----                                                                        ----
---- This source file may be used and distributed without                   ----
---- restriction provided that this copyright statement is not              ----
---- removed from the file and that any derivative work contains            ----
---- the original copyright notice and the associated disclaimer.           ----
----                                                                        ----
---- This source file is free software; you can redistribute it             ----
---- and/or modify it under the terms of the GNU Lesser General             ----
---- Public License as published by the Free Software Foundation;           ----
---- either version 2.1 of the License, or (at your option) any             ----
---- later version.                                                         ----
----                                                                        ----
---- This source is distributed in the hope that it will be                 ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied             ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR                ----
---- PURPOSE. See the GNU Lesser General Public License for more            ----
---- details.                                                               ----
----                                                                        ----
---- You should have received a copy of the GNU Lesser General              ----
---- Public License along with this source; if not, download it             ----
---- from http://www.opencores.org/lgpl.shtml                               ----
----                                                                        ----
--------------------------------------------------------------------------------
-- Object        : Entity work.esoc_tb
-- Last modified : Mon Apr 14 12:50:20 2014.
--------------------------------------------------------------------------------



library ieee, std, work;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use work.package_crc32_8b.all;
use work.package_esoc_configuration.all;
use work.package_txt_utilities.all;

entity esoc_tb is
end entity esoc_tb;

--------------------------------------------------------------------------------
-- Object        : Architecture work.esoc_tb.esoc_tb
-- Last modified : Mon Apr 14 12:50:20 2014.
--------------------------------------------------------------------------------

architecture esoc_tb of esoc_tb is

  type smi_states is (start, preamble, cmd, dev_addr, reg_addr, ta_cycles, data,store);

  signal esoc_wait_timer_start  : std_logic; -- Used by CONTROL testbench to protect bus cycles from freezing
  signal esoc_wait_time_enable  : std_logic;
  signal esoc_wait_timer        : integer; -- Used by CONTROL testbench to protect bus cycles from freezing
  signal esoc_wait_timeout      : std_logic; -- Used by CONTROL testbench to protect bus cycles from freezing
  signal esoc_rgmii_rxc_int     : std_logic; -- Used by RGMII testbench
  signal esoc_rgmii_txc_int     : std_logic_vector(esoc_port_count-1 downto 0); -- Used by RGMII testbench
  signal reg_rgmii_port_enable  : std_logic_vector(31 downto 0); -- Used by RGMII testbench, under control of CONTROL testbench
  signal reg_rgmii_port_enable2 : std_logic_vector(31 downto 0); -- Used by RGMII testbench, under control of CONTROL testbench
  signal smi_mdio               : std_logic_vector(esoc_port_count-1 downto 0);
  signal smi_mdio_ena           : std_logic_vector(esoc_port_count-1 downto 0);
  signal esoc_wait              : std_logic;
  signal esoc_rgmii_txc         : std_logic_vector(esoc_port_count-1 downto 0);
  signal esoc_rgmii_rxd         : std_logic_vector(3+4*(esoc_port_count-1) downto 0);
  signal esoc_rgmii_rxctl       : std_logic_vector(esoc_port_count-1 downto 0);
  signal esoc_rgmii_rxc         : std_logic_vector(esoc_port_count-1 downto 0);
  signal esoc_address           : std_logic_vector(15 downto 0);
  signal esoc_wr                : std_logic;
  signal esoc_data              : std_logic_vector(31 downto 0);
  signal esoc_rd                : std_logic;
  signal esoc_areset            : std_logic;
  signal esoc_cs                : std_logic;
  signal esoc_clk               : std_logic;
  signal esoc_rgmii_txctl       : std_logic_vector(esoc_port_count-1 downto 0);
  signal esoc_rgmii_txd         : std_logic_vector(3+4*(esoc_port_count-1) downto 0);
  signal esoc_boot_complete     : std_logic;
  signal esoc_mdio              : std_logic_vector(esoc_port_count-1 downto 0);
  signal esoc_mdc               : std_logic_vector(esoc_port_count-1 downto 0);

  component esoc
    port(
      esoc_address       : in     std_logic_vector(15 downto 0);
      esoc_areset        : in     std_logic;
      esoc_boot_complete : out    std_logic;
      esoc_clk           : in     std_logic;
      esoc_cs            : in     std_logic;
      esoc_data          : inout  std_logic_vector(31 downto 0);
      esoc_mdc           : out    std_logic_vector(esoc_port_count-1 downto 0);
      esoc_mdio          : inout  std_logic_vector(esoc_port_count-1 downto 0);
      esoc_rd            : in     std_logic;
      esoc_rgmii_rxc     : in     std_logic_vector(esoc_port_count-1 downto 0);
      esoc_rgmii_rxctl   : in     std_logic_vector(esoc_port_count-1 downto 0);
      esoc_rgmii_rxd     : in     std_logic_vector(3+4*(esoc_port_count-1) downto 0);
      esoc_rgmii_txc     : out    std_logic_vector(esoc_port_count-1 downto 0);
      esoc_rgmii_txctl   : out    std_logic_vector(esoc_port_count-1 downto 0);
      esoc_rgmii_txd     : out    std_logic_vector(3+4*(esoc_port_count-1) downto 0);
      esoc_wait          : out    std_logic;
      esoc_wr            : in     std_logic);
  end component esoc;

begin
  esoc_test_rgmii_loggers: for esoc_port_nr in esoc_port_count-1 downto 0 generate
  begin

    esoc_test_rgmii_logger: process		-- EASE/HDL sens.list
                            begin
                            wait;
                            end process esoc_test_rgmii_logger ;
    -- create shifted txc clock                        
    esoc_rgmii_txc_int <= esoc_rgmii_txc after 2 ns;

    --=============================================================================================================
    -- Process		  : store all packets on RGMII RX interfaces
    -- Description	: 
    --=============================================================================================================                       
    esoc_rgmii_rx_logging:  process(esoc_rgmii_rxc, esoc_areset)
          						        -- declare file for rgmii interface logging
          						        file esoc_rgmii_rx_log : TEXT open WRITE_MODE is "../../Simulation/Logs/esoc_rgmii_test_rx_port_" & to_string(esoc_port_nr) & "_log.txt";
           		          
          		                variable esoc_rgmii_rx_buffer: LINE;
          		                
          		                variable byte: std_logic_vector(7 downto 0);
          		                variable byte_counter: integer;
          		                variable rx_state: std_logic;
          		          
          						      begin
          						        if esoc_areset = '1' then
          						          byte_counter := 0;
          						          rx_state := '0';
          						        
          						        elsif esoc_rgmii_rxc(esoc_port_nr)'event and esoc_rgmii_rxc(esoc_port_nr) = '1' then
          						          if esoc_rgmii_rxctl(esoc_port_nr) = '1' then
          						            rx_state := '1';
            						          byte(3 downto 0) := esoc_rgmii_rxd(esoc_port_nr*4+3 downto esoc_port_nr*4);
            						          
            						        elsif rx_state = '1' then
            						          rx_state := '0';
            						          byte_counter := 0;
            						          write(esoc_rgmii_rx_buffer,string'("")); 
            						          writeline(esoc_rgmii_rx_log, esoc_rgmii_rx_buffer); 
            						          writeline(esoc_rgmii_rx_log, esoc_rgmii_rx_buffer); 
                                end if;
                                
                              elsif esoc_rgmii_rxc(esoc_port_nr)'event and esoc_rgmii_rxc(esoc_port_nr) = '0' then
                                if esoc_rgmii_rxctl(esoc_port_nr) = '1' and rx_state = '1' then
            						          byte(7 downto 4) := esoc_rgmii_rxd(esoc_port_nr*4+3 downto esoc_port_nr*4);
            						          write(esoc_rgmii_rx_buffer, to_hexstring(byte) & " ");    
            						          
            						          if byte_counter = 15 then
            						            byte_counter := 0;
            						            writeline(esoc_rgmii_rx_log, esoc_rgmii_rx_buffer); 
            						          else
            						            byte_counter := byte_counter + 1;
                                  end if;
                                end if;
                              end if;
                            end process esoc_rgmii_rx_logging;

    --=============================================================================================================
    -- Process		  : store all packets on RGMII TX interfaces
    -- Description	: 
    --=============================================================================================================
    esoc_rgmii_tx_logging:  process(esoc_rgmii_txc_int, esoc_areset)
          						        -- declare file for rgmii interface logging
          						        file esoc_rgmii_tx_log : TEXT open WRITE_MODE is "../../Simulation/Logs/esoc_rgmii_test_tx_port_" & to_string(esoc_port_nr) & "_log.txt";

          		                variable esoc_rgmii_tx_buffer: LINE;
          		                
          		                variable byte: std_logic_vector(7 downto 0);
          		                variable byte_counter: integer;
          		                variable tx_state: std_logic;
          		          
          						      begin
          						        if esoc_areset = '1' then
          						          byte_counter := 0;
          						          tx_state := '0';
          						        
          						        elsif esoc_rgmii_txc_int(esoc_port_nr)'event and esoc_rgmii_txc_int(esoc_port_nr) = '1' then
          						          if esoc_rgmii_txctl(esoc_port_nr) = '1' then
          						            tx_state := '1';
            						          byte(3 downto 0) := esoc_rgmii_txd(esoc_port_nr*4+3 downto esoc_port_nr*4);
            						          
            						        elsif tx_state = '1' then
            						          tx_state := '0';
            						          byte_counter := 0;
            						          write(esoc_rgmii_tx_buffer,string'("")); 
            						          writeline(esoc_rgmii_tx_log, esoc_rgmii_tx_buffer); 
            						          writeline(esoc_rgmii_tx_log, esoc_rgmii_tx_buffer); 

                                end if;
                                
                              elsif esoc_rgmii_txc_int(esoc_port_nr)'event and esoc_rgmii_txc_int(esoc_port_nr) = '0' then
                                if esoc_rgmii_txctl(esoc_port_nr) = '1' and tx_state = '1' then
            						          byte(7 downto 4) := esoc_rgmii_txd(esoc_port_nr*4+3 downto esoc_port_nr*4);
            						          write(esoc_rgmii_tx_buffer, to_hexstring(byte) & " ");    
            						          
            						          if byte_counter = 15 then
            						            byte_counter := 0;
            						            writeline(esoc_rgmii_tx_log, esoc_rgmii_tx_buffer); 
            						          else
            						            byte_counter := byte_counter + 1;
                                  end if;
                                end if;
                              end if;
                            end process esoc_rgmii_tx_logging;
  end generate esoc_test_rgmii_loggers;
  esoc_test_smi: for esoc_port_nr in esoc_port_count-1 downto 0 generate
  begin

    esoc_test_smi: process (esoc_mdio, esoc_mdc, esoc_areset) is		-- EASE/HDL sens.list
                      variable smi_cmd      : std_logic_vector(1 downto 0);
                      variable smi_dev_addr : std_logic_vector(4 downto 0);
                      variable smi_dev_reg  : std_logic_vector(4 downto 0);
                      variable smi_data     : std_logic_vector(15 downto 0);
                      
                      variable smi_counter : integer;
                      
                      variable smi_registers: std_logic_vector(511 downto 0);
                      
                   
                      variable smi_state : smi_states;
                      
                    begin
                      if esoc_areset = '1' then
                        smi_cmd       := (others => '0');
                        smi_dev_addr  := (others => '0');
                        smi_dev_reg   := (others => '0');
                        smi_data      := (others => '0');
                        
                        smi_registers := (others => '0');

                        smi_mdio(esoc_port_nr)      <= '0';
                        smi_mdio_ena(esoc_port_nr)  <= '0';
                        
                        smi_counter   := 31;
                        smi_state     := preamble;
                                          
                      elsif esoc_mdc(esoc_port_nr)'event and esoc_mdc(esoc_port_nr) = '1' then
          
                        case smi_state is
                          when preamble =>  -- detect preamble of 32 ones
                                            if esoc_mdio(esoc_port_nr) = '1' then
                                              if smi_counter = 0 then
                                                smi_counter := 1;
                                                smi_state   := start;
                                              else
                                                smi_counter := smi_counter - 1;
                                              end if;
                                              
                                            else
                                              smi_counter := 31;
                                            end if;
                                              
                          when start    =>  -- detect two start bits, if valid continue else back
                                            if smi_counter = 1 then
                                              if  esoc_mdio(esoc_port_nr) = '0' then
                                                smi_counter := smi_counter - 1;
                                              end if;
                                              
                                            elsif smi_counter = 0 then
                                              if  esoc_mdio(esoc_port_nr) = '1' then
                                                smi_counter := 1;
                                                smi_state   := cmd;
                                                
                                              else 
                                                smi_counter := 31;
                                                smi_state   := preamble;
                                              end if;
                                            end if;  
                          
                          when cmd      =>  smi_cmd(smi_counter) := esoc_mdio(esoc_port_nr);
                          
                                            if smi_counter = 0 then
                                              smi_counter := 4;
                                              smi_state   := dev_addr;
                                            else
                                              smi_counter := smi_counter - 1;
                                            end if;
                          
                          
                          when dev_addr =>  smi_dev_addr(smi_counter) := esoc_mdio(esoc_port_nr);
                                            
                                            if smi_counter = 0 then
                                              smi_counter := 4;
                                              smi_state   := reg_addr;
                                            else
                                              smi_counter := smi_counter - 1;
                                            end if;
                          
                          when reg_addr =>  smi_dev_reg(smi_counter) := esoc_mdio(esoc_port_nr);
                                            
                                            if smi_counter = 0 then
                                              smi_counter := 1;
                                              smi_state   := ta_cycles;
                                            else
                                              smi_counter := smi_counter - 1;
                                            end if;
                          
                          when ta_cycles =>  -- check device address
                                             if smi_dev_addr /= std_logic_vector(to_unsigned(esoc_port_nr,smi_dev_addr'length)) then
                                               smi_counter := 31;
                                               smi_state   := preamble;
                                               
                                             elsif smi_counter = 0 then
                                               smi_mdio(esoc_port_nr) <= smi_data(smi_data'high);
                                               smi_data := smi_data(smi_data'high-1 downto 0) & '0';
                                               smi_counter := 15;
                                               smi_state   := data; 
                                              
                                             else
                                               -- SMI Read, prepare
                                               if smi_cmd = "10" then
                                                 smi_data := smi_registers((to_integer(unsigned(smi_dev_reg))*16)+15 downto (to_integer(unsigned(smi_dev_reg))*16));
                                                 smi_mdio(esoc_port_nr) <= '0';
                                                 smi_mdio_ena(esoc_port_nr) <= '1';   
                                               end if;
                                              
                                               smi_counter := smi_counter - 1;
                                             end if;
                                            
                          when data     =>  -- SMI Read, provide data
                                            if smi_cmd = "10" then
                                              smi_mdio(esoc_port_nr) <= smi_data(smi_data'high);
                                              smi_data := smi_data(smi_data'high-1 downto 0) & '0';
                                            
                                            -- SMI Write, store data
                                            else
                                              smi_data := smi_data(smi_data'high-1 downto 0) & esoc_mdio(esoc_port_nr);
                                            end if;
                                            
                                            if smi_counter = 0 then
                                              smi_counter := 31;
                                              smi_mdio_ena(esoc_port_nr) <= '0';
                                              
                                              -- SMI Read, return to preamble; SMI Write, store data
                                              if smi_cmd = "10" then
                                                smi_state   := preamble;
                                              else
                                                smi_state   := store;
                                              end if;
                                              
                                            else
                                              smi_counter := smi_counter - 1;
                                            end if;  
                                             
                          when store    =>  -- store received data
                                            smi_registers((to_integer(unsigned(smi_dev_reg))*16)+15 downto (to_integer(unsigned(smi_dev_reg))*16)) := smi_data;
                                            smi_state   := preamble;
                                            
                          when others   =>  smi_state     := preamble;
                        end case;
                        
                      end if;
                    end process esoc_test_smi ;
                    
                    -- drive the mdio line when enabled
                    esoc_mdio(esoc_port_nr) <= smi_mdio(esoc_port_nr) when smi_mdio_ena(esoc_port_nr) = '1'  else 'Z';
  end generate esoc_test_smi;
  esoc_tb: esoc
    port map(
      esoc_address       => esoc_address,
      esoc_areset        => esoc_areset,
      esoc_boot_complete => esoc_boot_complete,
      esoc_clk           => esoc_clk,
      esoc_cs            => esoc_cs,
      esoc_data          => esoc_data,
      esoc_mdc           => esoc_mdc,
      esoc_mdio          => esoc_mdio,
      esoc_rd            => esoc_rd,
      esoc_rgmii_rxc     => esoc_rgmii_rxc,
      esoc_rgmii_rxctl   => esoc_rgmii_rxctl,
      esoc_rgmii_rxd     => esoc_rgmii_rxd,
      esoc_rgmii_txc     => esoc_rgmii_txc,
      esoc_rgmii_txctl   => esoc_rgmii_txctl,
      esoc_rgmii_txd     => esoc_rgmii_txd,
      esoc_wait          => esoc_wait,
      esoc_wr            => esoc_wr);



  --=============================================================================================================
  -- Process		  : 
  -- Description	: 
  --=============================================================================================================
  esoc_test_control: process		-- EASE/HDL sens.list
  						begin
  						wait;
  						end process esoc_test_control ;
  						
  --=============================================================================================================
  -- Process		  : generate esoc input reset
  -- Description	: 
  --=============================================================================================================
  esoc_reset: process
  						-- EASE/HDL sens.list
              begin
                esoc_areset <= '1';
                wait for 1 us;
                esoc_areset <= '0'; 
                assert false report "ESOC Reset -> reset released" severity note;
                wait;
              end process esoc_reset ;
              
  --=============================================================================================================
  -- Process		  : generate esoc control input clock
  -- Description	: 
  --=============================================================================================================
  esoc_ctrl_clock:  process
        		        -- EASE/HDL sens.list
                    begin
                      esoc_clk <= '1';
                      wait for 10 ns;
                      esoc_clk <= '0'; 
                      wait for 10 ns;
                    end process esoc_ctrl_clock ;

  --=============================================================================================================
  -- Process		  : generate input for the esoc control interface
  -- Description	: 
  --=============================================================================================================
  esoc_ctrl: 	process
  						-- EASE/HDL sens.list
  							-- declare files for control interface stimuli and logging
  						  file esoc_ctrl_out: TEXT open WRITE_MODE is "../../Simulation/Logs/esoc_control_test_log.txt";
  						  file esoc_ctrl_in : TEXT open READ_MODE  is "../../Simulation/Scripts/esoc_control_test_stim.txt";
  						  file esoc_control_auto_log : TEXT open APPEND_MODE  is "../../Simulation/Logs/auto/esoc_control_auto_log.txt";
    						
    						-- declare buffers for a complete line from file
    						variable esoc_ctrl_in_buffer: LINE;
    						variable esoc_ctrl_out_buffer: LINE;
    						variable esoc_control_auto_log_buffer: LINE;
    						
    						-- define fields in a line (only white spaces before first field are skipped)
    						variable esoc_ctrl_in_id : string(7 downto 1);
    						variable esoc_ctrl_in_cmd : string(2 downto 1);
    						variable esoc_ctrl_in_addr: string(5 downto 1);
    						variable esoc_ctrl_in_val : string(9 downto 1);
    						variable esoc_ctrl_out_val : string(9 downto 1);
    						variable esoc_ctrl_in_info : string(40 downto 1);
    						variable esoc_ctrl_wait : integer;
    						
    						variable error_counter: integer;
    						
    					begin
              
                -- init control interface inputs
              	esoc_cs <= '0';
              	esoc_wr <= '0';
  							esoc_rd <= '0';
  							esoc_address <= (others => '0');
  							esoc_data  <= (others => 'Z');
  							esoc_wait_timer_start <= '0';
  							error_counter := 0;
  							
  							-- wait for de-assertion of external reset
  							wait until esoc_areset = '0';
  							
  							-- wait for assertion of boot status
  							wait until esoc_boot_complete = '1';
  							wait for 1 us;
  							
  							-- read stimuli ID
  							readline(esoc_ctrl_in, esoc_ctrl_in_buffer);
  							read(esoc_ctrl_in_buffer, esoc_ctrl_in_cmd);
  							read(esoc_ctrl_in_buffer, esoc_ctrl_in_id);

  							-- start access on control interface
  							assert false report "ESOC Control -> generate read/write cycles on control interface" severity note;
  							write(esoc_ctrl_out_buffer, string'("ESOC Control -> start generating read/write cycles on control interface"));
    						writeline(esoc_ctrl_out, esoc_ctrl_out_buffer);
  							
  							-- read file until end of file is reached
  							loop 
  							  exit when endfile(esoc_ctrl_in);
  							  -- read command before reading the arguments
  								readline(esoc_ctrl_in, esoc_ctrl_in_buffer);
  								read(esoc_ctrl_in_buffer, esoc_ctrl_in_cmd);
  								
  								--
  								-- start WRITE CYCLE
  								--
  								if esoc_ctrl_in_cmd = "mw" then
  								  -- read address and data from file
  								  read(esoc_ctrl_in_buffer, esoc_ctrl_in_addr);
  								  read(esoc_ctrl_in_buffer, esoc_ctrl_in_val);
  								  
  								  -- drive the control interface
  								  wait for 30 ns;
  								  esoc_cs <= '1';
  								  esoc_wr <= '1';
  								  esoc_address <= hex_string_to_std_logic_vector(esoc_ctrl_in_addr(4 downto 1));
  								  esoc_data  <= hex_string_to_std_logic_vector(esoc_ctrl_in_val(8 downto 1));
  								  
  								  -- enable timer to avoid lockup
  								  esoc_wait_timer_start <= '1';
  								  wait until esoc_wait = '0' or esoc_wait_timeout = '1';
  								  
  								  -- check for timeout
  								  if esoc_wait_timeout = '0' then
  								    esoc_wait_timer_start <= '0';
  								  end if;
  								  
  								  -- finalize cycle
  								  wait for 20 ns;
  								  esoc_cs <= '0';
  								  esoc_wr <= '0';
  								  esoc_data  <= (others => 'Z');
  								  
  								  -- report time out
  								  if esoc_wait_timeout = '1'  then
  								    esoc_wait_timer_start <= '0';
  								    -- write control bus access to output file
    								  assert false report "ESOC Control -> write to address" & esoc_ctrl_in_addr & "h" & esoc_ctrl_out_val & "h, status: TIMEOUT" severity error;
    								  write(esoc_ctrl_out_buffer, esoc_ctrl_in_cmd & esoc_ctrl_in_addr & esoc_ctrl_out_val & ", status: TIMEOUT");
    								  writeline(esoc_ctrl_out, esoc_ctrl_out_buffer);
    								  
    								else
    								  -- write control bus access to output file
    								  assert false report "ESOC Control -> write" & esoc_ctrl_in_val  & "h" & " to address" & esoc_ctrl_in_addr  & "h" severity note;
    								  write(esoc_ctrl_out_buffer, esoc_ctrl_in_cmd & esoc_ctrl_in_addr & esoc_ctrl_in_val);
    								  writeline(esoc_ctrl_out, esoc_ctrl_out_buffer);
  								  end if;
  								  
  								--  
  								-- start READ CYCLE
  								--
  								elsif esoc_ctrl_in_cmd = "mr" then
  								  -- read address and data from file
  								  read(esoc_ctrl_in_buffer, esoc_ctrl_in_addr);
  								  read(esoc_ctrl_in_buffer, esoc_ctrl_in_val);
  								  
  								  -- drive the control interface
  								  wait for 30 ns;
  								  esoc_cs <= '1';
  								  esoc_rd <= '1';
  								  esoc_address <= hex_string_to_std_logic_vector(esoc_ctrl_in_addr(4 downto 1));
  								  
  								  -- enable timer to avoid lockup
  								  esoc_wait_timer_start <= '1';
  								  wait until esoc_wait = '0' or esoc_wait_timeout = '1';
  								  
  								   -- check for timeout
  								  if esoc_wait_timeout = '0' then
  								    esoc_wait_timer_start <= '0';
  								  end if;
  								  
  								  -- finalize cycle
  								  wait for 20 ns;
                    esoc_cs <= '0';
  								  esoc_rd <= '0';
  								  
  								  -- store read data, add space in front to be able to compare to expected value from file
  								  esoc_ctrl_out_val(8 downto 1) := to_hexstring(esoc_data);
  								  esoc_ctrl_out_val := " " & esoc_ctrl_out_val(8 downto 1);
  								  
  								  -- check expected read value with actual read value or report time out
  								  if esoc_wait_timeout = '1'  then
  								    esoc_wait_timer_start <= '0';
  								    -- write control bus access to output file
    								  assert false report "ESOC Control -> read from address" & esoc_ctrl_in_addr & "h" & esoc_ctrl_out_val & "h, expected" & ", status: TIMEOUT" severity error;
    								  write(esoc_ctrl_out_buffer, esoc_ctrl_in_cmd & esoc_ctrl_in_addr & esoc_ctrl_out_val & ", status: TIMEOUT");
    								  writeline(esoc_ctrl_out, esoc_ctrl_out_buffer);
  								  
  								  elsif esoc_ctrl_in_val = esoc_ctrl_out_val then
  								    -- write control bus access to output file
    								  assert false report "ESOC Control -> read from address" & esoc_ctrl_in_addr & "h" & esoc_ctrl_out_val & "h, expected" & esoc_ctrl_in_val & "h, status: OK" severity note;
    								  write(esoc_ctrl_out_buffer, esoc_ctrl_in_cmd & esoc_ctrl_in_addr & esoc_ctrl_out_val & ", expected" & esoc_ctrl_in_val & ", status: OK");
    								  writeline(esoc_ctrl_out, esoc_ctrl_out_buffer);
  								  else
  								    -- write control bus access to output file
    								  assert false report "ESOC Control -> read from address" & esoc_ctrl_in_addr & "h" & esoc_ctrl_out_val & "h, expected" & esoc_ctrl_in_val & "h, status: ERROR" severity note;
    								  write(esoc_ctrl_out_buffer, esoc_ctrl_in_cmd & esoc_ctrl_in_addr & esoc_ctrl_out_val & ", expected" & esoc_ctrl_in_val & ", status: ERROR");
    								  writeline(esoc_ctrl_out, esoc_ctrl_out_buffer);
    								  error_counter := error_counter + 1;
  								  end if;
  								
  								--								  
  								-- create delay 
  								--
  								elsif esoc_ctrl_in_cmd = "wt" then
  								  read(esoc_ctrl_in_buffer, esoc_ctrl_wait);
  								  for i in esoc_ctrl_wait downto 0 loop
  								    wait until esoc_clk'event and esoc_clk = '1';
  								  end loop;
  								  
  								--								  
  								-- process information 
  								--
  								elsif esoc_ctrl_in_cmd = "--" then
  								  writeline(esoc_ctrl_out, esoc_ctrl_in_buffer);
  								
  								-- ignore other commands  
  								else
  								  assert false report "ESOC Control -> illegal command for read/write cycles on control interface" severity error;
  								  write(esoc_ctrl_out_buffer, string'("ESOC Control -> illegal command for read/write cycles on control interface"));
    								writeline(esoc_ctrl_out, esoc_ctrl_out_buffer);
  								end if;
  							end loop;
  							
  							if error_counter = 1 then
  							  assert false report "ESOC Control -> end of stimuli for control interface (" & to_string(error_counter,10) & " error)" severity note;
  							else
  							  assert false report "ESOC Control -> end of stimuli for control interface (" & to_string(error_counter,10) & " errors)" severity note;
  							end if;
  							
  							--write(esoc_ctrl_out_buffer, string'("ESOC Control -> end of stimuli for control interface")& error_counter & " errors)");
  							write(esoc_ctrl_out_buffer, string'("ESOC Control -> end of stimuli for control interface (") & to_string(error_counter,10) & " errors)");
    					  writeline(esoc_ctrl_out, esoc_ctrl_out_buffer);
  							
  							write(esoc_control_auto_log_buffer, "Test script" & esoc_ctrl_in_id & " - " & to_string(error_counter,10) & " errors");
    					  writeline(esoc_control_auto_log, esoc_control_auto_log_buffer);
    					  
  							wait;
              end process esoc_ctrl ;

  --=============================================================================================================
  -- Process		  : start timer when previous process waits for signal from esoc
  -- Description	: 
  --=============================================================================================================
  esoc_ctrl_timer: 	process (esoc_areset, esoc_clk)
                    begin
                      if esoc_areset = '1'  then
                        esoc_wait_timer <= 3000;
                        esoc_wait_timeout <= '0';
                        esoc_wait_time_enable <= '1';
                        
                      elsif esoc_clk = '1'  and esoc_clk'event then
                        if esoc_wait_time_enable = '1' then
                          -- start timer on command of read/write process
                          if esoc_wait_timer_start = '1' then
                            -- assert time out signal when timer expires
                            if esoc_wait_timer = 0 then
                              esoc_wait_timeout <= '1';
                            else
                              esoc_wait_timer <= esoc_wait_timer - 1;
                            end if;
                          
                          -- reset timer settings when timer is stopped by read/write process  
                          else
                            esoc_wait_timeout <= '0';
                            esoc_wait_timer <= 3000;
                          end if;
                        end if;
                      end if;
                    end process esoc_ctrl_timer;



  --=============================================================================================================
  -- Process		  : 
  -- Description	: 
  --=============================================================================================================
  esoc_test_rgmii: process		-- EASE/HDL sens.list
  						begin
  						wait;
  						end process esoc_test_rgmii ;
  						
  --=============================================================================================================
  -- Process		  : generate esoc rgmii input clock
  -- Description	: 
  --=============================================================================================================
  esoc_rgmii_clock: process
        		        -- EASE/HDL sens.list
                    begin
                      -- create internal and external RGMII clock, phase shift of 90 degrees
                      for i in esoc_port_count-1 downto 0 loop
                        esoc_rgmii_rxc_int <= '1';
                        esoc_rgmii_rxc(i)  <= '1' after 2 ns;
                      end loop;
                      
                      wait for 4 ns;
                     
                      for i in esoc_port_count-1 downto 0 loop
                        esoc_rgmii_rxc_int <= '0';
                        esoc_rgmii_rxc(i)  <= '0' after 2 ns;
                      end loop;
                      
                      wait for 4 ns;
                    end process esoc_rgmii_clock ;						

  --=============================================================================================================
  -- Process		  : access registers of testbench
  -- Description	: 
  --=============================================================================================================    
  registers:  process(esoc_areset, esoc_cs, esoc_rd, esoc_wr)
                variable esoc_rd_pending: std_logic;
                variable esoc_wr_pending: std_logic;
              begin
                if esoc_areset = '1' then
                  reg_rgmii_port_enable <= (others => '0');
                  esoc_wait <= 'Z';
                  esoc_data <= (others => 'Z');
                  esoc_rd_pending := '0';
                  esoc_wr_pending := '0';
                                
                -- continu if memory space of this entity is addressed
                elsif to_integer(unsigned(esoc_address)) >= esoc_testbench_base and to_integer(unsigned(esoc_address)) < esoc_testbench_base + esoc_testbench_size then
                  --
                  -- READ CYCLE started, unit addressed?
                  --
                  if esoc_cs = '1' and esoc_rd = '1' and esoc_rd_pending = '0' then
                    -- Check register address and provide data when addressed
                    case to_integer(unsigned(esoc_address)) - esoc_testbench_base is
                      when 0          =>   esoc_data <= reg_rgmii_port_enable after 40 ns;
                      
                      when others     =>   esoc_data <= (others => '0');
                    end case;
                    
                    esoc_rd_pending := '1';
                    esoc_wait <= '0' after 40 ns;
                  
                  -- wait until cycle is finished                  
                  elsif esoc_cs = '0' and esoc_rd = '0' and esoc_rd_pending = '1' then
                    esoc_rd_pending := '0';
                    
                    -- finalize cycle
                    esoc_wait <= 'Z' after 20 ns;
                    esoc_data <= (others => 'Z') after 20 ns;
                  
                  --
                  -- WRITE CYCLE started, unit addressed?  
                  --
                  elsif esoc_cs = '1' and esoc_wr = '1' and esoc_wr_pending = '0' then
                  	-- Check register address and accept data when addressed
                  	case to_integer(unsigned(esoc_address)) - esoc_testbench_base is
                      when 0          =>   reg_rgmii_port_enable <= esoc_data;
                      
                      when others     =>   NULL;
                    end case;
                    
                    esoc_wr_pending := '1';
                    esoc_wait <= '0' after 40 ns;

                  -- wait until cycle is finished
                  elsif esoc_cs = '0' and esoc_wr = '0' and esoc_wr_pending = '1' then
                    -- finalize cycle
                    esoc_wr_pending := '0';
                    esoc_wait <= 'Z' after 20 ns;
    							end if;
    					  end if;
            end process; 
                               
  --=============================================================================================================
  -- Process		  : fill packet transmit buffers for all ports
  -- Description	: 
  --=============================================================================================================
  esoc_rgmii_tx:    process
        						  -- declare files for rgmii interface stimuli and logging
        						  file esoc_rgmii_in : TEXT open READ_MODE  is "../../Simulation/Scripts/esoc_rgmii_test_stim.txt";
        		          file esoc_rgmii_out: TEXT open WRITE_MODE is "../../Simulation/Logs/esoc_rgmii_test_log.txt";
  						        
  						        -- declare buffer for a complete line from file
          						variable esoc_rgmii_in_buffer: LINE;
          						variable esoc_rgmii_out_buffer: LINE;  		
          						
          						-- define fields in a line
          						variable esoc_rgmii_in_port   : string(2 downto 1);
          						variable esoc_rgmii_in_dmac   : string(12 downto 1);
          						variable esoc_rgmii_in_smac   : string(12 downto 1);
          						variable esoc_rgmii_in_vid    : string(8 downto 1);
          						variable esoc_rgmii_in_type   : string(4 downto 1);
          						variable esoc_rgmii_in_plen   : string(4 downto 1);
          						variable esoc_rgmii_in_pstart : string(2 downto 1);
          						variable esoc_rgmii_in_gap    : string(8 downto 1);
          						variable esoc_rgmii_in_white_space : string(1 downto 1);
          						
          						variable esoc_rgmii_in_wait   : integer;
          					  
          					  -- create packet buffers for all ports (use variable to avoid slow simulations)
          					  constant packet_buffer_size           : integer := 64*1024;
          						
          						type     packet_buffer_array is array (esoc_port_count-1 downto 0, packet_buffer_size-1 downto 0) of std_logic_vector(8 downto 0);
          						variable packet_buffers               : packet_buffer_array; 
                      
                      constant pck_type_ipg: std_logic := '0';
                      constant pck_type_pck: std_logic := '1';
                      
                      -- create packet counter for all ports (use variable to avoid slow simulations)
                      type     packet_buffer_bytes_array is array (esoc_port_count-1 downto 0) of integer;
                      variable packet_buffer_bytes              : packet_buffer_bytes_array; 
                      variable packet_buffer_bytes_sent         : packet_buffer_bytes_array; 
                      
                      -- create inter packet gap counter for all ports (use variable to avoid slow simulations)
                      type     packet_ipg_array is array (esoc_port_count-1 downto 0) of integer;
                      variable packet_ipg : packet_ipg_array; 
                      
                      -- signals and variables for inside process
                      variable esoc_rgmii_port : integer;
                      variable esoc_rgmii_count : integer;
                      variable esoc_rgmii_data : std_logic_vector(47 downto 0);
                      
                      variable esoc_rgmii_crc : std_logic_vector(31 downto 0);
                      
                    begin
                      --
                      -- initialize signals, buffers and clear counters
                      --
          					  for i in esoc_port_count-1 downto 0 loop
          					    packet_buffer_bytes(i) := 0;
          					    packet_buffer_bytes_sent(i) := 0;
          					    
          					    esoc_rgmii_rxctl(i) <= '0';
          					    esoc_rgmii_rxd(i*4+3 downto i*4) <= (others => '0');
          					    
          					    packet_ipg(i) := 0;
          					    
          					    for j in packet_buffer_size-1 downto 0 loop
          					      packet_buffers(i,j) := '0' & X"00";  
          					    end loop;
          					  end loop;
          					  
          					  reg_rgmii_port_enable2 <= (others => '0');
          					  
          					  -- wait for de-assertion of external reset
        							wait until esoc_areset = '0';
        							wait for 1 us;
        							
        							--
        							-- start preprocessing of Ethernet packets
        							--
                      assert false report "ESOC RGMII Preprocessing -> start of processing stimuli for RGMII interfaces" severity note;
        							write(esoc_rgmii_out_buffer, string'("ESOC RGMII Preprocessing -> start of processng stimuli for RGMII interfaces"));
    								  writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    					  
          					  loop 
        							  exit when endfile(esoc_rgmii_in);
        							  
        							  -- read packet information, read away the post white space
        								readline(esoc_rgmii_in, esoc_rgmii_in_buffer);
                        read(esoc_rgmii_in_buffer, esoc_rgmii_in_port); 
        								    								
        								-- skip comment
        								if esoc_rgmii_in_port = "--" then
        								
  								      -- check packet information
        							  elsif to_integer(unsigned(hex_string_to_std_logic_vector(esoc_rgmii_in_port))) > esoc_port_count-1 then
                          assert false report "ESOC RGMII Preprocessing -> " & esoc_rgmii_in_port & " is illegal port number in RGMII stimuli (max ESOC Port count is " &  to_string(esoc_port_count-1, 10) & ")" severity error;
        							    write(esoc_rgmii_out_buffer, "ESOC RGMII Preprocessing -> " & esoc_rgmii_in_port & " is illegal port number in RGMII stimuli (max ESOC Port count is " &  to_string(esoc_port_count-1, 10) & ")");
    								      writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);                        
        							  
        							  -- write packet into buffer of correct port
        							  else
        							    -- read packet information, read away the pre white space
        							    read(esoc_rgmii_in_buffer, esoc_rgmii_in_white_space);  read(esoc_rgmii_in_buffer, esoc_rgmii_in_dmac);
          								read(esoc_rgmii_in_buffer, esoc_rgmii_in_white_space);  read(esoc_rgmii_in_buffer, esoc_rgmii_in_smac);
          								read(esoc_rgmii_in_buffer, esoc_rgmii_in_white_space);  read(esoc_rgmii_in_buffer, esoc_rgmii_in_vid);
          								read(esoc_rgmii_in_buffer, esoc_rgmii_in_white_space);  read(esoc_rgmii_in_buffer, esoc_rgmii_in_type);
          								read(esoc_rgmii_in_buffer, esoc_rgmii_in_white_space);  read(esoc_rgmii_in_buffer, esoc_rgmii_in_plen);
          								read(esoc_rgmii_in_buffer, esoc_rgmii_in_white_space);  read(esoc_rgmii_in_buffer, esoc_rgmii_in_pstart);
          								read(esoc_rgmii_in_buffer, esoc_rgmii_in_white_space);  read(esoc_rgmii_in_buffer, esoc_rgmii_in_gap);
        								  
          							  -- convert port number to have index inside the buffer and counter arrays, counter itself is also index inside buffer array
          								esoc_rgmii_port  := to_integer(unsigned(hex_string_to_std_logic_vector(esoc_rgmii_in_port)));
          								
          								-- store current value of byte counter of port before new packet is written
          								esoc_rgmii_count := packet_buffer_bytes(esoc_rgmii_port);
          								
          								-- reset CRC storage
          								esoc_rgmii_crc := (others => '0');
          								
          								-- store preamble and SFD
          								for i in 7 downto 0 loop
          					        -- check and update byte counter related to the port, store data if space available, update crc
          								  if packet_buffer_bytes(esoc_rgmii_port) = packet_buffer_size then
          								    assert false report "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded." severity error;
          								    write(esoc_rgmii_out_buffer, "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded.");
    								          writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    								  
                            else
                              -- write sfd as last byte, write preamble bytes before
                              if i = 0 then
          								      packet_buffers(esoc_rgmii_port, packet_buffer_bytes(esoc_rgmii_port)) := pck_type_pck & X"D5";  
          								    else
          								      packet_buffers(esoc_rgmii_port, packet_buffer_bytes(esoc_rgmii_port)) := pck_type_pck & X"55";  
          								    end if;
          								    
          								    packet_buffer_bytes(esoc_rgmii_port) := packet_buffer_bytes(esoc_rgmii_port) + 1;
           								  end if;
          					      end loop;
          								        								
          								-- store DMAC in buffer
          								esoc_rgmii_data := hex_string_to_std_logic_vector(esoc_rgmii_in_dmac);
          								
          								for i in 5 downto 0 loop
          					        -- check and update byte counter related to the port, store data if space available, update crc
          								  if packet_buffer_bytes(esoc_rgmii_port) = packet_buffer_size then
          								    assert false report "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded." severity error;
          								    write(esoc_rgmii_out_buffer, "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded.");
    								          writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    								  
                            else
          								    packet_buffers(esoc_rgmii_port, packet_buffer_bytes(esoc_rgmii_port)) := pck_type_pck & esoc_rgmii_data(i*8+7 downto i*8);  
          								    packet_buffer_bytes(esoc_rgmii_port) := packet_buffer_bytes(esoc_rgmii_port) + 1;
          								    
          								    
          								    -- invert first four bytes of packet (32 bits of DMAC) before CRC calculation
          								    if i > 1 then
          								      esoc_rgmii_data(i*8+7 downto i*8) := INVERT_CRC32_DATA(esoc_rgmii_data(i*8+7 downto i*8));
          								    end if;
          								    
          								    -- swap bit order in accordance with bit order at physical interface before CRC calculation
          								    esoc_rgmii_data(i*8+7 downto i*8) := SWAP_CRC32_DATA(esoc_rgmii_data(i*8+7 downto i*8));
          								    esoc_rgmii_crc := CALC_CRC32(esoc_rgmii_data(i*8+7 downto i*8),esoc_rgmii_crc);
          								  end if;
          					      end loop;
          					      
          					      -- store SMAC in buffer
          								esoc_rgmii_data := hex_string_to_std_logic_vector(esoc_rgmii_in_smac);
          								
          								for i in 5 downto 0 loop
          					        -- check and update byte counter related to the port, store data if space available, update crc
          								  if packet_buffer_bytes(esoc_rgmii_port) = packet_buffer_size then
          								    assert false report "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded." severity error;
          								    write(esoc_rgmii_out_buffer, "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded.");
    								          writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    								          
          								  else
          								    packet_buffers(esoc_rgmii_port, packet_buffer_bytes(esoc_rgmii_port)) := pck_type_pck & esoc_rgmii_data(i*8+7 downto i*8);  
          								    packet_buffer_bytes(esoc_rgmii_port) := packet_buffer_bytes(esoc_rgmii_port) + 1;
          								    
          								    -- swap bit order in accordance with bit order at physical interface before CRC calculation
          								    esoc_rgmii_data(i*8+7 downto i*8) := SWAP_CRC32_DATA(esoc_rgmii_data(i*8+7 downto i*8));
          								    esoc_rgmii_crc := CALC_CRC32(esoc_rgmii_data(i*8+7 downto i*8),esoc_rgmii_crc);
          								  end if;
          					      end loop;
          					      
          					      -- store VID in buffer (0x8100**** is  VLAN tagged packet)
          					      esoc_rgmii_data(31 downto 0) := hex_string_to_std_logic_vector(esoc_rgmii_in_vid);
          					      
          					      if esoc_rgmii_data(31 downto 16) = X"8100" then
            					      for i in 3 downto 0 loop
            					        -- check and update byte counter related to the port, store data if space available, update crc
            								  if packet_buffer_bytes(esoc_rgmii_port) = packet_buffer_size then
            								    assert false report "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded." severity error;
            								    write(esoc_rgmii_out_buffer, "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded.");
    								            writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    								            
            								  else
            								    packet_buffers(esoc_rgmii_port, packet_buffer_bytes(esoc_rgmii_port)) := pck_type_pck & esoc_rgmii_data(i*8+7 downto i*8);  
            								    packet_buffer_bytes(esoc_rgmii_port) := packet_buffer_bytes(esoc_rgmii_port) + 1;
            								    
            								    -- swap bit order in accordance with bit order at physical interface before CRC calculation
          								      esoc_rgmii_data(i*8+7 downto i*8) := SWAP_CRC32_DATA(esoc_rgmii_data(i*8+7 downto i*8));
            								    esoc_rgmii_crc := CALC_CRC32(esoc_rgmii_data(i*8+7 downto i*8),esoc_rgmii_crc);
            								  end if;
            					      end loop;
            					    end if;
          					      
          					      -- store TYPE/LEN in buffer
          								esoc_rgmii_data(15 downto 0) := hex_string_to_std_logic_vector(esoc_rgmii_in_type);
          								
          								for i in 1 downto 0 loop
          					        -- check and update byte counter related to the port, store data if space available, update crc
          								  if packet_buffer_bytes(esoc_rgmii_port) = packet_buffer_size  then
          								    assert false report "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded." severity error;
          								    write(esoc_rgmii_out_buffer, "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded.");
    								          writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    								          
          								  else
          								    packet_buffers(esoc_rgmii_port, packet_buffer_bytes(esoc_rgmii_port)) := pck_type_pck & esoc_rgmii_data(i*8+7 downto i*8);  
          								    packet_buffer_bytes(esoc_rgmii_port) := packet_buffer_bytes(esoc_rgmii_port) + 1;
          								    
          								    -- swap bit order in accordance with bit order at physical interface before CRC calculation
          								    esoc_rgmii_data(i*8+7 downto i*8) := SWAP_CRC32_DATA(esoc_rgmii_data(i*8+7 downto i*8));
          								    esoc_rgmii_crc := CALC_CRC32(esoc_rgmii_data(i*8+7 downto i*8),esoc_rgmii_crc);
          								  end if;
          					      end loop;

                          -- store payload (if length is sufficient)
                          if to_integer(unsigned(hex_string_to_std_logic_vector(esoc_rgmii_in_plen))) < 46 then
                            assert false report "ESOC RGMII Preprocessing -> payload field too short, should be at least 46 bytes." severity error;
                            write(esoc_rgmii_out_buffer, string'("ESOC RGMII Preprocessing -> payload field too short, should be at least 46 bytes."));
    								        writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    								        
                          else
                            esoc_rgmii_data(7 downto 0) := hex_string_to_std_logic_vector(esoc_rgmii_in_pstart);
                            
            								for i in to_integer(unsigned(hex_string_to_std_logic_vector(esoc_rgmii_in_plen)))-1 downto 0 loop
            					        -- check and update byte counter related to the port, store data if space available, update crc
            								  if packet_buffer_bytes(esoc_rgmii_port) = packet_buffer_size then
            								    assert false report "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded." severity error;
            								    write(esoc_rgmii_out_buffer, "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded.");
    								            writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    								            
            								  else
            								    packet_buffers(esoc_rgmii_port, packet_buffer_bytes(esoc_rgmii_port)) := pck_type_pck & esoc_rgmii_data(7 downto 0);
            								    packet_buffer_bytes(esoc_rgmii_port) := packet_buffer_bytes(esoc_rgmii_port) + 1;
            								    
            								    -- swap bit order in accordance with bit order at physical interface before CRC calculation
          								      esoc_rgmii_data(7 downto 0) := SWAP_CRC32_DATA(esoc_rgmii_data(7 downto 0));
            								    esoc_rgmii_crc := CALC_CRC32(esoc_rgmii_data(7 downto 0),esoc_rgmii_crc);
            								    esoc_rgmii_data(7 downto 0) := SWAP_CRC32_DATA(esoc_rgmii_data(7 downto 0));
            								  end if;
            								  
            								  esoc_rgmii_data(7 downto 0) := std_logic_vector(to_unsigned(to_integer(unsigned(esoc_rgmii_data(7 downto 0)))+1, 8));
            					      end loop;
          								end if;
          								
          								-- store CRC, invert and change order before ...
          								esoc_rgmii_crc := SWAP_CRC32_RESULT(esoc_rgmii_crc);
          								esoc_rgmii_crc := INVERT_CRC32_RESULT(esoc_rgmii_crc);
          								esoc_rgmii_data(31 downto 0) := esoc_rgmii_crc;
          								        								
          								for i in 3 downto 0 loop
          					        -- check and update byte counter related to the port, store data if space available
          								  if packet_buffer_bytes(esoc_rgmii_port) = packet_buffer_size then
          								    assert false report "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded." severity error;
          								    write(esoc_rgmii_out_buffer, "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded.");
    								          writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    								          
          								  else
          								    packet_buffers(esoc_rgmii_port, packet_buffer_bytes(esoc_rgmii_port)) := pck_type_pck & esoc_rgmii_data(i*8+7 downto i*8);
          								    packet_buffer_bytes(esoc_rgmii_port) := packet_buffer_bytes(esoc_rgmii_port) + 1;
          								  end if;
          					      end loop;
          					      
          					      -- store GAP (if length is sufficient)
          					      esoc_rgmii_data(31 downto 0) := hex_string_to_std_logic_vector(esoc_rgmii_in_gap);
          					      
          								if to_integer(unsigned(hex_string_to_std_logic_vector(esoc_rgmii_in_gap))) < 12 then
                            assert false report "ESOC RGMII Preprocessing -> Inter Packet Gap too short, should be at least 12 bytes." severity error;
                            write(esoc_rgmii_out_buffer, string'("ESOC RGMII Preprocessing -> Inter Packet Gap too short, should be at least 12 bytes."));
    								        writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    								        
                          else
                            for i in 3 downto 0 loop
            					        -- check and update byte counter related to the port, store data if space available
            								  if packet_buffer_bytes(esoc_rgmii_port) = packet_buffer_size then
            								    assert false report "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded." severity error;
            								    write(esoc_rgmii_out_buffer, "ESOC RGMII Preprocessing -> packet buffer for port " & esoc_rgmii_in_port & "overloaded.");
    								            writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    								            
            								  else
            								    packet_buffers(esoc_rgmii_port, packet_buffer_bytes(esoc_rgmii_port)) := pck_type_ipg & esoc_rgmii_data(i*8+7 downto i*8);  
            								    packet_buffer_bytes(esoc_rgmii_port) := packet_buffer_bytes(esoc_rgmii_port) + 1;
            								  end if;
            								end loop;
          								end if;
          								
          								
          								-- log packet information in file
          								assert false report "ESOC RGMII Preprocessing -> packet with length of " & to_string(packet_buffer_bytes(esoc_rgmii_port) - esoc_rgmii_count) & " bytes written to port " & esoc_rgmii_in_port severity note;
          								assert false report "ESOC RGMII Preprocessing -> packet details -> dmac: 0x" & esoc_rgmii_in_dmac & " smac: 0x" & esoc_rgmii_in_smac & " vid: 0x" & esoc_rgmii_in_vid & " type: 0x" & esoc_rgmii_in_type & " plen: 0x" & esoc_rgmii_in_plen & " pstart: 0x" & esoc_rgmii_in_pstart & " crc: 0x" & to_hexstring(esoc_rgmii_crc) & " ipg: 0x" & esoc_rgmii_in_gap severity note;
          								
          								write(esoc_rgmii_out_buffer, "ESOC RGMII Preprocessing -> packet with length of " & to_string(packet_buffer_bytes(esoc_rgmii_port) - esoc_rgmii_count) & " bytes written to port " & esoc_rgmii_in_port);
          								writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
          								write(esoc_rgmii_out_buffer, "ESOC RGMII Preprocessing -> packet details -> dmac: 0x" & esoc_rgmii_in_dmac & " smac: 0x" & esoc_rgmii_in_smac & " vid: 0x" & esoc_rgmii_in_vid & " type: 0x" & esoc_rgmii_in_type & " plen: 0x" & esoc_rgmii_in_plen & " pstart: 0x" & esoc_rgmii_in_pstart & " crc: 0x" & to_hexstring(esoc_rgmii_crc) & " ipg: 0x" & esoc_rgmii_in_gap);
    								      writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
        							  end if;
        							end loop;

                      assert false report "ESOC RGMII Preprocessing -> end of processing stimuli for RGMII interfaces" severity note;      							
        							write(esoc_rgmii_out_buffer, string'("ESOC RGMII Preprocessing -> end of processng stimuli for RGMII interfaces"));
        							writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
        							write(esoc_rgmii_out_buffer, string'(""));
        							writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
        							
        							--
        							-- start transmitting of Ethernet packets
        							--
        							assert false report "ESOC RGMII Transmit -> start of transmitting stimuli to RGMII interfaces" severity note;
        							write(esoc_rgmii_out_buffer, string'("ESOC RGMII Transmit -> start of transmitting stimuli to RGMII interfaces"));
    								  writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    								  
    								  while true loop
    								  
    								  
    								  
    								  -- get data for each port from their buffer and send on rising edge
    								  wait until esoc_rgmii_rxc_int'event and esoc_rgmii_rxc_int = '1';
    								  
    								  for i in esoc_port_count-1 downto 0 loop
    								    reg_rgmii_port_enable2(i) <= reg_rgmii_port_enable(i);
    								    -- check whether the port is enabled or not 
    								    if reg_rgmii_port_enable(i) = '1' then
    								      -- check whether there are still bytes to send
    								      if packet_buffer_bytes_sent(i) < packet_buffer_bytes(i) then
      								      -- start inter packet gap delay period?
      								      if packet_buffers(i,packet_buffer_bytes_sent(i))(8) = pck_type_ipg and packet_ipg(i) = 0 then
      								        esoc_rgmii_rxd(i*4+3 downto i*4) <= X"0";
      								        esoc_rgmii_rxctl(i) <= '0';
      								        
      								        packet_ipg(i) := to_integer(unsigned(packet_buffers(i,packet_buffer_bytes_sent(i))(7 downto 0) & packet_buffers(i,packet_buffer_bytes_sent(i)+1)(7 downto 0)  & packet_buffers(i,packet_buffer_bytes_sent(i)+2)(7 downto 0)  & packet_buffers(i,packet_buffer_bytes_sent(i)+3)(7 downto 0)));
      								        packet_buffer_bytes_sent(i) := packet_buffer_bytes_sent(i) + 4;
      								        
      								      -- inter packet gap delay passed?  
      								      elsif packet_ipg(i) /= 0 then
      								      
      								      -- inter packet gap delay passed, send data
      								      else
      								        esoc_rgmii_rxd(i*4+3 downto i*4) <= packet_buffers(i,packet_buffer_bytes_sent(i))(3 downto 0);
      								        esoc_rgmii_rxctl(i) <= '1';
      								      end if;
      								    end if;
      								  end if;
    								  end loop;
    								  
    								  -- get data for each port from their buffer and send on falling edge
    								  wait until esoc_rgmii_rxc_int'event and esoc_rgmii_rxc_int = '0';
    								 
                      for i in esoc_port_count-1 downto 0 loop
                        -- check whether the port is enabled or not 
                        if reg_rgmii_port_enable2(i) = pck_type_pck then
                          -- check whether there are still bytes to send
                          if packet_buffer_bytes_sent(i) < packet_buffer_bytes(i) then
                            -- inter packet gap delay passed?  
                            if packet_ipg(i) /= 0 then
      								        packet_ipg(i) := packet_ipg(i) - 1;
                            -- inter packet gap delay passed, send data    								        
                            else
      								        esoc_rgmii_rxd(i*4+3 downto i*4) <= packet_buffers(i,packet_buffer_bytes_sent(i))(7 downto 4);
      								        packet_buffer_bytes_sent(i) := packet_buffer_bytes_sent(i) + 1;
      								      end if;
      								    end if;
    								    end if;
    								  end loop;
    								  
    								  end loop;
    								  
    								  assert false report "ESOC RGMII Transmit -> end of transmitting stimuli to RGMII interfaces" severity note;
        							write(esoc_rgmii_out_buffer, string'("ESOC RGMII Transmit -> end of transmitting stimuli to RGMII interfaces"));
    								  writeline(esoc_rgmii_out, esoc_rgmii_out_buffer);
    								  
        							wait;
                    end process esoc_rgmii_tx;
end architecture esoc_tb ; -- of esoc_tb

