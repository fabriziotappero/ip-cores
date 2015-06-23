library verilog;
use verilog.vl_types.all;
entity pc_gen is
    port(
        ctl             : in     vl_logic_vector(2 downto 0);
        hold            : in     vl_logic;
        clk             : in     vl_logic;
        pc_next         : out    vl_logic_vector(31 downto 0);
        branch          : out    vl_logic;
        pc_prectl       : in     vl_logic_vector(3 downto 0);
        check           : in     vl_logic;
        s               : in     vl_logic_vector(31 downto 0);
        pc              : in     vl_logic_vector(31 downto 0);
        zz_spc          : in     vl_logic_vector(31 downto 0);
        imm             : in     vl_logic_vector(31 downto 0)
    );
end pc_gen;
