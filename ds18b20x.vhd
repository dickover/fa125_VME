-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- + This is a DS18B20 hardware interface to read serial number at startup and     +
-- + then periodically read temperature.                                           +
-- + Developed for the ADC125 for GlueX but hopefully also useable in other        +
-- + projects...                                                                   +
-- + Gerard Visser, Indiana University                                             +
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- $Id: ds18b20x.vhd 6 2010-06-28 20:52:27Z gvisser $

-- to do: This design is functional but doesn't seem to use SRL16's in synthesis (and probably there are other
-- ways to improve). It should be fixed, this takes an excessive amount of resources like it is. But I'm not
-- at the resource limit and I'm behind schedule, so this is deferred for now.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.miscellaneous.all;

entity ds18b20x is
   port (
      clk: in std_logic;                -- 1 MHz clock (frequency does matter here)
      onewirebus: inout std_logic;      -- the bus (pullup resistor is expected)
      serial: out std_logic_vector(47 downto 0);  -- serial number out
      temperature : out std_logic_vector(11 downto 0);  -- temperatur out
      update: in std_logic);            -- ok to update temperature
end ds18b20x;

architecture ds18b20x_0 of ds18b20x is
   type x_type is (por,a_initstb,a_initrec,a_wstb,a_wbit,a_wrec,a_rstb,a_rbit,a_rrec,
                   b_initstb,b_initrec,b_wstb,b_wbit,b_wrec,delay800,
                   c_initstb,c_initrec,c_wstb,c_wbit,c_wrec,c_rstb,c_rbit,c_rrec);
   signal x: x_type := por;
   signal n: integer range 0 to 799999 := 99999;  -- init value here gives power-on delay
   signal k: integer range 0 to 63;
   signal wdat: std_logic_vector(15 downto 0);
   signal rdat: std_logic_vector(63 downto 0);
   signal temperature_int: std_logic_vector(11 downto 0);
begin
   process(clk)
   begin
      if clk'event and clk='1' then
         if n=0 then
            case x is
               when por =>
                  x <= a_initstb;
                  n <= 500;
               -- get serial number
               when a_initstb =>          -- init pulse low
                  x <= a_initrec;
                  n <= 500;
               when a_initrec =>          -- init high (PD pulse response here, ignored)
                  wdat <= X"0033";      -- READ_ROM command
                  k <= 7;               -- this will be 1 byte only!
                  n <= 1;
                  x <= a_wstb;
               when a_wstb =>             -- write time slot, strobe interval 2us low
                  n <= 69;
                  x <= a_wbit;
               when a_wbit =>             -- write time slot, data bit 70us
                  n <= 1;
                  x <= a_wrec;
               when a_wrec =>             -- recovery time 2us
                  if k=0 then
                     n <= 1;
                     k <= 63;
                     x <= a_rstb;
                  else
                     k <= k-1;
                     wdat <= '0'&wdat(15 downto 1);
                     n <= 1;
                     x <= a_wstb;
                  end if;
               when a_rstb =>             -- read time slot, strobe interval 2 us low
                  n <= 12;
                  x <= a_rbit;
               when a_rbit =>             -- read time slot, data bit setup 13 us
                  rdat <= onewirebus&rdat(63 downto 1);
                  n <= 54;
                  x <= a_rrec;
               when a_rrec =>             -- recovery time 55 us (total read time 70 us)
                  if k=0 then
                     serial <= rdat(55 downto 8);
                     n <= 500;
                     x <= b_initstb;
                  else
                     k <= k-1;
                     n <= 1;
                     x <= a_rstb;
                  end if;
               -- convert temperature
               when b_initstb =>          -- init pulse low
                  x <= b_initrec;
                  n <= 500;
               when b_initrec =>          -- init high (PD pulse response here, ignored)
                  wdat <= X"44cc";        -- SKIP_ROM & CONVERT command // little endian!
                  k <= 15;
                  n <= 1;
                  x <= b_wstb;
               when b_wstb =>             -- write time slot, strobe interval 2us low
                  n <= 69;
                  x <= b_wbit;
               when b_wbit =>             -- write time slot, data bit 70us
                  n <= 1;
                  x <= b_wrec;
               when b_wrec =>             -- recovery time 2us
                  if k=0 then
                     n <= 799999;
                     x <= delay800;
                  else
                     k <= k-1;
                     wdat <= '0'&wdat(15 downto 1);
                     n <= 1;
                     x <= b_wstb;
                  end if;
               when delay800 =>
                  n <= 500;
                  x <= c_initstb;
               -- get temperature
               when c_initstb =>          -- init pulse low
                  x <= c_initrec;
                  n <= 500;
               when c_initrec =>          -- init high (PD pulse response here, ignored)
                  wdat <= X"becc";        -- SKIP_ROM & READ_PAD command // little endian!
                  k <= 15;
                  n <= 1;
                  x <= c_wstb;
               when c_wstb =>             -- write time slot, strobe interval 2us low
                  n <= 69;
                  x <= c_wbit;
               when c_wbit =>             -- write time slot, data bit 70us
                  n <= 1;
                  x <= c_wrec;
               when c_wrec =>             -- recovery time 2us
                  if k=0 then
                     n <= 1;
                     k <= 63;   --WELL we could read only 12 is enough!
                     x <= c_rstb;
                  else
                     k <= k-1;
                     wdat <= '0'&wdat(15 downto 1);
                     n <= 1;
                     x <= c_wstb;
                  end if;
               when c_rstb =>             -- read time slot, strobe interval 2 us low
                  n <= 12;
                  x <= c_rbit;
               when c_rbit =>             -- read time slot, data bit setup 13 us
                  rdat <= onewirebus&rdat(63 downto 1);
                  n <= 54;
                  x <= c_rrec;
               when c_rrec =>             -- recovery time 55 us (total read time 70 us)
                  if k=0 then
                     temperature_int <= rdat(11 downto 0);
                     n <= 500;
                     x <= b_initstb;    -- all done, go convert again
                  else
                     k <= k-1;
                     n <= 1;
                     x <= c_rstb;
                  end if;
            end case;
         else
            n <= n-1;
         end if;
         if update='1' then
            temperature <= temperature_int;
         end if;
      end if;
   end process;
   -- careful - check that we don't get some combinatorial logic encoding glitch here:
   onewirebus <= '0' when (x=a_initstb
                           or x=a_wstb or (x=a_wbit and wdat(0)='0')
                           or x=a_rstb
                           or x=b_initstb
                           or x=b_wstb or (x=b_wbit and wdat(0)='0')
                           or x=c_initstb
                           or x=c_wstb or (x=c_wbit and wdat(0)='0')
                           or x=c_rstb
                           ) else 'Z';
   
end architecture ds18b20x_0;
