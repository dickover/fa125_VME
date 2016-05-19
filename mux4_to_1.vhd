----- 4 to 1 multiplexor ('bitlength' wide)

-- sel = '0', d0_in -> d_out
-- sel = '1', d1_in -> d_out 
-- sel = '2', d2_in -> d_out 
-- sel = '3', d3_in -> d_out 

library ieee;
use ieee.std_logic_1164.all;

entity mux4_to_1 is
	generic( bitlength: integer );
	port( d0_in: in std_logic_vector((bitlength-1) downto 0);
		  d1_in: in std_logic_vector((bitlength-1) downto 0);
		  d2_in: in std_logic_vector((bitlength-1) downto 0);
		  d3_in: in std_logic_vector((bitlength-1) downto 0);
			sel: in std_logic_vector(1 downto 0);
		  d_out: out std_logic_vector((bitlength-1) downto 0));
end mux4_to_1;

architecture a1 of mux4_to_1 is
begin
p1: process (sel, d0_in, d1_in, d2_in, d3_in)
	begin
		if sel = "00" then
			d_out <= d0_in;
		elsif sel = "01" then
			d_out <= d1_in;
		elsif sel = "10" then
			d_out <= d2_in;
		elsif sel = "11" then
			d_out <= d3_in;
		else
			d_out <= d0_in;
		end if;
	end process p1;
end a1;

