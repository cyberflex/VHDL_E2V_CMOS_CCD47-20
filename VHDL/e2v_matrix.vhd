-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY e2v_matrix IS
	PORT(
		clk : in std_logic;
		rst : in std_logic;
		start : in std_logic;

		set_id : in integer;
		set_value : in integer;
		set_flag : in std_logic;
                
                start_of_frame : out std_logic;  -- single pulse, active during
                                               -- one cloack cycle after READOUT begins
                end_of_frame : out std_logic;  -- single pulse, active during
                                               -- one cloack cycle after READOUT finished
                exposition_time_min : out std_logic_vector(31 downto 0);  -- minimum of exposition time over the last frame captured, 32-bit signed value
                exposition_time_max : out std_logic_vector(31 downto 0);  -- maximum of exposition time over the last frame captured, 32-bit signed value

                adc_dac_select: in STD_LOGIC; -- 0  select ADC, 1 select DAC
		adc_is_active: out STD_LOGIC; -- ADC-s selected
		dac_is_active: out STD_LOGIC; -- DAC-s selected
		adc_dac_mux_busy: out STD_LOGIC; -- is 1 when miltiplexer is switching bitween ADC and DAC
		adc_dac_mux_err: out STD_LOGIC;
                
                
                data_to_dac: in std_logic_vector(15 downto 0); -- from internal logic (IO register) to external DAC chip


                -- signals to conect to output of IO registers controlling DAC-s
                nDAC_WR : in  STD_LOGIC;
                nBIAS_DAC_CS : in  STD_LOGIC;
                nCLK_DAC1_CS : in  STD_LOGIC;
                nCLK_DAC2_CS : in  STD_LOGIC;
                nDAC_RESET : in  STD_LOGIC;
                -- the same DAC controlling signals, output after multiplexer
                nDAC_WR_OUT : out  STD_LOGIC;
                nBIAS_DAC_CS_OUT : out  STD_LOGIC;
                nCLK_DAC1_CS_OUT : out  STD_LOGIC;
                nCLK_DAC2_CS_OUT : out  STD_LOGIC;
                nDAC_RESET_OUT: out STD_LOGIC;                

		-- signals to ADC/DAC
		--adc_data_in : in  STD_LOGIC_VECTOR (15 downto 0);
		adc_busy0_async : in  STD_LOGIC; -- asynchrous to clk clock domain (BUSY from ADC0)
		adc_busy1_async : in  STD_LOGIC; -- asynchrous to clk clock domain (BUSY from ADC1)

		-- signals for matrix
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

		-- signals from ADC/DAC
		nCNVST0 : out  STD_LOGIC;
		nCNVST1 : out  STD_LOGIC;
		adc_rst_out : out  STD_LOGIC;
		nCS0 : out  STD_LOGIC;
		nCS1 : out  STD_LOGIC;
		nRD0 : out  STD_LOGIC;
		nRD1 : out  STD_LOGIC;
		adc_latch0 : out STD_LOGIC; -- debug output, pulsed when ADC1 output is latched
		adc_latch1 : out STD_LOGIC;  -- debug output, pulsed when ADC2 output is latched

		-- ADC/DAC in/out
		data_out : inout std_logic_vector(15 downto 0); -- ADC/DAC data bus, route out from crystal

                -- -- integrator control signals
                ipc : out std_logic;
                FRST : out std_logic;
                FINT_plus : out std_logic;
                FINT_minus : out std_logic
                
	);
END e2v_matrix;
 
ARCHITECTURE behavior OF e2v_matrix IS

	COMPONENT matrix_control
	PORT(
		clk : in std_logic;
		rst : in std_logic;
		start : in std_logic;

		set_id : in integer;
		set_value : in integer;
		set_flag : in std_logic;

                start_of_frame : out std_logic;  -- single pulse, active during
                                               -- one cloack cycle after READOUT begins
                
                end_of_frame : out std_logic;  -- single pulse, active during
                                               -- one cloack cycle after READOUT finished
                exposition_time_min : out std_logic_vector(31 downto 0);  -- minimum of exposition time over the last frame captured, 32-bit signed value
                exposition_time_max : out std_logic_vector(31 downto 0);  -- maximum of exposition time over the last frame captured, 32-bit signed value                
                
		-- signals to ADC
		adc_data_in : in  STD_LOGIC_VECTOR (15 downto 0);
		adc_busy0_async : in  STD_LOGIC; -- asynchrous to clk clock domain (BUSY from ADC0)
		adc_busy1_async : in  STD_LOGIC; -- asynchrous to clk clock domain (BUSY from ADC1)

		-- signals for matrix
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

		-- signals from ADC
		nCNVST0 : out  STD_LOGIC;
		nCNVST1 : out  STD_LOGIC;
		adc_rst_out : out  STD_LOGIC;
		nCS0 : out  STD_LOGIC;
		nCS1 : out  STD_LOGIC;
		nRD0 : out  STD_LOGIC;
		nRD1 : out  STD_LOGIC;
		adc_latch0 : out STD_LOGIC; -- debug output, pulsed when ADC1 output is latched
		adc_latch1 : out STD_LOGIC;  -- debug output, pulsed when ADC2 output is latched

                -- -- integrator control signals
                ipc : out std_logic;
                FRST : out std_logic;
                FINT_plus : out std_logic;
                FINT_minus : out std_logic
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

	-- ADC stuff
	--signal adc_data_in : std_logic_vector (15 downto 0);
	signal adc_data_out : std_logic_vector (15 downto 0);  -- TODO: rename to data_from_adc
	--signal adc_busy0_async : std_logic;
	--signal adc_busy1_async : std_logic;

	--signal nCNVST0 : std_logic;
	--signal nCNVST1 : std_logic;
	--signal adc_rst_out : std_logic;
	signal nCS0_in : std_logic;
	signal nCS1_in : std_logic;
	signal nRD0_in : std_logic;
	signal nRD1_in : std_logic;
	--signal adc_latch0 : std_logic;
	--signal adc_latch1 : std_logic;
BEGIN

	control: matrix_control PORT MAP (
		clk => clk,
		rst => rst,
		start => start,

		set_id => set_id,
		set_value => set_value,
		set_flag => set_flag,

                start_of_frame => start_of_frame,
                end_of_frame => end_of_frame,
                exposition_time_min =>  exposition_time_min,
                exposition_time_max =>  exposition_time_max,
                
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
		adc_latch1 => adc_latch1,

                -- -- integrator control signals
                ipc => ipc,
                FRST => FRST,
                FINT_plus => FINT_plus,
                FINT_minus => FINT_minus
	);
	mux: adc_dac_mux PORT MAP(
		clk => clk,
		rst => rst,
		adc_dac_select => adc_dac_select,-- 0  select ADC, 1 select DAC
		adc_is_active => adc_is_active,
		dac_is_active => dac_is_active,
		comp_busy => adc_dac_mux_busy,
		err => adc_dac_mux_err,
		data_out => data_out,
		nADC_CS0_OUT => nCS0,
		nADC_CS1_OUT => nCS1,
		nADC_RD0_OUT => nRD0,
		nADC_RD1_OUT => nRD1,

		nDAC_WR_OUT => nDAC_WR_OUT,
		nBIAS_DAC_CS_OUT => nBIAS_DAC_CS_OUT,
		nCLK_DAC1_CS_OUT => nCLK_DAC1_CS_OUT,
		nCLK_DAC2_CS_OUT => nCLK_DAC2_CS_OUT,
		nDAC_RESET_OUT => nDAC_RESET_OUT,
                
		data_from_adc => adc_data_out, -- from external ADC chip to our internal logic
		data_to_dac => data_to_dac,-- from internal logic to external DAC chip
		nADC_CS0 => nCS0_in,
		nADC_CS1 => nCS1_in,
		nADC_RD0 => nRD0_in,
		nADC_RD1 => nRD1_in,

                
		nDAC_WR => nDAC_WR,
		nBIAS_DAC_CS => nBIAS_DAC_CS,
		nCLK_DAC1_CS => nCLK_DAC1_CS,
		nCLK_DAC2_CS => nCLK_DAC2_CS,
		nDAC_RESET => nDAC_RESET
	);
END;
