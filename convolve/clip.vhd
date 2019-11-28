

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity clip is
  generic(
	input_width : positive);
  port (
    input : in std_logic_vector(input_width-1 downto 0);
	output : out std_logic_vector(15 downto 0)
	);
end clip;

architecture BHV of clip is
	
  
begin
	process(input)
	begin
		if(unsigned(input) >= 65536) then
			output <= std_logic_vector(to_unsigned(65535, 16)); --Make 16-bit all 1'select
		else
			output <= input(15 downto 0); --Output 16 bits of original value
		end if;
		
	end process;

  
end BHV;

