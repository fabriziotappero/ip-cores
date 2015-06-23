-- $(lic)
-- $(help_generic)
-- $(help_local)

library IEEE;
use IEEE.std_logic_1164.all;
use work.armcmd.all;
use work.armshiefter.all;
use work.armpctrl.all;
use work.gendc_lib.all;

package armcmd_comp is

-------------------------------------------------------------------------------
-- Arithmetic commands
  
type armcmd_al_typ_in is record
                           
   ctrli    : acm_ctrlin;
   
end record;

type armcmd_al_typ_out is record
   
   ctrlo    : acm_ctrlout;

   -- rrstg
   r1_src    : acm_regsrc;           -- (micro.r1)
   r2_src    : acm_regsrc;           -- (micro.r2)
   rd_src    : acm_rdsrc;            -- (pctrl.wr.wrop_rd)
  
   -- rsstg:
   rsop_op1_src : apc_rsop_opsrc;    -- EXSTG operand1 source (pctrl.rs.rsop_op1_src)
   rsop_op2_src : apc_rsop_opsrc;    -- EXSTG operand2 source (pctrl.rs.rsop_op2_src)
   rsop_buf2_src : apc_rsop_bufsrc;  -- RSSTG buffer1 source (pctrl.rs.rsop_buf2_src)
  
   
end record;

component armcmd_al
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_al_typ_in;
    o       : out armcmd_al_typ_out
    );
end component;

-------------------------------------------------------------------------------
-- ctrl commands (msr,mrs,b)

type armcmd_sr_typ_in is record
                           
   ctrli    : acm_ctrlin;

   deid  : std_logic_vector(2 downto 0);  -- (destg.pctrl.id)

   exid  : std_logic_vector(2 downto 0);  -- (exstg.pctrl.id)
   exvalid : std_logic;                   -- (exstg.pctrl.valid)

   wrid  : std_logic_vector(2 downto 0);  -- (wrstg.pctrl.id) 
   wrvalid : std_logic;                   -- (wrstg.pctrl.valid)

end record;

type armcmd_sr_typ_out is record
                            
   ctrlo    : acm_ctrlout;

   -- rrstg:
   r2_src    : acm_regsrc;                 -- (micro.r2)
   rd_src    : acm_rdsrc;                  -- (pctrl.wr.wrop_rd)
  
   -- rsstg:
   rsop_styp        : ash_styp;            -- RSSTG shieft op (pctrl.rs.rsop_styp)
   rsop_sdir        : ash_sdir;            -- RSSTG shieft dir (pctrl.rs.rsop_sdir)
   rsop_op2_src     : apc_rsop_opsrc;      -- EXSTG operand2 source (pctrl.rs.rsop_op2_src)
  
   -- exstg:
   exop_setcpsr : std_logic;               -- EXSTG set cpsr (pctrl.ex.exop_setcpsr)
   
end record;

component armcmd_sr
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_sr_typ_in;
    o       : out armcmd_sr_typ_out
    );
end component;

type armcmd_bl_typ_in is record
                           
   ctrli    : acm_ctrlin;


end record;

type armcmd_bl_typ_out is record
                            
   ctrlo    : acm_ctrlout;

   r1_src    : acm_regsrc;  -- (micro.r1)
   r2_src    : acm_regsrc;  -- (micro.r2)
   rd_src    : acm_rdsrc;   -- (pctrl.wr.wrop_rd)
  
   rsop_op2_src     : apc_rsop_opsrc;    -- EXSTG operand1 source (pctrl.rs.rsop_op2_src)
  
   data2            : std_logic_vector(31 downto 0); -- immidiate 1 (pctlr.data2)
   
end record;

component armcmd_bl
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_bl_typ_in;
    o       : out armcmd_bl_typ_out
    );
end component;

-------------------------------------------------------------------------------
-- memory commands (ldr, str, ldm, stm)

type armcmd_ld_typ_in is record
                           
   ctrli    : acm_ctrlin;

   ctrlmemo : acm_ctrlmemout;
      
end record;

type armcmd_ld_typ_out is record
   
   ctrlo    : acm_ctrlout;

   ctrlmemo : acm_ctrlmemout;
   
   rsop_styp        : ash_styp;  -- RSSTG shieft op (pctrl.rs.rsop_styp)
   rsop_sdir        : ash_sdir;  -- RSSTG shieft dir (pctrl.rs.rsop_sdir)

end record;

component armcmd_ld 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_ld_typ_in;
    o       : out armcmd_ld_typ_out
    );
end component;

type armcmd_st_typ_in is record
                           
   ctrli    : acm_ctrlin;

   ctrlmemo : acm_ctrlmemout;
            
end record;

type armcmd_st_typ_out is record
   
   ctrlo    : acm_ctrlout;

   ctrlmemo : acm_ctrlmemout;
   
   rsop_styp        : ash_styp;  -- RSSTG shieft op (pctrl.rs.rsop_styp)
   rsop_sdir        : ash_sdir;  -- RSSTG shieft dir (pctrl.rs.rsop_sdir)

end record;

component armcmd_st 
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_st_typ_in;
    o       : out armcmd_st_typ_out
    );
end component;

type armcmd_lm_typ_in is record
                           
   ctrli    : acm_ctrlin;

   ctrlmulti : acm_ctrlmult_in;
   
end record;

type armcmd_lm_typ_out is record
   
   ctrlo    : acm_ctrlout;

   ctrlmemo : acm_ctrlmemout;

end record;

component armcmd_lm
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_lm_typ_in;
    o       : out armcmd_lm_typ_out
    );
end component;

type armcmd_sm_typ_in is record
                           
   ctrli    : acm_ctrlin;

   ctrlmulti : acm_ctrlmult_in;
   
end record;

type armcmd_sm_typ_out is record
   
   ctrlo    : acm_ctrlout;

   ctrlmemo : acm_ctrlmemout;

end record;

component armcmd_sm
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_sm_typ_in;
    o       : out armcmd_sm_typ_out
    );
end component;

type armcmd_sw_typ_in is record
                           
   ctrli    : acm_ctrlin;
   
   ctrlmemo : acm_ctrlmemout;

end record;

type armcmd_sw_typ_out is record
   
   ctrlo    : acm_ctrlout;

   ctrlmemo : acm_ctrlmemout;

end record;

component armcmd_sw
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_sw_typ_in;
    o       : out armcmd_sw_typ_out
    );
end component;

-------------------------------------------------------------------------------
-- Coprocessor commands

type armcmd_cr_typ_in is record
                           
   ctrli    : acm_ctrlin;

   fromCP_busy : std_logic;

end record;

type armcmd_cr_typ_out is record
   
   ctrlo    : acm_ctrlout;

   r1_src    : acm_regsrc;           -- (micro.r1)
   rd_src    : acm_rdsrc;            -- (pctrl.wr.wrop_rd)

end record;

component armcmd_cr
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_cr_typ_in;
    o       : out armcmd_cr_typ_out
    );
end component;

type armcmd_cl_typ_in is record
                           
   ctrli    : acm_ctrlin;
   
   ctrlmemo : acm_ctrlmemout;
   fromCP_busy : std_logic;
   fromCP_last : std_logic;

end record;

type armcmd_cl_typ_out is record
   
   ctrlo    : acm_ctrlout;

   ctrlmemo : acm_ctrlmemout;

end record;

component armcmd_cl
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_cl_typ_in;
    o       : out armcmd_cl_typ_out
    );
end component;

type armcmd_cs_typ_in is record
                           
   ctrli    : acm_ctrlin;
   
   ctrlmemo : acm_ctrlmemout;
   fromCP_busy : std_logic;
   fromCP_last : std_logic;

end record;

type armcmd_cs_typ_out is record
   
   ctrlo    : acm_ctrlout;

   ctrlmemo : acm_ctrlmemout;

end record;

component armcmd_cs
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armcmd_cs_typ_in;
    o       : out armcmd_cs_typ_out
    );
end component;

end armcmd_comp;
