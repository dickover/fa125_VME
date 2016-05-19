--  C:\USERS\DICKOVER\DOCUMENTS\...\BLOCK_SEND_NEW.vhd
--  VHDL code created by Xilinx's StateCAD 10.1
--  Tue Feb 16 16:50:44 2016

--  This VHDL code (for use with Xilinx XST) was generated using: 
--  enumerated state assignment with structured code format.
--  Minimization is enabled,  implied else is enabled, 
--  and outputs are speed optimized.

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY BLOCK_SEND_NEW IS
	PORT (CLK,FIFO_GO,RESET_N: IN std_logic;
		ren,wrreq_data,wrreq_data2 : OUT std_logic);
END;

ARCHITECTURE BEHAVIOR OF BLOCK_SEND_NEW IS
	TYPE type_sreg IS (CHECK_FULL_HIGH,CHECK_FULL_LOW,DATA_HIGH,DATA_LOW,STATE0,
		STATE1,STATE2,STATE4);
	SIGNAL sreg, next_sreg : type_sreg;
	SIGNAL next_ren,next_wrreq_data,next_wrreq_data2 : std_logic;
BEGIN
	PROCESS (CLK, RESET_N, next_sreg, next_ren, next_wrreq_data, 
		next_wrreq_data2)
	BEGIN
		IF ( RESET_N='0' ) THEN
			sreg <= STATE0;
			ren <= '0';
			wrreq_data <= '0';
			wrreq_data2 <= '0';
		ELSIF CLK='1' AND CLK'event THEN
			sreg <= next_sreg;
			ren <= next_ren;
			wrreq_data <= next_wrreq_data;
			wrreq_data2 <= next_wrreq_data2;
		END IF;
	END PROCESS;

	PROCESS (sreg,FIFO_GO)
	BEGIN
		next_ren <= '0'; next_wrreq_data <= '0'; next_wrreq_data2 <= '0'; 

		next_sreg<=CHECK_FULL_HIGH;

		CASE sreg IS
			WHEN CHECK_FULL_HIGH =>
				IF ( FIFO_GO='1' ) THEN
					next_sreg<=STATE1;
					next_wrreq_data<='0';
					next_wrreq_data2<='0';
					next_ren<='1';
				 ELSE
					next_sreg<=CHECK_FULL_HIGH;
					next_ren<='0';
					next_wrreq_data<='0';
					next_wrreq_data2<='0';
				END IF;
			WHEN CHECK_FULL_LOW =>
				IF ( FIFO_GO='1' ) THEN
					next_sreg<=STATE2;
					next_wrreq_data<='0';
					next_wrreq_data2<='0';
					next_ren<='1';
				 ELSE
					next_sreg<=CHECK_FULL_LOW;
					next_ren<='0';
					next_wrreq_data<='0';
					next_wrreq_data2<='0';
				END IF;
			WHEN DATA_HIGH =>
				next_sreg<=CHECK_FULL_LOW;
				next_ren<='0';
				next_wrreq_data<='0';
				next_wrreq_data2<='0';
			WHEN DATA_LOW =>
				next_sreg<=CHECK_FULL_HIGH;
				next_ren<='0';
				next_wrreq_data<='0';
				next_wrreq_data2<='0';
			WHEN STATE0 =>
				IF ( FIFO_GO='1' ) THEN
					next_sreg<=STATE4;
					next_wrreq_data<='0';
					next_wrreq_data2<='0';
					next_ren<='1';
				 ELSE
					next_sreg<=STATE0;
					next_ren<='0';
					next_wrreq_data<='0';
					next_wrreq_data2<='0';
				END IF;
			WHEN STATE1 =>
				next_sreg<=DATA_HIGH;
				next_ren<='0';
				next_wrreq_data2<='0';
				next_wrreq_data<='1';
			WHEN STATE2 =>
				next_sreg<=DATA_LOW;
				next_ren<='0';
				next_wrreq_data<='0';
				next_wrreq_data2<='1';
			WHEN STATE4 =>
				next_sreg<=DATA_HIGH;
				next_ren<='0';
				next_wrreq_data2<='0';
				next_wrreq_data<='1';
			WHEN OTHERS =>
		END CASE;
	END PROCESS;
END BEHAVIOR;
