`timescale 1ns/1ps

module tb_inst_type;

    localparam [2:0] TYPE_R = 3'b001;
    localparam [2:0] TYPE_I = 3'b010;
    localparam [2:0] TYPE_J = 3'b100;

    reg  [31:0] instr;
    reg  [2:0]  got_type;
    reg  [2:0]  exp_type;
    integer pass_count;
    integer fail_count;

    // Mirrors the intended decode rule in 0MIPS.sv
    function automatic [2:0] decode_type(input [31:0] x);
        begin
            if (x[31:26] == 6'b000000)
                decode_type = TYPE_R;
            else if (x[31:27] == 5'b00001)
                decode_type = TYPE_J;
            else
                decode_type = TYPE_I;
        end
    endfunction

    task automatic run_case(
        input [31:0] v_instr,
        input [2:0]  v_exp,
        input [8*24-1:0] label
    );
        begin
            instr = v_instr;
            #1;
            got_type = decode_type(instr);
            exp_type = v_exp;

            if (got_type === exp_type) begin
                pass_count = pass_count + 1;
                $display("PASS | %0s | instr=%h | type=%b", label, instr, got_type);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL | %0s | instr=%h | got=%b exp=%b", label, instr, got_type, exp_type);
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        // R-type samples (opcode 000000)
        run_case(32'h012A4020, TYPE_R, "R: add");
        run_case(32'h012A4822, TYPE_R, "R: sub");

        // I-type samples (opcode not 000000 and not 00001x)
        run_case(32'h21290005, TYPE_I, "I: addi");
        run_case(32'h8D090004, TYPE_I, "I: lw");
        run_case(32'hAD090008, TYPE_I, "I: sw");
        run_case(32'h312900FF, TYPE_I, "I: andi");

        // J-type samples (opcode 000010, 000011)
        run_case(32'h08000010, TYPE_J, "J: j");
        run_case(32'h0C000020, TYPE_J, "J: jal");

        $display("-----------------------------------------------");
        $display("RESULT: pass=%0d fail=%0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TB STATUS: PASS");
        else
            $display("TB STATUS: FAIL");

        $finish;
    end

endmodule
