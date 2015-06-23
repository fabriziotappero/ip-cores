library verilog;
use verilog.vl_types.all;
entity ac97_dma_if is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        o3_status       : in     vl_logic_vector(1 downto 0);
        o4_status       : in     vl_logic_vector(1 downto 0);
        o6_status       : in     vl_logic_vector(1 downto 0);
        o7_status       : in     vl_logic_vector(1 downto 0);
        o8_status       : in     vl_logic_vector(1 downto 0);
        o9_status       : in     vl_logic_vector(1 downto 0);
        o3_empty        : in     vl_logic;
        o4_empty        : in     vl_logic;
        o6_empty        : in     vl_logic;
        o7_empty        : in     vl_logic;
        o8_empty        : in     vl_logic;
        o9_empty        : in     vl_logic;
        i3_status       : in     vl_logic_vector(1 downto 0);
        i4_status       : in     vl_logic_vector(1 downto 0);
        i6_status       : in     vl_logic_vector(1 downto 0);
        i3_full         : in     vl_logic;
        i4_full         : in     vl_logic;
        i6_full         : in     vl_logic;
        oc0_cfg         : in     vl_logic_vector(7 downto 0);
        oc1_cfg         : in     vl_logic_vector(7 downto 0);
        oc2_cfg         : in     vl_logic_vector(7 downto 0);
        oc3_cfg         : in     vl_logic_vector(7 downto 0);
        oc4_cfg         : in     vl_logic_vector(7 downto 0);
        oc5_cfg         : in     vl_logic_vector(7 downto 0);
        ic0_cfg         : in     vl_logic_vector(7 downto 0);
        ic1_cfg         : in     vl_logic_vector(7 downto 0);
        ic2_cfg         : in     vl_logic_vector(7 downto 0);
        dma_req         : out    vl_logic_vector(8 downto 0);
        dma_ack         : in     vl_logic_vector(8 downto 0)
    );
end ac97_dma_if;
