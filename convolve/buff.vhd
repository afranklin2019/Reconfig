library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buff is 
    generic
		(size : positive);
	port( clk   : in  std_logic;
          rst   : in  std_logic;
          wr_en : in  std_logic;
          rd_en : in  std_logic;
          full  : out std_logic;
          empty : out std_logic;
          input : in  std_logic_vector(15 downto 0);
          output: out std_logic_vector((size * 16)-1 downto 0));
end buff;

architecture BHV of buff is 

    -- Each element of the array represents a register 
    type reg_array is array (0 to size-1) of std_logic_vector(15 downto 0);
    signal regs : reg_array;
    
    -- Counter to keep track of how many elements in buffer
    signal count : unsigned(7 downto 0);
        
begin

    process(clk, rst)
    begin
        if(rst = '1') then
            -- Initialize all 128 registers
            for i in 0 to size-1 loop
                regs(i) <= (others => '0');
            end loop;
           
            -- Reset counter
            count <= (others => '0');
                
        elsif (rising_edge(clk)) then
            -- Registers created by assigning on rising clock edge 
            if(wr_en = '1' AND (rd_en = '1')) then  --Write and a read
                -- Write new element to buffer
                regs(0) <= input;
                
                -- Shift buffer contents left by 1
                for i in 0 to size-2 loop
                    regs(i+1) <= regs(i);
                    
                end loop;
				
				--Preserve count
			   
            
			elsif(wr_en = '1') then --Just a write
				-- Write new element to buffer
                regs(0) <= input;
                
                -- Shift buffer contents left by 1
                for i in 0 to size-2 loop
                    regs(i+1) <= regs(i);
                    
                end loop;
				
			  -- Increment count
                count <= count + 1;
				
            elsif(rd_en = '1') then
            -- If data being read from buffer then decrement count to signify new slot available 
                count <= count - 1;
            end if;
			
        end if;
    end process;
    
   
	
		--Combinational Logic for Full and Empty
	process(rd_en, count)
	begin
		if((count = size) AND (rd_en = '0')) then
			full <= '1';  --Full if max count is reached and there is no read 
		else
			full <= '0';  --Not full
		end if;
	end process;
	
	process(count)
	begin
		if(count = size) then
			empty <= '0'; --Not empty only when max count is reached
		else
			empty <= '1'; --Empty when count is not 128
		end if;
	end process;
    
    -- Vectorize entirety of output of buffer. Place left most register in most significant
    -- 16 bits of vector, and right most register in least significant 16 bits of vector 
        U_VECTORIZE : for i in 0 to size-1 generate
        output((i * 16) + 15 downto (i * 16)) <= regs(i);
    end generate U_VECTORIZE;
    
    
end BHV;   


            
           
                
          
            
      
        
          
          
            
            