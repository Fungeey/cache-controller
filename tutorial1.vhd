----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:14:11 09/12/2024 
-- Design Name: 
-- Module Name:    tutorial1 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
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

entity tutorial1 is
    Port ( clk : in  STD_LOGIC;
           led : out  STD_LOGIC_VECTOR (7 downto 0);
           switches : in  STD_LOGIC_VECTOR (3 downto 0));
end tutorial1;

architecture Behavioral of tutorial1 is

	component icon
	  PORT (
		 CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));

	end component;
	
	component ila
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CLK : IN STD_LOGIC;
		 DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 TRIG0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0));

	end component;

	component vio
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 ASYNC_OUT : OUT STD_LOGIC_VECTOR(17 DOWNTO 0));

	end component;
	
	signal control0: std_logic_vector(35 downto 0);
	signal control1: std_logic_vector(35 downto 0);
	signal ila_data: std_logic_vector(31 downto 0);
	signal trig0: std_logic_vector(7 downto 0);
	signal vio_out: std_logic_vector(17 downto 0);
	
	COMPONENT bram
	  PORT (
		 clka : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	  );
	END COMPONENT;
	
	signal bram_addr: std_logic_vector(7 downto 0);
	signal bram_din, bram_dout : std_logic_vector(7 downto 0);
	signal bram_wen: std_logic_vector(0 downto 0);
	
	signal counter: std_logic_vector(29 downto 0);

begin

	sys_icon:icon
	port map(
			CONTROL0 => control0,
			CONTROL1 => control1
	);
	
	sys_lia:ila
	port map(
			CONTROL => control0,
			CLK => clk,
			DATA => ila_data,
			TRIG0 => trig0
	);
	
	system_vio: vio
	port map(
		CONTROL => control1,
		ASYNC_OUT => vio_out
	);

	system_bram: bram
	PORT MAP(
		clka => clk,
		wea => bram_wen,
		addra => bram_addr,
		dina => bram_din,
		douta => bram_dout
	);

	process(clk)
	begin
		if(clk'Event and clk='1') then
			if (switches(0) ='1') then
				counter <= counter +'1';
			else
				counter <= counter -'1';
			end if;
		end if;
	end process;

	process(clk, counter, vio_out)
	begin
		if (clk'Event and clk ='1')then
			if(vio_out(17)='1') then 
				bram_din <= counter(7 downto 0);
			else
				bram_din <= vio_out(7 downto 0);
			end if;
		end if;
	end process;
	
	led (7 downto 0) <= bram_dout;

	ila_data(7 downto 0) <= bram_din;
	ila_data(15 downto 8) <= bram_dout;
	ila_data(23 downto 16) <=bram_addr;
	ila_data(31 downto 24) <= counter(7 downto 0);
	
	bram_addr <= vio_out (15 downto 8);
	bram_wen(0) <= vio_out (16);
	
	trig0(0) <= bram_wen (0);
	trig0(7 downto 1) <= (others =>'0');

end Behavioral;

