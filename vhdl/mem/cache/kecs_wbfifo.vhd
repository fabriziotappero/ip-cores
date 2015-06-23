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
use work.tech_map.all;

entity kecs_wbfifo is
  generic (
    WBBUF_SZ : integer := 2
  );
  port ( 
    rst : in  std_logic; 
    clk : in  clk_type;
    wbfifoi : in  kcif_ketyp_wbfifo_in;
    wbfifoo : out kcif_ketyp_wbfifo_out
  );
end kecs_wbfifo;

architecture rtl of kecs_wbfifo is

  type kecswbfifo_tmp_type is record
     wbfifoo : kcif_ketyp_wbfifo_out;
     readint, writeint : std_logic;
     
  end record;
  type kecswbfifo_reg_type is record
     buf : kclw_ketyp_entry_a((WBBUF_SZ)-1 downto 0);
     cur, set : std_logic_vector((log2(WBBUF_SZ))-1 downto 0);
     empty : std_logic;
  end record;
  type kecswbfifo_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     wbaddr : std_logic_vector(31 downto 0);
     dbg : kecswbfifo_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : kecswbfifo_reg_type;
  signal rdbg, cdbg : kecswbfifo_dbg_type;
  
  
begin  
    
  p0: process (clk, rst, r, wbfifoi )
    variable v    : kecswbfifo_reg_type;
    variable t    : kecswbfifo_tmp_type;
    variable vdbg : kecswbfifo_dbg_type;
  begin 
    
    -- $(init(t:kecswb_tmp_type))
    v := r;


    --$(del)             wbfifoo.entry_r  
    --       +-------+ <-cur   /\
    --       | xxxxx |  -------+ 
    --       +-------+
    --       | xxxxx |
    --       +-------+ <-set
    --       |       |
    --       .       .
    --       .       .
    --       +-------+
    --       |       |
    --       +-------+
    --$(/del)

    t.wbfifoo.fifo_entry := r.buf(khin_convint(r.cur));
    t.wbfifoo.fifo_empty_r := r.empty;
    
    t.readint := wbfifoi.fifo_read;
    t.writeint := wbfifoi.fifo_write;
    t.wbfifoo.fifo_stored_v := wbfifoi.fifo_write;
      
    if t.writeint = '1' then
      if r.cur = r.set then
        if (r.empty = '0') then
          if (wbfifoi.fifo_read = '0') then
            t.writeint := '0';
            t.wbfifoo.fifo_stored_v := '0';
          end if;
        end if;
      end if;
      if t.writeint = '1' then
        v.buf(khin_convint(r.set)) := wbfifoi.fifo_entry;
        khin_incdec(r.set,v.set,'1','1');
        v.empty := '0';
      end if;
    end if;
    
    if t.readint = '1' then
      khin_incdec(r.cur,v.cur,'1','1');
      if v.cur = v.set then
        if t.wbfifoo.fifo_stored_v = '0' then
          v.empty := '1';
        end if;
      end if;
    end if;
    
    
    -- reset
    if ( rst = '0' ) then
      v.empty := '1';
      v.cur := (others => '0');
      v.set := (others => '0');
    end if;
    
    c <= v;

    wbfifoo <= t.wbfifoo;
    
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

  -- pragma translate_off
  check0 : process (clk)
  begin
    if falling_edge(clk) then
      if wbfifoi.fifo_read = '1' then
        assert (r.empty = '0') report "Read on empty fifo" severity failure;
      end if;
    end if;
  end process;
  -- pragma translate_on  end process p0;

end rtl;

