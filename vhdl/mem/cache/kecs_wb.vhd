-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.iface.all;
use work.target.all;
use work.kecs_config.all;
use work.kecs_libiface.all;
use work.kecs_libwb.all;
use work.kehl_libint.all;
use work.kebu_libahb.all;
use work.kecs_libcomp.all;
use work.kems_libbase.all;

entity kecs_wb is
  port ( 
    rst     : in  std_logic; 
    clk     : in  clk_type;
    wbi  : in  kcif_ketyp_wb_in;
    wbo  : out kcif_ketyp_wb_out;
    mcwbo : in kbah_ketyp_out;
    mcwbi : out kbah_ketyp_in
  );
end kecs_wb;

architecture rtl of kecs_wb is

  type kecswb_tmp_type is record
     wbo   : kcif_ketyp_wb_out;
     wbfifoi : kcif_ketyp_wbfifo_in;
     consume : std_logic;
  end record;
  type kecswb_reg_type is record
     active : std_logic;
     mcwbi : kbah_ketyp_in;
     last_addr, last_data : std_logic_vector(31 downto 0);
  end record;
  type kecswb_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : kecswb_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : kecswb_reg_type;
  signal rdbg, cdbg : kecswb_dbg_type;
  signal wbfifoi : kcif_ketyp_wbfifo_in;
  signal wbfifoo : kcif_ketyp_wbfifo_out;
  
begin  
    
  p0: process (clk, rst, r, wbi, mcwbo, wbfifoo )
    variable v    : kecswb_reg_type;
    variable t    : kecswb_tmp_type;
    variable vdbg : kecswb_dbg_type;
  begin 
    
    -- $(init(t:kecswb_tmp_type))
    v := r;
    
    t.wbfifoi.fifo_read := '0';
    t.wbfifoi.fifo_write := '0';
    t.consume := '0';
    
    if mcwbo.ready = '1' then
      v.active := '0';
    end if;
          
    if v.active = '0' then
      if r.mcwbi.req = '0' and wbfifoo.fifo_empty_r = '0' then
        t.consume := '1';
      end if;
    end if;
    
    if mcwbo.grant = '1' then
      v.active := '1';
      v.mcwbi.req := '0';
      v.last_addr := r.mcwbi.address;
      v.last_data := r.mcwbi.data;
      if wbfifoo.fifo_empty_r = '0' then
        t.consume := '1';
      end if;
    end if;
    
    if mcwbo.retry = '1' then
      v.mcwbi.req := '1';
      v.mcwbi.address := r.last_addr;
      v.mcwbi.data := r.last_data;
    end if;
    
    if t.consume = '1' then
      v.mcwbi.req := '1';
      v.mcwbi.address := wbfifoo.fifo_entry.addr;
      v.mcwbi.data    := wbfifoo.fifo_entry.data;
      v.mcwbi.burst   := wbfifoo.fifo_entry.burst;
      v.mcwbi.size    := wbfifoo.fifo_entry.size;
      v.mcwbi.read := '0';
      v.mcwbi.lock := '0';
      t.wbfifoi.fifo_read := '1';
    end if;
    
    -- reset
    if ( rst = '0' ) then
      v.mcwbi.req := '0';
      v.active := '0';
    end if;
    
    t.wbfifoi.fifo_entry := wbi.fifo_entry;
    t.wbfifoi.fifo_write := wbi.fifo_write;
    t.wbo.fifo_stored_v  := wbfifoo.fifo_stored_v;
    t.wbo.empty_v := wbfifoo.fifo_empty_r and (not r.mcwbi.req) and (not r.active); -- might be v.active

    c <= v;
    
    wbfifoi <= t.wbfifoi;
    wbo <= t.wbo;
    mcwbi <= r.mcwbi;
    
    -- pragma translate_off
    vdbg := rdbg;
    vdbg.dbg := t;
    cdbg <= vdbg;
    -- pragma translate_on  end process p0;
    
  end process p0;
  
  pregs : process (clk, c)
  begin
    if rising_edge(clk) then
      r <= c;
      -- pragma translate_off
      rdbg <= cdbg;
      -- pragma translate_on
    end if;
  end process;

  gfifo0 : if KCLD_WBBUF_SZ > 0 generate
    fifo0 : kecs_wbfifo generic map ( WBBUF_SZ => KCLD_WBBUF_SZ )
      port map (rst, clk, wbfifoi, wbfifoo );
  end generate;    
  
end rtl;

