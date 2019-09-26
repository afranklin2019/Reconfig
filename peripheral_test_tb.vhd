-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity peripheral_test_tb is
end peripheral_test_tb;


architecture TB of peripheral_test_tb is

	constant WIDTH : positive := 4;  --Declare width
	
	
	signal in0, in1, in2, in3 : std_logic_vector(WIDTH-1 downto 0);
	signal out0, out1, out2, out3 : std_logic_vector(WIDTH-1 downto 0);
	
	
begin --TB

	U_PERIPH: entity work.peripheral_test
		generic map (
		width => WIDTH)
		port map (
			in0 => in0,
			in1 => in1,
			in2 => in2,
			in3 => in3,
			out0 => out0,
			out1 => out1,
			out2 => out2,
			out3 => out3
			);
		
	
	process
	begin
	
	in0 <= std_logic_vector(to_unsigned(8, WIDTH)); 
	wait;
	in1 <= std_logic_vector(to_unsigned(8, WIDTH)); 
	wait;
	in2 <= std_logic_vector(to_unsigned(8, WIDTH)); 
	wait;
	in3 <= std_logic_vector(to_unsigned(8, WIDTH)); 
	
	wait;
	
	
	in0 <= std_logic_vector(to_unsigned(1, WIDTH)); 
	wait;
	in1 <= std_logic_vector(to_unsigned(1, WIDTH)); 
	wait;
	in2 <= std_logic_vector(to_unsigned(8, WIDTH)); 
	wait;
	in3 <= std_logic_vector(to_unsigned(8, WIDTH)); 
	wait;
	
	-- for i in 0 to 15  loop
		-- in0 <= std_logic_vector(to_unsigned(i, WIDTH)); 
		-- wait;
		
		-- for j in 0 to 15 loop
			-- in1 <= std_logic_vector(to_unsigned(i, WIDTH)); 
		-- wait;
		
			-- for j in 0 to 15 loop
			-- in2 <= std_logic_vector(to_unsigned(i, WIDTH)); 
		    -- wait;
			
				-- for j in 0 to 15 loop
				-- in2 <= std_logic_vector(to_unsigned(i, WIDTH)); 
				-- wait;
				-- end loop;
		   
			-- end loop;
		
			
		-- end loop;
			
			
	-- end loop;
	
	
	
	
	end process;
end TB;