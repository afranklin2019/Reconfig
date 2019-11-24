library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buffer_tb is 
end buffer_tb;

architecture TB of buffer_tb is 

        signal clk	:      std_logic := '0';
        signal rst	:      std_logic := '1';
        signal wr_en	:    std_logic := '0';
        signal rd_en	:    std_logic := '0';
        signal full	:     std_logic := '0';
        signal empty	:    std_logic := '0';
        
        signal input	:    std_logic_vector(15 downto 0) := (others => '0');
        signal output   :    std_logic_vector((128 * 16) - 1 downto 0 );
        
        signal word     :   std_logic_vector(15 downto 0) := (others => '0');
        
begin 

    UUT : entity work.buff
        port map (
                  clk   => clk,
                  rst   => rst,
                  wr_en => wr_en,
                  rd_en => rd_en,
                  full  => full,
                  empty => empty,
                  input => input,
                  output=> output);
                  
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
        
        -- Begin testing buffer functionality. Write 128 16-bit elements to buffer
        wr_en <= '1';
        
        for i in 0 to 127 loop
            input <= std_logic_vector(to_unsigned(i, 16));
            wait until rising_edge(clk);
        end loop;
        
        -- Full signal should be asserted at this point 

            wr_en <= '0';
            
            wait until rising_edge(clk);
            
        -- Begin reading from buffer. Empty flag should remain 1 for as long as buffer is being read
            rd_en <= '1';
            
        
            
        -- Check output vector is correct for reading each 16-bit word from LSW to MSW
        for i in 0 to 127 loop
            word <= output((i*16) + 15 downto (i * 16));
            assert(output((i*16) + 15 downto (i * 16))) = std_logic_vector(to_unsigned(127-i, 16)) report "Incorrect output";
            wait until rising_edge(clk);
        end loop;
        
        rd_en <= '0';
        
        report "Test bench complete!!!!";
        
        wait;
        
    
    end process;
end TB;
        
        
        
        
            
            
            
        
    
        