library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity controller_tb is
end controller_tb;

architecture TB of controller_tb is

    constant SIZE   : integer := 8;
    
    signal clk, rst : std_logic := '0';
    
    signal done            : std_logic := '0';
    signal done_controller : std_logic := '0'; 
    signal go              : std_logic := '0'; 
    
    signal addrGenIn_go    : std_logic := '0';
    signal addrGenOut_go   : std_logic := '0';
    signal addrGenIn_done  : std_logic := '0';
    signal addrGenOut_done : std_logic := '0';
    
    signal size_in         : std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal size_out        : std_logic_vector(C_MEM_ADDR_WIDTH-1 downto 0) := (others => '0');
    
begin

    U_CONTROLLER : entity work.controller
        port map(
                clk             => clk,
                rst             => rst,
                done            => done_controller,
                go              => go,
                addrGenIn_go    => addrGenIn_go,
                addrGenOut_go   => addrGenOut_go,
                addrGenIn_done  => addrGenIn_done,
                addrGenOut_done => addrGenOut_done,
                size_in         => size_in,
                size_out        => size_out);
                 
clk <= not clk after 10 ns when done = '0' else clk; 


process
    begin
        -- Assert reset for 4 clock cycles 
        rst <= '1';
        for i in 0 to 3 loop
            wait until rising_edge(clk);
        end loop;

        rst <= '0';
        wait until rising_edge(clk);
        
        -- Send size to controller
        
            size_in <= std_logic_vector(to_unsigned(SIZE, C_MEM_ADDR_WIDTH));
            go <= '1';
            wait until rising_edge(clk);
            go <= '0';

            -- Wait for 4 cycles
            for i in 0 to 3 loop
                wait until rising_edge(clk);
            end loop;
            
            -- Tell controller that input address generator is done
            addrGenIn_done <= '1';
            
            for i in 0 to 3 loop
                wait until rising_edge(clk);
            end loop;
            
             -- Tell controller that output address generator is done
            addrGenOut_done<= '1';
            
            
            wait until done_controller = '1';
            
            -- Wait 4 cycles to check done remains asserted
            for i in 0 to 7 loop
            wait until rising_edge(clk);
        end loop;
                       
        

        -- wait until done is asserted
    report "SIMULATION COMPLETE!!!!";
    done <= '1';
    wait;
               
    end process;
    
    
    
end TB;                              