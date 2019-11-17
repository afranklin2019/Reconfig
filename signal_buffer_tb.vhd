
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity signal_buffer_tb is
end signal_buffer_tb;

architecture Behavioral of signal_buffer_tb is
	

	
	--Declare signals for testing
	
	signal clk : std_logic := '0'; --Initialize clk to zero
	signal rst : std_logic := '1'; --Set reset
	signal rd_en  : std_logic := '0'; --Disable read
	signal wr_en  : std_logic := '0'; --Disable write
	signal empty, full : std_logic;
	
	signal input : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(0,16));
	signal output : std_logic_vector(128*16-1 downto 0);

begin
	
	--Instatiate entity
	
	UUT : entity work.signal_buffer
		port map (
			clk => clk,
			rst => rst,
			rd_en => rd_en,
			wr_en => wr_en,
			input => input,
			full => full,
			empty => empty,
			output => output
			);
			
	--Toggle clock
	clk <= not clk after 5 ns;
	
	process
	
	begin
	
	rst <= '1';
	rd_en <= '0';
	wr_en <= '0';
	
	input <= std_logic_vector(to_unsigned(1,16));
	
	wait until clk'event and clk = '1';
	
	rst <= '0';
	
	wr_en <= '1';
	
	for i in 0 to 127 loop
		input <= std_logic_vector(to_unsigned(i+1,16)); --Write in 128 new values
		wait until clk'event and clk = '1';
	end loop;
	
	wr_en <= '0';
	
	rd_en <= '1';
	
	wait until clk'event and clk = '1';
	
	wr_en <= '1';
	rd_en <= '0';
	
	for i in 200 to 250 loop
		input <= std_logic_vector(to_unsigned(i+1,16)); --Write in 128 new values
		wait until clk'event and clk = '1';
	end loop;
		
	
	wait;
	end process;


end Behavioral;
