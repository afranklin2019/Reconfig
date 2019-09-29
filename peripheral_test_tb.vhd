-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity peripheral_test_tb is
end peripheral_test_tb;


architecture TB of peripheral_test_tb is

	component peripheral_test
		generic (
			width : positive := 8);
		port (
        in0  : in  std_logic_vector(width-1 downto 0);
        in1  : in  std_logic_vector(width-1 downto 0);
        in2  : in  std_logic_vector(width-1 downto 0);
        in3  : in  std_logic_vector(width-1 downto 0);
        out0 : out std_logic_vector(width-1 downto 0);
        out1 : out std_logic_vector(width-1 downto 0);
        out2 : out std_logic_vector(width-1 downto 0);
        out3 : out std_logic_vector(width-1 downto 0));
		
	end component;	
	
	
	constant WIDTH : positive := 4;  --Declare width
	
	
	signal in0, in1, in2, in3 : std_logic_vector(WIDTH-1 downto 0) := std_logic_vector(to_unsigned(0, WIDTH));
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
	
	
	
	for i in 0 to 15  loop
		in0 <= std_logic_vector(to_unsigned(i, WIDTH)); 
		wait for 10 ns;
		
		for j in 0 to 15 loop
			in1 <= std_logic_vector(to_unsigned(j, WIDTH)); 
		wait for 10 ns;
		
			for k in 0 to 15 loop
			in2 <= std_logic_vector(to_unsigned(k, WIDTH)); 
			
		    wait for 10 ns;
			
				for l in 0 to 15 loop
				in3 <= std_logic_vector(to_unsigned(l, WIDTH)); 
				wait for 10 ns;
				end loop;
		   
			end loop;
		
			
		end loop;
			
			
	end loop;
	
	wait;
	
	
	end process;
end TB;
