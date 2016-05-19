----- VME_example_TOP.vhd - EJ   8/4/10, 9/14/10, 9/20/10, 9/22/10, 10/25/10, 11/1/10, 6/27/12
----- VME interface has variable A24 local address size

-- VME data & strobes registered at output for reduced skew - 9/22/10
-- removal of latches + simplify to make timing analysis cleaner - 10/18/10
-- OUTPUT FIFO IS NOW EXTERNAL TO INTERFACE - 11/1/10
-- use files from FADC250 implementation - 6/27/12

-- integrated and adapted to fADC125 6/14/13 for testing and further developement

-- ver 0x10101 Raw mode
-- ver 0x10201 250 processing modes
-- ver 0x10202 250 processing modes, ch mask, pulser, playback, serial line bug fix
-- ver 0x10203 event cnt bug fix (change on proc)
-- ver 0x10207 bug fix here on MAIN, buffer overrun, changed block send SM, also bigger FIFOs on FE just cause
--......
--- ver 0x20007 bug fixes on fe 
--.......
--- ver 0x20009 Changed BLOCK_SEND_3 to BLOCK_SEND_NEW 

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
library unisim;
use unisim.vcomponents.all;
library work;
use work.miscellaneous.all;

  use IEEE.std_logic_unsigned.all; 
  use IEEE.std_logic_arith.all;

entity VME_example_TOP is
	port( 	 
				   clk: in std_logic;							 		-- clock in				 
		         a_vme: inout std_logic_vector(31 downto 0);	-- vme bus I/O signals  NOTE:  a_vme(0) is lw_n	
		            am: in std_logic_vector(5 downto 0);
		          as_n: in std_logic;
		        iack_n: in std_logic;
		           w_n: in std_logic;
		         ds0_n: in std_logic;
		         ds1_n: in std_logic;
		         d_vme: inout std_logic_vector(31 downto 0);	            
		    dtack_in_n: in std_logic;
		     berr_in_n: in std_logic;
		       dtack_n: out std_logic;
		        berr_n: out std_logic;
		       retry_n: out std_logic;
		      iackin_n: in std_logic;
		     iackout_n: out std_logic;
				 irq_test_1: out std_logic;
				 irq_test_2: out std_logic;
				 irq_test_7: out std_logic;
		      oe_dtack: out std_logic;
		      oe_retry: out std_logic;
					adout: out std_logic; -- only one direction on 125 for both a and d
		         aoe_n: out std_logic;
				   doe_n: out std_logic;
					gad: in std_logic;
------------------------------------------------------------------------------------------				 		  							
		   token_in_p0: in std_logic; -- CHECK ON PORT
		  token_out_p0: out std_logic; -- CHECK ON PORT									
----------------------------------------------------------------------------------------
--------------------------start to integrate---------------------------------------------	
----------------------------------------------------------------------------------------
		
      pclko: out std_logic;             -- clock out to processor fpga
      rclko: out std_logic;             -- read clock out to fifo	
		 -- data fifo
      fwclk,fwen_n: in std_logic;
      fd: in std_logic_vector(17 downto 16);
      paf_n,pae_n,or_n: in std_logic;
      ren_n: out std_logic;
      fq: in std_logic_vector(35 downto 0);
      -- spare signals between here and processor fpga
      spare0: out std_logic;
		spare1: in std_logic;
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
      vp3r0a_en_n,swphasea,swphaseb,swphasec,swphased: out std_logic;   
      -- other slow controls stuff
      selaclk: out std_logic_vector(1 downto 0);  -- adc sample clock source select
      dacld,dacsclk,adacsi,bdacsi: out std_logic;  -- DAC control (note: bdacsi is on init_n pin)
      atid,btid: inout std_logic;       -- DS18B20 temperature/serial # chips
      -- front panel led's
      led_vme_n,led_drdy_n: out std_logic);

   attribute period: string;
   attribute period of clk: signal is "12.5ns";
	
---------------leftovers/replaced/need to apply----------------------
--		    reset_ctrl: in std_logic;	-- reset in, from SW
--			   led_vme: out std_logic;	 
--		    retry_in_n: in std_logic; -- CHECK ON PORT... set to '1' in interface_24 (Not Needed no longer used)
--		    sysreset_n: in std_logic; --moved and pulled high WHAT's THE DEAL WITH THE PIN

end VME_example_TOP;

architecture a1 of VME_example_TOP is

	component vme_interface_8 is
		generic( LOCAL_ADDR_SIZE: integer );						-- # bits of local (byte) address (A24)
		port(         a: inout std_logic_vector(31 downto 0);	-- vme bus signals
						 am: in std_logic_vector(5 downto 0);
					  as_n: in std_logic;
					iack_n: in std_logic;
					   w_n: in std_logic;
					 ds0_n: in std_logic;
		          ds1_n: in std_logic;
						 dt: inout std_logic_vector(31 downto 0);
				dtack_in_n: in std_logic;
				 berr_in_n: in std_logic;
				sysreset_n: in std_logic;
				   dtack_n: out std_logic;
					 berr_n: out std_logic;
				   retry_n: out std_logic;
					 i_lev: in std_logic_vector(2 downto 0);
				 iackin_n: in std_logic;
				iackout_n: out std_logic;
					 irq_n: out std_logic_vector(7 downto 1);
------------------------------------------------------------------------------------------				 
				   oe_d1_n: out std_logic;							-- vme tx/rx chip controls
				   oe_d2_n: out std_logic;
				  oe_dtack: out std_logic;
				  oe_retry: out std_logic;
					  dir_a: out std_logic;
				 	  dir_d: out std_logic;
					 oe_a_n: out std_logic;
					   le_d: out std_logic;
				   clkab_d: out std_logic;
				   clkba_d: out std_logic;
					   le_a: out std_logic;
				   clkab_a: out std_logic;
				   clkba_a: out std_logic;
------------------------------------------------------------------------------------------				 
				   d_fifo1: in std_logic_vector(35 downto 0);	-- data from output fifo 1 (data(71..36))
					empty1:	in std_logic;						-- fifo 1 empty flag		 
					rdreq1:	out std_logic;						-- fifo 1 read request (synced to clk_x2)		 
				   d_fifo2: in std_logic_vector(35 downto 0);	-- data from output fifo 2 (data(35..0))			 
					empty2:	in std_logic;						-- fifo 2 empty flag		 
					rdreq2:	out std_logic;						-- fifo 2 read request (synced to clk_x2)		 	 
				  d_reg_in: out std_logic_vector(31 downto 0);
				 d_reg_out: in std_logic_vector(31 downto 0);
				  intr_stb: in std_logic;		         		     
------------------------------------------------------------------------------------------				 
					  adr24: in std_logic_vector(23 downto LOCAL_ADDR_SIZE);
					  adr32: in std_logic_vector(8 downto 0);
				  en_adr32: in std_logic;
				adr32m_min: in std_logic_vector(8 downto 0);
				adr32m_max: in std_logic_vector(8 downto 0);
				 en_adr32m: in std_logic;
------------------------------------------------------------------------------------------				 
			 en_multiboard: in std_logic;
			   first_board: in std_logic;
				 last_board: in std_logic;
			en_token_in_p0: in std_logic;						-- assert to enable module to accept token in from p0
			   token_in_p0: in std_logic;						-- token in from previous module on p0
			en_token_in_p2: in std_logic;						-- assert to enable module to accept token in from p2
			   token_in_p2: in std_logic;						-- token in from previous module on p2
				 take_token: in std_logic;
------------------------------------------------------------------------------------------				 		  
					    busy: in std_logic;
			   fast_access: in std_logic;
------------------------------------------------------------------------------------------				 		   
					 modsel: out std_logic;
					   addr: out std_logic_vector((LOCAL_ADDR_SIZE - 1) downto 0);
					   byte: out std_logic_vector(3 downto 0);
				data_cycle: out std_logic;
				iack_cycle: out std_logic;
				  read_sig: out std_logic;
				  read_stb: out std_logic;
				 write_sig: out std_logic;
				 write_stb: out std_logic;
				 a24_cycle: out std_logic;
				 a32_cycle: out std_logic;
				a32m_cycle: out std_logic;
				 d64_cycle: out std_logic;
			    end_cycle: out std_logic;
			  berr_status: out std_logic;
				   ds_sync: out std_logic;
				  w_n_sync: out std_logic;
------------------------------------------------------------------------------------------				 		       
					  token: out std_logic;
				 token_out: out std_logic;
				done_block: out std_logic;
------------------------------------------------------------------------------------------				 		       		       
				   en_berr: in std_logic;
------------------------------------------------------------------------------------------				 		       		       		         
			 ev_count_down: out std_logic;
			  event_header: out std_logic;
			  block_header: out std_logic;
			 block_trailer: out std_logic;
------------------------------------------------------------------------------------------				 		       		       
					clk_x2: in std_logic;
					clk_x4: in std_logic;
					 reset: in std_logic ;
------------------------------------------------------------------------------------------				 		       		       		         
				   dnv_word: in std_logic_vector(31 downto 0);	-- word output when no valid data is available (empty)
			   filler_word: in std_logic_vector(31 downto 0);   -- word output as a filler for 2eVME and 2eSST cycles
			   
					   temp: out std_logic_vector(31 downto 0); -- for debug
				 sst_state: out std_logic_vector(16 downto 0);
				  sst_ctrl: out std_logic_vector(31 downto 0));			 		         
	end component;

component control_example is
		port ( 		addr: in std_logic_vector(15 downto 0);
				read_sig: in std_logic; 
			   write_sig: in std_logic; 
				read_stb: in std_logic;
			   write_stb: in std_logic;
					byte: in std_logic_vector(3 downto 0);
			  iack_cycle: in std_logic; 
			   a24_cycle: in std_logic;
			   a32_cycle: in std_logic; 
			  a32m_cycle: in std_logic;
				   token: in std_logic;
				  berr_n: in std_logic; 
			   berr_in_n: in std_logic; 
			  sysreset_n: in std_logic;
					 w_n: in std_logic;
			   end_cycle: in std_logic;
			 berr_status: in std_logic;
					 clk: in std_logic;
				   reset: in std_logic;
					busy: in std_logic;
			 fast_access: out std_logic;
			
					reg0: out std_logic_vector(31 downto 0);	-- register outputs
					reg1: out std_logic_vector(31 downto 0);
					reg2: out std_logic_vector(31 downto 0);
					reg3: out std_logic_vector(31 downto 0);
					reg4: out std_logic_vector(31 downto 0);
					reg5: out std_logic_vector(31 downto 0);
					reg6: out std_logic_vector(31 downto 0);
					reg7: out std_logic_vector(31 downto 0);
					reg8: out std_logic_vector(31 downto 0);	
					reg9: out std_logic_vector(31 downto 0);
					reg10: out std_logic_vector(31 downto 0);
					reg11: out std_logic_vector(31 downto 0);
					reg12: out std_logic_vector(31 downto 0);
					reg13: out std_logic_vector(31 downto 0);
					reg14: out std_logic_vector(31 downto 0);
					reg15: out std_logic_vector(31 downto 0);
			
				   stat0: in std_logic_vector(31 downto 0); -- status inputs all muxed from main, seperate out some regs?
				   stat1: in std_logic_vector(31 downto 0);
				   stat2: in std_logic_vector(31 downto 0);
				   stat3: in std_logic_vector(31 downto 0);
				   stat4: in std_logic_vector(31 downto 0);
				   stat5: in std_logic_vector(31 downto 0);
				   stat6: in std_logic_vector(31 downto 0);
				   stat7: in std_logic_vector(31 downto 0);
				   stat8: in std_logic_vector(31 downto 0);		 
				   stat9: in std_logic_vector(31 downto 0);
				   stat10: in std_logic_vector(31 downto 0);
				   stat11: in std_logic_vector(31 downto 0);
				   stat12: in std_logic_vector(31 downto 0);
				   stat13: in std_logic_vector(31 downto 0);
				   stat14: in std_logic_vector(31 downto 0);
				   stat15: in std_logic_vector(31 downto 0);
					
				 data_in: in std_logic_vector(31 downto 0);		-- data input to registers (from VME (write))
				data_out: out std_logic_vector(31 downto 0) );	-- data output from reg, status (to VME (read))
						
		end component;

component fifo_4096x36v is
		port (		
					rst		: IN STD_LOGIC  := '0';
					wr_clk	: IN STD_LOGIC ;
					rd_clk	: IN STD_LOGIC ;
					din		: IN STD_LOGIC_VECTOR (35 DOWNTO 0);	
					wr_en		: IN STD_LOGIC ;
					rd_en		: IN STD_LOGIC ;		
					dout		: OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
					full		: OUT STD_LOGIC ;
					empty		: OUT STD_LOGIC ;
					rd_data_count : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
					wr_data_count : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
					 );
	end component;
	
	component AT45DB642_iface
        generic
        (
                SimSpeedUp                  : integer := 1; --- to speed up simulation,  Should be 0 for normal run.
                I2C_CLK_HPERIOD             : integer := 5;  --- equal to CLK * 20 nS  (250 MHz Clock) Min is 3
                I2C_CLK_CNT_NumOfBits       : integer :=  3;   --- equal to > ln(I2C_CLK_PERIOD) / ln(2)
                BaseTime                    : integer  := 32750 ; --- equal CLK * 131 uS 
                BaseTimerNumberOfBits       : integer  := 15;   -- equal to > (ln(BaseTime) / ln(2)
                SROM_CS_N_HiTime            : integer  := 13    -- equal 50 ns * CLK
        );
        port
         (
           CLK                  : in std_logic;
           RESET_N              : in std_logic; 
           
           IDLE_REG    : out std_logic; --- Wait for this = 1 before bring EXEC from low to high
           
           OPCODE      : in std_logic_vector(2 downto 0);  --- See above
           EXEC        : in std_logic;  --- Rising Edge execute OPCODE
           PAGE_ADR    : in std_logic_vector(12 downto 0); -- Flash Page Address
           BYTE_ADR    : in std_logic_vector(10 downto 0); -- Flash Byte Address
           NUM_BYTES   : in std_logic_vector(10 downto 0); -- Number of Bytes to Read from or send to Flash
           DATA_TO_ROM        : in std_logic_vector(7 downto 0); -- Data to be written to FLASH
           BlockNumberToErase : in std_logic_vector(9 downto 0); 
           ReadyForNewDataToRom_REG : out std_logic;  --- Rising Edde indicate DATA_TO_ROM can change.
           CmdPending   : in std_logic;
           HOST_IDLE    : in std_logic;
           
           DATA_FROM_ROM_REG        : out std_logic_vector(7 downto 0); -- Data read from FLASH
           DataFromRomValid_REG     : out std_logic; -- rising edge indicate DATA_FROM_ROM is valid.
           RdyForCmd                : out std_logic; 
           
                      
           --- To ROM pins
           SROM_SCK   : out std_logic;
           SROM_CS_N  : out std_logic;
           SROM_SI    : out std_logic;
           SROM_SO    : in  std_logic 
        );
    end component;
	 
	component EXECUTE_HACK 
		PORT (CLK,EXEC,IDLE_REG,RdyForCmd,RESET_N: IN std_logic;
				CmdPending,EXEC_GO,HOST_IDLE : OUT std_logic);
	end component;
	 
 ------------------------- AT45DB642_iface signals--------------------------------
 ---------------------------------------------------------------------------------
	signal m_config_csr_wr,m_config_csr_rd,m_config_addr_data  :  std_logic_vector(31 downto 0);
	signal BYTE_ADDR : std_logic_vector(10 downto 0); 
	signal PAGE_ADDR : std_logic_vector(12 downto 0);
	signal vme_cclk, vme_cso_n, vme_mosi, main_cclk, main_cso_n, main_mosi : std_logic;
	signal vme_pr_en : std_logic;
	signal EXEC, EXEC_GO, IDLE_REG, RdyForCmd : std_logic;
	signal EXEC_D,EXEC_Q	: std_logic;
	signal CmdPending, HOST_IDLE : std_logic;
	
-------------------------------------------------------------------------------------
-------------------------------new components----------------------------------------
-------------------------------------------------------------------------------------

---------state machine for fullcrate testing  ---------------------------------------

--component dummy_fifo_load is
--		port (		
--		clk       : IN   STD_LOGIC; -- on board
--      fifo_go   : IN   STD_LOGIC; -- trigger from register ctrl_0
--		dummy_rst : IN   STD_LOGIC;
--	  wrreq_data : OUT   STD_LOGIC; --fifo write EN
--	  wrreq_data2 : OUT   STD_LOGIC;
--	  data_tag_H : OUT STD_LOGIC_VECTOR(3 downto 0);
--	  data_tag_L : OUT STD_LOGIC_VECTOR(3 downto 0);
--	  data_high : OUT  STD_LOGIC_VECTOR(31 downto 0);
--	  test_dummy_high : OUT  STD_LOGIC_VECTOR(35 downto 0);
--      data_low : OUT  STD_LOGIC_VECTOR(31 downto 0);
--		or_n		 : in std_logic;
--      ren_n		 : out std_logic;
--		--ga_inst	: in std_logic_vector(7 downto 0);
--      fq			 : in std_logic_vector(35 downto 0)
--					 );			 
--	end component;

---------link to original main  ---------------------------------------
component main is
  port(
	      a: inout std_logic_vector(15 downto 1); -- change to fix serial 
	      lword_n: inout std_logic;
	      d: inout std_logic_vector(31 downto 0);
	      am: in std_logic_vector(5 downto 0);
	      iack_n,as_n,write_n,dtacki_n,berri_n: in std_logic;
		  gad: in std_logic;
	      ds0_n: in std_logic;
		  ds1_n: in std_logic;
		  busy: out std_logic;
	      iackin_n: in std_logic;
		  clk, clk1MHz, clk40MHz: in std_logic;
	      -- data fifo
	      --fwclk,fwen_n: in std_logic;
	     -- fd: in std_logic_vector(17 downto 16);
		  --fq: in std_logic_vector(35 downto 0);
	      --paf_n,pae_n,or_n: in std_logic;
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
	      selaclk: out std_logic_vector(1 downto 0);  	-- adc sample clock source select
	      dacld,dacsclk,adacsi,bdacsi: out std_logic;  -- DAC control (note: bdacsi is on init_n pin)
	      atid,btid: inout std_logic;       				-- DS18B20 temperature/serial # chips
			--read/write variables
		  m_swapctrl, m_csr, m_pwrctrl, m_dacctrl: in std_logic_vector(31 downto 0);
		  proc_csr, proc_fifo_test: in std_logic_vector(31 downto 0);
			--variable for vmex returns
		  d_stat: out std_logic_vector(31 downto 0);
	      -- front panel led's
	      led_vme_n,led_drdy_n: out std_logic;
			-- from new vme interface
		  ga: out std_logic_vector(7 downto 0);
		  --a32_ba: in std_logic_vector(31 downto 0);
		  write_sig, read_sig: in std_logic
		);
	end component;

--		component BLOCK_SEND_3 is
--					port
--					(
--					CLK,
--					FIFO_GO,
--					--BLOCK_DONE,
--					RESET_N
--					: IN std_logic;--BLOCK_DONE,
--					data_high_sel,
--					data_low_sel,
--					ren,wrreq_data,
--					wrreq_data2
--					--DEC_BLOCK_CNT 
--					: OUT std_logic
--					);
--		end component;

		component BLOCK_SEND_NEW is
					port
					(
					CLK,
					FIFO_GO,
					--BLOCK_DONE,
					RESET_N
					: IN std_logic;--BLOCK_DONE,
					--data_high_sel,
					--data_low_sel,
					ren,wrreq_data,
					wrreq_data2
					--DEC_BLOCK_CNT 
					: OUT std_logic
					);
		end component;
---------------------signal definitions------------------------------------------
---------------------------------------------------------------------------------
	signal d_stat: std_logic_vector(31 downto 0);  -- varible from main muxing 'cd', status to d buss in "control example"
	signal empty1, empty2, rdreq1, rdreq2: std_logic;
	signal addr: std_logic_vector(15 downto 0);
	signal modsel, read_sig, read_stb, write_sig, write_stb: std_logic;
	signal a24_cycle, a32_cycle, a32m_cycle, iack_cycle, end_cycle, berr_status: std_logic;		
	signal d_reg_in, d_reg_out: std_logic_vector(31 downto 0);	
	signal token_in, token, token_out: std_logic;	
	signal nw_o1, nw_o2: std_logic_vector(11 downto 0);
	signal byte: std_logic_vector(3 downto 0);		
	signal dnv_word, filler_word: std_logic_vector(31 downto 0);	
	signal ds_sync, w_n_sync, berr_n_int, fast_access: std_logic;
	signal int_stb: std_logic;							-- interrupt strobe (IN) 
	
	signal dir_a, dir_d: std_logic;
	signal irq_n: std_logic_vector(7 downto 1);
----------control signals-----------------------	
	signal m_swapctrl, m_csr, m_pwrctrl, m_dacctrl, proc_csr, fe_csr:  std_logic_vector(31 downto 0); --register writes
	signal proc_fifo_test, m_fifo_test:  std_logic_vector(31 downto 0); --test writes for fifo loading. 
	signal ctrl_8, ctrl_9, ctrl_10, ctrl_11, ctrl_12, ctrl_13, ctrl_14, ctrl_15: std_logic_vector(31 downto 0); -- 0-7 defined seperatly as writes 
	signal status_1, status_2, status_3, status_4, status_5, status_6, status_7 : std_logic_vector(31 downto 0);
	signal status_8, status_9, status_10, status_11, status_12, status_13, status_14, status_15: std_logic_vector(31 downto 0); --don't need this many, remove?
-----------------------(WORK TO DO HERE)---------------------------------------------------
	signal ga_inst: std_logic_vector(7 downto 0); -- done -- ga&"000"
	signal ga: std_logic_vector(7 downto 0); -- done -- component in main
	signal a32_ba: std_logic_vector(31 downto 0); -- done --0xAA000000
	signal a32_single: std_logic_vector(8 downto 0); -- done -- 001g4 g3g2g1g0
	
	signal gap: std_logic; 
	signal retry_in_n: std_logic; -- CHECK ON PORT... set to '1' in interface_24
	--Handled By Ben's mod
	signal le_d, clkab_d, clkba_d, le_a, clkab_a, clkba_a: std_logic;
	signal oe_d2_n: std_logic; -- only need oe_d1
	signal i_lev: std_logic_vector(2 downto 0); -- SW reg????????
-------------------------------Signal definitions for TESTING--------------------------
-------------------------------------'dummy_events' -----------------------------------
	signal d_fifo1, d_fifo2: std_logic_vector(35 downto 0);
	signal data_tag_H, data_tag_L: std_logic_vector(3 downto 0);
	signal data_high, data_low: std_logic_vector(31 downto 0);
	signal dummy_high, dummy_low, test_dummy_high: std_logic_vector(35 downto 0);
	signal wrreq_data, wrreq_data2: std_logic;	-- write enable for out fifo (sync to wrt_clk) (IN) -- from vme now
	signal reset_ctrl: std_logic := '1'; -- reset control for out fifo IN -- from vme now
	signal sysreset_n: std_logic; -- could do in instantiation 
	signal dir_d_int, oe_d1_n_int, oe_a_n_int, d64_cycle_int: std_logic;
	signal wrt_clk_1, wrt_clk_2, rd_clk_1, clk_x2, clk_x4, clk40MHz, clk1MHz: std_logic; --clock conversions, all comes from 80MHz osc
	signal fifo_go, dummy_rst, proc_fifo_go, proc_dummy_rst: std_logic; --varibles mapped to write registers for fifo control
	signal count: std_logic_vector(2 downto 0); --testing var
	signal busy: std_logic :='0'; -- to hold off dtack. used in main (block sc1) to wait on serial comm
	signal AAAA, BBBB, CCCC, DDDD: std_logic_vector(31 downto 0); --dummy numbers for testing
	signal test_token, take_token: std_logic;
	--	signal wrt_clk: std_logic;		-- write clock for output fifo (IN) -- changed to clk
	--	signal data_in: std_logic_vector(71 downto 0);	-- module data (sync to wrt_clk) (IN) changed to dummy
	
-------------------------------Signal definitions for real fifo load-------------------

		signal INC_BLOCK_CNT,PINC_BLOCK_CNT : std_logic; 
		signal INC_BLOCK_BUF1_D : std_logic;
		signal INC_BLOCK_BUF1_Q : std_logic;
		signal INC_BLOCK_BUF2_D : std_logic;
		signal INC_BLOCK_BUF2_Q : std_logic;
		signal INC_BLOCK_BUF3_D : std_logic;
		signal INC_BLOCK_BUF3_Q : std_logic;
		
		signal DEC_BLOCK_CNT,PDEC_BLOCK_CNT : std_logic; 
		signal DEC_BLOCK_BUF1_D : std_logic;
		signal DEC_BLOCK_BUF1_Q : std_logic; 
		
		signal BLOCK_CNT_D,BLOCK_CNT_Q : std_logic_vector(19 downto 0);
		signal FIFO_BLOCK_CNT_D,FIFO_BLOCK_CNT_Q : std_logic_vector(19 downto 0);
		--signal FIFO_GO : std_logic;
		
		signal BLOCK_READY,BLOCK_DONE : std_logic;
		signal done_block	: std_logic;--from ed;s interface
		signal done_block_D, done_block_Q, pdone_block : std_logic;
		signal done_block_2D, done_block_2Q : std_logic;
		signal done_block_3D, done_block_3Q : std_logic;
		
		signal BLOCK_DONE_D,BLOCK_DONE_Q,pBLOCK_DONE : std_logic;
		
		signal BLOCK_NUMBER_D, BLOCK_NUMBER_Q : std_logic_vector(6 downto 0) := "0000000";
		
		signal data_high_sel,data_low_sel : std_logic;
		
--		signal insert_gad : std_logic;
		signal insert_blk_head, insert_ev_head, insert_ev_trail, insert_blk_trail, insert_raw_head : std_logic;
		signal data_high_sel_D,data_high_sel_Q : std_logic;
		signal data_low_sel_D,data_low_sel_Q : std_logic;
		
		signal low_fifo_full, high_fifo_full : std_logic;

		signal wrreq_data_D,wrreq_data_Q : std_logic;
		signal wrreq_data2_D,wrreq_data2_Q : std_logic;
		
		signal or_n_D,or_n_Q		: std_logic;	
		signal fq_D,fq_Q : std_logic_vector(35 downto 0);
		
		signal ren : std_logic;
		signal ren_n_D,ren_n_Q : std_logic := '1';
		signal RESET_P : std_logic;
		signal RESET_N : std_logic := '1';
		
-------------------------------New Reg map Signal definitions -------------------		
		signal m_block_csr_wr,m_block_csr_rd: std_logic_vector(31 downto 0);
		
		signal m_CTRL1: std_logic_vector(31 downto 0):= X"00000004";
		signal sync_rst_source: std_logic_vector(1 downto 0);
		signal en_berr: std_logic; -- initial value = 1
		signal en_multiboard: std_logic; -- initial value = 1
		signal first_board, last_board: std_logic; -- done -- slot 3 = first board, slot 20 = last board

		signal m_ADR32: std_logic_vector(31 downto 0) := X"0000AA01"; 
		signal en_adr32: std_logic; -- initial value = 1
		signal adr32_ba : std_logic_vector(8 downto 0) := "101010100"; -- initial value AA000000
		
		signal m_ADR32_MB: std_logic_vector(31 downto 0) := X"AB00AA00";
		signal en_adr32m: std_logic; -- initial value = 0
		
		signal adr32: std_logic_vector(8 downto 0); --use adr32ba but take out of main!!!!
		signal adr_min: std_logic_vector(8 downto 0); --A32m min address (IN) initial value = AA 
		signal adr_max: std_logic_vector(8 downto 0); --A32m max address (IN) initial value = AB 
		
		signal m_block_count: std_logic_vector(31 downto 0);
		signal SOFT_RESET,HARD_RESET: std_logic;
		
		signal RESET_P_D,RESET_P_Q : std_logic;
		signal RESET_N_D,RESET_N_Q : std_logic;
		
		signal RESET_P_2D,RESET_P_2Q : std_logic;
		signal RESET_N_2D,RESET_N_2Q : std_logic;
		
		signal RESET_P_3D,RESET_P_3Q : std_logic;
		signal RESET_N_3D,RESET_N_3Q : std_logic;	
		
		
--		component div_2 is
--			port ( CLKIN_IN        : in    std_logic; 
--					 RST_IN          : in    std_logic; 
--					 CLKDV_OUT       : out   std_logic; 
--					 CLKIN_IBUFG_OUT : out   std_logic; 
--					 CLK0_OUT        : out   std_logic; 
--					 LOCKED_OUT      : out   std_logic);
--			end component;
		
		signal clk_b : std_logic;
		signal fwclk_B : std_logic;
--***************************************************************************************************
--***************************************BEGIN*******************************************************
begin

-------------------------- VME firmware programming -----------------------------------------
--------------------------------------------------------------------------------------------- 
--
--		udiv_2 : div_2 
--			port map( 
--					 CLKIN_IN        => clk, 
--					 RST_IN          => RESET_P, 
--					 CLKDV_OUT       => clk40MHz, 
--					 CLKIN_IBUFG_OUT => open, 
--					 CLK0_OUT        => clk_B, 
--					 LOCKED_OUT      => open);


--	fBUFG_inst : BUFG
--		port map (
--			O => fwclk_B, -- Clock buffer output
--			I => fwclk -- Clock buffer input
--			);
--
	rBUFG_inst : BUFG
		port map (
			O => clk_B, -- Clock buffer output
			I => clk -- Clock buffer input
			);
			

	uEXECUTE_HACK : EXECUTE_HACK 
		port map 
			(
				CLK => clk_B, --clk,
				EXEC => EXEC,
				IDLE_REG => IDLE_REG,
				RdyForCmd => RdyForCmd,
				RESET_N => RESET_N, 
				CmdPending => CmdPending,
				EXEC_GO => EXEC_GO,
				HOST_IDLE => HOST_IDLE
			);

		--EXEC_D <= m_config_addr_data(31) and write_stb;
		--EXEC <= EXEC_D and not EXEC_Q;
		EXEC <= m_config_addr_data(31);
		
		m_config_csr_rd(8) <= IDLE_REG;
		
    UAT45DB642_iface : AT45DB642_iface -- actually AT45DB321
        generic map
        (
            SimSpeedUp => 0 --AT45DB642_iface_SimSpeedUp
        )
        port map
         (
           CLK               			 => clk_B, --clk40MHz, --clk, --CLK,  
           RESET_N           			 => RESET_N,
           
           IDLE_REG    					 => IDLE_REG, -- m_config_csr_rd(8), --AT45DB642_iface_IDLE_D, --- Wait for this = 1 before bring EXEC from low to high,  use for busy but need to count for prog and erase
           
           CmdPending                => CmdPending, --'1', --AT45_CmdPending -- 0 or 1?????
           HOST_IDLE                 => HOST_IDLE, --'0', --REFPCOSM_IDLE, -- 0 or 1 ????
           OPCODE                    => m_config_csr_wr(26 downto 24), --AT45DB642_iface_OPCODE, -- map from vme register actions     
           EXEC                      => EXEC_GO, --m_config_addr_data(31), --m_config_csr_wr(28), --AT45DB642_iface_EXEC_Q, -- drop EXEC with addr/data OK????      
           PAGE_ADR                  => PAGE_ADDR,--m_config_addr_data(30 downto 18), --AT45DB642_iface_PAGE_ADR_Q,   
           BYTE_ADR                  => BYTE_ADDR, --"0" & m_config_addr_data(17 downto 8), --AT45DB642_iface_BYTE_ADR_Q, --only need 10 bits for the AT45DB321  
           NUM_BYTES                 => "00000000001", --AT45DB642_iface_NUM_BYTES_Q, -- always 1  
           DATA_TO_ROM               => m_config_addr_data(7 downto 0), --AT45DB642_iface_DATA_TO_ROM_Q,
           BlockNumberToErase        => m_config_addr_data(30 downto 21), --"0" & m_config_addr_data(17 downto 8), --BlockNumberToErase, 
           ReadyForNewDataToRom_REG  => open, --AT45DB642_iface_ReadyForNewDataToRom, --- Rising Edde indicate DATA_TO_ROM can change.
           
           RdyForCmd                 => RdyForCmd, --open, --AT45_RdyForCmd, 
           DATA_FROM_ROM_REG         => m_config_csr_rd(7 downto 0), --AT45DB642_iface_DATA_FROM_ROM,    -- Data read from FLASH
           DataFromRomValid_REG      => open, --AT45DB642_iface_DataFromRomValid, -- rising edge indicate DATA_FROM_ROM is valid. 
           
                      
           --- To ROM pins
           SROM_SCK   => vme_cclk, --AT45DB642_iface_SROM_SCK,
           SROM_CS_N  => vme_cso_n, --AT45DB642_iface_SROM_CS_N,
           SROM_SI    => vme_mosi, --AT45DB642_iface_SROM_SI,
           SROM_SO    => din --AT45DB642_iface_SROM_SO_Q
        );
		  
--		cclk <= vme_cclk or main_cclk;
--		cso_n <= vme_cso_n or main_cso_n;
--		mosi <= vme_mosi or main_mosi;
		vme_pr_en <= m_config_csr_wr(31);
		cclk <= vme_cclk when vme_pr_en = '1' else main_cclk;
		cso_n <= vme_cso_n when vme_pr_en = '1' else main_cso_n;
		mosi <= vme_mosi when vme_pr_en = '1' else main_mosi;
		
		PAGE_ADDR <= '0' & m_config_addr_data(30 downto 19);
		--BYTE_ADDR <= "0" & m_config_addr_data(17 downto 8); --only need 10 bits for AT45DB321	
		BYTE_ADDR <= m_config_addr_data(18) & m_config_addr_data(17 downto 8);
		
		m_config_csr_rd(31 downto 24) <= m_config_csr_wr(31 downto 24);  -- allow for r/w of opcode
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------		  

	sync_rst_source <= m_CTRL1(1 downto 0);
	en_berr <= m_CTRL1(2);
	en_multiboard <= m_CTRL1(3); --default = 0
	first_board <= m_CTRL1(4); -- bryan on 
	last_board <= m_CTRL1(5); -- bryan on
	
	en_adr32 <= m_ADR32(0); -- default 1
	adr32_ba <= m_ADR32(15 downto 7); -- default AA000000
	
	en_adr32m <= m_ADR32_MB(0); -- default = 0
	adr_min <= m_ADR32_MB(15 downto 7); -- bryan on
	adr_max <= m_ADR32_MB(31 downto 23); -- bryan on
	
	m_block_count(19 downto 0) <= BLOCK_CNT_Q;
	
	take_token <= m_block_csr_wr(5); -- bryan on
	
--------------RESET SHENNANIGANS------------------------------------
	SOFT_RESET <= '1' when (m_block_csr_wr(8) = '1' and write_sig = '1') else '0'; -- and write_sig = '1'
	HARD_RESET <= '1' when (m_block_csr_wr(9) = '1' and write_sig = '1') else '0'; -- and write_sig = '1'
	
--	RESET_P <= '1' when (SOFT_RESET ='1' or HARD_RESET ='1') else '0';
--	RESET_N <= not RESET_P;
	
	RESET_P_D <= '1' when (SOFT_RESET ='1' or HARD_RESET ='1') else '0';
	RESET_N_D <= not RESET_P_D;
	RESET_P <= RESET_P_2Q; --CHANGE!
	RESET_N <=RESET_N_2Q;  --CHANGE!
	spare0 <= RESET_N_Q;
--	
	RESET_REG : process (clk_B)
	begin
		if (clk_B = '1' and clk_B'event) then --aclk
			RESET_P_Q <= RESET_P_D;
			RESET_P_2Q <= RESET_P_2D;
			
			RESET_N_Q <= RESET_N_D;	
			RESET_N_2Q <= RESET_N_2D;	
		end if;
	end process RESET_REG;
	
			RESET_P_2D <= RESET_P_Q;
			RESET_N_2D <= RESET_N_Q;	
	
-------------- END RESET SHENNANIGANS------------------------------------


-------------125 Fixes_------------------------------------------------------------
	token_in <= token_in_p0;
	--test_token <= token_in_p0;
	--led_drdy_n <= test_token;
	token_out_p0 <= token_out;	
	berr_n <= not berr_n_int; --reverse logic for 125	
	adout <= dir_d_int; -- for 125 conversion
	doe_n <= oe_d1_n_int;
	aoe_n <= oe_a_n_int or (modsel and w_n_sync and (not d64_cycle_int)); --directional logic fix for 125 
	irq_test_1 <= '0';
	irq_test_2 <= '0';
	irq_test_7 <= '0';
	ga_inst <= ga(4 downto 0)&"000"; --bit SHIFTED!!!!
	--a32_ba <= X"AA000000"; 
	a32_single <= "001"&ga(4 downto 0)&"0"; -- 001g4 g3g2g1g0; hex equiv ex... 03=23, 0a=2a, 14=34..... and "0" or whatev because it's 9 bit
	--first_board <= '1' when ga_inst = "00011000" else '0'; -- 0X18, vme slot 3, payload slot 15 was "00000011" before shift --bryan off
	--last_board  <= '1' when ga_inst = "10100000" else '0'; --  0XA0, vme slot 20, payload slot 16 was "00010100" before shift --bryan off
-------------READS-------------------------
	status_2 <= data_low(31 downto 0);	
	status_3 <= test_dummy_high(31 downto 0);		  
	status_4 <= d_fifo1(31 downto 0); 						
	status_5 <= d_fifo2(31 downto 0);
	
	m_block_csr_rd(2) <= BLOCK_READY;
	m_block_csr_rd(3) <= berr_status;
	m_block_csr_rd(4) <= token;
-------------WRITES------------	
	--fifo_go   <= m_fifo_test(0);
	--dummy_rst <= m_fifo_test(1);
	--reset_ctrl <= m_fifo_test(2);
	--take_token <= m_fifo_test(3); -- bryan off

	--ren_n <= '0'; -- read enable for main fifo tied low to read
--	proc_fifo_go <= ctrl_3(2);
--	proc_dummy_rst <= ctrl_3(3);
--	dummy_high <= data_tag_H & data_high;
--	dummy_low <=  data_tag_L & data_low;

------------------------------original fifo flags, may be used in final ---------------
	status_6(31 downto 29) <= "000";					-- fix undefined bits  38		
	status_6(15 downto 13) <= "000";	
	status_6(11 downto 0)  <= nw_o1;
	status_6(12)           <= empty1;
	status_6(27 downto 16) <= nw_o2;
	status_6(28)           <= empty2;
	status_7(31 downto 4)  <= "0000000000000000000000000000";	     -- 3c
	dnv_word    <= "11110"&ga(4 downto 0)&"0000000000000000000000";	-- user specified 'data not valid' word (empty fifo)
	filler_word <= "11111"&ga(4 downto 0)&"0000000000000000000000";	-- user specified 'filler' word (2eVME, 2eSST cycles)	
-------CLOCKS--------------
	wrt_clk_1 <= clk_B; --clk_B; --clk40MHz; --clk; 
	rd_clk_1 <= clk40MHz; --clk_B; --clk40MHz; --clk; 
	clk_x2 <= clk40MHz; --clk_B; --clk40MHz --clk;
	clk_x4 <= clk40MHz; --clk_B; --clk40MHz; --clk;
	--pclko <= clk;             -- clock out to processor fpga
	--rclko <= clk;             -- read clock out to fifo
	
	upclko : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1"
			INIT => '0', -- Sets initial state of the Q output to '0' or '1'
			SRTYPE => "SYNC") -- Specifies "SYNC" or "ASYNC" set/reset
		port map (
			Q => pclko, -- 1-bit output data
			C0 => clk_B, --clk40MHz, --clk, -- 1-bit clock input
			C1 => not clk_B, --clk40MHz, --clk, -- 1-bit clock input
			CE => '1', -- 1-bit clock enable input
			D0 => '1', -- 1-bit data input (associated with C0)
			D1 => '0', -- 1-bit data input (associated with C1)
			R => '0', -- 1-bit reset input
			S => '0' -- 1-bit set input
		);	  
		
	urclko : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1"
			INIT => '0', -- Sets initial state of the Q output to '0' or '1'
			SRTYPE => "SYNC") -- Specifies "SYNC" or "ASYNC" set/reset
		port map (
			Q => rclko, -- 1-bit output data
			C0 => clk_B, --clk40MHz, --clk, -- 1-bit clock input
			C1 => not clk_B, --clk40MHz, --clk, -- 1-bit clock input
			CE => '1', -- 1-bit clock enable input
			D0 => '1', -- 1-bit data input (associated with C0)
			D1 => '0', -- 1-bit data input (associated with C1)
			R => '0', -- 1-bit reset input
			S => '0' -- 1-bit set input
		);	  

-------------------------------CLOCK BLOCKING--------------------------------------

clkdiv_40: block
      signal n_40: integer range 0 to 1;
   begin
      process(clk_b)
      begin
         if clk_b'event and clk_b='1' then
            n_40 <= n_40-1;
            if n_40=0 then
               n_40 <= 1;
               clk40MHz <= not clk40MHz;  
            end if;
         end if;
      end process;
   end block;

	--clk40MHz <= clk_B;

clkdiv: block
      signal n: integer range 0 to 39;
   begin
      process(clk_B)
      begin
         if clk_B'event and clk_B='1' then
            n <= n-1;
            if n=0 then
               n <= 39;
               clk1MHz <= not clk1MHz;  -- attach period constraint ? will that work (to supersede 80MHz constraint?)
            end if;
         end if;
      end process;
   end block;	
------------------------------------------------------------------------------	
--------------------------component instantiation-----------------------------
------------------------------------------------------------------------------
x1 : main PORT MAP (			
									a => addr(15 downto 1), --a_vme(31 downto 1),
									lword_n => addr(0), --a_vme(0),
									d => d_vme(31 downto 0),
									busy => busy, 
									am => am,
									iack_n => '1',
									as_n => as_n,
									write_n => w_n,
									dtacki_n => dtack_in_n,
									berri_n => berr_in_n, 
									ds0_n => ds0_n,
									ds1_n => ds1_n,
									iackin_n => '1',							
									clk => clk_B, --clk40MHz, --clk,
									clk1MHz => clk1MHz,
									clk40MHz => clk40MHz,
									gad => gad,
									-- data fifo
--									fwclk => fwclk,
--									fwen_n => fwen_n,
--									fd => fd,
--									paf_n => paf_n,
--									pae_n => pae_n,
--									or_n => or_n,
--									ren_n => ren_n,
									-- spare signals between here and processor fpga
									--spare0 => spare0,
									--spare1 => spare1,
									-- controls interface and programming interface to FE and proc fpga's
									progo_n => progo_n,
									softrst => softrst,
									absclk => absclk,
									absin => absin,
									psclk => psclk,
									psin => psin,
									asout => asout,
									bsout => bsout,
									psout => psout,
									-- configuration memory interface - these are for user-mode access of the usual config pins
									din => din,
									cclk => main_cclk, --cclk,
									cso_n => main_cso_n, --cso_n
									mosi => main_mosi, --mosi
									-- power supply stuff
									vp3r0a_en_n => vp3r0a_en_n,
									swphasea => swphasea,
									swphaseb => swphaseb,
									swphasec => swphasec,
									swphased => swphased,      
									-- other slow controls stuff
									selaclk => selaclk,
									dacld => dacld,
									dacsclk => dacsclk,
									adacsi => adacsi,
									bdacsi => bdacsi,
									atid => atid,
									btid => btid,
									-- passing registers to new vme
									d_stat => d_stat,	
									m_swapctrl => m_swapctrl,
									m_csr => m_csr,
									m_pwrctrl => m_pwrctrl,
									m_dacctrl => m_dacctrl,
									--m_block_csr => m_block_csr,
									proc_csr => proc_csr,
									proc_fifo_test => proc_fifo_test,
									-- front panel led's
									led_vme_n => led_vme_n,
									led_drdy_n => 	led_drdy_n,
									-- from new vmeinterface
									ga => ga,
									--a32_ba => adr32_ba,-- a32_ba,
									read_sig => read_sig,
									write_sig => write_sig
									);
-----------------------------------------------------------------------------------------------------
--------------------------------control example------------------------------------------------------	
-- Pipelines read/write data to vme bus, making use of options provided by new interface
-- Some register redundancy here with Gerards vmex and main but since those elements still handle the 
-- serial interface to proc and FE's we'll work with both until a more organized approach is availed
x4: control_example port map ( 		
									 addr => addr,
								read_sig => read_sig, 
							   write_sig => write_sig, 
								read_stb => read_stb,
							   write_stb => write_stb,
									byte => byte,
							  iack_cycle => iack_cycle, 
							   a24_cycle => a24_cycle,
							   a32_cycle => a32_cycle, 
							  a32m_cycle => a32m_cycle,
								   token => token,
								  berr_n => berr_n_int, 
							   berr_in_n => berr_in_n, 
							  sysreset_n => '1',
									 w_n => w_n_sync,			-- use synchronized write qualifier
							   end_cycle => end_cycle,
							 berr_status => berr_status,
									 clk => clk40MHz, --clk,
								   reset => HARD_RESET, --'0', --HARD_RESET,--reset_ctrl, --RESET_P, --reset_ctrl, --change
									busy => busy,
							 fast_access => fast_access,
															-- register outputs
									reg0 => m_swapctrl,				
									reg1 => m_csr,
									reg2 => m_pwrctrl,
									reg3 => m_dacctrl,
									reg4 => proc_csr,  
									reg5 => fe_csr, 
									reg6 => proc_fifo_test,
									reg7 => m_fifo_test,
									reg8 => m_block_csr_wr,
									reg9 => m_CTRL1,
									reg10 => m_ADR32,
									reg11 => m_ADR32_MB, 
									reg12 => m_config_csr_wr, 
									reg13 => m_config_addr_data,
									reg14 => ctrl_14,
									reg15 => ctrl_15,
															-- status inputs 
								   stat0 => d_stat,  -- varible from vmex, vmex now uses 'busy' instead of holding of dtack_oe 
								   stat1 => m_block_csr_rd,--status_1,
								   stat2 => m_block_count,
								   stat3 => m_config_csr_rd,
								   stat4 => status_4,
								   stat5 => status_5,
								   stat6 => status_6,
								   stat7 => status_7,									
									stat8 => status_8,			
								   stat9 => status_9,
								   stat10 => status_10,
								   stat11 => status_11,
								   stat12 => status_12,
								   stat13 => status_13,
								   stat14 => X"FA15E000",
								   stat15 => fq(31 downto 0),
			
								 data_in => d_reg_in,			-- data input to registers (from VME (write))
								data_out => d_reg_out );		-- data output from reg, status (to VME (read))

								
x6: vme_interface_8 generic map( LOCAL_ADDR_SIZE => 16 )			-- local address = 12 bits (4096 bytes)
					port map (        a => a_vme,					-- vme bus signals
										  am => am,
									   as_n => as_n,
									 iack_n => iack_n,
										 w_n => w_n,
									  ds0_n => ds0_n,
									  ds1_n => ds1_n,
										  dt => d_vme,
		            
								 dtack_in_n => dtack_in_n,
								  berr_in_n => berr_in_n,
								 sysreset_n => '1',
									 dtack_n => dtack_n,
									  berr_n => berr_n_int,
									 retry_n => retry_n,

									   i_lev => i_lev,
								   iackin_n => iackin_n,
								  iackout_n => iackout_n,
									   irq_n => irq_n,
------------------------------------------------------------------------------------------				 
									oe_d1_n => oe_d1_n_int,				-- vme tx/rx chip controls
									oe_d2_n => oe_d2_n,
								  oe_dtack => oe_dtack,
								  oe_retry => oe_retry,
									  dir_a => dir_a,
									  dir_d => dir_d_int,
									 oe_a_n => oe_a_n_int,
									   le_d => le_d,
									clkab_d => clkab_d,
									clkba_d => clkba_d,
									   le_a => le_a,
									clkab_a => clkab_a,
									clkba_a => clkba_a,
------------------------------------------------------------------------------------------				 
									d_fifo1 => d_fifo1,
									 empty1 => empty1,		 
									 rdreq1 => rdreq1,		 
									d_fifo2 => d_fifo2,			 
									 empty2 => empty2,	 
									 rdreq2 => rdreq2,		 
				 
								   d_reg_in => d_reg_in,
								  d_reg_out => d_reg_out,

								   intr_stb => int_stb,		         		     
------------------------------------------------------------------------------------------!!!!!!!!!!!!!!!				 
									   adr24 => ga_inst,--X"38",--ga_inst, -- was X"a1", now from 5 bit GAD! AND SHIFTED! slot '3' is X"18", slot 20 is X"A0", etc
									   adr32 => adr32_ba, --adr32_ba, --"101010100", --AA000000
								   en_adr32 => en_adr32, --en_adr32, --'1',
								 adr32m_min => adr_min,
								 adr32m_max => adr_max,
								  en_adr32m => en_adr32m, --en_adr32m, --'0', -- for single test need o reg
------------------------------------------------------------------------------------------				 
							 en_multiboard => en_multiboard, --en_multiboard, --'0', -- for single test need o reg
								first_board => first_board,
								 last_board => last_board,
						   en_token_in_p0 => '1',
								token_in_p0 => token_in,
							en_token_in_p2 => '0',
								token_in_p2 => '0',
								 take_token => take_token,
------------------------------------------------------------------------------------------				 		  
									    busy => busy,
								fast_access => fast_access,
------------------------------------------------------------------------------------------				 		   
									  modsel => modsel,
									    addr => addr,
									    byte => byte,
								 data_cycle => open,
								 iack_cycle => iack_cycle,
								   read_sig => read_sig,
								   read_stb => read_stb,
								  write_sig => write_sig,
								  write_stb => write_stb,
								  a24_cycle => a24_cycle,
								  a32_cycle => a32_cycle,
								 a32m_cycle => a32m_cycle,
								  d64_cycle => d64_cycle_int,
								  end_cycle => end_cycle,
								berr_status => berr_status,
									 ds_sync => open,				-- OR of VME data strobes (positive, sync to clk_x2)
								   w_n_sync => w_n_sync,			-- VME write qualifier (sync to clk_x2)
------------------------------------------------------------------------------------------				 		       
									   token => token,
								  token_out => token_out,
								 done_block => done_block,
------------------------------------------------------------------------------------------				 		       		       
									en_berr => en_berr, --'1',
------------------------------------------------------------------------------------------				 		       		       		         
							  ev_count_down => status_7(0),
							   event_header => status_7(1),
							   block_header => status_7(2),
							  block_trailer => status_7(3),
------------------------------------------------------------------------------------------				 		       		       
									 clk_x2 => clk_x2,
									 clk_x4 => clk_x4,
									  reset => RESET_P, --'0', --SOFT_RESET, --HARD_RESET, --reset_ctrl, --change
------------------------------------------------------------------------------------------				 		       		       
								    dnv_word => dnv_word,			-- word output when no valid data is available (empty)
							    filler_word => filler_word,			-- word output as a filler for 2eVME and 2eSST cycles
							    
									    temp => open,				-- for debug
								  sst_state => open,				-- for debug
								   sst_ctrl => open 				-- for debug
									);				
									
				

		BLOCK_READY <= '1' when (BLOCK_CNT_Q > 0)else '0'; -- as soon as there is an event in the 1MB fifo
		

		FIFO_GO <= '1' when (or_n = '0' and high_fifo_full = '0' and low_fifo_full = '0' and BLOCK_READY = '1') else '0'; -- goes as soon as data is in 1MB FIFO
								  
		BLOCK_NUMBER_D <= BLOCK_NUMBER_Q + 1 when PINC_BLOCK_CNT = '1' else
								BLOCK_NUMBER_Q;

--uBLOCK_SEND : BLOCK_SEND_3 PORT MAP (
--								CLK => clk_B, --clk_B, --clk40MHz, --clk,
--								--BLOCK_DONE => BLOCK_DONE, --BLOCK_DONE,
--								FIFO_GO => FIFO_GO,
--								RESET_N => RESET_N, -- RESET_N,--'1', --: IN std_logic; --will need to move reset first to work
--								data_high_sel => data_high_sel,
--								data_low_sel => data_low_sel,
--								--DEC_BLOCK_CNT => DEC_BLOCK_CNT,
--								ren => ren,
--								wrreq_data => wrreq_data,
--								wrreq_data2 => wrreq_data2 --: OUT std_logic
--								);
								
uBLOCK_SEND : BLOCK_SEND_NEW PORT MAP (
								CLK => clk_B, --clk_B, --clk40MHz, --clk,
								--BLOCK_DONE => BLOCK_DONE, --BLOCK_DONE,
								FIFO_GO => FIFO_GO,
								RESET_N => RESET_N, -- RESET_N,--'1', --: IN std_logic; --will need to move reset first to work
								--data_high_sel => data_high_sel,
								--data_low_sel => data_low_sel,
								--DEC_BLOCK_CNT => DEC_BLOCK_CNT,
								ren => ren,
								wrreq_data => wrreq_data,
								wrreq_data2 => wrreq_data2 --: OUT std_logic
								);						
								
				--DEC_BLOCK_BUF1_D <= DEC_BLOCK_CNT;
				--DEC_BLOCK_BUF1_D <= '1' when done_block = '1'  else '0'; --d_fifo2(31 downto 27) = "10001" 
				--PDEC_BLOCK_CNT <= DEC_BLOCK_BUF1_D and not DEC_BLOCK_BUF1_Q;	
				
				ren_n <= not ren;
				--ren_n_D <= not ren;
				--ren_n <= ren_n_Q;	
				
				or_n_D <= or_n;
				
--				fq_D <= fq;


--				insert_gad <= '1' when (fq_Q(31 downto 27) = "10001" or fq_Q(31 downto 27) = "10010" or fq_Q(31 downto 27) = "10000") else --blk trailer and event header  and blk header
--								 '0';
--
--
--				dummy_high <= fq_Q(35 downto 27)&ga(4 downto 0)&fq_Q(21 downto 0) when (data_high_sel ='1' and insert_gad = '1') else
--								  fq_Q when (data_high_sel ='1' and insert_gad = '0'); --else (others => '0')
--								  
--				dummy_low <= fq_Q(35 downto 27)&ga(4 downto 0)&fq_Q(21 downto 0) when (data_low_sel ='1' and insert_gad = '1') else
--								  fq_Q when (data_low_sel ='1' and insert_gad = '0'); --else (others => '0')
--			
					  
-- CRAZY CHANGE FOR 16 to 18 BIT CONVERSION THHING
	fq_D <= "0000"&fq(33 downto 18)&fq(15 downto 0); -- shifting "00"'s from 16 bit PROC load
				

	insert_blk_head <= '1' when (fq_Q(31 downto 27) = "10000") else -- block header 
					       '0';	
							 
	insert_ev_head <= '1' when (fq_Q(31 downto 27) = "10010") else -- event header 
					       '0';	

	insert_ev_trail <= '1' when (fq_Q(31 downto 27) = "11101") else -- event trailer 
					       '0';			 

	insert_blk_trail <= '1' when (fq_Q(31 downto 27) = "10001") else -- block trailer 
					       '0';

	insert_raw_head <= '1' when (fq_Q(31 downto 27) = "10100") else -- raw header 
					       '0';						 

--	insert_gad <= '1' when (fq_Q(31 downto 27) = "10010" or fq_Q(31 downto 27) = "11101" or fq_Q(31 downto 27) = "10001") else --event header, ev trailer, blk trailer 
--					  '0';								 


	dummy_high <= "0100"&fq_Q(31 downto 27)&ga(4 downto 0)&"0010000"&BLOCK_NUMBER_Q&fq_Q(7 downto 0) when insert_blk_head = '1' else
					  "0001"&fq_Q(31 downto 27)&ga(4 downto 0)&fq_Q(21 downto 0) 								 when insert_ev_head = '1' else
					  "0010"&fq_Q(31 downto 27)&ga(4 downto 0)&fq_Q(21 downto 0) 								 when insert_ev_trail = '1' else
					  "1000"&fq_Q(31 downto 27)&ga(4 downto 0)&fq_Q(21 downto 0) 								 when insert_blk_trail = '1' else
					  fq_Q(35 downto 20)&ga(4 downto 0)&fq_Q(14 downto 0)	 								 			 when insert_raw_head = '1' else
					  fq_Q; 
					  
	dummy_low <=  "0100"&fq_Q(31 downto 27)&ga(4 downto 0)&"0010000"&BLOCK_NUMBER_Q&fq_Q(7 downto 0) when insert_blk_head = '1' else
					  "0001"&fq_Q(31 downto 27)&ga(4 downto 0)&fq_Q(21 downto 0) 								 when insert_ev_head = '1' else
					  "0010"&fq_Q(31 downto 27)&ga(4 downto 0)&fq_Q(21 downto 0) 								 when insert_ev_trail = '1' else
					  "1000"&fq_Q(31 downto 27)&ga(4 downto 0)&fq_Q(21 downto 0) 								 when insert_blk_trail = '1' else
					  fq_Q(35 downto 20)&ga(4 downto 0)&fq_Q(14 downto 0) 								 		 when insert_raw_head = '1' else
					  fq_Q; 
						  
--				
--				fq_D <= fq(35 downto 27)&ga(4 downto 0)&fq(21 downto 0) when insert_gad = '1' else
--						  fq;
						  
--				dummy_high <= fq_Q when (data_high_sel_Q ='1') else (others => '0');
--				dummy_low <= fq_Q when (data_low_sel_Q = '1') else (others => '0');
-----------------------------------------------------------------------------------------------------
-----------------------------------x2, x3 FIFOS------------------------------------------------------
-- used by this interface to efficiently transfer data through vme bus protocol 
-- not the same as fe fifos, nor main fifo.
				   
x2 : fifo_4096x36v PORT MAP (										-- HIGH 36-bit word of output fifo
								rst	 => RESET_P, --RESET_P, --reset_ctrl,--RESET_N, 
								wr_clk => wrt_clk_1, -- CHANGED FROM WRT_CLK
								rd_clk => rd_clk_1,
								din	 => dummy_high,
								wr_en	 => wrreq_data,--wrreq_data wrreq_data_Q
								rd_en	 => rdreq1,
								dout 	 => d_fifo1,
								full	 => high_fifo_full,
								empty	 => empty1,
								rd_data_count	 => nw_o1,
								wr_data_count	 => open
						--		wrempty	 => open,
						--		wrfull	 => open,
								 );	
								 
x3 : fifo_4096x36v PORT MAP (										-- LOW 36-bit word of output fifo										
								rst	 => RESET_P, --RESET_P, --reset_ctrl,--RESET_N,
								wr_clk => wrt_clk_1, -- CHANGED FROM WRT_CLK
								rd_clk => rd_clk_1,
								din	 => dummy_low,
								wr_en	 => wrreq_data2,--wrreq_data2 wrreq_data2_Q
								rd_en	 => rdreq2,
								dout 	 => d_fifo2,
								full	 => low_fifo_full,
								empty	 => empty2,
								rd_data_count	 => nw_o2,
								wr_data_count	 => open
						--		wrempty	 => open,
						--		wrfull	 => open,
								 );
								 
	fREG : process (clk_B, RESET_N) -- need to change reset for this to work too
      begin
        if RESET_N = '0' then 
		  
				fq_Q <= (others => '0');
--				
				INC_BLOCK_BUF1_Q <= '0';
				INC_BLOCK_BUF2_Q <= '0';
				INC_BLOCK_BUF3_Q <= '0';
				
				BLOCK_CNT_Q <= (others => '0');
				BLOCK_NUMBER_Q <= (others => '0');
				
				done_block_Q <= '0';
				done_block_2Q <= '0';				
				done_block_3Q <= '0';
				
        elsif (clk_B = '1' and clk_B'event) then 
		  
				fq_Q <= fq_D;

				BLOCK_CNT_Q <= BLOCK_CNT_D;
				BLOCK_NUMBER_Q <= BLOCK_NUMBER_D;

				INC_BLOCK_BUF1_Q <= INC_BLOCK_BUF1_D;
				INC_BLOCK_BUF2_Q <= INC_BLOCK_BUF2_D;
				INC_BLOCK_BUF3_Q <= INC_BLOCK_BUF3_D;
		
				done_block_Q <= done_block_D;
				done_block_2Q <= done_block_2D;
				done_block_3Q <= done_block_3D;
								
        end if;
      end process fREG;
		
-----------------------------------------------------------------------------------------------------
-----------------------------------BLOCK Counter-----------------------------------------------------

		--INC_BLOCK_CNT <= spare1; --from proc, event in 1MB FIFO
		INC_BLOCK_BUF1_D <= spare1; 
		INC_BLOCK_BUF2_D <= INC_BLOCK_BUF1_Q;
		INC_BLOCK_BUF3_D <= INC_BLOCK_BUF2_Q;

		done_block_D <= done_block; -- from Ed's interface, block read by VME
		done_block_2D <= done_block_Q;
		done_block_3D <= done_block_2Q;

		PINC_BLOCK_CNT <= INC_BLOCK_BUF2_Q and not INC_BLOCK_BUF3_Q;
		pdone_block <= done_block_2Q and not done_block_3Q;

		BLOCK_CNT_D <= BLOCK_CNT_Q + 1 when PINC_BLOCK_CNT = '1' and pdone_block = '0' else --PDEC_BLOCK_CNT --and pdone_block = '0'
                     BLOCK_CNT_Q - 1 when pdone_block = '1' and PINC_BLOCK_CNT = '0' else --PDEC_BLOCK_CNT --and PINC_BLOCK_CNT = '0' CHANGE
                     BLOCK_CNT_Q;


		
--	REG : process (clk_B, RESET_N) -- need to change reset for this to work too
--      begin
--        if RESET_N = '0' then 
--		  
--				--fq_Q <= (others => '0');
--				
--				INC_BLOCK_BUF1_Q <= '0';
--				INC_BLOCK_BUF2_Q <= '0';
--				
--				BLOCK_CNT_Q <= (others => '0');
--				BLOCK_NUMBER_Q <= (others => '0');
--				
--				done_block_Q <= '0';
--				done_block_2Q <= '0';				
--
--        elsif (clk_B = '1' and clk_B'event) then 
--		  
--				--fq_Q <= fq_D;
--				
--				INC_BLOCK_BUF1_Q <= INC_BLOCK_BUF1_D;
--				INC_BLOCK_BUF2_Q <= INC_BLOCK_BUF2_D;
--				
--				BLOCK_CNT_Q <= BLOCK_CNT_D;
--				BLOCK_NUMBER_Q <= BLOCK_NUMBER_D;
--
--				done_block_Q <= done_block_D;
--				done_block_2Q <= done_block_2D;
--				
--        end if;
--      end process REG;
				
end a1;
		
