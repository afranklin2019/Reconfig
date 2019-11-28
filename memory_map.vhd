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
	
	signal reg    : std_logic_vector(MMAP_DATA_RANGE); -- Register for Latency
	signal go_reg : std_logic;                         -- Register for Latency
	signal n_reg  : std_logic_vector(MMAP_DATA_RANGE); -- Register for Latency
	
begin
	
    --Write Operation
	process(clk, rst)
	begin
		if(rst = '1') then
			go_reg <= '0';
			n_reg  <= std_logic_vector(to_unsigned(0,32));		
		elsif(rising_edge(clk)) then
			if(wr_en = '1') then --If this is a write
				if(wr_addr = std_logic_vector(to_unsigned(C_GO_ADDR, C_MMAP_ADDR_WIDTH) )) then    -- Check if this is a write to go
					go_reg <= wr_data(0);           -- Clear or set go
				elsif(wr_addr =  std_logic_vector(to_unsigned(C_N_ADDR, C_MMAP_ADDR_WIDTH) ) ) then -- Check if this is a write to n
					n_reg <= wr_data;               -- Write to n                  
				end if;
			end if;
		end if;
	end process;
	
	
	
	--Read Operation
	process(clk, rst)
	begin
		if(rst = '1') then
			reg <= std_logic_vector(to_unsigned(0,C_MMAP_DATA_WIDTH)); 
		elsif(rising_edge(clk)) then
			if(rd_en = '1') then
				if(rd_addr = std_logic_vector(to_unsigned(C_GO_ADDR, C_MMAP_ADDR_WIDTH) ) ) then    -- Check if this is a read from go
					--Store in register
					reg(0) <= go_reg; --Delay a cycle (go is only 1 bit)
									
				elsif(rd_addr = std_logic_vector(to_unsigned(C_N_ADDR, C_MMAP_ADDR_WIDTH) ) ) then -- Check if this is a read from n
					reg <= n_reg; --Delay a cycle
						
				elsif(rd_addr = std_logic_vector(to_unsigned(C_RESULT_ADDR, C_MMAP_ADDR_WIDTH) ) ) then --  Check if this is a read from result
					reg <= result; --Delay a cycle
	
				elsif(rd_addr = std_logic_vector(to_unsigned(C_DONE_ADDR, C_MMAP_ADDR_WIDTH) ) ) then    --  Check if this is a read from done
					reg(0) <= done; --Delay a cycle  (done is only 1 bit)
				
				end if;
			end if;		
		end if;
	end process;
	
	rd_data <= reg; --Update rd_data (Correct value will appear one cycle after read operation)
	

	go <= go_reg; --Assign outputs to registers so I can read from them
	n  <= n_reg;
	
end BHV;