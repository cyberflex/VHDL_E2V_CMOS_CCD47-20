-- Author: Andrew Mityagin <andrew_mit@mail.ru>
-- Author: Alexandre Rusev <cyberflex@mail.ru>
-- Author: Anton Pischulin <letanton@mail.ru>
-- Author: Vyacheslav Frolov <frolov_12@yahoo.com>


-- converts "level triggered interrupt" to "edge triggered interrupt"

library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;





entity single_pulse is
port(
  clk: in std_logic;
  rst: in std_logic;
  input: in std_logic;
  output: out std_logic
);
end single_pulse;

architecture Behavioral of single_pulse is

signal inpiutDelayed : std_logic;

begin


main_proc: process(clk,rst,input, inpiutDelayed)
 begin
   if clk'event and clk = '1' then

     if rst = '1' then
       inpiutDelayed <= '0';
     else
       inpiutDelayed <= input;
     end if;
   end if;
 
end process main_proc;


output  <=  input and (not inpiutDelayed);


end Behavioral;
