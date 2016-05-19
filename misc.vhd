-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- + Indiana University CEEM    /    GlueX/Hall-D Jefferson Lab                    +
-- + 72 channel 12/14 bit 125 MSPS ADC module with digital signal processing       +
-- + Main FPGA misc package                                                        +
-- + Gerard Visser - gvisser@indiana.edu - 812 855 7880                            +
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- $Id: misc.vhd 12 2012-04-20 18:47:34Z gvisser $

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package miscellaneous is
   function bool2std(x: boolean) return std_logic;
   function swapif(doit: boolean; x: std_logic_vector(31 downto 0)) return std_logic_vector;
end package miscellaneous;

package body miscellaneous is
   function bool2std(x: boolean) return std_logic is
   begin
      if x then
         return '1';
      else
         return '0';
      end if;
   end function bool2std;
   function swapif(doit: boolean; x: std_logic_vector(31 downto 0)) return std_logic_vector is
   begin
      if doit then
         return x(7 downto 0)&x(15 downto 8)&x(23 downto 16)&x(31 downto 24);
      else
         return x;
      end if;
    end function swapif;
end package body miscellaneous;
