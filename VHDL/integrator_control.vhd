-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity integrator_control is
	Port ( 
	   clk : in std_logic;
           rst : in std_logic;

           start : in std_logic;        -- single clock start signal (start condition)
           stop  : in std_logic;

           -- output pulses' parameters
           delay_ipc : in integer;
           length_ipc : in integer;
           invert_ipc : in std_logic;

           delay_FRST : in integer;
           length_FRST : in integer;
           invert_FRST : in std_logic;

           delay_FINT_plus : in integer;
           length_FINT_plus : in integer;
           invert_FINT_plus : in std_logic;

           delay_FINT_minus : in integer;
           length_FINT_minus : in integer;
           invert_FINT_minus : in std_logic;
           
           -- output pulses
           ipc : out STD_LOGIC;
           FRST : out STD_LOGIC;
           FINT_plus : out STD_LOGIC;
           FINT_minus : out STD_LOGIC

			  
			  
	);
end integrator_control;


architecture integrator_control_behavorial of integrator_control is


component pulse_gen is
	generic (
		C_FREEZE_OUTPUT_PULSE : boolean := false;  -- freeze active state of
                                                           -- pulse at the pulse end until the next start condition
		C_DUMMY : integer := 0
	);
	port ( 
	   clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;

           start : in STD_LOGIC;        -- single clock start signal (start condition)
           stop  : in STD_LOGIC;

           delay : in integer;          -- delay to pulse start
           length : in integer;         -- pulse length
           invert : in std_logic;       -- invert pulse

           
           
           pulse : out STD_LOGIC

			  
			  
	);
end component;
  
begin



  ipc_g : pulse_gen PORT MAP(
    clk => clk,
    rst => rst,

    start => start,
    stop => stop,
    
    delay => delay_ipc,
    length => length_ipc,
    invert => invert_ipc,
    
    pulse => ipc
    );


  FRST_G : pulse_gen PORT MAP(
    clk => clk,
    rst => rst,

    start => start,
    stop => stop,    
    
    delay => delay_FRST,
    length => length_FRST,
    invert => invert_FRST,
    
    pulse => FRST
    );


  FINT_plus_g : pulse_gen PORT MAP(
    clk => clk,
    rst => rst,

    start => start,
    stop => stop,
    
    delay => delay_FINT_plus,
    length => length_FINT_plus,
    invert => invert_FINT_plus,
    
    pulse => FINT_plus
    );


  FINT_minus_g : pulse_gen PORT MAP(
    clk => clk,
    rst => rst,

    start => start,
    stop => stop,
    
    delay => delay_FINT_minus,
    length => length_FINT_minus,
    invert => invert_FINT_minus,
    
    pulse => FINT_minus
    );  


end integrator_control_behavorial;
  
