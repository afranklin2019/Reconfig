-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;
use work.math_custom.all;

entity user_app is
    port (
        clks   : in  std_logic_vector(NUM_CLKS_RANGE);
        rst    : in  std_logic;
        sw_rst : out std_logic;

        -- memory-map interface
        mmap_wr_en   : in  std_logic;
        mmap_wr_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_wr_data : in  std_logic_vector(MMAP_DATA_RANGE);
        mmap_rd_en   : in  std_logic;
        mmap_rd_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_rd_data : out std_logic_vector(MMAP_DATA_RANGE);

        -- DMA interface for RAM 0
        -- read interface
        ram0_rd_rd_en : out std_logic;
        ram0_rd_clear : out std_logic;
        ram0_rd_go    : out std_logic;
        ram0_rd_valid : in  std_logic;
        ram0_rd_data  : in  std_logic_vector(RAM0_RD_DATA_RANGE);
        ram0_rd_addr  : out std_logic_vector(RAM0_ADDR_RANGE);
        ram0_rd_size  : out std_logic_vector(RAM0_RD_SIZE_RANGE);
        ram0_rd_done  : in  std_logic;
        -- write interface
        ram0_wr_ready : in  std_logic;
        ram0_wr_clear : out std_logic;
        ram0_wr_go    : out std_logic;
        ram0_wr_valid : out std_logic;
        ram0_wr_data  : out std_logic_vector(RAM0_WR_DATA_RANGE);
        ram0_wr_addr  : out std_logic_vector(RAM0_ADDR_RANGE);
        ram0_wr_size  : out std_logic_vector(RAM0_WR_SIZE_RANGE);
        ram0_wr_done  : in  std_logic;

        -- DMA interface for RAM 1
        -- read interface
        ram1_rd_rd_en : out std_logic;
        ram1_rd_clear : out std_logic;
        ram1_rd_go    : out std_logic;
        ram1_rd_valid : in  std_logic;
        ram1_rd_data  : in  std_logic_vector(RAM1_RD_DATA_RANGE);
        ram1_rd_addr  : out std_logic_vector(RAM1_ADDR_RANGE);
        ram1_rd_size  : out std_logic_vector(RAM1_RD_SIZE_RANGE);
        ram1_rd_done  : in  std_logic;
        -- write interface
        ram1_wr_ready : in  std_logic;
        ram1_wr_clear : out std_logic;
        ram1_wr_go    : out std_logic;
        ram1_wr_valid : out std_logic;
        ram1_wr_data  : out std_logic_vector(RAM1_WR_DATA_RANGE);
        ram1_wr_addr  : out std_logic_vector(RAM1_ADDR_RANGE);
        ram1_wr_size  : out std_logic_vector(RAM1_WR_SIZE_RANGE);
        ram1_wr_done  : in  std_logic
        );
end user_app;

architecture default of user_app is

    signal go        : std_logic;
    signal sw_rst_s  : std_logic;
    signal rst_s     : std_logic;
    signal signal_size      : std_logic_vector(RAM0_RD_SIZE_RANGE);
    signal done      : std_logic;

	
	--Kernel Buffer Signals
	signal kernel_data : std_logic_vector(KERNEL_WIDTH_RANGE);
	signal kernel_load   : std_logic;
	signal kernel_loaded : std_logic;
	signal kernel_empty : std_logic;
	signal kernel_output : std_logic_vector(C_KERNEL_SIZE * C_KERNEL_WIDTH - 1 downto 0);
	
	
	--Signal Buffer Signals
	signal sb_wr_en : std_logic;
	signal sb_rd_en : std_logic;
	signal sb_full : std_logic;
	signal sb_empty : std_logic;
	signal signal_output : std_logic_vector(C_KERNEL_SIZE * C_SIGNAL_WIDTH - 1 downto 0 );
	
	--RAM 0 Signals
	signal ram0_rd_en : std_logic;
	
	--RAM 1 Signals
	signal ram1_wr_en : std_logic;
	
	--Pipeline Signals
	signal valid_in : std_logic;
	signal valid_out : std_logic;
	signal pipeline_en : std_logic;
	signal pipeline_output : std_logic_vector(C_KERNEL_WIDTH+C_SIGNAL_WIDTH+clog2(C_KERNEL_SIZE)-1 downto 0);
	
begin

    U_MMAP : entity work.memory_map
        port map (
            clk     => clks(C_CLK_USER),
            rst     => rst,
            wr_en   => mmap_wr_en,
            wr_addr => mmap_wr_addr,
            wr_data => mmap_wr_data,
            rd_en   => mmap_rd_en,
            rd_addr => mmap_rd_addr,
            rd_data => mmap_rd_data,

            -- dma interface for accessing DRAM from software
            ram0_wr_ready => ram0_wr_ready,
            ram0_wr_clear => ram0_wr_clear,
            ram0_wr_go    => ram0_wr_go,
            ram0_wr_valid => ram0_wr_valid,
            ram0_wr_data  => ram0_wr_data,
            ram0_wr_addr  => ram0_wr_addr,
            ram0_wr_size  => ram0_wr_size,
            ram0_wr_done  => ram0_wr_done,

            ram1_rd_rd_en => ram1_rd_rd_en,
            ram1_rd_clear => ram1_rd_clear,
            ram1_rd_go    => ram1_rd_go,
            ram1_rd_valid => ram1_rd_valid,
            ram1_rd_data  => ram1_rd_data,
            ram1_rd_addr  => ram1_rd_addr,
            ram1_rd_size  => ram1_rd_size,
            ram1_rd_done  => ram1_rd_done,

            -- circuit interface from software
            go            => go,
			sw_rst        => sw_rst_s,
			signal_size   => signal_size,
			kernel_data   => kernel_data,
			kernel_load   => kernel_load,
			kernel_loaded => kernel_loaded,
			done          => done
            );

    rst_s  <= rst or sw_rst_s;
    sw_rst <= sw_rst_s;

    U_CTRL : entity work.ctrl
        port map (
            clk           => clks(C_CLK_USER),
            rst           => rst_s,
            go            => go,
            mem_in_go     => ram0_rd_go,
            mem_out_go    => ram1_wr_go,
            mem_in_clear  => ram0_rd_clear,
            mem_out_clear => ram1_wr_clear,
            mem_out_done  => ram1_wr_done,
            done          => done);

    -- ram0_rd_rd_en <= ram0_rd_valid and ram1_wr_ready;
    -- ram0_rd_size  <= size;
-- --    ram0_rd_addr  <= ram0_rd_addr;
    -- ram1_wr_size  <= size;
-- --    ram1_wr_addr  <= ram1_rd_addr;
    -- ram1_wr_data  <= ram0_rd_data;
    -- ram1_wr_valid <= ram0_rd_valid and ram1_wr_ready;
	
	
	U_KERNEL_BUFFER : entity work.buff
		generic map (
			size => C_KERNEL_SIZE  )
		port map (
			clk   => clks(C_CLK_USER),
			rst   => rst_s,
			wr_en => kernel_load,
			rd_en => '0',
			full  => open,
			empty => kernel_empty,
			input => kernel_data,
			output => kernel_output
			);
			
	kernel_loaded <= not kernel_empty;	--Define kernel_loaded as the opposite of empty	

	ram0_rd_en <= ram0_rd_valid AND not sb_full; --Read from RAM 0 when read is valid and signal buffer is not full
	ram0_rd_rd_en <= ram0_rd_en; --Connect internal signal to output
	sb_wr_en <= ram0_rd_en;      --Write to signal buffer when read from RAM 0 is valid and signal buffer is not full
	sb_rd_en <= not sb_empty AND ram1_wr_ready; --Read from signal buffer when signal buffer is not empty and RAM 1 is ready to be written to 
			
	U_SIGNAL_BUFFER : entity work.buff
		generic map (
			size => C_KERNEL_SIZE )
		port map (
			clk   => clks(C_CLK_USER),
			rst   => rst_s,
			wr_en => sb_wr_en,
			rd_en => sb_rd_en,
			full  => sb_full,
			empty => sb_empty,
			input => ram0_rd_data,
			output => signal_output
			);
	
	U_DELAY : entity work.delay      --Delay for valid signal
		generic map(
			cycles => clog2(C_KERNEL_SIZE+C_KERNEL_SIZE)+1,
			width => 1,
			init => std_logic_vector(to_unsigned(0,1))
			)
		port map (
			clk    => clks(C_CLK_USER),
			rst    => rst_s,
			en     => pipeline_en,
			input(0)  => valid_in,
			output(0) => valid_out);

	ram1_wr_en <= valid_out AND ram1_wr_ready;  --Write to RAM1 when data is valid and RAM1 is ready
	
	valid_in <= sb_rd_en;         --Data is valid whenever I read from signal buffer
	
	pipeline_en <= ram1_wr_ready; --Stall pipeline when ram1_wr_ready is not ready
			
	U_PIPELINE : entity work.mult_add_tree
		generic map (
			num_inputs => C_KERNEL_SIZE,
			input1_width => C_KERNEL_WIDTH,
			input2_width => C_SIGNAL_WIDTH )
		port map (
			clk    => clks(C_CLK_USER), 
			rst    => rst_s,
			en     => pipeline_en,
			input1 => kernel_output,
			input2 => signal_output,
			output => pipeline_output);
			
	U_CLIP : entity work.clip
		generic map (
			input_width => C_KERNEL_WIDTH+C_SIGNAL_WIDTH+clog2(C_KERNEL_SIZE)
		)
		port map(
			input => pipeline_output,
			output => ram1_wr_data
			);

	ram0_rd_size  <= std_logic_vector(to_unsigned( unsigned(signal_size) + 2*(C_KERNEL_SIZE - 1) , C_RAM0_RD_SIZE_WIDTH) ) ;  --Ensure that I read from the signal as well as the padded zeroes
	ram1_wr_size  <= std_logic_vector(to_unsigned( unsigned(signal_size) + C_KERNEL_SIZE - 1, C_RAM1_WR_SIZE_WIDTH) );                                    --Write to these many locations
	
	ram0_rd_addr  <= (others => '0'); --Starting address for both DMA entities is zero for convolution
	ram1_wr_addr  <= (others => '0');
			
end default;
