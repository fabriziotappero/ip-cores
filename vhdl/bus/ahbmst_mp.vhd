-- $(lic)
-- $(help_generic)
-- $(help_local)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_arith.conv_unsigned;
use work.amba.all;
use work.memdef.all;
use work.int.all;
use work.bus_comp.all;

entity ahbmst_mp is
  generic ( AHBMST_PORTS : integer := 4 );
  port (
    rst   : in  std_logic;
    clk   : in  std_logic;
    i     : in  ahbmst_mp_in_a(AHBMST_PORTS-1 downto 0);
    o     : out ahbmst_mp_out_a(AHBMST_PORTS-1 downto 0);
    ahbi  : in  ahb_mst_in_type;
    ahbo  : out ahb_mst_out_type
  );
end;

architecture rtl of ahbmst_mp is

  constant AHBMST_PORTS_BITSZ : integer := lin_log2x(AHBMST_PORTS);
  constant NBO_ZERO : std_logic_vector(AHBMST_PORTS-1 downto 0) := (others => '0');
  
  type ahbmst_mp_tmp_type is record
    ahbo   : ahb_mst_out_type;
    bo_i,nbo_i   : integer;
    o_ready, o_grant, o_mexc : std_logic_vector(AHBMST_PORTS-1 downto 0);   
    o_retry, o_cache, hold, nboreq : std_logic_vector(AHBMST_PORTS-1 downto 0);   
    nbo : std_logic_vector(AHBMST_PORTS_BITSZ-1 downto 0);
    num : std_logic_vector(AHBMST_PORTS_BITSZ-1 downto 0);
  end record;
  type ahbmst_mp_reg_type is record
     retry, cache : std_logic;
     bo    : std_logic_vector(AHBMST_PORTS_BITSZ-1 downto 0);
     ba, bg : std_logic;
  end record;
  type ahbmst_mp_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : ahbmst_mp_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : ahbmst_mp_reg_type;
  signal rdbg, cdbg : ahbmst_mp_dbg_type;

begin
  
  p0 : process(ahbi, r, rst, i)
    variable v    : ahbmst_mp_reg_type;
    variable t    : ahbmst_mp_tmp_type;
    variable vdbg : ahbmst_mp_dbg_type;
  begin

    -- $(init(t:ahbmst_mp_tmp_type))

    v := r;

    t.o_ready := (others => '0');
    t.o_grant := (others => '0');
    t.o_retry := (others => '0');
    t.o_cache := (others => '0');
    t.o_mexc := (others => '0'); 

    -- owner hold 
    t.num := (others => '0');
    t.hold := (others => '0');
    for j in AHBMST_PORTS-1 downto 0 loop
      t.num := std_logic_vector(conv_unsigned(j, AHBMST_PORTS_BITSZ));
      if (r.ba = '1') and
         (i(j).req = '1') and
         (r.bo = t.num) then
        t.hold(j) := '1';
      end if;
    end loop;  -- i
    
    -- next bus owner req
    for k in AHBMST_PORTS-1 downto 0 loop
      t.nboreq(k) := i(k).req;
      for j in AHBMST_PORTS-1 downto 0 loop
        if k /= j then
          if t.hold(j) = '1' then
            t.nboreq(k) := '0';
          end if;
        end if;
      end loop;
    end loop;

    -- priority 
    t.nbo_i := 0;
l1: for j in AHBMST_PORTS-1 downto 0 loop
      if t.nboreq(j) = '1' then
        t.nbo_i := j;
        exit l1;
      end if;
    end loop;

    -- lock (only per ahb)
    t.ahbo.hlock := '0';
    for j in AHBMST_PORTS-1 downto 0 loop
      if i(j).lock = '1' then
        t.ahbo.hlock := '1';
      end if;
    end loop;
    
    -- ahb signals
    t.ahbo.hbusreq := '0';
    t.ahbo.htrans  := HTRANS_IDLE;
    t.ahbo.haddr   := i(0).address;
    
    if not (t.nboreq = NBO_ZERO) then
      
      t.nbo := std_logic_vector(conv_unsigned(t.nbo_i, AHBMST_PORTS_BITSZ));
      t.ahbo.hbusreq := i(t.nbo_i).req;
      t.ahbo.haddr   := i(t.nbo_i).address;
      t.ahbo.htrans  := HTRANS_NONSEQ;
      t.ahbo.hwrite  := not i(t.nbo_i).read;
      t.ahbo.hsize   := lmd_toamba(i(t.nbo_i).size);
      t.ahbo.hburst := HBURST_SINGLE;
      if i(t.nbo_i).burst = '1' then
        t.ahbo.hburst := HBURST_INCR; 
      end if;

      -- burst
      if (r.bo = t.nbo) then
        if (i(t.nbo_i).req = '1') and (r.ba = '1')  then
          if ((not r.retry) = '1') then
            if i(t.nbo_i).burst = '1' then
              t.ahbo.htrans := HTRANS_SEQ;
              -- todo: 1k boundary check
              t.ahbo.hburst := HBURST_INCR; 
            end if;
          end if;
        end if;
      end if;
      
      -- grant
      if (r.bg = '1') then
        if (ahbi.hready = '1') and (i(t.nbo_i).req = '1') then
          if ((not r.retry) = '1') then
            t.o_grant(t.nbo_i) := '1';
          end if;
        end if;
      end if;
    
    end if;

    -- retry
    v.retry := '0';
    if (r.ba = '1') and 
       ((ahbi.hresp = HRESP_RETRY) or
        (ahbi.hresp = HRESP_SPLIT))
    then
      v.retry := not ahbi.hready;
    end if;
    if r.retry = '1' then
      t.ahbo.htrans := HTRANS_IDLE;
    end if;

    -- ahb return
    t.bo_i := lin_convint(r.bo);
    t.ahbo.hwdata := i(t.bo_i).data;
    if r.ba = '1' then
      t.o_cache(t.bo_i) := r.cache;
      if ahbi.hready = '1' then
        case ahbi.hresp is
	  when HRESP_OKAY => t.o_ready(t.bo_i) := '1'; 
	  when HRESP_RETRY | HRESP_SPLIT=> t.o_retry(t.bo_i) := '1'; 
	  when others => t.o_ready(t.bo_i) := '1'; t.o_mexc(t.bo_i) := '1'; 
        end case;
      end if;
    end if;

    -- next
    if ahbi.hready = '1' then
      v.bo := t.nbo;
      v.bg := ahbi.hgrant;
      v.ba := '0';
      if (t.ahbo.htrans = HTRANS_NONSEQ) or (t.ahbo.htrans = HTRANS_SEQ) then
	v.ba := r.bg;
      end if;
    end if;
    
    -- reset
    if rst = '0' then
      v.retry := '0';
      v.cache := '0';
      v.bo := (others => '0');
      v.ba := '0';
      v.bg := '0';
    end if;
    
    c <= v;

    for i in AHBMST_PORTS-1 downto 0 loop
      o(i).grant <= t.o_grant(i);
      o(i).ready <= t.o_ready(i);
      o(i).mexc <=  t.o_mexc(i);
      o(i).retry <= t.o_retry(i);
      o(i).data  <= ahbi.hrdata;
    end loop;
    
    ahbo   <= t.ahbo;
    
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


end;














