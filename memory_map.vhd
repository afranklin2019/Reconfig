-- Entity: memory_map
-- This entity establishes connections with user-defined addresses and
-- internal FPGA components (e.g. registers and blockRAMs).
--
-- Note: Make sure to use the addresses in user_pkg. Also, in your C code,
-- make sure to use the same constants.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity memory_map is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        wr_en   : in  std_logic;
        wr_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        wr_data : in  std_logic_vector(MMAP_DATA_RANGE);
        rd_en   : in  std_logic;
        rd_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        rd_data : out std_logic_vector(MMAP_DATA_RANGE);

        -- application-specific I/O
        go     : out std_logic;
        n      : out std_logic_vector(31 downto 0);
        result : in  std_logic_vector(31 downto 0);
        done   : in  std_logic
        );
end memory_map;

architecture BHV of memory_map is
	signal reg : std_logic_vector(MMAP_DATA_RANGE); --Register for Latency
	
begin
	
    -- --Write Operation
	-- process(clk, rst)
	-- begin
		-- if(rst = '1') then
			-- go <= '0';
			-- n  <= std_logic_vector(to_unsigned(0,32));		
		-- elsif(rising_edge(clk)) then
			-- if(wr_en = '1') then --If this is a write
				-- if(wr_addr = C_GO_ADDR) then    -- Check if this is a write to go
					-- go <= wr_data(0);           -- Clear or set go
				-- elsif(wr_addr =  C_N_ADDR) then -- Check if this is a write to n
					-- n <= wr_data;               -- Write to n                  
				-- end if;
			-- end if;
		-- end if;
	-- end process;
	
	 --Write Operation
	process(wr_en, wr_addr, wr_data)
	begin
		if(wr_en = '1') then --If this is a write
			if(wr_addr = std_logic_vector(to_unsigned(C_GO_ADDR, C_MMAP_ADDR_WIDTH) ) ) then    -- Check if this is a write to go
				go <= wr_data(0);           -- Clear or set go
				n  <= std_logic_vector(to_unsigned(0,32));
			elsif(wr_addr = std_logic_vector(to_unsigned (C_N_ADDR, C_MMAP_ADDR_WIDTH) ) ) then -- Check if this is a write to n
				n <= wr_data;               -- Write to n     
				go <= '0';
			else
				go <= '0';
			    n  <= std_logic_vector(to_unsigned(0,32)); 
			end if;
		else
		
		end if;
	end process;
	
	
	
	
	--Read Operation
	process(rd_en, rd_addr)
	begin
		if(rd_en = '1') then
				
					if(rd_addr = std_logic_vector(to_unsigned(C_GO_ADDR, C_MMAP_ADDR_WIDTH) ) ) then    -- Check if this is a read from go
						--Store in register
						if(rst = '1') then
							reg <= std_logic_vector(to_unsigned(0, 32)); --Clear reg
						elsif(rising_edge(clk)) then
							reg <= std_logic_vector(to_unsigned(0, 32)); --Clear reg
							reg(0) <= go; --Delay a cycle (go is only 1 bit)
						end if;
						
							
					elsif(rd_addr = std_logic_vector(to_unsigned(C_N_ADDR, C_MMAP_ADDR_WIDTH) ) ) then -- Check if this is a read from n
						--Store in register
						if(rst = '1') then
							reg <= std_logic_vector(to_unsigned(0, 32)); --Clear reg
						elsif(rising_edge(clk)) then
							reg <= n; --Delay a cycle
						end if;
						
					elsif(rd_addr = std_logic_vector(to_unsigned(C_RESULT_ADDR, C_MMAP_ADDR_WIDTH) ) ) then --  Check if this is a read from result
						--Store in register
						if(rst = '1') then
							reg <= std_logic_vector(to_unsigned(0, 32)); --Clear reg
						elsif(rising_edge(clk)) then
							reg <= result; --Delay a cycle
						end if;
						
					elsif(rd_addr = std_logic_vector(to_unsigned(C_DONE_ADDR, C_MMAP_ADDR_WIDTH) ) ) then    --  Check if this is a read from done
						--Store in register
						if(rst = '1') then
							reg <= std_logic_vector(to_unsigned(0, 32)); --Clear reg
						elsif(rising_edge(clk)) then
							reg <= std_logic_vector(to_unsigned(0, 32)); --Clear reg
							reg(0) <= done; --Delay a cycle  (done is only 1 bit)
						end if;
				
					end if;
					
					rd_data <= reg; --Write to read data after a cycle
				
	    else
			rd_data <= std_logic_vector(to_unsigned(0,C_MMAP_DATA_WIDTH));
		end if;
	end process;

end BHV;
