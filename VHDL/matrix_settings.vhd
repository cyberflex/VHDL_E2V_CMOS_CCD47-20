-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY matrix_settings IS
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
END matrix_settings;

ARCHITECTURE matrix_settings_arch OF matrix_settings IS
	signal uvalue : unsigned(31 downto 0);  -- auxilary copy of value signal, just a vector
  
	signal int_soft_reset : std_logic;
	signal int_delay_S1 : integer;		-- here and below - settings for S1-S3 signals
	signal int_delay_S2 : integer;
	signal int_delay_S3 : integer;
	signal int_length_S1 : integer;
	signal int_length_S2 : integer;
	signal int_length_S3 : integer;
	signal int_invert_S1 : std_logic;
	signal int_invert_S2 : std_logic;
	signal int_invert_S3 : std_logic;
	signal int_delay_R1 : integer;		-- here and below - settings for R1-R3 and R signals
	signal int_delay_R2 : integer;
	signal int_delay_R3 : integer;
	signal int_delay_R : integer;
	signal int_length_R1 : integer;
	signal int_length_R2 : integer;
	signal int_length_R3 : integer;
	signal int_length_R : integer;
	signal int_invert_R1 : std_logic;
	signal int_invert_R2 : std_logic;
	signal int_invert_R3 : std_logic;
	signal int_invert_R : std_logic;
        -- -- integrator control signals
        SIGNAL int_delay_ipc : integer;
        SIGNAL int_delay_FRST : integer;
        SIGNAL int_delay_FINT_plus : integer;
        SIGNAL int_delay_FINT_minus : integer;
        SIGNAL int_length_ipc : integer;
        SIGNAL int_length_FRST : integer;
        SIGNAL int_length_FINT_plus : integer;
        SIGNAL int_length_FINT_minus : integer;
        SIGNAL int_invert_ipc : std_logic;
        SIGNAL int_invert_FRST : std_logic;
        SIGNAL int_invert_FINT_plus : std_logic;
        SIGNAL int_invert_FINT_minus : std_logic;
        -- ---------------        
	signal int_rows_num : integer;		-- number of rows in our matrix
	signal int_columns_num : integer;	-- number of columns in our matrix
	signal int_dump_length : integer;	-- readout register clean time
	signal int_expose_time : integer;		-- exposition time
        signal int_state_during_shift_R1 : std_logic;
        signal int_state_during_shift_R2 : std_logic;
        signal int_state_during_shift_R3 : std_logic;
        signal int_state_default_S1 : std_logic;
        signal int_state_default_S2 : std_logic;
        signal int_state_default_S3 : std_logic;
        signal int_state_default_I1 : std_logic;
        signal int_state_default_I2 : std_logic;
        signal int_state_default_I3 : std_logic;
BEGIN
	uvalue <= to_unsigned(value, uvalue'length);
  
	delay_S1 <= int_delay_S1;
	delay_S2 <= int_delay_S2;
	delay_S3 <= int_delay_S3;
	length_S1 <= int_length_S1;
	length_S2 <= int_length_S2;
	length_S3 <= int_length_S3;
	invert_S1 <= int_invert_S1;
	invert_S2 <= int_invert_S2;
	invert_S3 <= int_invert_S3;
	delay_R1 <= int_delay_R1;
	delay_R2 <= int_delay_R2;
	delay_R3 <= int_delay_R3;
	delay_R <= int_delay_R;
	length_R1 <= int_length_R1;
	length_R2 <= int_length_R2;
	length_R3 <= int_length_R3;
	length_R <= int_length_R;
	invert_R1 <= int_invert_R1;
	invert_R2 <= int_invert_R2;
	invert_R3 <= int_invert_R3;
	invert_R <= int_invert_R;
	rows_num <= int_rows_num;
	columns_num <= int_columns_num;
	dump_length <= int_dump_length;
	expose_time <= int_expose_time;
        state_during_shift_R1 <= int_state_during_shift_R1;
        state_during_shift_R2 <= int_state_during_shift_R2;
        state_during_shift_R3 <= int_state_during_shift_R3;
        state_default_S1 <= int_state_default_S1;
        state_default_S2 <= int_state_default_S2;
        state_default_S3 <= int_state_default_S3;
        state_default_I1 <= int_state_default_I1;
        state_default_I2 <= int_state_default_I2;
        state_default_I3 <= int_state_default_I3;

	main: process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				soft_reset <= '0';
				int_delay_S1 <= 10;
				int_delay_S2 <= 0;
				int_delay_S3 <= 20;
				int_length_S1 <= 30;
				int_length_S2 <= 30;
				int_length_S3 <= 30;
				int_invert_S1 <= '1';
				int_invert_S2 <= '0';
				int_invert_S3 <= '0';
				int_delay_R1 <= 0;
				int_delay_R2 <= 2;
				int_delay_R3 <= 1;
				int_delay_R <= 3;
				int_length_R1 <= 3;
				int_length_R2 <= 3;
				int_length_R3 <= 3;
				int_length_R <= 1;
				int_invert_R1 <= '1';
				int_invert_R2 <= '1';
				int_invert_R3 <= '0';
				int_invert_R <= '0';
                                -- -- integrator control signals
                                int_delay_ipc <= 0;
                                int_delay_FRST <= 1;
                                int_delay_FINT_plus <= 2;
                                int_delay_FINT_minus <= 3;
                                int_length_ipc <= 2;
                                int_length_FRST <= 3;
                                int_length_FINT_plus <= 4;
                                int_length_FINT_minus <= 5;
                                int_invert_ipc <= '0';
                                int_invert_FRST <= '0';
                                int_invert_FINT_plus <= '0';
                                int_invert_FINT_minus <= '0';
                                -- ---------------                                
				int_rows_num <= 5;
				int_columns_num <= 5;
				int_dump_length <= 2;
				int_expose_time <= 2000;
                                int_state_during_shift_R1 <= '1';
                                int_state_during_shift_R2 <= '1';
                                int_state_during_shift_R3 <= '0';
                                int_state_default_S1 <= '0';
                                int_state_default_S2 <= '0';
                                int_state_default_S3 <= '0';
                                int_state_default_I1 <= '0';
                                int_state_default_I2 <= '0';
                                int_state_default_I3 <= '0';
			else
				if flag = '1' then
					case id is
					when 0 =>
						if value = 0 then soft_reset <= '0';
						else soft_reset <= '1';
						end if;
					when 1 => int_delay_S1 <= value;
					when 2 => int_delay_S2 <= value;
					when 3 => int_delay_S3 <= value;
					when 4 => int_length_S1 <= value;
					when 5 => int_length_S2 <= value;
					when 6 => int_length_S3 <= value;
					when 7 =>
						if value = 0 then int_invert_S1 <= '0';
						else int_invert_S1 <= '1';
						end if;
					when 8 =>
						if value = 0 then int_invert_S2 <= '0';
						else int_invert_S2 <= '1';
						end if;
					when 9 =>
						if value = 0 then int_invert_S3 <= '0';
						else int_invert_S3 <= '1';
						end if;
					when 10 => int_delay_R1 <= value;
					when 11 => int_delay_R2 <= value;
					when 12 => int_delay_R3 <= value;
					when 13 => int_delay_R <= value;
					when 14 => int_length_R1 <= value;
					when 15 => int_length_R2 <= value;
					when 16 => int_length_R3 <= value;
					when 17 => int_length_R <= value;
					when 18 =>
						if value = 0 then int_invert_R1 <= '0';
						else int_invert_R1 <= '1';
						end if;
					when 19 =>
						if value = 0 then int_invert_R2 <= '0';
						else int_invert_R2 <= '1';
						end if;
					when 20 =>
						if value = 0 then int_invert_R3 <= '0';
						else int_invert_R3 <= '1';
						end if;
					when 21 =>
						if value = 0 then int_invert_R <= '0';
						else int_invert_R <= '1';
						end if;
					when 22 => int_rows_num <= value;
					when 23 => int_columns_num <= value;
					when 24 => int_dump_length <= value;
					when 25 => int_expose_time <= value;
					when 26 =>
                                          int_state_during_shift_R1 <= uvalue(0);
                                          int_state_during_shift_R2 <= uvalue(1);
                                          int_state_during_shift_R3 <= uvalue(2);
                                          int_state_default_S1 <= uvalue(3);
                                          int_state_default_S2 <= uvalue(4);
                                          int_state_default_S3 <= uvalue(5);
                                          int_state_default_I1 <= uvalue(6);
                                          int_state_default_I2 <= uvalue(7);
                                          int_state_default_I3 <= uvalue(8);
                                        -- -- integrator control signals  
                                        when 27 =>  
                                          int_delay_ipc <= value;
                                        when 28 =>
                                          int_delay_FRST <= value;
                                        when 29 =>  
                                          int_delay_FINT_plus <= value;
                                        when 30 =>  
                                          int_delay_FINT_minus <= value;
                                        when 31 =>  
                                          int_length_ipc <= value;
                                        when 32 =>
                                          int_length_FRST <= value;
                                        when 33 =>  
                                          int_length_FINT_plus <= value;
                                        when 34 =>  
                                          int_length_FINT_minus <= value;
                                        when 35 =>
                                          int_invert_ipc <= uvalue(0);
                                          int_invert_FRST <= uvalue(1);
                                          int_invert_FINT_plus <= uvalue(2);
                                          int_invert_FINT_minus <= uvalue(3);
                                        -- ---------------  
					when others =>
					end case;
				end if;
			end if;
		end if;
	end process;

END;
