-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity adc7671dual_control is
	Port (
		clk : in STD_LOGIC;
		rst : in  STD_LOGIC;
		start : in  STD_LOGIC;
		done : out  STD_LOGIC; -- active high, set when work is finished
		done_rising_edge : out STD_LOGIC; -- "rising edge active" (single clock finished signal)
		busy : out  STD_LOGIC;
		data_in : in  STD_LOGIC_VECTOR (15 downto 0);
		data_out : out  STD_LOGIC_VECTOR (31 downto 0); -- 16 bit of left channel ADC + 16 bits right channel ADC
		data_out_valid : out  STD_LOGIC; -- set 1 when output data is valid ADC out, latched at some moment before
		busy0_async : in  STD_LOGIC; -- asynchrous to clk clock domain (BUSY from ADC0)
		busy1_async : in  STD_LOGIC; -- asynchrous to clk clock domain (BUSY from ADC1)
		nCNVST0 : out  STD_LOGIC;
		nCNVST1 : out  STD_LOGIC;
		rst_out : out  STD_LOGIC;
		nCS0 : out  STD_LOGIC;
		nCS1 : out  STD_LOGIC;
		nRD0 : out  STD_LOGIC;
		nRD1 : out  STD_LOGIC;
		latch0 : out STD_LOGIC; -- debug output, pulsed when ADC1 output is latched
		latch1 : out STD_LOGIC  -- debug output, pulsed when ADC2 output is latched
	);
end adc7671dual_control;

architecture Behavioral of adc7671dual_control is

component single_pulse is
port(
  clk: in std_logic;
  rst: in std_logic;
  input: in std_logic;
  output: out std_logic
);
end component;


type state_type is	(
								IDLE,
								ACQUIRE, -- run ADC-s and wait them to complete
								READOUT  -- read out acquition results
							);

signal state: state_type;


signal cnvst_lazy: std_logic;
signal cnvst: std_logic;

signal ready0: std_logic;
signal ready1: std_logic;

signal ready0_rising_edge: std_logic;
signal ready1_rising_edge: std_logic;

signal busy0: std_logic;
signal busy1: std_logic;

-- signals for busy0/1 synchronizer
signal busy0_0d: std_logic;
signal busy1_0d: std_logic;
signal busy0_1d: std_logic;
signal busy1_1d: std_logic;

signal counter: integer; -- TODO: may be "(un)signed"  of some shorter length

signal done_internal: std_logic;

begin

-------------------------------------------------------
-- synchronizer for busy0/1 signals

busy01Sync: process(clk,rst,busy0,busy1,busy0_0d,busy1_0d)
begin
	if rising_edge(clk) then
		if rst = '1' then
			-- TODO
		else
			busy0 <= busy0_1d;
			busy1 <= busy1_1d;
			busy0_1d <= busy0_0d;
			busy1_1d <= busy1_0d;			
			busy0_0d <= busy0_async;
			busy1_0d <= busy1_async;
		end if;
	end if;
end process;

-------------------------------------------------------
ready0 <= not busy0;
ready1 <= not busy1;

readyRising0: single_pulse port map(
  clk => clk,
  rst => rst,
  input => ready0,
  output => ready0_rising_edge
);

readyRising1: single_pulse port map(
  clk => clk,
  rst => rst,
  input => ready1,
  output => ready1_rising_edge
);
-------------------------------------------------------
doneRisingEdge: single_pulse port map(
  clk => clk,
  rst => rst,
  input => done_internal,
  output => done_rising_edge
);

-------------------------------------------------------

outCvnStart: single_pulse port map(
  clk => clk,
  rst => rst,
  input => cnvst_lazy,
  output => cnvst
);

nCNVST0 <= not cnvst;
nCNVST1 <= not cnvst;

done <= done_internal;

rst_out <= '0'; --TODO

main: process(clk,rst)
	variable cnv0_finished: std_logic;
	variable cnv1_finished: std_logic;
	
	variable state_next: state_type;
begin

	if rising_edge(clk) then
		if rst = '1' then
			busy <= '0';
			data_out <= X"FFFF_FFFF";
			data_out_valid <= '0';
			cnvst_lazy <= '0';
			-- rst_out <= '0'; TODO
			nCS0 <= '1';
			nCS1 <= '1';
			nRD0 <= '1';
			nRD1 <= '1';
			latch0 <= '0';
			latch1 <= '0';
			
			state <= IDLE;
			state_next := IDLE;
			cnvst_lazy <= '0';
			cnv0_finished := '0';
			cnv1_finished := '0';
			
			counter <= 0;
			done_internal <= '0';
		else
		
			if state = IDLE then
				busy <= '0';
				cnvst_lazy <= '0';
				cnv0_finished := '0';
				cnv1_finished := '0';
				counter <= 0;
				nRD0 <= '1';
				nCS0 <= '1';
				nRD1 <= '1';
				nCS1 <= '1';
				latch0 <= '0';
				latch1 <= '0';				
				if start = '1' then
					state_next := ACQUIRE;
					busy <= '1';
				end if;
			elsif state = ACQUIRE then
				cnvst_lazy <= '1';
				
				counter <= 0;

				latch0 <= '0';
				latch1 <= '0';
				
				if  ready0_rising_edge = '1' then
					cnv0_finished := ready0_rising_edge;
				end if;
				if  ready1_rising_edge = '1' then
					cnv1_finished := ready1_rising_edge;
				end if;				
				if cnv0_finished = '1' and cnv1_finished = '1' then
					-- both ADC-s finished conversion, moving to readout of results
					nRD0 <= '0';
					nCS0 <= '0';
					done_internal <= '0';
					state_next := READOUT;
				end if;
			
			elsif state = READOUT then
				done_internal <= '0';

				latch0 <= '0';
				latch1 <= '0';
				
				if counter = 4 then --
					-- turn off ADC0 output
					nRD0 <= '1';
					nCS0 <= '1';					
				end if;
				
				if counter = 4 then  -- 
					-- turn on adc ADC1 output
					nRD1 <= '0';
					nCS1 <= '0';					
				end if;
				
				if counter = 4 then  -- 
					data_out(31 downto 16) <= data_in;
					data_out_valid <= '0';
					latch0 <= '1';
					latch1 <= '0';
				end if;
				
				if counter = 9 then  -- 
					data_out(15 downto 0) <= data_in;			
					nRD0 <= '1';
					nCS0 <= '1';
					nRD1 <= '1';
					nCS1 <= '1';
					latch0 <= '0';
					latch1 <= '1';
					done_internal <= '1';
					data_out_valid <= '1';
					state_next := IDLE;
					busy <= '0';
				end if;
				
				counter <= counter + 1;
			else
				state_next := IDLE;
			end if;
		
			state <= state_next;
		end if;		
	end if;


end process;




end Behavioral;

