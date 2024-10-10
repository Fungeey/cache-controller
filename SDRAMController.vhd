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


begin

    --port map?
    
    process (clk)
        begin


    end process;

end Behavioral;