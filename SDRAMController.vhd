library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SDRAMController is -- the ports of the SDRAM controller
	Port    (   
                --inputs
                clk 		: in    STD_LOGIC;
				rst		    : in    STD_LOGIC;
				
                addr_in		: in 	STD_LOGIC_VECTOR(15 downto 0);
                wr_rd       : in    STD_LOGIC;
                memstrb     : in    STD_LOGIC;
                din         : in    STD_LOGIC_VECTOR(7 downto 0);

                dout        : out   STD_LOGIC_VECTOR(7 downto 0));
end SDRAMController;

architecture Behavioral of SDRAMController is

--components and signals goes here
type memory_block is array (7 downto 0, 31 downto 0) of std_logic_vector(7 downto 0);
--the cache has 8 row of 32 words. each word is 1 byte or 8 bits

signal memory_signal: std_logic_vector(7 downtp 0); -- word

begin

    --port map?
    
    process (clk)
        begin
            if (clk'event and clk = '1') then
                if (memstrb ='1') then-- event
                    if (wr_rd ='1') then
                        --write

                        
                    else -- wr_rd = 0
                        --read
                        dout <= 

                end if;
                --memstrb = 0 nothing happens
            end if
        end if
    end process;

end Behavioral;