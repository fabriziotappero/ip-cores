-- synthesis library lib

--------------------------------------------------------------------
-- Project : SPI receivers master 
-- Author : AlexRayne
-- Date : 2009.03.16.03
-- File : 
-- Design  : 
--------------------------------------------------------------------
-- Description : (win1251) SPI мастер-приемник с минимальными затратами ресурсов.
--      и возможностью выдачи shut-down посылки. ѕреназначено дл€ загрузки ј÷ѕ AD747x.
--      ћожет загружать настраиваемую часть SPI последовательности (кусок).
--      формирует последовательность вхождени€ и выхода из посылки сигналов nSS и SCK:
--          посылка обозначаетс€ активным nSS('0'), на старте посылки SCK='1' полтакта
--          загружаютс€ биты по переднему фронту SCK, последний бит посылки неимеет заднего
--           фронта, SCK = '1' все пассивное врем€.

-- Description : SPI master-receiver minimalistic costs
--      intended for loading ADC AD747x, capable produce shut-down frames.
--      can load tunable part of frame. generate entry/exit sequences on nSS, SCK:
--          activate nSS='0' on frame transfer, SCK='1' for half clock cycle at frame start,
--          data loads on rising front SCK, last frame bit have no falling edge SCK,
--          SCK='1' durung inactive period.   

--   SDLen, SDMax:
        -- sets len of short spi sequence for poweroff purposes short (SDLen) and maximum (SDMax) length
--   QuietLen:
        -- requred TimeOut before start 
--   Start:
        --Start lock on rising CLK, and changes ignores during transmition. if one still high after transmition 
        --   ends, then new frame starts after QuietLen timeout if ContinueStart not active
--   ContinueStart:
        -- if false then spi produce controling sequense of xfer entry and inter-frame pause
        -- else spi start new frame xfer immeidate after completing current frame
--   ShutDown
        -- locks by high level, after Shuting down complete new SutDown sequence can be forced by Start
        -- if one activate during transmition, then it forces current frame to close if it can (beetween SDLen..SDMax bits)
        --    or generate short shutdown frame after completing current frae else
--   Ready:
        -- rising edge of ready can be used for loading DQ data to dest.
--   Shift:
        -- shift clock for internal data register  intended to expand load logic to parallel loading registers, 
        -- to make a multi chanel reciever
--   Sleeping
        -- State of ADC power mode - is it shutdowned.
--------------------------------------------------------------------
-- $Log$
--------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

--  Entity Declaration
ENTITY AdcRecv IS
	-- {{ALTERA_IO_BEGIN}} DO NOT REMOVE THIS LINE!
    GENERIC(
        SPILen      : positive  := 16;
        DataLen     : positive  := 16;
        DataOffset  : natural   := 0;
        SDLen       : natural   := 1;
        SDMax       : natural   := 10;
        QuietLen    : natural   := 1
    );
	PORT
	(
        CLK     : IN STD_LOGIC;
        Start   : IN STD_LOGIC;
        ContinueStart : in STD_LOGIC := '0';
        ShutDown: IN STD_LOGIC;
        reset   : IN STD_LOGIC;

        SDI     : IN STD_LOGIC;
        SCK     : OUT STD_LOGIC;
        nSS     : OUT STD_LOGIC;

        DQ      : OUT std_logic_vector(DataLen-1 downto 0);--STD_LOGIC_2D(Chanels-1 downto 0, DataLen-1 downto 0);
        Ready   : OUT STD_LOGIC;
        Shift   : OUT STD_LOGIC;
        Sleeping : OUT STD_LOGIC
	);
	-- {{ALTERA_IO_END}} DO NOT REMOVE THIS LINE!
	
END AdcRecv;


--  Architecture Body

ARCHITECTURE BEH OF AdcRecv IS
    signal SS           : std_logic;
    signal Data         : std_logic_vector(DataLen-1 downto 0);
    signal iSCK			: std_logic;
    signal iReady		: std_logic;

    subtype BitIndex is natural range 0 to SPILen-1;
    signal BitNo        : BitIndex;

    subtype QuietIndex is natural range 0 to QuietLen;
    signal  QuietCnt    : QuietIndex;
    signal  QuietOk     : std_logic;

    signal isLastBit    : std_logic;
    signal isLastDataBit: std_logic;
    signal isFirstBit	: std_logic;
    signal Transfer     : std_logic := '0';
    signal PrepTransfer : std_logic := '0';
    signal ReceiveWindow : std_logic := '0';

    type States is ( stSerLoading, stQuietCheck); --stReady,
    signal FSMState : States;
    signal NextState : States;

    signal SDEnough     : std_logic;
    signal SDDone       : std_logic;
    signal NeedSD       : std_logic;
    signal Enable       : std_logic;
   
begin
    BitCounter : process(CLK, reset, Enable, Transfer, isLastBit, FSMState) is begin
        if (reset = '1') or (FSMState = stQuietCheck) then -- (Enable = '0') then 
            BitNo <= 0;
        else
            if falling_edge(CLK) then
				if isLastBit = '1' then
					BitNo <= 0;
				else
					if Transfer = '1' then
                    	BitNo <= BitNo+1;
					end if;
                end if;
            end if;
        end if;
    end process;

	isFirstBit <= '1' when (BitNo = 0) else '0';
    isLastBit <= '1' when (BitNo = SPILen-1) else '0';
    isLastDataBit <= '1'when (BitNo = DataOffset + DataLen-1) else '0';

    ReceiveWindow <= '1' when (BitNo >= DataOffset) and (BitNo <= DataOffset + DataLen-1)
                else '0';

    SDEnough <= '1' when (BitNo >= SDLen) and (BitNo < SDMax) else '0';

    SDmonitor : process(SS, enable, iSCK, NeedSD, SDEnough, Reset) is begin
       if (reset = '1') or (iSCK = '0') then
            SDDone      <= '0';
       elsif falling_edge(enable) then
            SDDone      <= SDEnough;
        end if;
    end process;

    Sleeping <= SDDone;

    Qsafer: if QuietLen > 1 generate
		QuietOk <= '1' when (QuietCnt >= QuietLen) else '0';

        QuietCounter: process(FSMState, reset, CLK, QuietOk) is begin
			if (reset = '1') 
				or (FSMState = stSerLoading) 
			then
				QuietCnt <= 0;
			else
				if rising_edge(CLK) then 
					if QuietOk = '0' then
						QuietCnt <= QuietCnt+1;
					end if;
				end if;
			end if;
		end process;
	end generate;

    EmptyQsafer: if QuietLen <= 1 generate
		QuietOk <= '1';
	end generate;

	EnableReg: process(Start, NeedSD, iReady, NextState, FSMState, CLK, Reset) is begin
		if (reset = '1') then
			Enable <= '0';
		elsif rising_edge(CLK) then
			if (iReady and (Start or NeedSD)) = '1' then
				Enable <= '1';
			else
				if (FSMState = stSerLoading) and (NextState /= stSerLoading) then
					Enable <= '0';
				end if;
			end if;
		end if;
	end process;

	SDRequest: process(ShutDown, SDDone, Reset) is begin
		if (Reset = '1') or (SDDone = '1') then
			NeedSD <= '0';
		elsif (ShutDown = '1') and (SDDone = '0') then
			NeedSD <= '1';
		end if;
	end process;
	
--	NeedSD <= ShutDown and not SDDone;
--			NeedSD <= '1' when ShutDown and not SDDone else
--						'0' when ;

	
	FSMStepper : process(NextState, CLK, Reset) is begin
		if reset = '1' then
			FSMState <= stQuietCheck;
		elsif falling_edge(CLK) then
			FSMState <= NextState;
		end if;
	end process;

    FSM : process(FSMState, CLK, QuietOk, isLastBit, ContinueStart
                 , ShutDown, SDEnough, Start, NeedSD, Reset, Enable) 
    is begin
            case FSMState is
                when stSerLoading =>
                        if (ShutDown = '1') and (SDEnough = '1') then
                            NextState <= stQuietCheck;
                        elsif (isLastBit = '1') then
                            if ContinueStart = '0' then
                                NextState <= stQuietCheck;
                            else
                                NextState <= stSerLoading;--stReady;
                            end if;
                        else
                            NextState <= stSerLoading;
                        end if;
                when stQuietCheck =>
                    if (QuietOk = '1') then
						if ((Enable = '1') or (NeedSD = '1')) then
							NextState <= stSerLoading;
						else
							NextState <= stQuietCheck;--stReady;
						end if;
                    else
                        NextState <= stQuietCheck;
                    end if;
                when others =>
                    NextState <= stQuietCheck;
            end case;
    end process;

	Transfer <= '1' when (FSMState = stSerLoading) else '0';
	-- SS must contain gap with '1' about 1/2cycle on SCK at start and end of frames
    SS <= Transfer or Enable;
    iSCK   <= CLK or not Enable; --when (FSMState = stSerLoading) else '1';

    nSS <= not SS;
    SCK	<= iSCK;

    DataCell : process (Data, CLK, reset, ReceiveWindow, SS) is begin
            if reset = '1' then
                Data <= (others => '0');
            elsif rising_edge(CLK) then
                if (ReceiveWindow = '1') and (SS = '1') then
                    Data(Data'high downto 1)  <= Data(Data'high-1 downto 0);
                    Data(0)                   <= SDI;
                end if;
            end if;
    end process;
    
    DQ <= Data;
    Shift <= CLK and ReceiveWindow;

	readyMoitor: process(CLK, FSMState, isFirstbit, isLastDataBit, Reset) is begin
		if (reset = '1') or (FSMState = stQuietCheck) then
			iready <= '1';
		elsif (FSMState = stSerLoading) and (isFirstbit = '1') and (CLK = '1') then
			iready <= '0';
		elsif falling_edge(CLK) then
			if isLastDataBit = '1' then
				iready <= '1';
			end if;
		end if;
    end process;

	Ready <= iReady;
end architecture BEH;
