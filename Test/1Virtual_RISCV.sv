// ----------- Code -----------
// --------- Auf Das ---------
// ------ RISCV Virtual ------
// --- I. Date: 03/01/2025 ---
// --- C. Date: 24/01/2025 ---
// ------- Main Library -------

import riscv_constants_pkg::*;

module RISCV (
    // Main Clock
    input wire CLK,
    input wire RESETV,
    // ROM 
    inout wire[7:0] RAMIN,
    // Address
    output reg[7:0] PCIN,
    output reg[7:0] ADDRESSRAM,
    output reg WRAM,
    // Ports
    input wire[7:0] P0IN,
    output reg[7:0] P1OUT,
    output reg[7:0] PDebug
);

    // Virtual Rom 
    logic [7:0] ROMIN, S_P1OUT;
    logic [7:0] VROMIN [0:ROM_DEPTH-1];
    logic [7:0] VRAMIN [0:ROM_DEPTH-1];

    logic RESET, clks;
    logic [7:0] S_ADDRESSRAM;
    logic [25:0] c, cplus;
    logic [7:0] XIN, XIN_COMB, SPIN, SP_COMB,PC_COMB;
    logic [7:0] S_PCIN = 8'd0, DATA, ALU, INA, SELR;
    logic [2:0] SELD;
    logic [1:0] XUD, SPUD, SELL;
    
    integer i;

initial begin
    S_P1OUT = 8'h00;

    for (i = 0; i < ROM_DEPTH; i = i + 1) begin
        VROMIN[i] = ROM_INIT[i];
        VRAMIN[i] = ROM_DEFAULT;
    end
end

// Same as: ROMIN <= VROMIN(to_integer(S_PCIN));
always_comb begin
    RESET = RESETV;
    ROMIN = VROMIN[S_PCIN]; // S_PCIN must be in range 0..35
end

// -- 1 Second counter--
always_ff @(posedge CLK)begin
    c = cplus;
end
always_comb begin : second_counter
    if (c < 26'b11001101111111100110000000)
        cplus = c + 1'b1;
    else
        cplus = 26'b0;

    clks = c[20];
    // !clk;
end

always_comb begin  
    case (SELD)
        M_ALU   : DATA = ALU;
        M_ROMIN : DATA = ROMIN;
        M_PCIN  : DATA = PCIN;
        M_RAMIN : DATA = RAMIN;
        M_XIN   : DATA = XIN;
        M_SPIN  : DATA = SPIN;
        M_P0IN  : DATA = P0IN;
        M_INA   : DATA = INA;
        default : DATA = 8'h00;
    endcase
end

/*
   WRAM Escribir Ram
    
   XD  XU  Puntero X
   SPD SPU Stack Pointer
    0   0  sin cambio
    0   1  decremento
    1   0  incremento (pre)
    1   1  carga

   EN_PORT Mandar puerto salida ENP
   EN_AC Escribir o modifir el Acumulador ENA
   PCL Modificar Program Counter

    
   SCL Selector Ram MRAM
   SCR Selector Registro M
   SCD Selector de dato
   IBI IBO Maquina de estados del decodificador 
              F_ZERO & F_CARRY & F_NEG & F_OVF;

*/
always_comb begin 
    if(ROMIN = INST_JMP || IBI[1] =1'b1 || (IBI = 2'b00 && ((ROMIN = INST_BREQ && FLAGIN[0])|| 
                                                            (ROMIN = INST_BRCS && FLAGIN[1])||
                                                            (ROMIN = INST_BRMI && FLAGIN[2])||
                                                            (ROMIN = INST_BRVS && FLAGIN[3]))) )
    PCL = 1'b1;
    else PCL = 1'b0;

    if(ROMIN == INST_MOV_P1) EN_PORT = 1b'1; else EN_PORT = 1b'0;

    
end
always_ff @(posedge CLK) begin 
   XIN <= XIN_COMB;
end
always_comb begin
    if (RESET) XIN_COMB = 7'd0;
    else 
    begin
    case (XUD)
        2'b00 : XIN_COMB = XIN;
        2'b01 : XIN_COMB = XIN+1;
        2'b10 : XIN_COMB = XIN-1;
        2'b11 : XIN_COMB = DATA;
    endcase
    end
    
    if (RESET) SP_COMB = 7'd0;
    else
    begin
        case (SPUD)
            2'b00 : SP_COMB = SPIN;
            2'b01 : SP_COMB = SPIN+1;
            2'b10 : SP_COMB = SPIN-1;
            2'b11 : SP_COMB = 7'hFF;
            default: SP_COMB = SPIN;
        endcase
    end

    begin
    case (SELL)
        2'b10 : ADDRESSRAM = SPIN;
        2'b11 : ADDRESSRAM = XIN; 
        default: ADDRESSRAM = SELR;
    endcase
    end
end 

    always_ff @(posedge CLK) begin
    PCIN = S_PCIN;
    end

    always_comb begin
        if (PCIN < (ROM_DEPTH - 1))
            S_PCIN = PCIN + 1'd1;
        else
            S_PCIN = 7'd0;
    end

endmodule
