library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity resetBlock is
  Port (
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    rstAux1 : out STD_LOGIC;
    rstAux2 : out STD_LOGIC;
    rstAux3 : out STD_LOGIC
  );
end resetBlock;

architecture Behavioral of resetBlock is
  -- Up counter.
  signal countVal : std_logic_vector(4 downto 0) := "00000";
  signal rstC, incC : std_logic;
  -- Comparators.
  signal match16, match24, match30 : std_logic;
  -- FSM control unit.
  signal st1 : std_logic_vector(2 downto 0) := "000";
  signal st1N : std_logic_vector(2 downto 0);

begin
  -- System up-counter, used to keep track of time.
  upCounter: process(clk, rstC, incC)
  begin
    if(rstC = '1')then
        countVal <= "00000";
      else
        if(clk'event and clk = '1' and incC = '1')then
          countVal <= countVal + "00001";
        end if;
    end if;
  end process;

-- Comparators, used to flag specific counter values.
comparator16 : process(countVal)
begin
if(countVal = "10000")then
match16 <= '1';
else
match16 <= '0';
end if;
end process;

comparator24 : process(countVal)
begin
if(countVal = "11000")then
match24 <= '1';
else
match24 <= '0';
end if;
end process;

comparator30 : process(countVal)
begin
if(countVal = "11110")then
match30 <= '1';
else
match30 <= '0';
end if;
end process;

-- FSM control unit, with 6 states.
-- State storage.
stateStorage: process(clk, st1N)
begin
  if(clk'event and clk = '1')then
  st1 <= st1N;
  end if;
end process;

-- Next state generation.
nextStateGen : process(st1, rst, match16, match24, match30)
begin
  if(st1 = "000")then -- S0: Rest state.
  if(rst = '1')then
  st1N <= "001";
  else
  st1N <= "000";
  end if;
  elsif(st1 = "001")then -- S1: generate all three reset signals.
  if(match16 = '1')then
  st1N <= "010";
  else
  st1N <= "001";
  end if;
  elsif(st1 = "010")then -- S2: generate only two reset signals.
  if(match24 = '1')then
  st1N <= "011";
  else
  st1N <= "010";
  end if;
  elsif(st1 = "011")then -- S3: generate only one reset signal.
  if(match30 = '1')then
  st1N <= "100";
  else
  st1N <= "011";
  end if;
  elsif(st1 = "100")then -- S4: de-assert all reset signals.
  st1N <= "101";
  elsif(st1 = "101")then -- S5: reset up-counter.
  st1N <= "000";
  else
  st1N <= "000";
  end if;
end process;

-- Output generation.
  outGen: process(st1)
  begin
    if(st1 = "000")then -- S0: Rest state.
    incC <= '0';
    rstC <= '0';
    rstAux1 <= '0';
    rstAux2 <= '0';
    rstAux3 <= '0';
    elsif(st1 = "001")then -- S1: generate all three reset signals.
    incC <= '1';
    rstC <= '0';
    rstAux1 <= '1';
    rstAux2 <= '1';
    rstAux3 <= '1';
    elsif(st1 = "010")then -- S2: generate only two reset signals.
    incC <= '1';
    rstC <= '0';
    rstAux1 <= '1';
    rstAux2 <= '1';
    rstAux3 <= '0';
    elsif(st1 = "011")then -- S3: generate only one reset signal.
    incC <= '1';
    rstC <= '0';
    rstAux1 <= '1';
    rstAux2 <= '0';
    rstAux3 <= '0';
    elsif(st1 = "100")then -- S4: de-assert all reset signals.
    incC <= '0';
    rstC <= '0';
    rstAux1 <= '0';
    rstAux2 <= '0';
    rstAux3 <= '0';
    elsif(st1 = "101")then -- S5: reset up-counter.
    incC <= '0';
    rstC <= '1';
    rstAux1 <= '0';
    rstAux2 <= '0';
    rstAux3 <= '0';
    else
    incC <= '0';
    rstC <= '0';
    rstAux1 <= '0';
    rstAux2 <= '0';
    rstAux3 <= '0';
    end if;
  end process;
end Behavioral;