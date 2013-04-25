-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pulse_gen is
	generic (
		C_FREEZE_OUTPUT_PULSE : boolean := false;  -- freeze active state of
                                                           -- pulse at the pulse end until the next start condition
		C_DUMMY : integer := 0
	);
	Port ( 
	   clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;

           start : in STD_LOGIC;        -- single clock start signal (start condition)
           stop  : in STD_LOGIC;

           delay : in integer;          -- delay to pulse start
           length : in integer;         -- pulse length
           invert : in std_logic;       -- invert pulse

           
           
           pulse : out STD_LOGIC

			  
			  
	);
end pulse_gen;



architecture pulse_gen_behavorial of pulse_gen is

  type state_type is (IDLE,RUNNING);

  signal state : state_type;
  signal cnt : integer;

  signal t_from : integer;
  signal t_to : integer;
  signal internal_pulse : std_logic;
  signal internal_invert : std_logic;
begin




  out_proc:  process (clk)
  begin
    if internal_invert = '0' then 
      pulse <= internal_pulse;
    else
      pulse <= not internal_pulse;
    end if;
  end process out_proc;
  
  main: process(rst,clk)
    begin

      if rising_edge(clk) then
        if rst = '1' then
          state <= IDLE;
          cnt <= 0;
          internal_pulse <= '0';
        else

          case (state) is 
            when IDLE =>
              cnt <= 0;
              if not C_FREEZE_OUTPUT_PULSE then
                internal_pulse <= '0';
              end if;
            when RUNNING =>
              cnt <= cnt + 1;
              internal_pulse <= '1';
              if cnt < t_from then                
                internal_pulse <= '0';
              elsif cnt > t_to then
                state <= IDLE;
                if not C_FREEZE_OUTPUT_PULSE then
                  internal_pulse <= '0';
                end if;
              else
                internal_pulse <= '1';  
              end if;              
            when others => null;
          end case;


          if stop = '1' then
            state <= IDLE;
            cnt <= 0;
          end if;
          
          if start = '1' then
            state <= RUNNING;
            cnt <= 0;
            t_from <= delay;
            t_to <= delay + length;
            internal_invert <= invert;
          end if;
          
          
        end if;
      end if;

    end process;

end pulse_gen_behavorial;
