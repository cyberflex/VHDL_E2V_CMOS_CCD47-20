-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

-- -------------------------------------------------------------------------
-- adc_dac_mux passes througth ADC group or DAC group chip selects (r/w enables)
-- depending on value of signal adc_dac_select.
-- when switching multiplexer bitween these two states both groups chipselects (and other signals)
-- are deactivated for C_SWITCH_DELAY cycles
-- -------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity adc_dac_mux is
	generic (
		C_SWITCH_DELAY : integer := 10; -- delay bitween deactivation of CS-s of one group and activation of enother
		
		C_DUMMY : integer := 0
	);
	Port ( 
			 clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  
           adc_dac_select: in STD_LOGIC; -- 0  select is working with ADC, 1 is working with DAC
           adc_is_active: out STD_LOGIC; -- ADC-s chip selects are passed through, DAC-s chip selects are blocked
           dac_is_active: out STD_LOGIC; -- DAC-s chip selects are passed through, ADC-s chip selects are blocked
	  
           comp_busy: out STD_LOGIC; -- is 1 when miltiplexer is not yet ready or in the middle of switching
           err: out STD_LOGIC; -- set to 1 in case of any invalid combinations of input signals, just for routing to some bit of SW status register
			  
           -- [interface to external chips]
           data_out : inout std_logic_vector(15 downto 0); -- ADC/DAC data bus, route out from crystal
			
           nADC_CS0_OUT : out  STD_LOGIC; 
           nADC_CS1_OUT : out  STD_LOGIC;
           nADC_RD0_OUT : out  STD_LOGIC;
           nADC_RD1_OUT : out  STD_LOGIC;
           
           nDAC_WR_OUT : out  STD_LOGIC;
           nBIAS_DAC_CS_OUT : out  STD_LOGIC;
           nCLK_DAC1_CS_OUT : out  STD_LOGIC;
           nCLK_DAC2_CS_OUT : out  STD_LOGIC;
			  			  
           nDAC_RESET_OUT: out STD_LOGIC;
           --BIAS_EN_OUT: out STD_LOGIC;
           --DAC_ADDR_OUT: out STD_LOGIC_VECTOR(3 downto 0);			
			  
           -- [interface to internal logic (ADC/DAC control)]
           data_from_adc : out std_logic_vector(15 downto 0); -- from external ADC chip to our internal logic
           data_to_dac: in std_logic_vector(15 downto 0); -- from internal logic to external DAC chip
			  
           nADC_CS0 : in  STD_LOGIC; 
           nADC_CS1 : in  STD_LOGIC;
           nADC_RD0 : in  STD_LOGIC;
           nADC_RD1 : in  STD_LOGIC;
           
           nDAC_WR : in  STD_LOGIC;
           nBIAS_DAC_CS : in  STD_LOGIC;
           nCLK_DAC1_CS : in  STD_LOGIC;
           nCLK_DAC2_CS : in  STD_LOGIC;
			  			  
           nDAC_RESET: in STD_LOGIC
           --BIAS_EN: in STD_LOGIC;
           --DAC_ADDR: in STD_LOGIC_VECTOR(3 downto 0)
			  
			  
	);
end adc_dac_mux;

architecture Behavioral of adc_dac_mux is

type state_type is (ADC,DAC,BUSY);

signal state : state_type;
signal state_to_go : state_type;

signal data_out_internal : std_logic_vector(data_out'length-1  downto 0); 


signal delay_counter: integer;

begin

	nDAC_RESET_OUT <= nDAC_RESET;
	--BIAS_EN_OUT <= BIAS_EN;
	--DAC_ADDR_OUT <= DAC_ADDR;


	data_out <= data_out_internal;
	data_from_adc <= data_out;

	err <= '0';

async_switch: process(rst, clk)
begin

	if state /= ADC and state /= DAC then
		comp_busy <= '1';
	else
		comp_busy <= '0';
	end if;

   case (state) is 
      when ADC =>        
			data_out_internal <= (others => 'Z');
			nADC_CS0_OUT <= nADC_CS0; 
         nADC_CS1_OUT <= nADC_CS1; 
         nADC_RD0_OUT <= nADC_RD0; 
         nADC_RD1_OUT <= nADC_RD1; 
         nDAC_WR_OUT <= '1'; 
         nBIAS_DAC_CS_OUT <= '1'; 
         nCLK_DAC1_CS_OUT <= '1'; 
         nCLK_DAC2_CS_OUT <= '1';	
			adc_is_active <= '1';
			dac_is_active <= '0';		
      when DAC =>
         data_out_internal <= data_to_dac;
			nADC_CS0_OUT <= '1'; 
         nADC_CS1_OUT <= '1';  
         nADC_RD0_OUT <= '1'; 
         nADC_RD1_OUT <= '1'; 			   
         nDAC_WR_OUT <= nDAC_WR;  -- TODO: avoid possibility simultanious DAC chip select-s
         nBIAS_DAC_CS_OUT <= nBIAS_DAC_CS; 
         nCLK_DAC1_CS_OUT <= nCLK_DAC1_CS; 
         nCLK_DAC2_CS_OUT <= nCLK_DAC2_CS;
			adc_is_active <= '0';
			dac_is_active <= '1'; 			
      when BUSY =>
         data_out_internal <= (others => 'Z');
			nADC_CS0_OUT <= '1'; 
         nADC_CS1_OUT <= '1'; 
         nADC_RD0_OUT <= '1'; 
         nADC_RD1_OUT <= '1'; 
         nDAC_WR_OUT <= '1'; 
         nBIAS_DAC_CS_OUT <= '1'; 
         nCLK_DAC1_CS_OUT <= '1'; 
         nCLK_DAC2_CS_OUT <= '1'; 
			adc_is_active <= '0';
			dac_is_active <= '0';
      when others =>
			data_out_internal <= (others => 'Z');
			nADC_CS0_OUT <= '1'; 
         nADC_CS1_OUT <= '1'; 
         nADC_RD0_OUT <= '1'; 
         nADC_RD1_OUT <= '1'; 
         nDAC_WR_OUT <= '1'; 
         nBIAS_DAC_CS_OUT <= '1'; 
         nCLK_DAC1_CS_OUT <= '1'; 
         nCLK_DAC2_CS_OUT <= '1';
			adc_is_active <= '0';
			dac_is_active <= '0'; 
   end case;

end process;



main: process(rst, clk)
begin

	if rising_edge(clk) then
		if rst = '1' then
			state <= BUSY;
			state_to_go <= ADC;
			delay_counter <= 0;
		else
			case (state) is
				when ADC =>
					if adc_dac_select = '0' then
						state_to_go <= ADC;
						state <= ADC;
					elsif adc_dac_select = '1' then
						state_to_go <= DAC;
						delay_counter <= C_SWITCH_DELAY;
						state <= BUSY;
					end if;
				when DAC =>
					if adc_dac_select = '0' then
						state_to_go <= ADC;
						state <= BUSY;						
					elsif adc_dac_select = '1' then
						state_to_go <= DAC;
						delay_counter <= C_SWITCH_DELAY;
						state <= DAC;
					end if;				
				when BUSY =>
					if delay_counter > 0 then 
						delay_counter <= delay_counter - 1;
					else
						state <= state_to_go;
					end if;
				when others =>
					state <= BUSY;
					state_to_go <= BUSY;
					delay_counter <= C_SWITCH_DELAY;					
			end case;
		
		
		end if;
	end if;



end process;




end Behavioral;

