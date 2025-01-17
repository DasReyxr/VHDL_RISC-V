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
        RESET, CLK : in std_logic;
        -- Rom & Ram --
        ROMIN: in std_logic_vector (7 downto 0);
        RAMIN : inout std_logic_vector (7 downto 0);
        -- Address --
        PCIN, ADDRESSRAM: out std_logic_vector (7 downto 0);
        WRAM : out std_logic;
        -- Ports --
        P0IN : in  std_logic_vector (7 downto 0);
        P1OUT: out std_logic_vector (7 downto 0);
        P_DEBUG : out std_logic_vector (7 downto 0)
        );
end RISCV;


architecture juve3dstudio of RISCV is
    constant  M_ALU          :std_logic_vector(2 downto 0)  := "000";
    constant  M_ROMIN        :std_logic_vector(2 downto 0)  := "001";
    constant  M_PCIN         :std_logic_vector(2 downto 0)  := "010";
    constant  M_RAMIN        :std_logic_vector(2 downto 0)  := "011";
    constant  M_XIN          :std_logic_vector(2 downto 0)  := "100";
    constant  M_SPIN         :std_logic_vector(2 downto 0)  := "101";
    constant  M_P0IN         :std_logic_vector(2 downto 0)  := "110";
    constant  M_INA          :std_logic_vector(2 downto 0)  := "111";
    -- Main Clock --
    signal CLKS : std_logic;
    -- Program Counter --
    signal PC_S,PC_A : unsigned (7 downto 0) := "00000000";
    
    
    -- BUSES DE SLECTOR DE DATOS Y CSC --
    signal P1, SELR : std_logic_vector(7 downto 0);
    signal XIN, DATA : unsigned (7 downto 0) := (others => '0'); 
    signal SPIN: unsigned (7 downto 0) := x"FF";

    -- MUX RAM --
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
    
    signal CARRY, NEG, OVF, ZERO: std_logic;
    

    -- Instruction Decoder  --
    signal S_WRAM, XD, XU, SPD, SPU, EN_PORT, EN_AC, PCL: std_logic;
    signal IBI  : std_logic_vector(1 downto 0) := (others => '0');
    signal SCL,IBO  : std_logic_vector (1 downto 0) := (others => '0');
    signal SCR, SCD : std_logic_vector (2 downto 0) := (others => '0');
    
    signal SPUD, XUD : std_logic_vector (1 downto 0) ;
    
    -- 1 Second Counter --
    signal c, cplus : unsigned(26 downto 0) := (others => '0'); -- 25 Bits 
    constant tim : integer := 33554431;

begin
    --Debugging --

    ----- 1 Second Counter ----- 
    -- Memoria --
    c <= cplus when clk'event and clk='1';
    -- Logica de estado Siguiente --
    cplus <= c + 1 when (c < "111111111111111111111111111") else (others => '0');
    
    CLKS <= cplus(26);

    P_DEBUG <= 
            not std_logic_vector(ALU);
             --   not ("00000" &EN_AC & EN_PORT & PCL);
            --not std_logic_vector(P1OUT);
    




 


    P1OUT <= P1 when CLKS'event and CLKS = '1' ;
    P1 <= std_logic_vector(DATA) when RESET = '1' and EN_PORT = '1' else "ZZZZZZZZ"; --CSC(2) = EN_PORT
    -- Program Counter -- 

    PCIN  <= std_logic_vector(PC_A);

    PC_A <= PC_S when  CLKS'event and CLKS = '1'; 
    PC_S <= PC_A + 1 when PC_A<x"FF" and RESET ='1' else x"00";

/*
    PC_A <= 
            PC_A + 1     when PCL = '0' and RESET = '1' and CLKS'event and CLKS = '1'   else
            DATA + 2   when PCL = '1' and RESET = '1' and CLKS'event and CLKS = '1'   else 
            PC_A;
  */  -- Stack Pointer --
    SPIN <=    
        SPIN         when CLKS'event and CLKS = '1'  and SPUD = "00" else
        SPIN + 1     when CLKS'event and CLKS = '1'  and SPUD = "10" else
        SPIN - 1     when CLKS'event and CLKS = '1'  and SPUD = "01" else
        x"FF"        when CLKS'event and CLKS = '1'  and SPUD = "11";

    -- X Pointer --
    XIN <=    
        XIN         when CLKS'event and CLKS = '1'  and XUD = "00" else
        XIN + 1     when CLKS'event and CLKS = '1'  and XUD = "10" else
        XIN - 1     when CLKS'event and CLKS = '1'  and XUD = "01" else
        DATA        when CLKS'event and CLKS = '1'  and XUD = "11";

    -- MUX RAM --
    with SELL select
    ADDRESSRAM <= 
        std_logic_vector(SELR) when "00",
        std_logic_vector(SELR) when "01",
        std_logic_vector(XIN)   when "10",
        std_logic_vector(SPIN)  when "11",
        x"00" when others;

   
    -- RAM --
    WRAM<=S_WRAM; 
    RAMIN <= "ZZZZZZZZ" when S_WRAM = '0' else std_logic_vector(DATA);
    RW <= S_WRAM and (not CLKS);

    -- Flag Register --
    FLAGOUT <= FLAGIN when CLKS'event and CLKS = '1' ;
    FLAGIN <= "0000" when RESET = '1' else 
              ZERO & CARRY & NEG & OVF;
    
    -- ALU --
    AC <= signed('0'&std_logic_vector(DATA)) when CLKS'event and CLKS = '1'  and RESET = '1' and EN_AC = '0' else
          "000000000" when CLKS'event and CLKS = '1';
        
    REG <=signed('0'&RAMIN);
 
    ZERO <='0' when ROMIN = x"4C" else '1' when INA = "000000000" else '1' when ROMIN = x"4B" else  '0';
    CARRY<='1' when ROMIN = x"47" else '0' when ROMIN = x"48" else INA(8);
    NEG  <='1' when ROMIN = x"49" else '0' when ROMIN = x"4C" else INA(7);
    OVF  <='1' when ROMIN = x"4D" else '0' when ROMIN = x"4E" else CARRY xor NEG;

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
    
        

    ALU <= CPC(7 downto 0) when ROMIN = x"10" else INA(7 downto 0);
    CPC <= AC - REG  - FLAGOUT(2);


--MUX DATOS
    with SELD select
    DATA     <=
              unsigned(ALU)   when M_ALU,
              unsigned(ROMIN) when M_ROMIN,
              unsigned(PC_A)  when M_PCIN,
              unsigned(RAMIN) when M_RAMIN,
              unsigned(XIN)   when M_XIN,
              unsigned(SPIN)  when "101",
              unsigned(P0IN)  when M_P0IN,
              unsigned(INA(7 downto 0))   when M_INA,
              x"00" when others;

    -- Decoder --

    PCL <= '1'  when IBI="01" or (ROMIN=x"5D" and IBI="00" and FLAGIN(3)='1') or (ROMIN=x"5E" and IBI="00" and FLAGIN(2)='1') or (ROMIN=x"5F" and IBI="00" and FLAGIN(1)='1') or (ROMIN=x"60" and IBI="00" and FLAGIN(0)='1') or (ROMIN=x"5A" and IBI="10")
                or (IBI="10" and ROMIN=x"5B") or (IBI="00" and ROMIN=x"5C") else '0';

    EN_AC <= '1' when (IBI="00" and (ROMIN<x"10" or (ROMIN>x"17" and ROMIN<x"38") or (ROMIN>x"3F" and ROMIN<x"47") or ROMIN=x"51" or ROMIN=x"53")) or IBI="10" 
            else '0';

    EN_PORT <= '1' when ROMIN = x"50"--(IBI="00" and ROMIN=x"40") or (IBI="00" and ROMIN=x"61") or (IBI="10" and ROMIN=x"5B") or ()
            else '0';

    SPUD <= "01" when (IBI="10" and ROMIN=x"5B") else
            "10" when (IBI="00" and ROMIN=x"56") or (IBI="00" and ROMIN=x"5C") else
            "11" when (IBI="00" and ROMIN=x"61") else 
            "00";

    XUD <=  "01" when IBI="00" and ROMIN=x"58" else
            "10" when IBI="00" and ROMIN=x"59" else
            "11" when IBI="00" and ROMIN=x"52" else
            "00";

    S_WRAM <= '1' when (IBI="00" and ((ROMIN>x"37" and ROMIN<x"40") or ROMIN=x"54"  or ROMIN=x"5B")) 
                or   (IBI="00" and (ROMIN=x"56")) else '0';

    SELR <= '0'&'0'&'0'&'0'&'0' & ROMIN(2 downto 0) when (ROMIN(7 downto 3) < "01000") else "00000000";
    SELL <= 
        "11" when IBI="00" and ((ROMIN>x"54" and ROMIN<x"57") or (ROMIN>x"5A" and ROMIN<x"5D") or ROMIN=x"5B") else
        "10" when IBI="00" and (ROMIN>x"52" and ROMIN<x"55") else
        "00";            

    SELD <= 
        M_INA when IBI="00" and ((ROMIN>x"37" and ROMIN<x"40") or ROMIN=x"40" or ROMIN=x"42" or ROMIN=x"44" or ROMIN=x"46") else
        M_P0IN when IBI="00" and ROMIN=x"4F" else
        M_SPIN when IBI="00" and ROMIN=x"5C" else
        M_XIN when IBI="00" and ROMIN=x"51" else
        M_RAMIN when IBI="00" and ((ROMIN>x"2F" and ROMIN<x"38") or ROMIN=x"53" or ROMIN=x"55" or ROMIN=x"5C") else
        M_PCIN when IBI="00" and ROMIN=x"5B" else
        M_ROMIN when IBI="01" or IBI="10" else
        M_ALU;

    IBO <= 
        "01" when IBI="00" and ((ROMIN=x"5D" and FLAGIN(3)='1') or (ROMIN=x"5E" and FLAGIN(2)='1') or (ROMIN=x"5F" and FLAGIN(1)='1') or (ROMIN=x"60" and FLAGIN(0)='1')) else
        "10" when IBI="00" and (ROMIN=x"57" or ROMIN=x"5A" or ROMIN=x"5B") else
        "00";

    -- Decoder Machine States --
    IBI <=
        IBO  when CLKS'event and CLKS ='1' and RESET = '1' else
        "00" when CLKS'event and CLKS ='1'; 

end juve3dstudio;


/*

    -- WRAM Escribir Ram
    
    -- XD  XU  Puntero X
    -- SPD SPU Stack Pointer
    --  0   0  sin cambio
    --  0   1  decremento
    --  1   0  incremento (pre)
    --  1   1  carga

    -- EN_PORT Mandar puerto salida ENP
    -- EN_AC Escribir o modifir el Acumulador ENA
    -- PCL Modificar Program Counter

    
    -- SCL Selector Ram MRAM
    -- SCR Selector Registro M
    -- SCD Selector de dato
    -- IBI IBO Maquina de estados del decodificador 


ADC A,Rs |0x"00" - 0x"07"
SBC A,Rs |0x"08" - 0x"0F"
CPC A,Rs |0x"10" - 0x"17"
AND A,Rs |0x"18" - 0x"1F"
ORL A,Rs |0x"20" - 0x"27"
EOR A,Rs |0x"28" - 0x"2F"
MOV A,Rs |0x"30" - 0x"37"
MOV Rs,A |0x"38" - 0x"3F"
COM A    |0x"40"
NEG A    |0x"41"
INC A    |0x"42"
DEC A    |0x"43"
CLR A    |0x"44"
ROL A    |0x"45"
ROR A    |0x"46"
SET C    |0x"47"
CLR C    |0x"48"
SET N    |0x"49"
CLR N    |0x"4A"
SET Z    |0x"4B"
CLR Z    |0x"4C"
SET V    |0x"4D"
CLR V    |0x"4E"
MOV A,PO |0x"4F"
MOV P1,A |0x"50"
MOV A,X  |0x"51"
MOV X,A  |0x"52"
MOV A,M  |0x"53"
MOV M,A  |0x"54"
POP A    |0x"55"
PUSH A   |0x"56"
MOV A,K  |0x"57"
INC X    |0x"58"
DEC X    |0x"59"
JMP      |0x"5A"
CALL     |0x"5B"
RET      |0x"5C"
BREQ     |0x"5D"
BRCS     |0x"5E"
BRMI     |0x"5F"
BRVS     |0x"60"
MOV SP,A |0x"61"
NOP      |0x"FF"
*/