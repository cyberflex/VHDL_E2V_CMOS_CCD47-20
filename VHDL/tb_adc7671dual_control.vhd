-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>




LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY tb_adc7671dual_control IS
END tb_adc7671dual_control;
 
ARCHITECTURE behavior OF tb_adc7671dual_control IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT adc7671dual_control
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         start : IN  std_logic;
         done : OUT  std_logic;
         done_rising_edge : OUT  std_logic;
         busy : OUT  std_logic;
         data_in : IN  std_logic_vector(15 downto 0);
         data_out : OUT  std_logic_vector(31 downto 0);
         data_out_valid : OUT  std_logic;
         busy0_async : IN  std_logic;
         busy1_async : IN  std_logic;
         nCNVST0 : OUT  std_logic;
         nCNVST1 : OUT  std_logic;
         rst_out : OUT  std_logic;
         nCS0 : OUT  std_logic;
         nCS1 : OUT  std_logic;
         nRD0 : OUT  std_logic;
         nRD1 : OUT  std_logic;
			latch0 : out STD_LOGIC; -- debug output, pulsed when ADC1 output is latched
			latch1 : out STD_LOGIC  -- debug output, pulsed when ADC2 output is latched			
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal start : std_logic := '0';
   signal data_in : std_logic_vector(15 downto 0) := (others => '0');
   signal busy0_async : std_logic := '0';
   signal busy1_async : std_logic := '0';

 	--Outputs
   signal done : std_logic;
   signal done_rising_edge : std_logic;
   signal busy : std_logic;
   signal data_out : std_logic_vector(31 downto 0);
   signal data_out_valid : std_logic;
   signal nCNVST0 : std_logic;
   signal nCNVST1 : std_logic;
   signal rst_out : std_logic;
   signal nCS0 : std_logic;
   signal nCS1 : std_logic;
   signal nRD0 : std_logic;
   signal nRD1 : std_logic;
   signal latch0 : std_logic;
   signal latch1 : std_logic;	

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	constant adc_cnv_time : time := 30 ns;
	
	signal counter: integer := 0;
	signal sample_counter: integer := 0;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: adc7671dual_control PORT MAP (
          clk => clk,
          rst => rst,
          start => start,
          done => done,
          done_rising_edge => done_rising_edge,
          busy => busy,
          data_in => data_in,
          data_out => data_out,
          data_out_valid => data_out_valid,
          busy0_async => busy0_async,
          busy1_async => busy1_async,
          nCNVST0 => nCNVST0,
          nCNVST1 => nCNVST1,
          rst_out => rst_out,
          nCS0 => nCS0,
          nCS1 => nCS1,
          nRD0 => nRD0,
          nRD1 => nRD1,
			 latch0 => latch0,
			 latch1 => latch1
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
		start <= '0';
	
		rst <= '1';
      --wait for 20 ns;
		wait for clk_period*2;
		rst <= '0';
		wait for clk_period;
	
	
-- wait until rising_edge(<signal_name>);	
--	wait until <signal_name> = <value>;
-- <signal_name> <= <signal_value> after SIM_TIME;
-- wait on <signal_name>;
	
		sample_counter	<= sample_counter + 1;
		data_in <= X"0003";--std_logic_vector(to_signed(sample_counter,32));
		start <= '1';
		wait for clk_period;
		start <= '0';
      wait for adc_cnv_time;
		busy0_async <= '1';
		busy1_async <= '1';		
		wait for clk_period*3;
		busy0_async <= '0';
		wait for clk_period;
		busy1_async <= '0';
		wait  on done_rising_edge;
		wait until done_rising_edge = '0';


		--wait until done = '1';
		wait for clk_period;


		sample_counter	<= sample_counter + 1;
		data_in <= X"0005";--std_logic_vector(to_signed(sample_counter,32));
		start <= '1';
		wait for clk_period;
		start <= '0';
      wait for adc_cnv_time;
		busy0_async <= '1';
		busy1_async <= '1';		
		wait for clk_period*3;
		busy0_async <= '0';
		wait for clk_period;
		busy1_async <= '0';	


      wait;
   end process;
	
	
	main: process(clk)
	begin
		if rising_edge(clk) then
--			if counter < 2 then
--				rst <= '1';
--			else
--				rst <= '0';
--			end if;
			
--			if counter > 2 and counter < 4 then
--				start <= '1';
--			else
--				start <= '0';
--			end if;


--			if counter > 8 and counter < 12 then
--				busy0_async <= '1';
--				busy1_async <= '1';
--			else
--				busy0_async <= '0';
--				busy1_async <= '0';
--			end if;



		
			counter <= counter + 1;
		end if;
	end process;
	

END;
