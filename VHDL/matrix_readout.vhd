-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY matrix_readout IS
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
                state_during_shift_R1 : in std_logic;
                state_during_shift_R2 : in std_logic;
                state_during_shift_R3 : in std_logic;
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
END matrix_readout;

ARCHITECTURE behavior OF matrix_readout IS 

	COMPONENT line_readout
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

	SIGNAL step_start : std_logic;
	SIGNAL step_done : std_logic;

BEGIN

	lines: line_readout PORT MAP(
		clk => clk,
		rst => rst,
		start => step_start,
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
                state_during_shift_R1 => state_during_shift_R1,
                state_during_shift_R2 => state_during_shift_R2,
                state_during_shift_R3 => state_during_shift_R3,
                -- -- integrator control signals
                delay_ipc => delay_ipc,
                delay_FRST => delay_FRST,
                delay_FINT_plus => delay_FINT_plus,
                delay_FINT_minus => delay_FINT_minus,
                length_ipc => length_ipc,
                length_FRST => length_FRST,
                length_FINT_plus =>length_FINT_plus ,
                length_FINT_minus => length_FINT_minus,
                invert_ipc => invert_ipc,
                invert_FRST => invert_FRST,
                invert_FINT_plus => invert_FINT_plus,
                invert_FINT_minus => invert_FINT_minus,
                -- ---------------                
		repeat => columns,
		dump_length => dump_length,
		adc_busy => adc_busy,
		adc_done => adc_done,
		adc_data_out => adc_data_out,
		adc_data_out_valid => adc_data_out_valid,
		S1 => S1,
		S2 => S2,
		S3 => S3,
		R1 => R1,
		R2 => R2,
		R3 => R3,
		R => R,
		DG => DG,
		data => data,
		data_valid => data_valid,
		done => step_done,
		adc_start => adc_start,
                -- -- integrator control signals
                ipc => ipc,
                FRST => FRST,
                FINT_plus => FINT_plus,
                FINT_minus => FINT_minus
	);
	generator : continuous_generator PORT MAP(
		clk => clk,
		rst => rst,
		repeat => rows,
		done => step_done,
		flag => start,
		start => step_start,
		finished => done
	);

END;
