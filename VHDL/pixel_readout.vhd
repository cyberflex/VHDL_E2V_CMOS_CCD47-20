-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pixel_readout IS
	PORT(
		clk : in  std_logic;
		rst : in  std_logic;
		start : in std_logic;
		delay_R1 : in integer;
		delay_R2 : in integer;
		delay_R3 : in integer;
		delay_R : in integer;
                delay_ipc : in integer;
                delay_FRST : in integer;
                delay_FINT_plus : in integer;
                delay_FINT_minus : in integer;
		length_R1 : in integer;
		length_R2 : in integer;
		length_R3 : in integer;
		length_R : in integer;
                length_ipc : in integer;
                length_FRST : in integer;
                length_FINT_plus : in integer;
                length_FINT_minus : in integer;
		invert_R1 : in std_logic;
		invert_R2 : in std_logic;
		invert_R3 : in std_logic;
		invert_R : in std_logic;
                invert_ipc : in std_logic; 
                invert_FRST : in std_logic;
                invert_FINT_plus : in std_logic;
                invert_FINT_minus : in std_logic;
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
END pixel_readout;

ARCHITECTURE behavior OF pixel_readout IS 

	COMPONENT four_clocks
	PORT(
		clk : in  std_logic;
		rst : in  std_logic;
		start : in std_logic;
		suspend : in std_logic;
		delay1 : in integer;
		delay2 : in integer;
		delay3 : in integer;
		delay4 : in integer;
		length1 : in integer;
		length2 : in integer;
		length3 : in integer;
		length4 : in integer;
		invert1 : in std_logic;
		invert2 : in std_logic;
		invert3 : in std_logic;
		invert4 : in std_logic;
		output1 : out std_logic;
		output2 : out std_logic;
		output3 : out std_logic;
		output4 : out std_logic;
		done : out std_logic;
		done_rising_edge : out STD_LOGIC;
		busy : out std_logic
	);
	END COMPONENT;



        COMPONENT integrator_control 
	PORT ( 
	   clk : in std_logic;
           rst : in std_logic;

           start : in std_logic;        -- single clock start signal (start condition)
           stop  : in std_logic;

           -- output pulses' parameters
           delay_ipc : in integer;
           length_ipc : in integer;
           invert_ipc : in std_logic;

           delay_FRST : in integer;
           length_FRST : in integer;
           invert_FRST : in std_logic;

           delay_FINT_plus : in integer;
           length_FINT_plus : in integer;
           invert_FINT_plus : in std_logic;

           delay_FINT_minus : in integer;
           length_FINT_minus : in integer;
           invert_FINT_minus : in std_logic;
           
           -- output pulses
           ipc : out STD_LOGIC;
           FRST : out STD_LOGIC;
           FINT_plus : out STD_LOGIC;
           FINT_minus : out STD_LOGIC

			  
			  
	);
        END COMPONENT;

        

	TYPE STATE_TYPE is (
		WAIT_STATE,
		PIXEL_TRANSFER,
		ADC_READOUT
	);

        SIGNAL zero : std_logic;
          
	SIGNAL move_start : std_logic;
	SIGNAL move_done : std_logic;
	SIGNAL read_start : std_logic;
	SIGNAL read_done : std_logic;
	SIGNAL R_internal : std_logic;
        signal clocks_done : std_logic;

	SIGNAL state : STATE_TYPE;

BEGIN
  
	ZERO <= '0';

	clocks: four_clocks PORT MAP(
		clk => clk,
		rst => rst,
		start => move_start,
		suspend => '0',
		delay1 => delay_R1,
		delay2 => delay_R2,
		delay3 => delay_R3,
		delay4 => delay_R,
		length1 => length_R1,
		length2 => length_R2,
		length3 => length_R3,
		length4 => length_R,
		invert1 => invert_R1,
		invert2 => invert_R2,
		invert3 => invert_R3,
		invert4 => invert_R,
		output1 => R1,
		output2 => R2,
		output3 => R3,
		output4 => R_internal,
		done => move_done,
		done_rising_edge => clocks_done,
		busy => open
	);

	R <= R_internal;
	adc_start <= clocks_done;

	main : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				move_start <= '0';
				read_start <= '0';
				data_valid <= '0';
				--adc_start <= '0';
				done <= '0';
				data <= (others => '0');
				state <= WAIT_STATE;
			else
				case state is
				when WAIT_STATE =>
					read_start <= '0';
					data_valid <= '0';
					--adc_start <= '0';

					if start = '1' then
						done <= '0';
						move_start <= '1';

						state <= PIXEL_TRANSFER;
					end if;
				when PIXEL_TRANSFER =>
					move_start <= '0';
					if move_start = '0' and move_done = '1' then
						read_start <= '1';
						--adc_start <= '1';

						state <= ADC_READOUT;
					end if;
				when ADC_READOUT =>
					read_start <= '0';
					-- if read_start = '0' and adc_done = '1' and adc_data_out_valid = '1' and adc_busy = '0' then
                                        if read_start = '0' and adc_done = '1' then
						data <= adc_data_out;
						data_valid <= '1';
						read_done <= '1';

						done <= '1';
						state <= WAIT_STATE;
					end if;
				when others =>
					move_start <= '0';
					read_start <= '0';
					data_valid <= '0';
					done <= '0';
					state <= WAIT_STATE;
				end case;
			end if;
		end if;
	end process;




        intctl: integrator_control  PORT MAP( 
	   clk => clk,
           rst => rst,

           start => move_start,        -- single clock start signal (start condition)
           stop => zero,

           -- output pulses' parameters
           delay_ipc => delay_ipc,
           length_ipc => length_ipc,
           invert_ipc => invert_ipc,

           delay_FRST => delay_FRST,
           length_FRST => length_FRST,
           invert_FRST => invert_FRST,

           delay_FINT_plus => delay_FINT_plus,
           length_FINT_plus => length_FINT_plus,
           invert_FINT_plus => invert_FINT_plus,

           delay_FINT_minus => delay_FINT_minus,
           length_FINT_minus => length_FINT_minus,
           invert_FINT_minus => invert_FINT_minus,
           
           -- output pulses
           ipc => ipc,
           FRST => FRST,
           FINT_plus => FINT_plus,
           FINT_minus =>FINT_minus

			  
			  
	);



        
END;
 
 
