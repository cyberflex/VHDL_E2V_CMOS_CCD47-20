-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>





LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_main_SM IS
END tb_main_SM;
 
ARCHITECTURE behavior OF tb_main_SM IS 

-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT main_SM
	PORT(
		clk : in  std_logic;
		rst : in  std_logic;
		start : in std_logic;
		delay_S1 : in integer;		-- here and below - settings for S1-S3 signals
		delay_S2 : in integer;
		delay_S3 : in integer;
		length_S1 : in integer;
		length_S2 : in integer;
		length_S3 : in integer;
		invert_S1 : in std_logic;
		invert_S2 : in std_logic;
		invert_S3 : in std_logic;
		delay_R1 : in integer;		-- here and below - settings for R1-R3 and R signals
		delay_R2 : in integer;
		delay_R3 : in integer;
		delay_R : in integer;
		length_R1 : in integer;
		length_R2 : in integer;
		length_R3 : in integer;
		length_R : in integer;
		invert_R1 : in std_logic;
		invert_R2 : in std_logic;
		invert_R3 : in std_logic;
		invert_R : in std_logic;
                -- -- integrator control signals
                delay_ipc : in integer;
                delay_FRST : in integer;
                delay_FINT_plus : in integer;
                delay_FINT_minus : in integer;
                length_ipc : in integer;
                length_FRST : in integer;
                length_FINT_plus : in integer;
                length_FINT_minus : in integer;
                invert_ipc : in std_logic; 
                invert_FRST : in std_logic;
                invert_FINT_plus : in std_logic;
                invert_FINT_minus : in std_logic;
                -- ---------------                
		rows_num : in integer;		-- number of rows in our matrix
		columns_num : in integer;	-- number of columns in our matrix
		dump_length : in integer;	-- readout register clean time
		expose_time : in integer;	-- exposition time
                state_during_shift_R1 : in std_logic;
                state_during_shift_R2 : in std_logic;
                state_during_shift_R3 : in std_logic;
                state_default_S1 : in std_logic;
                state_default_S2 : in std_logic;
                state_default_S3 : in std_logic;
                state_default_I1 : in std_logic;
                state_default_I2 : in std_logic;
                state_default_I3 : in std_logic;

                start_of_frame : out std_logic;  -- single pulse, active during
                                               -- one cloack cycle after READOUT begins
                
                end_of_frame : out std_logic;  -- single pulse, active during
                                               -- one cloack cycle after READOUT finished
                
                
		adc_data_in : in  STD_LOGIC_VECTOR (15 downto 0);
		adc_busy0_async : in  STD_LOGIC; -- asynchrous to clk clock domain (BUSY from ADC0)
		adc_busy1_async : in  STD_LOGIC; -- asynchrous to clk clock domain (BUSY from ADC1)

		S1 : out std_logic;		-- here and below - output signals for matrix
		S2 : out std_logic;
		S3 : out std_logic;
		I1 : out std_logic;
		I2 : out std_logic;
		I3 : out std_logic;
		R1 : out std_logic;
		R2 : out std_logic;
		R3 : out std_logic;
		R : out std_logic;
		data : out std_logic_vector (31 downto 0);
		data_valid : out std_logic;
		DG : out std_logic;	-- dump gate

		nCNVST0 : out  STD_LOGIC;
		nCNVST1 : out  STD_LOGIC;
		adc_rst_out : out  STD_LOGIC;
		nCS0 : out  STD_LOGIC;
		nCS1 : out  STD_LOGIC;
		nRD0 : out  STD_LOGIC;
		nRD1 : out  STD_LOGIC;
		adc_latch0 : out STD_LOGIC; -- debug output, pulsed when ADC1 output is latched
		adc_latch1 : out STD_LOGIC  -- debug output, pulsed when ADC2 output is latched
	);
	END COMPONENT;
	COMPONENT adc7671 
	PORT(
		clock : in STD_LOGIC;
		nCS : in  STD_LOGIC;
		nRD : in  STD_LOGIC;
		nCNVST : in  STD_LOGIC;
		BUSY : out  STD_LOGIC;
		DATA : out  STD_LOGIC_VECTOR (15 downto 0)
	);
	END COMPONENT;

	COMPONENT adc_dac_mux
	PORT(
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		adc_dac_select: in STD_LOGIC; -- 0  select is working with ADC, 1 is working with DAC
		adc_is_active: out STD_LOGIC; -- ADC-s chip selects are passed through, DAC-s chip selects are blocked
		dac_is_active: out STD_LOGIC; -- DAC-s chip selects are passed through, ADC-s chip selects are blocked
		comp_busy: out STD_LOGIC; -- is 1 when miltiplexer is not yet ready or in the middle of switching
		err: out STD_LOGIC; -- set to 1 in case of any invalid combinations of input signals, just for routing to some bit of SW status register
		data_out : inout std_logic_vector(15 downto 0); -- ADC/DAC data bus, route out from crystal
		nADC_CS0_OUT : out  STD_LOGIC; 
		nADC_CS1_OUT : out  STD_LOGIC;
		nADC_RD0_OUT : out  STD_LOGIC;
		nADC_RD1_OUT : out  STD_LOGIC;
		nDAC_WR_OUT : out  STD_LOGIC;
		nBIAS_DAC_CS_OUT : out  STD_LOGIC;
		nCLK_DAC1_CS_OUT : out  STD_LOGIC;
		nCLK_DAC2_CS_OUT : out  STD_LOGIC;
		nDAC_RESET_OUT: out STD_LOGIC;
		data_from_adc : out std_logic_vector(15 downto 0); -- from external ADC chip to our internal logic
		data_to_dac: in std_logic_vector(15 downto 0); -- from internal logic to external DAC chip
		nADC_CS0 : in  STD_LOGIC; 
		nADC_CS1 : in  STD_LOGIC;
		nADC_RD0 : in  STD_LOGIC;
		nADC_RD1 : in  STD_LOGIC;
		nDAC_WR : in  STD_LOGIC;
		nBIAS_DAC_CS : in  STD_LOGIC;
		nCLK_DAC1_CS : in  STD_LOGIC;
		nCLK_DAC2_CS : in  STD_LOGIC;
		nDAC_RESET: in STD_LOGIC
	);
	END COMPONENT;

   --Inputs
	signal clk : std_logic := '0';
	signal adc_clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal start : std_logic := '0';
	signal delay_S1 : integer := 20;
	signal delay_S2 : integer := 10;
	signal delay_S3 : integer := 30;
	signal length_S1 : integer := 30;
	signal length_S2 : integer := 30;
	signal length_S3 : integer := 30;
	signal invert_S1 : std_logic := '1';
	signal invert_S2 : std_logic := '0';
	signal invert_S3 : std_logic := '0';
	signal delay_R1 : integer := 2;
	signal delay_R2 : integer := 1;
	signal delay_R3 : integer := 3;
	signal delay_R : integer := 8;
	signal length_R1 : integer := 3;
	signal length_R2 : integer := 3;
	signal length_R3 : integer := 3;
	signal length_R : integer := 1;
	signal invert_R1 : std_logic := '1';
	signal invert_R2 : std_logic := '0';
	signal invert_R3 : std_logic := '0';
	signal invert_R : std_logic := '0';
        -- -- integrator control signals
        signal delay_ipc :  integer := 1;
        signal delay_FRST :  integer := 1;
        signal delay_FINT_plus :  integer := 1;
        signal delay_FINT_minus : integer := 1;
        signal length_ipc :  integer := 2;
        signal length_FRST : integer := 2;
        signal length_FINT_plus : integer := 2;
        signal length_FINT_minus : integer  := 2;
        signal invert_ipc :  std_logic := '0'; 
        signal invert_FRST :  std_logic := '0';
        signal invert_FINT_plus : std_logic := '0';
        signal invert_FINT_minus :  std_logic := '0';
        -- ---------------         
	signal rows_num : integer := 3;
	signal columns_num : integer := 3;
	signal dump_length : integer := 2;
	signal expose_time : integer := 2000;
        signal state_during_shift_R1 : std_logic := '1';
        signal state_during_shift_R2 : std_logic := '0';
        signal state_during_shift_R3 : std_logic := '0';
        signal state_default_S1 : std_logic := '0';
        signal state_default_S2 : std_logic := '0';
        signal state_default_S3 : std_logic := '0';
        signal state_default_I1 : std_logic := '0';
        signal state_default_I2 : std_logic := '0';
        signal state_default_I3 : std_logic := '0';
        
        signal start_of_frame :  std_logic;
                
        signal end_of_frame :  std_logic;

	--Outputs
	signal S1 : std_logic;
	signal S2 : std_logic;
	signal S3 : std_logic;
	signal I1 : std_logic;
	signal I2 : std_logic;
	signal I3 : std_logic;
	signal R1 : std_logic;
	signal R2 : std_logic;
	signal R3 : std_logic;
	signal R : std_logic;
	signal data : std_logic_vector (31 downto 0);
	signal data_valid : std_logic;
	signal DG : std_logic;

	-- Clock period definitions
	constant clk_period : time := 10 ps;

	-- ADC stuff
	signal adc_data_in : std_logic_vector (15 downto 0);
	signal adc_data_out : std_logic_vector (15 downto 0);
	signal adc_busy0_async : std_logic;
	signal adc_busy1_async : std_logic;

	signal nCNVST0 : std_logic;
	signal nCNVST1 : std_logic;
	signal adc_rst_out : std_logic;
	signal nCS0_out : std_logic;
	signal nCS1_out : std_logic;
	signal nRD0_out : std_logic;
	signal nRD1_out : std_logic;
	signal nCS0_in : std_logic;
	signal nCS1_in : std_logic;
	signal nRD0_in : std_logic;
	signal nRD1_in : std_logic;
	signal adc_latch0 : std_logic;
	signal adc_latch1 : std_logic;

	-- Other
	signal reset_done : std_logic := '0';
        signal fcnt : integer := 0;
BEGIN





  
	-- Instantiate the Unit Under Test (UUT)
	uut: main_SM PORT MAP (
		clk => clk,
		rst => rst,
		start => start,
		delay_S1 => delay_S1,
		delay_S2 => delay_S2,
		delay_S3 => delay_S3,
		length_S1 => length_S1,
		length_S2 => length_S2,
		length_S3 => length_S3,
		invert_S1 => invert_S1,
		invert_S2 => invert_S2,
		invert_S3 => invert_S3,
		delay_R1 => delay_R1,
		delay_R2 => delay_R2,
		delay_R3 => delay_R3,
		delay_R => delay_R,
		length_R1 => length_R1,
		length_R2 => length_R2,
		length_R3 => length_R3,
		length_R => length_R,
		invert_R1 => invert_R1,
		invert_R2 => invert_R2,
		invert_R3 => invert_R3,
		invert_R => invert_R,
                -- -- integrator control signals
                delay_ipc => delay_ipc,
                delay_FRST => delay_FRST,
                delay_FINT_plus => delay_FINT_plus, 
                delay_FINT_minus => delay_FINT_minus,
                length_ipc => length_ipc,
                length_FRST => length_FRST,
                length_FINT_plus => length_FINT_plus,
                length_FINT_minus => length_FINT_minus,
                invert_ipc => invert_ipc,
                invert_FRST => invert_FRST,
                invert_FINT_plus => invert_FINT_plus,
                invert_FINT_minus => invert_FINT_minus,
                -- ---------------
		rows_num => rows_num,
		columns_num => columns_num,
		dump_length => dump_length,
		expose_time => expose_time,
                state_during_shift_R1 => state_during_shift_R1,
                state_during_shift_R2 => state_during_shift_R2,
                state_during_shift_R3 => state_during_shift_R3,
                state_default_S1 => state_default_S1,
                state_default_S2 => state_default_S2,
                state_default_S3 => state_default_S3,
                state_default_I1 => state_default_I1,
                state_default_I2 => state_default_I2,
                state_default_I3 => state_default_I3,

                start_of_frame => start_of_frame,
                end_of_frame => end_of_frame,
                
		adc_data_in => adc_data_out,
		adc_busy0_async => adc_busy0_async,
		adc_busy1_async => adc_busy1_async,

		S1 => S1,
		S2 => S2,
		S3 => S3,
		I1 => I1,
		I2 => I2,
		I3 => I3,
		R1 => R1,
		R2 => R2,
		R3 => R3,
		R => R,
		data => data,
		data_valid => data_valid,
		DG => DG,

		nCNVST0 => nCNVST0,
		nCNVST1 => nCNVST1,
		adc_rst_out => adc_rst_out,
		nCS0 => nCS0_in,
		nCS1 => nCS1_in,
		nRD0 => nRD0_in,
		nRD1 => nRD1_in,
		adc_latch0 => adc_latch0,
		adc_latch1 => adc_latch1
	);
	adc0: adc7671
        PORT MAP(
		clock => adc_clk,
		nCS => nCS0_out,
		nRD => nRD0_out,
		nCNVST => nCNVST0,
		BUSY => adc_busy0_async,
		DATA => adc_data_in
	);
	adc1: adc7671 PORT MAP(
		clock => adc_clk,
		nCS => nCS1_out,
		nRD => nRD1_out,
		nCNVST => nCNVST1,
		BUSY => adc_busy1_async,
		DATA => adc_data_in
	);
	mux: adc_dac_mux PORT MAP(
		clk => clk,
		rst => rst,
		adc_dac_select => '0',
		adc_is_active => open,
		dac_is_active => open,
		comp_busy => open,
		err => open,
		data_out => adc_data_in,
		nADC_CS0_OUT => nCS0_out,
		nADC_CS1_OUT => nCS1_out,
		nADC_RD0_OUT => nRD0_out,
		nADC_RD1_OUT => nRD1_out,
		nDAC_WR_OUT => open,
		nBIAS_DAC_CS_OUT => open,
		nCLK_DAC1_CS_OUT => open,
		nCLK_DAC2_CS_OUT => open,
		nDAC_RESET_OUT => open,
		data_from_adc => adc_data_out, -- from external ADC chip to our internal logic
		data_to_dac => (others => '0'),
		nADC_CS0 => nCS0_in,
		nADC_CS1 => nCS1_in,
		nADC_RD0 => nRD0_in,
		nADC_RD1 => nRD1_in,
		nDAC_WR => '1',
		nBIAS_DAC_CS => '1',
		nCLK_DAC1_CS => '1',
		nCLK_DAC2_CS => '1',
		nDAC_RESET => '1'
	);



	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	adc_clk_process :process
	begin
		adc_clk <= '0';
		wait for clk_period/8;
		adc_clk <= '1';
		wait for clk_period/8;
	end process;
 
	main : process(clk)
	begin
		if rising_edge(clk) then
			if reset_done = '0' then
				rst <= '1';
				reset_done <= '1';
				start <= '1';
			else
				rst <= '0';

                                if end_of_frame = '1' then
                                  fcnt <= fcnt + 1;
                                end if;
                                if end_of_frame = '1' and fcnt > 3 then
                                  start <= '0';
                                end if;
			end if;
                        
		end if;
	end process;

END;
