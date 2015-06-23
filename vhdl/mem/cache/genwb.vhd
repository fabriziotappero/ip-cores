-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.int.all;
use work.memdef.all;
use work.bus_comp.all;
use work.cache_comp.all;
use work.cache_config.all;
use work.genwb_lib.all;

entity genwb is
  port ( 
    rst     : in  std_logic; 
    clk     : in  std_logic;
    i  : in  genwb_type_in;
    o  : out genwb_type_out;
    mcwbo : in ahbmst_mp_out;
    mcwbi : out ahbmst_mp_in
  );
end genwb;

architecture rtl of genwb is

  type kecswb_tmp_type is record
     o   : genwb_type_out;
     wbfifoi : genwbfifo_type_in;
     consume, req : std_logic;
  end record;
  type kecswb_reg_type is record
     active : std_logic;
     data : std_logic_vector(31 downto 0);
     mcwbi : ahbmst_mp_in;
     retry_mcwbi,buf_mcwbi : ahbmst_mp_in;
  end record;
  type kecswb_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : kecswb_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : kecswb_reg_type;
  signal rdbg, cdbg : kecswb_dbg_type;
  signal wbfifoi : genwbfifo_type_in;
  signal wbfifoo : genwbfifo_type_out;
  
begin  
    
  p0: process (clk, rst, r, i, mcwbo, wbfifoo )
    variable v    : kecswb_reg_type;
    variable t    : kecswb_tmp_type;
    variable vdbg : kecswb_dbg_type;
  begin 

    -- todo: locking on atomic load store does not work yet
    -- until no multiprocessor system is implemented it's defered to the future

    
    -- $(init(t:kecswb_tmp_type))
    v := r;
    
    t.wbfifoi.fifo_read := '0';
    t.wbfifoi.fifo_entry := i.fifo_entry;
    t.wbfifoi.fifo_write := i.fifo_write;
    t.o.fifo_stored_v  := wbfifoo.fifo_stored_v;
    t.o.empty_v := wbfifoo.fifo_empty_r and (not r.mcwbi.req) and (not r.active); -- might be v.active
    t.o.read_finish_v := '0';
    t.o.read_mexc := mcwbo.mexc;
    t.o.read_data := mcwbo.data;
    
    t.req := (not wbfifoo.fifo_empty_r) or (i.fifo_write);
    t.consume := '0';
    
    if mcwbo.ready = '1' then
      v.active := '0';
      t.o.read_finish_v := r.retry_mcwbi.read;
    end if;
          
    if v.active = '0' then
      if r.mcwbi.req = '0' and t.req = '1' then
        t.consume := '1';
      end if;
    end if;
    
    if mcwbo.grant = '1' then
      v.active := '1';
      v.mcwbi.req := '0';
      v.mcwbi.data := r.data;
      v.retry_mcwbi := r.mcwbi;
      v.retry_mcwbi.data := r.data;
      if t.req = '1' then
        t.consume := '1';
      end if;
    end if;
    
    if mcwbo.retry = '1' then
      v.buf_mcwbi := r.mcwbi;
      v.buf_mcwbi.data := r.data;
      v.mcwbi := r.retry_mcwbi;
      v.data := r.retry_mcwbi.data;
    end if;
    
    if t.consume = '1' then
      if r.buf_mcwbi.req = '1' then
        v.buf_mcwbi.req := '0';
        v.data := r.buf_mcwbi.data;
        v.mcwbi := r.buf_mcwbi;
      else
        if (wbfifoo.fifo_empty_r = '0') then
          v.mcwbi.req := '1';
          v.data          := wbfifoo.fifo_entry.data; 
          v.mcwbi.address := wbfifoo.fifo_entry.addr;
          v.mcwbi.burst   := wbfifoo.fifo_entry.burst;
          v.mcwbi.size    := wbfifoo.fifo_entry.size;
          v.mcwbi.read    := wbfifoo.fifo_entry.read;
          v.mcwbi.lock    := wbfifoo.fifo_entry.lock;
          t.wbfifoi.fifo_read := '1';
        else
          v.mcwbi.req := '1';
          t.o.fifo_stored_v := '1';
          t.wbfifoi.fifo_write := '0';
          v.data          := i.fifo_entry.data;
          v.mcwbi.address := i.fifo_entry.addr;
          v.mcwbi.burst   := i.fifo_entry.burst;
          v.mcwbi.size    := i.fifo_entry.size;
          v.mcwbi.read    := i.fifo_entry.read;
          v.mcwbi.lock    := i.fifo_entry.lock;
        end if;
      end if;
      
    end if;
    
    -- reset
    if ( rst = '0' ) then
      v.mcwbi.req := '0';
      v.active := '0';
      v.buf_mcwbi.req := '0';
    end if;

    c <= v;
    
    wbfifoi <= t.wbfifoi;
    o <= t.o;
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

  gfifo0 : if CFG_WBBUF_SZ > 0 generate
    fifo0 : genwbfifo generic map ( WBBUF_SZ => CFG_WBBUF_SZ )
      port map (rst, clk, wbfifoi, wbfifoo );
  end generate;    
  
end rtl;

