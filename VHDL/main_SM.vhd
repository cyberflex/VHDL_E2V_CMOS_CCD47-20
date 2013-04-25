-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Main state-machine for matrix manipulations
entity main_SM is
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
end main_SM;

architecture Behavioral of main_SM is

	COMPONENT shift_matrix
	PORT(
		clk : in std_logic;
		rst : in std_logic;
		start : in std_logic;
		delay1 : in integer;
		delay2 : in integer;
		delay3 : in integer;
		length1 : in integer;
		length2 : in integer;
		length3 : in integer;
		invert1 : in std_logic;
		invert2 : in std_logic;
		invert3 : in std_logic;
                invertR : in std_logic;
		repeat : in integer;
		S1 : out std_logic;
		S2 : out std_logic;
		S3 : out std_logic;
                R  : out std_logic;
		done : out std_logic
	);
	END COMPONENT;
	COMPONENT matrix_readout
	PORT(
		clk : in  std_logic;
		rst : in  std_logic;
		start : in std_logic;
		delay_S1 : in integer;
		delay_S2 : in integer;
		delay_S3 : in integer;
		length_S1 : in integer;
		length_S2 : in integer;
		length_S3 : in integer;
		invert_S1 : in std_logic;
		invert_S2 : in std_logic;
		invert_S3 : in std_logic;
		delay_R1 : in integer;
		delay_R2 : in integer;
		delay_R3 : in integer;
		delay_R : in integer;
		length_R1 : in integer;
		length_R2 : in integer;
		length_R3 : in integer;
		length_R : in integer;
                state_during_shift_R1 : in std_logic;
                state_during_shift_R2 : in std_logic;
                state_during_shift_R3 : in std_logic;
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
		rows : in integer;
		columns : in integer;
		dump_length : in integer;
		adc_busy : in std_logic;
		adc_done : in std_logic;
		adc_data_out : in std_logic_vector (31 downto 0);
		adc_data_out_valid : in std_logic;
		S1 : out std_logic;
		S2 : out std_logic;
		S3 : out std_logic;
		R1 : out std_logic;
		R2 : out std_logic;
		R3 : out std_logic;
		R : out std_logic;
		DG : out std_logic;
		data : out std_logic_vector (31 downto 0);
		data_valid : out std_logic;
		done : out std_logic;
		adc_start : out std_logic;
                -- -- integrator control signals
                ipc : out std_logic;
                FRST : out std_logic;
                FINT_plus : out std_logic;
                FINT_minus : out std_logic
	);
	END COMPONENT;
	COMPONENT adc7671dual_control
	PORT(
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
	END COMPONENT;

	type STATE_TYPE is (	-- TODO: add more if we want :)
		STAND_BY,
		SETTINGS,	-- remembering new settings
		EXPOSE,		-- exposition
		SHIFT,		-- shifting image to storage
		READ		-- reading data from storage
	);

	SIGNAL clean_req : std_logic;	-- '1' when it`s required to clean the charge on a matrix
	SIGNAL exposed : integer;	-- how long has it been exposed
	-- data for shift_matrix module
	SIGNAL delay_S1_int : integer;
	SIGNAL delay_S2_int : integer;
	SIGNAL delay_S3_int : integer;
	SIGNAL length_S1_int : integer;
	SIGNAL length_S2_int : integer;
	SIGNAL length_S3_int : integer;
	SIGNAL invert_S1_int : std_logic;
	SIGNAL invert_S2_int : std_logic;
	SIGNAL invert_S3_int : std_logic;
	SIGNAL delay_R1_int : integer;
	SIGNAL delay_R2_int : integer;
	SIGNAL delay_R3_int : integer;
	SIGNAL delay_R_int : integer;
	SIGNAL length_R1_int : integer;
	SIGNAL length_R2_int : integer;
	SIGNAL length_R3_int : integer;
	SIGNAL length_R_int : integer;
	SIGNAL invert_R1_int : std_logic;
	SIGNAL invert_R2_int : std_logic;
	SIGNAL invert_R3_int : std_logic;
	SIGNAL invert_R_int : std_logic;
        SIGNAL delay_ipc_int : integer;
        SIGNAL delay_FRST_int : integer;
        SIGNAL delay_FINT_plus_int : integer;
        SIGNAL delay_FINT_minus_int : integer;
        SIGNAL length_ipc_int : integer;
        SIGNAL length_FRST_int : integer;
        SIGNAL length_FINT_plus_int : integer;
        SIGNAL length_FINT_minus_int : integer;
        SIGNAL invert_ipc_int : std_logic;
        SIGNAL invert_FRST_int : std_logic;
        SIGNAL invert_FINT_plus_int : std_logic;
        SIGNAL invert_FINT_minus_int : std_logic;            
	SIGNAL rows_num_int : integer;
	SIGNAL columns_num_int : integer;
	SIGNAL expose_time_int : integer;
	SIGNAL S1_shift : std_logic;
	SIGNAL S2_shift : std_logic;
	SIGNAL S3_shift : std_logic;
        SIGNAL R_shift : std_logic;
	SIGNAL S1_read : std_logic;
	SIGNAL S2_read : std_logic;
	SIGNAL S3_read : std_logic;
        SIGNAL R1_read : std_logic;
        SIGNAL R2_read : std_logic;
        SIGNAL R3_read : std_logic;
        SIGNAL R_read : std_logic;
	SIGNAL shift_start : std_logic;	-- matrix shift started
	SIGNAL shift_done : std_logic;	-- matrix shift finished
	SIGNAL read_start : std_logic;	-- matrix readout started
	SIGNAL read_done : std_logic;	-- matrix readout finished
	SIGNAL DG_read : std_logic;
	SIGNAL adc_start : std_logic;
	SIGNAL adc_done : std_logic;
	SIGNAL adc_done_rising_edge : std_logic;
	SIGNAL adc_busy : std_logic;
	SIGNAL adc_data_out : std_logic_vector (31 downto 0);
	SIGNAL adc_data_out_valid : std_logic;
        
	SIGNAL state : STATE_TYPE;

begin

	shifter : shift_matrix PORT MAP(
		clk => clk,
		rst => rst,
		start => shift_start,
		delay1 => delay_S1_int,
		delay2 => delay_S2_int,
		delay3 => delay_S3_int,
		length1 => length_S1_int,
		length2 => length_S2_int,
		length3 => length_S3_int,
		invert1 => invert_S1_int,
		invert2 => invert_S2_int,
		invert3 => invert_S3_int,
                invertR => invert_R_int,
		repeat => rows_num_int,
		S1 => S1_shift,
		S2 => S2_shift,
		S3 => S3_shift,
                R => R_shift,
		done => shift_done
	);
	reader : matrix_readout PORT MAP(
		clk => clk,
		rst => rst,
		start => read_start,
		delay_S1 => delay_S1_int,
		delay_S2 => delay_S2_int,
		delay_S3 => delay_S3_int,
		length_S1 => length_S1_int,
		length_S2 => length_S2_int,
		length_S3 => length_S3_int,
		invert_S1 => invert_S1_int,
		invert_S2 => invert_S2_int,
		invert_S3 => invert_S3_int,
		delay_R1 => delay_R1_int,
		delay_R2 => delay_R2_int,
		delay_R3 => delay_R3_int,
		delay_R => delay_R_int,
		length_R1 => length_R1_int,
		length_R2 => length_R2_int,
		length_R3 => length_R3_int,
		length_R => length_R_int,
		invert_R1 => invert_R1_int,
		invert_R2 => invert_R2_int,
		invert_R3 => invert_R3_int,
		invert_R => invert_R_int,
                -- -- integrator control signals
                delay_ipc => delay_ipc_int,
                delay_FRST => delay_FRST_int,
                delay_FINT_plus => delay_FINT_plus_int,
                delay_FINT_minus => delay_FINT_minus_int,
                length_ipc => length_ipc_int,
                length_FRST => length_FRST_int,
                length_FINT_plus => length_FINT_plus_int,
                length_FINT_minus => length_FINT_minus_int,
                invert_ipc => invert_ipc_int,
                invert_FRST => invert_FRST_int,
                invert_FINT_plus => invert_FINT_plus_int,
                invert_FINT_minus => invert_FINT_minus_int,
                -- ---------------                
                state_during_shift_R1 => state_during_shift_R1,
                state_during_shift_R2 => state_during_shift_R2,
                state_during_shift_R3 => state_during_shift_R3,
		rows => rows_num_int,
		columns => columns_num_int,
		dump_length => dump_length,
		adc_busy => adc_busy,
		adc_done => adc_done_rising_edge,
--		adc_done => adc_done,
		adc_data_out => adc_data_out,
		adc_data_out_valid => adc_data_out_valid,
		S1 => S1_read,
		S2 => S2_read,
		S3 => S3_read,
		R1 => R1_read,
		R2 => R2_read,
		R3 => R3_read,
		R => R_read,
		DG => DG_read,
		data => data,
		data_valid => data_valid,
		done => read_done,
		adc_start => adc_start,
                -- -- integrator control signals
                ipc => ipc,
                FRST => FRST,
                FINT_plus => FINT_plus,
                FINT_minus => FINT_minus                
	);
	adc : adc7671dual_control PORT MAP(
		clk => clk,
		rst => rst,
		start => adc_start,
		done => adc_done,
		done_rising_edge => adc_done_rising_edge,
		busy => adc_busy,
		data_in => adc_data_in,
		data_out => adc_data_out,
		data_out_valid => adc_data_out_valid,
		busy0_async => adc_busy0_async,
		busy1_async => adc_busy1_async,
		nCNVST0 => nCNVST0,
		nCNVST1 => nCNVST1,
		rst_out => adc_rst_out,
		nCS0 => nCS0,
		nCS1 => nCS1,
		nRD0 => nRD0,
		nRD1 => nRD1,
		latch0 => adc_latch0,
		latch1 => adc_latch1 
	);

	switcher : process(clk)
	begin
		case state is			-- we will want to use signals from different modules for output
		when SHIFT =>
			S1 <= S1_shift;
			S2 <= S2_shift;
			S3 <= S3_shift;
			I1 <= S1_shift;
			I2 <= S2_shift;
			I3 <= S3_shift;
			DG <= '1';
                        R1 <= state_during_shift_R1;
                        R2 <= state_during_shift_R2;
                        R3 <= state_during_shift_R3;
                        if invert_R = '0' then
                          R <= '1';
                        else
                          R <= '0';
                        end if;
		when READ =>
			S1 <= S1_read;
			S2 <= S2_read;
			S3 <= S3_read;
			I1 <= state_default_I1; --'1';
			I2 <= state_default_I1; --'0';
			I3 <= state_default_I1; --'0';
			DG <= DG_read;
                        R1 <= R1_read;
                        R2 <= R2_read;
                        R3 <= R3_read;                        
                        R <= R_read;                        
		when others =>
			S1 <= state_default_S1; --S1_shift;
			S2 <= state_default_S2; --S2_shift;
			S3 <= state_default_S3; --S3_shift;
			I1 <= state_default_I1; --'1';
			I2 <= state_default_I2; --'0';
			I3 <= state_default_I3; -- '0';
			DG <= '0';
                        R1 <= state_during_shift_R1;
                        R2 <= state_during_shift_R2;
                        R3 <= state_during_shift_R3;                        
                        R <= R_read;
		end case;
	end process;

	main : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				exposed <= 0;
				shift_start <= '0';
				clean_req <= '1';
				state <= STAND_BY;
                                end_of_frame <= '0';
                                start_of_frame <= '0';
                                exposition_time_min <= (others => '0');
                                exposition_time_max <= (others => '0');
			else
				start_of_frame <= '0';
				end_of_frame <= '0';
                                
				case state is
				when STAND_BY =>
					exposed <= exposed + 1;

					if start = '1' then
						clean_req <= '1';
						state <= SETTINGS;
					end if;
				when SETTINGS =>
					exposed <= exposed + 1;

					delay_S1_int <= delay_S1;
					delay_S2_int <= delay_S2;
					delay_S3_int <= delay_S3;
					length_S1_int <= length_S1;
					length_S2_int <= length_S2;
					length_S3_int <= length_S3;
					invert_S1_int <= invert_S1;
					invert_S2_int <= invert_S2;
					invert_S3_int <= invert_S3;
					delay_R1_int <= delay_R1;
					delay_R2_int <= delay_R2;
					delay_R3_int <= delay_R3;
					delay_R_int <= delay_R;
					length_R1_int <= length_R1;
					length_R2_int <= length_R2;
					length_R3_int <= length_R3;
					length_R_int <= length_R;
					invert_R1_int <= invert_R1;
					invert_R2_int <= invert_R2;
					invert_R3_int <= invert_R3;
					invert_R_int <= invert_R;
                                        -- -- integrator control signals
                                        delay_ipc_int <= delay_ipc;
                                        delay_FRST_int <= delay_FRST;
                                        delay_FINT_plus_int <= delay_FINT_plus;
                                        delay_FINT_minus_int <= delay_FINT_minus;
                                        length_ipc_int <= length_ipc;
                                        length_FRST_int <= length_FRST;
                                        length_FINT_plus_int <= length_FINT_plus;
                                        length_FINT_minus_int <= length_FINT_minus;
                                        invert_ipc_int <= invert_ipc;
                                        invert_FRST_int <= invert_FRST;
                                        invert_FINT_plus_int <= invert_FINT_plus;
                                        invert_FINT_minus_int <= invert_FINT_minus;
                                        -- ---------------
					rows_num_int <= rows_num;
					columns_num_int <= columns_num;
					expose_time_int <= expose_time;
					if clean_req = '1' then
						shift_start <= '1';
						state <= SHIFT;
					else
						state <= EXPOSE;
					end if;
				when EXPOSE =>
					exposed <= exposed + 1;
					if exposed >= expose_time_int then
						exposition_time_min <= std_logic_vector(to_signed(exposed,exposition_time_min'length));
						shift_start <= '1';
						state <= SHIFT;
					end if;
				when SHIFT =>
					shift_start <= '0';
					if shift_start = '0' and shift_done = '1' then

						exposed <= 0;
						if clean_req = '1' then
							clean_req <= '0';
							state <= EXPOSE;
						else
							read_start <= '1';
							state <= READ;
                                                        start_of_frame <= '1';
                                                        exposition_time_max <= std_logic_vector(to_signed(exposed,exposition_time_max'length));
						end if;
					else
						exposed <= exposed + 1;
					end if;
				when READ =>
					exposed <= exposed + 1;

					read_start <= '0';
					if read_start = '0' and read_done = '1' then
						if start = '1' then
							state <= SETTINGS;
						else
							state <= STAND_BY;
						end if;
                                                end_of_frame <= '1';
					end if;
				when others =>
					exposed <= exposed + 1;

					shift_start <= '0';
					state <= SETTINGS;
				end case;

			end if;
		end if;
	end process;

end Behavioral;

