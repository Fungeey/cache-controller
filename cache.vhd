library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CacheController is
	Port    (   clk 		: in    STD_LOGIC;
				reset		: in    STD_LOGIC;
				addr_in		: in 	STD_LOGIC_VECTOR(15 downto 0);
                cs          : in    STD_LOGIC;


                memstrb     : out   STD_LOGIC;
                rdy         : out   STD_LOGIC;
                wen         : out   STD_LOGIC;

                din_mux     : out   STD_LOGIC;
                dout_mux    : out   STD_LOGIC;

                );
end CacheController;
