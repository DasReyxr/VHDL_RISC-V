----------- Code -----------
--------- Auf Das ---------
------ RISCV Virtual ------
--- I. Date: 03/01/2025 ---
--- C. Date: 24/01/2025 ---
------- Main Library -------
library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.NUMERIC_STD.ALL;

--------- Pin/out ---------
entity RISCV is
	port
	(
        ---- Main Clock ---
        RESETV, CLK : in std_logic;
        -- Rom & Ram --
        --ROMIN: in std_logic_vector (7 downto 0);
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
    -- Virtual Rom -- 
    signal  ROMIN, S_P1OUT: std_logic_vector (7 downto 0) :="00000000";
    type MEMORY is array (0 to 35) of std_logic_vector(7 downto 0);
    constant VROMIN : MEMORY := (x"57",
        x"01", x"50", x"45", x"50", -- Data values for addresses 0 to 3
        x"45", x"50", x"45", x"50", -- Data values for addresses 4 to 7
        x"45", x"50", x"45", x"50", -- Data values for addresses 8 to 11
        x"45", x"50", x"45", x"50",  -- Data values for addresses 12 to 15
        x"46", x"50", x"46", x"50",
        x"46", x"50", x"46", x"50",
        x"46", x"50", x"46", x"50",
        x"46", x"50",x"46", x"50",x"44" ,
   others => x"FF" -- Remaining addresses 16 to 255 filled with zeros
    );
           /* Barrido LEds
    constant VROMIN : MEMORY := (
        x"57", x"01", x"39", x"57", x"02", 
        x"01", x"50", 
    others => x"FF"
    );
    */
    signal VRAMIN : MEMORY := (others => x"FF");
    signal S_ADDRESSRAM : unsigned(7 downto 0);

    -- Main Clock --
    signal CLKS : std_logic;
    signal RESET : std_logic:= '1';

    -- Program Counter --
    signal S_PCIN,PC_A,PC_S : unsigned (7 downto 0) := "00000000";
    
    
    -- BUSES DE SLECTOR DE DATOS Y CSC --
    signal P1, SELR : std_logic_vector(7 downto 0) := (others => '0');
    signal XIN, DATA : unsigned (7 downto 0) := (others => '0'); 
    signal SPIN: unsigned (7 downto 0) := x"34";

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
    
    signal F_CARRY, F_NEG, F_OVF, F_ZERO: std_logic;
    

    -- Instruction Decoder  --
    signal S_WRAM, EN_PORT, EN_AC, PCL: std_logic;
    signal IBI  : std_logic_vector(1 downto 0) := (others => '0');
    signal IBO  : std_logic_vector (1 downto 0) := (others => '0');
    
    signal SPUD, XUD : std_logic_vector (1 downto 0) ;
      
    -- 1 Second Counter --
    signal c, cplus : unsigned(25 downto 0) := (others => '0'); -- 25 Bits 

begin
    --Debugging --
    RESET<=RESETV;
    ----- 1 Second Counter ----- 
    -- Memoria --
    c <= cplus when clk'event and clk='1';
    -- Logica de estado Siguiente --
    cplus <= c + 1 when (c < "11001101111111100110000000") else (others => '0');
    
    CLKS <= 
            C(20);  
            --not clk; --(For debugging in tb)
    
    P_DEBUG <= 
        --not std_logic_vector(AC(7 downto 0));
        --not std_logic_vector(DATA);
        --not std_logic_vector(ALU);
        --not ("00000" &EN_AC & EN_PORT & PCL);
        not std_logic_vector(S_P1OUT);
        --not ROMIN;
        --not std_logic_vector(PC_A);
    
    -- Internal Memory --
    ROMIN <= VROMIN(to_integer(S_PCIN));
    -- MUX RAM --
    with SELL select
    S_ADDRESSRAM <= 
        unsigned(SELR) when "00",
        unsigned(SELR) when "01",
        XIN   when "10",
        SPIN  when "11",
        x"00" when others;

    ADDRESSRAM <= std_logic_vector(S_ADDRESSRAM);
    -- RAM --
    REG <=signed('0'&RAMIN) when S_WRAM = '1' else REG;
    
	RAMIN <= VRAMIN(to_integer(S_ADDRESSRAM));
    VRAMIN(to_integer(S_ADDRESSRAM)) <= std_logic_vector(DATA) when S_WRAM = '1';

    P1OUT <= S_P1OUT;
    S_P1OUT <= P1 when CLKS'event and CLKS = '1';
    P1 <= std_logic_vector(DATA) when  EN_PORT = '1' else 
            S_P1OUT;
    ------------------------------ 1SEQUENCER -----------------------------
    -- Program Counter -- 
	PCIN <= std_logic_vector(S_PCIN);
    S_PCIN  <= (PC_A) when clks'event and clks = '1';

    PC_A <=
        x"00" when PC_A >= 35 and RESET = '1' else
        (others => '0') when RESET = '0' else
        DATA + 2 when PCL = '1' else
        PC_A + 1 when rising_edge(clks) and PCL = '0' else
        PC_A;

    ------------------------------ 2Registers ------------------------------
    -- Stack Pointer --
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

   
    -- Flag Register --
    FLAGOUT <= FLAGIN when CLKS'event and CLKS = '1' ;
    FLAGIN <= "0000" when RESET = '1' else 
              F_ZERO & F_CARRY & F_NEG & F_OVF;
    ---------------------------- 3Arithmetic Logic Unit ----------------------------
  
    -- ALU --
    AC <= "000000000" when RESET = '0' else 
        signed('0'&std_logic_vector(DATA)) when CLKS'event and CLKS = '1'  and EN_AC = '1';
        
 
    F_ZERO <='0' when ROMIN = x"4C" else '1' when INA = "000000000" else '1' when ROMIN = x"4B" else  '0';
    F_CARRY<='1' when ROMIN = x"47" else '0' when ROMIN = x"48" else INA(8);
    F_NEG  <='1' when ROMIN = x"49" else '0' when ROMIN = x"4C" else INA(7);
    F_OVF  <='1' when ROMIN = x"4D" else '0' when ROMIN = x"4E" else F_CARRY xor F_NEG;
    with ROMIN select
    INA <= 
        AC + REG + FLAGOUT(2)         when "00000000" | "00000001" | "00000010" | "00000011" |
                                        "00000100" | "00000101" | "00000110" | "00000111",
        AC - REG - FLAGOUT(2)         when "00001000" | "00001001" | "00001010" | "00001011" |
                                        "00001100" | "00001101" | "00001110" | "00001111",
        not(AC) + 1                   when "01000000",
        not AC                        when "01000001",
        AC + 1                        when "01000010",
        AC - 1                        when "01000011",
        AC AND "000000000"            when "01000100",
        AC and REG                    when "00011000",
        AC or REG                     when "00100000",
        AC xor REG                    when "00101000",
        AC + AC + FLAGOUT(2)          when "01000101",
        AC(0) & FLAGOUT(2) & AC(7 downto 1) when "01000110",
        AC                   when others;

        

    ALU <= CPC(7 downto 0) when ROMIN = x"10" else INA(7 downto 0);
    CPC <= AC - REG  - FLAGOUT(2);

    ---------------------------- 4Instruction Decoder ----------------------------

    -- MUX DATOS --
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
    PCL <= '1'  when IBI="01" or (ROMIN=x"5D" and IBI="00" and FLAGIN(3)='1') or (ROMIN=x"5E" and IBI="00" and FLAGIN(2)='1') or (ROMIN=x"5F" and IBI="00" and FLAGIN(1)='1') or (ROMIN=x"60" and IBI="00" and FLAGIN(0)='1') or (ROMIN=x"5A")
                or (IBI="01" and ROMIN=x"5B") or (IBI="11") else '0';

    EN_AC <='1' when ((IBI="00" and (ROMIN<x"10" or (ROMIN>x"17" and ROMIN<x"38") or (ROMIN>x"3F" and ROMIN<x"47") or ROMIN=x"50" or ROMIN=x"51" or ROMIN=x"53")) or IBI="10")  
            else '0';

    EN_PORT <= '1' when ROMIN = x"50" else '0';

    SPUD <= "01" when (IBI="00" and ROMIN=x"5B") else
            "10" when (IBI="00" and ROMIN=x"56") or (ROMIN=x"5C") else
            "00";

    XUD <=  "01" when IBI="00" and ROMIN=x"58" else
            "10" when IBI="00" and ROMIN=x"59" else
            "11" when IBI="00" and ROMIN=x"52" else
            "00";

    S_WRAM <= '1' when (IBI="00" and ((ROMIN>x"37" and ROMIN<x"40") or ROMIN=x"54"  or ROMIN=x"5B")) 
                or   (IBI="00" and (ROMIN=x"56" or ROMIN = x"61"))  else '0';

    SELR <= '0'&'0'&'0'&'0'&'0' & ROMIN(2 downto 0) when (ROMIN(7 downto 3) < "01000") else "00000000";
    SELL <= 
        "11" when (IBI="00" and ((ROMIN>x"54" and ROMIN<x"57") or (ROMIN>x"5A" and ROMIN<x"5D") or ROMIN=x"5B"))or IBI = "11" else
        "10" when IBI="00" and (ROMIN>x"52" and ROMIN<x"55") else
        "00";            

    SELD <= 
        M_INA when (IBI="00" and ((ROMIN>x"37" and ROMIN<x"40") or ROMIN=x"40" or ROMIN=x"42" or ROMIN=x"44" or ROMIN=x"46"  or ROMIN = x"50" or  ROMIN = x"61"))  else
        M_P0IN when IBI="00" and ROMIN=x"4F" else
        --M_SPIN when IBI="00" and ROMIN=x"5C" else
        M_XIN when IBI="00" and ROMIN=x"51" else
        M_RAMIN when (IBI="00" and ((ROMIN>x"2F" and ROMIN<x"38") or ROMIN = x"5C" or ROMIN=x"53" or ROMIN=x"55")) or IBI = "11" else
        M_PCIN when IBI="00" and ROMIN=x"5B" else
        M_ROMIN when IBI="01" or IBI="10" else
        M_ALU;

    IBO <= 
        "01" when IBI="00" and ((ROMIN=x"5D" and FLAGIN(3)='1') or (ROMIN=x"5E" and FLAGIN(2)='1') or (ROMIN=x"5F" and FLAGIN(1)='1') or (ROMIN=x"60" and FLAGIN(0)='1') or ROMIN=x"5A" or ROMIN=x"5B") else
        "10" when ROMIN = x"57" else
        "11" when ROMIN = x"5C" else
        "00";

    -- Decoder Machine States --
    IBI <=
        IBO  when CLKS'event and CLKS ='1' and RESET = '1' else
        "00" when CLKS'event and CLKS ='1'; 

end juve3dstudio;