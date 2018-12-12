// Sign extender
module signextend(input wire [15:0] inputVal, output wire [31:0] outputVal);

    assign outputVal = { {16{inputVal[15]}}, inputVal };

endmodule

// 32-bit 2 to 1 Multiplexer
module twotoonemux(input wire [31:0] input1, input wire [31:0] input2, input wire sel, output wire [31:0] outputval);

    assign outputval = (sel == 0) ? input1 : input2;

endmodule

// 32-bit 2 to 1 Multiplexer
module twotoonemux2(input wire [31:0] input1, input wire [31:0] input2, input wire sel, output wire [31:0] outputval);

    assign outputval = (sel == 0) ? input1 : input2;

endmodule

// 5-bit 2 to 1 Multiplexer
module twotoonemux_5bit(input wire [4:0] input1, input wire [4:0] input2, input wire sel, output wire [4:0] outputval);

    assign outputval = (sel == 0) ? input1 : input2;

endmodule

// Arithmetic Logic Unit
module alu(input wire [31:0] op1,input wire [31:0] op2,input wire [3:0] ctrl,output wire [31:0] result);

	assign result = (ctrl == 4'b0000) ? (op1 & op2) : ((ctrl == 4'b0001) ? (op1 | op2) : 
		((ctrl == 4'b0010) ? (op1 + op2) : ((ctrl == 4'b0110) ? (op1 - op2) : 
		((ctrl == 4'b0111) ? ((op1 < op2) ? 1 : 0) : ((ctrl == 4'b1100) ? (~(op1 | op2)) : (op1 + op2)) ) ) ) );

endmodule

// ALU Control
module alucontrol(input wire [5:0] func, input wire [1:0] aluOp, output wire [3:0] aluctrl);
        always @ * begin    
        if(((func == 6'd32)&&(aluOp == 2'd2)) || (aluOp == 2'd0)) begin
        
            aluctrl = 4'd2; // Add or LW/SW
    
        end else if ((func == 6'd34)&&(aluOp == 2'd2)) begin
        
            aluctrl = 4'd6; // Subtract
        
        end else if ((func == 6'd36)&&(aluOp == 2'd2)) begin
        
            aluctrl = 4'd0; // AND
        
        end else if ((func == 6'd37)&&(aluOp == 2'd2)) begin
        
            aluctrl = 4'd1; // OR
        
        end else if ((func == 6'd39)&&(aluOp == 2'd2)) begin
        
            aluctrl = 4'd12; // NOR
        
        end else if ((func == 6'd42)&&(aluOp == 2'd2)) begin  
            aluctrl = 4'd7;  // SLT
        end              
    end 
endmodule

// Register File
module registerfile(input wire rst, input wire [4:0] readReg1, input wire [4:0] readReg2, input wire [4:0] writeReg, 
    input wire [31:0] writeData, input wire regWrite, output reg [31:0] readData1, output reg [31:0] readData2);

    // Register file
    reg [31:0] register[31:0];

    integer i;

    always @(posedge rst)
    begin
        for(i=0;i<32;i=i+1)
        begin
            register[i] = 0;
        end
    end

    always @(readReg1)
    begin
        readData1 = register[readReg1];
    end

    always @(readReg2)
    begin
        readData2 = register[readReg2];
    end

    always @(posedge regWrite)
    begin
    	if(writeReg != 0)
        	register[writeReg] = writeData;
    end

endmodule

// Data Memory
module datamem(input wire rst, input wire [6:0] memAddr, input wire memRead, input wire memWrite, 
    input wire [31:0] writeData, output reg [31:0] readData);

    // Memory
    reg [31:0] memory[127:0];

    integer i;

    always @(posedge rst)
    begin
        for(i=0;i<128;i=i+1)
        begin
            memory[i] = 0;
        end
    end

    always @(posedge memRead)
    begin
        readData = memory[memAddr];
    end

    always @(posedge memWrite)
    begin
        memory[memAddr] = writeData;
    end

endmodule




// FSM portion of Control Path (RegWrite, MemRead, MemWrite)     
module controlpathfsm(input wire rst, input wire clk, input wire newInstruction, input wire [5:0] opcode, 
                        output reg _RegWrite, output reg _MemRead, output reg _MemWrite);
   
   
   typedef enum reg [2:0] {A,B,C,D,E} state;
   
   state currentState, nextState;
   
   //

	always @(posedge clock)
	
		if(reset) 					currentState <=A;
		else if (newInstruction) 	currentState <=A;
		else 						currentState <= nextState;
		
		case(curretnState)
		
			A:  _RegWrite = 0;
				_MemRead  = 0;
				_MemWrite = 0;
				nextState = B;

			B:	if (opcode==0)  // add, sub, and, or
					begin
						nextState = C;
					end
		
				else if (opcode==35)  //lw 
					begin
						nextState = D;
					end
		
				else if (opcode==43) //sw
					begin
						nextState = E;
					end
			
			
			C: //add, sub, and, or, slt
				_RegWrite = 1;
				_MemRead = 0;
				_MemWrite = 0;
				
			D: //lw
				_RegWrite = 1;
				_MemRead = 1;
				_MemWrite = 0;
			
			E: //sw
				_RegWrite = 0;
				_MemeRead = 0;
				_MemWrite = 1;
				
			default:_RegWrite = 0;
					_MemRead  = 0;
					_MemWrite = 0;
		endcase
			                     
endmodule

// Combinational logic portion of Control Path (MemToReg, RegDst, ALUSrc, ALUOp)
module controlpathcomb(input wire [5:0] opcode, output wire _MemToReg, 
                    output wire _RegDst, output wire _ALUSrc, output wire [1:0] _ALUOp);

 always @ * begin    

        if(opcode == 6'd0) //ALL R-Types, ADD, SUB, AND, and OR
        begin

        _MemToReg   = 1'd0;
        _RegDst     = 1'd1;
        _ALUSrc     = 1'd0;
        _ALUOp      = 2'd2;
       
        end 

        else if(opcode == 6'd35) //LW
        begin
        
        _MemToReg   = 1'd1;
        _RegDst     = 1'd0;
        _ALUSrc     = 1'd1;
        _ALUOp      = 2'd0;
       
        end 

        else if(opcode == 6'd43) //SW
        begin
        
        _MemToReg   = 1'd0; //don't care
        _RegDst     = 1'd0; //don't care
        _ALUSrc     = 1'd1;
        _ALUOp      = 2'd0;
       
        end 
    end 
                    
endmodule




// The entire CPU without PC, instruction memory, and branch circuit
module mipscpu(input wire reset, input wire clock, input wire [31:0] instrword, input wire newinstr);

    wire rst = reset;   // Reset Signal
    wire clk = clock;   // Clock Signal
    wire newInstruction = newinstr;     // Used to signal a new instruction 

    
    // FSM Control Path
    wire [5:0] FSMOpcode = instrword[31:26];
    reg _RegWrite;
    reg _MemRead;
    reg _MemWrite;

    // Combination Logic Portion of Control path
    wire [5:0] CombOpcode = instrword[31:26];
    wire _MemToReg;
    wire _RegDst;
    wire _ALUSrc;
    wire [1:0] _ALUOp;

    // ALU Control
    wire [5:0] func = instrword[5:0];
    wire [1:0] aluOp = _ALUOp;
    wire [3:0] aluctrl;

    // Sign Extend 
    wire [15:0] inputVal = instrword[15:0];
    wire [31:0] outputVal;
    
    // 5-bit 2 to 1
    wire [4:0] mux_5in1 = instrword[20:16];
    wire [4:0] mux_5in2 = instrword[15:11];
    wire [4:0] outval_5;
    wire sel_5 = _RegDst;
        
    // Register File
    wire [4:0] readReg1 = instrword[25:21];
    wire [4:0] readReg2 = instrword[20:16];
    wire [4:0] writeReg = outval_5;
    wire [31:0] writeData;
    wire regWrite = _RegWrite;
    reg [31:0] readData1;
    reg [31:0] readData2;

    // 32-bit 2 to 1 mux
    wire [31:0] mux_32in1 = readData2;
    wire [31:0] mux_32in2 = outputVal;
    wire [31:0] outval_32;
    wire sel_32 = _ALUSrc;

    // Arithmetic Logic Unit
    wire [31:0] op1 = readData1;
    wire [31:0] op2 = outval_32;
    wire [3:0] ctrl = aluctrl;
    wire [31:0] result;

    // Data Memory
    wire [6:0] memAddr;
    wire memRead = _MemRead;
    wire memWrite = _MemWrite;
    wire [31:0] writeDataMem = readData2;
    reg [31:0] readData;

    // 32-bit 2 to 1 mux
    wire [31:0] input1 = result;
    wire [31:0] input2 = readData;
    wire [31:0] outputval;
    wire sel = _MemToReg;

    // ALU results

    assign writeData = outputval;
  
    // Module instantiations
    
    signextend signextend(inputVal, outputVal);
    twotoonemux twotoonemux(mux_32in1, mux_32in2, sel_32, outval_32);
    twotoonemux2 twotoonemux2(input1, input2, sel, outputval);
    twootoonemux_5bit twotoonemux_5bit(mux_5in1, mux_5in2, sel_5, outval_5);
    alu alu(op1, op2, ctrl, result);
    alucontrol alucontrol(func, aluOp, aluctrl);
    registerfile registerfile(rst, readReg1, readReg2, writeReg, writeData, regWrite, readData1, readData2);
    datamem myDataMem(rst, memAddr, memRead, memWrite, writeDataMem, readData);
    controlpathfsm controlpathfsm(rst, clk, newInstruction, FSMOopcode, _RegWrite, _MemRead, _MemWrite);
    cotrolpathcomb controlpathcomb(CombOpcode, _MemToReg, _RegDst, _ALUSrc, _ALUOp);
 
endmodule
