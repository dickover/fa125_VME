--  C:\USERS\DICKOVER\DOCUMENTS\...\EXECUTE_HACK.vhd
--  VHDL code created by Xilinx's StateCAD 10.1
--  Wed Feb 05 15:18:25 2014

--  This VHDL code (for use with IEEE compliant tools) was generated using: 
--  enumerated state assignment with structured code format.
--  Minimization is enabled,  implied else is enabled, 
--  and outputs are speed optimized.

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY EXECUTE_HACK IS
	PORT (CLK,EXEC,IDLE_REG,RdyForCmd,RESET_N: IN std_logic;
		CmdPending,EXEC_GO,HOST_IDLE : OUT std_logic);
END;

ARCHITECTURE BEHAVIOR OF EXECUTE_HACK IS
	TYPE type_sreg2 IS (Drop_Idle,EXEC_H,EXEC_L,Main_Idle,STATE0);
	SIGNAL sreg2, next_sreg2 : type_sreg2;
	SIGNAL next_CmdPending,next_EXEC_GO,next_HOST_IDLE : std_logic;
BEGIN
	PROCESS (CLK, RESET_N, next_sreg2, next_CmdPending, next_EXEC_GO, 
		next_HOST_IDLE)
	BEGIN
		IF ( RESET_N='0' ) THEN
			sreg2 <= Main_Idle;
			EXEC_GO <= '0';
			CmdPending <= '1';
			HOST_IDLE <= '1';
		ELSIF CLK='1' AND CLK'event THEN
			sreg2 <= next_sreg2;
			CmdPending <= next_CmdPending;
			EXEC_GO <= next_EXEC_GO;
			HOST_IDLE <= next_HOST_IDLE;
		END IF;
	END PROCESS;

	PROCESS (sreg2,EXEC,IDLE_REG,RdyForCmd)
	BEGIN
		next_CmdPending <= '0'; next_EXEC_GO <= '0'; next_HOST_IDLE <= '0'; 

		next_sreg2<=Drop_Idle;

		CASE sreg2 IS
			WHEN Drop_Idle =>
				IF ( RdyForCmd='1' ) THEN
					next_sreg2<=EXEC_H;
					next_HOST_IDLE<='0';
					next_CmdPending<='1';
					next_EXEC_GO<='1';
				 ELSE
					next_sreg2<=Drop_Idle;
					next_EXEC_GO<='0';
					next_HOST_IDLE<='0';
					next_CmdPending<='1';
				END IF;
			WHEN EXEC_H =>
				next_sreg2<=STATE0;
				next_HOST_IDLE<='0';
				next_CmdPending<='1';
				next_EXEC_GO<='1';
			WHEN EXEC_L =>
				IF ( IDLE_REG='1' AND EXEC='0' ) THEN
					next_sreg2<=Main_Idle;
					next_EXEC_GO<='0';
					next_HOST_IDLE<='1';
					next_CmdPending<='1';
				 ELSE
					next_sreg2<=EXEC_L;
					next_EXEC_GO<='0';
					next_HOST_IDLE<='0';
					next_CmdPending<='1';
				END IF;
			WHEN Main_Idle =>
				IF ( EXEC='1' ) THEN
					next_sreg2<=Drop_Idle;
					next_EXEC_GO<='0';
					next_HOST_IDLE<='0';
					next_CmdPending<='1';
				 ELSE
					next_sreg2<=Main_Idle;
					next_EXEC_GO<='0';
					next_HOST_IDLE<='1';
					next_CmdPending<='1';
				END IF;
			WHEN STATE0 =>
				next_sreg2<=EXEC_L;
				next_EXEC_GO<='0';
				next_HOST_IDLE<='0';
				next_CmdPending<='1';
			WHEN OTHERS =>
		END CASE;
	END PROCESS;
END BEHAVIOR;
