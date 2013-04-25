
-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity adc7671 is
	generic(
		C_ID : integer := 0;
		c_CNVTIME_clk : integer := 20;

		C_DUMMY : integer := 0
	);
	port (
		clock : in STD_LOGIC;
		nCS : in  STD_LOGIC;
		nRD : in  STD_LOGIC;
		nCNVST : in  STD_LOGIC;
		BUSY : out  STD_LOGIC;
		DATA : out  STD_LOGIC_VECTOR (15 downto 0)
	);
end adc7671;

architecture Behavioral of adc7671 is

signal acq_data : std_logic_vector(DATA'length-1 downto 0);
signal counter : unsigned(DATA'length-1 downto 0) := X"0000";

constant DATALEN : integer := DATA'length;

type state_type is	(
								IDLE,
								RUNNING
							);
							
signal state : state_type := IDLE;							

begin

	out_proc: process(acq_data, nRD, nCS)
	begin
			if nCS = '0' and nRD = '0' then
				DATA <= acq_data;
			else
				DATA <= (others => 'Z');
			end if;
	end process;




	cnv_proc: process(clock,nCNVST)
		variable i: integer := 0;
	begin
		if rising_edge(clock)  then
			if state = IDLE then
				i := 0;
				-- if nCS = '0' and nCNVST = '0' then
				if nCNVST = '0' then
					state <= RUNNING;
				end if;	
			elsif state = RUNNING then
				i := i + 1;
				BUSY <= '1';
				if i > 31 then
					-- "busy" is set after about 30 ns
					BUSY <= '1';
					if i > 41 then
						-- old data output is valid upto 40 ns after a new conversion start
						acq_data <= X"FFFF";
					end if;
					if i > 31 + c_CNVTIME_clk then
						state <= IDLE;
						BUSY <= '0';
						acq_data <= std_logic_vector(counter);
						i := 0;
					end if;
				end if;
			else
				state <= IDLE;
				BUSY <= '0';
			end if;			
		end if;	
	end process;

	data_proc: process(clock)
	begin
		if rising_edge(clock) then
			if counter < to_unsigned(1333, DATALEN) then
				counter <= counter + 1;
			else
				counter <= to_unsigned(0, DATALEN);
			end if;
		end if;
	
	end process;


end Behavioral; 
