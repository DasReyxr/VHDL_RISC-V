----------- Code -----------
--------- Auf Das ---------
------ RISCV ------
-------- 03/01/2025 --------
------- Main Library -------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.NUMERIC_STD.ALL;

--------- Pin/out ---------
entity RISCV is
	port
		(
        ---- PC ---
        CLRS, CLKS : in std_logic;
        -- WRAM --
        P0IN, ROMIN: in std_logic_vector (7 downto 0);
        RAMIN : inout std_logic_vector (7 downto 0);
        WR : out std_logic;
        P1OUT: out std_logic_vector (7 downto 0)
        );
end RISCV;


architecture juve3dstudio of RISCV is
    -- Signed --
    
    
    -- Program Counter --
    signal PC, SP, XP : std_logic_vector (7 downto 0) := "00000000";
    signal PC, SP, XP, SELR8 : std_logic_vector (7 downto 0) := "00000000";
    -- FF Decoder --
    signal SBO, SBI : std_logic_vector(1 downto 0) := "00";
    -- BUSES DE SLECTOR DE DATOS Y CSC --
    signal CSC, P1, ALU, XIN, SPIN, DATA, PCIN, ADDRESS : std_logic_vector (7 downto 0) := "00000000";
     -- MUX RAM --
    signal SELR : std_logic_vector (3 downto 0) := (others => '0') ;
    signal SELL : std_logic_vector (2 downto 0) := (others => '0');
    signal RW : std_logic;
    --MUX DATA--
    signal SELD : std_logic_vector (2 downto 0) := (others => '0');
    -- Flags --
    signal FLAGIN, FLAGOUT : std_logic_vector (3 downto 0) := (others => '0');
    -- ALU --
    signal ACM : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal AC, REG : signed(8 downto 0) := (others => '0');
    
    signal INA : std_logic_vector( 8 downto 0)  := (others => '0');
    signal CARRY, NEG, OVF, ZERO: std_logic;

    -- Instruction Decoder  --
    signal S_WR, XD, XU, SPD, SPU, CKP, CKA, PCL: std_logic;
    signal IBI  : std_logic_vector(1 downto 0) := (others => '0');
    signal SCL,IBO  : std_logic_vector (1 downto 0) := (others => '0');
    signal SCR, SCD : std_logic_vector (2 downto 0) := (others => '0');
    

begin
    P1OUT <= P1 when CLKS'event and CLKS = '1';
    P1 <= DATA when CLRS = '1' and CSC(2) = '1'; --CSC(2) = CKP

    PCL <= CSC(0); 
    PC <= 
            PC + '1'   when PCL = '0' and CLRS = '1' and CLKS'event and CLKS = '1'  else
            DATA + 2   when PCL = '1' and CLRS = '1' and CLKS'event and CLKS = '1'  else 
            PC;

    PCIN  <= PC;
    -- FF Decoder --
    SBI <=
        SBO  when CLKS'event and CLKS ='1' and CLRS = '1' else
        "00" when CLKS'event and CLKS ='1'; 

    -- Stack Pointer --
    SP <=    
        SP         when CLKS'event and CLKS = '1' and SPU = '0' and SPD = '0' else
        SP + '1'   when CLKS'event and CLKS = '1' and SPU = '0' and SPD = '1' else
        SP - '1'   when CLKS'event and CLKS = '1' and SPU = '1' and SPD = '0' else
        "11111111" when CLKS'event and CLKS = '1' and SPU = '1' and SPD = '1';

    -- X Pointer --
    XP <=    
        XP         when CLKS'event and CLKS = '1' and XU = '0' and XD = '0' else
        XP + '1'   when CLKS'event and CLKS = '1' and XU = '0' and XD = '1' else
        XP - '1'   when CLKS'event and CLKS = '1' and XU = '1' and XD = '0' else
        DATA       when CLKS'event and CLKS = '1' and XU = '1' and XD = '1';

    -- MUX RAM --
    with SELL select 
    ADDRESS <= 
        SELR8 when "00",
        SELR8 when "01",
        XIN   when "10",
        SPIN  when "11";

    -- Decode 3to8 --
    with SELR select
    SELR8 <= 
            "00000001" when "000",  
            "00000010" when "001",  
            "00000100" when "010",  
            "00001000" when "011",  
            "00010000" when "100",  
            "00100000" when "101",  
            "01000000" when "110",  
            "10000000" when "111",  
            "00000000" when others;    
    -- RAM --
    S_WR <= CSC(7); 
    RAMIN <= "ZZZZZZZZ" when S_WR = '0' else DATA;
    RW <= S_WR and (not CLKS);

    -- Flag Register --
    FLAGOUT <= FLAGIN when CLKS'event and CLKS = '1';
    FLAGIN <= "0000" when CLRS = '1' else 
              ZERO & CARRY & NEG & OVF;
    
    -- ALU --
    CKA <= CSC(1);

    ACM <= DATA when CLKS'event and CLKS = '1' and CLRS = '1' and CKA = '0' else
          "00000000" when CLKS'event and CLKS = '1';
    
    AC  <=signed('0'&ACM); 

    REG <=signed('0'&RAMIN);
 
    -- HACER LOGICA DE BANDERAS DE ENTRADA --
    ZERO <='0' when ROMIN ="01001100" else '1' when INA = "000000000" else '1' when ROMIN ="01001011" else  '0';
    CARRY<='1' when ROMIN ="01000111" else '0' when ROMIN ="01001000" else INA(8);
    NEG  <='1' when ROMIN ="01001001" else '0' when ROMIN ="01001100" else INA(7);
    OVF  <='1' when ROMIN ="01001101" else '0' when ROMIN ="01001110" else CARRY xor NEG;

--    INA <= std_logic_vector(signed(AC) + signed(REG) + to_signed(to_integer(unsigned(FLAGIN(2))), 9)) when "00000000",

    with ROMIN select
    INA<= 
        AC + REG  + FLAGIN(2) when "00000000",
        AC + REG  + FLAGIN(2) when "00000001",
        AC + REG  + FLAGIN(2) when "00000010",
        AC + REG  + FLAGIN(2) when "00000011",
        AC + REG  + FLAGIN(2) when "00000100",
        AC + REG  + FLAGIN(2) when "00000101",
        AC + REG  + FLAGIN(2) when "00000110",
        AC + REG  + FLAGIN(2) when "00000111",

        AC - REG  - FLAGIN(2) when "00001000",
        AC - REG  - FLAGIN(2) when "00001001",
        AC - REG  - FLAGIN(2) when "00001010",
        AC - REG  - FLAGIN(2) when "00001011",
        AC - REG  - FLAGIN(2) when "00001100",
        AC - REG  - FLAGIN(2) when "00001101",
        AC - REG  - FLAGIN(2) when "00001110",
        AC - REG  - FLAGIN(2) when "00001111",
        
        not(std_logic_vector(AC)) + 1    when "01000000",
        not std_logic_vector(AC)         when "01000001",
        AC+1           when "01000010",
        AC-1           when "01000011",
        AC AND "000000000" when "01000100",
        AC              when "00010000",
        AC and REG         when "00011000",
        AC or REG          when "00100000",
        AC xor REG         when "00101000",
        AC + AC + FLAGIN(2) when "01000101",
        AC(0)& FLAGIN(2) &AC(7 downto 1) when "01000110",
        "000000000"     when others;

    -- INA<= 
    --     AC + REG  + FLAGIN(2) when ROMIN < "00000111" else
    --     AC - REG  - FLAGIN(2) when ROMIN >= "00000111"and ROMIN <="00001111"
    --     not(AC) + 1    when ROMIN = "01000000" else
    --     not AC         when ROMIN = "01000001" else
    --     AC+1           when ROMIN = "01000010" else
    --     AC-1           when ROMIN = "01000011" else
    --     AC AND "000000000" when ROMIN = "01000100" else
    --     AC              when ROMIN = "00010000" else
    --     AC and REG         when ROMIN = "00011000" else
    --     AC or REG          when ROMIN = "00100000" else
    --     AC xor REG         when ROMIN = "00101000" else
    --     AC + AC + FLAGIN(2) when ROMIN = "01000101" else
    --     AC(0)& FLAGIN(2) &AC(7 downto 1) when ROMIN = "01000110" else
    --     ((others => '0') );
        

    --OPERACIONES ARITMETICAS LOGICAS
    with ROMIN  select
    ALU <= INA when "00000000",
        INA when "00001000",
        INA when "01000000",
        INA when "01000001", 
        INA when "01000010", 
        INA when "01000011", 
        INA when "01000100",
        AC - REG  - FLAGIN(2) when "00010000", 
        INA when "00011000",
        INA when "00100000",
        INA when "00101000",
        INA when "01000101",
        INA when "01000110",
        "000000000" when others;



--MUX DATOS
    with SELD select
    SELD     <=ALU   when "000",
              ROMIN when "001",
              PCIN  when "010",
              RAMIN when "011",
              XIN   when "100",
              SPIN  when "101",
              P0IN  when "110",
              INA   when "111";


    -- Decoder --
    CSC <=  
        "00000010" when (IBI="00" and (ROMIN<"00010000" or (ROMIN>"00010111" and ROMIN<"00111000") or (ROMIN>"00111111" and ROMIN<"01000111") or ROMIN="01010001" or ROMIN="01010011")) or (ROMIN="01010111" and IBI="10") else
        "00000001" when IBI="01" or (ROMIN="01011101" and IBI="00" and FLAGIN(3)='1') or (ROMIN="01011110" and IBI="00" and FLAGIN(2)='1') or (ROMIN="01011111" and IBI="00" and FLAGIN(1)='1') or (ROMIN="01100000" and IBI="00" and FLAGIN(0)='1') or (ROMIN="01010111" and IBI="00") or (ROMIN="01011010" and IBI="10") else 
        "00000100" when IBI="00" and ROMIN="01010000" else 
        "10000000" when IBI="00" and ((ROMIN>"00110111" and ROMIN<"01000000") or ROMIN="01010100"  or ROMIN="01011011") else
        "01100000" when IBI="00" and ROMIN="01010010" else
        "10010000" when IBI="00" and (ROMIN="01010110") else
        "01000000" when IBI="00" and ROMIN="01011001" else 
        "00011000" when IBI="00" and ROMIN="01100001" else
        "00001001" when IBI="10" and ROMIN="01011011" else
        "00010001" when IBI="00" and ROMIN="01011100" else
        "00100000" when IBI="00" and ROMIN="01011000" else                    
        "00000010" when IBI="00" and ROMIN="01010101" else
        "00000000";

    SCL <= 
        "11" when IBI="00" and ((ROMIN>"01010100" and ROMIN<"01010111") or (ROMIN>"01011010" and ROMIN<"01011101") or ROMIN="01011011") else
        "10" when IBI="00" and (ROMIN>"01010010" and ROMIN<"01010101") else
        "00";            

    SCD <= 
        "111" when IBI="00" and ((ROMIN>"00110111" and ROMIN<"01000000") or ROMIN="01010000" or ROMIN="01010010" or ROMIN="01010100" or ROMIN="01010110") else
        "110" when IBI="00" and ROMIN="01001111" else
        "100" when IBI="00" and ROMIN="01010001" else
        "011" when IBI="00" and ((ROMIN>"00101111" and ROMIN<"00111000") or ROMIN="01010011" or ROMIN="01010101" or ROMIN="01011100") else
        "010" when IBI="00" and ROMIN="01011011" else
        "001" when IBI="01" or IBI="10" else
        "000";

    IBO <= 
        "01" when IBI="00" and ((ROMIN="01011101" and FLAGIN(3)='1') or (ROMIN="01011110" and FLAGIN(2)='1') or (ROMIN="01011111" and FLAGIN(1)='1') or (ROMIN="01100000" and FLAGIN(0)='1')) else
        "10" when IBI="00" and (ROMIN="01010111" or ROMIN="01011010" or ROMIN="01011011") else
        "00";

    SCR <= ROMIN(2 downto 0) when (ROMIN(7 downto 3) < "01000");
    

end juve3dstudio;