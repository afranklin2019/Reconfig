library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity addr_gen is
    port (
          clk               : in    std_logic;
          rst               : in    std_logic;
          go                : in    std_logic;
          size              : in    std_logic_vector(RAM0_RD_SIZE_RANGE);-- Corresponds to number of 16-bit words requested from memory  
          start_addr        : in    std_logic_vector(RAM0_ADDR_RANGE);   -- Corresponds to a 32-bit address from which to begin fetching from memory
          rd_addr           : out   std_logic_vector(DRAM0_ADDR_RANGE);  -- Current address from which to read from memory
          rd_en             : out   std_logic;                           -- Asserted when a valid address is present on rd_addr
          dram_rdy          : in    std_logic;                           -- Address generation will stall when this signal is cleared
          stall             : in    std_logic);                          -- Asserted when FIFO is almost full. Should stall address generation to avoid
                                                                         -- loosing data from FIFO
end addr_gen;

architecture BHV of addr_gen is

    type STATE_TYPE is (S_WAIT_GO_ASSERT, S_INIT, S_COUNT, S_DONE, S_WAIT_GO_UNASSERT);
    
    signal state, next_state : STATE_TYPE; -- Address generator to be implemented as a 2-process FSM

    signal count    : unsigned(DRAM0_ADDR_RANGE);    
    signal size_reg : std_logic_vector(RAM0_RD_SIZE_RANGE);
    
    -- count holds current address 
      
begin

    -- Sequential process
    process(clk, rst)
    begin
        if(rst = '1') then
            state    <= S_WAIT_GO_ASSERT; -- Set initial state 
            count    <= (others => '0');
            size_reg <= (others => '0');
            
        elsif(rising_edge(clk)) then
            
            state <= next_state;        -- State will become next_state on next clock cycle
           
            -- Initialize size_reg and start addr of counter
            if(state = S_INIT) then
                size_reg <= std_logic_vector(shift_right(unsigned(size),1));
                count <= unsigned(start_addr);
            end if;
           
            -- Determine if addresses should be generated. Address generator will stall if either dram_rdy or stall are asserted
            if(state = S_COUNT AND dram_rdy = '1' AND stall = '0') then
                count <= count + 1;
            end if;
            
            --Reset counter
            if(next_state = S_DONE) then
                count <= (others => '0'); --Reset count when limit is reached
            end if;
            
        end if;
        
    end process;
    
    -- Combinational process for next state logic and outputs 
    process(state, go, count, dram_rdy, stall, start_addr)
    begin
    
    -- Assignment of default values 
    next_state <= state;
    rd_en      <= '0';
    
        case state is
            when S_WAIT_GO_ASSERT =>
                
                if(go = '1') then
                    next_state <= S_INIT;
                else
                    next_state <= S_WAIT_GO_ASSERT;
                end if;
                    
            when  S_INIT =>

                next_state <= S_COUNT;
                    
            when S_COUNT =>
            
                if(count = unsigned(start_addr) + unsigned(size_reg) - 1) then
                    next_state <= S_DONE;
					rd_en <= '1';
                elsif(dram_rdy = '0' OR stall = '1') then
                    next_state <= S_COUNT;
                    rd_en <= '0';  
                else
                    next_state <= S_COUNT;
                    rd_en <= '1';
                end if;
                
            when S_DONE =>
            
                --Wait for go to clear
				if(go = '0') then
					next_state <= S_WAIT_GO_ASSERT;
				else 
					next_state <= S_WAIT_GO_UNASSERT;  
				end if;
			 
			when others => null;
            
        end case;
        
    end process;
    
    rd_addr <= std_logic_vector(count); 

end BHV;                
            
            
            
            
            
            
            
            
