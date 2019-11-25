library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;

entity dma_counter_tb is
end dma_counter_tb;

architecture TB of dma_counter_tb is

    signal clk          : std_logic := '0';
    signal rst          : std_logic := '1';
    signal fifo_rd_en   : std_logic := '1';
    signal fifo_valid   : std_logic := '1';
    signal done         : std_logic;
    signal size         : std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0) := (others => '0');
    
begin

    UUT : entity work.dma_counter
        port map (
                  clk        =>  clk,
                  rst        => rst,
                  fifo_rd_en => fifo_rd_en,
                  fifo_valid => fifo_valid,
                  done       => done,
                  size       => size);
                  
    -- Toggle clock 
    clk <= NOT clk after 5ns;
    
    process
    begin
        -- Leave reset asserted for 4 clock cycles 
        rst <= '1';
        size<= std_logic_vector(to_unsigned(32, C_DRAM0_SIZE_WIDTH+1));
        for i in 0 to 3 loop
            wait until rising_edge(clk);
        end loop;
        
        rst <= '0';
        
        wait until rising_edge(clk);
        
        -- Allow counter to count to size - 1

        wait until done = '1';
        
        fifo_rd_en <= '0';
        
        wait;
        
    end process;
    
end TB;
        