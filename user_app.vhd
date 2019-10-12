library ieee;
use ieee.std_logic_1164.all;

use work.config_pkg.all;

entity user_app is
    port (
        clk : in std_logic;
        rst : in std_logic;

        -- memory-map interface
        mmap_wr_en   : in  std_logic;
        mmap_wr_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_wr_data : in  std_logic_vector(MMAP_DATA_RANGE);
        mmap_rd_en   : in  std_logic;
        mmap_rd_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_rd_data : out std_logic_vector(MMAP_DATA_RANGE)
        );
end user_app;

architecture CONNECT of user_app is

    signal go     : std_logic;
    signal n      : std_logic_vector(31 downto 0);
    signal result : std_logic_vector(31 downto 0);
    signal done   : std_logic;
	
begin

	-- connect memory map and fib entity
	
	--Memory Map
	U_MEMORY_MAP : entity work.memory_map
	port map(
		clk => clk,
        rst => rst,
        wr_en   => mmap_wr_en,
        wr_addr => mmap_wr_addr,
        wr_data => mmap_wr_data,
        rd_en   => mmap_rd_en,
        rd_addr => mmap_rd_addr,
        rd_data => mmap_rd_data,

        -- application-specific I/O
        go     => go,
        n      => n,
        result => result,
        done   => done);
	
	--Fiboncacci Calculator	
	U_FIB : entity work.fib 
	port map(
		clk => clk,
        rst => rst,
        go  => go,
        n   => n,
        result => result,
        done   => done);
	

end CONNECT;
