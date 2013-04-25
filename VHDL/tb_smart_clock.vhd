-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>




LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_smart_clock IS
END tb_smart_clock;
 
ARCHITECTURE behavior OF tb_smart_clock IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT smart_clock
    generic
    (
	C_INVERT : std_logic := '0';         -- invert component output

	C_DUMMY : integer :=0
    ); 
    PORT(
         clk : IN  std_logic;
         delay : IN  integer;
         length : IN  integer;
         start : IN  std_logic;
			suspend : in std_logic;
         rst : IN  std_logic;
         output : OUT  std_logic;
         done : OUT  std_logic;
			done_rising_edge : out STD_LOGIC;
			busy : out std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal delay : integer := 3;
   signal length : integer := 5;
   signal start : std_logic := '0';
	signal suspend : std_logic := '0';
   signal rst : std_logic := '0';
	signal done_rising_edge : std_logic := '0';
	signal busy : std_logic;

 	--Outputs
   signal output : std_logic;
   signal done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	
	signal counter : integer := 0;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: smart_clock PORT MAP (
          clk => clk,
          delay => delay,
          length => length,
          start => start,
			 suspend => suspend,
          rst => rst,
          output => output,
          done => done,
			 done_rising_edge => done_rising_edge,
			 busy => busy
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;



	main: process(clk)
	begin
		if rising_edge(clk) then
				if counter < 3 then
					rst <= '1';
					start <= '0';
				else 
					rst <= '0';
					if counter = 8 or counter = 20 then
						start <= '1';
					else
						start <= '0';
					end if;
				end if;
				 
				if counter > 9 and counter < 12  then 
					suspend <= '1';
				else
					suspend <= '0';
				end if;
		
				counter <= counter + 1;
							
		end if;

	end process;



END;
