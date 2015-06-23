-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.int.all;
use work.genwb_lib.all;
use work.cache_comp.all;
use work.cache_config.all;
use work.tech_map.all;

entity genwbfifo is
  generic (
    WBBUF_SZ : integer := 2
  );
  port ( 
    rst : in  std_logic; 
    clk : in  std_logic;
    i : in  genwbfifo_type_in;
    o : out genwbfifo_type_out
  );
end genwbfifo;

architecture rtl of genwbfifo is

  type genwbfifo_tmp_type is record
     o : genwbfifo_type_out;
     readint, writeint : std_logic;
     
  end record;
  type genwbfifo_reg_type is record
     buf : gwbl_entry_a((WBBUF_SZ)-1 downto 0);
     cur, set : std_logic_vector((lin_log2(WBBUF_SZ))-1 downto 0);
     empty : std_logic;
  end record;
  type genwbfifo_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     wbaddr : std_logic_vector(31 downto 0);
     dbg : genwbfifo_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : genwbfifo_reg_type;
  signal rdbg, cdbg : genwbfifo_dbg_type;
  
  
begin  
    
  p0: process (clk, rst, r, i )
    variable v    : genwbfifo_reg_type;
    variable t    : genwbfifo_tmp_type;
    variable vdbg : genwbfifo_dbg_type;
  begin 
    
    -- $(init(t:genwbfifo_tmp_type))
    v := r;


    --$(del)             o.entry_r  
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

    t.o.fifo_entry := r.buf(lin_convint(r.cur));
    t.o.fifo_empty_r := r.empty;
    
    t.readint := i.fifo_read;
    t.writeint := i.fifo_write;
    t.o.fifo_stored_v := i.fifo_write;
      
    if t.writeint = '1' then
      if r.cur = r.set then
        if (r.empty = '0') then
          if (i.fifo_read = '0') then
            t.writeint := '0';
            t.o.fifo_stored_v := '0';
          end if;
        end if;
      end if;
      if t.writeint = '1' then
        v.buf(lin_convint(r.set)) := i.fifo_entry;
        lin_incdec(r.set,v.set,'1','1');
        v.empty := '0';
      end if;
    end if;
    
    if t.readint = '1' then
      lin_incdec(r.cur,v.cur,'1','1');
      if v.cur = v.set then
        if t.o.fifo_stored_v = '0' then
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

    o <= t.o;
    
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
      if i.fifo_read = '1' then
        assert (r.empty = '0') report "Read on empty fifo" severity failure;
      end if;
    end if;
  end process;
  -- pragma translate_on  end process p0;

end rtl;

