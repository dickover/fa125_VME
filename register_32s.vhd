-- 32-bit register (synchronous with byte clk enables) - 6/22/10 VHDL  EJ 

library ieee;
use ieee.std_logic_1164.all;

entity register_32s is
	port (   data: in std_logic_vector(31 downto 0);
			ce_b0: in std_logic;
			ce_b1: in std_logic;
			ce_b2: in std_logic;
			ce_b3: in std_logic;
			  clk: in std_logic;
			reset: in std_logic;
			  reg: out std_logic_vector(31 downto 0) );
end register_32s;
			   
architecture a1 of register_32s is

	component dffe_8 is
		port( 	  d: in std_logic_vector(7 downto 0);
				clk: in std_logic;
			reset_n: in std_logic;
			  set_n: in std_logic;
			clk_ena: in std_logic;
				  q: out std_logic_vector(7 downto 0));
	end component;

	signal reset_n: std_logic;
														
begin

	reset_n <= not reset;

x0: dffe_8 port map (  	   d => data(31 downto 24),
						 clk => clk,
					 reset_n => reset_n,
					   set_n => '1',
					 clk_ena => ce_b0,
						   q => reg(31 downto 24) );
				  
x1: dffe_8 port map (  	   d => data(23 downto 16),
						 clk => clk,
					 reset_n => reset_n,
					   set_n => '1',
					 clk_ena => ce_b1,
						   q => reg(23 downto 16) );
				  
x2: dffe_8 port map (  	   d => data(15 downto 8),
						 clk => clk,
					 reset_n => reset_n,
					   set_n => '1',
					 clk_ena => ce_b2,
						   q => reg(15 downto 8) );
				  
x3: dffe_8 port map (  	   d => data(7 downto 0),
						 clk => clk,
					 reset_n => reset_n,
					   set_n => '1',
					 clk_ena => ce_b3,
						   q => reg(7 downto 0) );
				  
end a1;

