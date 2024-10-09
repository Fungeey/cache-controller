library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cache is -- the ports of the cache controller
	Port    (   
                --inputs
                clk 		: in    STD_LOGIC;
				reset		: in    STD_LOGIC;
				addr_in		: in 	STD_LOGIC_VECTOR(15 downto 0);
                cs          : in    STD_LOGIC;

                --outputs
                memstrb     : out   STD_LOGIC;
                rdy         : out   STD_LOGIC;
                wen         : out   STD_LOGIC;

                -- to SRAM
                din_mux     : out   STD_LOGIC;
                dout_mux    : out   STD_LOGIC;

                );
end cache;

architecture Behavioral of cache is

--components and signals goes here





begin

    --port map?
    
    process (clk)
    begin