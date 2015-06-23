-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.conv_integer;
use IEEE.std_logic_arith.conv_unsigned;
use work.config.all;
use work.int.all;
use work.memdef.all;
use work.corelib.all;
use work.cache_comp.all;
use work.cache_config.all;
use work.genic_lib.all;
use work.gencmem_lib.all;
use work.bus_comp.all;

entity genic is
  port ( 
    rst     : in  std_logic; 
    clk     : in  std_logic;
    hold : in cli_hold;
    i    : in  genic_type_in;
    o    : out genic_type_out;
    ctrl : in gicl_ctrl;
    icmo : in gencmem_type_ic_out;
    icmi : out gencmem_type_ic_in;
    mcio : in ahbmst_mp_out;
    mcii : out ahbmst_mp_in
    );
end genic;

architecture rtl of genic is

  type genic_datasrc is (genic_mem,genic_cmem);
  type genic_tmp_type is record
    hit ,valid  : std_logic;
    set  : integer;
    pos  : integer;
    setrep : integer;
    sethit  : std_logic_vector(CFG_IC_SETS-1 downto 0);
    setvalid   : std_logic_vector(CFG_IC_SETS-1 downto 0);
    icmi      : gencmem_type_ic_in;
    o  : genic_type_out;
    datasrc  : genic_datasrc;
    ehold, reqinsn, branch : std_logic;
    twrite, dwrite : std_logic;
    newvalid : std_logic_vector(CFG_IC_TLINE_SZ-1 downto 0);
    mcii  : ahbmst_mp_in;
  end record;
  type genic_state is (genic_hit,genic_pempty,genic_stream,genic_pfull,genic_waitwrite);
  type genic_reg_type is record
    setrep : std_logic_vector(lin_log2x(CFG_IC_SETS)-1 downto 0);
    state : genic_state;
    hold : std_logic;
    hit : std_logic;
    mcii  : ahbmst_mp_in;
    faddr : std_logic_vector(GCML_IC_TADDR_BSZ-1 downto 0);
    ready_addr  : std_logic_vector(31 downto 0);
    --flush, fluship : std_logic;
  end record;
  type genic_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : genic_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : genic_reg_type;
  signal rdbg, cdbg : genic_dbg_type;
  
begin  
    
  p0: process (clk, rst, r, hold, i, icmo, mcio, ctrl )
    variable v    : genic_reg_type;
    variable t    : genic_tmp_type;
    variable vdbg : genic_dbg_type;
  begin 
    
    -- $(init(t:genic_tmp_type))
    
    v := r;

    -- todo: use part of with mcii.address
    -- lin_incdec(t.ahbo.haddr(4 downto 2),t.ahbo.haddr(4 downto 2),'1','1');
    t.icmi.addr := r.ready_addr;
    
    t.datasrc := genic_mem;
    t.ehold :=  hold.dhold;
    t.reqinsn := not (t.ehold or i.annul);
    t.branch := i.bra_v;
    t.twrite := '0';
    t.dwrite := '0';
    
    t.o.mstrobe := '0';
    
    -- cmp
    t.hit := '0';
    t.set := 0;
    for j in CFG_IC_SETS-1 downto 0 loop
      if gicl_is_taghit(i.pc_r,icmo.tag_line(j)) then
        t.hit := '1';
        t.sethit(j) := '1';
        t.set := j;
      end if;
    end loop; 
    
    t.valid := '0';
    if gicl_is_linevalid(i.pc_r,icmo.tag_line(t.set)) then
      t.valid := '1';
    end if;

    -- next addr
    if mcio.ready = '1' then
      v.ready_addr := r.mcii.address;
    end if;

    -- state
    case r.state is
      when genic_hit =>

        t.icmi.addr := i.pc_v;
        t.datasrc := genic_cmem;
        v.hold := '0';
 	
        -- remove: 
        v.mcii.burst := ctrl.burst;
        if gicl_is_onetogo(i.pc_r) then
          v.mcii.burst := '0';
        end if;
        v.hit := t.hit;

        if t.reqinsn = '1' then
          if (not (t.hit and t.valid)) = '1' then
            v.hold := '1';
            v.state := genic_pempty;
            v.mcii.req := '1';
          end if;
          v.mcii.address := i.pc_r;
          -- todo: use part of with mcii.address
          v.ready_addr := i.pc_r;
        end if;
        
        v.setrep := std_logic_vector(conv_unsigned(t.set, lin_log2x(CFG_IC_SETS)));
        
      when genic_pempty =>
        
        if mcio.ready = '1' then
          t.o.mstrobe := '1';
          if i.bra_r = '1' then
            v.state := genic_pfull;
          else
            v.state := genic_stream;
            v.hold := '0';
          end if;
        end if;

        t.branch := i.bra_r;
        
      when genic_stream =>
        
        if t.reqinsn = '1' then
          if mcio.ready = '0' then
            v.hold := '1';
            v.state := genic_pempty;
          else
            if i.bra_v = '1' then
              v.hold := '1';
              v.state := genic_pfull;
            end if;
          end if;
        else
          if mcio.ready = '1' then
            v.hold := '1';
            v.state := genic_pfull;
          end if;
        end if;
        
      when genic_pfull =>
        
      when genic_waitwrite =>
        
        v.state := genic_hit;
        t.icmi.addr := i.pc_r;
        v.hold := '0';
        
      when others => 
    end case;

    -- next req
    if mcio.grant = '1' then 
      v.mcii.burst := ctrl.burst;
      v.mcii.req := r.mcii.burst;
      lin_incdec(r.mcii.address(31 downto 2), v.mcii.address(31 downto 2),'1','1');
      if gicl_is_onetogo(r.mcii.address) then
        v.mcii.burst := '0';
        if mcio.ready = '1' then
          v.mcii.req := '0';
        end if;
      end if;
      if (t.branch   = '1') then
        v.mcii.burst := '0';
        v.mcii.req := '0';
      end if;
    end if;
    
    -- finish
    if (mcio.ready = '1') and (r.mcii.req = '0') then
      --v.flush := r.fluship;
      v.state := genic_waitwrite;
      v.hold := '1';
    end if;

    -- memdata returned
    if mcio.ready = '1' then
      t.twrite := '1';
      t.dwrite := '1';
    end if;
    
    -- retry
    if mcio.retry = '1' then
      v.mcii.req := '1';
      v.mcii.address := r.ready_addr;
    end if;

    -- mexc
    if (mcio.mexc or not mcio.cache) = '1' then 
      t.twrite := '0';
      t.dwrite := '0';
    else
      t.dwrite := t.twrite;
    end if;

    -- return data
    t.o.dat_line_v := icmo.dat_line(t.set);
    if CFG_IC_DLINE_SZ = 1 then
      t.pos := 0;
    else
      t.pos := lin_convint(r.ready_addr(GICL_TLINE_U downto GICL_TLINE_D));
    end if;
    case t.datasrc is
      when genic_mem    => t.o.dat_line_v.data(t.pos) := mcio.data;
      when genic_cmem   => t.o.dat_line_v := icmo.dat_line(t.set);
      when others => 
    end case;
    
    -- assemble input tag line
    t.setrep := lin_convint(r.setrep);
    t.icmi.tag_line := icmo.tag_line(t.setrep);
    t.newvalid := lin_decode(r.ready_addr(GICL_TLINE_U downto GICL_TLINE_D));
    if r.hit = '1' then
      t.icmi.tag_line.valid := t.icmi.tag_line.valid or t.newvalid;
    else
      t.icmi.tag_line.valid := t.newvalid;
    end if;
    t.icmi.tag_line.tag := r.ready_addr(GICL_TTAG_U downto GICL_TTAG_D);
    t.icmi.tag_write(t.setrep) := t.twrite;
    
    -- assemble input data line
    t.icmi.dat_line := icmo.dat_line(t.setrep);
    t.icmi.dat_line.data(t.pos) := mcio.data;
    t.icmi.dat_write(t.setrep) := t.dwrite;
    
    -- flush
    --if r.fluship = '1' then
    --  t.icmi.tag_write := (others => '1');
    --  t.icmi.addr(GICL_TADDR_U downto GICL_TADDR_D) := r.faddr;
    --  t.icmi.tag_line.tag := (others => '0');
    --  t.icmi.tag_line.valid := (others => '0');
    --  lin_incdec(r.faddr, v.faddr,'1','1');
    --  if (r.faddr(GICL_TADDR_U) and not v.faddr(GICL_TADDR_U)) = '1' then
    --	v.fluship := '0';
    --  end if;
    --end if;

    -- reset
    if ( rst = '0' ) then
      v.state := genic_hit;
      v.hold := '0';
      v.mcii.req := '0';
      --v.flush := '0';
      --v.fluship := '0';
    end if;

    t.o.hold := r.hold;
    t.mcii := r.mcii;
    t.mcii.read := '1';
    t.mcii.lock := '0';
    v.mcii.size := lmd_word;
    t.mcii.data := (others => '0');
    
    c <= v;
    
    icmi <= t.icmi;
    o  <= t.o;
    mcii <= t.mcii;
    
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
  
end rtl;

