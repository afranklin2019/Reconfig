
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity addr_gen is
	generic (
		width  : positive;
		in_out : std_logic
	);
	port(
	clk, rst, go              : in std_logic;
	en  	                  : in std_logic;
	size                      : in std_logic_vector(width-1 downto 0);
	valid_in                  : out std_logic;
	addr                      : out std_logic_vector(width-1 downto 0);
	done                      : out std_logic);
end addr_gen;

architecture Behavioral of addr_gen is

	type STATE_TYPE is (S_START,  S_SIZE, S_COUNT, S_DONE, S_WAIT_FOR_GO_TO_CLEAR);
	
	signal state, next_state : STATE_TYPE;  --Declare state
	
	signal count : std_logic_vector(width-1 downto 0);
	
	signal size_reg : std_logic_vector(width-1 downto 0);

	begin
	
	process(clk, rst)
	begin	
	if(rst = '1') then
		state <= S_START; --Go back to first state on reset
		count <= std_logic_vector(to_unsigned(0, width));
		size_reg <= std_logic_vector(to_unsigned(0, width));
		
	elsif(rising_edge(clk)) then
		
		state <= next_state;   --Move to next state
		
		--Count up
		
		--Count up for input addr gen
		if(in_out = '0') then --If input addr gen
			if(state = S_COUNT and next_state = S_COUNT) then
				count <= std_logic_vector(unsigned(count) + to_unsigned(1, width)); --Increment count
			end if;
		--Count up for output addr gen
		elsif(in_out = '1') then	 --If output addr gen
			if(en = '1' and state = S_COUNT and next_state = S_COUNT ) then
				count <= std_logic_vector(unsigned(count) + to_unsigned(1, width)); --Increment count
			end if;
		end if;
		
		--Load size
		if(state = S_SIZE) then
			size_reg <= size;
		end if;
		
		--Reset count
		if(next_state = S_DONE) then
			count <= std_logic_vector(to_unsigned(0, width)); --Reset count when limit is reached
		end if;
		
	end if;
	
	end process;
	
	process(go, state, en, count)
	
	begin
		--Default values
		valid_in <= '0';
		-- addr <= count; --Update address	
		done <= '0';
	
		case state is 
			when S_START =>
				
				if(go = '1') then
					next_state <= S_SIZE;
				else
					next_state <= S_START; 
				end if;
				
				
			when S_SIZE =>
				next_state <= S_COUNT;
				
			when S_COUNT =>
				--Check if limit is reached
				if(unsigned(count) = unsigned(size_reg)) then
					next_state <= S_DONE;
					-- done <= '1'; --Assert Done
				elsif(in_out <= '0') then
					valid_in <= '1';       --Send valid input signal
					next_state <= S_COUNT; --Go back to this state
				elsif(in_out <= '1' and en = '1') then --If this is the output addr gen and it is enabled
					valid_in <= '1';                 --Send valid input signal
					next_state <= S_COUNT; --Go back to this state
				else   --Stall
					next_state <= S_COUNT;
				end if;
			
			when S_DONE =>
				done <= '1';
				next_state <= S_WAIT_FOR_GO_TO_CLEAR;
			
			when S_WAIT_FOR_GO_TO_CLEAR =>
				done <= '1';
				
				--Wait for go to clear
				if(go = '0') then
					next_state <= S_START;
				else 
					next_state <= S_WAIT_FOR_GO_TO_CLEAR;  
				end if;
				
				
			end case;
		end process;
				
addr <= count; --Update address		


end Behavioral;
