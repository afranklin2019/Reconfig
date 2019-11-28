

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity delay is
  generic(
	cycles : natural
  );
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    en     : in  std_logic;
    input  : in  std_logic;
    output : out std_logic);
end delay;

architecture BHV of delay is
	--Make array type
	type reg_array is array (0 to cycles-1) of std_logic;
	
	signal reg : reg_array; 
  
begin
	--Sequential Process for count and shifting
	process(clk, rst)
	begin
		if(rst = '1') then
			for i in 0 to cycles-1 loop
				reg(i) <= '0'; --Reset all elements of array 
			end loop;
			
		elsif(rising_edge(clk)) then
			
			if(en = '1') then --Check for case when read and write is in same cycle
				
				reg(0) <= input; --Write new value into array
				
				for i in 0 to cycles-2 loop 
					reg(i+1) <= reg(i); --Shift the entire array
				end loop;
				
			end if;
			
		end if;
		
	end process;


	output <= reg(cycles-1); --Store most recent result into output
  
  
end BHV;

