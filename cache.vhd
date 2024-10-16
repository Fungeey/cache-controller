library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cache is

Port(   -- the ports of the cache controller
    --inputs
    clk        : in    STD_LOGIC;
    --rst          : in    STD_LOGIC;
    addr_in      : in  STD_LOGIC_VECTOR(15 downto 0);
    wr_rd_in        : in    STD_LOGIC;
    cs              : in    STD_LOGIC;

    --outputs
    rdy           : out   STD_LOGIC;

    -- to SDRAM controller
    addr_out1       : out   STD_LOGIC_VECTOR(15 downto 0);
    wr_rd_out       : out   STD_LOGIC;
    memstrb         : out   STD_LOGIC;

    -- to SRAM
    addr_out2       : out   STD_LOGIC_VECTOR(7 downto 0);
    wen             : out   STD_LOGIC;

    -- mux
    din_mux         : out   STD_LOGIC;
    dout_mux        : out   STD_LOGIC
  );
end cache;

architecture Behavioral of cache is --components and signals goes here
  component SDRAMController
    PORT (
      clk 		      : in    STD_LOGIC;
      rst		        :  in    STD_LOGIC; --do we need
      addr_in		    : in 	STD_LOGIC_VECTOR(15 downto 0);
      wr_rd         : in    STD_LOGIC;
      memstrb       : in    STD_LOGIC;
      din           : in    STD_LOGIC_VECTOR(7 downto 0);
      dout          : out   STD_LOGIC_VECTOR(7 downto 0)
    );
  end component;

  component CPU_gen
    PORT (
      clk 		      : in  STD_LOGIC;
      rst 		      : in  STD_LOGIC;
      trig 		      : in  STD_LOGIC;
		-- Interface to the Cache Controller.
      Address 	    : out  STD_LOGIC_VECTOR (15 downto 0);
      wr_rd 	      : out  STD_LOGIC;
      cs 		        : out  STD_LOGIC;
      DOut 		      : out  STD_LOGIC_VECTOR (7 downto 0)
    );
  end component;

  component SRAM -- the ports of the SRAM controller
    Port(  
    --inputs
    clk : in    STD_LOGIC;
    rst    : in    STD_LOGIC;

    addr_in : in STD_LOGIC_VECTOR(15 downto 0);
    wr_rd       : in    STD_LOGIC;
    memstrb     : in    STD_LOGIC;
    din         : in    STD_LOGIC_VECTOR(7 downto 0);
    dout        : out   STD_LOGIC_VECTOR(7 downto 0)
    );
  end component;

  component icon
    PORT (
    CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
    ); -- control 1 do we need
  end component;

  component ila
    PORT (
        CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
        CLK : IN STD_LOGIC;
        DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        TRIG0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  end component;

  component vio -- board inputs / outputs
    PORT (
    CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    ASYNC_OUT : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
    );
  end component;

  COMPONENT bram
    PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  END COMPONENT;

-- SIGNALS

  -- chipscope
  signal control0 : std_logic_vector(35 downto 0);
  signal control1 : std_logic_vector(35 downto 0);
  signal ila_data : std_logic_vector(31 downto 0);
  signal trig0 : std_logic_vector(7 downto 0);
  signal vio_out : std_logic_vector(17 downto 0);

  signal bram_addr : std_logic_vector(7 downto 0);
  signal bram_din, bram_dout : std_logic_vector(7 downto 0);
  signal bram_wen : std_logic_vector (0 downto 0);

  -- Address Decoder
  signal tag    : std_logic_vector(15 downto 8);
  signal index  : std_logic_vector(7 downto 5);
  signal offset : std_logic_vector(4 downto 0);

  -- Local SRAM Table (stores 32 1-byte words)
  type index_array is array (0 to 7) of std_logic_vector(2 downto 0);
  signal table_index  : index_array;

  type tag_array is array (0 to 7) of std_logic_vector(7 downto 0);
  signal table_tag    : tag_array;

  signal table_valid  : std_logic_vector(7 downto 0);
  signal table_dirty  : std_logic_vector(7 downto 0);

  -- FSM control unit
  signal state_current : std_logic_vector(2 downto 0) := "000";
  signal state_next : std_logic_vector(2 downto 0);

  -- variables
  signal counter : integer := 0; -- for SDRAM operations
  --signal offset_inc : std_logic_vector (4 downto 0);
  signal offset_inc : integer := 0;
  signal done : std_logic := '0';

-- COMPONENTS
begin

  sys_icon : icon
  port map (
  CONTROL0 => control0,
  CONTROL1 => control1
  );

  sys_ila : ila
  port map (
  CONTROL => control0,
  CLK => clk,
  DATA => ila_data,
  TRIG0 => trig0
  );

  system_vio : vio
  port map (
  CONTROL => control1,
  ASYNC_OUT => vio_out
  );

  -- Block Ram
  system_bram : bram
  PORT MAP (
  clka => clk,
  wea => bram_wen,
  addra => bram_addr,
  dina => bram_din,
  douta => bram_dout
  );

  -- address decoder
  addressDecoder: process(addr_in, cs)
  begin
    if(cs'event and cs = '1') then
      tag <= addr_in(15 downto 8);
      index <= addr_in(7 downto 5);
      offset <= addr_in(4 downto 0);
    end if;
  end process;

  -- FSM: control unit, 6 states.
  stateStorage: process(clk, state_next)
  begin
    if(clk'event and clk = '1')then
      state_current <= state_next;
    end if;
  end process;

  -- FSM: Next state generation.
  nextStateGen : process(state_current, tag, index, offset)
  begin
    if(state_current = "000") then     -- S0: Idle
      -- compare if tags are same
      if(tag = table_tag(to_integer(unsigned(index)))) then
        state_next <= "011"; -- Hit
      else
        -- Check dirty bit
        if(table_dirty(to_integer(unsigned(index))) = '0') then
          state_next <= "001"; -- Miss
        else
          state_next <= "010"; -- Dirty Miss
        end if;
      end if;

    elsif(state_current = "001") then  -- S1: Dirty Miss
      -- don't move on until finished data transfer
      if (done = '1') then
        state_next <= "010"; -- go into miss
      end if;

    elsif(state_current = "010") then  -- S2: Miss
      -- don't move on until finished data transfer
      if (done = '1') then
        state_next <= "011"; -- become hit
      end if;

    elsif(state_current = "011") then  -- S3: Hit
        if (wr_rd_in = '1') then      
          state_next <= "101"; -- write
        else
          state_next <= "100"; -- read
        end if;

    elsif(state_current = "100") then  -- S4: Read
      state_next <= "000";

    elsif(state_current = "101") then  -- S5: Write
      state_next <= "000";

    else                              
      state_next <= "000";            -- default / reset (idle)

    end if;
  end process;

  -- FSM: Output generation.
  outGen: process(state_current)
  begin
    if(state_current = "000") then     -- S0: Idle
      rdy <= '1';

    elsif(state_current = "001") then  -- S1: Dirty Miss
      rdy <= '0';

      if(counter = 0) then
        -- on first run of this state: send offset as 0
        -- these variables are static or they dont change

        -- tag miss must write into SDRAM controller
        addr_out1(15 downto 8) <= tag;
        addr_out1(7 downto 5) <= index;
        addr_out2(7 downto 5) <= index;
        addr_out2(4 downto 0) <= "00000";
 
 offset_inc <= 0;
 done <= '0';
       
        wr_rd_out <= '1'; -- write
        dout_mux <= '0';
        -- din_mux <= '1'; -- do we need this
        wen <= '0';
 counter <= 1;

      -- repeat 32 times: send data from SRAM to SDRAM
      elsif (counter <= 64) then --event every 2 clock cycles x 32 times (words)
        if (counter mod 2 = 0) then -- operation
          memstrb <= '1';
         
          --the indices remains the same (same row). the offset changes (going through the columns)
          -- int to unsigned(value,size)

          addr_out1(4 downto 0) <= STD_LOGIC_VECTOR(to_unsigned(offset_inc, 5));
          addr_out2(4 downto 0) <= STD_LOGIC_VECTOR(to_unsigned(offset_inc, 5));
          offset_inc <= offset_inc + 1;
     
        else -- mod 2 = 1
          memstrb <= '0';

        end if;
        counter <= counter + 1;
elsif (counter > 64) then
done <= '1';
counter <= 0;
      end if;

    elsif(state_current = "010") then  -- S2: Miss
      rdy <= '0';

      if(counter = 0) then
        -- on first run of this state: send offset as 0
        table_valid(to_integer(unsigned(index))) <= '1';

        -- tag miss must write into SDRAM controller
        addr_out1(15 downto 8) <= tag;
        addr_out1(7 downto 5) <= index;
        addr_out2(7 downto 5) <= index;
        addr_out2(4 downto 0) <= "00000";
 
 offset_inc <= 0;
 done <= '0';

        wr_rd_out <= '0'; -- read
        din_mux <= '1';
        wen <= '1';
 counter <= 1;
     
      elsif (counter <= 64) then
        --event every 2 clock cycles x 32 times (words)
        -- repeat 32 times: wait for MSTRB high, then store data from SDRAM into SRAM
        -- repeat 32 times: send data from SDRAM TO SRAM
        if (counter mod 2 = 0) then -- operation
          memstrb <= '1';
         
          --the Controller tells SDRAM the tag + index and SRAM the index
          --and the offset to both which increments
          addr_out1(4 downto 0) <= STD_LOGIC_VECTOR(to_unsigned(offset_inc, 5));
          addr_out2(4 downto 0) <= STD_LOGIC_VECTOR(to_unsigned(offset_inc, 5));
          offset_inc <= offset_inc + 1;

        else -- mod 2 = 1
          memstrb <= '0';

        end if;
        counter <= counter + 1;
elsif (counter > 64) then
done <= '1';
counter <= 0;
      end if;

      -- once done, update tag in the table
      table_tag(to_integer(unsigned(index))) <= tag;

    elsif(state_current = "011")then  -- S3: Hit
      rdy <= '0';
      -- shouldn't output anything

    elsif(state_current = "100")then  -- S4: Read
      rdy <= '0';

      -- SRAM to CPU
      dout_mux <= '1';
      din_mux <= '0';
      wen <= '0';
      addr_out2(7 downto 5) <= index;
      addr_out2(4 downto 0) <= offset;

    elsif(state_current = "101")then  -- S5: Write
      rdy <= '0';

      -- CPU to SRAM
      din_mux <= '0';
      wen <= '1';
      table_dirty(to_integer(unsigned(index))) <= '1';
      table_valid(to_integer(unsigned(index))) <= '1';
      addr_out2(7 downto 5) <= index;
      addr_out2(4 downto 0) <= offset;

    else                              -- default / reset (idle)

    end if;
  end process;
end Behavioral;