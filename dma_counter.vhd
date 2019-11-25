library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity dma_counter is 
    port (
          clk           : in    std_logic;
          rst           : in    std_logic;
          fifo_rd_en    : in    std_logic;
          fifo_valid    : in    std_logic;
          done          : out   std_logic;
          size          : in    std_logic_vector(RAM0_RD_SIZE_RANGE));
          
end dma_counter;

architecture BHV of dma_counter is

    signal count :     unsigned(RAM0_ADDR_RANGE);
    signal size_reg :  unsigned(RAM0_RD_SIZE_RANGE);
    
begin

    process(clk, rst)
    begin
        
        if(rst = '1') then
            count       <= (others => '0');
            size_reg    <= unsigned(size);
       
       elsif(rising_edge(clk)) then
            
            -- Update count if fifo_rd_en and fifo_valid are asserted. This implies data has been read from the FIFO
            if(fifo_rd_en = '1' AND fifo_valid = '1') then
                count <= count + 1;
            end if;
            
        end if;
        
    end process;
    
    process(count, size_reg)
    begin
    
        done <= '0';
    
        -- Check if count is equal to size - 1. This indicates that all requested data has been read from the FIFO
            if(count = size_reg - 1) then
                done <= '1';
                
            end if;
            
    end process;
    
end BHV;
            
             
            
           
            
            
          
          