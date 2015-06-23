------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity:      ahb_slv
-- File:        ahb_slv.vhd
-- Author:      David Lindh - Gaisler Research
-- Description: AMBA AHB slave interface for DDR-RAM memory controller
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use grlib.devices.all;
use gaisler.memctrl.all;
library techmap;
use techmap.gencomp.all;
use techmap.allmem.all;
use gaisler.ddrrec.all;

entity ahb_slv is
  generic (
    hindex      :     integer := 0;
    haddr       :     integer := 0;
    hmask       :     integer := 16#f80#;
    sepclk      :     integer := 0;
    dqsize      :     integer := 64;
    dmsize      :     integer := 8;
    tech        :     integer := virtex2);
  port (
    rst      : in  std_ulogic;
    hclk     : in  std_ulogic;
    clk0     : in  std_ulogic;
    csi      : in  ahb_ctrl_in_type;
    cso      : out ahb_ctrl_out_type);
end ahb_slv;

architecture rtl of ahb_slv is

  -- Configuration for AMBA PlugNplay
  constant REVISION : integer         := 0;
  constant HCONFIG  : ahb_config_type := (
    0      => ahb_device_reg ( VENDOR_GAISLER, GAISLER_DDRMP, 0, REVISION, 0),
    4      => ahb_membar(haddr, '1', '1', hmask),
    others => zero32);

  type burst_mask_type is array (buffersize-1 downto 0) of integer range 1 to 8;
  type hsize_type is array (4 downto 0) of integer range 8 to 128;
  constant hsize_array : hsize_type := (128, 64, 32, 16, 8);
  
  signal ahbr       : ahb_reg_type;
  signal ahbri      : ahb_reg_type;
  signal csi_synced : ahb_ctrl_in_type;
  signal DSRAM_i    : syncram_dp_in_type;
  signal DSRAM_o    : syncram_dp_out_type;
  signal ASRAM_i    : syncram_2p_in_type;
  signal ASRAM_o    : syncram_2p_out_type;
  signal vcc        : std_ulogic;
  
begin  -- rtl 

  vcc <= '1';

 -------------------------------------------------------------------------------
   --AMBA AHB control combinatiorial part
 -------------------------------------------------------------------------------  
  ahbcomb : process(ahbr, rst, csi, csi_synced, DSRAM_o)
    
    variable v : ahb_reg_type;          -- local variables for registers
    variable next_rw_cmd_valid : std_logic_vector((log2(buffersize)-1) downto 0);

  begin
    v                 := ahbr;
    next_rw_cmd_valid := v.rw_cmd_valid +1;
    v.new_burst := '0';
    v.sync_write := '0';
    v.sync2_write := '0';
     
 -------------------------------------------------------------------------------
     -- Give respons on prevoius address cycle  (DATA CYCLE)
 -------------------------------------------------------------------------------        

    -- If read and read prediction in previos cycle. Both couldn't be
    -- written into address syncram (sync2)
    if ahbr.sync2_busy = '1' then
      v.sync2_adr   := v.pre_read_buffer;
      v.sync2_wdata := '0' & ahbr.pre_read_adr;
      v.sync2_write := '1';
      v.sync2_busy  := '0';
    end if;

       
         
        
     
     -- In case of a write followed by a read both will try to use sync_ram
     -- in same cycle, delays read.
    if ahbr.sync_busy = '1' then
      v.sync_adr    := ahbr.sync_busy_adr;
      v.doRead      := '1';
      


          
      -- Write data to address given in previous cycle
    elsif ahbr.doWrite = '1' then   
      -- If first word set all datamasks
      if conv_std_logic_vector(v.writecounter,4)(0) = '0' then
        v.sync_wdata((2*(dmsize+dqsize))-1 downto 2*dqsize) :=  (others => '1');
      end if;          
      -- Write data to syncram
      v.even_odd_write := (conv_integer(conv_std_logic_vector(v.writecounter,4)(0)));
      for i in 0 to dqsize-1 loop
        if i >= v.startp*8  and i < (v.startp+v.burst_hsize)*8  then
          v.sync_wdata(i + v.even_odd_write*dqsize) := csi.ahbsi.hwdata(i+(v.ahbstartp-v.startp)*8);
        end if;
      end loop;
      -- Clear masks for valid bytes
      for i in 0 to dmsize-1 loop
        if i >= v.startp and i < (v.startp+v.burst_hsize) then 
          v.sync_wdata((2*dqsize)+v.even_odd_write*dmsize+i) := '0';
        end if;
      end loop;
      v.sync_adr    := v.use_write_buffer & conv_std_logic_vector(v.writecounter,4)(2 downto 1);
      v.sync_write  := '1';
      -- Increase mask counter
      v.burst_dm(conv_integer(v.use_write_buffer)) := v.writecounter+1; 
      v.doWrite            := '0';
    end if;





          
-------------------------------------------------------------------------------
    -- Analyze incomming command on AHB   (ADDRESS CYCLE)
-------------------------------------------------------------------------------
    v.sync_busy   := '0';
    
    -- An error occured in previous address cycle
    if ahbr.prev_error = '1' then
      v.hresp := HRESP_ERROR;
      v.hready := '1';
      v.prev_retry := '0';
      v.prev_error := '0';
      
      -- A retry occured in previous address cycle
    elsif ahbr.prev_retry = '1' then
      v.hresp := HRESP_RETRY;
      v.hready := '1';
      v.prev_retry := '0';
      v.prev_error := '0';
      
      -- Slave selected and previous transfer complete
    elsif csi.ahbsi.hsel(hindex) = '1' and csi.ahbsi.hready = '1' then
      v.prev_retry := '0';
      v.prev_error := '0';
            
          
      -- Check if hsize is within range
      if hsize_array(conv_integer(csi.ahbsi.hsize)) > dqsize and csi.ahbsi.htrans(1) = '1' then
        assert false report "AHB HSIZE cannot be greater then DQ size" severity error;
        v.hresp := HRESP_ERROR;
        v.hready := '0';
        v.prev_error := '1';
      
            
        -- BUSY or IDLE command
      elsif csi.ahbsi.htrans(1) = '0' then
        v.hresp  := HRESP_OKAY;
        v.hready := '1';
        
        -- If idle, begin write burst (if waiting)
        if csi.ahbsi.htrans = HTRANS_IDLE then
          v.w_data_valid := v.rw_cmd_valid;
          v.pre_read_valid := '0';
        end if;
        
        -- SEQ or NONSEQ command
      else
        -- Calculate valid bits for transfer according to big endian

        case ahbdata is
          when 8 =>  v.ahboffset := "000";
          when 16 => v.ahboffset := "00" & csi.ahbsi.haddr(0);
          when 32 => v.ahboffset := "0" & csi.ahbsi.haddr(1 downto 0);
          when 64 => v.ahboffset := csi.ahbsi.haddr(2 downto 0);
          when others => null;
        end case;
        
        
        case dqsize is
          when 8  => v.rwadrbuffer  := csi.ahbsi.haddr;
                     v.offset       := "000";
          when 16 => v.rwadrbuffer  := "0" & csi.ahbsi.haddr(31 downto 1);
                     v.offset       := "00" & csi.ahbsi.haddr(0);
          when 32 => v.rwadrbuffer  := "00" & csi.ahbsi.haddr(31 downto 2);
                     v.offset       := "0" & csi.ahbsi.haddr(1 downto 0);
          when 64 => v.rwadrbuffer  := "000" & csi.ahbsi.haddr(31 downto 3);
                     v.offset       := csi.ahbsi.haddr(2 downto 0);
          when others => null;
        end case;

               
        case csi.ahbsi.hsize is
          when "000" => v.burst_hsize:= 1;
                        v.startp:= ((dqsize-8)/8) - conv_integer(v.offset);
                        v.ahbstartp := ((ahbdata-8)/8) - conv_integer(v.ahboffset);
          when "001" => v.burst_hsize:= 2; v.offset(0):= '0';
                        v.startp:= ((dqsize-16)/8) - conv_integer(v.offset);
                        v.ahbstartp:= ((ahbdata-16)/8) - conv_integer(v.ahboffset);
          when "010" => v.burst_hsize:= 4; v.offset(1 downto 0) := "00";
                        v.startp:= ((dqsize-32)/8) - conv_integer(v.offset);
                        v.ahbstartp:= ((ahbdata-32)/8) - conv_integer(v.ahboffset);
          when "011" => v.burst_hsize:= 8; v.offset(2 downto 0) := "000";
                        v.startp:= 0;
                        v.ahbstartp := 0;
          when others =>
            assert false report "Too large HSIZE" severity error;
            v.hresp := HRESP_ERROR;
            v.hready := '0';
            v.prev_error := '1';
        end case;




      
-------------------------------------------------------------------------------
 -- SEQUENCIAL, continuation of burst
            
 -- Read (seq)
      if (csi.ahbsi.hwrite = '0' and csi.ahbsi.htrans = HTRANS_SEQ and
          csi.ahbsi.hburst = HBURST_INCR and v.offset /= "000") then   
        -- Do nothing, requested data is in the same ahb word as
        -- already is on ahb bus
        
      elsif (csi.ahbsi.hwrite = '0' and csi.ahbsi.htrans = HTRANS_SEQ and
             csi.ahbsi.hburst = HBURST_INCR)
      then
        -- Check that new command can be part of current burst
        if v.readcounter /= v.blockburstlength then
          -- Read from Syncram
          v.sync_write  := '0';
          v.doRead      := '1';
        else
          if csi_synced.locked = '0' then           
            -- Check if a prediction was made that matches this new address
            if v.pre_read_valid = '1' then
              v.use_read_buffer := v.pre_read_buffer;
              v.readcounter := 0;
              v.blockburstlength := csi_synced.burstlength;
              -- Read from Syncram
              v.sync_write  := '0';
              v.doRead      := '1';
              v.pre_read_valid := '0';
                    
              -- Make new read prediction if buffer not full
              if (v.pre_read_buffer+1) /= csi_synced.rw_cmd_done and csi_synced.r_predict = '1' then
                v.pre_read_adr     := v.rwadrbuffer + csi_synced.burstlength;                 
                v.pre_read_buffer  := v.pre_read_buffer +1;
                v.pre_read_valid   := '1';
                v.sync2_write      := '1';
                v.sync2_wdata      := '0' & v.pre_read_adr;
                v.sync2_adr        := v.pre_read_buffer;                                                                              
                v.rw_cmd_valid     := v.pre_read_buffer;
                v.w_data_valid     := v.pre_read_buffer;
              end if;
                      
              -- No prediction was made, treat as non sequencial
            else
              v.new_burst := '1';
            end if;
          else
            v.new_burst := '1';
          end if;
        end if;



                
  -- Write (seq) 
      elsif csi.ahbsi.hwrite = '1' and csi.ahbsi.htrans = HTRANS_SEQ then
        v.pre_read_valid := '0';
                 
        -- Check that new command can be part of current burst
        if v.offset /= "000" then
          v.doWrite := '1';
          v.hresp              := HRESP_OKAY;
          v.hready             := '1';
        elsif v.writecounter+1 /= v.blockburstlength and csi_synced.locked = '0' then
          v.writecounter := v.writecounter +1;
          v.doWrite := '1';
          v.hresp              := HRESP_OKAY;
          v.hready             := '1';
          -- Command has to start new burst
        else
          v.w_data_valid := v.rw_cmd_valid;
          v.rw_cmd_valid := v.use_write_buffer;
          v.new_burst := '1';
        end if;
      end if;



            
-------------------------------------------------------------------------------            
-- NON SEQUENCIAL, start of new burst
      if (csi.ahbsi.htrans = HTRANS_NONSEQ or v.new_burst = '1') then
        v.pre_read_valid := '0';
        
        -- Determine how many words that is valid until DRRMEM
        -- will wrap within block
        case csi_synced.burstlength is
          when 2      => v.blockburstlength := csi_synced.burstlength - conv_integer(v.rwadrbuffer(0));
          when 4      => v.blockburstlength := csi_synced.burstlength - conv_integer(v.rwadrbuffer(1 downto 0));
          when 8      => v.blockburstlength := csi_synced.burstlength - conv_integer(v.rwadrbuffer(2 downto 0));
          when others => null;
        end case;
      
              
        -- Commandbuffer full or AHB interface locked
        if next_rw_cmd_valid = csi_synced.rw_cmd_done or csi_synced.locked = '1' then
          v.hresp := HRESP_RETRY;
          v.hready := '0';
          v.prev_retry := '1';
          
          -- Put new command into command buffer
        else
          v.sync2_adr     := next_rw_cmd_valid;
                


                
-------------------------------------------------------------------------------
-- Read (non-seq)
          if csi.ahbsi.hwrite = '0' then
            v.hready           := '0';
            v.readcounter      := 0;
            v.use_read_buffer  := next_rw_cmd_valid;
            v.rw_cmd_valid     := next_rw_cmd_valid;
            v.w_data_valid     := next_rw_cmd_valid;  -- keep in phase for read
            v.sync2_wdata      := '0' & v.rwadrbuffer;
            v.sync2_write      := '1';
                  
            -- Wait one cycle (maybe write before)
            v.sync_busy_adr    :=  next_rw_cmd_valid & "00";
            v.sync_busy        := '1';
            v.doRead           := '0';
            
            -- Predict (if space in buffer and option choosen) next read
            next_rw_cmd_valid   := next_rw_cmd_valid +1;
            if next_rw_cmd_valid /= csi_synced.rw_cmd_done and csi_synced.r_predict = '1' then
              v.pre_read_buffer := next_rw_cmd_valid;
              v.pre_read_adr    :=  v.rwadrbuffer + v.blockburstlength;
              v.pre_read_valid  := '1';
              v.rw_cmd_valid    := next_rw_cmd_valid;
              v.w_data_valid    := next_rw_cmd_valid;  -- keep in phase
              
              -- Address cannot be saved due to syncram busy, write in
              -- next cycle
              v.sync2_busy      := '1';
                     
            end if;



                  
-------------------------------------------------------------------------------
-- Write (non-seq)
          elsif csi_synced.w_prot = '0' then
            v.pre_read_valid     := '0';
            
            v.w_data_valid       := v.rw_cmd_valid;
            v.rw_cmd_valid       := next_rw_cmd_valid;
            v.writecounter       := 0;
            v.use_write_buffer   := next_rw_cmd_valid;
            v.sync2_wdata        := '1' & v.rwadrbuffer;
            v.sync2_write        := '1';
            v.doWrite            := '1';
            v.hresp              := HRESP_OKAY;
            v.hready             := '1';
                  
            -- Write protection error
          else
            assert false report "Write when write protection enabled" severity warning;
            v.hresp := HRESP_ERROR;
            v.hready := '0';
            v.prev_error := '1';
          end if;                 -- write
        end if;                   -- cmdbuffer not full
      end if;                     -- non seq transfer
    end if;                       -- seq or non seq

         
    -- Slave not selected
  else
    v.w_data_valid := v.rw_cmd_valid;
    v.hready := '1';
    v.hresp  := HRESP_OKAY;
  end if;                              
         

  -- Always set HRDATA (to improve timing)
  if conv_std_logic_vector(v.readcounter,4)(0) = '0' then -- Even word
    v.read_data((dqsize-1) downto 0) := DSRAM_o.dataout1((dqsize-1) downto 0);
  else -- Odd word
    v.read_data((dqsize-1) downto 0) := DSRAM_o.dataout1((2*dqsize)-1 downto dqsize);
  end if;          
  --Read data from syncram    
  for i in 0 to ahbdata-1 loop
    if i >= v.ahbstartp*8  and i < (v.ahbstartp+v.burst_hsize)*8  then
      v.cur_hrdata(i) := v.read_data(i+(v.startp-v.ahbstartp)*8);
    end if;
  end loop;



  
  -- Calculate for next clk cycle

  -- If read cmd, dont try to read from syncram since maybe write before
  if v.sync_busy = '1' then
    v.cur_hready := '0';
    v.cur_hresp  := HRESP_OKAY;
  -- Read data is avalible
  elsif (csi_synced.rw_cmd_done = v.use_read_buffer or
         (csi_synced.rw_cmd_done = v.pre_read_buffer and
          v.pre_read_valid = '1')) and v.doRead = '1' then
    -- Set address for next read
    v.readcounter := v.readcounter +1;
     if v.readcounter = v.blockburstlength then
       v.sync_adr := (v.use_read_buffer+1) & "00";
     else
       v.sync_adr := v.use_read_buffer & conv_std_logic_vector(v.readcounter,3)(2 downto 1);
     end if;
    v.doRead := '0';
    v.cur_hready := '1';
    v.cur_hresp  := HRESP_OKAY;
  -- Waiting for read data
  elsif v.doRead = '1' then
    v.cur_hready := '0';
    v.cur_hresp  := HRESP_OKAY;
  else
    v.cur_hready := v.hready;
    v.cur_hresp  := v.hresp;  
  end if;

-------------------------------------------------------------------------------
-- Reset
  if rst = '0' then
    v.readcounter     := 0;
    v.writecounter    := 0;
    v.blockburstlength:= 0;
    v.hready          := '1';
    v.hresp           := HRESP_OKAY;
    v.rwadrbuffer     := (others => '0');
    v.use_read_buffer := (others => '1');
    v.pre_read_buffer := (others => '1');
    v.pre_read_adr    := (others => '0');
    v.pre_read_valid  := '0';
    v.use_write_buffer:= (others => '1');
    v.rw_cmd_valid    := (others => '1');
    v.w_data_valid    := (others => '1');
    
    v.sync_adr        := (others => '0');
    v.sync_wdata      := (others => '0');
    v.sync_write      := '0';
    v.sync_busy       := '0';
    v.sync_busy_adr   := (others => '0');
    v.sync2_adr       := (others => '0');
    v.sync2_wdata     := (others => '0');
    v.sync2_write     := '0';
    v.sync2_busy      := '0';
    
    v.doRead          := '0';
    v.doWrite         := '0';
    v.new_burst       := '0';
    v.startp          := 0;
    v.ahbstartp       := 0;
    v.even_odd_write  := 0;
    v.burst_hsize     := 1;
    v.offset          := "000";
    v.ahboffset       := "000";
    v.read_data       := (others => '0');
    v.cur_hready      := '0';
    v.cur_hresp       := HRESP_OKAY;
    v.prev_retry      := '0';
    v.prev_error      := '0';
      
  end if;
-------------------------------------------------------------------------------
-- Set output signals

  ahbri <= v;
  
  cso.ahbso.hsplit <= (others => '0');
  cso.ahbso.hcache <= '1';
  cso.ahbso.hirq   <= (others => '0');
  cso.ahbso.hindex <= hindex;
  
 
  DSRAM_i.address1 <= v.sync_adr;
  DSRAM_i.datain1 <= v.sync_wdata;
  DSRAM_i.write1 <= v.sync_write;
  
  ASRAM_i.waddress <= v.sync2_adr;
  ASRAM_i.datain <= v.sync2_wdata;
  ASRAM_i.write <= v.sync2_write;
      
            
  end process;
-------------------------------------------------------------------------------
  -- Purely combinatorial (no process)
  cso.ahbso.hconfig <= HCONFIG;

  DSRAM_i.address2 <= csi.dsramsi.address2;
  DSRAM_i.datain2 <= csi.dsramsi.datain2;
  DSRAM_i.write2 <= csi.dsramsi.write2;
  ASRAM_i.raddress <= csi.asramsi.raddress;

  cso.asramso <= ASRAM_o;
  cso.dsramso <= DSRAM_o;

-------------------------------------------------------------------------------
-- AMBA AHB control clocked register
  ahbclk : process(hclk)
  begin
    
    if rising_edge(hclk) then
      ahbr          <= ahbri;

      -- Registred outputs
      cso.rw_cmd_valid <= ahbri.rw_cmd_valid;
      cso.w_data_valid <= ahbri.w_data_valid;
      cso.burst_dm     <= ahbri.burst_dm;

      cso.ahbso.hrdata <= ahbri.cur_hrdata;
      cso.ahbso.hresp   <= ahbri.cur_hresp;
      cso.ahbso.hready  <= ahbri.cur_hready;
      
    end if;
  end process;


-- Register for incoming signals if separete clock domains
  sept :  if sepclk = 1 generate 
    sepp : process(hclk)
    begin
      if rising_edge(hclk) then
        csi_synced.burstlength            <= csi.burstlength;
        csi_synced.r_predict              <= csi.r_predict;
        csi_synced.w_prot                 <= csi.w_prot;
        csi_synced.locked                 <= csi.locked;
        csi_synced.rw_cmd_done            <= csi.rw_cmd_done;
      end if;
    end process;
  end generate;
  sepf :  if sepclk = 0 generate
    csi_synced.burstlength            <= csi.burstlength;
    csi_synced.r_predict              <= csi.r_predict;
    csi_synced.w_prot                 <= csi.w_prot;
    csi_synced.locked                 <= csi.locked;
    -- This sync below required since the current used syncram cannot write
    -- and read from the same location in the same cycle
    sepp : process(hclk)
     begin
       if rising_edge(hclk) then
        csi_synced.rw_cmd_done            <= csi.rw_cmd_done;
       end if;
     end process; 
  end generate;
-------------------------------------------------------------------------------
-- SyncRAM

-- Data syncram
  S0: syncram_dp
    generic map(
      tech      => tech,
      abits     => bufferadr,
      dbits     => 2*(dqsize+dmsize))
    port map(
      clk1      => hclk,
      address1  => DSRAM_i.address1,
      datain1   => DSRAM_i.datain1(2*(dqsize+dmsize)-1 downto 0),
      dataout1  => DSRAM_o.dataout1(2*(dqsize+dmsize)-1 downto 0),
      enable1   => vcc,
      write1    => DSRAM_i.write1,
      clk2      => clk0,
      address2  => DSRAM_i.address2,
      datain2   => DSRAM_i.datain2(2*(dqsize+dmsize)-1 downto 0),
      dataout2  => DSRAM_o.dataout2(2*(dqsize+dmsize)-1 downto 0),
      enable2   => vcc,
      write2    => DSRAM_i.write2);

-- Address syncram
  S1: syncram_2p
    generic map(
      tech      => tech*0,
      abits     => log2(buffersize),
      dbits     => ahbadr+1,
      sepclk    => sepclk,
      wrfst     => syncram_2p_write_through(tech))
    port map(
      rclk      => clk0,
      renable   => vcc,
      raddress  => ASRAM_i.raddress,
      dataout   => ASRAM_o.dataout,
      wclk      => hclk,
      write     => ASRAM_i.write,
      waddress  => ASRAM_i.waddress,
      datain    => ASRAM_i.datain);






  
-- End of AHB controller
-------------------------------------------------------------------------------
end rtl;
