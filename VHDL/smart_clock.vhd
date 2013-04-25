-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>




-- Generates a single clock of specified length with specified delay
-- Initiated by "start" signal
-- When the clock is finished sets "done" to 1

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity smart_clock is
generic
(
    C_INVERT : std_logic := '0';         -- invert component output
    
    C_DUMMY : integer :=0
);  
port(
	clk : in std_logic;
	delay : in integer;
	length : in integer;
	start : in std_logic;
	suspend : in std_logic; -- suspend execution at current point (if already started and NOT finished yet)
	rst : in std_logic; -- overrides "suspend" and moves component to reset
	output : out std_logic;
	done : out std_logic; -- setting of this signal may be delayed untill "suspend" signal is active
	done_rising_edge : out STD_LOGIC; -- "rising edge active" (single clock finished signal, length is NOT changed by "suspend" signal)	
	busy : out std_logic
);
end smart_clock;

architecture smart_clock_arch of smart_clock is

component single_pulse is
port(
  clk: in std_logic;
  rst: in std_logic;
  input: in std_logic;
  output: out std_logic
);
end component;

type STATE_TYPE is (
	WAIT_STATE,
	DO_STATE);

signal started : std_logic;
signal finished : std_logic;
signal clock : std_logic;
signal step : integer;
signal state : STATE_TYPE := WAIT_STATE;

begin
	output <= clock xor C_INVERT;
	done <= finished;
	busy <= started;


	doneRisingEdge: single_pulse port map(
		clk => clk,
		rst => rst,
		input => finished,
		output => done_rising_edge
	);

	main : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				started <= '0';
				finished <= '0';
				clock <= '0';
				step <= 0;
				state <= WAIT_STATE;
			else
				case state is
				when WAIT_STATE =>
					if start = '1' then
						if delay = 0 then
							clock <= '1';
						else
							clock <= '0';
						end if;
						step <= 1;
						started <= '1';
						finished <= '0';
						state <= DO_STATE;
					end if;
				when DO_STATE =>
					if step < delay + length then
						if step >= delay then
							clock <= '1';
						else
							clock <= '0';
						end if;
						step <= step + 1;
					else
						clock <= '0';
						started <= '0';
						finished <= '1';
						state <= WAIT_STATE;
					end if;
				when others =>
					started <= '0';
					finished <= '0';
					step <= 0;
					clock <= '0';
					state <= WAIT_STATE;
				end case;
			end if;
		end if;
	end process;

end smart_clock_arch;
