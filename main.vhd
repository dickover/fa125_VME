-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- + Indiana University CEEM    /    GlueX/Hall-D Jefferson Lab                    +
-- + 72 channel 12/14 bit 125 MSPS ADC module with digital signal processing       +
-- + Main FPGA (VME interface, data FIFO read, miscellaneous controls)             +
-- + Gerard Visser - gvisser@indiana.edu - 812 855 7880                            +
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- $Id: main.vhd 14 2012-04-24 15:38:54Z gvisser $

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library unisim;
use unisim.vcomponents.all;
library work;
use work.miscellaneous.all;

entity main is
    generic(svnver: integer := 1);
   port(
		busy: out std_logic;
	   a: inout std_logic_vector(15 downto 1); -- change for serial fix
      lword_n: inout std_logic;
      d: inout std_logic_vector(31 downto 0);
      am: in std_logic_vector(5 downto 0);
      iack_n,as_n,write_n,dtacki_n,berri_n: in std_logic;
      ds0_n: in std_logic;
		ds1_n: in std_logic;
      iackin_n: in std_logic;
      iackout_n,irq1,irq2,irq7: out std_logic;
      gad: in std_logic;                -- from 74'165 reading GA and option jumpers
--		gad_addr: out std_logic_vector(7 downto 0);
      -- clock
      clk, clk1MHz, clk40MHz: in std_logic;               -- 80 MHz local oscillator
      -- spare signals between here and processor fpga
      --spare0: out std_logic;
	   --spare1: in std_logic;
      -- controls interface and programming interface to FE and proc fpga's
      progo_n: out std_logic;
      softrst: out std_logic;           -- this is also din to processor FPGA
      absclk: out std_logic;            -- this is also cclk to FE FPGA's
      absin: out std_logic;             -- this is also din to FE FPGA's
      psclk: out std_logic;
      psin: out std_logic;              -- this is also cclk to processor FPGA
      asout,bsout,psout: in std_logic;

      -- configuration memory interface - these are for user-mode access of the usual config pins
      din: in std_logic;
      cclk,cso_n,mosi: out std_logic;

      -- power supply stuff
		vp3r0a_en_n: out std_logic;
		swphasea,swphaseb,swphasec,swphased: out std_logic;
      
      -- other slow controls stuff
      selaclk: out std_logic_vector(1 downto 0);  -- adc sample clock source select
      dacld,dacsclk,adacsi,bdacsi: out std_logic;  -- DAC control (note: bdacsi is on init_n pin)
      atid,btid: inout std_logic;       -- DS18B20 temperature/serial # chips

	  -- register passing to new vme int
	  ga: out std_logic_vector(7 downto 0);
	  d_stat: out std_logic_vector(31 downto 0);
	  m_swapctrl, m_csr, m_pwrctrl, m_dacctrl: in std_logic_vector(31 downto 0);
	  proc_fifo_test, proc_csr: in std_logic_vector(31 downto 0);
	  -- data fifo
--      fwclk,fwen_n: in std_logic;
--      fd: in std_logic_vector(17 downto 16);
--      paf_n,pae_n,or_n: in std_logic;
--      ren_n: out std_logic;
      --fq: in std_logic_vector(35 downto 0);
		
      -- front panel led's
      led_vme_n,led_drdy_n: out std_logic;
		--a32_ba: in std_logic_vector(31 downto 0);
		write_sig, read_sig: in std_logic
		);
		
--   attribute period: string;
--   attribute period of clk: signal is "12.5ns";
end main;

architecture main_0 of main is
 
   component ds18b20x
      port(
         clk: in std_logic;
         onewirebus: inout std_logic;
         serial: out std_logic_vector(47 downto 0);
         temperature: out std_logic_vector(11 downto 0);
         update: in std_logic);
   end component;
	
--   component ila1
--      port(
--         control: inout std_logic_vector(35 downto 0);
--         clk: in std_logic;
--         trig0: in std_logic_vector(15 downto 0));
--   end component;
--	
--   component icon1
--      port(
--         control0: inout std_logic_vector(35 downto 0));
--   end component;
--	
   component gad1
      port(
			gad: in std_logic;
			clk: in std_logic;
         ld_n_d15: out std_logic;
			ga_ld_en: out std_logic;
			clk_d07: out std_logic;
			ga_clk_en: out std_logic;
         gad_addr: out std_logic_vector(7 downto 0));
   end component;
	
--component vmex
--      port(
--         clk: in std_logic;
--         a: inout std_logic_vector(31 downto 1);
--         lword_n: inout std_logic;
--         d: in std_logic_vector(31 downto 0);
--         am: in std_logic_vector(5 downto 0);
--         iack_n,as_n,write_n,dtacki_n,berri_n: in std_logic;
--         ds0_n, ds1_n: in std_logic;
--			busy: out std_logic; 
--         iackin_n: in std_logic;
--         led_vme: out std_logic;
--         do_swap: in std_logic;
--         cbase: in std_logic_vector(23 downto 16);
--         ca: out std_logic_vector(15 downto 2);
--         cd: inout std_logic_vector(31 downto 0);
--         crd,cwr: out std_logic;
--			d_stat,test_stat: out std_logic_vector(31 downto 0);
--         cack: in std_logic;
--			scack: in std_logic);
--	end component;
	
   signal control: std_logic_vector(35 downto 0);
   signal iladat: std_logic_vector(15 downto 0);
   signal ca_int: integer range 0 to 2**14-1;
   signal cd: std_logic_vector(31 downto 0);
	signal test_stat: std_logic_vector(31 downto 0);
	signal cack, crd, cwr: std_logic;
   signal swapctl, pwrctl, dacctl: std_logic_vector(31 downto 0) := X"00000000";
	signal csr: std_logic_vector(31 downto 0) := X"00000003"; -- this makes default selaclk = "11" 125Mhz local
   signal led_vme: std_logic;
	signal do_swap: std_logic;
   constant ADDR_ID:       std_logic_vector(15 downto 2) := "00000000000000";
   constant ADDR_SWAPCTL:  std_logic_vector(15 downto 2) := "00000000000001";
   constant ADDR_VER:      std_logic_vector(15 downto 2) := "00000000000010";
   constant ADDR_CSR:      std_logic_vector(15 downto 2) := "00000000000011";
   constant ADDR_PWRCTL:   std_logic_vector(15 downto 2) := "00000000000100";
   constant ADDR_DACCTL:   std_logic_vector(15 downto 2) := "00000000000101";
   constant ADDR_SER:      std_logic_vector(15 downto 2) := "000000000010--";
   constant ADDR_TMP:      std_logic_vector(15 downto 2) := "0000000000110-";
   constant ADDR_GAR:      std_logic_vector(15 downto 2) := "00000000001110";
   constant ADDR_A32BAR:   std_logic_vector(15 downto 2) := "00000000001111";
	--constant ADDR_CLKSELCTRL:std_logic_vector(15 downto 2):= "00000000000011";
	
   constant NADDR_SC: std_logic_vector(15 downto 2) := "0000----------";  -- addresses NOT to serial control
	
   constant ADDR_proc_ID: std_logic_vector(15 downto 2) := "11010000000000";	
	constant ADDR_proc_TEST: std_logic_vector(15 downto 2) := "11010000000010";	
	signal pick: std_logic_vector(3 downto 0);
	signal ga_clk_en, ga_ld_en, ld_n_d15, clk_d07: std_logic; 
	signal gad_addr, gad_inst: std_logic_vector(7 downto 0);

   signal main_temperature, mezz_temperature: std_logic_vector(11 downto 0);
   signal main_serial, mezz_serial: std_logic_vector(47 downto 0);
  
   signal scack: std_logic;
   signal cclk_int,en_cfg_fe,en_cfg_proc,cfg_busy: std_logic;
	signal ca: std_logic_vector(15 downto 2);


--*************************BEGIN****************************************************	
begin
   assert (svnver>=0) and (svnver<=65535) report "svnver code out of range" severity FAILURE;

      -- power supply control **BE CAREFUL HERE**
   ps_control: block
      signal n: integer range 0 to 12;
      signal k: integer range 0 to 5;
   begin
      process(clk)
      begin
         if clk'event and clk='1' then
            if n=12 then
               n <= 0;
               if k=5 then
                  k <= 0;
               else
                  k <= k+1;
               end if;
            else
               n <= n+1;
            end if;
            swphasea <= bool2std(k=0);
            swphaseb <= bool2std(k=2);
            swphasec <= bool2std(k=4);
            swphased <= bool2std(k=3);
         end if;
      end process;
		
      vp3r0a_en_n <= not bool2std(pwrctl=X"3000abcd");  -- key for +3.0V power on
		
   end block ps_control;
   -- end of power supply control

   -- ++++++++++++++++++++++++++++++++++++++++++++
   -- + config the frontend and processor FPGA's +
   -- ++++++++++++++++++++++++++++++++++++++++++++
   slave_cfg_1: block
      signal pscl: integer range 0 to 2;  -- prescale clock to 26.7 MHz ( ==> CCLK @ 13.3 MHz)
      type cfg_x_type is (sdelay,init,sel,cl,ch,dsel,psel,pcl,pch,pdsel);
      signal cfg_x: cfg_x_type := sdelay;
      signal k: integer range 0 to 2**24-1 := 2500000;  -- init to 94 ms delay value
      signal cso_n_int: std_logic := '1';  -- local signal so we don't have to init a port (ugly)
      signal sin_sr: std_logic_vector(31 downto 0);
   begin
      process(clk) --clk clk40MHz
      begin
         if clk'event and clk='1' then
            if pscl=0 then
               pscl <= 2;
               case cfg_x is
                  when sdelay =>
                     if k=0 then
                        progo_n <= '1';
                        k <= 266666;  -- 10 ms delay while slaves release init
                        cfg_x <= init;
                     else
                        k <= k-1;
                        progo_n <= '0';
                        cfg_busy <= '1';
                     end if;
                  when init =>
                     k <= k-1;
                     cclk_int <= '1';
                     if k=0 then
                        cso_n_int <= '0';
                        en_cfg_fe <= '1';
                        cfg_x <= sel;                    
                     end if;
                  when sel =>
                     cclk_int <= '0';
                     sin_sr <= X"0b0e3800";  -- read FE FPGA cfg data starting page = 038e
                     k <= 40+6441600;   -- bit count for FE FPGA (XC6LX25) rounded up to whole page
                     cfg_x <= cl;
                  when cl =>
                     cclk_int <= '1';
                     cfg_x <= ch;
                  when ch =>
                     if k=0 then
                        cso_n_int <= '1';
                        k <= 1;         -- for memory chip min CS# high requirement
                        en_cfg_fe <= '0';
                        cfg_x <= dsel;
                     else
                        cclk_int <= '0';
                        sin_sr <= sin_sr(30 downto 0)&'1';
                        k <= k-1;
                        cfg_x <= cl;
                     end if;
                  when dsel =>
                     k <= k-1;
                     if k=0 then
                        cso_n_int <= '0';
                        en_cfg_proc <= '1';
                        cfg_x <= psel;
                     end if;
                  when psel =>
                     cclk_int <= '0';
                     sin_sr <= X"0b3a6400";  -- read PROC FPGA cfg data starting page = 0e99
                     k <= 40+11721600;  -- bit count for PROC FPGA rounded up to whole page
                     cfg_x <= pcl;
                  when pcl =>
                     cclk_int <= '1';
                     cfg_x <= pch;
                  when pch =>
                     if k=0 then
                        cso_n_int <= '1';
                        en_cfg_proc <= '0';
                        cfg_busy <= '0';
                        cfg_x <= pdsel;
                     else
                        cclk_int <= '0';
                        sin_sr <= sin_sr(30 downto 0)&'1';
                        k <= k-1;
                        cfg_x <= pcl;
                     end if;
                  when pdsel =>         -- terminal state, just stay here
               end case;
            else
               pscl <= pscl-1;
            end if;
            softrst <= din;             -- LATER if softrst functionality is used should be softrst_n I guess
         end if;
      end process;
      cso_n <= cso_n_int;
      mosi <= sin_sr(31);
      cclk <= cclk_int;
   end block slave_cfg_1;

   -- generic chipscope placeholder (will surely be used again)
--   ila_0: ila1 port map (
--      control => control,
--      clk => clk,
--      trig0 => iladat);
--   icon_0: icon1 port map (
--      control0 => control);
--   iladat(0) <= din;
--   iladat(15 downto 1) <= (others => '0');

   -- local oscillator clock source only, for now (eventually select from a register)
   --selaclk <= csr(1 downto 0); -- should default "11" 
   led_vme_n <= not led_vme;
   led_drdy_n <= not cfg_busy; 
   ca_int <= to_integer(unsigned(ca));

-----------------------------------------------------------------------------
-- main status reg, variables passed to new interface from vmex as 'd_stat'--*************!!!!!!!!***********
-----------------------------------------------------------------------------	

	cd <= X"adc12500" when std_match(ca,ADDR_ID) else (others => 'Z'); --	status_main_id
	cd <= X"0002000F" when std_match(ca,ADDR_VER) else (others => 'Z'); -- m_ver was &std_logic_vector(to_unsigned(svnver,16))
	cd <= std_logic_vector(resize(signed(main_temperature),32))
         when read_sig='1' and std_match(ca,ADDR_TMP) and ca(2)='0' else (others => 'Z'); -- m_temp1 
   cd <= std_logic_vector(resize(signed(mezz_temperature),32))
         when read_sig='1' and std_match(ca,ADDR_TMP) and ca(2)='1' else (others => 'Z'); -- m_temp2	
	cd <= X"0000"&main_serial(47 downto 32) when read_sig='1' and std_match(ca,ADDR_SER) and ca(3 downto 2)="00" else (others => 'Z');
   cd <= main_serial(31 downto 0) when read_sig='1' and std_match(ca,ADDR_SER) and ca(3 downto 2)="01" else (others => 'Z');
   cd <= X"0000"&mezz_serial(47 downto 32) when read_sig='1' and std_match(ca,ADDR_SER) and ca(3 downto 2)="10" else (others => 'Z');
   cd <= mezz_serial(31 downto 0) when read_sig='1' and std_match(ca,ADDR_SER) and ca(3 downto 2)="11" else (others => 'Z');
----------------may not need, new interface can read control variables from 'control example'
	cd <= csr when read_sig='1' and std_match(ca,ADDR_CSR) else (others => 'Z');
	cd <= swapctl when read_sig='1' and std_match(ca,ADDR_SWAPCTL) else (others => 'Z');
	cd <= pwrctl when read_sig='1' and std_match(ca,ADDR_PWRCTL) else (others => 'Z');
   cd <= X"000000"&"000"&gad_addr(4 downto 0) when read_sig='1' and std_match(ca,ADDR_GAR) else (others => 'Z'); -- bit shiftted
	--cd <= a32_ba when read_sig='1' and std_match(ca,ADDR_A32BAR) else (others => 'Z');
--------------------------------------------------------------------------------------

-- m_*** values come from new interface, function now redundant? works for now.
   process(clk40MHz) --clk --clk40MHz
   begin
      if clk40MHz'event and clk40MHz='1' then
         if write_sig='1' and std_match(ca,ADDR_CSR) then
            --csr <= swapif(do_swap='1',m_csr);
				csr <= m_csr;
				selaclk <= csr(1 downto 0);
         elsif write_sig='1' and std_match(ca,ADDR_SWAPCTL) then
            --swapctl <= swapif(do_swap='1',m_swapctrl);
				swapctl <= X"00000000"; --NIX DO_SWAP!!!!
         elsif write_sig='1' and std_match(ca,ADDR_PWRCTL) then
            --pwrctl <= swapif(do_swap='1',m_pwrctrl);
				pwrctl <= m_pwrctrl;
         elsif write_sig='1' and std_match(ca,ADDR_DACCTL) then
            --dacctl <= swapif(do_swap='1',m_dacctrl);
				dacctl <= m_dacctrl;
         end if;
      end if;
   end process;

   --do_swap <= bool2std(swapctl/=X"00000000");
	
   dacld <= not dacctl(0);
   dacsclk <= dacctl(1);
   adacsi <= dacctl(2);
   bdacsi <= dacctl(3);

---------------------------------------------------------------------------
--------------------------------GAD----------------------------------------
-- does the trick, could be cleaner??--------------------------------------

gs1: gad1 port map(gad => gad, clk => clk1MHz, ld_n_d15 => ld_n_d15, ga_ld_en => ga_ld_en,
						 clk_d07 => clk_d07, ga_clk_en => ga_clk_en, gad_addr => gad_addr);
ga <= gad_addr;

d(15 downto 0) <= ld_n_d15&"0000000"&clk_d07&"0000000" when ga_clk_en = '1' else (others => 'Z');
--d(15 downto 0) <= ld_n_d15&"0000000"&"-0000000" when ga_clk_en ='1' else (others => 'Z');

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
   -- temperature & serial number for main and mezzanine boards
   -- SHOULD use 'update' esp if interlock added later
   -- NOTE that temperature readout only works IF 3.0V power is enabled! (maybe fix in new pcb rev?)
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
   ts1: ds18b20x port map(clk => clk1MHz,onewirebus => atid, serial => main_serial,
                          temperature => main_temperature,update => '1');
   ts2: ds18b20x port map(clk => clk1MHz,onewirebus => btid, serial => mezz_serial,
                          temperature => mezz_temperature,update => '1');
-----------------------------------------------------------------------------
--------------------Serial control block-------------------------------------
-----------------------------------------------------------------------------
   sc1: block
      type scmx_type is (idle,low,high,finish);
      signal scmx: scmx_type;
      signal absclk_l,psclk_l: std_logic := '1';  -- local signal so we don't have to init a port (ugly)
      signal k: integer range 0 to 50;
      signal wreg: std_logic_vector(47 downto 0);
      signal rreg: std_logic_vector(32 downto 1);
      signal asout_r,bsout_r,psout_r: std_logic;
		
   begin
      process(clk) --clk clk40MHz
      begin
         if clk'event and clk='1' then
            if (write_sig='0' and read_sig='0') then
               scmx <= idle;
               absclk_l <= cclk_int or not en_cfg_fe;
               psclk_l <= '1';
               -- need to check that absin/psin are consistently idled high not low (or better said, that it's
               -- ok to do that, as well as that it is so!)
               absin <= din or not en_cfg_fe;
               psin <= cclk_int or not en_cfg_proc;

            else
               case scmx is
                  when idle => 
                     if ((write_sig='1' or read_sig='1') and not std_match(ca,NADDR_SC)) then 
                        absin <= '0'; psin <= '0'; wreg <= '0'&write_sig&ca&cd;
								--absin <= '0'; psin <= '0'; wreg <= '0'&cwr&ca&X"ADCDEF55";
                        k <= 50;
                        scmx <= low;
                        absclk_l <= '0'; psclk_l <= '0';
                     else
                        absclk_l <= '1'; psclk_l <= '1';
								--absin <= '1'; psin <= '1'; -- CHANGE!!!!!
                     end if;
                  when low =>
                     scmx <= high;
                     absclk_l <= '1'; psclk_l <= '1';
                     asout_r <= asout; bsout_r <= bsout; psout_r <= psout;  -- i.e., on sclk RISING edge
                     rreg <= rreg(31 downto 1)&(asout_r and bsout_r and psout_r);
                  when high =>
                     if k=0 then
                        scmx <= finish;
                     else
                        k <= k-1;
                        absin <= wreg(47); psin <= wreg(47); wreg <= wreg(46 downto 0)&'1';
                        scmx <= low;
                        absclk_l <= '0'; psclk_l <= '0';
                     end if;
                  when finish =>        -- just wait for VME cycle to terminate
								scmx <= idle; -- change added
               end case;
            end if;
         end if;
      end process;
      absclk <= absclk_l; psclk <= psclk_l;
      cd <= rreg(32 downto 1) when (scmx=finish and read_sig = '1') else (others => 'Z');
      --scack <= bool2std(scmx=finish and (asout_r and bsout_r and psout_r)='0'); -- not needed anymore?
		busy <= '1' when (scmx=low or scmx=high) else '0'; -- added to hold off dtack through new interface --or scmx=idle 
		led_vme <= '1' when (scmx/=idle) else '0'; -- probably of better use somewhere else but had to give a home
   end block sc1;
-- old vmex stuff-------------------------------------------------------
	
--cd <= swapif(do_swap='1',d) when write_sig='1' else (others => 'Z');
cd <= d when write_sig='1' else (others => 'Z');

--d_stat <= swapif(do_swap='1',cd) when read_sig='1' else (others => 'Z');
d_stat <= cd when read_sig='1' else (others => 'Z');
ca <= a(15 downto 2);	
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
------------acknowledge bit for serial delay and address match----------------
--needed for serial comm but address matching is redundent in the new interface
--also, the new registers are already setup as status/control so vmex could be refined to handle serial comm exclusively? 
--played around with this some and have some ideas, but this works for now. Could clean up later, use discrete variables?
-----------------------------------------------------------------------------
--	 cack <= ((crd or cwr) and bool2std(std_match(ca,ADDR_CSR)
--                                      or std_match(ca,ADDR_SWAPCTL)
--                                      or std_match(ca,ADDR_PWRCTL)))
--           or (crd and bool2std(std_match(ca,ADDR_ID)
--                                or std_match(ca,ADDR_VER)
--                                or std_match(ca,ADDR_SER)
--                                or std_match(ca,ADDR_TMP)
--										  or std_match(ca,ADDR_GAR)
--										  or std_match(ca,ADDR_A32BAR)))
--           or (cwr and bool2std(std_match(ca,ADDR_DACCTL)))
--           or scack;

----------------------------------------------------------------------------------------------
-- old vme interface, (was) hacked to pass 'busy' to new interface for waiting on onboard serial comm 
-- Busy now handled in serial control block, time to remove redundancy? 
-- divide out dstat to seperate registers in new interface instead of using all in stat0?
----------------------------------------------------------------------------------------------
-- vmex_1: vmex
--      port map (clk => clk, a => a, lword_n => lword_n, d => d,
--                am => am, iack_n => iack_n, as_n => as_n, write_n => write_n,
--                dtacki_n => dtacki_n, berri_n => berri_n, ds0_n => ds0_n, ds1_n => ds1_n,
--					 iackin_n => iackin_n,
--                led_vme => led_vme, do_swap => do_swap, 
--                cbase => gad_inst, -- take from ga and bit shifted by 19, i.e. slot 03 = 180000
--                ca => ca, cd => cd,  crd => crd, cwr => cwr, cack => cack, scack => scack,
--					 d_stat => d_stat, test_stat => test_stat); --busy => busy

end architecture main_0;
