-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY shift_matrix IS
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
END shift_matrix;

ARCHITECTURE behavior OF shift_matrix IS 

	COMPONENT three_clocks
	PORT(
		clk : in std_logic;
		rst : in std_logic;
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
		done_rising_edge : out std_logic;
		busy : out std_logic
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
        signal R_internal : std_logic;

BEGIN
	r_control: process(clk)
        begin
          if invertR = '0' then
            R <= R_internal;
          else
            R <= not R_internal;
          end if;
        end process r_control;
        
  
	clocks: three_clocks PORT MAP(
		clk => clk,
		rst => rst,
		start => step_start,
		suspend => '0',
		delay1 => delay1,
		delay2 => delay2,
		delay3 => delay3,
		length1 => length1,
		length2 => length2,
		length3 => length3,
		invert1 => invert1,
		invert2 => invert2,
		invert3 => invert3,
		output1 => S1,
		output2 => S2,
		output3 => S3,
		done => step_done,
		done_rising_edge => open,
		busy => R_internal
	);
	generator : continuous_generator PORT MAP(
		clk => clk,
		rst => rst,
		repeat => repeat,
		done => step_done,
		flag => start,
		start => step_start,
		finished => done
	);

  END;
