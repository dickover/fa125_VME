--  Author:  Hai Dong
--
-- This code read/write Atmel AT45DB642 Spi Flash
--  Wait for IDLE_REG = 1 before bring EXEC low to high.
--  On rising edge of EXEC, do OPCODE. and wait 50 nS before recognize another rising edge of EXEC
--
--  Bytes are shifted in / out MSB first.
--
--  It will take approximately 300 second to Erase (opcode 100) the entire chip.
--  Software should wait this long before issue another command.
--
--  OPCODE  :
--      000 :  Buffer Write : 0x84 to Buffer 1
--      001 :  Continuous Array Read Low Frequency Mode : 0xE8
--      010 :  Buffer Read :  0xD1  SCK max = 33MHz 
--      011 :  Buffer To Main Memory Page Program without Built-In Erase : 0x88
--      100 :  Chip Erase : 0xC7 0x94 0x80 0x9A.  
--
-- 
--  Buffer Write (000): 
--       1) PAGE_ADR should be 0  
--       2) 0x84, PAGE_ADR (13 don't care bits),  BYTE_ADR (11 buffer address bits), data byte 8bits, ...
--       3) DATA_TO_ROM are sent to Flash for NUM_BYTES time.
--          DATA_TO_ROM should change when ReadyForNewDataToRom_REG goes from low to high.
--       4) IDLE_REG goes low until all bytes are written
--
--  Continuous Array Read Low Frequency Mode (001):
--       1) 0xE8 PAGE_ADR  BYTE_ADR  4 don't care bytes.
--       2) Read NUM_BYTES number of Byte from FLASH to DATA_FROM_ROM_REG. On rising edge of DataFromRomValid_REG
--          indicates DATA_FROM_ROM_REG has the latest data
--       3) IDLE_REG goes low until all bytes are read
--
--  Buffer Read (010):
--       1) PAGE_ADR should be 0
--       2) 0xD1 PAGE_ADR  BYTE_ADR
--       3) Read NUM_BYTES number of Byte from FLASH to DATA_FROM_ROM_REG. On rising edge of DataFromRomValid_REG
--          indicates DATA_FROM_ROM_REG has the latest data
--       4) IDLE_REG goes low until all bytes are read
--
--  Buffer To Main Memory Page Program without Built-In Erase (011):  IC need to be erase first
--       1) BYTE_ADR should be zero
--       2) 0x88 PAGE_ADR  BYTE_ADR 
--       3) IDLE_REG goes low until Flash finish Program. It takes 6 mS to program a page.
--
-- Chip Erase (100): Obsolete See Below
--       1) 0xC7 0x94 0x80 0x9A
--       2) 3) IDLE_REG goes low until Flash finish erase.
--
--  6/18/2013
--     Replace Chip Erase (100) to Block Erase Command.  There are 1024 blocks.  Each Block takes 100 mS  to Erase.
--       1)ROM Opcode 0c50 follow by 10 pages address bits follow by 14 don't care bits.
--       2) Add BlockNumberToErase : in std_logic_vector(9 downto 0);  to specify which Block To Erase.
--
--  Page program timer increment every 262.144 uS. 
--  Each page takes 16 mS to program
--
--  Modification:
--     10/15/13:
--       Add the following to allow continuous generation of SROM_SCK.
--           RdyForCmd                : out std_logic; 
--           HOST_IDLE    : in std_logic;
--           CmdPending   : in std_logic;
--
--      The sequence of event is as follow:
--          1) Host brings CmdPending high and HOST_IDLE low.
--          2) Host wait for RdyForCmd to go high.  This indicate SROM_SCK just finish last clock.
--          3) Host issues  command by bringing EXEC high and low.
--          4) Host wait for IDLE_REG to go back high to indicate command has been exeuted/
--          5) Host repeat 3 and 4 if there is more commands
--          6) WHen all the commands are done, hosr bring HOST_IDLE back to high
--
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.std_logic_unsigned.all; 
  use IEEE.std_logic_arith.all;


entity AT45DB642_iface is
        generic
        (
                SimSpeedUp                  : integer := 0; --- to speed up simulation,  Should be 0 for normal run.
                I2C_CLK_HPERIOD             : integer := 5;  --- equal to CLK * 20 nS  (25 MHz Clock) Min is 3
                I2C_CLK_CNT_NumOfBits       : integer :=  3;   --- equal to > ln(I2C_CLK_PERIOD) / ln(2)
                BaseTime                    : integer  := 32750; -- 10480; -- 32750; --- equal CLK * 131 uS 
                BaseTimerNumberOfBits       : integer  := 15;   -- equal to > (ln(BaseTime) / ln(2)
                SROM_CS_N_HiTime            : integer  := 13 --4 --13    -- equal 50 ns * CLK
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
           BlockNumberToErase : in std_logic_vector(9 downto 0); -- specify which Block To Erase.
           ReadyForNewDataToRom_REG : out std_logic;  --- Falling Edge indicate DATA_TO_ROM can change.
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
end AT45DB642_iface;

architecture STRUCT of AT45DB642_iface is

    constant BufWrOpCode : std_logic_vector(7 downto 0) := x"84";
    constant ConArOpCode : std_logic_vector(7 downto 0) := x"E8";
    constant BufRdOpCode : std_logic_vector(7 downto 0) := x"D1"; --x"D1"; --x"D2";-- changed to read from main memory
    constant BufPrOpCode : std_logic_vector(7 downto 0) := x"88";
    constant BlkEraOpCode : std_logic_vector(7 downto 0) := x"50";
    constant LASTOPCODE      : std_logic_vector(2 downto 0) := "100";  --- See above
    

    signal ChEraCmdSequence_D : std_logic_vector(23 downto 0);
    signal ChEraCmdSequence_Q : std_logic_vector(23 downto 0);
    signal OPCODE_D      :  std_logic_vector(2 downto 0);  --- See above
    signal OPCODE_Q      :  std_logic_vector(2 downto 0);  --- See above
    signal EXEC_CMD_D    : std_logic;
    signal EXEC_CMD_Q    : std_logic;
    signal EXEC_CMD_DLY_Q : std_logic;
    signal InvalidOpcode_D : std_logic;
    signal InvalidOpcode_Q : std_logic;
    signal PEXEC_D     : std_logic;
    signal PEXEC_Q     : std_logic;
    signal EXEC_D        :  std_logic;  --- Rising Edge execute OPCODE
    signal EXEC_Q        :  std_logic;  --- Rising Edge execute OPCODE
    signal PAGE_ADR_D    :  std_logic_vector(12 downto 0); -- Flash Page Address
    signal PAGE_ADR_Q    :  std_logic_vector(12 downto 0); -- Flash Page Address
    signal BYTE_ADR_D    :  std_logic_vector(10 downto 0); -- Flash Byte Address
    signal BYTE_ADR_Q    :  std_logic_vector(10 downto 0); -- Flash Byte Address
    signal NUM_BYTES_D   :  std_logic_vector(10 downto 0); -- Number of Bytes to Read from or send to Flash
    signal NUM_BYTES_Q   :  std_logic_vector(10 downto 0); -- Number of Bytes to Read from or send to Flash
    
    --signal DATA_TO_ROM_D :  std_logic_vector(7 downto 0); -- Data to be written to FLASH
    --signal DATA_TO_ROM_Q :  std_logic_vector(7 downto 0); -- Data to be written to FLASH

    ---- MUX Byte to Flash
    signal FlashOpcode_D        : std_logic_vector(7 downto 0);
    signal FlashOpcode_Q        : std_logic_vector(7 downto 0);
    signal FlashByte2_3_4_D     : std_logic_vector(23 downto 0);
    signal FlashByte2_3_4_Q     : std_logic_vector(23 downto 0);
    signal BYTE_TO_FLASH_D : std_logic_vector(7 downto 0);
    signal BYTE_TO_FLASH_Q : std_logic_vector(7 downto 0);
    signal ByteToFlashSel : std_logic_vector(2 downto 0);
    --signal ByteToFlashSel_D : std_logic_vector(2 downto 0);
    --signal ByteToFlashSel_Q : std_logic_vector(2 downto 0);
    
    --- Out Shift Register
    signal LdShiftRegOut : std_logic;                           
    signal ShiftRegOutEn : std_logic;                                        
    signal ShiftRegOut_D : std_logic_vector(7 downto 0);                     
    signal ShiftRegOut_Q : std_logic_vector(7 downto 0);         
    signal ShiftOutCnt_D : std_logic_vector(3 downto 0);                     
    signal ShiftOutCnt_Q : std_logic_vector(3 downto 0);
    signal SftOutCntEn   : std_logic;
    signal ShiftOutDone  : std_logic;
    signal ClrSftCntOut : std_logic; 
    
    --- Keep track of data byte to ROM
    signal ClrByteToRomCnt   : std_logic;
    signal IncByteToRomCnt   : std_logic;
    signal DatByteToRomDon_D : std_logic;
    signal DatByteToRomDon_Q : std_logic;
    signal DatByteToRomCnt_D : std_logic_vector(10 downto 0);                   
    signal DatByteToRomCnt_Q : std_logic_vector(10 downto 0);
    signal RdyForNeDatToRom : std_logic;  --- Falling edge indicate DATA_TO_ROM can change                   
    
    --- Keep Track of SCK half period
    signal ClrSckHalfTiHi : std_logic;
    signal ClrSckHalfTiLo : std_logic;
    signal SckHalfTiHiTc_D : std_logic;
    signal SckHalfTiHiTc_Q : std_logic;
    signal SckHalfTiLoTc_D : std_logic;
    signal SckHalfTiLoTc_Q : std_logic;
    signal SckHalfTimerHi_D  : std_logic_vector(I2C_CLK_CNT_NumOfBits - 1 downto 0);
    signal SckHalfTimerHi_Q  : std_logic_vector(I2C_CLK_CNT_NumOfBits - 1 downto 0);
    signal SckHalfTimerLo_D  : std_logic_vector(I2C_CLK_CNT_NumOfBits - 1 downto 0);
    signal SckHalfTimerLo_Q  : std_logic_vector(I2C_CLK_CNT_NumOfBits - 1 downto 0);
    
    ---- IC pins
    signal SROM_SCK_D   :  std_logic;
    signal SROM_SCK_Q   :  std_logic;
    signal SROM_SCK_BUF_Q   :  std_logic;
    signal SROM_CS_N_D  :  std_logic;
    signal SROM_CS_N_Q  :  std_logic;
    signal SROM_CS_N_DLY_Q  :  std_logic_vector(1  downto 0);
    signal SROM_CS_N_BUF_Q  :  std_logic;
    signal SROM_SI_D    :  std_logic;
    signal SROM_SI_Q    :  std_logic;
    signal SROM_SI_DLY_Q : std_logic;
    signal SROM_SI_BUF_Q : std_logic;
    signal SROM_SO_BUF_Q    :   std_logic;
    
    --- Data From ROM
    signal ShiftInCnt_D :  std_logic_vector(3 downto 0); 
    signal ShiftInCnt_Q :  std_logic_vector(3 downto 0); 
    signal ClrSftCntIn  : std_logic;
    signal SftInCntEn   : std_logic;
    signal ShiftInDone  : std_logic;                                      
    signal DATA_FROM_ROM_D :  std_logic_vector(7 downto 0); --- Data read from ADDRESS
    signal DATA_FROM_ROM_Q :  std_logic_vector(7 downto 0); --- Data read from ADDRESS
    signal ShiftRegInEn        : std_logic;
    signal SHIFT_REGISTER_IN_D           :  std_logic_vector(7 downto 0);
    signal SHIFT_REGISTER_IN_Q           :  std_logic_vector(7 downto 0);
    signal DataFromRomValid_D  : std_logic;
    signal DataFromRomValid_Q  : std_logic;
    signal DataFromRomValidDly_Q  : std_logic;
    signal IncByteFrRomCnt : std_logic;
    signal DatByteFrRomDon : std_logic;
    signal ClrByteFrRomCnt : std_logic;
    signal DumByteDone_D : std_logic;
    signal DumByteDone_Q : std_logic;
    
    ---- Wait for ROm to finish program
    signal BaseTimerEn : std_logic;
    signal BaseTimer_D : std_logic_vector(BaseTimerNumberOfBits downto 0);
    signal BaseTimer_Q : std_logic_vector(BaseTimerNumberOfBits downto 0);
    signal PageProgTimerEn_D : std_logic;
    signal PageProgTimerEn_Q : std_logic;
    signal PageProgTimer_D : std_logic_vector(8 downto 0);
    signal PageProgTimer_Q : std_logic_vector(8 downto 0);
    signal PageProgDone : std_logic;
    
    signal SROM_CS_N_HiTime_TC_D : std_logic;
    signal SROM_CS_N_HiTime_TC_Q : std_logic;

    component AT35DBSM
        PORT (ByteToFlashSel : OUT std_logic_vector (2 DOWNTO 0);
                CLK,DatByteToRomDon,EXEC,OPCODE_0,OPCODE_1,OPCODE_2,PageProgDone,RESET_N,SromCsNHiTiTc,
                ShiftInDone, DatByteFrRomDon, DumByteDone,  CmdPending, HOST_IDLE,            
                SckHalfTiHiTc,SckHalfTiLoTc,ShiftOutDone: IN std_logic;
                BaseTimerEn,ClrByteToRomCnt,ClrSckHalfTiHi,ClrSckHalfTiLo,IDLE, ClrSftCntOut, IncByteToRomCnt, 
                SftInCntEn, DatFrRomValid, IncByteFrRomCnt,ShiftRegInEn,ClrSftCntIn, ClrByteFrRomCnt,
                LdShiftRegOut,RdyForNeDatToRom,SftOutCntEn,ShiftRegOutEn,SROM_CS_N,SROM_SCK, RdyForCmd :
                         OUT std_logic);
    end component;

begin

   --ChEraCmdSequence_D <=  BlockNumberToErase & conv_std_logic_vector(0,14) when  PEXEC_Q = '1' else ChEraCmdSequence_Q;
	ChEraCmdSequence_D <=  '0' & BlockNumberToErase & conv_std_logic_vector(0,13) when  PEXEC_Q = '1' else ChEraCmdSequence_Q; -- hack for 321D
   --- Latch in parameters
    OPCODE_D      <=   OPCODE when PEXEC_D = '1' else OPCODE_Q;
    InvalidOpcode_D <= '1' when OPCODE_Q > LASTOPCODE else '0';
    EXEC_CMD_D  <= not InvalidOpcode_Q and PEXEC_Q;
    PEXEC_D         <=   EXEC_D and not EXEC_Q;
    EXEC_D        <=   EXEC;      
    PAGE_ADR_D    <=   PAGE_ADR when PEXEC_Q = '1' else PAGE_ADR_Q;  
    BYTE_ADR_D    <=   BYTE_ADR when PEXEC_Q = '1' else BYTE_ADR_Q;  
    NUM_BYTES_D   <=   NUM_BYTES when PEXEC_Q = '1' else NUM_BYTES_Q; 
    --DATA_TO_ROM_D <=   DATA_TO_ROM;

    ---- MUX Byte to Flash
    FlashOpcode_D   <= BufWrOpCode when OPCODE_Q = "000" else 
                       ConArOpCode when OPCODE_Q = "001" else
                       BufRdOpCode when OPCODE_Q = "010" else
                       BufPrOpCode when OPCODE_Q = "011" else                                                 
                       BlkEraOpCode;                                                                     
    FlashByte2_3_4_D <= ChEraCmdSequence_Q when OPCODE_Q = "100" else
                        PAGE_ADR_Q & BYTE_ADR_Q; 
        
    BYTE_TO_FLASH_D <= FlashOpcode_Q                  when ByteToFlashSel = "000" else 
                       FlashByte2_3_4_Q(23 downto 16) when ByteToFlashSel = "001" else
                       FlashByte2_3_4_Q(15 downto 8)  when ByteToFlashSel = "010" else
                       FlashByte2_3_4_Q(7 downto 0)   when ByteToFlashSel = "011" else
                       DATA_TO_ROM                    when ByteToFlashSel = "100" else
                       ChEraCmdSequence_Q(23 downto 16) when ByteToFlashSel = "101" else
                       ChEraCmdSequence_Q(15 downto 8)  when ByteToFlashSel = "110" else
                       ChEraCmdSequence_Q(7 downto 0);

    --- Keep Track of SCK half period
    SckHalfTiHiTc_D   <= '1' when SckHalfTimerHi_Q = conv_std_logic_vector(I2C_CLK_HPERIOD, I2C_CLK_CNT_NumOfBits) else '0';
    SckHalfTimerHi_D  <= (others => '0') when ClrSckHalfTiHi = '1' else SckHalfTimerHi_Q + 1;
    SckHalfTiLoTc_D   <= '1' when SckHalfTimerLo_Q = conv_std_logic_vector(I2C_CLK_HPERIOD, I2C_CLK_CNT_NumOfBits) else '0';
    SckHalfTimerLo_D  <= (others => '0') when ClrSckHalfTiLo = '1' else SckHalfTimerLo_Q + 1;
                       
    ---- Keep track of the number of bits shift out
    ShiftOutCnt_D <= x"7" when ClrSftCntOut = '1' else
                     ShiftOutCnt_Q - 1 when SftOutCntEn = '1' else
                     ShiftOutCnt_Q;
    ShiftOutDone <= ShiftOutCnt_Q(3);                                        

                  
  
   --- Shift bit out MSB first
   SROM_SI_D <=  ShiftRegOut_Q(7);
  SHIFTOUT_REG : process (ShiftRegOut_Q, LdShiftRegOut, ShiftRegOutEn, BYTE_TO_FLASH_Q )
   variable INDEX : integer;
   begin
     ShiftRegOut_D <= ShiftRegOut_Q;
     if LdShiftRegOut = '1' then
       ShiftRegOut_D <= BYTE_TO_FLASH_Q;
      elsif  ShiftRegOutEn = '1'  then
       for INDEX in 7 downto 1 loop -- left shift --7 change
         ShiftRegOut_D(INDEX) <= ShiftRegOut_Q(INDEX-1);
       end loop;
         ShiftRegOut_D(0) <= '0';
     else
       ShiftRegOut_D <= ShiftRegOut_Q;
     end if;
   end process;

    ---- Wait for ROm to finish program one sector
    BaseTimer_D <= BaseTimer_Q + 1 when BaseTimerEn = '1' else (others => '0');
    PageProgTimerEn_D <= BaseTimer_D(BaseTimerNumberOfBits) and not  BaseTimer_Q(BaseTimerNumberOfBits);
    PageProgTimer_D <= (others => '0') when BaseTimerEn = '0' else 
                        PageProgTimer_Q + 1 when PageProgTimerEn_Q = '1' else
                        PageProgTimer_Q;
   PageProgDone <= PageProgTimer_Q(6) when SimSpeedUp = 0 else '1';
   
   ---- Minimum ROM_CS_N hi time (time between command)
   SROM_CS_N_HiTime_TC_D <= '1' when BaseTimer_Q = conv_std_logic_vector(SROM_CS_N_HiTime, BaseTimerNumberOfBits) else '0';
 
   ------ *****************************
    --- Keep track of data byte from/to ROM
    DatByteFrRomDon   <= DatByteToRomDon_Q;
    DatByteToRomDon_D <= '1' when DatByteToRomCnt_Q = NUM_BYTES_Q else '0';
    DumByteDone_D     <= '1' when DatByteToRomCnt_Q(2 downto 0) = "100" else '0';
    DatByteToRomCnt_D <= (others => '0')        when ClrByteToRomCnt = '1' or ClrByteFrRomCnt = '1' else
                         DatByteToRomCnt_Q  + 1 when IncByteToRomCnt = '1' or IncByteFrRomCnt = '1' else
                         DatByteToRomCnt_Q;                   

  ---- **********************************************************************
  ---- Data from ROM  -------------------------------------------------------
    ---- Keep track of the number of bits shift out
    ShiftInCnt_D <= x"7" when ClrSftCntIn = '1' else --x"7" change
                     ShiftInCnt_Q - 1 when SftInCntEn = '1' else
                     ShiftInCnt_Q;
    ShiftInDone <= ShiftInCnt_Q(3);                                        
    --ShiftInDone <= '1' when ShiftInCnt_Q = "0000" else '0'; --change

  DATA_FROM_ROM_REG <= DATA_FROM_ROM_Q;
  DATA_FROM_ROM_D <= SHIFT_REGISTER_IN_Q when DataFromRomValid_Q = '1' else DATA_FROM_ROM_Q;
  
  --- Shift bits in MSB first
  SHIFTIN_REG : process (SHIFT_REGISTER_IN_Q, ShiftRegInEn, SROM_SO_BUF_Q)
   variable INDEX : integer;
   begin
     if  ShiftRegInEn = '1'  then
       for INDEX in 7 downto 1 loop -- left shift --7 change
         SHIFT_REGISTER_IN_D(INDEX) <= SHIFT_REGISTER_IN_Q(INDEX-1);
       end loop;
         SHIFT_REGISTER_IN_D(0) <= SROM_SO_BUF_Q;
     else
       SHIFT_REGISTER_IN_D <= SHIFT_REGISTER_IN_Q;
     end if;
   end  process;

  ---- SM  -------------------------------------------------------
    UAT35DBSM : AT35DBSM
       port map
           (
             CLK   => CLK,
             RESET_N => RESET_N,
             ByteToFlashSel => ByteToFlashSel,
             DatByteToRomDon => DatByteToRomDon_Q,
             EXEC => EXEC_CMD_DLY_Q,
             OPCODE_0 => OPCODE_Q(0),
             OPCODE_1 => OPCODE_Q(1),
             OPCODE_2 => OPCODE_Q(2),
             PageProgDone => PageProgDone,
             SckHalfTiHiTc => SckHalfTiHiTc_Q,
             SckHalfTiLoTc => SckHalfTiLoTc_Q,
             ShiftOutDone => ShiftOutDone,
             SromCsNHiTiTc => SROM_CS_N_HiTime_TC_Q,
             ShiftInDone  => ShiftInDone,
             DatByteFrRomDon => DatByteFrRomDon,
             DumByteDone => DumByteDone_Q,
             CmdPending  => CmdPending,
             HOST_IDLE   => HOST_IDLE,
             
             BaseTimerEn => BaseTimerEn,
             ClrByteToRomCnt => ClrByteToRomCnt,
             ClrSckHalfTiHi => ClrSckHalfTiHi,
             ClrSckHalfTiLo => ClrSckHalfTiLo,
             IDLE => IDLE_REG,
             LdShiftRegOut => LdShiftRegOut,
             RdyForNeDatToRom => RdyForNeDatToRom,
             SftOutCntEn => SftOutCntEn,
             ShiftRegOutEn => ShiftRegOutEn,
             SROM_CS_N => SROM_CS_N_D,
             ClrSftCntOut => ClrSftCntOut,
             IncByteToRomCnt => IncByteToRomCnt,
             SftInCntEn  => SftInCntEn,
             DatFrRomValid => DataFromRomValid_D,
             IncByteFrRomCnt => IncByteFrRomCnt,
             ShiftRegInEn => ShiftRegInEn,
             ClrSftCntIn => ClrSftCntIn,
             ClrByteFrRomCnt => ClrByteFrRomCnt,
             RdyForCmd   => RdyForCmd,
             SROM_SCK => SROM_SCK_D
            );


    process (CLK, RESET_N)
      begin
        if RESET_N = '0' then
            EXEC_Q        <=   '0';
            PEXEC_Q <= '0';      
            SROM_SCK_Q   <=  '1';
            SROM_SCK_BUF_Q <=  '1';
            SROM_CS_N_Q  <=  '1';
            SROM_CS_N_DLY_Q <= (others => '1');
            SROM_CS_N_BUF_Q <= '1';
            SROM_SI_Q    <=  '1';
           SROM_SCK   <=  '1';   
           SROM_CS_N  <=  '1';
           SROM_SI    <=  '1';
           EXEC_CMD_Q <= '0';
           EXEC_CMD_DLY_Q <= '0';
           InvalidOpcode_Q <= '1';
           ReadyForNewDataToRom_REG <= '1';
          --ShiftRegOut_Q   <= (others => '0');
        elsif rising_edge(CLK) then
            EXEC_Q        <=   EXEC_D;
            PEXEC_Q <= PEXEC_D;      
            SROM_SCK_Q   <=  SROM_SCK_D ;
            SROM_SCK_BUF_Q <= SROM_SCK_Q;
           SROM_SCK   <=  SROM_SCK_BUF_Q;
            SROM_CS_N_Q  <=  SROM_CS_N_D;
            SROM_CS_N_DLY_Q(0) <=  SROM_CS_N_Q;
            SROM_CS_N_DLY_Q(1) <= SROM_CS_N_DLY_Q(0);
            SROM_CS_N_BUF_Q <= SROM_CS_N_DLY_Q(1);            
           SROM_CS_N  <=  SROM_CS_N_BUF_Q;
            SROM_SI_Q    <=  SROM_SI_D  ;
            SROM_SI_DLY_Q <= SROM_SI_Q;
            SROM_SI_BUF_Q <=  SROM_SI_DLY_Q;
           SROM_SI    <=  SROM_SI_BUF_Q;
          --ShiftRegOut_Q   <= ShiftRegOut_D;
          EXEC_CMD_Q <= EXEC_CMD_D;
          EXEC_CMD_DLY_Q <= EXEC_CMD_Q;
          InvalidOpcode_Q <= InvalidOpcode_D;
          ReadyForNewDataToRom_REG <= RdyForNeDatToRom;
        end if;
      end process;

    process (CLK)
      begin
        if rising_edge(CLK) then
          OPCODE_Q      <=   OPCODE_D;    
          PAGE_ADR_Q    <=   PAGE_ADR_D;  
          BYTE_ADR_Q    <=   BYTE_ADR_D;  
          NUM_BYTES_Q   <=   NUM_BYTES_D; 
          --DATA_TO_ROM_Q <=   DATA_TO_ROM_D;
          BYTE_TO_FLASH_Q <=  BYTE_TO_FLASH_D;
          FlashOpcode_Q  <= FlashOpcode_D;
          FlashByte2_3_4_Q <= FlashByte2_3_4_D;
          --ByteToFlashSel_Q <= ByteToFlashSel_D;     
          --SROM_SO_BUF_Q   <=   SROM_SO;
          SckHalfTimerHi_Q <= SckHalfTimerHi_D;
          SckHalfTiHiTc_Q <= SckHalfTiHiTc_D; 
          SckHalfTimerLo_Q <= SckHalfTimerLo_D;
          SckHalfTiLoTc_Q <= SckHalfTiLoTc_D; 
          SHIFT_REGISTER_IN_Q <= SHIFT_REGISTER_IN_D;
          DATA_FROM_ROM_Q <=  DATA_FROM_ROM_D;
          ShiftOutCnt_Q <= ShiftOutCnt_D;
          DatByteToRomCnt_Q <= DatByteToRomCnt_D;
          DatByteToRomDon_Q <= DatByteToRomDon_D;
          BaseTimer_Q       <= BaseTimer_D;
          PageProgTimerEn_Q  <= PageProgTimerEn_D;
          PageProgTimer_Q    <= PageProgTimer_D;
          ShiftRegOut_Q   <= ShiftRegOut_D;
          SROM_CS_N_HiTime_TC_Q <= SROM_CS_N_HiTime_TC_D;
          ShiftInCnt_Q   <= ShiftInCnt_D;
          DataFromRomValid_Q <= DataFromRomValid_D;
          DataFromRomValidDly_Q <= DataFromRomValid_Q;
          DataFromRomValid_REG <= DataFromRomValidDly_Q;
          DumByteDone_Q  <= DumByteDone_D;
          ChEraCmdSequence_Q <= ChEraCmdSequence_D;
        end if;
      end process;

    process (SROM_SCK_BUF_Q)
      begin
        if rising_edge(SROM_SCK_BUF_Q) then
			SROM_SO_BUF_Q   <=   SROM_SO;
        end if;
      end process;



end STRUCT;
