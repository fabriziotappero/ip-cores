library verilog;
use verilog.vl_types.all;
entity ramDualPort is
    generic(
        DATA_WIDTH      : integer := 8;
        ADDRESS_WIDTH   : integer := 8
    );
    port(
        dataA           : in     vl_logic_vector;
        dataB           : in     vl_logic_vector;
        addrA           : in     vl_logic_vector;
        addrB           : in     vl_logic_vector;
        weA             : in     vl_logic;
        weB             : in     vl_logic;
        clk             : in     vl_logic;
        qA              : out    vl_logic_vector;
        qB              : out    vl_logic_vector
    );
end ramDualPort;
