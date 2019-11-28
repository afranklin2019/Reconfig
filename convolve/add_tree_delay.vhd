-- Greg Stitt
-- University of Florida
--
-- File: add_tree_delay.vhd
-- Entity: add_tree_delay
--
-- Description: In this example, we extend the previous add_tree_delay entity to support
-- an arbitrary initialization value for each register, in addition to
-- supporting a natural number of cycles. Previously, the entity required the
-- input to be add_tree_delayed by at least 1 cycle, but in this case, the entity can
-- add_tree_delay a signal by 0 cycles (i.e., no add_tree_delay)
--
-- Topics discussed: "if generate" and unconstrained generics.

library ieee;
use ieee.std_logic_1164.all;

entity add_tree_delay is
  generic(cycles : natural;
          width  : positive;

          -- here is the first change. "init" will be the valued stored into
          -- each register on reset. Notice that the vector is unconstrained.
          -- Normally, you would likely do something like
          -- std_logic_vector(width-1 downto 0), but unfortunately you cannot
          -- define one generic in terms of another generic, at least with the
          -- versions of VHDL that are supported by most tools. This
          -- restriction might change with VHDL 2008.

          init :     std_logic_vector);
  port( clk    : in  std_logic;
        rst    : in  std_logic;
        en     : in  std_logic;
        input  : in  std_logic_vector(width-1 downto 0);
        output : out std_logic_vector(width-1 downto 0));
end add_tree_delay;

-- A modified version of the previous structural implementation

 


-- Here is the modified behavioral architecture.

architecture BHV of add_tree_delay is

  type reg_array is array (0 to cycles-1) of std_logic_vector(width-1 downto 0);
  signal regs : reg_array;

begin  -- BHV

  -- This previous process only works for cycles > 0, so we also use an "if
  -- generate" here.

  U_CYCLES_GT_0 : if cycles > 0 generate

    process(clk, rst)
    begin
      if (rst = '1') then
        for i in 0 to cycles-1 loop
          regs(i) <= init;              -- Use the init generic here. Note that
                                        -- because init is unconstrained, there
                                        -- could be type-checking errors here
                                        -- if you don't provide a vector with
                                        -- the appropriate length.
        end loop;
      elsif (clk'event and clk = '1') then

        if (en = '1') then
          regs(0) <= input;
        end if;

        for i in 0 to cycles-2 loop
          if (en = '1') then
            regs(i+1) <= regs(i);
          end if;
        end loop;

      end if;
    end process;

    output <= regs(cycles-1);

  end generate U_CYCLES_GT_0;

  -- handle the cycles = 0 case

  U_CYCLES_EQ_0: if cycles = 0 generate

    output <= input;
    
  end generate U_CYCLES_EQ_0;
  
end BHV;
