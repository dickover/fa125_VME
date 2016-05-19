----- 32-bit DFFE with reset, set

library ieee;
use ieee.std_logic_1164.all;

entity dffe_32 is
	port( 	  d: in std_logic_vector(31 downto 0);
			clk: in std_logic;
		reset_n: in std_logic;
		  set_n: in std_logic;
		clk_ena: in std_logic;
			  q: out std_logic_vector(31 downto 0));
end dffe_32;

architecture a1 of dffe_32 is

	constant all_zeros: std_logic_vector(31 downto 0) 
			 := "00000000000000000000000000000000";
	constant all_ones: std_logic_vector(31 downto 0) 
			 := "11111111111111111111111111111111";

begin
p1: process (reset_n,set_n,clk)
	begin
		if reset_n = '0' then q <= all_zeros;
		elsif set_n = '0' then q <= all_ones;
		elsif rising_edge(clk) then
			if clk_ena = '1' then q <= d;
			end if;
		end if;
	end process p1;
end a1;


		