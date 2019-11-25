library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity addr_gen_tb is
end addr_gen_tb;

architecture TB of addr_gen_tb is

    signal clk : std_logic := '0';
    signal go  : std_logic := '0';
    signal rst : std_logic := '1';
    
    signal rd_addr : std_logic_vector(DRAM0_ADDR_RANGE);
    signal rd_en   : std_logic;
    signal dram_rdy: std_logic := '1';
    
    signal fifo_almost_full : std_logic := '0';
    
    signal size         :    std_logic_vector(RAM0_RD_SIZE_RANGE) := (others => '0');
    signal start_addr   :    std_logic_vector(RAM0_ADDR_RANGE) := std_logic_vector(to_unsigned(8, C_DRAM0_ADDR_WIDTH));
    
    
begin

    UUT : entity work.addr_gen
        port map (
                    clk              => clk,
                    rst              => rst,
                    go               => go,
                    size             => size,
                    start_addr       => start_addr,
                    rd_addr          => rd_addr,
                    rd_en            => rd_en,
                    dram_rdy         => dram_rdy,
                    stall => fifo_almost_full);
                    
    -- Toggle clock 
    clk <= NOT clk after 5ns;
    
    process
    begin
        -- Leave reset asserted for 4 clock cycles 
        rst <= '1';
        for i in 0 to 3 loop
            wait until rising_edge(clk);
        end loop;
        
        rst <= '0';
        
        wait until rising_edge(clk);
        
        -- Begin testing address generator funtionality
        -- Start address generator and assert dram_rdy signal
        go       <= '1';
        size     <= std_logic_vector(to_unsigned(32, C_DRAM0_SIZE_WIDTH+1));
        
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        fifo_almost_full <= '1';
        dram_rdy         <= '0';
        
        wait until rising_edge(clk);
        
        fifo_almost_full <= '0';
        dram_rdy         <= '1';
        go               <= '0';
        
        for i in 0 to 10 loop
            wait until rising_edge(clk);
        end loop;
        
        go               <= '1';
        size     <= std_logic_vector(to_unsigned(64, C_DRAM0_SIZE_WIDTH+1));
        
        
        wait;
        
        
        
        
        
        
        
   

        
    end process;

end TB;
        
        
        
                    
                    
                    
                    
    