library verilog;
use verilog.vl_types.all;
entity ctl_FSM is
    generic(
        ID_CUR          : integer := 1;
        ID_LD           : integer := 5;
        ID_MUL          : integer := 2;
        ID_NOI          : integer := 6;
        ID_RET          : integer := 4;
        PC_IGN          : integer := 1;
        PC_IRQ          : integer := 4;
        PC_KEP          : integer := 2;
        PC_RST          : integer := 8
    );
    port(
        clk             : in     vl_logic;
        hold            : in     vl_logic;
        id_cmd          : in     vl_logic_vector(2 downto 0);
        rst             : in     vl_logic;
        iack            : out    vl_logic;
        zz_is_nop       : out    vl_logic;
        id2ra_ctl_clr   : out    vl_logic;
        id2ra_ctl_cls   : out    vl_logic;
        id2ra_ins_clr   : out    vl_logic;
        id2ra_ins_cls   : out    vl_logic;
        pc_prectl       : out    vl_logic_vector(3 downto 0);
        ra2exec_ctl_clr : out    vl_logic
    );
end ctl_FSM;
