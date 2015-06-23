library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.leval2_pipelineregs.all;
use work.leval2_package.all;

entity leval2 is
    port (
    clk : in std_logic;
    rst : in std_logic;
    data_in : in std_logic_vector (BUS_BITS - 1 downto 0);
    data_out : in std_logic_vector (BUS_BITS - 1 downto 0);
    addr_bus : out std_logic_vector (ADDR_BITS - 1 downto 0);
    iowait : in std_logic;
    Sync : in std_logic;
    read : out std_logic;
    write : out std_logic;
    led : out std_logic_vector(7 downto 0));
end entity;


architecture mixed of leval2 is
    ----------------------------------------------------
    -- Pipeline register instances.
    ----------------------------------------------------
    signal IFID : IFID_t; 
    signal IDEX : IDEX_t;
    signal EXMEM : EXMEM_t;
    signal M1M2 : M1M2_t;
    signal M2WB : M2WB_t;
    
	
	----------------------------------------------------
    -- Signals from/internal to stages
    ----------------------------------------------------
    
    -- Fetch
    ----------------------------------------------------------------------------
    signal PC : std_logic_vector(MC_ADDR_BITS - 1 downto 0);
    signal PCincremented : std_logic_vector(MC_ADDR_BITS - 1 downto 0);
--    signal PCmuxin : std_logic_vector(MC_ADDR_BITS - 1 downto 0);
	signal InstrMemWe : std_logic;
	signal InstrWriteData : std_logic_vector(MC_INSTR_BITS - 1 downto 0);
	signal InstrWriteAddress : std_logic_vector(MC_ADDR_BITS - 1 downto 0);
	signal Instruction : std_logic_vector(MC_INSTR_BITS - 1 downto 0);

    -- Signals from decode stage
    ----------------------------------------------------------------------------
	signal RegAddr1 : std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
	signal RegAddr2 : std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
    signal RegData1 : std_logic_vector(WORD_BITS - 1 downto 0);
    signal RegData2 : std_logic_vector(WORD_BITS - 1 downto 0);
    signal IndirReg1Sel : std_logic;
    signal IndirReg2Sel : std_logic;

    -- Signals from execute stage
    ----------------------------------------------------------------------------
    signal Flags : std_logic_vector(STATUS_REG_BITS - 1 downto 0);
    signal AluRes : std_logic_vector(OBJECT_SIZE - 1 downto 0);
    signal AluIn1 : std_logic_vector(OBJECT_SIZe - 1 downto 0);
    signal AluIn2 : std_logic_vector(OBJECT_SIZe - 1 downto 0);


    -- Signals from/internal to memory 1 stage
    ----------------------------------------------------------------------------
	signal Tag : std_logic_vector(CACHE_TAG_BITS - 1 downto 0);	
    signal BranchTaken : std_logic;
		
    -- Signals from memory 2 stage
    ----------------------------------------------------------------------------
	signal CacheHit : std_logic;
	signal WriteCache : std_logic;
	signal MemSrc : std_logic_vector(WORD_BITS - 1 downto 0);
	signal CachedData : std_logic_vector(WORD_BITS - 1 downto 0);

    -- Signals from write-back stage
    ----------------------------------------------------------------------------
    signal WriteData : std_logic_vector(WORD_BITS - 1 downto 0);

    -- Signals from control
    ----------------------------------------------------------------------------
    signal PCMuxSel : std_logic_vector(1 downto 0);
    signal AluOp : std_logic_vector(ALU_FUNCT_SIZE - 1 downto 0);
    signal WriteReg : std_logic;
    signal MemToReg : std_logic;
    signal Store : std_logic;
    signal AluIn2Src : std_logic;
    signal IndirMux1 : std_logic;
    signal IndirMux2 : std_logic;
    signal Flush : std_logic;
	signal Branch : std_logic;
    signal Stall : std_logic;

 
    -- Signals from forward
    signal FwdMux1 : std_logic_vector(2 downto 0);
    signal FwdMux2 : std_logic_vector(2 downto 0);
 
    -- Signals from hazard
    ----------------------------------------------------------------------------
	signal Hazard : std_logic;

	-- Signals from outside
    ----------------------------------------------------------------------------
	signal LoadedMem : std_logic_vector(WORD_BITS - 1 downto 0);
	signal WritingMem : std_logic_vector(WORD_BITS - 1 downto 0);
--	signal Sync : std_logic;
    signal MemWait : std_logic;



begin
    ----------------------------------------------------
    -- Control unit
    ----------------------------------------------------
    control_unit : entity control 
    port map (
        IndirReg1Sel,
        IndirReg2Sel,
        PCMuxSel,
        AluOp,
        WriteReg,
        Flush,
        MemToReg,
        IndirMux1,
        IndirMux2,
		Branch,
		Store,
        Stall,
        Instruction(INSTR_OPCODE_START downto INSTR_OPCODE_END),
        MemWait,
		Sync,
        BranchTaken,
		Hazard
             );

	----------------------------------------------------
	-- Forwarding unit
    ----------------------------------------------------
	forwarding_unit : entity Forward 
	port map (
		IDEX.AluIn2Src,
		IDEX.Branch,
		IDEX.IR(INSTR_REG1_START downto INSTR_REG1_END),
		IDEX.IR(INSTR_REG2_START downto INSTR_REG2_END),
		EXMEM.IR(INSTR_REG1_START downto INSTR_REG1_END),
		EXMEM.IR(INSTR_REG2_START downto INSTR_REG2_END),
		M2WB.IR(INSTR_REG1_START downto INSTR_REG1_END),
		M2WB.IR(INSTR_REG2_START downto INSTR_REG2_END),
		FwdMux1,
		FwdMux2
	);

	----------------------------------------------------
	-- Hazard unit
    ----------------------------------------------------
	hazard_detection : entity Hazard
	port map (
        Instruction(INSTR_OPCODE_START downto INSTR_OPCODE_END),
		Instruction(INSTR_REG1_START downto INSTR_REG1_END),
		Instruction(INSTR_REG2_START downto INSTR_REG2_END),
		IDEX.IR(INSTR_OPCODE_START downto INSTR_OPCODE_END),
		IDEX.IR(INSTR_REG1_START downto INSTR_REG1_END),
		IDEX.IR(INSTR_REG2_START downto INSTR_REG2_END),
		EXMEM.IR(INSTR_OPCODE_START downto INSTR_OPCODE_END),
		EXMEM.IR(INSTR_REG1_START downto INSTR_REG1_END),
		EXMEM.IR(INSTR_REG2_START downto INSTR_REG2_END),
		Hazard );

		
	


    ----------------------------------------------------
    -- Fetch stage
    ----------------------------------------------------
    PCincremented <= std_logic_vector(unsigned(PC) + 1);

	instr_mem : entity rwmem 
	generic map (
		INSTR_MEM_SIZE,
		MC_ADDR_BITS,
		MC_INSTR_BITS)
		
	port map (
		clk,
		InstrMemWe,
		PC,
		InstrWriteAddress,
		InstrWriteData,
		Instruction);

    instr_fetch : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                PC <= (others => '0');
            elsif PCMuxSel = "00" then -- pipeline stall
                PC <= PC;
				IFID.PC <= PC;
            elsif PCMUxSel = "01" then
                PC <= EXMEM.AluRes(MC_ADDR_BITS - 1 downto 0);
				IFID.PC <= EXMEM.AluRes(MC_ADDR_BITS - 1 downto 0);
            else
                PC <= PCIncremented;
				IFID.PC <= PCIncremented;
            end if;

            if Flush = '1' then
                IFID.PC <= (others => '0');
            end if;

        end if;
    end process;


    ----------------------------------------------------
    -- Decode stage
    ----------------------------------------------------
  
    -- If we stored the indirect-bits in the previous cycle,
    -- we now shall use the results from that register fetch
    -- to address the new fetch, but avoid looping by anding with negated.
    IndirReg1Sel <= not IDEX.IndirReg1bit and Instruction(INSTR_REG1_INDIR);
    IndirReg2Sel <= not IDEX.IndirReg2bit and Instruction(INSTR_REG2_INDIR);


	-- Indirection multiplexers
	RegAddr1 <= Instruction(INSTR_REG1_START downto INSTR_REG1_END) 
				when IndirMux1 = '0' 
				else IDEX.IndirReg1;

	RegAddr2 <= Instruction(INSTR_REG2_START downto INSTR_REG2_END) 
				when IndirMux2 = '0' 
				else IDEX.IndirReg2;

    regfile : entity rrwmem
    generic map (
        memsize => REGS_SIZE,
        addr_width => REGS_ADDR_BITS,
        data_width => WORD_BITS,
        initfile => SCRATCH_MEM_INIT)
    port map (
        clk,
        M2WB.WriteReg,
		RegAddr1,
		RegAddr2,
		M2WB.IR(INSTR_REG1_START downto INSTR_REG1_END),
        WriteData,
        RegData1,
        RegData2);

    instr_decode : process (clk)
    begin
        if rising_edge(clk) then
            IDEX.WriteReg <= WriteReg;  
            IDEX.MemToReg <= MemToReg;
            IDEX.Store <= Store;
            IDEX.AluIn2Src <= AluIn2Src;
            IDEX.AluOp <= AluOp;
            IDEX.IndirReg1bit <= Instruction(INSTR_REG1_INDIR);
            IDEX.IndirReg2bit <= Instruction(INSTR_REG2_INDIR);
            IDEX.Branch <= Branch;
            IDEX.IR <= Instruction;
            IDEX.PC <= IFID.PC;
            IDEX.Immediate <= sign_extend_18_26(Instruction(INSTR_IMM_START downto 0));

            -- Flushing and stalling control paths. 
            if Flush = '1' then
                IDEX.WriteReg <= '0';  
                IDEX.MemToReg <= '0';
                IDEX.Store <= '0';
                IDEX.AluIn2Src <= '0';
                IDEX.AluOp <= ALU_PASS;
                IDEX.IndirReg1bit <= '0';
                IDEX.IndirReg2bit <= '0';
                IDEX.Branch <= '0';
                IDEX.IR <= (others=>'0');
                IDEX.PC <= (others=>'0');
                IDEX.Immediate <= (others=>'0');
            elsif Stall = '1' then
                IDEX.WriteReg <= IDEX.WriteReg;
                IDEX.MemToReg <= IDEX.MemToReg;
                IDEX.Store <= IDEX.Store;
                IDEX.AluIn2Src <= IDEX.AluIn2Src;
                IDEX.AluOp <= IDEX.AluOp;
                IDEX.IndirReg1bit <= IDEX.IndirReg1bit;
                IDEX.IndirReg2bit <= IDEX.IndirReg2bit;
                IDEX.Branch <= IDEX.Branch;
                IDEX.IR <= IDEX.IR;
                IDEX.PC <= IDEX.PC;
                IDEX.Immediate <= IDEX.Immediate;
            end if;
        end if;
    end process;



    ----------------------------------------------------
    -- Execution stage
    ----------------------------------------------------
    -- Forwarding muxes
    
    fwd_mux1 : process (FwdMux1, RegData1, IDEX.PC, M2WB.MemWriteData, M2WB.AluRes, EXMEM.AluRes) 
    begin
        case FwdMux1 is
            when FWD_BRANCH =>
                AluIn1 <= IDEX.PC;
            when FWD_REGDATA =>
                AluIn1 <= RegData1;
            when FWD_1_EXMEM_ALURES =>
                AluIn1 <= EXMEM.AluRes;
            when FWD_1_M2WB_ALURES => 
                AluIn1 <= M2WB.AluRes;
            when FWD_1_M2WB_MEMWRITEDATA => 
                AluIn1 <= M2WB.MemWriteData;
			when others => 
				AluIn1 <= "00000000000000000000000000000000";
        end case;
	end process;

	fwd_mux2 : process (FwdMux2, RegData2, IDEX.Immediate, M2WB.MemWriteData, M2WB.AluRes, EXMEM.AluRes) 
    begin
        case FwdMux2 is
            when FWD_2_IMMEDIATE =>
                AluIn2 <= IDEX.Immediate;
            when FWD_REGDATA =>
                AluIn2 <= RegData2;
            when FWD_2_EXMEM_ALURES =>
                AluIn2 <= EXMEM.AluRes;
            when FWD_2_M2WB_ALURES => 
                AluIn2 <= M2WB.AluRes;
            when FWD_2_M2WB_MEMWRITEDATA => 
                AluIn2 <= M2WB.MemWriteData;
			when others => 
				AluIn2 <= "00000000000000000000000000000000";
        end case;
	end process;



    main_alu : entity alu 
    port map (
        AluIn1,
        AluIn2,
        IDEX.AluOp,
        Flags,
        AluRes
             );
    exec_stage : process (clk)
    begin 
        if rising_edge(clk) then
            EXMEM.WriteReg <= IDEX.WriteReg;
            EXMEM.MemToReg <= IDEX.MemToReg;
            EXMEM.Store <= IDEX.Store;
            EXMEM.IR <= IDEX.IR;
            EXMEM.AluRes <= AluRes;
            EXMEM.MemWriteData <= RegData2;
        end if;
    end process;



    ----------------------------------------------------
    -- Memory stage 1
    ----------------------------------------------------


	tags : entity rwmem
	generic map (
		CACHE_LINES,
		CACHE_INDEX_BITS,
		CACHE_TAG_BITS)
			
	port map (
		clk,
		WriteCache,
		EXMEM.AluRes(CACHE_INDEX_POS downto 0),
		M1M2.Address(CACHE_INDEX_POS downto 0) ,--write addr
		M1M2.Tag,--write data
		Tag);
	

	data : entity rwmem
	generic map (
		CACHE_LINES,
		CACHE_INDEX_BITS,
		CACHE_DATA_BITS)
			
	port map (
		clk,
		WriteCache,
		EXMEM.AluRes(CACHE_INDEX_POS downto 0),
		M1M2.Address(CACHE_INDEX_POS downto 0) ,--write addr
		MemSrc,--write data
		CachedData);

	mem1 : process (clk)
	begin
		if rising_edge(clk) then
			M1M2.WriteReg <= EXMEM.WriteReg;
			M1M2.MemToReg <= EXMEM.MemToReg;
			M1M2.Store <= EXMEM.Store;

			M1M2.IR <= EXMEM.IR;
			M1M2.Tag <= Tag;
			M1M2.Address <= EXMEM.AluRes;
			M1M2.Data <= CachedData;
			M1M2.MemWriteData <= EXMEM.MemWriteData;

            if Stall = '1' then
                 M1M2.WriteReg  <=  M1M2.WriteReg ;
                 M1M2.MemToReg  <=  M1M2.MemToReg ;
                 M1M2.Store  <=  M1M2.Store ;

                 M1M2.IR  <=  M1M2.IR ;
                 M1M2.Tag  <=  M1M2.Tag ;
                 M1M2.Address  <=  M1M2.Address ;
                 M1M2.Data  <=  M1M2.Data ;
                 M1M2.MemWriteData  <=  M1M2.MemWriteData ;
            end if;

 
		end if;
	end process;

	----------------------------------------------------
    -- Memory stage 2
    ----------------------------------------------------
	
	addr_bus <= M1M2.Address;

	-- Tag compare
	CacheHit <= '1' when M1M2.Tag = M1M2.Address(CACHE_TAG_START downto CACHE_TAG_END);
	WriteCache <= not CacheHit;

	LoadedMem <= data_in;
	WritingMem <= data_out;

	MemWait <= iowait; -- From outside.

	-- The cache result mux
	memmux : process(M1M2.Data, M1M2.MemWriteData, LoadedMem)
	begin
		if M1M2.Store = '1' then
			MemSrc <= M1M2.Data; -- don't care: we're storing.
		elsif M1M2.Store = '0' and CacheHit = '1' then -- cache hit
			MemSrc <= M1M2.Data;
		elsif MemToReg = '1' and CacheHit = '0' then -- cache miss
			MemSrc <= LoadedMem;
		end if;
	end process;


	
	mem2 : process (clk)
	begin

		write <= M1M2.Store; -- to outside
		read <= '0';

		if rising_edge(clk) then
			M2WB.WriteReg <= M1M2.WriteReg;
			M2WB.MemToReg <= M1M2.MemToReg;

			M2WB.IR <= M1M2.IR;
			M2WB.AluRes <= M1M2.Address;
			M2WB.MemWriteData <= MemSrc;

            if Stall = '1' then
                 M2WB.WriteReg  <=  M2WB.WriteReg ;
                 M2WB.MemToReg  <=  M2WB.MemToReg ;
                 M2WB.IR  <=  M2WB.IR ;
                 M2WB.AluRes  <=  M2WB.AluRes ;
                 M2WB.MemWriteData  <=  M2WB.MemWriteData ;
            end if;
		end if;
	end process;

	----------------------------------------------------
    -- Write back
    ----------------------------------------------------
	WriteData <= M2WB.AluRes when M2WB.MemToReg = '0' else M2WB.MemWriteData;		

end architecture;
