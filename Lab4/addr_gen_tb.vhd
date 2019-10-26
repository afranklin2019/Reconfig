-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addr_gen_tb is
end addr_gen_tb;


architecture TB of addr_gen_tb is

	constant WIDTH : positive := 8;  --Declare width
	
	
	signal clk, rst, go, en : std_logic := '0';
	
	signal valid_in : std_logic := '0';
	
	signal size, addr : std_logic_vector(WIDTH-1 downto 0);
	
	signal done : std_logic;
	
	
begin --TB

	UUT: entity work.addr_gen
		generic map (
		width => WIDTH,
		in_out => '1')
		port map (
			clk => clk,
			rst => rst,
			go  => go,
			
			en => en,
			size => size,
			valid_in => valid_in,
			addr => addr,
		
		
			done => done);
			
	clk <= not clk after 10 ns;
	
	process
	begin
	
	rst <= '1'; --Reset
	go <= '0';  --Set go as zero
	
	wait until clk'event and clk = '1';
	
	rst <= '0';
	
	size <= std_logic_vector(to_unsigned(10,WIDTH));
	
	en <= '1';
	
	go <= '1';
	
	for i in 0 to 10 loop
		wait until clk'event and clk = '1';
	end loop;
	
	go <= '0';
	wait until clk'event and clk = '1';
	
	go <= '1';
	
	size <= std_logic_vector(to_unsigned(5,WIDTH));
	
	for i in 0 to 1 loop
		wait until clk'event and clk = '1';
	end loop;
	
	en <= '0';
	
	for i in 0 to 10 loop
		wait until clk'event and clk = '1';
	end loop;
	
	go <= '1';
	
	for i in 0 to 3 loop
		wait until clk'event and clk = '1';
	end loop;
	
	go <= '0';
	
	en <= '1';
	
	wait until clk'event and clk = '1';
	
	go <= '1';
	
	for i in 0 to 3 loop
		wait until clk'event and clk = '1';
	end loop;
	
	en <= '0';
	
	for i in 0 to 9 loop
		wait until clk'event and clk = '1';
	end loop;
	
	en <= '1';
	
	for i in 0 to 9 loop
		wait until clk'event and clk = '1';
	end loop;
	
	
	
	
	
	
	

	
	wait;
	end process;
end TB;