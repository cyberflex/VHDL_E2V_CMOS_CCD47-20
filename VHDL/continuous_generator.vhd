-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

-- Generates a continuous sequence of start flags
-- After each flag waits for a "done" signal before generating next "start"
-- Number of repetitions is specified by "repeat"
-- Initiated by "flag" signal
-- When the sequence is finished sets "finished" to 1

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity continuous_generator is
port(
	clk : in std_logic;
	rst : in std_logic;
	repeat : in integer; -- times to repeat before "finished"
	done : in std_logic;
	flag : in std_logic;
	start : out std_logic;
	finished : out std_logic
);
end continuous_generator;

architecture generator of continuous_generator is

type STATE_TYPE is (
	WAIT_STATE,
	DO_STATE);

signal state : STATE_TYPE := WAIT_STATE;
signal counter : integer := 0;
signal started : std_logic;

begin

	start <= started;

	main : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				state <= WAIT_STATE;
				counter <= 0;
				started <= '0';
				finished <= '0';
			else
				case state is
				when WAIT_STATE =>
					if flag = '1' then
						started <= '1';
						finished <= '0';
						counter <= 1;
						state <= DO_STATE;
					end if;
				when DO_STATE =>
					if started = '0' and done = '1' then
						if counter >= repeat then
							finished <= '1';
							state <= WAIT_STATE;
						else
							counter <= counter + 1;
							started <= '1';
						end if;
					else
						started <= '0';
					end if;
				when others =>
					started <= '0';
					state <= WAIT_STATE;
				end case;
			end if;
		end if;
	end process;

end generator;