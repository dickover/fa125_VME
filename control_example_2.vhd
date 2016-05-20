-- control_example - use of registers with 'vme_interface_1' -  8/3/10, 8/13/10  EJ

-- eight 32-bit R/W registers, eight 32-bit R-only status registers, interrupt ID access
-- main data access

library ieee;
use ieee.std_logic_1164.all;

entity control_example is
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
			
			   stat0: in std_logic_vector(31 downto 0);		-- status inputs 
			   stat1: in std_logic_vector(31 downto 0);
			   stat2: in std_logic_vector(31 downto 0);
			   stat3: in std_logic_vector(31 downto 0);
			   stat4: in std_logic_vector(31 downto 0);
			   stat5: in std_logic_vector(31 downto 0);
			   stat6: in std_logic_vector(31 downto 0);
			   stat7: in std_logic_vector(31 downto 0);
			   stat8: in std_logic_vector(31 downto 0);		-- status inputs 
			   stat9: in std_logic_vector(31 downto 0);
			   stat10: in std_logic_vector(31 downto 0);
			   stat11: in std_logic_vector(31 downto 0);
			   stat12: in std_logic_vector(31 downto 0);
			   stat13: in std_logic_vector(31 downto 0);
			   stat14: in std_logic_vector(31 downto 0);
			   stat15: in std_logic_vector(31 downto 0);
			
			 data_in: in std_logic_vector(31 downto 0);		-- data input to registers (from VME (write))
			data_out: out std_logic_vector(31 downto 0) );	-- data output from reg, status (to VME (read))
						
	end control_example;

architecture a1 of control_example is

	component register_32s is
		port (   data: in std_logic_vector(31 downto 0);
				ce_b0: in std_logic;
				ce_b1: in std_logic;
				ce_b2: in std_logic;
				ce_b3: in std_logic;
				  clk: in std_logic;
				reset: in std_logic;
				  reg: out std_logic_vector(31 downto 0) );
	end component;

	component dffe_32 is
		port( 	  d: in std_logic_vector(31 downto 0);
				clk: in std_logic;
			reset_n: in std_logic;
			  set_n: in std_logic;
			clk_ena: in std_logic;
				  q: out std_logic_vector(31 downto 0));
	end component;

	component mux8_to_1 is
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
	end component;
	
	component mux4_to_1 is
		generic( bitlength: integer );
		port( d0_in: in std_logic_vector((bitlength-1) downto 0);
			  d1_in: in std_logic_vector((bitlength-1) downto 0);
			  d2_in: in std_logic_vector((bitlength-1) downto 0);
			  d3_in: in std_logic_vector((bitlength-1) downto 0);
				sel: in std_logic_vector(1 downto 0);
			  d_out: out std_logic_vector((bitlength-1) downto 0));
	end component;
				   

	signal ctrl_fpga: std_logic;

	signal register0, register1, register2, register3, register4, register5, register6, register7: std_logic;
	signal register8, register9, register10, register11, register12, register13, register14, register15: std_logic;
	signal rstatus0, rstatus1, rstatus2, rstatus3, rstatus4, rstatus5, rstatus6, rstatus7: std_logic;
	signal rstatus8, rstatus9, rstatus10, rstatus11, rstatus12, rstatus13, rstatus14, rstatus15: std_logic;
	signal reg0_int, reg1_int, reg2_int, reg3_int, reg4_int, reg5_int, reg6_int, reg7_int: std_logic_vector(31 downto 0);
	signal reg8_int, reg9_int, reg10_int, reg11_int, reg12_int, reg13_int, reg14_int, reg15_int: std_logic_vector(31 downto 0);
	signal status0, status1, status2, status3, status4, status5, status6, status7: std_logic_vector(31 downto 0);
	signal status8, status9, status10, status11, status12, status13, status14, status15: std_logic_vector(31 downto 0);

	signal ce_b0_reg0, ce_b1_reg0, ce_b2_reg0, ce_b3_reg0: std_logic;
	signal ce_b0_reg1, ce_b1_reg1, ce_b2_reg1, ce_b3_reg1: std_logic;
	signal ce_b0_reg2, ce_b1_reg2, ce_b2_reg2, ce_b3_reg2: std_logic;
	signal ce_b0_reg3, ce_b1_reg3, ce_b2_reg3, ce_b3_reg3: std_logic;
	signal ce_b0_reg4, ce_b1_reg4, ce_b2_reg4, ce_b3_reg4: std_logic;
	signal ce_b0_reg5, ce_b1_reg5, ce_b2_reg5, ce_b3_reg5: std_logic;
	signal ce_b0_reg6, ce_b1_reg6, ce_b2_reg6, ce_b3_reg6: std_logic;
	signal ce_b0_reg7, ce_b1_reg7, ce_b2_reg7, ce_b3_reg7: std_logic;
	signal ce_b0_reg8, ce_b1_reg8, ce_b2_reg8, ce_b3_reg8: std_logic;
	signal ce_b0_reg9, ce_b1_reg9, ce_b2_reg9, ce_b3_reg9: std_logic;
	signal ce_b0_reg10, ce_b1_reg10, ce_b2_reg10, ce_b3_reg10: std_logic;
	signal ce_b0_reg11, ce_b1_reg11, ce_b2_reg11, ce_b3_reg11: std_logic;
	signal ce_b0_reg12, ce_b1_reg12, ce_b2_reg12, ce_b3_reg12: std_logic;
	signal ce_b0_reg13, ce_b1_reg13, ce_b2_reg13, ce_b3_reg13: std_logic;
	signal ce_b0_reg14, ce_b1_reg14, ce_b2_reg14, ce_b3_reg14: std_logic;
	signal ce_b0_reg15, ce_b1_reg15, ce_b2_reg15, ce_b3_reg15: std_logic;

	signal registers, status, ce_status, status_read, stat_haps: std_logic;
	signal register_read, interrupt_read: std_logic;
	
	signal sel_reg, sel_reg_chose, sel_status, sel_status_chose: std_logic_vector(3 downto 0);
	
	signal sel_read: std_logic_vector(1 downto 0);

	signal reg_out, status_out, interrupt_out: std_logic_vector(31 downto 0);
	
	signal zero_32: std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
	signal one_24: std_logic_vector(23 downto 0):= "111111111111111111111111";
	
	signal reset_n: std_logic;
	
begin

	reg0 <= reg0_int;
	reg1 <= reg1_int;
	reg2 <= reg2_int;
	reg3 <= reg3_int;
	reg4 <= reg4_int;
	reg5 <= reg5_int;
	reg6 <= reg6_int;
	reg7 <= reg7_int;
	reg8 <= reg8_int;
	reg9 <= reg9_int;
	reg10 <= reg10_int;
	reg11 <= reg11_int;
	reg12 <= reg12_int;
	reg13 <= reg13_int;
	reg14 <= reg14_int;
	reg15 <= reg15_int;
	
	reset_n <= not reset;
	
	fast_access <= (a32_cycle or a32m_cycle) and w_n;										-- main data access (R only)		

												   
	-- register addresses
	register_read <= '1' when ( 
										(--(register0 = '1')or(register1 = '1')or(register2 = '1')or(register3 = '1')
										--or(register4 = '1')or(register5 = '1')or(register6 = '1')or(register7 = '1')
										--(register8 = '1')or
										(register9 = '1')or(register10 = '1')or(register11 = '1')
										--or(register12 = '1')
										or(register13 = '1')or(register14 = '1')or(register15 = '1'))
										and (a24_cycle = '1') and (read_sig = '1') and not (busy = '1') ) 
							else '0';
							
with addr select sel_reg_chose <=
									"0000"	when "00000000000001--", --0-- 0x0004 m_swapctl
									"0001"	when "00000000000011--", --1-- 0x000c m_csr
									"0010"	when "00000000000100--", --2-- 0x0010 m_pwrctrl
   								"0011"	when "00000000000101--", --3-- 0x00014 m_dacctrl
									"0100"	when "11010000000111--", --4-- 0xd01c proc_csr (removed was 0xd004)
									"0101"	when "00010000000001--", --5-- 0x1004 fe_csr --don't need??
									"0110"	when "11010000000100--", --6-- 0xd010 proc_fifo_test
									"0111"	when "00000000000111--", --7-- 0x001C m_fifo_test
									"1000"	when "00000000010000--", --8-- 0x0040 m_block_csr_wr
									"1001"	when "00000000010001--", --9-- 0x0044 m_CTRL1
									"1010"	when "00000000010010--", --10-- 0x0048 m_ADR32
									"1011"	when "00000000010011--", --11-- 0x004C m_ADR32_MB
									"1100"	when "00000000010110--", --12-- 0x0058 m_config_csr_wr
									"1101"	when "00000000010111--", --13-- 0x005c m_config_addr_data
									"1110"	when "11101111000111--",
									"1111"	when "11101111001000--",
									(others => '-') when others;
	sel_reg <= sel_reg_chose when (register_read = '1') else
			   "0000";	
			   	
	register0  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "00001") ) else --0-- 0x0004 m_swapctl
				  '0';
	register1  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "00011") ) else --1-- 0x000c m_csr
				  '0';
	register2  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "00100") ) else --2-- 0x0010 m_pwrctrl
				  '0';
	register3  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "00101") ) else --3-- 0x00014 m_dacctrl
				  '0';
	register4  <= '1' when ((addr(15 downto 12) = "1101") and (addr(6 downto 2) = "00111") ) else --4-- 0xd01c proc_csr (removed was 0xd004)
				  '0';
	register5  <= '1' when ((addr(15 downto 12) = "1111") and (addr(6 downto 2) = "00001") ) else --5-- 0xf004 fe_csr (removed was 0x1001)
				  '0';
	register6  <= '1' when ((addr(15 downto 12) = "1111") and (addr(6 downto 2) = "00111") ) else --6-- 0xf01c proc_fifo_test (removed was 0xd010)
				  '0';
	register7  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "00111") ) else --7-- 0x001C m_fifo_test
				  '0';
	register8  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "10000") ) else --8-- 0x0040 m_block_csr_wr
				  '0';
	register9  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "10001") ) else --9-- 0x0044 m_CTRL1
				  '0';
	register10  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "10010") ) else --10-- 0x0048 m_ADR32
				  '0';
	register11  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "10011") ) else --11-- 0x004C m_ADR32_MB
				  '0';
	register12  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "10110") ) else --12-- 0x0058 m_config_csr_wr
				  '0';
	register13  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "10111") ) else --13-- 0x005C m_config_addr_data
				  '0';
	register14  <= '1' when ((addr(15 downto 12) = "1110") and (addr(6 downto 2) = "00110") ) else-- 0xE018 SPARE
				  '0';
	register15  <= '1' when ((addr(15 downto 12) = "1110") and (addr(6 downto 2) = "00111") ) else-- 0xE01C spare_ctrl_3
				  '0';
				  
	ce_b0_reg0 <= register0 and a24_cycle and byte(0) and write_stb;	-- byte enables for register write
	ce_b1_reg0 <= register0 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg0 <= register0 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg0 <= register0 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg1 <= register1 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg1 <= register1 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg1 <= register1 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg1 <= register1 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg2 <= register2 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg2 <= register2 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg2 <= register2 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg2 <= register2 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg3 <= register3 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg3 <= register3 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg3 <= register3 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg3 <= register3 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg4 <= register4 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg4 <= register4 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg4 <= register4 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg4 <= register4 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg5 <= register5 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg5 <= register5 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg5 <= register5 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg5 <= register5 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg6 <= register6 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg6 <= register6 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg6 <= register6 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg6 <= register6 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg7 <= register7 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg7 <= register7 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg7 <= register7 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg7 <= register7 and a24_cycle and byte(3) and write_stb;
	
	ce_b0_reg8 <= register8 and a24_cycle and byte(0) and write_stb;	-- byte enables for register write
	ce_b1_reg8 <= register8 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg8 <= register8 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg8 <= register8 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg9 <= register9 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg9 <= register9 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg9 <= register9 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg9 <= register9 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg10 <= register10 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg10 <= register10 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg10 <= register10 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg10 <= register10 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg11 <= register11 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg11 <= register11 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg11 <= register11 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg11 <= register11 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg12 <= register12 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg12 <= register12 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg12 <= register12 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg12 <= register12 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg13 <= register13 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg13 <= register13 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg13 <= register13 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg13 <= register13 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg14 <= register14 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg14 <= register14 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg14 <= register14 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg14 <= register14 and a24_cycle and byte(3) and write_stb;

	ce_b0_reg15 <= register15 and a24_cycle and byte(0) and write_stb;
	ce_b1_reg15 <= register15 and a24_cycle and byte(1) and write_stb;
	ce_b2_reg15 <= register15 and a24_cycle and byte(2) and write_stb;
	ce_b3_reg15 <= register15 and a24_cycle and byte(3) and write_stb;
	
x0:	register_32s port map (   data => data_in,							-- 8 32-bit R/W registers
							 ce_b0 => ce_b0_reg0,
							 ce_b1 => ce_b1_reg0,
							 ce_b2 => ce_b2_reg0,
							 ce_b3 => ce_b3_reg0,
							   clk => clk,
							 reset => reset,
							   reg => reg0_int );

x1:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg1,
							 ce_b1 => ce_b1_reg1,
							 ce_b2 => ce_b2_reg1,
							 ce_b3 => ce_b3_reg1,
							   clk => clk,
							 reset => reset,
							   reg => reg1_int );

x2:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg2,
							 ce_b1 => ce_b1_reg2,
							 ce_b2 => ce_b2_reg2,
							 ce_b3 => ce_b3_reg2,
							   clk => clk,
							 reset => reset,
							   reg => reg2_int );

x3:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg3,
							 ce_b1 => ce_b1_reg3,
							 ce_b2 => ce_b2_reg3,
							 ce_b3 => ce_b3_reg3,
							   clk => clk,
							 reset => reset,
							   reg => reg3_int );

x4:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg4,
							 ce_b1 => ce_b1_reg4,
							 ce_b2 => ce_b2_reg4,
							 ce_b3 => ce_b3_reg4,
							   clk => clk,
							 reset => reset,
							   reg => reg4_int );

x5:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg5,
							 ce_b1 => ce_b1_reg5,
							 ce_b2 => ce_b2_reg5,
							 ce_b3 => ce_b3_reg5,
							   clk => clk,
							 reset => reset,
							   reg => reg5_int );

x6:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg6,
							 ce_b1 => ce_b1_reg6,
							 ce_b2 => ce_b2_reg6,
							 ce_b3 => ce_b3_reg6,
							   clk => clk,
							 reset => reset,
							   reg => reg6_int );

x7:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg7,
							 ce_b1 => ce_b1_reg7,
							 ce_b2 => ce_b2_reg7,
							 ce_b3 => ce_b3_reg7,
							   clk => clk,
							 reset => reset,
							   reg => reg7_int );
								
x88:	register_32s port map (   data => data_in,							-- 8 32-bit R/W registers
							 ce_b0 => ce_b0_reg8,
							 ce_b1 => ce_b1_reg8,
							 ce_b2 => ce_b2_reg8,
							 ce_b3 => ce_b3_reg8,
							   clk => clk,
							 reset => reset,
							   reg => reg8_int );

x99:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg9,
							 ce_b1 => ce_b1_reg9,
							 ce_b2 => ce_b2_reg9,
							 ce_b3 => ce_b3_reg9,
							   clk => clk,
							 reset => reset,
							   reg => reg9_int );

x1010:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg10,
							 ce_b1 => ce_b1_reg10,
							 ce_b2 => ce_b2_reg10,
							 ce_b3 => ce_b3_reg10,
							   clk => clk,
							 reset => reset,
							   reg => reg10_int );

x1111:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg11,
							 ce_b1 => ce_b1_reg11,
							 ce_b2 => ce_b2_reg11,
							 ce_b3 => ce_b3_reg11,
							   clk => clk,
							 reset => reset,
							   reg => reg11_int );

x1212:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg12,
							 ce_b1 => ce_b1_reg12,
							 ce_b2 => ce_b2_reg12,
							 ce_b3 => ce_b3_reg12,
							   clk => clk,
							 reset => reset,
							   reg => reg12_int );

x1313:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg13,
							 ce_b1 => ce_b1_reg13,
							 ce_b2 => ce_b2_reg13,
							 ce_b3 => ce_b3_reg13,
							   clk => clk,
							 reset => reset,
							   reg => reg13_int );

x1414:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg14,
							 ce_b1 => ce_b1_reg14,
							 ce_b2 => ce_b2_reg14,
							 ce_b3 => ce_b3_reg14,
							   clk => clk,
							 reset => reset,
							   reg => reg14_int );

x1515:	register_32s port map (   data => data_in,
							 ce_b0 => ce_b0_reg15,
							 ce_b1 => ce_b1_reg15,
							 ce_b2 => ce_b2_reg15,
							 ce_b3 => ce_b3_reg15,
							   clk => clk,
							 reset => reset,
							   reg => reg15_int );

x8: mux8_to_1 generic map ( bitlength => 32 )
				 port map ( d0_in => reg0_int,
							d1_in => reg1_int,
							d2_in => reg2_int,
							d3_in => reg3_int,
							d4_in => reg4_int,
							d5_in => reg5_int,
							d6_in => reg6_int,
							d7_in => reg7_int,
							d8_in => reg8_int,
							d9_in => reg9_int,
							d10_in => reg10_int,
							d11_in => reg11_int,
							d12_in => reg12_int,
							d13_in => reg13_int,
							d14_in => reg14_int,
							d15_in => reg15_int,
							  sel => sel_reg,
							d_out => reg_out );

	-------------------------------------------------------------------------------------------
	----------------------------status addresses-----------------------------------------------
	-------------------------------------------------------------------------------------------

with addr select sel_status_chose <=									
												"0000"	when "00000000000000--", -- 0x0000 m_id
												"0000"	when "00000000000001--", -- 0x0004 m_swapctrl
												"0000"	when "00000000000100--", -- 0x0010 m_pwrctrl
												"0000"	when "00000000000011--", -- 0x000c m_csr 
												"0000"	when "00000000000010--", -- 0x0008 m_ver
												"0000"	when "00000000001100--", -- 0x0030 m_temp1
												"0000"	when "00000000001101--", -- 0x0034 m_temp2
												"0000"	when "00000000001110--", -- GAD readback 0x038
												"0000"	when "00000000001111--", -- a32 base 0x003c
												"0000"	when "00000000001000--", 
												"0000"	when "00000000001001--", 
												"0000"	when "00000000001010--", 
												"0000"	when "00000000001011--", -- 0x0020-0x002C m_serial (serial number)
												--proc serial reads
												"0000"	when "1101------------",
												--fe serial reads
												"0000"	when "0001------------", "0000"	when "0010------------", "0000"	when "0011------------", "0000"	when "0100------------",-- 0xX000 fe_all test
												"0000"	when "0101------------", "0000"	when "0110------------", "0000"	when "0111------------", "0000"	when "1000------------",
												"0000"	when "1001------------", "0000"	when "1010------------", "0000"	when "1011------------", "0000"	when "1100------------",
												--end reg 0
												"0001"	when "00000000010000--", --0x0040 m_block_csr_rd
												"0010"	when "00000000010101--", --0x0054 m_block_count
												"0011"	when "00000000010110--", --0x0058 m_config_csr_rd
												
												"1011"	when "11100000000100--",
												"1100"	when "11100000000101--",
												"1101"	when "11100000000111--",
												"1110"	when "11100000001000--",
												"1111"	when "11100000001001--",
												(others => '-') when others;	
												
	ce_status <= stat_haps and a24_cycle and byte(0) and read_sig;			-- capture data when byte(0) accessed (read) 
-- NOTE: Had to change to read_sig from read_stb to hold dff until serial comm to proc completed, thus releasing 'busy'
 
	status_read <= '1' when ((stat_haps = '1') and (a24_cycle = '1') and (read_sig = '1')) else '0'; -- and not (busy = '1') 
	
	stat_haps <= '1' when ((rstatus0 = '1')or(rstatus1 = '1')or(rstatus2 = '1')or(rstatus3 = '1')
									or(rstatus4 = '1')or(rstatus5 = '1')or(rstatus6 = '1')or(rstatus7 = '1')
									or(rstatus8 = '1')or(rstatus9 = '1')or(rstatus10 = '1')or(rstatus11 = '1')
									or(rstatus12 = '1')or(rstatus13 = '1')or(rstatus14 = '1')or(rstatus15 = '1'))
							else '0';
	
	sel_status <= sel_status_chose when (status_read = '1') else
				  "0000";

	rstatus0  <= '1' when ((addr = "00000000000000--") or (addr = "00000000000010--") or (addr = "00000000001100--") --0x0000 m_id, 0x0008 m_ver, 0x0030 m_temp1
							  or (addr = "00000000001101--") 
							  or (addr = "00000000001000--") or (addr = "00000000001001--") or (addr = "00000000001010--") -- 0x0020-0x0028 m_serial (serial number)
							  or (addr = "00000000001011--") or (addr = "00000000001110--") or (addr = "00000000001111--")-- 0x002C m_serial, 0x0038/GAD, 0x003c/a32ba 
							  --proc serial reads
							  or (addr = "1101------------")
							  --fe serial reads
							  or (addr = "0001------------") or (addr = "0010------------") or (addr = "0011------------") --0xX000 fe_all test
							  or (addr = "0100------------") or (addr = "0101------------") or (addr = "0110------------")
							  or (addr = "0111------------") or (addr = "1000------------") or (addr = "1001------------")
							  or (addr = "1010------------") or (addr = "1011------------") or (addr = "1100------------")	
							  --more main
							  or (addr = "00000000000001--") or (addr = "00000000000011--") or (addr = "00000000000100--") -- 0x0004/swap, 0x000C/m_csr, 0x0010/pwr, 0x0014/dac,  
							  or (addr = "00000000000101--")  ) else  
				  '0';
				  
	rstatus1  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "10000") ) else-- 0x0040 m_block_csr_rd
				  '0';
	rstatus2  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "10101") ) else-- 0x0054 m_block_count
				  '0';
	rstatus3  <= '1' when ((addr(15 downto 12) = "0000") and (addr(6 downto 2) = "10110") ) else-- 0x0058 m_config_csr_rd
				  '0';	
--	rstatus4  <= '1' when ((addr(15 downto 12) = "0001") and (addr(5 downto 2) = "0000") ) else-- 0x1000 fe_ver
--				  '0';				  
--	rstatus5  <= '1' when ((addr(15 downto 12) = "1101") and (addr(5 downto 2) = "0000") ) else-- 0xd000 status_proc_id
--				  '0';	
--	rstatus6  <= '1' when ((addr(15 downto 12) = "1101") and (addr(5 downto 2) = "0010") ) else-- 0xd008 status_proc_test
--				  '0';	
--	rstatus7  <= '1' when ( (addr = "00010000010000--") or (addr = "00010000010001--") or (addr = "00010000010010--") ) else -- 0xX040-0xX054 fe_acqfifo
--				  '0';			
--	rstatus8  <= '1' when ((addr(15 downto 12) = "0000") and (addr(5 downto 2) = ("1000" or "1010" or "1011")) ) else-- 0x0020-x002c m_serial
--				  '0';
--	rstatus9  <= '1' when ((addr(15 downto 12) = "0000") and (addr(5 downto 2) = "1000") ) else-- new
--				  '0';
--	rstatus10  <= '1' when ((addr(15 downto 12) = "0000") and (addr(5 downto 2) = "1001") ) else-- new
--				  '0';
--	rstatus11  <= '1' when ((addr(15 downto 12) = "0000") and (addr(5 downto 2) = "1010") ) else-- new
--				  '0';	
--	rstatus12  <= '1' when ((addr(15 downto 12) = "0000") and (addr(5 downto 2) = "1011") ) else-- new
--				  '0';				  
--	rstatus13  <= '1' when ((addr(15 downto 12) = "1110") and (addr(5 downto 2) = "0111") ) else-- new
--				  '0';	
--	rstatus14  <= '1' when ((addr(15 downto 12) = "1110") and (addr(5 downto 2) = "1000") ) else-- new
--				  '0';	
--	rstatus15  <= '1' when ((addr(15 downto 12) = "1110") and (addr(5 downto 2) = "1001") ) else-- new
--				  '0';	
				  
x10: dffe_32 port map ( 	d => stat0,									-- 8 32-bit R-only status registers
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status0 );

x11: dffe_32 port map ( 	d => stat1,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status1 );

x12: dffe_32 port map ( 	d => stat2,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status2 );

x13: dffe_32 port map ( 	d => stat3,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status3 );

x14: dffe_32 port map ( 	d => stat4,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status4 );

x15: dffe_32 port map ( 	d => stat5,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status5 );

x16: dffe_32 port map ( 	d => stat6,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status6 );

x17: dffe_32 port map ( 	d => stat7,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status7 );
							
x1818: dffe_32 port map ( 	d => stat8,									-- 8 32-bit R-only status registers
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status8 );

x1919: dffe_32 port map ( 	d => stat9,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status9 );

x2020: dffe_32 port map ( 	d => stat10,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status10 );

x2121: dffe_32 port map ( 	d => stat11,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status11 );

x2222: dffe_32 port map ( 	d => stat12,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status12 );

x2323: dffe_32 port map ( 	d => stat13,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status13 );

x2424: dffe_32 port map ( 	d => stat14,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status14 );

x2525: dffe_32 port map ( 	d => stat15,
						  clk => clk,
					  reset_n => reset_n,
						set_n => '1',
					  clk_ena => ce_status,
							q => status15 );


x18: mux8_to_1 generic map ( bitlength => 32 )
				 port map ( d0_in => status0,
							d1_in => status1,
							d2_in => status2,
							d3_in => status3,
							d4_in => status4,
							d5_in => status5,
							d6_in => status6,
							d7_in => status7,
							d8_in => status8,
							d9_in => status9,
							d10_in => status10,
							d11_in => status11,
							d12_in => status12,
							d13_in => status13,
							d14_in => status14,
							d15_in => status15,
							  sel => sel_status,
							d_out => status_out );

	interrupt_out <= one_24 & reg7_int(7 downto 0);			-- register 7, byte3 contains interrupt ID
	interrupt_read <= '1' when ( (iack_cycle = '1') and (read_sig = '1') ) else
					  '0';

-- multiplex register, status, interrupt outputs

	sel_read <= "01" when ( status_read = '1' ) else
				   "10" when ( interrupt_read = '1') else
				   "00";									-- default is register read

x19: mux4_to_1 generic map ( bitlength => 32 )
				 port map ( d0_in => reg_out,
							d1_in => status_out,
							d2_in => interrupt_out,
							d3_in => zero_32,
							  sel => sel_read,
							d_out => data_out );

end a1;


--main
--or (addr = "00000000001010--") or (addr = "00000000001011--") 
--fe

--"0000"	when "00010000010000--", "0000"	when "00010000010001--", "0000"	when "00010000010010--", -- 0x1040-0x1054 acq
--"0000"	when "00010000010011--", "0000"	when "00010000010100--", "0000"	when "00010000010101--",
--"0000"	when "00100000010000--", "0000"	when "00100000010001--", "0000"	when "00100000010010--", -- 0x2040-0x2054 acq
--"0000"	when "00100000010011--", "0000"	when "00100000010100--", "0000"	when "00100000010101--",
--"0000"	when "00110000010000--", "0000"	when "00110000010001--", "0000"	when "00110000010010--", -- 0x3040-0x3054 acq
--"0000"	when "00110000010011--", "0000"	when "00110000010100--", "0000"	when "00110000010101--",
--"0000"	when "01000000010000--", "0000"	when "01000000010001--", "0000"	when "01000000010010--", -- 0x4040-0x4054 acq
--"0000"	when "01000000010011--", "0000"	when "01000000010100--", "0000"	when "01000000010101--",
--"0000"	when "01010000010000--", "0000"	when "01010000010001--", "0000"	when "01010000010010--", -- 0x5040-0x5054 acq
--"0000"	when "01010000010011--", "0000"	when "01010000010100--", "0000"	when "01010000010101--",
--"0000"	when "01100000010000--", "0000"	when "01100000010001--", "0000"	when "01100000010010--", -- 0x6040-0x6054 acq
--"0000"	when "01100000010011--", "0000"	when "01100000010100--", "0000"	when "01100000010101--",
--"0000"	when "01110000010000--", "0000"	when "01110000010001--", "0000"	when "01110000010010--", -- 0x7040-0x7054 acq
--"0000"	when "01110000010011--", "0000"	when "01110000010100--", "0000"	when "01110000010101--",
--"0000"	when "10000000010000--", "0000"	when "10000000010001--", "0000"	when "10000000010010--", -- 0x8040-0x8054 acq
--"0000"	when "10000000010011--", "0000"	when "10000000010100--", "0000"	when "10000000010101--",
--"0000"	when "10010000010000--", "0000"	when "10010000010001--", "0000"	when "10010000010010--", -- 0x9040-0x9054 acq
--"0000"	when "10010000010011--", "0000"	when "10010000010100--", "0000"	when "10010000010101--",
--"0000"	when "10100000010000--", "0000"	when "10100000010001--", "0000"	when "10100000010010--", -- 0xa040-0xa054 acq
--"0000"	when "10100000010011--", "0000"	when "10100000010100--", "0000"	when "10100000010101--",
--"0000"	when "10110000010000--", "0000"	when "10110000010001--", "0000"	when "10110000010010--", -- 0xb040-0xb054 acq
--"0000"	when "10110000010011--", "0000"	when "10110000010100--", "0000"	when "10110000010101--",
--"0000"	when "11000000010000--", "0000"	when "11000000010001--", "0000"	when "11000000010010--", -- 0xc040-0xc054 acq
--"0000"	when "11000000010011--", "0000"	when "11000000010100--", "0000"	when "11000000010101--",


--"0000"	when "00010000000000--", "0000"	when "00100000000000--", "0000"	when "00110000000000--", "0000"	when "01000000000000--",-- 0xX000 fe_ver
--"0000"	when "01010000000000--", "0000"	when "01100000000000--", "0000"	when "01110000000000--", "0000"	when "10000000000000--",
--"0000"	when "10010000000000--", "0000"	when "10100000000000--", "0000"	when "10110000000000--", "0000"	when "11000000000000--",

--"0000"	when "00010000000001--", "0000"	when "00100000000001--", "0000"	when "00110000000001--", "0000"	when "01000000000001--",-- 0xX004 fe_csr
--"0000"	when "01010000000001--", "0000"	when "01100000000001--", "0000"	when "01110000000001--", "0000"	when "10000000000001--",
--"0000"	when "10010000000001--", "0000"	when "10100000000001--", "0000"	when "10110000000001--", "0000"	when "11000000000001--",

--******************************************************************************************************************************************
							  
--							  or (addr = "00010000000000--") or (addr = "00100000000000--") or (addr = "00110000000000--") --0xX000 fe_ver
--							  or (addr = "01000000000000--") or (addr = "01010000000000--") or (addr = "01100000000000--")
--							  or (addr = "01110000000000--") or (addr = "10000000000000--") or (addr = "10010000000000--")
--							  or (addr = "10100000000000--") or (addr = "10110000000000--") or (addr = "11000000000000--")
							  
--							  or (addr = "00010000010000--") or (addr = "00010000010001--") or (addr = "00010000010010--") -- 0x1040-0x1054 acq
--							  or (addr = "00010000010011--") or (addr = "00010000010100--") or (addr = "00010000010101--")
--							  or (addr = "00100000010000--") or (addr = "00100000010001--") or (addr = "00100000010010--") -- 0x2040-0x2054 acq
--							  or (addr = "00100000010011--") or (addr = "00100000010100--") or (addr = "00100000010101--")
--							  or (addr = "00110000010000--") or (addr = "00110000010001--") or (addr = "00110000010010--") -- 0x3040-0x3054 acq
--							  or (addr = "00110000010011--") or (addr = "00110000010100--") or (addr = "00110000010101--")
--							  or (addr = "01000000010000--") or (addr = "01000000010001--") or (addr = "01000000010010--") -- 0x4040-0x4054 acq
--							  or (addr = "01000000010011--") or (addr = "01000000010100--") or (addr = "01000000010101--")
--							  or (addr = "01010000010000--") or (addr = "01010000010001--") or (addr = "01010000010010--") -- 0x5040-0x5054 acq
--							  or (addr = "01010000010011--") or (addr = "01010000010100--") or (addr = "01010000010101--")
--							  or (addr = "01100000010000--") or (addr = "01100000010001--") or (addr = "01100000010010--") -- 0x6040-0x6054 acq
--							  or (addr = "01100000010011--") or (addr = "01100000010100--") or (addr = "01100000010101--")
--							  or (addr = "01110000010000--") or (addr = "01110000010001--") or (addr = "01110000010010--") -- 0x7040-0x7054 acq
--							  or (addr = "01110000010011--") or (addr = "01110000010100--") or (addr = "01110000010101--")
--							  or (addr = "10000000010000--") or (addr = "10000000010001--") or (addr = "10000000010010--") -- 0x8040-0x8054 acq
--							  or (addr = "10000000010011--") or (addr = "10000000010100--") or (addr = "10000000010101--")
--							  or (addr = "10010000010000--") or (addr = "10010000010001--") or (addr = "10010000010010--") -- 0x9040-0x9054 acq
--							  or (addr = "10010000010011--") or (addr = "10010000010100--") or (addr = "10010000010101--")
--							  or (addr = "10100000010000--") or (addr = "10100000010001--") or (addr = "10100000010010--") -- 0xa040-0xa054 acq
--							  or (addr = "10100000010011--") or (addr = "10100000010100--") or (addr = "10100000010101--")
--							  or (addr = "10110000010000--") or (addr = "10110000010001--") or (addr = "10110000010010--") -- 0xb040-0xb054 acq
--							  or (addr = "10110000010011--") or (addr = "10110000010100--") or (addr = "10110000010101--")
--							  or (addr = "11000000010000--") or (addr = "11000000010001--") or (addr = "11000000010010--") -- 0xc040-0xc054 acq
--							  or (addr = "11000000010011--") or (addr = "11000000010100--") or (addr = "11000000010101--")

							  --fe csr readback 
--							  or (addr = "00010000000001--") -- 0x1004
--							  or (addr = "00100000000001--") -- 0x2004...
--							  or (addr = "00110000000001--")
--							  or (addr = "01000000000001--")
--							  or (addr = "01010000000001--")
--							  or (addr = "01100000000001--")
--							  or (addr = "01110000000001--")
--							  or (addr = "10000000000001--")
--							  or (addr = "10010000000001--")
--							  or (addr = "10100000000001--")
--							  or (addr = "10110000000001--")
--							  or (addr = "11000000000001--")


--PROC

--												"0000"	when "11010000000000--", -- 0xd000 status_proc_id
--												"0000"	when "11010000000001--", -- 0xd004 proc CSR readback 
--												"0000"	when "11010000000010--", -- 0xd008 proc trig readback 
--												"0000"	when "11010000000100--", -- 0xd010 proc fcontrol readback 

--												"0000"	when "11010000000011--", -- 0xd00c
--												"0000"	when "11010000000101--", -- 0xd014
--												"0000"	when "11010000000110--", -- 0xd018
--												"0000"	when "11010000000111--", -- 0xd01c
--												"0000"	when "11010000001000--", -- 0xd020
--												"0000"	when "11010000001001--", -- 0xd024
--												"0000"	when "11010000001010--", -- 0xd028

--******************************************************************************************************************************************
--or (addr = "11010000000000--") or (addr = "11010000000010--") --0x0034 m_temp2, 0xd000 status_proc_id, 0xd008 status_proc_test  
--							  or (addr = "11010000000001--") -- 0xd004 proc_csr
--							  or (addr = "11010000000010--") or (addr = "11010000000100--") -- 0xd008 proc trig, 0xd010 fcontrol	
--							  
--							  or (addr = "11010000000011--")-- 0xd00c
--							  or (addr = "11010000000101--")-- 0xd014
--							  or (addr = "11010000000110--")-- 0xd018
--							  or (addr = "11010000001000--")-- 0xd020
--							  or (addr = "11010000001001--")-- 0xd024
--							  or (addr = "11010000001010--")-- 0xd028
--							  or (addr = "11010000000111--")-- 0xd01c		
