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