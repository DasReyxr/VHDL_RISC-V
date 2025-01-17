----------- Code -----------
--------- Auf Das ---------
------ RISCV ------

-------- 03/01/2025 --------
------- Main Library -------
library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.NUMERIC_STD.ALL;

--------- Pin/out ---------
entity RISCV is
	port
		(
        ---- Main Clock ---
        CLRS, CLKS : in std_logic;
        -- Rom & Ram --
        ROMIN: in std_logic_vector (7 downto 0);
        RAMIN : inout std_logic_vector (7 downto 0);
        -- Address --
        PCIN,ADDRESSRAM: out std_logic_vector (7 downto 0);
        WR : out std_logic;
        -- Ports --
        P0IN : in  std_logic_vector (7 downto 0);
        P1OUT: out std_logic_vector (7 downto 0)
        );
end RISCV;


architecture juve3dstudio of RISCV is
    -- Program Counter --
    signal S_PCIN, SELR8 : unsigned (7 downto 0) := "00000000";
    
    
    -- BUSES DE SLECTOR DE DATOS Y CSC --
    signal CSC, P1 : std_logic_vector(7 downto 0);
    signal XIN, DATA  : unsigned (7 downto 0) := (others => '0'); 
    signal SPIN: unsigned (7 downto 0) := x"FF";

    -- MUX RAM --
    signal SELR : std_logic_vector (7 downto 0) := (others => '0') ;
    signal SELL : std_logic_vector (1 downto 0) := (others => '0');
    signal RW : std_logic;
    --MUX DATA--
    signal SELD : std_logic_vector (2 downto 0) := (others => '0');
    -- Flags --
    signal FLAGIN, FLAGOUT : std_logic_vector (3 downto 0) := (others => '0');
    -- ALU --
    signal ALU : signed (7 downto 0) := (others => '0');
    signal AC, REG : signed(8 downto 0) := (others => '0');
    signal INA,CPC : signed( 8 downto 0)  := (others => '0');
    
    signal ACM : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal CARRY, NEG, OVF, ZERO: std_logic;
    

    -- Instruction Decoder  --
    signal S_WR, XD, XU, SPD, SPU, CKP, CKA, PCL: std_logic;
    signal IBI  : std_logic_vector(1 downto 0) := (others => '0');
    signal SCL,IBO  : std_logic_vector (1 downto 0) := (others => '0');
    signal SCR, SCD : std_logic_vector (2 downto 0) := (others => '0');
    
    signal SPDU, XDU : std_logic_vector (1 downto 0) ;
begin
    P1OUT <= P1 when CLKS'event and CLKS = '1';
    P1 <= std_logic_vector(DATA) when CLRS = '1' and CSC(2) = '1' else "ZZZZZZZZ"; --CSC(2) = CKP

    
    S_PCIN <= 
            S_PCIN + 1   when PCL = '0' and CLRS = '1' and CLKS'event and CLKS = '1'    else
            DATA + 2   when PCL = '1' and CLRS = '1' and CLKS'event and CLKS = '1'  else 
            S_PCIN;

    PCIN  <= std_logic_vector(S_PCIN);


    -- Stack Pointer --
    SPIN <=    
        SPIN         when CLKS'event and CLKS = '1' and SPU = '0' and SPD = '0' else
        SPIN + 1  when CLKS'event and CLKS = '1' and SPU = '0' and SPD = '1' else
        SPIN - 1   when CLKS'event and CLKS = '1' and SPU = '1' and SPD = '0' else
        "11111111" when CLKS'event and CLKS = '1' and SPU = '1' and SPD = '1';

    -- X Pointer --
    XIN <=    
        XIN         when CLKS'event and CLKS = '1' and XU = '0' and XD = '0' else
        XIN + 1   when CLKS'event and CLKS = '1' and XU = '0' and XD = '1' else
        XIN - 1   when CLKS'event and CLKS = '1' and XU = '1' and XD = '0' else
        DATA       when CLKS'event and CLKS = '1' and XU = '1' and XD = '1';

    -- MUX RAM --
    with SELL select
    ADDRESSRAM <= 
        std_logic_vector(SELR8) when "00",
        std_logic_vector(SELR8) when "01",
        std_logic_vector(XIN)   when "10",
        std_logic_vector(SPIN)  when "11",
        x"00" when others;

    -- Decode 3to8 --
    SELR8 <= unsigned(SELR);
    -- RAM --
    WR<=S_WR; 
    RAMIN <= "ZZZZZZZZ" when S_WR = '0' else std_logic_vector(DATA);
    RW <= S_WR and (not CLKS);

    -- Flag Register --
    FLAGOUT <= FLAGIN when CLKS'event and CLKS = '1';
    FLAGIN <= "0000" when CLRS = '1' else 
              ZERO & CARRY & NEG & OVF;
    
    -- ALU --

    ACM <= std_logic_vector(DATA) when CLKS'event and CLKS = '1' and CLRS = '1' and CKA = '0' else
          "00000000" when CLKS'event and CLKS = '1';
    
    AC  <=signed('0'&ACM); 
    REG <=signed('0'&RAMIN);
 
    ZERO <='0' when ROMIN ="01001100" else '1' when INA = "000000000" else '1' when ROMIN ="01001011" else  '0';
    CARRY<='1' when ROMIN ="01000111" else '0' when ROMIN ="01001000" else INA(8);
    NEG  <='1' when ROMIN ="01001001" else '0' when ROMIN ="01001100" else INA(7);
    OVF  <='1' when ROMIN ="01001101" else '0' when ROMIN ="01001110" else CARRY xor NEG;


    with ROMIN select
    INA<= 
        AC + REG  + FLAGOUT(2) when "00000000" to "00000111",    
        AC - REG  - FLAGOUT(2) when "00001000" to "00001111",
        not(AC) + 1    when "01000000",
        not AC         when "01000001",
        AC+1           when "01000010",
        AC-1           when "01000011",
        AC AND "000000000" when "01000100",
        AC              when "00010000",
        AC and REG         when "00011000",
        AC or REG          when "00100000",
        AC xor REG         when "00101000",
        AC + AC + FLAGOUT(2) when "01000101",
        AC(0)& FLAGOUT(2) &AC(7 downto 1) when "01000110",
        "000000000"     when others;
        

    ALU <= CPC(7 downto 0) when ROMIN = "00010000" else INA(7 downto 0);
    CPC <= AC - REG  - FLAGOUT(2);


--MUX DATOS
    with SELD select
    DATA     <=
              unsigned(ALU)   when "000",
              unsigned(ROMIN) when "001",
              unsigned(S_PCIN)  when "010",
              unsigned(RAMIN) when "011",
              unsigned(XIN)   when "100",
              unsigned(SPIN)  when "101",
              unsigned(P0IN)  when "110",
              unsigned(INA(7 downto 0))   when "111",
              x"00" when others;



    -- Decoder --
    PCL <= '1'  when IBI="01" or (ROMIN="01011101" and IBI="00" and FLAGIN(3)='1') or (ROMIN="01011110" and IBI="00" and FLAGIN(2)='1') or (ROMIN="01011111" and IBI="00" and FLAGIN(1)='1') or (ROMIN="01100000" and IBI="00" and FLAGIN(0)='1') or (ROMIN="01011010" and IBI="10")
                or (IBI="10" and ROMIN="01011011") or (IBI="00" and ROMIN="01011100") else '0';

    CKA <= '1' when (IBI="00" and (ROMIN<"00010000" or (ROMIN>"00010111" and ROMIN<"00111000") or (ROMIN>"00111111" and ROMIN<"01000111") or ROMIN="01010001" or ROMIN="01010011")) or (ROMIN="01010111" and IBI="10") 
                else '0';
    CKP <= '1' when (IBI="00" and ROMIN="01010000") or (IBI="00" and ROMIN="01100001") or (IBI="10" and ROMIN="01011011")
                else '0';
    SPDU <= "01" when (IBI="10" and ROMIN="01011011") else
            "10" when (IBI="00" and ROMIN="01010110") or (IBI="00" and ROMIN="01011100") else
            "11" when (IBI="00" and ROMIN="01100001") 
            else "00";

    XDU <=  "01" when IBI="00" and ROMIN="01011000" else
            "10" when IBI="00" and ROMIN="01011001" else
            "11" when IBI="00" and ROMIN="01010010" else
            "00";
    S_WR <= '1' when (IBI="00" and ((ROMIN>"00110111" and ROMIN<"01000000") or ROMIN="01010100"  or ROMIN="01011011")) 
                or (IBI="00" and (ROMIN="01010110"))
                else '0';

    
    SELR <= "00000" & ROMIN(2 downto 0) when (ROMIN(7 downto 3) < "01000") else "00000000";

    SELL <= 
        "11" when IBI="00" and ((ROMIN>"01010100" and ROMIN<"01010111") or (ROMIN>"01011010" and ROMIN<"01011101") or ROMIN="01011011") else
        "10" when IBI="00" and (ROMIN>"01010010" and ROMIN<"01010101") else
        "00";            

    SELD <= 
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
    -- FF Decoder --
    IBI <=
        IBO  when CLKS'event and CLKS ='1' and CLRS = '1' else
        "00" when CLKS'event and CLKS ='1'; 


end juve3dstudio;
/*
    -- WR Escribir Ram
    
    -- XD  XU  Puntero X
    -- SPD SPU Stack Pointer
    --  0   0  sin cambio
    --  0   1  decremento
    --  1   0  incremento (pre)
    --  1   1  carga

    -- CKP Mandar puerto salida
    -- CKA Escribir o modifir el Acumulador
    -- PCL Modificar Program Counter

    
    -- SCL Selector Ram
    -- SCR Selector Registro
    -- SCD Selector de dato
    -- IBI IBO Maquina de estados del decodificador 

CSC <=  
--      SSCCP
--   WXXPPKKC
--   RDUDUPAL
    "00000010" when (IBI="00" and (ROMIN<"00010000" or (ROMIN>"00010111" and ROMIN<"00111000") or (ROMIN>"00111111" and ROMIN<"01000111") or ROMIN="01010001" or ROMIN="01010011")) or (ROMIN="01010111" and IBI="10") else
    "00000001" when IBI="01" or (ROMIN="01011101" and IBI="00" and FLAGIN(3)='1') or (ROMIN="01011110" and IBI="00" and FLAGIN(2)='1') or (ROMIN="01011111" and IBI="00" and FLAGIN(1)='1') or (ROMIN="01100000" and IBI="00" and FLAGIN(0)='1') or (ROMIN="01011010" and IBI="10") else 
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
    "00000000";*/