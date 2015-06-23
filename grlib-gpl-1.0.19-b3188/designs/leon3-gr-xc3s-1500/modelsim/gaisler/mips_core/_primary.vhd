library verilog;
use verilog.vl_types.all;
entity mips_core is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        zz_ins_i        : in     vl_logic_vector(31 downto 0);
        iack_o          : out    vl_logic;
        qa              : in     vl_logic_vector(31 downto 0);
        qb              : in     vl_logic_vector(31 downto 0);
        wb_din_o        : out    vl_logic_vector(31 downto 0);
        rdaddra_o       : out    vl_logic_vector(4 downto 0);
        rdaddrb_o       : out    vl_logic_vector(4 downto 0);
        wb_addr_o       : out    vl_logic_vector(4 downto 0);
        wb_we_o         : out    vl_logic;
        zz_pc_o         : out    vl_logic_vector(31 downto 0);
        dmem_ctl_ur_o   : out    vl_logic_vector(4 downto 0);
        alu_ur_o        : out    vl_logic_vector(31 downto 0);
        dmem_data_ur_o  : out    vl_logic_vector(31 downto 0);
        dout            : in     vl_logic_vector(31 downto 0);
        size            : out    vl_logic_vector(1 downto 0);
        branch          : out    vl_logic;
        hold            : in     vl_logic;
        imds            : in     vl_logic;
        dmds            : in     vl_logic;
        asi_pass2       : out    vl_logic_vector(4 downto 0);
        pc_next         : out    vl_logic_vector(31 downto 0)
    );
end mips_core;
