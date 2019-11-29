library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity dma_rd_ram_in is
    port (
            -- Signals between user_app and DMA interface
            dram_clk  : in  std_logic;   
            user_clk  : in  std_logic;  
            rst       : in  std_logic;   
            clear     : in  std_logic;   
            go        : in  std_logic;      
            rd_en     : in  std_logic;     
            stall     : in  std_logic;
            start_addr: in  std_logic_vector(RAM0_ADDR_RANGE);
            size      : in  std_logic_vector(RAM0_RD_SIZE_RANGE);     
            valid     : out std_logic;   
            data      : out std_logic_vector(RAM0_RD_DATA_RANGE);   
            done      : out std_logic;
            
            -- Signals between DRAM and DMA interface
            dram_ready    : in  std_logic;
            dram_rd_en    : out std_logic;
            dram_rd_addr  : out std_logic_vector(DRAM0_ADDR_RANGE);
            dram_rd_data  : in  std_logic_vector(DRAM0_DATA_RANGE);
            dram_rd_valid : in  std_logic;
            dram_rd_flush : out std_logic);
            
end dma_rd_ram_in;

architecture STR of dma_rd_ram_in is

    signal go_sync      : std_logic;
    signal prog_full    : std_logic;
    signal empty        : std_logic;
    signal valid_s      : std_logic;
    signal done_s       : std_logic;
    signal size_r       : std_logic_vector(RAM0_RD_SIZE_RANGE);
    signal start_addr_r : std_logic_vector(RAM0_ADDR_RANGE);

    component addr_gen
        port(
             clk              : in  std_logic;
             rst              : in  std_logic;
             go               : in  std_logic;
             size             : in  std_logic_vector(RAM0_RD_SIZE_RANGE);
             start_addr       : in  std_logic_vector(RAM0_ADDR_RANGE);
             rd_addr          : out std_logic_vector(DRAM0_ADDR_RANGE);
             rd_en            : out std_logic;
             dram_rdy         : in  std_logic;
             stall            : in  std_logic
             );
    end component;
    
    component dma_counter
        port(
             clk           : in    std_logic;
             rst           : in    std_logic;
             fifo_rd_en    : in    std_logic;
             fifo_valid    : in    std_logic;
             done          : out   std_logic;
             size          : in    std_logic_vector(RAM0_RD_SIZE_RANGE)
             );
    end component; 
    
    component dma_fifo
        port(
             rst           : in    std_logic;
             wr_clk        : in    std_logic;
             rd_clk        : in    std_logic;
             din           : in    std_logic_vector(DRAM0_DATA_RANGE);
             wr_en         : in    std_logic;
             rd_en         : in    std_logic;
             dout          : out   std_logic_vector(RAM0_RD_DATA_RANGE);
             full          : out   std_logic;
             empty         : out   std_logic;
             prog_full     : out   std_logic
             );
    end component;
    
   
    
begin

    U_ADDR_GEN : addr_gen
        port map (
                  clk           => dram_clk,
                  rst           => rst,
                  go            => go_sync,
                  size          => size_r,
                  start_addr    => start_addr_r,
                  rd_addr       => dram_rd_addr,
                  rd_en         => dram_rd_en,
                  dram_rdy      => dram_ready,
                  stall         => prog_full
                  );
                  
    U_DMA_COUNT : dma_counter
        port map (
                  clk           => user_clk,
                  rst           => clear,
                  fifo_rd_en    => rd_en,
                  fifo_valid    => valid_s,
                  done          => done_s,
                  size          => size
                  );
                  
    U_REG_ADDR  : entity work.reg
        generic map (
                     width => C_RAM0_ADDR_WIDTH)
        port map    (
                     clk       => user_clk,
                     rst       => clear,
                     en        => go,
                     input     => start_addr,
                     output    => start_addr_r
                     );
                     
    U_REG_SIZE  : entity work.reg
        generic map (
                     width => C_RAM0_RD_SIZE_WIDTH)
        port map    (
                     clk       => user_clk,
                     rst       => clear,
                     en        => go,
                     input     => size,
                     output    => size_r
                     );
                     
    U_HANDSHAKE : entity work.handshake
        port map (
                    clk_src   => user_clk,
                    clk_dest  => dram_clk,
                    rst       => rst,
                    go        => go,
                    delay_ack => '0',
                    rcv       => go_sync,
                    ack       => open
                  );
    
    U_FIFO     : dma_fifo
        port map (
                   rst        => clear,
                   wr_clk     => dram_clk,
                   rd_clk     => user_clk,
                   din        => dram_rd_data,
                   wr_en      => dram_rd_valid,
                   rd_en      => rd_en,
                   dout       => data,
                   full       => open,
                   empty      => empty,
                   prog_full  => prog_full
                  );
                  
    U_DUAL_FLOP : entity work.dual_flop
        port map (
                  clk_src     => user_clk,
                  clk_dest    => dram_clk,
                  input       => done_s,
                  output      => dram_rd_flush,
                  rst_src     => rst,
                  rst_dest    => rst 
                 );

    valid_s <= NOT empty;
    valid   <= valid_s;
    done    <= done_s;
                  
end STR;                 
                  

    