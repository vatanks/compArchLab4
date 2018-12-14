`timescale 1ns/100ps
`include "student_cpu.v"
module cpu_tb;

    reg Reset;              // Reset signal
    reg [31:0] instrWord;   // Instruction Register
    reg newInstr;           // Used to signal a new instruction
    reg [31:0] checkreg;
    reg Clk;                // Clock Signal

    // CPU instantiation
    mipscpu myCPU(Reset, Clk, instrWord, newInstr);
    
    // Clock signal generator
    initial
        Clk = 0;

    always
        #1 Clk = ~Clk;
        
    // Waveform dump for waveform viewer application
    initial
    begin
        $dumpfile("cpu.vcd");
        $dumpvars; 
    end
        
    // Test bench
    initial
    begin
        // Test 1: d = a + b - c
        
        #1 Reset = 1;
        #1 Reset = 0;
        #1 myCPU.myDataMem.memory[0] = 10;
        #1 myCPU.myDataMem.memory[1] = 22;
        #1 myCPU.myDataMem.memory[2] = 6;
        // lw $1, 0($0); 
        #10 instrWord= 32'b100011_00000_00001_0000000000000000; 
        #1 newInstr=1;        

        #1 newInstr=0;

        // lw $2, 1($0);
        #10 instrWord= 32'b100011_00000_00010_0000000000000001; 
        #1 newInstr=1;
        #1 newInstr=0;
        // lw $3, 2($0);
        #10 instrWord= 32'b100011_00000_00011_0000000000000010; 
        #1 newInstr=1;
        #1 newInstr=0;
        // add $4, $1, $2; a + b
        #10 instrWord= 32'b000000_00001_00010_00100_00000_100000;
        #1 newInstr=1;
        #1 newInstr=0;
        // sub $4, $4, $3; ( a + b ) - c
        #10 instrWord= 32'b000000_00100_00011_00100_00000_100010;
        #1 newInstr=1;
        #1 newInstr=0;
        // sw $4, 3($0)
        #10 instrWord = 32'b101011_00000_00100_0000000000000011;
        #1 newInstr = 1;
        #1 newInstr = 0; 
        // Display
        #1 $display("Test 1: 10 + 22 - 6");
        #1 $display("a = %d", myCPU.myDataMem.memory[0]);
        #1 $display("b = %d", myCPU.myDataMem.memory[1]);
        #1 $display("c = %d", myCPU.myDataMem.memory[2]);
        #1 $display("d = %d", myCPU.myDataMem.memory[3]);        
        
        #1checkreg = (myCPU.myDataMem.memory[0] + myCPU.myDataMem.memory[1] - myCPU.myDataMem.memory[2]);
        
        if (checkreg == myCPU.myDataMem.memory[3]) begin
            $display("This output is correct : %d", checkreg);
            checkreg = 0;
        end
        else $display("That output is not correct, this output is correct ---> %d", checkreg);

        //*****************************************************

        // Test 2: d = b - a - c

        #1 Reset = 1;
        #1 Reset = 0;
        #1 myCPU.myDataMem.memory[0] = 5;
        #1 myCPU.myDataMem.memory[1] = 20;
        #1 myCPU.myDataMem.memory[2] = 11;
        // lw $1, 0($0); a
        #10 instrWord= 32'b100011_00000_00001_0000000000000000; 
        #1 newInstr=1;
        #1 newInstr=0;
        // lw $2, 1($0); b
        #10 instrWord= 32'b100011_00000_00010_0000000000000001;
        #1 newInstr=1;
        #1 newInstr=0;
        // lw $3, 2($0); c
        #10 instrWord= 32'b100011_00000_00011_0000000000000010; 
        #1 newInstr=1;
        #1 newInstr=0;
        // add $4, $1, $2; b - a
        #10 instrWord= 32'b000000_00010_00001_00100_00000_100010;
        #1 newInstr=1;
        #1 newInstr=0;
        // sub $4, $4, $3; ( b - a ) - c
        #10 instrWord= 32'b000000_00100_00011_00100_00000_100010;
        #1 newInstr=1;
        #1 newInstr=0;
        // sw $4, 3($0)
        #10 instrWord = 32'b101011_00000_00100_0000000000000011;
        #1 newInstr = 1;
        #1 newInstr = 0; 

        // Display
        #1 $display("Test 2: b - a - c ---> 20 - 5 - 11");
        #1 $display("a = %d", myCPU.myDataMem.memory[0]);
        #1 $display("b = %d", myCPU.myDataMem.memory[1]);
        #1 $display("c = %d", myCPU.myDataMem.memory[2]);
        #1 $display("d = %d", myCPU.myDataMem.memory[3]);

        #1checkreg = (myCPU.myDataMem.memory[1] - myCPU.myDataMem.memory[0] - myCPU.myDataMem.memory[2]);
        
        #1if (checkreg == myCPU.myDataMem.memory[3]) begin
            $display("This output is correct : %d", checkreg);
        end
        else $display("That output is not correct, this output is correct ---> %d", checkreg);
        //*****************************************************

        // Test 3: d = ( a & c ) | b

        #1 Reset = 1;
        #1 Reset = 0;
        #1 myCPU.myDataMem.memory[0] = 13;
        #1 myCPU.myDataMem.memory[1] = 1;
        #1 myCPU.myDataMem.memory[2] = 3;
        // lw $1, 0($0); a
        #10 instrWord= 32'b100011_00000_00001_0000000000000000; 
        #1 newInstr=1;
        #1 newInstr=0;
        // lw $2, 1($0); b
        #10 instrWord= 32'b100011_00000_00010_0000000000000001;
        #1 newInstr=1;
        #1 newInstr=0;
        // lw $3, 2($0); c
        #10 instrWord= 32'b100011_00000_00011_0000000000000010; 
        #1 newInstr=1;
        #1 newInstr=0;
        // AND $4, $1, $2; a & c
        #10 instrWord= 32'b000000_00001_00011_00100_00000_100100;
        #1 newInstr=1;
        #1 newInstr=0;
        // OR $4, $4, $3; [( a && c ) || b]
        #10 instrWord= 32'b000000_00100_00010_00100_00000_100101;
        #1 newInstr=1;
        #1 newInstr=0;
        // sw $4, 3($0)
        #10 instrWord= 32'b101011_00000_00100_0000000000000011;
        #1 newInstr=1;
        #1 newInstr=0; 

        // Display
        #1 $display("Test 3: (13 & 1) | 3 --> (1101 & 0001) | 0011 ");
        #1 $display("a = %d", myCPU.myDataMem.memory[0]);
        #1 $display("b = %d", myCPU.myDataMem.memory[1]);
        #1 $display("c = %d", myCPU.myDataMem.memory[2]);
        #1 $display("d = %d", myCPU.myDataMem.memory[3]);

        checkreg = ((myCPU.myDataMem.memory[0] & myCPU.myDataMem.memory[2]) | myCPU.myDataMem.memory[1]);
         
       #1if (checkreg == myCPU.myDataMem.memory[3]) begin
            $display("This output is correct : %d", checkreg);
        end
        else $display("That output is not correct, this output is correct ---> %d", checkreg);
        #1 $finish;
    end
endmodule
