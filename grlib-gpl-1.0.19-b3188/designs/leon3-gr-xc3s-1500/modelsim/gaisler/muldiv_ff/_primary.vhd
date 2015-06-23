library verilog;
use verilog.vl_types.all;
entity muldiv_ff is
    generic(
        OP_MULT         : integer := 9;
        OP_MULTU        : integer := 8;
        OP_DIV          : integer := 11;
        OP_DIVU         : integer := 10;
        OP_MFHI         : integer := 6;
        OP_MFLO         : integer := 7;
        OP_MTHI         : integer := 31;
        OP_MTLO         : integer := 30;
        OP_NONE         : integer := 0
    );
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        op_type         : in     vl_logic_vector(4 downto 0);
        op1             : in     vl_logic_vector(31 downto 0);
        op2             : in     vl_logic_vector(31 downto 0);
        rdy             : out    vl_logic;
        res             : out    vl_logic_vector(31 downto 0)
    );
end muldiv_ff;
