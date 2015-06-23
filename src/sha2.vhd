library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
library work;
use work.shaPkg.all;

entity sha2 is
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    chunk       : in  std_logic_vector(0 to CW-1);
    len         : in  std_logic_vector(0 to CLENBIT-1);
    load        : in  std_logic;
    --hash        : out std_logic_vector(0 to OS-1);
    hash        : out std_logic_vector(0 to WW-1);
    valid       : out std_logic
    );

end sha2;

architecture hash of sha2 is

  component stepCount
    port (
    cnt            : out integer range 0 to STMAX-1;
    clk            : in  std_logic;
    rst            : in  std_logic
    );
  end component;

  component outCount
   port (
   cnt            : out integer range 0 to WOUT-1;
   clk            : in  std_logic;
   en             : in  std_logic
   );
  end component;

  component romk
    port (
    addr           : in  integer range 0 to STMAX-1;
    k              : out std_logic_vector (0 to WW-1)
    );
  end component;

  signal k        : std_logic_vector(0 to WW-1);
  
  signal new_w    : unsigned(0 to WW-1);  -- nuova word del blocco Wt per t <= 15
  signal cal_w    : unsigned(0 to WW-1);  -- nuova word calcolata Wt per t > 15
  signal w        : unsigned(0 to WW-1);  -- word da utilizzare Wt
  signal wnd      : unsigned(0 to BS-1);  -- registro a scorrimento da Wt-16 a Wt-1
  signal buf      : unsigned(0 to BS-1);  -- buffer blocco precedente
																		   
  signal h_vld    : std_logic;	-- hash valida
  signal blk_vld  : std_logic;	-- blocco elaborato
																					
  signal loaded   : std_logic;	-- ho caricato
  signal loading  : std_logic;	-- sto caricando
  signal load_pad : std_logic;	-- sto caricando
  signal load_rst : std_logic;  -- comincia un nuovo messaggio
  
  signal step_rst : std_logic;	                    -- comincio a elaborare un nuovo blocco
  signal step     : integer range 0 to STMAX-1;     -- contatore step (sha-224/256 = 64)
  signal w_out    : integer range 0 to WOUT-1;      -- contatore out word's  (sha-224 = 7, 256 = 8)
  
  signal blk_num  : unsigned(0 to MSGBIT-LENBIT-1); -- numero di blocchi da elaborare
  signal blk_ok   : unsigned(0 to MSGBIT-LENBIT-1); -- numero di blocchi elaborati
  signal msg_len  : unsigned(0 to MSGBIT-1);        -- lunghezza messaggio

  -- Registri dell'algoritmo SHA-2

  signal a        : unsigned(0 to WW-1);
  signal b        : unsigned(0 to WW-1);
  signal c        : unsigned(0 to WW-1);
  signal d        : unsigned(0 to WW-1);
  signal e        : unsigned(0 to WW-1);
  signal f        : unsigned(0 to WW-1);
  signal g        : unsigned(0 to WW-1);
  signal h        : unsigned(0 to WW-1);

  signal a_2      : unsigned(0 to WW-1);
  signal b_2      : unsigned(0 to WW-1);
  signal c_2      : unsigned(0 to WW-1);
  signal d_2      : unsigned(0 to WW-1);
  signal e_2      : unsigned(0 to WW-1);
  signal f_2      : unsigned(0 to WW-1);
  signal g_2      : unsigned(0 to WW-1);
  signal h_2      : unsigned(0 to WW-1);
									   	  						  
  signal s0       : unsigned(0 to WW-1); -- sigma0
  signal s1       : unsigned(0 to WW-1); -- sigma1
  signal maj      : unsigned(0 to WW-1);
  signal ch       : unsigned(0 to WW-1);

  signal th0      : unsigned(0 to WW-1); -- theta0
  signal th1      : unsigned(0 to WW-1); -- theta1
  
  --signal t1       : unsigned(0 to WW-1); -- T1
  --signal t2       : unsigned(0 to WW-1); -- T2

  signal h0       : unsigned(0 to WW-1);
  signal h1       : unsigned(0 to WW-1);
  signal h2       : unsigned(0 to WW-1);
  signal h3       : unsigned(0 to WW-1);
  signal h4       : unsigned(0 to WW-1);
  signal h5       : unsigned(0 to WW-1);
  signal h6       : unsigned(0 to WW-1);
  signal h7       : unsigned(0 to WW-1);

  -- FSM
  signal first    : std_logic;
  signal first2   : std_logic;
  type state_type is (s_idle, s_load, s_add_block, s_padding, s_compute);
  signal state    : state_type;

begin  -- hash
		  
  -----------------------------------------------------------------------------  
  -- CONNESSIONI PERMANENTI PER CALCOLO DI OGNI STEP
  -----------------------------------------------------------------------------
  
  rom0             : romk
  port map (
    addr           => step,
    k              => k
  );
  
  step_count       : stepCount
  port map (
    cnt            => step,
    clk            => clk,
    rst            => step_rst
  ); 
  
  out_count       : outCount
  port map (
    cnt            => w_out,
    clk            => clk,
    en             => h_vld
  );  
  			
  -- Connessione digest -> hash, per sha-256/512 OS == ISS per 224/384 OS < ISS
  --hash  <= std_logic_vector(h0) & std_logic_vector(h1) & std_logic_vector(h2) & std_logic_vector(h3) & std_logic_vector(h4) & std_logic_vector(h5) & std_logic_vector(h6) & std_logic_vector(h7); -- (0 to OS-1);	  
  with w_out select hash <= std_logic_vector(h0) when 0,
                            std_logic_vector(h1) when 1,
                            std_logic_vector(h2) when 2,
                            std_logic_vector(h3) when 3,
                            std_logic_vector(h4) when 4,
                            std_logic_vector(h5) when 5,
                            std_logic_vector(h6) when 6,
                            std_logic_vector(h7) when others;
  valid <= h_vld;

  --s0  <= (a ror 2) xor (a ror 13) xor (a ror 22);
  --maj <= (a and b) xor (a and c) xor (b and c);
  --s1  <= (e ror 6) xor (e ror 11) xor (e ror 25);
  --ch  <= (e and f) xor ((not e)and g);

  s0  <= ((a + a_2)  ror 2) xor ((a + a_2) ror 13) xor ((a + a_2) ror 22);
  maj <= ((a + a_2) and (b + b_2)) xor ((a + a_2) and (c + c_2)) xor ((b + b_2) and (c + c_2));
  s1  <= ((e + e_2) ror 6) xor ((e + e_2) ror 11) xor ((e + e_2) ror 25);
  ch  <= ((e + e_2) and (f + f_2)) xor ((not (e + e_2))and (g + g_2));

  -- tetha0(Wt-15) == tetha0(W1) sulla finestra mobile
  th0 <= (wnd(WW to 2*WW-1) ror 7) xor (wnd(WW to 2*WW-1) ror 18) xor (wnd(WW to 2*WW-1) srl 3);
  -- tetha1(Wt-2) == tetha0(W14) sulla finestra mobile															
  th1 <= (wnd(14*WW to 15*WW-1) ror 17) xor (wnd(14*WW to 15*WW-1) ror 19) xor (wnd(14*WW to 15*WW-1) srl 10);				 

  -- Wt = tetha1(Wt-15) + Wt-7 + tetha0(Wt-2) + Wt-16 === Wt = tetha1(W1) + W9 + tetha0(Wt14) + W0 sulla finestra mobile
  cal_w <= th1 + wnd(9*WW to 10*WW-1) + th0 + wnd(0 to WW-1);
  
  -- NON SERVONO: Riduzione datapath
  --t1 <= h + s1 + ch + k[i] + w[i]                                                                                
  --t1 <= h + s1 + ch + unsigned(k) + w;
  --t2 <= s0 + maj
  --t2 <= s0 + maj;

  -- VARIABILI CONTROLLER
  
  with state select load_pad <= '1'  when s_add_block,
                                '1'  when s_padding,
								'1'  when s_load,
								load when others;
										
  load_rst  <= (loaded xor load_pad) and load_pad;   -- ORA STO CARICANDO MA NEL CICLO PASSATO NO == PARTENZA
  step_rst  <=  load_rst or rst;                     -- RESET CONTATORE STEP SE E' IN RESET O COMINCIA UN NUOVO CARICAMENTO
  
  -----------------------------------------------------------------------------  
  -- SEGNALI PRIMO BLOCCO: Conversione bloccata per il riempimento buffer
  -----------------------------------------------------------------------------

  first_blk: process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        first <= '0';
        first2 <= '0';
      else
		first2  <= first;
		if load_rst = '1' then
          first <= '1';
        elsif step = STMAX-1 and first = '1' then
          first <= '0';
		end if;
      end if;
    end if;
  end process;
  
  -----------------------------------------------------------------------------  
  -- CONTROLLER NUMERO BLOCCHI
  -----------------------------------------------------------------------------    
  
  blk_counter: process (clk)
  begin
    if (rising_edge(clk)) then
      if ((load_rst or rst) = '1') then	 
		  
	    blk_num(MSGBIT-LENBIT-1)      <= '1';
        blk_num(0 to MSGBIT-LENBIT-2) <= (others => '0');
        blk_ok                        <= (others => '0');
	    h_vld                         <= '0';

      elsif blk_ok < blk_num then 
		  
		-- caricato un nuovo blocco del messaggio
		if (load_pad = '1' and blk_vld = '1') then
			blk_num <= blk_num + 1;
		end if;	
		
		-- elaborato un blocco del messaggio
		if (first = '0' and step = STMAX-1) then
			blk_ok  <= blk_ok + 1;
		end if;
		
	  elsif state = s_compute and blk_ok = blk_num then
		  
		if h_vld = '0' then
		  h_vld <= '1';														   
		end if;
	  
	  -- dopo aver mandato in out tutte le word della hash, metto h_vld = '0'
      elsif w_out = WOUT-1 then
	    h_vld   <= '0';
		--blk_num <= (others => '0'); -- inibisce ulteriore modifica di h_vld
	  end if; 
	  
    end if;
  end process;

  -----------------------------------------------------------------------------  
  -- SETTA blk_vld SE NON E' IN RESET E HA CARICATO UN BLOCCO PER INTERO
  -----------------------------------------------------------------------------  
  
  blk_validity: process (clk)
  begin
    if (rising_edge(clk)) then
      if ((load_rst or rst) = '1') then
        blk_vld <= '0';
      elsif (step = STMAX-1) then
        blk_vld <= '1';
      else
        blk_vld <= '0';
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------------------------------  
  -- FASE 0: PREPROCESSING - RIEMPIMENTO BUFFER + CONTROLLER STATO + INSERIMENTO PADDING E LUNGHEZZA
  --------------------------------------------------------------------------------------------------
  
  p0_fill_buffer_and_padding: process (clk)
  variable len_i : integer range 0 to MSGBIT-1;
  variable clen : integer range 0 to CW;
  variable c	: unsigned(0 to CW-1);
  begin
    if rising_edge(clk) then
      if rst = '1' then	                     -- inizializza al reset
        buf     <= (others => '0');
        msg_len <= (others => '0');
        state   <= s_idle;
      else
		if load = '1' then
			
		  state <= s_load;
		  clen := to_integer(unsigned(len));
          if clen = CW then
            c          := unsigned(chunk);   -- Carico messaggio
            msg_len    <= msg_len + CW;      -- chunk pieno
          else                               -- chunk partiale carico messaggio con padding di 1 e vado in stato padding direttamente
            c := (others => '0');
			c(0 to clen-1) := unsigned(chunk(0 to clen-1));
			c(clen) := '1';
            msg_len    <= msg_len + clen;        -- chunk partiale (per forza ultimo)
            if (step+2)*CW + 1 >= BS-MSGBIT then -- SE >= 448 devo aggiungere un intero blocco di padding
			  state   <= s_add_block;
			else
	          state   <= s_padding;
			end if;
          end if;
		  
        elsif state = s_load then            -- se msg_len multipla di CW aggiungo un chunk di padding
			                                 -- con bit 1 e zeri e poi vado in stato padding
          c(0)         := '1';
          c(1 to CW-1) := (others => '0');
          if (step+2)*CW + 1 >= BS-MSGBIT then   -- SE >= 448 devo aggiungere un intero blocco di padding
		  	state <= s_add_block;
		  else
            state <= s_padding;
		  end if;
		
		elsif state = s_add_block then       -- finisco il blocco con il padding aggiungendone un altro
		  
		  c := (others => '0');
		  if step = STMAX-1 then
		    state <= s_padding;
		  end if;
		  
		elsif state = s_padding then         -- faccio padding di zeri fino agli ultimi 64 bit x la lunghezza
		  
	      if step = STMAX-1 then             -- alla fine mette in IDLE
		    state <= s_compute;
			c     := (others => '0');
		  elsif step >= STMAX-4 and step < STMAX-2 then	-- aggiunge chunk per chunk la lunghezza
			len_i := step*CW-(BS-MSGBIT-2*CW);
			c     := msg_len(len_i to len_i+CW-1);
		  else
		    c     := (others => '0');
		  end if;
		  
		else                                 -- re-inizializza a conversione effettuata
			
          buf     <= (others => '0');
		  msg_len <= (others => '0');			
		  c       := (others => '0');
		  
		  if state = s_compute and h_vld = '1' then
			  state <= s_idle;
		  end if;
		  
		end if;
		
		-- shift del buffer
		
		buf(BS-CW to BS-1)   <= c;
		buf(0 to BS-CW-1)    <= buf(CW to BS-1);
		
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------------------------------
  -- CONTROLLER CARICAMENTO WORD
  --------------------------------------------------------------------------------------------------
  
  fill_word: process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
		loaded  <= '0';
        loading <= '0';
        new_w   <= (others => '0');
      else 												 								  
        loaded  <= loading;           -- SE HA CARICATO UNA WORD
		loading <= load_pad;          -- SE STA CARICANDO UNA WORD
		
		-- LA NUOVA WORD IN INPUT (tiene conto del ciclo di clock per il caricamento)
	    -- il buffer si riempie a CW bit per volta, leggo a WW, word corrente si sposta           <--   CREA PROBLEMA DI CONNESSIONI? FORSE MIGLIORABILE
		
		if step = STMAX-2 then
		  new_w   <= buf(0 to WW-1);
		elsif step = STMAX-1 then																				   
		  new_w   <= buf(WW-CW to (WW-CW)+WW-1);
		elsif step > 14 then
		  new_w   <= (others => '0');
        else
		  new_w   <= buf((step+2)*(WW-CW) to (step+2)*(WW-CW)+WW-1);
		end if;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------------------------------
  -- FASE 1: RIEMPIMENTO REGISTRO A SCORRIMENTO: ESPANSIONE
  --------------------------------------------------------------------------------------------------
  
  p1_expansion: process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        w                  <= (others => '0');
        wnd                <= (others => '0');
      elsif step < WBLK-1 or step = STMAX-1 then  -- i da 1 a 16
        w                  <= new_w;
        wnd(BS-WW to BS-1) <= new_w;
        wnd(0 to BS-WW-1)  <= wnd(WW to BS-1);    -- shift della finestra corrente
      else                                        -- i da 17 a 64
        w                  <= cal_w;                                        
        wnd(BS-WW to BS-1) <= cal_w;
        wnd(0 to BS-WW-1)  <= wnd(WW to BS-1);    -- shift della finestra corrente
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------------------------------
  -- FASE 2: LOOP DI COMPRESSIONE
  --------------------------------------------------------------------------------------------------

  p2_compression: process (clk)
  begin
    if (rising_edge(clk)) then
		
	  -- inizializza a inizio messaggio
      if (load_rst or rst) = '1' then
        a  <=  (others => '0');
        b  <=  (others => '0');
        c  <=  (others => '0');
        d  <=  (others => '0');
        e  <=  (others => '0');
        f  <=  (others => '0');
        g  <=  (others => '0');
        h  <=  (others => '0');
        a_2  <=  (others => '0');
        b_2  <=  (others => '0');
        c_2  <=  (others => '0');
        d_2  <=  (others => '0');
        e_2  <=  (others => '0');
        f_2  <=  (others => '0');
        g_2  <=  (others => '0');
        h_2  <=  (others => '0');
      
      -- AI CICLI SUCCESSIVI IMPOSTO I REGISTRI CON LE FUNZIONI CORRETTI
      else
		-- al primo blocco la compressione è disabilitata (riempimento buffer)
        if first = '0' then
		  -- T1 e T2 sono state espanse direttamente in a ed e
  		  -- T1 ==  h + s1(e) + ch(e, f, g) + k(t) + W(t)
  		  -- T2 ==  s0(a) + maj(a, b, c)
		  
		  -- ulteriore riduzione datapath, (a-g)_2 contengono 0 in tutti gli step tranne l'ultimo
		  -- quando contengono il digest corrente e vengono direttamente sommati alle variabili (a-g)
		  -- così da eliminare il ritardo di propagazione di un ciclo che sfaserebbe il sincronismo
		  -- con il caricamento multiblocco
		  
          h  <=  g + g_2;
          g  <=  f + f_2;
          f  <=  e + e_2;
          e  <=  d + d_2 + h + h_2 + s1 + ch + unsigned(k) + w;   -- e  <=  d + T1;
          d  <=  c + c_2;
          c  <=  b + b_2;
          b  <=  a + a_2;
          a  <=  h + h_2 + s1 + ch + unsigned(k) + w + s0 + maj;  -- a  <= T1 + T2;
        end if;
		
		-- imposta all'ultimo step (a-g)_2 con il digest
        if step = STMAX-1 then
          a_2  <=  h0;
          b_2  <=  h1;
          c_2  <=  h2;
          d_2  <=  h3;
          e_2  <=  h4;
          f_2  <=  h5;
          g_2  <=  h6;
          h_2  <=  h7;
        else
          a_2  <=  (others => '0');
          b_2  <=  (others => '0');
          c_2  <=  (others => '0');
          d_2  <=  (others => '0');
          e_2  <=  (others => '0');
          f_2  <=  (others => '0');
          g_2  <=  (others => '0');
          h_2  <=  (others => '0');
        end if;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------------------------------
  -- FASE 3: ELABORAZIONE (aggiornamento) DIGEST - HASH
  --------------------------------------------------------------------------------------------------
  
  p3_digest_computation: process (clk)
  begin
    if (rising_edge(clk)) then
		
      -- reset a inizio messaggio
      if ((load_rst or rst) = '1') then
        h0   <= HASH0;
        h1   <= HASH1;
        h2   <= HASH2;
        h3   <= HASH3;
        h4   <= HASH4;
        h5   <= HASH5;
        h6   <= HASH6;
        h7   <= HASH7;											 
	  
	  -- nuova H cambia a ogni blocco elaborato e rimane fissa quando l'hash è valido
      elsif (blk_vld = '1' and first2 = '0') then
        h0   <= a + h0;
        h1   <= b + h1;
        h2   <= c + h2;
        h3   <= d + h3;
        h4   <= e + h4;
        h5   <= f + h5;
        h6   <= g + h6;
        h7   <= h + h7;
      end if;
	  
    end if;
  end process;
  
 end hash;