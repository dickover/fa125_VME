--  C:\PROJECTS_PHYSICS\CTP_V2\FPGA\...\AT35DBSM.vhd
--  VHDL code created by Xilinx's StateCAD 10.1
--  Tue Oct 15 16:48:51 2013

--  This VHDL code (for use with IEEE compliant tools) was generated using: 
--  enumerated state assignment with structured code format.
--  Minimization is enabled,  implied else is enabled, 
--  and outputs are speed optimized.

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY SHELL_AT35DBSM IS
	PORT (CLK,CmdPending,DatByteFrRomDon,DatByteToRomDon,DumByteDone,EXEC,
		HOST_IDLE,OPCODE_0,OPCODE_1,OPCODE_2,PageProgDone,RESET_N,SckHalfTiHiTc,
		SckHalfTiLoTc,ShiftInDone,ShiftOutDone,SromCsNHiTiTc: IN std_logic;
		BaseTimerEn,ByteToFlashSel0,ByteToFlashSel1,ByteToFlashSel2,ClrByteFrRomCnt
			,ClrByteToRomCnt,ClrSckHalfTiHi,ClrSckHalfTiLo,ClrSftCntIn,ClrSftCntOut,
			DatFrRomValid,IDLE,IncByteFrRomCnt,IncByteToRomCnt,LdShiftRegOut,RdyForCmd,
			RdyForNeDatToRom,SftInCntEn,SftOutCntEn,ShiftRegInEn,ShiftRegOutEn,SROM_CS_N,
			SROM_SCK : OUT std_logic;
		RomRd : BUFFER std_logic);

	SIGNAL RomWr,SckEn,SckIdleDone,SckIdleEn: std_logic;
END;

ARCHITECTURE BEHAVIOR OF SHELL_AT35DBSM IS
	TYPE type_sreg IS (SCKHi1,SckHi2a_RomLarDa,SckHi2b_Wait,SckHi2d_Wait1,
		SCKHiRd_Wait,SckIdle,SckIdle_Done,SckIdle_Hi,SckIdle_Lo,SckLo1,
		SckLo2a_SftRegEn,SckLo2b_Wait,SckRd_ValidByte,SckRdHi2_ShftBit,SckRdHi2b_Wait
		,SckRdLo1,STATE0,STATE2);
	SIGNAL sreg, next_sreg : type_sreg;
	TYPE type_sreg2 IS (MainIdle,MainIncDumWd,MainldByte2,MainldByte3,
		MainldByte4,MainLdChiEraByt2,MainLdChiEraByt3,MainLdChiEraByt4,MainLdDatoRom,
		MainRdByteCnt,MainRdBytes,MainRdyForCmd,MainRomProgWt,MainWaitMinCsNHi,
		MainWrByte2,MainWrByte3,MainWrByte4,MainWrChiEraByt2,MainWRChiEraByt3,
		MainWrChiEraByt4,MainWrDatoRom,MainwrDummyDone,MainWrDummyWd,MainWrOpCodChEra
		,MainWrOpCode,MainWt1,MainWtClkIdleDon);
	SIGNAL sreg2, next_sreg2 : type_sreg2;
	SIGNAL next_BaseTimerEn,next_ByteToFlashSel0,next_ByteToFlashSel1,
		next_ByteToFlashSel2,next_ClrByteFrRomCnt,next_ClrByteToRomCnt,
		next_ClrSckHalfTiHi,next_ClrSckHalfTiLo,next_ClrSftCntIn,next_ClrSftCntOut,
		next_DatFrRomValid,next_IDLE,next_IncByteFrRomCnt,next_IncByteToRomCnt,
		next_LdShiftRegOut,next_RdyForCmd,next_RdyForNeDatToRom,next_RomRd,next_RomWr
		,next_SckEn,next_SckIdleDone,next_SckIdleEn,next_SftInCntEn,next_SftOutCntEn,
		next_ShiftRegInEn,next_ShiftRegOutEn,next_SROM_CS_N,next_SROM_SCK : 
		std_logic;
	SIGNAL ByteToFlashSel : std_logic_vector (2 DOWNTO 0);
BEGIN
	PROCESS (CLK, RESET_N, next_sreg, next_ClrSckHalfTiHi, next_ClrSckHalfTiLo, 
		next_ClrSftCntIn, next_ClrSftCntOut, next_DatFrRomValid, next_SckIdleDone, 
		next_SftInCntEn, next_SftOutCntEn, next_ShiftRegInEn, next_ShiftRegOutEn, 
		next_SROM_SCK)
	BEGIN
		IF ( RESET_N='0' ) THEN
			sreg <= SckIdle;
			DatFrRomValid <= '0';
			SftInCntEn <= '0';
			SftOutCntEn <= '0';
			ShiftRegInEn <= '0';
			ShiftRegOutEn <= '0';
			ClrSckHalfTiHi <= '1';
			ClrSckHalfTiLo <= '1';
			ClrSftCntIn <= '1';
			ClrSftCntOut <= '1';
			SckIdleDone <= '1';
			SROM_SCK <= '1';
		ELSIF CLK='1' AND CLK'event THEN
			sreg <= next_sreg;
			ClrSckHalfTiHi <= next_ClrSckHalfTiHi;
			ClrSckHalfTiLo <= next_ClrSckHalfTiLo;
			ClrSftCntIn <= next_ClrSftCntIn;
			ClrSftCntOut <= next_ClrSftCntOut;
			DatFrRomValid <= next_DatFrRomValid;
			SckIdleDone <= next_SckIdleDone;
			SftInCntEn <= next_SftInCntEn;
			SftOutCntEn <= next_SftOutCntEn;
			ShiftRegInEn <= next_ShiftRegInEn;
			ShiftRegOutEn <= next_ShiftRegOutEn;
			SROM_SCK <= next_SROM_SCK;
		END IF;
	END PROCESS;

	PROCESS (CLK, RESET_N, next_sreg2, next_BaseTimerEn, next_ClrByteFrRomCnt, 
		next_ClrByteToRomCnt, next_IDLE, next_IncByteFrRomCnt, next_IncByteToRomCnt, 
		next_LdShiftRegOut, next_RdyForCmd, next_RdyForNeDatToRom, next_RomRd, 
		next_RomWr, next_SckEn, next_SckIdleEn, next_SROM_CS_N, next_ByteToFlashSel2,
		 next_ByteToFlashSel1, next_ByteToFlashSel0)
	BEGIN
		IF ( RESET_N='0' ) THEN
			sreg2 <= MainIdle;
			BaseTimerEn <= '0';
			IncByteFrRomCnt <= '0';
			IncByteToRomCnt <= '0';
			RdyForCmd <= '0';
			RdyForNeDatToRom <= '0';
			RomRd <= '0';
			RomWr <= '0';
			SckEn <= '0';
			SROM_CS_N <= '1';
			ClrByteFrRomCnt <= '1';
			ClrByteToRomCnt <= '1';
			IDLE <= '1';
			LdShiftRegOut <= '1';
			SckIdleEn <= '1';
			ByteToFlashSel2 <= '0';
			ByteToFlashSel1 <= '0';
			ByteToFlashSel0 <= '0';
		ELSIF CLK='1' AND CLK'event THEN
			sreg2 <= next_sreg2;
			BaseTimerEn <= next_BaseTimerEn;
			ClrByteFrRomCnt <= next_ClrByteFrRomCnt;
			ClrByteToRomCnt <= next_ClrByteToRomCnt;
			IDLE <= next_IDLE;
			IncByteFrRomCnt <= next_IncByteFrRomCnt;
			IncByteToRomCnt <= next_IncByteToRomCnt;
			LdShiftRegOut <= next_LdShiftRegOut;
			RdyForCmd <= next_RdyForCmd;
			RdyForNeDatToRom <= next_RdyForNeDatToRom;
			RomRd <= next_RomRd;
			RomWr <= next_RomWr;
			SckEn <= next_SckEn;
			SckIdleEn <= next_SckIdleEn;
			SROM_CS_N <= next_SROM_CS_N;
			ByteToFlashSel2 <= next_ByteToFlashSel2;
			ByteToFlashSel1 <= next_ByteToFlashSel1;
			ByteToFlashSel0 <= next_ByteToFlashSel0;
		END IF;
	END PROCESS;

	PROCESS (sreg,sreg2,CmdPending,DatByteFrRomDon,DatByteToRomDon,DumByteDone,
		EXEC,HOST_IDLE,OPCODE_0,OPCODE_1,OPCODE_2,PageProgDone,RomRd,RomWr,SckEn,
		SckHalfTiHiTc,SckHalfTiLoTc,SckIdleDone,SckIdleEn,ShiftInDone,ShiftOutDone,
		SromCsNHiTiTc,ByteToFlashSel)
	BEGIN
		next_BaseTimerEn <= '0'; next_ByteToFlashSel0 <= '0'; next_ByteToFlashSel1 
			<= '0'; next_ByteToFlashSel2 <= '0'; next_ClrByteFrRomCnt <= '0'; 
			next_ClrByteToRomCnt <= '0'; next_ClrSckHalfTiHi <= '0'; next_ClrSckHalfTiLo 
			<= '0'; next_ClrSftCntIn <= '0'; next_ClrSftCntOut <= '0'; next_DatFrRomValid
			 <= '0'; next_IDLE <= '0'; next_IncByteFrRomCnt <= '0'; next_IncByteToRomCnt 
			<= '0'; next_LdShiftRegOut <= '0'; next_RdyForCmd <= '0'; 
			next_RdyForNeDatToRom <= '0'; next_RomRd <= '0'; next_RomWr <= '0'; 
			next_SckEn <= '0'; next_SckIdleDone <= '0'; next_SckIdleEn <= '0'; 
			next_SftInCntEn <= '0'; next_SftOutCntEn <= '0'; next_ShiftRegInEn <= '0'; 
			next_ShiftRegOutEn <= '0'; next_SROM_CS_N <= '1'; next_SROM_SCK <= '0'; 
		ByteToFlashSel<=std_logic_vector'("000"); 

		next_sreg<=SCKHi1;
		next_sreg2<=MainIdle;

		CASE sreg IS
			WHEN SCKHi1 =>
				IF ( SckEn='0' ) THEN
					next_sreg<=SckIdle;
					next_DatFrRomValid<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiHi<='1';
					next_ClrSckHalfTiLo<='1';
					next_ClrSftCntOut<='1';
					next_ClrSftCntIn<='1';
					next_SckIdleDone<='1';
				ELSIF ( RomRd='1' ) THEN
					next_sreg<=STATE0;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
					next_ClrSftCntIn<='1';
				ELSIF ( SckHalfTiHiTc='1' ) THEN
					next_sreg<=SckLo1;
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='0';
					next_ClrSckHalfTiHi<='1';
				 ELSE
					next_sreg<=SCKHi1;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntIn<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
					next_ClrSftCntOut<='1';
				END IF;
			WHEN SckHi2a_RomLarDa =>
				next_sreg<=SckHi2b_Wait;
				next_ClrSckHalfTiHi<='0';
				next_ClrSftCntIn<='0';
				next_ClrSftCntOut<='0';
				next_DatFrRomValid<='0';
				next_SckIdleDone<='0';
				next_SftInCntEn<='0';
				next_SftOutCntEn<='0';
				next_ShiftRegInEn<='0';
				next_ShiftRegOutEn<='0';
				next_SROM_SCK<='1';
				next_ClrSckHalfTiLo<='1';
			WHEN SckHi2b_Wait =>
				IF ( ShiftOutDone='1' ) THEN
					next_sreg<=SCKHi1;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntIn<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
					next_ClrSftCntOut<='1';
				END IF;
				IF ( ShiftOutDone='0' ) THEN
					next_sreg<=SckHi2d_Wait1;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_ClrSckHalfTiLo<='1';
					next_SROM_SCK<='1';
				END IF;
			WHEN SckHi2d_Wait1 =>
				IF ( SckHalfTiHiTc='1' ) THEN
					next_sreg<=SckLo2a_SftRegEn;
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_SROM_SCK<='0';
					next_ClrSckHalfTiHi<='1';
					next_ShiftRegOutEn<='1';
				 ELSE
					next_sreg<=SckHi2d_Wait1;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_ClrSckHalfTiLo<='1';
					next_SROM_SCK<='1';
				END IF;
			WHEN SCKHiRd_Wait =>
				IF ( SckHalfTiHiTc='1' ) THEN
					next_sreg<=SckRdLo1;
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='0';
					next_ClrSckHalfTiHi<='1';
				 ELSE
					next_sreg<=SCKHiRd_Wait;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
					next_ClrSftCntIn<='1';
				END IF;
			WHEN SckIdle =>
				IF ( SckEn='1' AND RomWr='1' ) THEN
					next_sreg<=SCKHi1;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntIn<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
					next_ClrSftCntOut<='1';
				ELSIF ( SckIdleEn='1' ) THEN
					next_sreg<=SckIdle_Hi;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
				 ELSE
					next_sreg<=SckIdle;
					next_DatFrRomValid<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiHi<='1';
					next_ClrSckHalfTiLo<='1';
					next_ClrSftCntOut<='1';
					next_ClrSftCntIn<='1';
					next_SckIdleDone<='1';
				END IF;
			WHEN SckIdle_Done =>
				next_sreg<=SckIdle;
				next_DatFrRomValid<='0';
				next_SftInCntEn<='0';
				next_SftOutCntEn<='0';
				next_ShiftRegInEn<='0';
				next_ShiftRegOutEn<='0';
				next_SROM_SCK<='1';
				next_ClrSckHalfTiHi<='1';
				next_ClrSckHalfTiLo<='1';
				next_ClrSftCntOut<='1';
				next_ClrSftCntIn<='1';
				next_SckIdleDone<='1';
			WHEN SckIdle_Hi =>
				IF ( SckHalfTiHiTc='1' ) THEN
					next_sreg<=SckIdle_Lo;
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='0';
					next_ClrSckHalfTiHi<='1';
				 ELSE
					next_sreg<=SckIdle_Hi;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
				END IF;
			WHEN SckIdle_Lo =>
				IF ( SckHalfTiLoTc='1' ) THEN
					next_sreg<=SckIdle_Done;
					next_ClrSckHalfTiHi<='0';
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_SckIdleDone<='1';
				 ELSE
					next_sreg<=SckIdle_Lo;
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='0';
					next_ClrSckHalfTiHi<='1';
				END IF;
			WHEN SckLo1 =>
				IF ( SckHalfTiLoTc='1' ) THEN
					next_sreg<=SckHi2a_RomLarDa;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
					next_SftOutCntEn<='1';
				 ELSE
					next_sreg<=SckLo1;
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='0';
					next_ClrSckHalfTiHi<='1';
				END IF;
			WHEN SckLo2a_SftRegEn =>
				next_sreg<=SckLo2b_Wait;
				next_ClrSckHalfTiLo<='0';
				next_ClrSftCntIn<='0';
				next_ClrSftCntOut<='0';
				next_DatFrRomValid<='0';
				next_SckIdleDone<='0';
				next_SftInCntEn<='0';
				next_SftOutCntEn<='0';
				next_ShiftRegInEn<='0';
				next_ShiftRegOutEn<='0';
				next_SROM_SCK<='0';
				next_ClrSckHalfTiHi<='1';
			WHEN SckLo2b_Wait =>
				IF ( SckHalfTiLoTc='1' AND SckEn='0' ) THEN
					next_sreg<=SckIdle;
					next_DatFrRomValid<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiHi<='1';
					next_ClrSckHalfTiLo<='1';
					next_ClrSftCntOut<='1';
					next_ClrSftCntIn<='1';
					next_SckIdleDone<='1';
				ELSIF ( SckHalfTiLoTc='1' AND SckEn='1' AND RomWr='1' ) THEN
					next_sreg<=SckHi2a_RomLarDa;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
					next_SftOutCntEn<='1';
				 ELSE
					next_sreg<=SckLo2b_Wait;
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='0';
					next_ClrSckHalfTiHi<='1';
				END IF;
			WHEN SckRd_ValidByte =>
				IF ( SckEn='0' ) THEN
					next_sreg<=SckIdle;
					next_DatFrRomValid<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiHi<='1';
					next_ClrSckHalfTiLo<='1';
					next_ClrSftCntOut<='1';
					next_ClrSftCntIn<='1';
					next_SckIdleDone<='1';
				ELSIF ( SckEn='1' AND SckHalfTiHiTc='1' ) THEN
					next_sreg<=SckRdLo1;
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='0';
					next_ClrSckHalfTiHi<='1';
				 ELSE
					next_sreg<=SckRd_ValidByte;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntOut<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_DatFrRomValid<='1';
					next_ClrSckHalfTiLo<='1';
					next_SROM_SCK<='1';
					next_ClrSftCntIn<='1';
				END IF;
			WHEN SckRdHi2_ShftBit =>
				next_sreg<=SckRdHi2b_Wait;
				next_ClrSckHalfTiHi<='0';
				next_ClrSftCntIn<='0';
				next_ClrSftCntOut<='0';
				next_DatFrRomValid<='0';
				next_SckIdleDone<='0';
				next_SftInCntEn<='0';
				next_SftOutCntEn<='0';
				next_ShiftRegInEn<='0';
				next_ShiftRegOutEn<='0';
				next_SROM_SCK<='1';
				next_ClrSckHalfTiLo<='1';
			WHEN SckRdHi2b_Wait =>
				IF ( ShiftInDone='1' ) THEN
					next_sreg<=SckRd_ValidByte;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntOut<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_DatFrRomValid<='1';
					next_ClrSckHalfTiLo<='1';
					next_SROM_SCK<='1';
					next_ClrSftCntIn<='1';
				ELSIF ( SckHalfTiHiTc='1' ) THEN
					next_sreg<=SckRdLo1;
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='0';
					next_ClrSckHalfTiHi<='1';
				 ELSE
					next_sreg<=SckRdHi2b_Wait;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
				END IF;
			WHEN SckRdLo1 =>
				IF ( SckHalfTiLoTc='1' ) THEN
					next_sreg<=SckRdHi2_ShftBit;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
					next_SftInCntEn<='1';
					next_ShiftRegInEn<='1';
				 ELSE
					next_sreg<=SckRdLo1;
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='0';
					next_ClrSckHalfTiHi<='1';
				END IF;
			WHEN STATE0 =>
				IF ( SckHalfTiHiTc='1' ) THEN
					next_sreg<=STATE2;
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='0';
					next_ClrSckHalfTiHi<='1';
				 ELSE
					next_sreg<=STATE0;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
					next_ClrSftCntIn<='1';
				END IF;
			WHEN STATE2 =>
				IF ( SckHalfTiLoTc='1' ) THEN
					next_sreg<=SCKHiRd_Wait;
					next_ClrSckHalfTiHi<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='1';
					next_ClrSckHalfTiLo<='1';
					next_ClrSftCntIn<='1';
				 ELSE
					next_sreg<=STATE2;
					next_ClrSckHalfTiLo<='0';
					next_ClrSftCntIn<='0';
					next_ClrSftCntOut<='0';
					next_DatFrRomValid<='0';
					next_SckIdleDone<='0';
					next_SftInCntEn<='0';
					next_SftOutCntEn<='0';
					next_ShiftRegInEn<='0';
					next_ShiftRegOutEn<='0';
					next_SROM_SCK<='0';
					next_ClrSckHalfTiHi<='1';
				END IF;
			WHEN OTHERS =>
		END CASE;

		CASE sreg2 IS
			WHEN MainIdle =>
				IF ( CmdPending='1' ) THEN
					next_sreg2<=MainWtClkIdleDon;
					next_BaseTimerEn<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';
					next_IDLE<='1';
					next_LdShiftRegOut<='1';
					next_ClrByteToRomCnt<='1';
					next_ClrByteFrRomCnt<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				 ELSE
					next_sreg2<=MainIdle;
					next_BaseTimerEn<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SROM_CS_N<='1';
					next_IDLE<='1';
					next_LdShiftRegOut<='1';
					next_ClrByteToRomCnt<='1';
					next_ClrByteFrRomCnt<='1';
					next_SckIdleEn<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				END IF;
			WHEN MainIncDumWd =>
				next_sreg2<=MainWrDummyWd;
				next_BaseTimerEn<='0';
				next_ClrByteFrRomCnt<='0';
				next_ClrByteToRomCnt<='0';
				next_IDLE<='0';
				next_IncByteFrRomCnt<='0';
				next_IncByteToRomCnt<='0';
				next_LdShiftRegOut<='0';
				next_RdyForCmd<='0';
				next_RdyForNeDatToRom<='0';
				next_RomRd<='0';
				next_SckIdleEn<='0';
				next_SROM_CS_N<='0';
				next_RomWr<='1';
				next_SckEn<='1';

				ByteToFlashSel <= (std_logic_vector'("100"));
			WHEN MainldByte2 =>
				next_sreg2<=MainWrByte2;
				next_BaseTimerEn<='0';
				next_ClrByteFrRomCnt<='0';
				next_ClrByteToRomCnt<='0';
				next_IDLE<='0';
				next_IncByteFrRomCnt<='0';
				next_IncByteToRomCnt<='0';
				next_LdShiftRegOut<='0';
				next_RdyForCmd<='0';
				next_RdyForNeDatToRom<='0';
				next_RomRd<='0';
				next_SckIdleEn<='0';
				next_SROM_CS_N<='0';
				next_RomWr<='1';
				next_SckEn<='1';

				ByteToFlashSel <= (std_logic_vector'("010"));
			WHEN MainldByte3 =>
				next_sreg2<=MainWrByte3;
				next_BaseTimerEn<='0';
				next_ClrByteFrRomCnt<='0';
				next_ClrByteToRomCnt<='0';
				next_IDLE<='0';
				next_IncByteFrRomCnt<='0';
				next_IncByteToRomCnt<='0';
				next_LdShiftRegOut<='0';
				next_RdyForCmd<='0';
				next_RdyForNeDatToRom<='0';
				next_RomRd<='0';
				next_SckIdleEn<='0';
				next_SROM_CS_N<='0';
				next_RomWr<='1';
				next_SckEn<='1';

				ByteToFlashSel <= (std_logic_vector'("011"));
			WHEN MainldByte4 =>
				next_sreg2<=MainWrByte4;
				next_BaseTimerEn<='0';
				next_ClrByteFrRomCnt<='0';
				next_ClrByteToRomCnt<='0';
				next_IDLE<='0';
				next_IncByteFrRomCnt<='0';
				next_IncByteToRomCnt<='0';
				next_LdShiftRegOut<='0';
				next_RdyForCmd<='0';
				next_RomRd<='0';
				next_SckIdleEn<='0';
				next_SROM_CS_N<='0';
				next_RomWr<='1';
				next_SckEn<='1';
				next_RdyForNeDatToRom<='1';

				ByteToFlashSel <= (std_logic_vector'("100"));
			WHEN MainLdChiEraByt2 =>
				next_sreg2<=MainWrChiEraByt2;
				next_BaseTimerEn<='0';
				next_ClrByteFrRomCnt<='0';
				next_ClrByteToRomCnt<='0';
				next_IDLE<='0';
				next_IncByteFrRomCnt<='0';
				next_IncByteToRomCnt<='0';
				next_LdShiftRegOut<='0';
				next_RdyForCmd<='0';
				next_RdyForNeDatToRom<='0';
				next_RomRd<='0';
				next_SckIdleEn<='0';
				next_SROM_CS_N<='0';
				next_RomWr<='1';
				next_SckEn<='1';

				ByteToFlashSel <= (std_logic_vector'("110"));
			WHEN MainLdChiEraByt3 =>
				next_sreg2<=MainWRChiEraByt3;
				next_BaseTimerEn<='0';
				next_ClrByteFrRomCnt<='0';
				next_ClrByteToRomCnt<='0';
				next_IDLE<='0';
				next_IncByteFrRomCnt<='0';
				next_IncByteToRomCnt<='0';
				next_LdShiftRegOut<='0';
				next_RdyForCmd<='0';
				next_RdyForNeDatToRom<='0';
				next_RomRd<='0';
				next_SckIdleEn<='0';
				next_SROM_CS_N<='0';
				next_RomWr<='1';
				next_SckEn<='1';

				ByteToFlashSel <= (std_logic_vector'("111"));
			WHEN MainLdChiEraByt4 =>
				next_sreg2<=MainWrChiEraByt4;
				next_BaseTimerEn<='0';
				next_ClrByteFrRomCnt<='0';
				next_ClrByteToRomCnt<='0';
				next_IDLE<='0';
				next_IncByteFrRomCnt<='0';
				next_IncByteToRomCnt<='0';
				next_LdShiftRegOut<='0';
				next_RdyForCmd<='0';
				next_RdyForNeDatToRom<='0';
				next_RomRd<='0';
				next_SckIdleEn<='0';
				next_SROM_CS_N<='0';
				next_RomWr<='1';
				next_SckEn<='1';

				ByteToFlashSel <= (std_logic_vector'("111"));
			WHEN MainLdDatoRom =>
				next_sreg2<=MainWrDatoRom;
				next_BaseTimerEn<='0';
				next_ClrByteFrRomCnt<='0';
				next_ClrByteToRomCnt<='0';
				next_IDLE<='0';
				next_IncByteFrRomCnt<='0';
				next_IncByteToRomCnt<='0';
				next_LdShiftRegOut<='0';
				next_RdyForCmd<='0';
				next_RomRd<='0';
				next_SckIdleEn<='0';
				next_SROM_CS_N<='0';
				next_RomWr<='1';
				next_SckEn<='1';
				next_RdyForNeDatToRom<='1';

				ByteToFlashSel <= (std_logic_vector'("100"));
			WHEN MainRdByteCnt =>
				next_sreg2<=MainRdBytes;
				next_BaseTimerEn<='0';
				next_ClrByteFrRomCnt<='0';
				next_ClrByteToRomCnt<='0';
				next_IDLE<='0';
				next_IncByteFrRomCnt<='0';
				next_IncByteToRomCnt<='0';
				next_LdShiftRegOut<='0';
				next_RdyForCmd<='0';
				next_RdyForNeDatToRom<='0';
				next_RomWr<='0';
				next_SckIdleEn<='0';
				next_SROM_CS_N<='0';
				next_RomRd<='1';
				next_SckEn<='1';

				ByteToFlashSel <= (std_logic_vector'("000"));
			WHEN MainRdBytes =>
				IF ( ShiftInDone='0' ) THEN
					next_sreg2<=MainRdBytes;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomWr<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomRd<='1';
					next_SckEn<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				END IF;
				IF ( ShiftInDone='1' AND DatByteFrRomDon='0' ) THEN
					next_sreg2<=MainRdByteCnt;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomWr<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomRd<='1';
					next_SckEn<='1';
					next_IncByteFrRomCnt<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				END IF;
				IF ( ShiftInDone='1' AND DatByteFrRomDon='1' ) THEN
					next_sreg2<=MainWaitMinCsNHi;
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';
					next_BaseTimerEn<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				END IF;
			WHEN MainRdyForCmd =>
				IF ( EXEC='1' ) THEN
					next_sreg2<=MainWt1;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				ELSIF ( HOST_IDLE='1' ) THEN
					next_sreg2<=MainIdle;
					next_BaseTimerEn<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SROM_CS_N<='1';
					next_IDLE<='1';
					next_LdShiftRegOut<='1';
					next_ClrByteToRomCnt<='1';
					next_ClrByteFrRomCnt<='1';
					next_SckIdleEn<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				 ELSE
					next_sreg2<=MainRdyForCmd;
					next_BaseTimerEn<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';
					next_IDLE<='1';
					next_LdShiftRegOut<='1';
					next_ClrByteToRomCnt<='1';
					next_ClrByteFrRomCnt<='1';
					next_RdyForCmd<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				END IF;
			WHEN MainRomProgWt =>
				IF ( PageProgDone='1' ) THEN
					next_sreg2<=MainRdyForCmd;
					next_BaseTimerEn<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';
					next_IDLE<='1';
					next_LdShiftRegOut<='1';
					next_ClrByteToRomCnt<='1';
					next_ClrByteFrRomCnt<='1';
					next_RdyForCmd<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				 ELSE
					next_sreg2<=MainRomProgWt;
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';
					next_BaseTimerEn<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				END IF;
			WHEN MainWaitMinCsNHi =>
				IF ( SromCsNHiTiTc='1' ) THEN
					next_sreg2<=MainRdyForCmd;
					next_BaseTimerEn<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';
					next_IDLE<='1';
					next_LdShiftRegOut<='1';
					next_ClrByteToRomCnt<='1';
					next_ClrByteFrRomCnt<='1';
					next_RdyForCmd<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				 ELSE
					next_sreg2<=MainWaitMinCsNHi;
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';
					next_BaseTimerEn<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				END IF;
			WHEN MainWrByte2 =>
				IF ( ShiftOutDone='1' ) THEN
					next_sreg2<=MainldByte3;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';
					next_LdShiftRegOut<='1';

					ByteToFlashSel <= (std_logic_vector'("010"));
				 ELSE
					next_sreg2<=MainWrByte2;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';

					ByteToFlashSel <= (std_logic_vector'("010"));
				END IF;
			WHEN MainWrByte3 =>
				IF ( ShiftOutDone='1' ) THEN
					next_sreg2<=MainldByte4;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';
					next_LdShiftRegOut<='1';

					ByteToFlashSel <= (std_logic_vector'("011"));
				 ELSE
					next_sreg2<=MainWrByte3;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';

					ByteToFlashSel <= (std_logic_vector'("011"));
				END IF;
			WHEN MainWrByte4 =>
				IF ( ShiftOutDone='0' ) THEN
					next_sreg2<=MainWrByte4;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';
					next_RdyForNeDatToRom<='1';

					ByteToFlashSel <= (std_logic_vector'("100"));
				END IF;
				IF ( ShiftOutDone='1' AND OPCODE_1='0' AND OPCODE_0='1' ) THEN
					next_sreg2<=MainIncDumWd;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';
					next_IncByteToRomCnt<='1';

					ByteToFlashSel <= (std_logic_vector'("100"));
				END IF;
				IF ( ShiftOutDone='1' AND OPCODE_1='0' AND OPCODE_0='0' ) THEN
					next_sreg2<=MainLdDatoRom;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';
					next_LdShiftRegOut<='1';
					next_IncByteToRomCnt<='1';

					ByteToFlashSel <= (std_logic_vector'("100"));
				END IF;
				IF ( ShiftOutDone='1' AND OPCODE_1='1' AND OPCODE_0='1' ) THEN
					next_sreg2<=MainRomProgWt;
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';
					next_BaseTimerEn<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				END IF;
				IF ( ShiftOutDone='1' AND OPCODE_1='1' AND OPCODE_0='0' ) THEN
					next_sreg2<=MainRdByteCnt;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomWr<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomRd<='1';
					next_SckEn<='1';
					next_IncByteFrRomCnt<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				END IF;
			WHEN MainWrChiEraByt2 =>
				IF ( ShiftOutDone='1' ) THEN
					next_sreg2<=MainLdChiEraByt3;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';
					next_LdShiftRegOut<='1';

					ByteToFlashSel <= (std_logic_vector'("110"));
				 ELSE
					next_sreg2<=MainWrChiEraByt2;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';

					ByteToFlashSel <= (std_logic_vector'("110"));
				END IF;
			WHEN MainWRChiEraByt3 =>
				IF ( ShiftOutDone='1' ) THEN
					next_sreg2<=MainLdChiEraByt4;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';
					next_LdShiftRegOut<='1';

					ByteToFlashSel <= (std_logic_vector'("111"));
				 ELSE
					next_sreg2<=MainWRChiEraByt3;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';

					ByteToFlashSel <= (std_logic_vector'("111"));
				END IF;
			WHEN MainWrChiEraByt4 =>
				IF ( ShiftOutDone='1' ) THEN
					next_sreg2<=MainWaitMinCsNHi;
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';
					next_BaseTimerEn<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				 ELSE
					next_sreg2<=MainWrChiEraByt4;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';

					ByteToFlashSel <= (std_logic_vector'("111"));
				END IF;
			WHEN MainWrDatoRom =>
				IF ( ShiftOutDone='0' ) THEN
					next_sreg2<=MainWrDatoRom;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';
					next_RdyForNeDatToRom<='1';

					ByteToFlashSel <= (std_logic_vector'("100"));
				END IF;
				IF ( ShiftOutDone='1' AND DatByteToRomDon='0' ) THEN
					next_sreg2<=MainLdDatoRom;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';
					next_LdShiftRegOut<='1';
					next_IncByteToRomCnt<='1';

					ByteToFlashSel <= (std_logic_vector'("100"));
				END IF;
				IF ( ShiftOutDone='1' AND DatByteToRomDon='1' ) THEN
					next_sreg2<=MainWaitMinCsNHi;
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';
					next_BaseTimerEn<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				END IF;
			WHEN MainwrDummyDone =>
				next_sreg2<=MainRdByteCnt;
				next_BaseTimerEn<='0';
				next_ClrByteFrRomCnt<='0';
				next_ClrByteToRomCnt<='0';
				next_IDLE<='0';
				next_IncByteToRomCnt<='0';
				next_LdShiftRegOut<='0';
				next_RdyForCmd<='0';
				next_RdyForNeDatToRom<='0';
				next_RomWr<='0';
				next_SckIdleEn<='0';
				next_SROM_CS_N<='0';
				next_RomRd<='1';
				next_SckEn<='1';
				next_IncByteFrRomCnt<='1';

				ByteToFlashSel <= (std_logic_vector'("000"));
			WHEN MainWrDummyWd =>
				IF ( ShiftOutDone='0' ) THEN
					next_sreg2<=MainWrDummyWd;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';

					ByteToFlashSel <= (std_logic_vector'("100"));
				END IF;
				IF ( ShiftOutDone='1' AND DumByteDone='1' ) THEN
					next_sreg2<=MainwrDummyDone;
					next_BaseTimerEn<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomWr<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomRd<='1';
					next_SckEn<='1';
					next_ClrByteFrRomCnt<='1';

					ByteToFlashSel <= (std_logic_vector'("100"));
				END IF;
				IF ( ShiftOutDone='1' AND DumByteDone='0' ) THEN
					next_sreg2<=MainIncDumWd;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';
					next_IncByteToRomCnt<='1';

					ByteToFlashSel <= (std_logic_vector'("100"));
				END IF;
			WHEN MainWrOpCodChEra =>
				IF ( ShiftOutDone='1' ) THEN
					next_sreg2<=MainLdChiEraByt2;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';
					next_LdShiftRegOut<='1';

					ByteToFlashSel <= (std_logic_vector'("101"));
				 ELSE
					next_sreg2<=MainWrOpCodChEra;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';

					ByteToFlashSel <= (std_logic_vector'("101"));
				END IF;
			WHEN MainWrOpCode =>
				IF ( ShiftOutDone='1' ) THEN
					next_sreg2<=MainldByte2;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';
					next_LdShiftRegOut<='1';

					ByteToFlashSel <= (std_logic_vector'("001"));
				 ELSE
					next_sreg2<=MainWrOpCode;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';

					ByteToFlashSel <= (std_logic_vector'("001"));
				END IF;
			WHEN MainWt1 =>
				IF ( OPCODE_2='0' ) THEN
					next_sreg2<=MainWrOpCode;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';

					ByteToFlashSel <= (std_logic_vector'("001"));
				END IF;
				IF ( OPCODE_2='1' ) THEN
					next_sreg2<=MainWrOpCodChEra;
					next_BaseTimerEn<='0';
					next_ClrByteFrRomCnt<='0';
					next_ClrByteToRomCnt<='0';
					next_IDLE<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_LdShiftRegOut<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='0';
					next_RomWr<='1';
					next_SckEn<='1';

					ByteToFlashSel <= (std_logic_vector'("101"));
				END IF;
			WHEN MainWtClkIdleDon =>
				IF ( SckIdleDone='1' ) THEN
					next_sreg2<=MainRdyForCmd;
					next_BaseTimerEn<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';
					next_IDLE<='1';
					next_LdShiftRegOut<='1';
					next_ClrByteToRomCnt<='1';
					next_ClrByteFrRomCnt<='1';
					next_RdyForCmd<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				 ELSE
					next_sreg2<=MainWtClkIdleDon;
					next_BaseTimerEn<='0';
					next_IncByteFrRomCnt<='0';
					next_IncByteToRomCnt<='0';
					next_RdyForCmd<='0';
					next_RdyForNeDatToRom<='0';
					next_RomRd<='0';
					next_RomWr<='0';
					next_SckEn<='0';
					next_SckIdleEn<='0';
					next_SROM_CS_N<='1';
					next_IDLE<='1';
					next_LdShiftRegOut<='1';
					next_ClrByteToRomCnt<='1';
					next_ClrByteFrRomCnt<='1';

					ByteToFlashSel <= (std_logic_vector'("000"));
				END IF;
			WHEN OTHERS =>
		END CASE;

		next_ByteToFlashSel2 <= ByteToFlashSel(2);
		next_ByteToFlashSel1 <= ByteToFlashSel(1);
		next_ByteToFlashSel0 <= ByteToFlashSel(0);
	END PROCESS;
END BEHAVIOR;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY AT35DBSM IS
	PORT (ByteToFlashSel : OUT std_logic_vector (2 DOWNTO 0);
		CLK,CmdPending,DatByteFrRomDon,DatByteToRomDon,DumByteDone,EXEC,HOST_IDLE,
			OPCODE_0,OPCODE_1,OPCODE_2,PageProgDone,RESET_N,SckHalfTiHiTc,SckHalfTiLoTc,
			ShiftInDone,ShiftOutDone,SromCsNHiTiTc: IN std_logic;
		BaseTimerEn,ClrByteFrRomCnt,ClrByteToRomCnt,ClrSckHalfTiHi,ClrSckHalfTiLo,
			ClrSftCntIn,ClrSftCntOut,DatFrRomValid,IDLE,IncByteFrRomCnt,IncByteToRomCnt,
			LdShiftRegOut,RdyForCmd,RdyForNeDatToRom,SftInCntEn,SftOutCntEn,ShiftRegInEn,
			ShiftRegOutEn,SROM_CS_N,SROM_SCK : OUT std_logic;
		RomRd : BUFFER std_logic);
END;

ARCHITECTURE BEHAVIOR OF AT35DBSM IS
	COMPONENT SHELL_AT35DBSM
		PORT (CLK,CmdPending,DatByteFrRomDon,DatByteToRomDon,DumByteDone,EXEC,
			HOST_IDLE,OPCODE_0,OPCODE_1,OPCODE_2,PageProgDone,RESET_N,SckHalfTiHiTc,
			SckHalfTiLoTc,ShiftInDone,ShiftOutDone,SromCsNHiTiTc: IN std_logic;
			BaseTimerEn,ByteToFlashSel0,ByteToFlashSel1,ByteToFlashSel2,
				ClrByteFrRomCnt,ClrByteToRomCnt,ClrSckHalfTiHi,ClrSckHalfTiLo,ClrSftCntIn,
				ClrSftCntOut,DatFrRomValid,IDLE,IncByteFrRomCnt,IncByteToRomCnt,LdShiftRegOut
				,RdyForCmd,RdyForNeDatToRom,SftInCntEn,SftOutCntEn,ShiftRegInEn,ShiftRegOutEn
				,SROM_CS_N,SROM_SCK : OUT std_logic;
			RomRd : BUFFER std_logic);
	END COMPONENT;
BEGIN
	SHELL1_AT35DBSM : SHELL_AT35DBSM PORT MAP (CLK=>CLK,CmdPending=>CmdPending,
		DatByteFrRomDon=>DatByteFrRomDon,DatByteToRomDon=>DatByteToRomDon,DumByteDone
		=>DumByteDone,EXEC=>EXEC,HOST_IDLE=>HOST_IDLE,OPCODE_0=>OPCODE_0,OPCODE_1=>
		OPCODE_1,OPCODE_2=>OPCODE_2,PageProgDone=>PageProgDone,RESET_N=>RESET_N,
		SckHalfTiHiTc=>SckHalfTiHiTc,SckHalfTiLoTc=>SckHalfTiLoTc,ShiftInDone=>
		ShiftInDone,ShiftOutDone=>ShiftOutDone,SromCsNHiTiTc=>SromCsNHiTiTc,
		BaseTimerEn=>BaseTimerEn,ByteToFlashSel0=>ByteToFlashSel(0),ByteToFlashSel1=>
		ByteToFlashSel(1),ByteToFlashSel2=>ByteToFlashSel(2),ClrByteFrRomCnt=>
		ClrByteFrRomCnt,ClrByteToRomCnt=>ClrByteToRomCnt,ClrSckHalfTiHi=>
		ClrSckHalfTiHi,ClrSckHalfTiLo=>ClrSckHalfTiLo,ClrSftCntIn=>ClrSftCntIn,
		ClrSftCntOut=>ClrSftCntOut,DatFrRomValid=>DatFrRomValid,IDLE=>IDLE,
		IncByteFrRomCnt=>IncByteFrRomCnt,IncByteToRomCnt=>IncByteToRomCnt,
		LdShiftRegOut=>LdShiftRegOut,RdyForCmd=>RdyForCmd,RdyForNeDatToRom=>
		RdyForNeDatToRom,SftInCntEn=>SftInCntEn,SftOutCntEn=>SftOutCntEn,ShiftRegInEn
		=>ShiftRegInEn,ShiftRegOutEn=>ShiftRegOutEn,SROM_CS_N=>SROM_CS_N,SROM_SCK=>
		SROM_SCK,RomRd=>RomRd);
END BEHAVIOR;
