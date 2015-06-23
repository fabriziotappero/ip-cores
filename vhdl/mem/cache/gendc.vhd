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
use work.gendc_lib.all;
use work.genwb_lib.all;
use work.gencmem_lib.all;
use work.setrepl_lib.all;
use work.arith_cnt_comp.all;
use work.bus_comp.all;

entity gendc is
  port ( 
    rst     : in  std_logic; 
    clk     : in  std_logic;
    hold : in cli_hold;
    i  : in  gendc_type_in;
    o  : out gendc_type_out;
    ctrl : in gdcl_ctrl;
    dcmo : in gencmem_type_dc_out;
    dcmi : out gencmem_type_dc_in;
    wbi  : out genwb_type_in;
    wbo  : in genwb_type_out
    );
end gendc;

architecture rtl of gendc is
  
  type gendc_dirty_a is array (natural range <>) of std_logic_vector(GCML_DC_TADDR_BSZ-1 downto 0);
  
  type gendc_cmaddrsrc is (gdca_no, gdca_in,  gdca_re,  gdca_lo);
  type gendc_meaddrsrc is (gdcma_no, gdcma_in, gdcma_re, gdcma_lo );
  type gendc_datainsrc is (gdcdi_no, gdcdi_in, gdcdi_re, gdcdi_lo, gdcdi_me );
  type gendc_datapisrc is (gdcdp_cm, gdcdp_me, gdcdp_no );
  type gendc_dbsrc is (gdcdb_mem, gdcdb_cm );
  
  type gendc_validsrc is (gdcvalid_old, gdcvalid_clr, gdcvalid_new, gdcvalid_add );
  type gendc_dirtysrc is (gdcdirty_old, gdcdirty_clr, gdcdirty_new, gdcdirty_add );

  constant GCML_DC_DLINE_BSZ_X : integer := lin_log2x(CFG_DC_DLINE_SZ); 
  constant GCML_DC_SETS_X  : integer := lin_log2x(CFG_DC_SETS); 

  type gendc_tmp_type is record
    hit, valid, dirty  : std_logic;     -- cache line attr 
    set, setrep  : integer;                     -- hit set
    pos  : integer;                     -- line pos
    ehold, req, reqread, reqwrite : std_logic;
    sethit  : std_logic_vector(CFG_DC_SETS-1 downto 0);
    setvalid   : std_logic_vector(CFG_DC_SETS-1 downto 0);
    newvalid, newdirty : std_logic_vector(CFG_DC_TLINE_SZ-1 downto 0);
    twrite, dwrite : std_logic;
    mexc : std_logic;
    
    setpos : std_logic_vector(lin_log2x(CFG_DC_SETS)-1 downto 0);
    
    cmaddr : std_logic_vector(31 downto 0);
    datain : std_logic_vector(31 downto 0);
    meaddr : std_logic_vector(31 downto 0);
    datapi : std_logic_vector(31 downto 0);
    tvalid_src : gendc_validsrc;
    tdirty_src : gendc_dirtysrc;
    cmaddr_src : gendc_cmaddrsrc;
    datain_src : gendc_datainsrc;
    meaddr_src : gendc_meaddrsrc;
    datapi_src : gendc_datapisrc;
    db_src : gendc_dbsrc;
    
    sign, read, lock, burst : std_logic;
    size : lmd_memsize;       
    linepos : std_logic_vector(GCML_DC_TLINE_BSZ-1 downto 0);
    linepos_lastbit : std_logic_vector(CFG_DC_TLINE_SZ-1 downto 0);
    
    cmset : integer;
    
    si : arith_cnt8_in;
    dcmi : gencmem_type_dc_in;
    wbi  : genwb_type_in;
    o  : gendc_type_out;
    
    sr_setfree : std_logic_vector(CFG_DC_SETS-1 downto 0);
    sr_setlock : std_logic_vector(CFG_DC_SETS-1 downto 0);
    sr_useset : std_logic;
  end record;
  type gendc_state is (gendc_hit, 
                       gendc_wtwb_readdata,
                       gendc_wb_writedata, gendc_wt_writedata,
                       gendc_wb_wbline, gendc_wb_fillline, 
                       gendc_reloadtaddr );
  type gendc_reg_type is record
    setrep : std_logic_vector(lin_log2x(CFG_DC_SETS)-1 downto 0);
    state, state_wbline_next : gendc_state;
    hit, hold : std_logic;

    p_address : std_logic_vector(31 downto 0);
    p_data : std_logic_vector(31 downto 0);
    p_sign, p_read, p_lock : std_logic;
    p_size : lmd_memsize; 
    
    stored, wbready, wbnext : std_logic;
    setrep_locked, setrep_free : std_logic;
    o_wr_data : std_logic_vector(31 downto 0);
    addrlo : std_logic_vector(1 downto 0);
    dirty : std_logic_vector(CFG_DC_TLINE_SZ-1 downto 0);
    fill_linepos, linepos : std_logic_vector(GCML_DC_TLINE_BSZ-1 downto 0);
    doaddr : std_logic_vector(1 downto 0);
    mexc : std_logic;
  end record;
  type gendc_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     cmaddr : std_logic_vector(31 downto 0);
     dbg : gendc_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : gendc_reg_type;
  signal rdbg, cdbg : gendc_dbg_type;

  signal si : arith_cnt8_in;
  signal so : arith_cnt8_out;
  
  signal sr_setfree : std_logic_vector(CFG_DC_SETS-1 downto 0);
  signal sr_setlock : std_logic_vector(CFG_DC_SETS-1 downto 0);
  signal sr_useset : std_logic;
  signal sr_locked : std_logic;
  signal sr_free   : std_logic;
  signal sr_setrep_free : std_logic_vector(GCML_DC_SETS_X-1 downto 0);
  signal sr_setrep_repl : std_logic_vector(GCML_DC_SETS_X-1 downto 0);
    
begin  
    
  p0: process (clk, rst, r, hold, i, dcmo, wbo, so,
               sr_locked, sr_free, sr_setrep_free, sr_setrep_repl )
    variable v    : gendc_reg_type;
    variable t    : gendc_tmp_type;
    variable vdbg : gendc_dbg_type;
  begin
    
    -- todo: locking on atomic load store does not work yet
    -- until no multiprocessor system is implemented it's defered to the future
    
    -- $(init(t:gendc_tmp_type))
    v := r;
    
    t.meaddr := i.addr_in;
    t.cmaddr := i.addr_in;
    t.datain := i.data_in;
    
    t.wbi.fifo_write := '0';
    v.stored := r.stored or wbo.fifo_stored_v;
    
    -- write back address
    t.si.data := (others => '0');
    t.si.data(arith_cnt8_SZ-1 downto arith_cnt8_SZ-CFG_DC_TLINE_SZ) := r.dirty;
    t.linepos := so.res(GCML_DC_TLINE_BSZ-1 downto 0);
    t.linepos_lastbit := (others => '0');

    t.mexc := '0';
    
    t.datapi_src := gdcdp_no;
    t.db_src := gdcdb_cm;
    
    t.ehold := hold.ihold;
    t.req := (not (t.ehold or i.annul)) and i.addrin_re ;
    t.reqread := i.param_r.read and t.req;
    t.reqwrite := (not i.param_r.read) and t.req;
    t.twrite := '0';
    t.dwrite := '0';
    
    if r.hit = '1' then
      t.tvalid_src := gdcvalid_add;
      t.tdirty_src := gdcdirty_add;
    else
      t.tvalid_src := gdcvalid_new;
      t.tdirty_src := gdcdirty_new;
    end if;

    t.burst := '0';
    if (r.hold or t.ehold) = '1' then
      t.cmaddr_src := gdca_re;
      t.meaddr_src := gdcma_lo;
      t.datain_src := gdcdi_lo;
      t.sign := r.p_sign;
      t.size := r.p_size;
      t.read := r.p_read;
      t.lock := r.p_lock;
    else
      t.cmaddr_src := gdca_in;
      t.meaddr_src := gdcma_re;
      t.datain_src := gdcdi_in;
      t.sign := i.param_r.signed;
      t.size := i.param_r.size;
      t.read := i.param_r.read;
      t.lock := i.param_r.lock;
    end if;
    
    if t.read = '1' then
      t.size := lmd_word;
    end if;
        
    -- cmp
    t.hit := '0';
    t.set := 0;
    for j in CFG_DC_SETS-1 downto 0 loop
      -- (note: multiset does not recognice valid zero tags)
      if gdcl_is_taghit(i.addr_re,dcmo.tag_line(j)) then
        t.hit := '1';
        t.sethit(j) := '1';
        t.set := j;
      end if;
    end loop; 
        
    t.sr_setfree := (others => '0');
    for j in CFG_DC_SETS-1 downto 0 loop
      if gdcl_is_free(dcmo.tag_line(j)) then
        t.sr_setfree(j) := '1';
      end if;
    end loop; 
    
    t.sr_setlock := (others => '0');
    for j in CFG_DC_SETS-1 downto 0 loop
      t.sr_setlock(j) := dcmo.tag_line(j).lock;
    end loop; 

    t.sr_useset := '0';
    
    t.valid := '0';
    if gdcl_is_linevalid(i.addr_re,dcmo.tag_line(t.set)) then
      t.valid := '1';
    end if;

    t.dirty := '0';
    t.setrep := lin_convint(sr_setrep_repl);
    if (sr_free = '1') or (sr_locked = '1') then
      t.dirty := '0';
      if (sr_free = '1') then
        t.setrep := lin_convint(sr_setrep_free);
      end if;
    else
      if gdcl_is_linedirty(i.addr_re,dcmo.tag_line(t.setrep)) then
        t.dirty := '1';
      end if;
    end if;
      
    -- $(del)
    --                read                               write                                                
    --   Writeback     |   Writethrough     Writeback     |   Writethrough                                        
    --        +--------+--------+                +--------+--------+                                                  
    --    hit | miss        hit | miss       hit | miss        hit | miss                                      
    --   +----+----+       +----+----+      +----+----+       +----+----+                               
    --   |     free|dirty  |         |      |     free|dirty  |         |                   
    --   O1     +--+--+    O1        O3    O5      +--+--+   O4/O6     O6                              
    --          |     |              |             |     |                                            
    --          O3<---O2             O4            O5<---O2                                            
    --          |                                                                                                     
    --          O4                                                                                     
    --                                                                                                        
    --  O1: cacheread                                                                                                  
    --  O2: writeback line                                                                                              
    --  O3: memload                                                                                                     
    --  O4: cachewrite clean                                                                                              
    --  O5: cachewrite dirty                                                                                             
    --  O6: writeback single                                                                                            
    -- $(/del)

        
    case r.state is
      
      when gendc_hit =>

        if t.hit = '1' then
          t.tvalid_src := gdcvalid_add;
          t.tdirty_src := gdcdirty_add;
        else
          t.tvalid_src := gdcvalid_new;
          t.tdirty_src := gdcdirty_new;
        end if;

        v.mexc := '0';
        v.wbready := '0';
        v.wbnext := '0';
        v.stored := wbo.fifo_stored_v;
        v.hold := '0';
        
        v.setrep_locked := sr_locked;
        v.setrep_free := sr_free;
        
        v.hit := t.hit;
        
        v.p_address := i.addr_re;
        v.p_data := i.data_in;
        v.p_sign := i.param_r.signed;
        v.p_size := i.param_r.size;
        v.p_read := i.param_r.read;
        v.p_lock := i.param_r.lock;
  
        if t.req = '1' then
          
          t.sr_useset := '1';
    
          if i.param_r.read = '1' then
            if ctrl.writeback = '0' then
              if (not (t.hit and t.valid)) = '1' or (i.forceread = '1') then
                
                -- $(del)
                --                read               
                --   Writeback     |   Writethrough  
                --        +--------+--------+        
                --    hit | miss        hit |<MISS>                   
                --   +----+----+       +----+----+   
                --   |     free|dirty  |         |   
                --   O1     +--+--+    O1        O3  
                --          |     |              |   
                --          O3<---O2             O4  
                --          |                        
                --          O4
                -- $(/del)
                
                -- $(del)
                -- $(/del)
                t.cmaddr_src := gdca_re;

                v.hold := '1';
                
                t.wbi.fifo_write := '1';
                v.state := gendc_wtwb_readdata;
                
              else                                                          
                
                -- $(del)
                --                read               
                --   Writeback     |   Writethrough  
                --        +--------+--------+        
                --    hit | miss       <HIT>| miss                   
                --   +----+----+       +----+----+   
                --   |     free|dirty  |         |   
                --   O1     +--+--+    O1        O3  
                --          |     |              |   
                --          O3<---O2             O4  
                --          |                        
                --          O4
                -- $(/del)
                
                t.setrep := t.set;
                t.datapi_src := gdcdp_cm;

              end if;
              
            else
              if (not (t.hit and t.valid)) = '1' or (i.forceread = '1') then
                
                -- $(del)
                --                read               
                --   Writeback     |   Writethrough  
                --        +--------+--------+        
                --    hit |<MISS>       hit | miss                   
                --   +----+----+       +----+----+   
                --   |     free|dirty  |         |   
                --   O1     +--+--+    O1        O3  
                --          |     |              |   
                --          O3<---O2             O4  
                --          |                        
                --          O4
                -- $(/del)

                v.hold := '1';
                
                if t.dirty = '1' then
                  v.state := gendc_wb_wbline;
                  v.state_wbline_next := gendc_wtwb_readdata;
                else
                  
                  t.wbi.fifo_write := '1';
                  v.state := gendc_wtwb_readdata;
                  
                end if;
                
                
              else
                
                -- $(del)
                --                read               
                --   Writeback     |   Writethrough  
                --        +--------+--------+        
                --   <HIT>| miss        hit | miss                   
                --   +----+----+       +----+----+   
                --   |     free|dirty  |         |   
                --   O1     +--+--+    O1        O3  
                --          |     |              |   
                --          O3<---O2             O4  
                --          |                        
                --          O4
                -- $(/del)
                
                t.setrep := t.set;
                t.datapi_src := gdcdp_cm;
                
              end if;
              
            end if;
            
            
          else

            if ctrl.writeback = '0' then
              if (not (t.hit and t.valid)) = '1' then
                -- $(del)
                --               write                                                
                --    writeback    |   Writethrough                                  
                --        +--------+--------+
                --    hit | miss        hit |<MISS>                                      
                --   +----+----+       +----+----+                               
                --   |     free|dirty  |         |                   
                --  O5      +--+--+   O4/O6     O6                              
                --          |     |                                            
                --          O5<---O2                                        
                -- $(/del)
                
                if ctrl.allocateonstore = '1' then
                  t.twrite := '1';
                  t.dwrite := '1';
                end if;
                
              else                                                          
                -- $(del)
                --               write                                                
                --    writeback    |   writethrough                                    
                --        +--------+--------+                                          
                --    hit | miss       <HIT>| miss                                     
                --   +----+----+       +----+----+                               
                --   |     free|dirty  |         |                   
                --  O5      +--+--+   O4/O6     O6                              
                --          |     |                                            
                --          O5<---O2                                            
                -- $(/del)
                
                t.setrep := t.set;
                t.twrite := '1';
                t.dwrite := '1';
              end if;
              
              v.state := gendc_wt_writedata;
              t.wbi.fifo_write := '1';
              
              
              t.cmaddr_src := gdca_re;   
              t.meaddr_src := gdcma_re;  -- addr cycle 1
              t.datain_src := gdcdi_in;  -- data cycle 2
              
            else
              if (not (t.hit and t.valid)) = '1' then
                -- $(del)
                --               write                                                
                --    writeback    |   writethrough                                  
                --        +--------+--------+
                --    hit |<MISS>       hit | miss                                      
                --   +----+----+       +----+----+                               
                --   |     free|dirty  |         |                   
                --  O5      +--+--+   O4/O6     O6                              
                --          |     |                                            
                --          O5<---O2
                -- $(/del)
                -- 
                if ctrl.allocateonstore = '0' then
                  v.hold := '1';
                  v.setrep_locked := '1';
                  v.state := gendc_wb_writedata;
                  t.wbi.fifo_write := '1';
                else
                  
                  if t.dirty = '1' then
                    v.hold := '1';
                    v.state := gendc_wb_wbline;
                    v.state_wbline_next := gendc_wb_writedata;
                  else

                    if (sr_locked = '1') then
                      v.hold := '1';
                      v.state := gendc_wb_writedata;
                      t.wbi.fifo_write := '1';
                    
                    else
                    
                      if i.param_r.size = lmd_word then
                      
                        -- note : store is 2 cycle (no reload needed)
                        t.twrite := '1';
                        t.dwrite := '1';
                      
                      else
                      
                        v.hold := '1';
                        v.state := gendc_wb_writedata;
                      
                      end if;
                    end if;
                  end if;
                end if;
              else
                -- $(del)
                --               write                                                
                --    writeback    |   writethrough                                  
                --        +--------+--------+                                  
                --   <HIT>| miss        hit | miss                                      
                --   +----+----+       +----+----+                               
                --   |     free|dirty  |         |                   
                --  O5      +--+--+   O4/O6     O6                              
                --          |     |                                            
                --          O5<---O2                                            
                -- $(/del)
                
                t.setrep := t.set;
                t.twrite := '1';
                t.dwrite := '1';
                
                t.tvalid_src := gdcvalid_old;
                t.tdirty_src := gdcdirty_add;
                
                if i.forcewrite = '1' then
                  v.setrep_locked := '1';
                  v.hold := '1';
                  v.state := gendc_wb_writedata;
                  t.wbi.fifo_write := '1';
                end if;
              end if;
            end if;
          end if;
        end if;

        v.setrep := std_logic_vector(conv_unsigned(t.setrep, lin_log2x(CFG_IC_SETS)));
        v.dirty := dcmo.tag_line(t.set).dirty;
        
-------------------------------------------------------------------------------
        
      when gendc_wtwb_readdata => 

        -- writethrough and writeback read, load and allocate
        -- $(del)
        --                read               
        --   Writeback     |   Writethrough  
        --        +--------+--------+        
        --    hit |<MISS>       hit |<MISS>                   
        --   +----+----+       +----+----+   
        --   |   <free>|<dirty>|         |   
        --   O1     +--+--+    O1        O3  
        --          |     |              |   
        --          O3<---O2             O4  
        --          |                        
        --          O4
        -- $(/del)
        
        t.datain_src := gdcdi_me;
        t.datapi_src := gdcdp_me;
        t.cmaddr_src := gdca_lo;

        if r.stored = '0' then
          t.wbi.fifo_write := '1';
        else
          if wbo.read_finish_v = '1' then

            t.mexc := wbo.read_mexc;
            --t.mexc := '1';
            
            if r.setrep_locked = '0' then
              t.twrite := '1';
              t.dwrite := '1';
            end if;
              
            if i.addrin_re = '1' then
              v.state := gendc_reloadtaddr;
            else
              v.state := gendc_hit;
              v.hold := '0';
            end if;
          end if;
        end if;
        
-------------------------------------------------------------------------------
        
      when gendc_wb_writedata =>
        
        -- writeback-write, allocate, allocate word on subword write
        -- $(del)
        --               write                                                
        --    writeback    |   Writethrough                                  
        --        +--------+--------+
        --    hit | miss        hit | miss                                       
        --   +----+----+       +----+----+                               
        --   |   <FREE>|<DIRTY>|         |                   
        --  O5      +--+--+   O4/O6     O6                              
        --          |     |                                            
        --          O5<---O2
        -- $(/del)

        -- todo: check for lock on all sets

        if r.setrep_locked = '1' then
          t.wbi.fifo_write := '1';
          if wbo.fifo_stored_v = '1' then
            v.hold := '0';
            v.state := gendc_hit;
          end if;
        else
          t.twrite := '1';

          -- load word of subword allocate
          if (t.size /= lmd_word) then
            t.twrite := '0';
            
            t.datain_src := gdcdi_me;
            t.cmaddr_src := gdca_lo;

            if r.stored = '0' then
              
              t.wbi.fifo_write := '1';
              t.size := lmd_word;
              t.read := '1';
              t.lock := '0';

              t.datain_src := gdcdi_me;
              t.datapi_src := gdcdp_me;
              t.cmaddr_src := gdca_lo;

            else
              
              if wbo.read_finish_v = '1' then
                t.mexc := wbo.read_mexc;
            
                t.twrite := '1';
                t.db_src := gdcdb_mem;
              end if;
            end if;            
          end if;

          if (t.twrite = '1') then
            t.cmaddr_src := gdca_lo;
            t.datain_src := gdcdi_lo;
            t.meaddr_src := gdcma_lo;
            t.twrite := '1';
            t.dwrite := '1';
            v.hold := '0';
            if i.addrin_re = '1' then
              v.state := gendc_reloadtaddr;
            else
              v.state := gendc_hit;
              v.hold := '0';
            end if;
          end if;
        end if;
        
-------------------------------------------------------------------------------
        
      when gendc_wt_writedata =>
        
        -- writethrough-write, no allocate
        -- $(del)
        --               write                                                
        --    writeback    |   Writethrough                                  
        --        +--------+--------+
        --    hit | miss       <HIT>|<MISS>                                      
        --   +----+----+       +----+----+                               
        --   |     free|dirty  |         |                   
        --  O5      +--+--+   O4/O6     O6                              
        --          |     |                                            
        --          O5<---O2                                        
        -- $(/del)
        
        t.datain_src := gdcdi_lo;
        t.meaddr_src := gdcma_lo;

        if r.stored = '0'  then
          v.hold := '1';
          t.wbi.fifo_write := '1';
        end if;
        if v.stored = '1' then
          v.hold := '0';
          v.state := gendc_hit;
        end if;
        
-------------------------------------------------------------------------------

        -- writeback, allocte full line
        -- $(del)                                                        
        --                read                              write               
        --   Writeback     |   Writethrough      writeback    |   writethrough  
        --        +--------+--------+                +--------+--------+        
        --    hit |<MISS>       hit | miss       hit |<MISS>       hit | miss                   
        --   +----+----+       +----+----+      +----+----+       +----+----+   
        --   |   <free>|<dirty>|         |      |   <free>|<dirty>|         |   
        --   O1     +--+--+    O1        O3    O5      +--+--+   O4/O6     O6   
        --          |     |              |             |     |                  
        --          O3<---O2             O4            O5<---O2                 
        --          |                                                    
        --          O4
        -- $(/del)
        
      when gendc_wb_fillline =>
        
        t.cmaddr_src := gdca_no;
        t.meaddr_src := gdcma_no;
        t.datain_src := gdcdi_me;
        
        t.cmaddr := r.p_address;
        t.cmaddr(GDCL_TLINE_U downto GDCL_TLINE_D) := r.fill_linepos;
        t.meaddr := (others => '0');
        t.meaddr(GDCL_TTAG_U downto GDCL_TTAG_D) := dcmo.tag_line(lin_convint(r.setrep)).tag;
        t.meaddr(GDCL_TLINE_U downto GDCL_TLINE_D) := r.linepos;
        t.linepos := so.res(GCML_DC_TLINE_BSZ-1 downto 0);

        if r.fill_linepos = GDCL_ZERO_C then
          t.tvalid_src := gdcvalid_new;
          t.tdirty_src := gdcdirty_new;
        else
          t.tvalid_src := gdcvalid_add;
          t.tdirty_src := gdcdirty_add;
        end if;
        
        t.size := lmd_word;
        t.read := '1';
        t.lock := '0';
        t.burst := '1';
        if r.linepos = GDCL_LAST_C then
          t.burst := '0';
        end if;
        
        if r.stored = '0' then
          t.wbi.fifo_write := '1';
          v.fill_linepos := r.linepos;
        else
          
          if r.wbnext = '0' then
            v.wbnext := '1';
            lin_incdec(r.linepos,v.linepos,'1','1');
          end if;
          
          if wbo.read_finish_v = '1' then

            t.mexc := wbo.read_mexc;
            
            v.stored := '0';
            v.wbnext := '0';

            -- return data (on load)
            if t.cmaddr(GDCL_TLINE_U downto GDCL_TLINE_D) = r.p_address(GDCL_TLINE_U downto GDCL_TLINE_D) then
              t.datapi_src := gdcdp_me;
            end if;
            
            t.twrite := '1';
            t.dwrite := '1';

            if (r.linepos = GDCL_ZERO_C) then
              v.state := gendc_hit;
            end if;
          end if;
        end if;
        
-------------------------------------------------------------------------------

        -- writeback, line flush
        -- $(del)                                                        
        --                read                              write               
        --   Writeback     |   Writethrough      writeback    |   writethrough  
        --        +--------+--------+                +--------+--------+        
        --    hit |<MISS>       hit | miss       hit |<MISS>       hit | miss                   
        --   +----+----+       +----+----+      +----+----+       +----+----+   
        --   |     free|<dirty>|         |      |     free|<dirty>|         |   
        --   O1     +--+--+    O1        O3    O5      +--+--+   O4/O6     O6   
        --          |     |              |             |     |                  
        --          O3<---O2             O4            O5<---O2                 
        --          |                                                    
        --          O4
        -- $(/del)

      when gendc_wb_wbline =>

        t.cmaddr_src := gdca_no;
        t.meaddr_src := gdcma_no;
        t.datain_src := gdcdi_no;
        t.datapi_src := gdcdp_no;

        t.linepos := so.res(GCML_DC_TLINE_BSZ-1 downto 0);

        t.cmaddr := r.p_address;
        t.cmaddr(GDCL_TLINE_U downto GDCL_TLINE_D) := t.linepos;
        t.meaddr := (others => '0');
        t.meaddr(GDCL_TTAG_U downto GDCL_TTAG_D) := dcmo.tag_line(lin_convint(r.setrep)).tag;
        t.meaddr(GDCL_TLINE_U downto GDCL_TLINE_D) := r.linepos;
        t.datain := r.o_wr_data;
        
        t.size := lmd_word;
        t.read := '0';
        t.lock := '0';
        t.burst := '0';
        
        if r.wbready = '0' then         --calculating first address
          
          v.wbready := '1';
          v.dirty(lin_convint(t.linepos)) := '0';
          v.linepos := t.linepos;
          
        else
          
          t.wbi.fifo_write := '1';

          -- burst calc
          t.linepos_lastbit := lin_decode(r.linepos);
          t.linepos_lastbit := t.linepos_lastbit(CFG_DC_TLINE_SZ-2 downto 0) & "0";
          if (r.dirty and t.linepos_lastbit) /= GDCL_ZERO_C then
            t.burst := '1';
          end if;

          -- buffer cm out
          if r.wbnext = '0' then
            v.wbnext := '1';
            v.o_wr_data := dcmo.dat_line(lin_convint(r.setrep)).data(t.pos);
            t.datain := v.o_wr_data;
          end if;

          -- next pos
          if wbo.fifo_stored_v = '1' then
            v.wbnext := '0';
            v.dirty(lin_convint(t.linepos)) := '0';
            v.linepos := t.linepos;
            if r.dirty = GDCL_ZERO_C then
              v.state := r.state_wbline_next;
            end if;
          end if;
        end if;

        v.stored := '0';
        
-------------------------------------------------------------------------------
        
      when gendc_reloadtaddr =>
        
        t.cmaddr_src := gdca_re;
        v.state := gendc_hit;
        v.hold := '0';
        
-------------------------------------------------------------------------------
        
      when others =>
        
    end case;

    if t.mexc = '1' then
      t.twrite := '0';
      t.dwrite := '0';
      v.mexc := '1';
    end if;
      
    -- cm read/write address 
    case t.cmaddr_src is
      when gdca_no => 
      when gdca_in => t.cmaddr := i.addr_in;
      when gdca_re => t.cmaddr := i.addr_re;
      when gdca_lo => t.cmaddr := r.p_address;
      when others => null;
    end case;

    -- mem load/store address (wb input)
    case t.meaddr_src is
      when gdcma_no => 
      when gdcma_in => t.meaddr := i.addr_in;
      when gdcma_re => t.meaddr := i.addr_re;
      when gdcma_lo => t.meaddr := r.p_address;
      when others => null;
    end case;
    
    t.setpos := std_logic_vector(conv_unsigned(t.setrep, lin_log2x(CFG_IC_SETS)));
    if r.hold = '1' then
      t.setpos := r.setrep;
    end if;

    -- data pipeline: read data output [cm|mem]->pipeline
    t.pos := gdcl_getpos(t.meaddr(GDCL_TLINE_U downto GDCL_TLINE_D));
    case t.datapi_src is
      when gdcdp_no => 
      when gdcdp_me => v.o_wr_data := wbo.read_data;
      when gdcdp_cm => v.o_wr_data := dcmo.dat_line(lin_convint(t.setpos)).data(t.pos);
      when others => 
    end case;
    v.doaddr(1 downto 0) := t.meaddr(1 downto 0);
    t.o.wr_data := gdcl_readdata ( r.doaddr, r.o_wr_data, CFG_BO_BUS, r.p_sign, r.p_size );
    
    -- write data input (from (pipeline or mem) to (cmem or mem))
    case t.datain_src is
      when gdcdi_no =>
      when gdcdi_in => t.datain := i.data_in;
      when gdcdi_re => t.datain := i.data_re;
      when gdcdi_lo => t.datain := r.p_data;
      when gdcdi_me => t.datain := wbo.read_data;
      when others => null;
    end case;
    
    -- input tag/data line
    -- $(del)
    --               read                               write                                                
    --   Writeback     |   Writethrough     Writeback     |   Writethrough                                        
    --        +--------+--------+                +--------+--------+                                                  
    --    hit | miss        hit | miss       hit | miss        hit | miss                                      
    --   +----+----+       +----+----+      +----+----+       +----+----+                               
    --   |     free|dirty  |         |      |     free|dirty  |         |                   
    --   O1     +--+--+    O1        O3   <O5>     +--+--+  <O4>/O6     O6                              
    --          |     |              |             |     |                                            
    --          O3<---O2            <O4>         <O5><---O2                                            
    --          |                                                                                                     
    --         <O4>                                                                                     
    -- $(/del)
    
    -- assemble input tag line    
    t.dcmi.addr := t.cmaddr;
    t.dcmi.tag_line := dcmo.tag_line(lin_convint(t.setpos));
    t.newvalid := (others => '0');
    t.newvalid := lin_decode(t.cmaddr(GDCL_TLINE_U downto GDCL_TLINE_D));
    case t.tvalid_src is
      when gdcvalid_old => 
      when gdcvalid_clr => t.dcmi.tag_line.valid := (others => '0');
      when gdcvalid_new => t.dcmi.tag_line.valid := t.newvalid;
      when gdcvalid_add => t.dcmi.tag_line.valid := t.dcmi.tag_line.valid or t.newvalid;
    end case;
    t.newdirty := (others => '0');
    t.newdirty := lin_decode(t.cmaddr(GDCL_TLINE_U downto GDCL_TLINE_D));
    case t.tdirty_src is
      when gdcdirty_old => 
      when gdcdirty_clr => t.dcmi.tag_line.dirty := (others => '0');
      when gdcdirty_new => t.dcmi.tag_line.dirty := t.newdirty;
      when gdcdirty_add => t.dcmi.tag_line.dirty := t.dcmi.tag_line.dirty or t.newdirty;
    end case;
    t.dcmi.tag_line.tag := t.cmaddr(GDCL_TTAG_U downto GDCL_TTAG_D);
    t.dcmi.tag_write := (others => '0');
    t.dcmi.tag_write(lin_convint(t.setpos)) := t.twrite;
    
    -- assemble input data line [mem->cache]
    t.dcmi.dat_line := dcmo.dat_line(lin_convint(t.setpos));
    case t.db_src is
      when gdcdb_mem => t.dcmi.dat_line.data(t.pos) := wbo.read_data;  -- on allocate subword
      when others => 
    end case;
    t.dcmi.dat_line.data(t.pos) := gdcl_writedata(t.cmaddr(1 downto 0),t.dcmi.dat_line.data(t.pos),t.datain,CFG_BO_BUS,t.size);
    t.dcmi.dat_write := (others => '0');
    t.dcmi.dat_write(lin_convint(t.setpos)) := t.dwrite;
    
    -- write buffer in 
    -- $(del)
    --               read                               write                                                
    --   Writeback     |   Writethrough     Writeback     |   Writethrough                                        
    --        +--------+--------+                +--------+--------+                                                  
    --    hit | miss        hit | miss       hit | miss        hit | miss                                      
    --   +----+----+       +----+----+      +----+----+       +----+----+                               
    --   |     free|dirty  |         |      |     free|dirty  |         |                   
    --   O1     +--+--+    O1        O3    O5      +--+--+   O4/<O6>   <O6>                              
    --          |     |              |             |     |                                            
    --          O3<---<O2>           O4           O5 <---<O2>                                            
    --          |                                                                                                     
    --          O4                                                                                     
    -- $(/del)

    t.o.me_mexc := t.mexc;
    t.o.wr_mexc := r.mexc;
    
    t.wbi.fifo_entry.data := t.datain;
    t.wbi.fifo_entry.addr := t.meaddr;
    t.wbi.fifo_entry.size := t.size;
    t.wbi.fifo_entry.read := t.read;
    t.wbi.fifo_entry.lock := t.lock;
    t.wbi.fifo_entry.burst := t.burst;
    case t.wbi.fifo_entry.size is
      when lmd_word => t.wbi.fifo_entry.addr(1 downto 0) := (others => '0');
      when lmd_half => t.wbi.fifo_entry.addr(0) := '0';
      when others => 
    end case;
    
    -- reset
    if ( rst = '0' ) then
      v.hold := '0';
    end if;
    
    t.o.hold := r.hold;
    
    c <= v;

    o <= t.o;
    si <= t.si;
    dcmi <= t.dcmi;
    wbi <= t.wbi;

    sr_setfree <= t.sr_setfree;
    sr_setlock <= t.sr_setlock;
    sr_useset <= t.sr_useset;
    
    -- pragma translate_off
    vdbg := rdbg;
    vdbg.cmaddr := t.cmaddr;
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

  cnt0: arith_cnt8 port map (rst, clk, si, so);  

  sr0: setrepl generic map ( SETSIZE => CFG_DC_SETS,SETSIZE_logx => GCML_DC_SETS_X )
    port map (rst, clk, sr_setfree, sr_setlock, sr_useset, sr_locked, sr_free, sr_setrep_free, sr_setrep_repl);
        
  -- pragma translate_off
  check0 : process (rst)
  begin
    assert (CFG_DC_TLINE_SZ <= 8) report "Error: current arith_cntxx component can only count up to 8 positions. Replace with a larger one." severity failure;
  end process;
  -- pragma translate_on
  
end rtl;
