library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cache is 
	Port(   -- the ports of the cache controller
    --inputs
    clk 		    : in    STD_LOGIC;
	rst		        : in    STD_LOGIC;
	addr_in		    : in 	  STD_LOGIC_VECTOR(15 downto 0);
    wr_rd_in        : in   STD_LOGIC;
    cs              : in    STD_LOGIC;

    --outputs
    rdy             : out   STD_LOGIC;

    -- to SDRAM controller
    addr_out        : out   STD_LOGIC_VECTOR(15 downto 0);
    wr_rd_out       : out   STD_LOGIC;
    memstrb         : out   STD_LOGIC;

    -- to SRAM
    addr_out2       : out  STD_LOGIC_VECTOR(7 downto 0);
    wen             : out   STD_LOGIC;

    -- mux
    din_mux         : out   STD_LOGIC;
    dout_mux        : out   STD_LOGIC;
  );
end cache;

architecture Behavioral of cache is --components and signals goes here
-- SIGNALS

  -- Address Decoder
  signal tag    : std_logic_vector(15 downto 8);
  signal index  : std_logic_vector(7 downto 5);
  signal offset : std_logic_vector(4 downto 0);

  -- Local SRAM Table (stores 32 1-byte words)
  signal table_index  : std_logic_vector(32 downto 0);
  signal table_valid  : std_logic_vector(32 downto 0);
  signal table_dirty  : std_logic_vector(32 downto 0);
  signal table_tag    : std_logic_vector(32 downto 0);

  -- FSM control unit
  signal state_current : std_logic_vector(2 downto 0) := "000";
  signal state_next : std_logic_vector(2 downto 0);

-- COMPONENTS
begin

  -- address decoder
  addressDecoder: process(addr_in, tag, index)
    
  end process;

  -- FSM: control unit, 6 states.
  stateStorage: process(clk, state_next)
  begin
    if(clk'event and clk = '1')then
      state_current <= state_next;
    end if;
  end process;

  -- FSM: Next state generation.
  nextStateGen : process(state_current, rst, match16, match24, match30)
  begin
    if(state_current = "000")then     -- S0: Idle
        -- cs probe
    elsif(state_current = "001")then  -- S1: Miss
        -- 
    elsif(state_current = "010")then  -- S2: Dirty Miss 

    elsif(state_current = "011")then  -- S3: Hit
        if (wr_rd_in = '1') then
                
                --write
        else 
                
                -- read
        end if;
    elsif(state_current = "100")then  -- S4: Read

    elsif(state_current = "101")then  -- S5: Write
      state_next <= "000";
    else
      state_next <= "000";
    end if;
  end process;

  -- FSM: Output generation.
  outGen: process(state_current)
  begin
    if(state_current = "000")then     -- S0: Idle
        
    elsif(state_current = "001")then  -- S1: Miss

    elsif(state_current = "010")then  -- S2: Dirty Miss

    elsif(state_current = "011")then  -- S3: Hit

    elsif(state_current = "100")then  -- S4: Read

    elsif(state_current = "101")then  -- S5: Write

    else                              -- default / reset (idle)

    end if;
  end process;
end Behavioral;