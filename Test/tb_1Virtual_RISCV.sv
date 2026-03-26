`timescale 1ns/1ps

module tb_1Virtual_RISCV;

    logic       CLK;
    logic       RESETV;
    tri   [7:0] RAMIN;
    logic [7:0] PCIN;
    logic [7:0] ADDRESSRAM;
    logic       WRAM;
    logic [7:0] P0IN;
    logic [7:0] P1OUT;
    logic [7:0] PDebug;

    logic       ramin_oe;
    logic [7:0] ramin_drv;

    assign RAMIN = ramin_oe ? ramin_drv : 8'hZZ;

    RISCV dut (
        .CLK(CLK),
        .RESETV(RESETV),
        .RAMIN(RAMIN),
        .PCIN(PCIN),
        .ADDRESSRAM(ADDRESSRAM),
        .WRAM(WRAM),
        .P0IN(P0IN),
        .P1OUT(P1OUT),
        .PDebug(PDebug)
    );

    // 100 MHz clock
    initial CLK = 1'b0;
    always #5 CLK = ~CLK;

    initial begin
        RESETV    = 1'b0;
        P0IN      = 8'h00;
        ramin_oe  = 1'b0;
        ramin_drv = 8'h00;

        // Reset pulse
        #40;
        RESETV = 1'b1;

        // Basic external input changes over time
        #100 P0IN = 8'h12;
        #100 P0IN = 8'hA5;
        #100 P0IN = 8'h3C;

        // Optional external RAM drive windows
        #50  ramin_oe = 1'b1; ramin_drv = 8'h77;
        #40  ramin_oe = 1'b0;

        #200 ramin_oe = 1'b1; ramin_drv = 8'h55;
        #40  ramin_oe = 1'b0;

        #600;
        $stop;
    end

    // Wave dump for simulators that support VCD
    initial begin
        $dumpfile("tb_1Virtual_RISCV.vcd");
        $dumpvars(0, tb_1Virtual_RISCV);
    end

endmodule
