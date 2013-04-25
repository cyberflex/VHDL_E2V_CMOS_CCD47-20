-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY matrix_control IS
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
END matrix_control;

ARCHITECTURE matrix_control_arch OF matrix_control IS

	COMPONENT matrix_settings
	PORT(
		clk : in std_logic;
		rst : in std_logic;
		id : in integer;
		value : in integer;
		flag : in std_logic;

		soft_reset : out std_logic;
		delay_S1 : out integer;		-- here and below - settings for S1-S3 signals
		delay_S2 : out integer;
		delay_S3 : out integer;
		length_S1 : out integer;
		length_S2 : out integer;
		length_S3 : out integer;
		invert_S1 : out std_logic;
		invert_S2 : out std_logic;
		invert_S3 : out std_logic;
		delay_R1 : out integer;		-- here and below - settings for R1-R3 and R signals
		delay_R2 : out integer;
		delay_R3 : out integer;
		delay_R : out integer;
		length_R1 : out integer;
		length_R2 : out integer;
		length_R3 : out integer;
		length_R : out integer;
		invert_R1 : out std_logic;
		invert_R2 : out std_logic;
		invert_R3 : out std_logic;
		invert_R : out std_logic;
                -- -- integrator control signals
                delay_ipc : out integer;
                delay_FRST : out integer;
                delay_FINT_plus : out integer;
                delay_FINT_minus : out integer;
                length_ipc : out integer;
                length_FRST : out integer;
                length_FINT_plus : out integer;
                length_FINT_minus : out integer;
                invert_ipc : out std_logic; 
                invert_FRST : out std_logic;
                invert_FINT_plus : out std_logic;
                invert_FINT_minus : out std_logic;
                -- ---------------                
		rows_num : out integer;		-- number of rows in our matrix
		columns_num : out integer;	-- number of columns in our matrix
		dump_length : out integer;	-- readout register clean time
		expose_time : out integer;	-- exposition time
                state_during_shift_R1 : out std_logic;
                state_during_shift_R2 : out std_logic;
                state_during_shift_R3 : out std_logic;
                state_default_S1 : out std_logic;
                state_default_S2 : out std_logic;
                state_default_S3 : out std_logic;
                state_default_I1 : out std_logic;
                state_default_I2 : out std_logic;
                state_default_I3 : out std_logic                
	);
	END COMPONENT;

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
                
                exposition_time_min : out std_logic_vector(31 downto 0);  -- minimum of exposition time over the last frame captured, 32-bit signed value
                exposition_time_max : out std_logic_vector(31 downto 0);  -- maximum of exposition time over the last frame captured, 32-bit signed value                
                
                
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
		adc_latch1 : out STD_LOGIC;  -- debug output, pulsed when ADC2 output is latched
                
                -- -- integrator control signals
                ipc : out std_logic;
                FRST : out std_logic;
                FINT_plus : out std_logic;
                FINT_minus : out std_logic                
	);
	END COMPONENT;

	signal soft_reset : std_logic;
	signal internal_rst : std_logic;
        ---- signal DG_internal : std_logic;
	signal delay_S1 : integer;		-- here and below - settings for S1-S3 signals
	signal delay_S2 : integer;
	signal delay_S3 : integer;
	signal length_S1 : integer;
	signal length_S2 : integer;
	signal length_S3 : integer;
	signal invert_S1 : std_logic;
	signal invert_S2 : std_logic;
	signal invert_S3 : std_logic;
	signal delay_R1 : integer;		-- here and below - settings for R1-R3 and R signals
	signal delay_R2 : integer;
	signal delay_R3 : integer;
	signal delay_R : integer;
	signal length_R1 : integer;
	signal length_R2 : integer;
	signal length_R3 : integer;
	signal length_R : integer;
	signal invert_R1 : std_logic;
	signal invert_R2 : std_logic;
	signal invert_R3 : std_logic;
	signal invert_R : std_logic;
        -- -- integrator control signals
        SIGNAL delay_ipc : integer;
        SIGNAL delay_FRST : integer;
        SIGNAL delay_FINT_plus : integer;
        SIGNAL delay_FINT_minus : integer;
        SIGNAL length_ipc : integer;
        SIGNAL length_FRST : integer;
        SIGNAL length_FINT_plus : integer;
        SIGNAL length_FINT_minus : integer;
        SIGNAL invert_ipc : std_logic;
        SIGNAL invert_FRST : std_logic;
        SIGNAL invert_FINT_plus : std_logic;
        SIGNAL invert_FINT_minus : std_logic;
        -- ---------------
	signal rows_num : integer;		-- number of rows in our matrix
	signal columns_num : integer;	-- number of columns in our matrix
	signal dump_length : integer;	-- readout register clean time
	signal expose_time : integer;	-- exposition time
        signal state_during_shift_R1 : std_logic;
        signal state_during_shift_R2 : std_logic;
        signal state_during_shift_R3 : std_logic;
        signal state_default_S1 : std_logic;
        signal state_default_S2 : std_logic;
        signal state_default_S3 : std_logic;
        signal state_default_I1 : std_logic;
        signal state_default_I2 : std_logic;
        signal state_default_I3 : std_logic;        

BEGIN

	-- --DG <= not DG_internal;          -- need to invert it before output to E2V matrix 
  
	settings: matrix_settings PORT MAP(
		clk => clk,
		rst => rst,
		id => set_id,
		value => set_value,
		flag => set_flag,

		soft_reset => soft_reset,
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
                state_default_I3 => state_default_I3
	);


	internal_rst <= (rst or soft_reset);

	main: main_SM PORT MAP(
		clk => clk,
		rst => internal_rst,
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

                exposition_time_min =>  exposition_time_min,
                exposition_time_max =>  exposition_time_max,
                
		adc_data_in => adc_data_in,
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
		DG => DG, ---- DG_internal,

		nCNVST0 => nCNVST0,
		nCNVST1 => nCNVST1,
		adc_rst_out => adc_rst_out,
		nCS0 => nCS0,
		nCS1 => nCS1,
		nRD0 => nRD0,
		nRD1 => nRD1,
		adc_latch0 => adc_latch0,
		adc_latch1 => adc_latch1,

                -- -- integrator control signals
                ipc => ipc,
                FRST => FRST,
                FINT_plus => FINT_plus,
                FINT_minus => FINT_minus                
	);
END;
