----- 8 to 1 multiplexor ('bitlength' wide)

-- sel = '0', d0_in -> d_out
-- sel = '1', d1_in -> d_out 
-- sel = '2', d2_in -> d_out 
-- sel = '3', d3_in -> d_out 
-- sel = '4', d4_in -> d_out 
-- sel = '5', d5_in -> d_out 
-- sel = '6', d6_in -> d_out 
-- sel = '7', d7_in -> d_out 

library ieee;
use ieee.std_logic_1164.all;

entity mux8_to_1 is
	generic( bitlength: integer );
	port( d0_in: in std_logic_vector((bitlength-1) downto 0);
		  d1_in: in std_logic_vector((bitlength-1) downto 0);
		  d2_in: in std_logic_vector((bitlength-1) downto 0);
		  d3_in: in std_logic_vector((bitlength-1) downto 0);
		  d4_in: in std_logic_vector((bitlength-1) downto 0);
		  d5_in: in std_logic_vector((bitlength-1) downto 0);
		  d6_in: in std_logic_vector((bitlength-1) downto 0);
		  d7_in: in std_logic_vector((bitlength-1) downto 0);
		  d8_in: in std_logic_vector((bitlength-1) downto 0);
		  d9_in: in std_logic_vector((bitlength-1) downto 0);
		  d10_in: in std_logic_vector((bitlength-1) downto 0);
		  d11_in: in std_logic_vector((bitlength-1) downto 0);
		  d12_in: in std_logic_vector((bitlength-1) downto 0);
		  d13_in: in std_logic_vector((bitlength-1) downto 0);
		  d14_in: in std_logic_vector((bitlength-1) downto 0);
		  d15_in: in std_logic_vector((bitlength-1) downto 0);
			sel: in std_logic_vector(3 downto 0);
		  d_out: out std_logic_vector((bitlength-1) downto 0));
end mux8_to_1;

architecture a1 of mux8_to_1 is
begin
p1: process (sel, d0_in, d1_in, d2_in, d3_in, d4_in, d5_in, d6_in, d7_in)
	begin
		if sel = "0000" then
			d_out <= d0_in;
		elsif sel = "0001" then
			d_out <= d1_in;
		elsif sel = "0010" then
			d_out <= d2_in;
		elsif sel = "0011" then
			d_out <= d3_in;
		elsif sel = "0100" then
			d_out <= d4_in;
		elsif sel = "0101" then
			d_out <= d5_in;
		elsif sel = "0110" then
			d_out <= d6_in;
		elsif sel = "0111" then
			d_out <= d7_in;
		elsif sel = "1000" then
			d_out <= d8_in;
		elsif sel = "1001" then
			d_out <= d9_in;
		elsif sel = "1010" then
			d_out <= d10_in;
		elsif sel = "1011" then
			d_out <= d11_in;
		elsif sel = "1100" then
			d_out <= d12_in;
		elsif sel = "1101" then
			d_out <= d13_in;
		elsif sel = "1110" then
			d_out <= d14_in;
		elsif sel = "1111" then
			d_out <= d15_in;

		else
			d_out <= d0_in;
		end if;
	end process p1;
end a1;

