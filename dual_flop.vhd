library ieee;
use ieee.std_logic_1164.all;

entity dual_flop is
    port(
            clk_src     : in std_logic;
            clk_dest    : in std_logic;
            input       : in std_logic;
            output      : out std_logic;
            rst_src     : in std_logic;
            rst_dest    : in std_logic           
        );
        
end dual_flop;

architecture BHV of dual_flop is

    signal src_ff_out : std_logic;
    signal dest_ff_out: std_logic;
    
 begin
 
    process(clk_src, rst_src)
    begin
        if(rst_src = '1') then
            src_ff_out <= '0' ;
        elsif(rising_edge(clk_src)) then
            src_ff_out <= input;
        end if;
    end process;
    
    process(clk_dest, rst_dest)
    begin
        if(rst_dest = '1') then
            dest_ff_out <= '0';
            output      <= '0';
        elsif(rising_edge(clk_dest)) then
           dest_ff_out  <= src_ff_out;
           output       <= dest_ff_out;
        end if;
    end process;
    
end BHV;
            