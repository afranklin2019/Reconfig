-- Greg Stitt
-- University of Florida
-- EEL 5721/4720 Reconfigurable Computing
--
-- File: wrapper_tb.vhd
--
-- Description: This file implements a testbench for the simple pipeline
-- when running on the ZedBoard. 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity wrapper_tb is
end wrapper_tb;

architecture behavior of wrapper_tb is

    constant TEST_SIZE : integer := 256;
	constant PADDED_SIGNAL_SIZE : integer := C_SIGNAL_SIZE + 2*(C_KERNEL_SIZE-1);
	
	constant OUTPUT_SIZE : integer := C_SIGNAL_SIZE+C_KERNEL_SIZE+1;
    constant MAX_CYCLES : integer  := TEST_SIZE*4;

	
	signal clk0 : std_logic                        := '0';
    signal clk1 : std_logic                        := '0';
    signal clks : std_logic_vector(NUM_CLKS_RANGE) := (others => '0');
	
    signal rst : std_logic := '1';

    signal mmap_wr_en   : std_logic                         := '0';
    signal mmap_wr_addr : std_logic_vector(MMAP_ADDR_RANGE) := (others => '0');
    signal mmap_wr_data : std_logic_vector(MMAP_DATA_RANGE) := (others => '0');

    signal mmap_rd_en   : std_logic                         := '0';
    signal mmap_rd_addr : std_logic_vector(MMAP_ADDR_RANGE) := (others => '0');
    signal mmap_rd_data : std_logic_vector(MMAP_DATA_RANGE);

    signal sim_done : std_logic := '0';
	
	type reg_array is array (0 to 6) of std_logic_vector(15 downto 0);
	
	signal output : reg_array; 

	
begin

    UUT : entity work.wrapper
        port map (
            clks          => clks,
            rst          => rst,
            mmap_wr_en   => mmap_wr_en,
            mmap_wr_addr => mmap_wr_addr,
            mmap_wr_data => mmap_wr_data,
            mmap_rd_en   => mmap_rd_en,
            mmap_rd_addr => mmap_rd_addr,
            mmap_rd_data => mmap_rd_data);

	
	-- toggle clock
    clk0    <= not clk0 after 5 ns when sim_done = '0' else clk0;
    clk1    <= not clk1 after 3 ns when sim_done = '0' else clk1;
    clks(0) <= clk0;
    clks(1) <= clk1;

    -- process to test different inputs
    process

        -- function to check if the outputs is correct
        function checkOutput (
            i : integer)
            return integer is

        begin
            return ((i*4) mod 256)*((i*4+1) mod 256) + ((i*4+2) mod 256)*((i*4+3) mod 256);
        end checkOutput;

        procedure clearMMAP is
        begin
            mmap_rd_en <= '0';
            mmap_wr_en <= '0';
        end clearMMAP;

        variable errors       : integer := 0;
        variable total_points : real    := 50.0;
        variable min_grade    : real    := total_points*0.25;
        variable grade        : real;

        variable result : std_logic_vector(C_MMAP_DATA_WIDTH-1 downto 0);
        variable done   : std_logic;
        variable count  : integer;

    begin
		
		output(0) <= std_logic_vector(to_unsigned(0,16));
		output(1) <= std_logic_vector(to_unsigned(0,16));
		
		output(2) <= std_logic_vector(to_unsigned(1,16));
		output(3) <= std_logic_vector(to_unsigned(2,16));
		
		output(4) <= std_logic_vector(to_unsigned(3,16));
		output(5) <= std_logic_vector(to_unsigned(0,16));
		
		output(6) <= std_logic_vector(to_unsigned(0,16));

        -- reset circuit  
        rst <= '1';
        clearMMAP;
        wait for 200 ns;

        rst <= '0';
        wait until clk'event and clk = '1';
        wait until clk'event and clk = '1';

        -- write contents to input ram, which starts at addr 0 (Needs to be size of padded signal)
        --Initial Padding (One write means 2 16-bit zeros)
		
            mmap_wr_addr <= std_logic_vector(to_unsigned(0, C_MMAP_ADDR_WIDTH));
            mmap_wr_en   <= '1';
            mmap_wr_data <= std_logic_vector((to_unsigned(0, 16)) & (to_unsigned(0, 16)) );
            wait until clk'event and clk = '1';
            clearMMAP;
		
		--Actual Unpadded Signal
            mmap_wr_addr <= std_logic_vector(to_unsigned(1, C_MMAP_ADDR_WIDTH));
            mmap_wr_en   <= '1';
            mmap_wr_data <= std_logic_vector((to_unsigned(1, 16)) & (to_unsigned(2, 16)) ); 
            wait until clk'event and clk = '1';
            clearMMAP;
        
			mmap_wr_addr <= std_logic_vector(to_unsigned(2, C_MMAP_ADDR_WIDTH));
            mmap_wr_en   <= '1';
            mmap_wr_data <= std_logic_vector((to_unsigned(3, 16)) & (to_unsigned(0, 16)) ); 
            wait until clk'event and clk = '1';
            clearMMAP;
		
		
		--Backend Padding
            mmap_wr_addr <= std_logic_vector(to_unsigned(3, C_MMAP_ADDR_WIDTH));
            mmap_wr_en   <= '1';
			map_wr_data <= std_logic_vector(to_unsigned(0, 32) );
            wait until clk'event and clk = '1';
            clearMMAP;

        -- send size (Number of elements I want to transfer from memory) Must be signal size = unpadded size + 2*Kernel_size-1
        mmap_wr_addr <= C_SIGNAL_SIZE_ADDR;
        mmap_wr_en   <= '1';
        mmap_wr_data <= std_logic_vector(to_unsigned(PADDED_SIGNAL_SIZE, C_MMAP_DATA_WIDTH));
        wait until clk'event and clk = '1';
        clearMMAP;
		
		--Load Kernel Buffer (with Size of 3)
            mmap_wr_addr <= std_logic_vector(to_unsigned(C_KERNEL_DATA_ADDR, C_MMAP_ADDR_WIDTH));
            mmap_wr_en   <= '1';
            mmap_wr_data <= std_logic_vector(to_unsigned(1, 32));
            wait until clk'event and clk = '1';
            clearMMAP;
			mmap_wr_addr <= std_logic_vector(to_unsigned(C_KERNEL_DATA_ADDR, C_MMAP_ADDR_WIDTH));
            mmap_wr_en   <= '1';
            mmap_wr_data <= std_logic_vector(to_unsigned(1, 32));
            wait until clk'event and clk = '1';
			clearMMAP;
			mmap_wr_addr <= std_logic_vector(to_unsigned(C_KERNEL_DATA_ADDR, C_MMAP_ADDR_WIDTH));
            mmap_wr_en   <= '1';
            mmap_wr_data <= std_logic_vector(to_unsigned(1, 32));
            wait until clk'event and clk = '1';
			clearMMAP;
		

        -- send go = 1 over memory map
        mmap_wr_addr <= C_GO_ADDR;
        mmap_wr_en   <= '1';
        mmap_wr_data <= std_logic_vector(to_unsigned(1, C_MMAP_DATA_WIDTH));
        wait until clk'event and clk = '1';
        clearMMAP;
        
        done  := '0';
        count := 0;

        -- read the done signal every cycle to see if the circuit has
        -- completed.
        --
        -- equivalent to wait until (done = '1') for TIMEOUT;      
        while done = '0' and count < MAX_CYCLES loop

            mmap_rd_addr <= C_DONE_ADDR;
            mmap_rd_en   <= '1';
            wait until clk'event and clk = '1';
            clearMMAP;
            -- give entity one cycle to respond
            wait until clk'event and clk = '1';
            done         := mmap_rd_data(0);
            count        := count + 1;
        end loop;

        if (done /= '1') then
            errors := errors + 1;
            report "Done signal not asserted before timeout.";
        end if;

        -- read outputs from output memory
        for i in 0 to OUTPUT_SIZE-1 loop
            mmap_rd_addr   <= std_logic_vector(to_unsigned(i, C_MMAP_ADDR_WIDTH));
            mmap_rd_en     <= '1';            
            wait until clk'event and clk = '1';
            clearMMAP;
            -- give entity one cycle to respond
            wait until clk'event and clk = '1';
            result := mmap_rd_data;

            if (unsigned(result) /= checkOutput(i)) then
                errors := errors + 1;
                report "Result for " & integer'image(i) &
                    " is incorrect. The output is " &
                    integer'image(to_integer(unsigned(result))) &
                    " but should be " & integer'image(checkOutput(i));
            end if;
        end loop;  -- i

        report "SIMULATION FINISHED!!!";

        grade := total_points-(real(errors)*total_points*0.05);
        if grade < min_grade then
            grade := min_grade;
        end if;

        report "TOTAL ERRORS : " & integer'image(errors);
        report "GRADE = " & integer'image(integer(grade)) & " out of " &
            integer'image(integer(total_points));
        sim_done <= '1';
        wait;

    end process;
end behavior;
