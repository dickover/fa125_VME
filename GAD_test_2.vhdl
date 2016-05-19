
-- first attempt to obtain a geographical address from the shift register 

--------------------------------------------------------------------------------
--------------------------------------library----------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.miscellaneous.all;
--------------------------------------------------------------------------------
-------------------------------Component declaration ---------------------------
entity gad1 is
 port(
			clk: in std_logic; -- use 1 Mhz
			gad: in std_logic;
         ld_n_d15: out std_logic;
			ga_ld_en: out std_logic;
			clk_d07: out std_logic;
			ga_clk_en: out std_logic;
			gad_addr: out std_logic_vector(7 downto 0)
			);           
end gad1;
--------------------------------------------------------------------------------
----------------------------------architecture----------------------------------
architecture gad1_0 of gad1 is
	type x_type is (start,DA,A,B,C,D,E,F,G,H,finish);
	signal x: x_type := start;
	signal n: integer range 0 to 799999 := 99999;  -- init value here gives power-on delay
	signal GAH,GA4,GA3,GA2,GA1,GA0,GAP,swB,swA: std_logic;
--	signal GA4,GA3,GA2,GA1,GA0,GAP,swB,swA: std_logic;
	signal clk_edge: std_logic:='0';
	signal k: integer range 0 to 63;

--------------------------------------------------------------------------------
------------------------------------process-------------------------------------
begin
   process(clk)
   begin
	
		if clk'event and clk='1' then
         if n=0 then
--------------------------------------------------------------------------------
------------------------------------case----------------------------------------  
				case x is 
					when start =>	
						if clk_edge = '0' then
							clk_d07 <= '1';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							x <= start;
						else
							clk_d07 <= '0';
							ld_n_d15 <= '0';
							clk_edge <= not clk_edge;
							x <= H;
						end if;
					when H =>
						if clk_edge = '0' then 
							clk_d07 <= '1';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GAH <= gad;
							x <= H;
						else
							clk_d07 <= '0';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GAH <= gad;
							x <= G;
						end if;
					when G =>
						if clk_edge = '0' then 
							clk_d07 <= '1';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							swA <= gad;
							x <= G;
						else
							clk_d07 <= '0';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							swA <= gad;
							x <= F;
						end if;
					when F =>
						if clk_edge = '0' then 
							clk_d07 <= '1';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							swB <= gad;
							x <= F;
						else
							clk_d07 <= '0';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							swB <= gad;
							x <= E;
						end if;
					when E =>
						if clk_edge = '0' then 
							clk_d07 <= '1';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GAP <= gad;
							x <= E;
						else
							clk_d07 <= '0';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GAP <= gad;
							x <= D;
						end if;
					when D =>
						if clk_edge = '0' then 
							clk_d07 <= '1';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GA0 <= gad;
							x <= D;
						else
							clk_d07 <= '0';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GA0 <= gad;
							x <= C;
						end if;
					when C =>
						if clk_edge = '0' then 
							clk_d07 <= '1';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GA1 <= gad;
							x <= C;
						else
							clk_d07 <= '0';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GA1 <= gad;
							x <= B;
						end if;
					when B =>
						if clk_edge = '0' then 
							clk_d07 <= '1';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GA2 <= gad;
							x <= B;
						else
							clk_d07 <= '0';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GA2 <= gad;
							x <= A;
						end if;
					when A =>
						if clk_edge = '0' then 
							clk_d07 <= '1';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GA3 <= gad;
							x <= A;
						else
							clk_d07 <= '0';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GA3 <= gad;
							x <= DA;
						end if;
					when DA =>
						if clk_edge = '0' then 
							clk_d07 <= '1';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GA4 <= gad;
							x <= DA;
						else
							clk_d07 <= '0';
							ld_n_d15 <= '1';
							clk_edge <= not clk_edge;
							GA4 <= gad;
							x <= finish;
						 end if;	
					when finish =>
							--clk_d07 <= 'Z';
							--ld_n_d15 <= 'Z';
						--ld_n_d15 <= 'Z';
						--gad_addr <= GA4&GA3&GA2&GA1&GA0&GAP&swB&swA;
						
				end case;
--------------------------------------------------------------------------------
-----------------------------------end case-------------------------------------
			else
            n <= n-1;
         end if;
      end if;		
   end process;

ga_clk_en <= '1' when (x = start or x = DA or x = A or x = B or x = C or x = D or x = E or x = F or x = G) else '0'; 
--ga_ld_en <= '1' when (x = start or x = DA or x = A or x = B or x = C or x = D or x = E or x = F or x = G) else '0';

gad_addr <= swB&swA&GAP&GA4&GA3&GA2&GA1&GA0; 
--gad_addr <= GA2&GA3&GA0&GA1&swA&swB&GA4&GAP;
--clk_d07 <= clk when ga_clk_en = '1' else (others => 'Z');
--ld_n_d15 <= ld_n_d15_t when ga_clk_en ='1' else (others => 'Z');

end architecture gad1_0;





