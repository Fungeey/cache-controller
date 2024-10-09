library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cache is -- the ports of the cache controller
	Port    (   
                --inputs
                clk 		: in    STD_LOGIC;
				rst		    : in    STD_LOGIC;
				addr_in		: in 	STD_LOGIC_VECTOR(15 downto 0);
                cs          : in    STD_LOGIC;
                --wr/rdy      : in      STD_LOGIC;

                --outputs
                rdy         : out   STD_LOGIC;

                -- to SDRAM controller
                memstrb     : out   STD_LOGIC;
                wen         : out   STD_LOGIC;
                addr_out    : out   STD_LOGIC_VECTOR(15 downto 0);
                --wr/rdy      : in      STD_LOGIC;

                -- to SRAM
                din_mux     : out   STD_LOGIC;
                dout_mux    : out   STD_LOGIC;
                addr_out2   : out  STD_LOGIC_VECTOR(7 downto 0);
                --wen          : out    STD_LOGIC);
end cache;

architecture Behavioral of cache is

--components and signals goes here





begin

    --port map?
    
    process (clk)
    begin