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
-- Entity:      Vga Controller
-- File:        vga_controller.vhd
-- Author:      Hans Soderlund
-- Description: Vga Controller main file
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.misc.all;
 
entity svgactrl is

  generic(
    length      : integer := 384;        -- Fifo-length
    part        : integer := 128;        -- Fifo-part lenght
    memtech     : integer := DEFMEMTECH;  
    pindex      : integer := 0; 
    paddr       : integer := 0;
    pmask       : integer := 16#fff#;
    hindex      : integer := 0;           
    hirq        : integer := 0;
    clk0        : integer := 40000;
    clk1        : integer := 20000;
    clk2        : integer := 15385;
    clk3        : integer := 0;
    burstlen    : integer range 2 to 8 := 8
    );
  
  port (
    rst       : in std_logic;
    clk       : in std_logic;
    vgaclk    : in std_logic;
    apbi      : in apb_slv_in_type;
    apbo      : out apb_slv_out_type;
    vgao      : out apbvga_out_type;
    ahbi      : in  ahb_mst_in_type;
    ahbo      : out ahb_mst_out_type;
    clk_sel   : out std_logic_vector(1 downto 0)
    );

end ;

architecture rtl of svgactrl is

  constant REVISION : amba_version_type := 0; 
  constant pconfig : apb_config_type := (
     0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_SVGACTRL, 0, REVISION, 0),
     1 => apb_iobar(paddr, pmask));

  type RegisterType is array (1 to 5) of std_logic_vector(31 downto 0);
  type state_type is (running, not_running, reset);
 
  type read_type is record
    read_pointer      : integer range 0 to length ;
    read_pointer_out  : integer range 0 to length ;
    sync              : std_logic_vector(2 downto 0);
    data_out          : std_logic_vector(23 downto 0);
    lock              : std_logic;
    index             : std_logic_vector(1 downto 0);
    mem_index         : integer;
    read_pointer_clut : std_logic_vector(7 downto 0);
    hcounter          : std_logic_vector(15 downto 0);
    vcounter          : std_logic_vector(15 downto 0);
    fifo_ren          : std_logic;
    fifo_en           : std_logic;
    hsync             : std_logic ;
    vsync             : std_logic ;
    csync             : std_logic ;
    blank             : std_logic ;
    hsync2            : std_logic ;
    vsync2            : std_logic ;
    csync2            : std_logic ;
    blank2            : std_logic ;
  end record;

  type control_type is record
    int_reg            : RegisterType;
    state              : state_type;
    enable             : std_logic;
    reset              : std_logic;
    sync_c             : std_logic_vector(2 downto 0);
    sync_w             : std_logic_vector(2 downto 0);
    write_pointer_clut : std_logic_vector(7 downto 0);
    datain_clut        : std_logic_vector(23 downto 0);
    write_en_clut      : std_logic;
    adress             : std_logic_vector(31 downto 0);
    start              : std_logic;
    write_pointer      : integer range 0 to length;
    ram_address        : integer range 0 to length;
    data               : std_logic_vector(31 downto 0);
    level              : integer range 0 to part + 1;
    status             : integer range 0 to 3;
    hpolarity 		: std_ulogic;
    vpolarity 		: std_ulogic;
    func		: std_logic_vector(1 downto 0);
    clk_sel 		: std_logic_vector(1 downto 0);
  end record;

  type sync_regs is record
    s1 : std_logic_vector(2 downto 0);
    s2 : std_logic_vector(2 downto 0);
    s3 : std_logic_vector(2 downto 0);
   end record;
   
  signal t,tin              : read_type;
  signal r,rin              : control_type;
  signal sync_w             : sync_regs;
  signal sync_ra            : sync_regs;
  signal sync_rb            : sync_regs;
  signal sync_c             : sync_regs;
  signal read_status        : std_logic_vector(2 downto 0);
  signal write_status       : std_logic_vector(2 downto 0);
  signal write_en           : std_logic;
  signal res_mod            :std_logic;
  signal en_mod             : std_logic;
  signal fifo_en            : std_logic;
  signal dmai               : ahb_dma_in_type;
  signal dmao               : ahb_dma_out_type;
  signal equal              : std_logic;
  signal hmax               : std_logic_vector(15 downto 0);
  signal hfporch            : std_logic_vector(15 downto 0);
  signal hsyncpulse         : std_logic_vector(15 downto 0);
  signal hvideo             : std_logic_vector(15 downto 0);
  signal vmax               : std_logic_vector(15 downto 0);
  signal vfporch            : std_logic_vector(15 downto 0);
  signal vsyncpulse         : std_logic_vector(15 downto 0);
  signal vvideo             : std_logic_vector(15 downto 0);
  signal write_pointer_clut : std_logic_vector(7 downto 0);
  signal read_pointer_clut  : std_logic_vector(7 downto 0);
  signal read_pointer_fifo  : std_logic_vector(9 downto 0);
  signal write_pointer_fifo : std_logic_vector(9 downto 0);
  signal datain_clut        : std_logic_vector(23 downto 0);
  signal dataout_clut       : std_logic_vector(23 downto 0);
  signal dataout_fifo       : std_logic_vector(31 downto 0);
  signal datain_fifo        : std_logic_vector(31 downto 0);
  signal write_en_clut, read_en_clut : std_logic;
  signal vcc      : std_logic;
  signal read_en_fifo, write_en_fifo     : std_logic;

begin

  vcc <= '1';
  ram0 : syncram_2p generic map (tech => memtech, abits => 10, dbits => 32, 
	sepclk => 1)
  port map (vgaclk, read_en_fifo, read_pointer_fifo, dataout_fifo,clk, write_en_fifo,
	write_pointer_fifo, datain_fifo);

  clutram : syncram_2p generic map (tech => memtech, abits => 8, dbits => 24, 
	sepclk => 1)
  port map (vgaclk, read_en_clut, read_pointer_clut, dataout_clut, clk, write_en_clut, 
	write_pointer_clut,datain_clut);

  ahb_master : ahbmst generic map (hindex, hirq, VENDOR_GAISLER,
	GAISLER_SVGACTRL, 0, 3, 1)
  port map (rst, clk, dmai, dmao, ahbi, ahbo);    

  apbo.pirq        <= (others => '0');
  apbo.pindex      <= pindex;
  apbo.pconfig     <= pconfig;

  control_proc : process(r,rst,sync_c,apbi,fifo_en,write_en,read_status,dmao,res_mod, sync_w)

  variable v: control_type;
  variable rdata : std_logic_vector(31 downto 0);
  variable mem_sel : integer;
  variable apbwrite : std_logic;
  variable we_fifo : std_logic; 

  begin
  
    v := r; v.write_en_clut := '0'; rdata := (others =>'0');
    mem_sel := conv_integer(apbi.paddr(5 downto 2)); we_fifo := '0';

--   Control part. This part handles the apb-accesses and stores the internal registers
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
    apbwrite :=  apbi.psel(pindex) and apbi.pwrite and apbi.penable;
    case apbi.paddr(5 downto 2)  is
    when "0000" =>
      if apbwrite = '1' then
        v.enable := apbi.pwdata(0);
        v.reset  := apbi.pwdata(1);
    	v.hpolarity := apbi.pwdata(8);
    	v.vpolarity := apbi.pwdata(9);
    	v.func := apbi.pwdata(5 downto 4);
    	v.clk_sel := apbi.pwdata(7 downto 6);
      end if;
      rdata(9 downto 0) := r.vpolarity  & r.hpolarity & r.clk_sel & 
	r.func & fifo_en & '0' & r.reset & r.enable;
    when "1010" =>
      if apbwrite = '1' then
        v.datain_clut := apbi.pwdata(23 downto 0);
        v.write_pointer_clut := apbi.pwdata(31 downto 24);
        v.write_en_clut := '1';
      end if;
    when "0001" => 
      if apbwrite = '1' then v.int_reg(1) := apbi.pwdata; end if;
      rdata := r.int_reg(1);
    when "0010" => 
      if apbwrite = '1' then v.int_reg(2) := apbi.pwdata; end if;
      rdata := r.int_reg(2);
    when "0011" => 
      if apbwrite = '1' then v.int_reg(3) := apbi.pwdata; end if;
      rdata := r.int_reg(3);
    when "0100" => 
      if apbwrite = '1' then v.int_reg(4) := apbi.pwdata; end if;
      rdata := r.int_reg(4);
    when "0101" => 
      if apbwrite = '1' then v.int_reg(5) := apbi.pwdata; end if;
      rdata := r.int_reg(5);
    when "0110" => rdata := conv_std_logic_vector(clk0,32);
    when "0111" => rdata := conv_std_logic_vector(clk1,32);
    when "1000" => rdata := conv_std_logic_vector(clk2,32);
    when "1001" => rdata := conv_std_logic_vector(clk3,32);
    when others =>
    end case;
  
------------------------------------------ 
----------- Control state machine --------

    case r.state is
    when running => 
       if r.enable = '0' then
         v.sync_c := "011";
         v.state := not_running;
       end if;
    when not_running => 
       if r.enable = '1' then
         v.sync_c := "001";
         v.state := reset;
       end if;
    when reset =>
       if sync_c.s3 = "001" then
         v.sync_c := "010";
         v.state := running;
       end if;
    end case;         

-----------------------------------------
----------- Control reset part-----------

    if r.reset = '1' or rst = '0' then
      v.state     := not_running;
      v.enable    := '0';              
      v.int_reg   := (others => (others => '0'));
      v.sync_c    := "011";
      v.reset     := '0';
      v.clk_sel   := "00";
    end if; 

------------------------------------------------------------------------------
-- Write part. This part reads from the memory framebuffer and places the data
-- in the designated fifo specified from the generic.
-------------------------------------------------------------------------------

    v.start := '0';      
    if write_en = '0' then
      if (r.start or not dmao.active) = '1' then v.start := '1'; end if;
      if dmao.ready = '1' then         ------------ AHB access part -----------
                                        ---------- and Fifo write part ---------
        v.data := dmao.rdata(31 downto 0);
        v.ram_address := v.write_pointer;
        v.write_pointer := v.write_pointer +1; we_fifo := '1';
        if v.write_pointer = length then
          v.write_pointer := 0;
        end if;
        v.level := v.level +1;

        if dmao.haddr = (9 downto 0 => '0') then
            v.adress := (v.adress(31 downto 10) + 1) & dmao.haddr;
        else
            v.adress   := v.adress(31 downto 10) & dmao.haddr;
        end if;

        if (dmao.haddr(burstlen+1 downto 0) = ((burstlen+1 downto 2 => '1') & "00")) then 
             v.start := '0';
        end if;
      end if;                          ----------------------------------------

      v.sync_w := v.sync_w and read_status; ------------ Fifo sync part ------------

      if v.level >= (part -1)  then

        if read_status(r.status) = '1' and v.sync_w(r.status) = '0'  and v.level = part then
          v.level := 0;
          if r.status = 0 then
            v.sync_w(2) := '1';
          else
            v.sync_w(r.status -1) := '1';
          end if;
          v.status := v.status + 1;
          if v.status = 3  then
            v.status := 0;
          end if;
        else
          v.start := '0';
        end if;
      end if;
    end if;                            ------------------------------------------
  
                                     ------------ Write reset part ------------
    if res_mod = '0' or write_en = '1' then
      if dmao.active = '0' then v.adress := r.int_reg(5); end if;
      v.start := '0';
      v.sync_w := "000";
      v.status := 1;
      v.ram_address := 0;
      v.write_pointer := 0;
      v.level := 0;
    end if;                              ------------------------------------------

    if (r.start and dmao.active and not dmao.ready) = '1' then
      v.start := '1';
    end if;
    
-- Assertions 

    rin         <= v;
    sync_c.s1    <= v.sync_c;
    sync_w.s1    <= r.sync_w;
    res_mod      <= sync_c.s3(1);
    en_mod       <= sync_c.s3(0);
    write_status <= sync_w.s3;
    hvideo     <= r.int_reg(1)(15 downto 0);
    vvideo     <= r.int_reg(1)(31 downto 16);    
    hfporch    <= r.int_reg(2)(15 downto 0);    
    vfporch    <= r.int_reg(2)(31 downto 16);    
    hsyncpulse <= r.int_reg(3)(15 downto 0);
    vsyncpulse <= r.int_reg(3)(31 downto 16);    
    hmax       <= r.int_reg(4)(15 downto 0);    
    vmax       <= r.int_reg(4)(31 downto 16);
    apbo.prdata  <= rdata;
    dmai.wdata  <= (others => '0');
    dmai.burst  <= '1';
    dmai.irq    <= '0';
    dmai.size   <= "10";                    
    dmai.write  <= '0';
    dmai.busy   <= '0';
    dmai.start    <= r.start and r.enable;
    dmai.address  <= r.adress;
    write_pointer_fifo <= conv_std_logic_vector(v.ram_address,10);
    write_pointer_clut <= r.write_pointer_clut;
    datain_fifo   <= v.data;
    datain_clut <= r.datain_clut;
    write_en_clut <= r.write_en_clut;
    clk_sel <= r.clk_sel;
    write_en_fifo <= we_fifo;
    
  end process;

  read_proc : process(t,res_mod,en_mod,write_status,dataout_fifo,sync_rb,dataout_clut,
    vmax, hmax, hvideo, hfporch, hsyncpulse, vvideo, vfporch, vsyncpulse, sync_ra, r)

  variable v : read_type;
  variable inc_pointer : std_logic;
  
  begin    

    v := t;
    v.vsync2 := t.vsync; v.hsync2 := t.hsync; v.csync2 := t.csync;
    v.blank2 := t.blank; 

-- Syncsignals generation functions.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
       
    if en_mod = '0' then

      -- vertical counter
      if (t.vcounter = vmax ) and (t.hcounter = hmax ) then
        v.vcounter  := (others => '0');
      elsif t.hcounter = hmax then
        v.vcounter  := t.vcounter  +1;
      end if;
  
      -- horizontal counter
      if t.hcounter < hmax then v.hcounter := t.hcounter +1;
      else v.hcounter := (others => '0'); end if;
      
      -- generate hsync
      if t.hcounter < (hvideo+hfporch+hsyncpulse) and (t.hcounter > (hvideo+hfporch -1)) then
        v.hsync := r.hpolarity;
      else v.hsync := not r.hpolarity; end if;
      
      -- generate vsync
      if t.vcounter <= (vvideo+vfporch+vsyncpulse) and (t.vcounter > (vvideo+vfporch)) then
        v.vsync := r.vpolarity;             
      else v.vsync := not r.vpolarity; end if;
      
      --generate csync & blank signal
      v.csync := not (v.hsync xor v.vsync);
      v.blank := not t.fifo_ren;
  
      --generate fifo_ren -signal
      if (t.hcounter = (hmax -1) and t.vcounter = vmax) or
         (t.hcounter = (hmax -1 ) and t.vcounter < vvideo) then
        v.fifo_ren := '0';
      elsif t.hcounter = (hvideo -1) and t.vcounter <= vvideo then
        v.fifo_ren := '1';
      end if;
  
      --generate fifo_en -signal
      if t.vcounter = vmax then
         v.fifo_en := '0'; 
      elsif t.vcounter = vvideo and t.hcounter = (hvideo -1) then
         v.fifo_en := '1';
      end if;

    end if;

    if r.func /= "01" then -- do not delay strobes when not using CLUT
      v.vsync2 := v.vsync; v.hsync2 := v.hsync; v.csync2 := v.csync;
      v.blank2 := v.blank;
    end if;

   -- Sync reset part ---------
    if res_mod = '0' then
      v.hcounter := hmax;
      v.vcounter := vmax - 1;
      v.hsync := r.hpolarity;
      v.vsync := r.vpolarity;
      v.blank := '0';
      v.fifo_ren := '1';
      v.fifo_en := '1';
    end if;

-- Read from fifo.
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

    inc_pointer := '0';
   
    if t.fifo_en = '0' then
                                  ------------ Fifo sync part ------------
 
      if (v.read_pointer_out = 0 or v.read_pointer_out = part or
        v.read_pointer_out = (part + part)) and t.fifo_ren = '0'
        and  v.index = "00" 
      then
        case t.sync  is
        when "111" | "011" =>
          if write_status(0) = '1' then
            v.sync := "110"; v.lock := '0';
          else v.lock := '1'; end if;
        when "110" =>
          if write_status(1) = '1' then
             v.sync := "101"; v.lock := '0';
          else v.lock := '1'; end if;
        when "101" =>
          if write_status(2) = '1' then
            v.sync := "011"; v.lock := '0';
          else v.lock := '1'; end if;
        when others => null;
        end case;
      end if;
  
  ------------------------------------------
  ------------ Fifo read part  -------------
  ------------ and CLUT access -------------
  
      if t.fifo_ren = '0' and v.lock = '0' then

        case r.func is
        when "01" =>
          if t.index = "00" then
            v.read_pointer_clut := dataout_fifo(31 downto 24);
            v.index := "01";
          elsif t.index = "01" then
            v.read_pointer_clut := dataout_fifo(23 downto 16);
            v.index := "10";
          elsif t.index = "10" then
            v.read_pointer_clut := dataout_fifo(15 downto 8);
            v.index := "11";
          else
            v.read_pointer_clut := dataout_fifo(7 downto 0);
            v.index := "00"; inc_pointer := '1';
          end if;
          v.data_out := dataout_clut; 
        when "10" =>
          if t.index = "00" then
            v.data_out := dataout_fifo(31 downto 27) & "000"  &
            dataout_fifo(26 downto 21) & "00" & dataout_fifo(20 downto 16) & "000"; 
            v.index := "01";
          else
            v.data_out := dataout_fifo(15 downto 11) & "000" &
              dataout_fifo(10 downto 5)  & "00" & dataout_fifo(4 downto 0)   & "000";
            v.index := "00"; inc_pointer := '1';
          end if;
        when "11" =>
          v.data_out := dataout_fifo(23 downto 0);
          v.index := "00"; inc_pointer := '1';
        when others =>
          v.data_out := (23 downto 0 => '1');
          v.index := "00"; inc_pointer := '1';
        end case;
      else
        v.data_out := (others => '0');
      end if;
  
      if inc_pointer = '1' then
        v.read_pointer_out := t.read_pointer;
        v.read_pointer := t.read_pointer + 1;
  
        if v.read_pointer = length then
          v.read_pointer := 0;
        end if;
        if v.read_pointer_out = length then
          v.read_pointer_out := 0;
        end if;
    
      end if;      
      
    else
      v.data_out := (others => '0');
    end if;                           ------------------------------------------
                                  ------------ Fifo read reset part  -------
    if res_mod = '0' or t.fifo_en = '1' then
      v.sync := "111";
      v.read_pointer_out := 0;
      v.read_pointer := 1;
      v.data_out := (others => '0');
      v.lock := '1';
      v.index := "00";
      v.read_pointer_clut := (others => '0');
    end if;                           ------------------------------------------

    tin <= v;
    sync_ra.s1   <= t.sync;
    sync_rb.s1   <= t.fifo_en & "00";
    read_status  <= sync_ra.s3;
    write_en     <= sync_rb.s3(2);
    fifo_en      <= t.fifo_en;
    read_pointer_clut <= v.read_pointer_clut;
    read_pointer_fifo <= conv_std_logic_vector(v.read_pointer_out,10);
    read_en_fifo  <= not v.fifo_ren;
    read_en_clut  <= not v.fifo_ren and not r.func(1) and r.func(0); 
    vgao.video_out_r <= t.data_out(23 downto 16);
    vgao.video_out_g <= t.data_out(15 downto 8);
    vgao.video_out_b <= t.data_out(7 downto 0);
    vgao.hsync     <= t.hsync2;
    vgao.vsync     <= t.vsync2;
    vgao.comp_sync <= t.csync2;
    vgao.blank     <= t.blank2;

  end process;

  proc_clk : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;              -- Control
      sync_ra.s2 <= sync_ra.s1;      -- Write
      sync_ra.s3 <= sync_ra.s2;      -- Write
      sync_rb.s2 <= sync_rb.s1;      -- Write
      sync_rb.s3 <= sync_rb.s2;      -- Write
    end if;
  end process;
         
  proc_vgaclk : process(vgaclk)
  begin
    if rising_edge(vgaclk) then
      t <= tin;                    -- Read
      sync_c.s2 <= sync_c.s1;      -- Control
      sync_c.s3 <= sync_c.s2;      -- Control
      sync_w.s2 <= sync_w.s1;      -- Read
      sync_w.s3 <= sync_w.s2;      -- Read
    end if;
  end process;

end ;

