-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity three_clocks is
	PORT(
		clk : in  std_logic;
		rst : in  std_logic;
		start : in std_logic;
		suspend : in std_logic; -- suspend execution at current point (if already started and NOT finished yet)
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
		done_rising_edge : out STD_LOGIC; -- TODO "rising edge active" (single clock finished signal, length is NOT changed by "suspend" signal)	
		busy : out std_logic
	);
end three_clocks;

architecture Behavioral of three_clocks is

	COMPONENT smart_clock
	generic
	(
	    C_INVERT : std_logic := '0';         -- invert component output

	    C_DUMMY : integer :=0
	); 
	PORT(
		clk : in std_logic;
		delay : in integer;
		length : in integer;
		start : in std_logic;
		suspend : in std_logic;
		rst : in std_logic;
		output : out std_logic;
		done : out std_logic;
		done_rising_edge : out STD_LOGIC;
		busy : out std_logic
	);
	END COMPONENT;

component single_pulse is
port(
  clk: in std_logic;
  rst: in std_logic;
  input: in std_logic;
  output: out std_logic
);
end component;

	signal done1 : std_logic;
	signal done2 : std_logic;
	signal done3 : std_logic;
	signal busy1 : std_logic;
	signal busy2 : std_logic;
	signal busy3 : std_logic;

	signal clock1 : std_logic;
	signal clock2 : std_logic;
	signal clock3 : std_logic;
	
	
	signal done_internal : std_logic;

begin

	busy <= busy1 or busy2 or busy3;

	i1: smart_clock PORT MAP(
		clk => clk,
		delay => delay1,
		length => length1,
		start => start,
		suspend => suspend,
		rst => rst,
		output => clock1,
		done => done1,
		done_rising_edge => open,
		busy => busy1
	);
			 
          i2: smart_clock PORT MAP(
		clk => clk,
		delay => delay2,
		length => length2,
		start => start,
		suspend => suspend,
		rst => rst,
		output => clock2,
		done => done2,
		done_rising_edge => open,
		busy => busy2
          );

          i3: smart_clock PORT MAP(
		clk => clk,
		delay => delay3,
		length => length3,
		start => start,
		suspend => suspend,
		rst => rst,
		output => clock3,
		done => done3,
		done_rising_edge => open,
		busy => busy3
          );

	output1 <= clock1 xor invert1;
	output2 <= clock2 xor invert2;
	output3 <= clock3 xor invert3;

	done_internal <= done1 and done2 and done3;
	
	done <= done_internal;
	
	doneRisingEdge: single_pulse port map(
		clk => clk,
		rst => rst,
		input => done_internal,
		output => done_rising_edge
	);	

end Behavioral;

