-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY line_readout IS
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
		invert_R1 : in std_logic;
		invert_R2 : in std_logic;
		invert_R3 : in std_logic;
		invert_R : in std_logic;
                state_during_shift_R1 : in std_logic;
                state_during_shift_R2 : in std_logic;
                state_during_shift_R3 : in std_logic;
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
		repeat : in integer;
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
END line_readout;

ARCHITECTURE behavior OF line_readout IS 

	COMPONENT three_clocks
	PORT(
		clk : in  std_logic;
		rst : in  std_logic;
		start : in std_logic;
		suspend : in std_logic;
		delay1 : in integer;
		delay2 : in integer;
		delay3 : in integer;
		length1 : in integer;
		length2 : in integer;
		length3 : in integer;
		invert1 : in std_logic;
		invert2 : in std_logic;
		invert3 : in std_logic;
		output1 : out std_logic;
		output2 : out std_logic;
		output3 : out std_logic;
		done : out std_logic;
		done_rising_edge : out STD_LOGIC;	
		busy : out std_logic
	);
	END COMPONENT;

	COMPONENT pixel_readout
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
	END COMPONENT;

	COMPONENT continuous_generator
	PORT(
		clk : in std_logic;
		rst : in std_logic;
		repeat : in integer;
		done : in std_logic;
		flag : in std_logic;
		start : out std_logic;
		finished : out std_logic
	);
	END COMPONENT;

	TYPE STATE_TYPE is (
		WAIT_STATE,
		DUMP,		-- clear readout register
		TRANSFER,
		READOUT,
		WAIT_TDIR
	);

	SIGNAL move_start : std_logic;
	SIGNAL move_done : std_logic;
	SIGNAL read_start : std_logic;
	SIGNAL read_done : std_logic;

	SIGNAL step_start : std_logic;
	SIGNAL step_done : std_logic;

        signal three_clocks_busy : std_logic;
	
	SIGNAL dump_counter : integer;
	SIGNAL R1_read : std_logic;
	SIGNAL R2_read : std_logic;
	SIGNAL R3_read : std_logic;
	SIGNAL R_read : std_logic; 

        signal R_internal : std_logic;
      
	SIGNAL state : STATE_TYPE;
	SIGNAL wait_tdir_counter: integer := 0;
	
BEGIN

	clocks : three_clocks PORT MAP(
		clk => clk,
		rst => rst,
		start => move_start,
		suspend => '0',
		delay1 => delay_S1,
		delay2 => delay_S2,
		delay3 => delay_S3,
		length1 => length_S1,
		length2 => length_S2,
		length3 => length_S3,
		invert1 => invert_S1,
		invert2 => invert_S2,
		invert3 => invert_S3,
		output1 => S1,
		output2 => S2,
		output3 => S3,
		done => move_done,
		done_rising_edge => open,
		busy => three_clocks_busy
	);
	pixels : pixel_readout PORT MAP(
		clk => clk,
		rst => rst,
		start => step_start,
		delay_R1 => delay_R1,
		delay_R2 => delay_R2,
		delay_R3 => delay_R3,
		delay_R => delay_R,
                delay_ipc => delay_ipc,
                delay_FRST => delay_FRST,
                delay_FINT_plus => delay_FINT_plus,
                delay_FINT_minus  => delay_FINT_minus,               
		length_R1 => length_R1,
		length_R2 => length_R2,
		length_R3 => length_R3,
		length_R => length_R,
                length_ipc => length_ipc,
                length_FRST => length_FRST,
                length_FINT_plus => length_FINT_plus,
                length_FINT_minus => length_FINT_minus,               
		invert_R1 => invert_R1,
		invert_R2 => invert_R2,
		invert_R3 => invert_R3,
		invert_R => invert_R,
                invert_ipc => invert_ipc,
                invert_FRST => invert_FRST,
                invert_FINT_plus => invert_FINT_plus,
                invert_FINT_minus => invert_FINT_minus,                
		adc_busy => adc_busy,
		adc_done => adc_done,
		adc_data_out => adc_data_out,
		adc_data_out_valid => adc_data_out_valid,
		R1 => R1_read,
		R2 => R2_read,
		R3 => R3_read,
		R => R_read,
		data => data,
		data_valid => data_valid,
		done => step_done,
		adc_start => adc_start,
                -- -- integrator control signals
                ipc => ipc,
                FRST => FRST,
                FINT_plus => FINT_plus,
                FINT_minus  =>  FINT_minus           
	);
	generator : continuous_generator PORT MAP(
		clk => clk,
		rst => rst,
		repeat => repeat,
		done => step_done,
		flag => read_start,
		start => step_start,
		finished => read_done
	);

	switcher : process(clk, state,three_clocks_busy,R1_read,R2_read,R3_read,R_internal)--  !!!
	begin
				--add new state wait tdir after line transfer
                if state = TRANSFER or state = DUMP or state = WAIT_TDIR then
                  R_internal <= '1' xor  invert_R;
                else
                  R_internal <= '0' xor invert_R;
                end if;
                
		if state = DUMP then
			R1 <= '0';
			R2 <= '0';
			R3 <= '0';
			R <= R_internal; --'1';
			DG <= '1';
		else
                        if (three_clocks_busy = '1') or (state = TRANSFER) then
                              R1 <= state_during_shift_R1;
                              R2 <= state_during_shift_R2;
                              R3 <= state_during_shift_R3;
                        else
			      R1 <= R1_read;
			      R2 <= R2_read;
			      R3 <= R3_read;
                        end if;      
                        if invert_R = '0' then
                          R <= R_internal or R_read;
                        else
                          ---- R <= not ( (not R_internal) or (not R_read));
                          R <= R_internal and  R_read;
                        end if;

			DG <= '0';
		end if;

	end process;

	main : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				move_start <= '0';
				read_start <= '0';
				done <= '0';
				dump_counter <= 0;
				state <= WAIT_STATE;
			else
				case state is
				when WAIT_STATE =>
					read_start <= '0';
					if start = '1' then
						dump_counter <= 0;
						done <= '0';
						state <= DUMP;
					end if;
				when DUMP =>
					if dump_counter < dump_length then
						dump_counter <= dump_counter + 1;
					else
						move_start <= '1';
						state <= TRANSFER;
					end if;			
				when TRANSFER =>
					move_start <= '0';
					if move_start = '0' and move_done = '1' then
						state <= WAIT_TDIR;
					end if;
					--add new state wait tdir after line transfer
				when WAIT_TDIR =>
					move_start <= '0';
					wait_tdir_counter <= wait_tdir_counter + 1;
					if  wait_tdir_counter > 200 then
						read_start <= '1';
						state <= READOUT;
						wait_tdir_counter <= 0;
					end if;				
				when READOUT =>
					read_start <= '0';
					if read_start = '0' and read_done = '1' then
						done <= '1';
						state <= WAIT_STATE;
					end if;
				when others =>
					move_start <= '0';
					read_start <= '0';
					done <= '0';
					state <= WAIT_STATE;
				end case;
			end if;
		end if;
	end process;

END;
 
