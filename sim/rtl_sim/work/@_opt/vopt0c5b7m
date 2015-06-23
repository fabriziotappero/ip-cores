library verilog;
use verilog.vl_types.all;
entity registerDelay is
    generic(
        DATA_WIDTH      : integer := 8;
        STAGES          : integer := 1
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        enable          : in     vl_logic;
        d               : in     vl_logic_vector;
        q               : out    vl_logic_vector
    );
end registerDelay;
