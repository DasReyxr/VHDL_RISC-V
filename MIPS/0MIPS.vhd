----------- Code -----------
--------- Auf Das ---------
----------- MIPS -----------
--- I. Date: 03/23/2026 ---
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
        B1UP,B2DOWN : in std_logic;
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

    constant  TYPE_R :std_logic_vector(2 downto 0)  := "001";
    constant  TYPE_I :std_logic_vector(2 downto 0)  := "010";
    constant  TYPE_J :std_logic_vector(2 downto 0)  := "100";
    
    -- Virtual Rom -- 
    signal S_P1OUT: std_logic_vector (7 downto 0) :="00000000";
    type MEMORY is array (0 to 33) of std_logic_vector(7 downto 0);

    type REG is array (0 to 31) of std_logic_vector(31 downto 0);
    
    
    signal VRAMIN : MEMORY := (others => x"FF");
    signal S_ADDRESSRAM : unsigned(7 downto 0):= x"00";


    -- Main Clock --
    signal CLKS : std_logic;
    signal RESET : std_logic:= '1';

    -- Program Counter --
    signal S_PCIN,PC_A,PC_S : unsigned (7 downto 0) := "00000000";
    
    
    -- BUSES DE SLECTOR DE DATOS Y CSC --
    signal P1, SELR : std_logic_vector(7 downto 0) := (others => '0');
    signal XIN, DATA : unsigned (7 downto 0) := (others => '0'); 
    signal SPIN: unsigned (7 downto 0) := x"21";

    -- MUX RAM --
    signal SELL : std_logic_vector (1 downto 0) := (others => '0');
    signal RW : std_logic;
    SIGNAL VALOR,VALORA : natural:=2;
    --MUX DATA--
    signal SELD : std_logic_vector (2 downto 0) := (others => '0');
    -- Flags --
    signal FLAGIN, FLAGOUT : std_logic_vector (3 downto 0) := (others => '0');
    -- ALU --
    signal ALU : signed (7 downto 0) := (others => '0');
    signal AC, REG : signed(8 downto 0) := (others => '0');
    signal INA,CPC : signed( 8 downto 0)  := (others => '0');
    
    signal F_CARRY, F_NEG, F_OVF, F_ZERO: std_logic := '0';
    

    -- Instruction Decoder  --
    signal S_WRAM, EN_PORT, EN_AC, PCL: std_logic;
    signal IBI  : std_logic_vector(1 downto 0) := (others => '0');
    signal IBO  : std_logic_vector (1 downto 0) := (others => '0');
    
    signal SPUD, XUD : std_logic_vector (1 downto 0) ;
     signal S_B1UP, S_B2DOWN :  std_logic:= '0';  
    -- 1 Second Counter --
    signal c, cplus : unsigned(25 downto 0) := (others => '0'); -- 25 Bits 

    --- Register Selected ---
    signal rs,rt,rd : std_logic_vector(3 downto 0) := (others => '0');
    signal IMM : std_logic_vector(15 downto 0) := (others => '0');
    signal ADDR : std_logic_vector(25 downto 0) := (others => '0');
    signal OPCODE : std_logic_vector(5 downto 0) := (others => '0');
    signal TYPE_INST : std_logic_vector(2 downto 0) := (others => '0');

    signal STATE, STATE_P : unsigned(2 downto 0) := (others => '0');
begin

    --Debugging --
    RESET<=RESETV;

    ------------------------------ 1SEQUENCER -----------------------------

    ------------------------- 1Instruction FETCH -------------------------

    -- Program Counter --
    clks <= not CLK;
    STATE <= STATE_P when clks'event and clks = '1';
    STATE_P <= STATE + 1 when STATE < "100" else "000";
    
            --     "001" when STATE = "000" else
            --    "010" when STATE = "001" else
            --    "011" when STATE = "010" else
            --    "100" when STATE = "011" else
            --    "000";


    clk4 <= STATE(3);

	PCIN <= std_logic_vector(S_PCIN);
    S_PCIN  <= (PC_A) when clk4'event and clk4 = '1';

    PC_A <= S_PCIN + 1; 
    ROMIN <= VROMIN(to_integer(S_PCIN)) when clk4'event and clk4 = '1';

    -------- Control Signals --------
    Branch <= '1' when  (OPCODE = I_BEQ and F_ZERO = '1') or (OPCODE = I_BNE and F_ZERO = '0') else '0';
    UncondBranch <= OPCODE = I_J or OPCODE = I_JAL or OPCODE = I_JR;
    -- Memory --
    MemRead <= '1' when (OPCODE = I_LB OR OPCODE = I_LW) else '0';
    MemWrite <= '1' when (OPCODE = I_SB OR OPCODE = I_SW) else '0';
    Mem2Reg <= '1' when (OPCODE = I_LB OR OPCODE = I_LW) else '0';
    RegWrite <= '1' when (OPCODE = I_ADDI OR OPCODE = I_LB OR OPCODE = I_LW) else '0';
    -- ALU --
    ALUOp <= ;
    ALUSrc <= '1' when TYPE_INST = TYPE_I else '0';

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
    FLAGIN <= "0000" when RESET = '0' else 
              F_ZERO & F_CARRY & F_NEG & F_OVF;


    ---------------------------- 3Arithmetic Logic Unit ----------------------------
    ALU_IN1 <= REG(rs);
    ALU_IN2 <= REG(rt) when ALUSrc = '0' else IMM(7 downto 0);
    
    with FUNCT select
    ALU_OUT <=  ALU_IN1+ ALU_IN2                        when I_ADD,
                unsigned(ALU_IN1) + unsigned(ALU_IN2)   when I_ADDU,    
                ALU_IN1- ALU_IN2                        when I_SUB,
                unsigned(ALU_IN1) - unsigned(ALU_IN2)   when I_SUBU,
                shift_left(ALU_IN1, to_integer(unsigned(rt(4 downto 0)))) when I_SLL,
                shift_right(ALU_IN1, to_integer(unsigned(rt(4 downto 0)))) when I_SRL,
                
                not ALU_IN1 + 1   when I_NOT,
                not ALU_IN1       when I_NEG,
                ALU_IN1 + 1       when I_INC,
                ALU_IN1 - 1       when I_DEC,
                ALU_IN1 and ALU_IN2                     when I_AND,
                ALU_IN1 or  ALU_IN2                     when I_OR,
                ALU_IN1 xor ALU_IN2                     when I_XOR,
                (others => '0') when others;

    
    ---------------------------- 4Instruction Decoder ----------------------------
    OPCODE <= ROMIN(31 downto 26);
    TYPE_INST<= TYPE_R when ROMIN(31 downto 26) = "0000" else
                TYPE_J when ROMIN(31 downto 27) = "001" else
                TYPE_I;

    --- reg ---
    rs <= ROMIN(25 downto 21) when TYPE_INST != TYPE_J else "00000";
    rt <= ROMIN(20 downto 16) when TYPE_INST != TYPE_J else "00000";
    rd <= ROMIN(15 downto 11) when TYPE_INST  = TYPE_R else "00000";
    --- imm ---
    IMM <= ROMIN(15 downto 0) when TYPE_INST = TYPE_I else
           (others => '0');
    ADDR <= ROMIN(25 downto 0) when TYPE_INST = TYPE_J else
            (others => '0');
    --- Funct ---
    FUNCT <= ROMIN(5 downto 0) when TYPE_INST = TYPE_R else
            (others => '0');
    
    ----- 1 Second Counter ----- 
    -- Memoria --
    c <= cplus when clk'event and clk='1';
    -- Logica de estado Siguiente --
    cplus <= c + 1 when (c < "11001101111111100110000000") else (others => '0');
    
    CLKS <= not CLK;--C(VALOR); --cplus(26);

    P_DEBUG <= 
        --not std_logic_vector(AC(7 downto 0));
        --not std_logic_vector(DATA);
        --not std_logic_vector(ALU);
        --not ("00000" &EN_AC & EN_PORT & PCL);
        not std_logic_vector(S_P1OUT);
        --not ROMIN;
        --not std_logic_vector(PC_A);
    
    -- Internal Memory --
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
    --WRAM<=S_WRAM; 
    /*RAMIN <= "ZZZZZZZZ" when S_WRAM = '0' else std_logic_vector(DATA);
    RW <= S_WRAM and (not CLKS);
    */
    REG <=signed('0'&RAMIN);    
    
    RAMIN <= VRAMIN(to_integer(S_ADDRESSRAM));
    VRAMIN(to_integer(S_ADDRESSRAM)) <= std_logic_vector(DATA) when S_WRAM = '1';

    P1OUT <= S_P1OUT;
    S_P1OUT <= --x"00" when RESET = '0' and clks'event and clks = '1' else
                P1 when CLKS'event and CLKS = '1';
    P1 <= std_logic_vector(DATA) when  EN_PORT = '1' else 
            S_P1OUT;-- else "ZZZZZZZZ"; --CSC(2) = EN_PORT



    ---------------------------- 3Arithmetic Logic Unit ----------------------------
  
   

end juve3dstudio;