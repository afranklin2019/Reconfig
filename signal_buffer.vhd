

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;



entity signal_buffer is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    rd_en  : in  std_logic;
	wr_en  : in  std_logic;
    input  : in  std_logic_vector(15 downto 0);
	full   : out std_logic;
	empty  : out std_logic;
    output : out std_logic_vector( 128*16-1 downto 0));
end signal_buffer;

architecture BHV of signal_buffer is
	--Make array type
	type buffer_array is array (0 to 127) of std_logic_vector(15 downto 0);
	
	signal sb : buffer_array; --Make array called sb
	
	signal count : unsigned(130 downto 0); --Make array called sb
  
begin
	--Sequential Process for count and shifting
	process(clk, rst)
	begin
		if(rst = '1') then
			for i in 0 to 127 loop
				sb(i) <= std_logic_vector(to_unsigned(0, 16)); --Reset all elements of array 
			end loop;
			
			count <= to_unsigned(0, 131);
			
		elsif(rising_edge(clk)) then
			if(wr_en = '1') then --If this is a write operation
			
				sb(0) <= input; --Write new value into buffer
			
				for i in 0 to 126 loop 
					sb(i+1) <= sb(i); --Shift the entire array
				end loop;
			
				count <= count + to_unsigned(1, 131); --Increment count
			end if;
		
			if(rd_en = '1') then --If this is a read
			
				count <= count - to_unsigned(1, 131); --Decrement count
			
			end if;
			
		end if;
		
	end process;

	--Combinational Logic for Full and Empty
	process(rd_en, count)
	begin
		if((count = 128) AND (rd_en = '0')) then
			full <= '1';  --Full if max count is reached and there is no read 
		else
			full <= '0';  --Not full
		end if;
	end process;
	
	process(count)
	begin
		if(count = 128) then
			empty <= '0'; --Not empty only when max count is reached
		else
			empty <= '1'; --Empty when count is not 128
		end if;
	end process;
		
  
  output(15 downto 0) <= sb(0);        --Vectorize first element
  output(2047 downto 2032) <= sb(127); --Vectorize last element
  
	U_OUTPUT : for i in 1 to 126 generate
		output((i+1)*16 - 1  downto (i*16) ) <= sb(i);
    end generate;
  
  
end BHV;

