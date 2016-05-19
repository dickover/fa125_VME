-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- + This is a relatively generic VME interface developed for the ADC125 for GlueX +
-- +  but hopefully also useable in other projects...                              +
-- + Gerard Visser, Indiana University                                             +
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- $Id: vmex.vhd 6 2010-06-28 20:52:27Z gvisser $

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.miscellaneous.all;

entity vmex is
   port (
      clk: in std_logic;
      -- VME interface signals
      a: inout std_logic_vector(31 downto 1);
      lword_n: inout std_logic;
      d: in std_logic_vector(31 downto 0);
      am: in std_logic_vector(5 downto 0);
      iack_n,as_n,write_n,dtacki_n,berri_n: in std_logic;
      ds0_n: in std_logic;
		ds1_n: in std_logic;
      iackin_n: in std_logic;
      -- control signals & led
      led_vme: out std_logic;
      do_swap: in std_logic;            -- endianness swap control '1' means do it
      cbase: in std_logic_vector(23 downto 16);  -- base for A24 accesses
      -- local control bus (connected to A24:D32) - all signals synchronous to clk
      ca: out std_logic_vector(15 downto 2);
      cd: inout std_logic_vector(31 downto 0);
      crd,cwr: out std_logic;
      cack: in std_logic;
		scack: in std_logic;
      d_stat, test_stat: out std_logic_vector(31 downto 0);
		busy: out std_logic
      );
end vmex;

-- protocol for the local control bus interface
--
-- clk  ___/---\___/---\___/---\___/---\___/---\___/---\___/---\___/---\___/---\___/---\___/---\
-- ca    X  |  addr
-- cd    Z                      | data       |  Z
-- crd  ____/-----------------------\_______________
-- cwr  ____________________________________________
-- cack ________________________/-------------\_______


architecture vmex_0 of vmex is
   constant AM_A24_USR_DATA: std_logic_vector(5 downto 0) := "111001";
   constant AM_A24_SUP_DATA: std_logic_vector(5 downto 0) := "111101";
   type mainx_type is (idle,x0,start,rd0,rd1,rd2,rd3,wr0,wr1,wr2, wr_test);
   signal mainx: mainx_type := idle;
   signal cd_r: std_logic_vector(cd'range);
   signal k: integer range 0 to 7;

begin

   process(clk)
   begin
      if clk'event and clk='1' then
         -- The berri_n='0' abort conditions below could be gathered here into one line with the case
         -- statement in the else part. BUT I'm not sure yet how this will look when I put in the A32 space
         -- and the block transfer modes. So for now I've just written it in individually IN ALL states. The
         -- whole thing should be examined and simplified later. Idea for now is get something that works,
         -- reliably, even if not pretty.
         case mainx is
            when idle =>
               if ((as_n='0') and (ds0_n='0') and (ds1_n='0') and (iack_n='1') and (am=AM_A24_USR_DATA)
                  and (a(23 downto 16)=cbase) and (dtacki_n='1') and (berri_n='1') ) then --and (a(15 downto 12) = ("1101" or "1000") ) / and (a(15 downto 12) /= "0000")
                  mainx <= x0;
					end if;
				when x0 =>
               if as_n='0' and ds0_n='0' and ds1_n='0' and iack_n='1' and am=AM_A24_USR_DATA
                  and a(23 downto 16)=cbase and dtacki_n='1' and berri_n='1' then
                  mainx <= start;  -- the condition is stable for 2 consecutive cycles
               else
                  mainx <= idle;
               end if;
            when start =>
               if dtacki_n='0' or berri_n='0' then
                  mainx <= idle;-- it wasn't ours after all...
               elsif lword_n='0' and cack='0' and write_n='0' then  -- A24:D32 write
                  mainx <= wr0;      -- ADDED stabilization cycles wr0 & rd0 (NEEDED STILL?)
               elsif lword_n='0' and cack='0' and write_n='1' then  -- A24:D32 read
                  mainx <= rd0;
                  -- elsif (other transaction types here)
               end if;
            when rd0 =>
               if berri_n='0' then
                  mainx <= idle;
               else
                  mainx <= rd1;						
               end if;
            when rd1 =>
               if berri_n='0' then
                  mainx <= idle;
               elsif cack='1' then
                  mainx <= rd2;
						k <= 2; 
						cd_r <= swapif(do_swap='1',cd);		-- check is this enough (setup time for data out)?
               end if;
            when rd2 =>                 -- here provide setup of data to dtack
              if berri_n='0' then
                  mainx <= idle;
               else
                  k <= k-1;
                if k=0 then
                     mainx <= rd3;
                  end if;
               end if;
            when rd3 =>
               -- of course this would hang if cack='1' forever... should be impossible
               if cack='0' and ((as_n='1' and ds0_n='1' and ds1_n='1') or berri_n='0') then
                  mainx <= idle;
	            end if;		
            when wr0 =>
               if berri_n='0' then
                  mainx <= idle;
               else
						k <= 2;
                  mainx <= wr_test;
               end if;
				when wr_test =>
              if berri_n='0' then
                  mainx <= idle;
               else
                  k <= k-1;
                if k=0 then
                     mainx <= wr1;
                  end if;
               end if;
            when wr1 =>
               if berri_n='0' then
                  mainx <= idle;
               elsif cack='1' then
                  mainx <= wr2;
               end if;
            when wr2 =>
               if ((as_n='1' and ds0_n='1' and ds1_n='1') or berri_n='0') then
                  mainx <= idle;
               end if;
         end case;
      end if;
   end process;
	
	ca <= a(15 downto 2);   -- well, it should be latched actually I think... 
	cwr <= '1' when mainx=wr1 else '0';
	crd <= '1' when mainx=rd1 else '0';
	cd <= swapif(do_swap='1',d) when mainx=start or mainx=wr0 or mainx=wr1 or mainx=wr_test else (others => 'Z');
	led_vme <= bool2std(mainx/=idle and mainx/=start);
	  
	d_stat <= cd_r when mainx=rd2 or mainx=rd3 else (others => 'Z'); -- used in control_example as stat0 reigister for all reads
--	busy <= '1' when mainx=start or mainx=x0 or mainx=rd0 or mainx=rd1 or mainx=rd2 or mainx=wr0 or mainx=wr_test or mainx=wr1 else '0';-- 
--	busy <= '1' when mainx=rd0 or mainx=rd1 or mainx=rd2 or mainx=rd3 or mainx=wr0 or mainx=wr1 or mainx=wr2 else '0';
	
end architecture vmex_0;
