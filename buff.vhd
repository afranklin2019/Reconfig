library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buff is 
    port( clk   : in  std_logic;
          rst   : in  std_logic;
          wr_en : in  std_logic;
          rd_en : in  std_logic;
          full  : out std_logic;
          empty : out std_logic;
          input : in  std_logic_vector(15 downto 0);
          output: out std_logic_vector((128 * 16)-1 downto 0));
end buff;

architecture BHV of buff is 

    -- Each element of the array represents a register 
    type reg_array is array (0 to 127) of std_logic_vector(15 downto 0);
    signal regs : reg_array;
    
    -- Counter to keep track of how many elements in buffer
    signal count : unsigned(7 downto 0);
        
begin

    process(clk, rst)
    begin
        if(rst = '1') then
            -- Initialize all 128 registers
            for i in 0 to 127 loop
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
                for i in 0 to 126 loop
                    regs(i+1) <= regs(i);
                    
                end loop;
				
				--Preserve count
			   
            
			elsif(wr_en = '1') then --Just a write
				-- Write new element to buffer
                regs(0) <= input;
                
                -- Shift buffer contents left by 1
                for i in 0 to 126 loop
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
    
    process(count, rd_en)
    begin
        -- In order to write a new value into buffer in the same cycle in which it is being read, 
        -- only set full flag when count reaches 128 and output of buffer is not being read.
        -- If output is being read then this implies there is space available in the buffer as the
        -- left most element of the buffer is no longer needed. Buffer is never full if it is being
        -- read from. 
        
        -- Assignment of default values
        full  <= '0';
        empty <= '1';
        
        if(count = 128 AND rd_en = '0') then 
            full  <= '1';
            empty <= '0';
        end if;
        
    end process;
    
    -- Vectorize entirety of output of buffer. Place left most register in most significant
    -- 16 bits of vector, and right most register in least significant 16 bits of vector 
        U_VECTORIZE : for i in 0 to 127 generate
        output((i * 16) + 15 downto (i * 16)) <= regs(i);
    end generate U_VECTORIZE;
    
    
end BHV;   


            
           
                
          
            
      
        
          
          
            
            