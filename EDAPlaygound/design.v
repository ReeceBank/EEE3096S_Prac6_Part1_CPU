//contains ALU, CU, REG_MEM, SIMPLE_CPU(TOP)
`timescale 1ns / 1ps

//******************* ALU *********************
module alu( clk, operand_a, operand_b, opcode, result); //this is the alu, all it does is + and - two values
    parameter DATA_WIDTH = 8;

    input clk;
    input[DATA_WIDTH-1:0]operand_a,operand_b;
    input [3:0] opcode;
    output reg[DATA_WIDTH-1:0] result;

    
  always@(posedge clk)
    begin
     case(opcode)
        4'b0000: begin //Addition
           result <= operand_a + operand_b ; 
        end
        4'b0001: begin //Subtraction 
           result <= operand_a - operand_b;
        end
        default: result <= 8'bx; 
     endcase
     
    end
endmodule

//******************* CU *********************
module CU (clk,rst, instr, result2, operand1, operand2, offset, opcode, sel1, sel3,w_r);
    //Defaults unless overwritten during instantiation
    parameter DATA_WIDTH = 8; //8 bit wide data
    parameter ADDR_BITS = 5; //32 Addresses
    parameter INSTR_WIDTH =20; 
    //INPUTS
    input clk,rst;
    input [INSTR_WIDTH-1:0]instr;
  	input [DATA_WIDTH-1:0] result2; //output of alu

    //OUTPUTS
    output reg [DATA_WIDTH-1:0] operand1;
    output reg [DATA_WIDTH-1:0] operand2;
    output reg [DATA_WIDTH-1:0] offset;
    output reg [3:0] opcode;
    output reg sel1, sel3, w_r;
  
  	//my way of trying to get EPWave to show, since EDA cant pass arrays into epwave like vivado
  	output reg [DATA_WIDTH-1:0] regfile_0; 
  	output reg [DATA_WIDTH-1:0] regfile_1; 
  	output reg [DATA_WIDTH-1:0] regfile_2; 
  	output reg [DATA_WIDTH-1:0] regfile_3; 

    //REGISTER FILE: CU internal register file of 4 registers.  This is a over simplication of a real solution
  	reg [DATA_WIDTH-1:0] regfile[0:3];
    reg [INSTR_WIDTH-1:0]instruction;
    
    //STATES
    parameter RESET = 4'b0000;
    parameter DECODE = 4'b0001;
    parameter EXECUTE = 4'b0010;
    parameter MEM_ACCESS = 4'b0100;
    parameter WRITE_BACK = 4'b1000;
        
    reg [3:0] state = RESET;
    
    
    always @(posedge clk) begin
        instruction = instr;
      //this will appear a lot.
      //assigns each element of the array to a output register so you can view the array
      regfile_0 <= regfile[0]; 
      regfile_1 <= regfile[1];
      regfile_2 <= regfile[2];  
      regfile_3 <= regfile[3]; 
        case (state)
            RESET : begin //#0
                if (instruction[19:18] == 2'b00)  begin
                    state = RESET; 
                    end else begin
                    state = DECODE; //#1
                    end
                //-----------------------------
                //Write initial values to regfile
                regfile[0]<= 8'd0;
                regfile[1]<= 8'd1;
              	regfile[2]<= 8'd2;
                regfile[3]<= 8'd3;

                //Set output reset defaults
                operand1 <= #(DATA_WIDTH)'d0;
                operand2 <= #(DATA_WIDTH)'d0;
                offset <= #(DATA_WIDTH)'d0;
                opcode <= 4'b1111;
                sel1 <= 0;
                sel3 <= 0;
                w_r <= 0;
                //-----------------------------
            end

            DECODE : begin //#1
                state = EXECUTE; //#2
                if (instruction[19:18] == 2'b1) begin //std_op
                    operand1 <= regfile[instruction[15:14]]; //X2
                    operand2 <= regfile[instruction[13:12]]; //X3
                    offset <= instruction[11:4];
                    opcode <= instruction[3:0];
                   sel1 <= 1;
                    sel3 <= 0;
                    w_r <= 0;
                  	//------------
                  	//assigns each element of the array to a output register so you can view the array
                 	regfile_0 = regfile[0]; 
      				regfile_1 = regfile[1];
      				regfile_2 = regfile[2];  
      				regfile_3 = regfile[3]; 
                  	//------------
                end else if (instruction[19:18] == 2'b10) begin //loadR 
                    operand1 <= regfile[instruction[15:14]]; //X2
                  	operand2 <= regfile[instruction[17:16]]; //z offset?
                    offset <= instruction[11:4];
                    opcode <= instruction[3:0];
                    sel1 <= 0; //pass data_out
                    sel3 <= 1; //pass offset
                    w_r <= 0;
                  	//------------
                  	//assigns each element of the array to a output register so you can view the array
                 	regfile_0 = regfile[0]; 
      				regfile_1 = regfile[1];
      				regfile_2 = regfile[2];  
      				regfile_3 = regfile[3]; 
                  	//------------ 
                end else if (instruction[19:18] == 2'b11) begin //storeR 
                   /******************************************** 
                   *
                   * FILL IN CORRECT CODE HERE
                   *
                   ********************************************/ 
                  	
                  	operand1 <= regfile[instruction[15:14]]; //X2
                    operand2 <= regfile[instruction[17:16]]; //z
                  	offset <= instruction[11:4];
                    opcode <= instruction[3:0];
                 	sel1 <= 1; //pass offset
                    sel3 <= 1; //pass offset
                    w_r <= 0; //wen
                  	//------------
                  	//assigns each element of the array to a output register so you can view the array
                 	regfile_0 = regfile[0]; 
      				regfile_1 = regfile[1];
      				regfile_2 = regfile[2];  
      				regfile_3 = regfile[3]; 
                  	//------------

                end
            end
            EXECUTE: begin //#2
                state = MEM_ACCESS; //#3
                if (instruction[19:18] == 2'b01) begin //std_op
                    state = WRITE_BACK;
                    operand1 <= regfile[instruction[15:14]]; //X2
                    operand2 <= regfile[instruction[13:12]]; //X3
                    offset <= instruction[11:4];
                    opcode <= instruction[3:0];
                    sel1 <= 1;
                    sel3 <= 0;
                    w_r <= 0; //wen?
                 	//------------
                  	//assigns each element of the array to a output register so you can view the array
                 	regfile_0 = regfile[0]; 
      				regfile_1 = regfile[1];
      				regfile_2 = regfile[2];  
      				regfile_3 = regfile[3]; 
                  	//------------

                end else if (instruction[19:18] == 2'b10) begin //loadR  
                  operand1 <= regfile[instruction[15:14]]; //X2 (offset?)
                  operand2 <= regfile[instruction[17:16]]; //z 17:16 will be outfile
                    offset <= instruction[11:4];
                    opcode <= instruction[3:0];
                    sel1 <= 0; //pass data_out
                    sel3 <= 1; //pass offset
                    w_r <= 0; //wen
                 	//------------
                  	//assigns each element of the array to a output register so you can view the array
                 	regfile_0 = regfile[0]; 
      				regfile_1 = regfile[1];
      				regfile_2 = regfile[2];  
      				regfile_3 = regfile[3]; 
                  	//------------ 
                end else if (instruction[19:18] == 2'b11) begin //storeR
                   /******************************************** 
                   *
                   * FILL IN CORRECT CODE HERE
                   *
                   ********************************************/ 
                  	
                  	operand1 <= regfile[instruction[15:14]]; //X2
                    operand2 <= regfile[instruction[17:16]]; //z
                  	offset <= instruction[11:4];
                    opcode <= instruction[3:0];
                  	sel1 <= 1; //pass offset
                    sel3 <= 1; //pass offset
                    w_r <= 0; //wen
                 	//------------
                  	//assigns each element of the array to a output register so you can view the array
                 	regfile_0 = regfile[0]; 
      				regfile_1 = regfile[1];
      				regfile_2 = regfile[2];  
      				regfile_3 = regfile[3]; 
                  	//------------ 
                end
            end
            MEM_ACCESS: begin //#3
                state = WRITE_BACK; //#4
                if (instruction[19:18] == 2'b10) begin //loadR             
                    operand1 <= regfile[instruction[15:14]]; //X2
                    operand2 <= regfile[instruction[17:16]]; //z
                    offset <= instruction[11:4];
                    opcode <= instruction[3:0];
                    sel1 <= 0; //pass data_out
                    sel3 <= 1; //pass offset
                    w_r <= 0; //wen
                 	//------------
                  	//assigns each element of the array to a output register so you can view the array
                 	regfile_0 = regfile[0]; 
      				regfile_1 = regfile[1];
      				regfile_2 = regfile[2];  
      				regfile_3 = regfile[3]; 
                  	//------------ 
                end else if (instruction[19:18] == 2'b11) begin //storeR 
                   /******************************************** 
                   *
                   * FILL IN CORRECT CODE HERE
                   * Take note of what the next state should be according to
                   * the FSM
                   *
                   ********************************************/ 
                  	state = DECODE; //state switch for '11
                  	operand1 <= regfile[instruction[15:14]]; //X2
                    operand2 <= regfile[instruction[17:16]]; //z
                  	offset <= instruction[11:4];
                    opcode <= instruction[3:0];
                  	sel1 <= 1; //pass offset
                    sel3 <= 0; //pass offset
                    w_r <= 1; //wen
                 	//------------
                  	//assigns each element of the array to a output register so you can view the array
                 	regfile_0 = regfile[0]; 
      				regfile_1 = regfile[1];
      				regfile_2 = regfile[2];  
      				regfile_3 = regfile[3]; 
                  	//------------ 
                end
            end
            WRITE_BACK: begin //#4
                state = DECODE; //#1
                if (instruction[19:18] == 2'b01) begin //std_op
                    regfile[instruction[17:16]] <= result2; //X1
                    operand1 <= regfile[instruction[15:14]]; //X2
                    operand2 <= regfile[instruction[13:12]]; //X3
                    offset <= instruction[11:4];
                    opcode <= instruction[3:0];
                    sel1 <= 1; //pass result
                    sel3 <= 0; //pass operand2
                    w_r <= 0; //wen
                 	//------------
                  	//assigns each element of the array to a output register so you can view the array
                 	regfile_0 = regfile[0]; 
      				regfile_1 = regfile[1];
      				regfile_2 = regfile[2];  
      				regfile_3 = regfile[3]; 
                  	//------------
                end else if (instruction[19:18] == 2'b11) begin //storeR 
                   /******************************************** 
                   *
                   * FILL IN CORRECT CODE HERE
                   * technically this isnt supposed to be here, never runs.
                   * still made it anyway since you said i have to.
                   ********************************************/ 
                  	operand1 <= regfile[instruction[15:14]]; //X2
                    operand2 <= regfile[instruction[17:16]]; //z
                  	offset <= instruction[11:4];
                    opcode <= instruction[3:0];
                  	sel1 <= 1; //pass result
                    sel3 <= 1; //pass offset
                    w_r <= 1; //wen
                 	//------------
                  	//assigns each element of the array to a output register so you can view the array
                 	regfile_0 = regfile[0]; 
      				regfile_1 = regfile[1];
      				regfile_2 = regfile[2];  
      				regfile_3 = regfile[3]; 
                  	//------------
                  
                end else if (instruction[19:18] == 2'b10) begin //loadR
                    regfile[instruction[17:16]] <= result2; //From data mem
                    operand1 <= regfile[instruction[15:14]]; //X2
                    operand2 <= regfile[instruction[17:16]]; //z
                    offset <= instruction[11:4];
                    opcode <= instruction[3:0];
                    sel1 <= 0; //pass data_out
                    sel3 <= 1; //pass offset
                    w_r <= 0; //wen
                  	//------------
                  	//assigns each element of the array to a output register so you can view the array
                 	regfile_0 = regfile[0]; 
      				regfile_1 = regfile[1];
      				regfile_2 = regfile[2];  
      				regfile_3 = regfile[3]; 
                  	//------------
                end
            end

            default: // Fault Recovery
            state = RESET; //#0
        endcase
    end
endmodule

//******************* Register Memory *********************
module reg_mem (addr, data_in, wen, clk, data_out);

    parameter DATA_WIDTH = 8; //8 bit wide data
    parameter ADDR_BITS = 5; //32 Addresses

    input [ADDR_BITS-1:0] addr;
    input [DATA_WIDTH-1:0] data_in;
    input wen;
    input clk;
    output [DATA_WIDTH-1:0] data_out;

    reg [DATA_WIDTH-1:0] data_out;

    //8 memory locations each storing a 4bits wide value
    reg [DATA_WIDTH-1:0] mem_array [(2**ADDR_BITS)-1:0];

    always @(posedge clk) begin

        if (wen) begin //Write
            mem_array [addr] <= data_in;
            data_out <= #(DATA_WIDTH)'b0;
        end

        else begin //Read
            data_out <= mem_array[addr];
        end
    end

endmodule


//******************* Simple CPU (TOP) *********************
module simple_cpu( clk, rst, instruction );

    parameter DATA_WIDTH = 8; //8 bit wide data
    parameter ADDR_BITS = 5; //32 Addresses
    parameter INSTR_WIDTH =20; //20b instruction

    input [INSTR_WIDTH-1:0] instruction;
    input clk, rst;

    //Wires for connecting to data memory    
  wire [ADDR_BITS-1:0] addr_i; //not assigned?
    wire [DATA_WIDTH-1:0] data_in_i, data_out_i, result2_i ;
    wire wen_i; 
    
    //wire for connecting to the ALU
    wire [DATA_WIDTH-1:0]operand_a_i, operand_b_i, result1_i;
    wire [3:0]opcode_i;
    
   
    //Wire for connecting to CU
    wire [DATA_WIDTH-1:0]offset_i;
    wire sel1_i, sel3_i;
    wire [DATA_WIDTH-1:0] operand_1_i, operand_2_i;

    //wire [DATA_WIDTH-1:0] regfile_i [0:3];
    
    //Instantiating an alu1
    alu #(DATA_WIDTH) alu1 (clk, operand_a_i, operand_b_i, opcode_i, result1_i);
     
    //instantiation of data memory
    reg_mem  #(DATA_WIDTH,ADDR_BITS) data_memory(result1_i, data_in_i, wen_i, clk, data_out_i);
    
    //Instantiation of a CU
    CU  #(DATA_WIDTH,ADDR_BITS, INSTR_WIDTH) CU1(clk, rst, instruction, result2_i,
        operand_1_i, operand_2_i, offset_i, opcode_i, sel1_i, sel3_i, wen_i);
    
	/*my pesonal notes:
  		result1 is the address in memory to fetch/write to
        data_in is what to write to that address if wen=1
  	*/
    
    //Connect CU to ALU
    assign operand_a_i = operand_1_i;
    assign operand_b_i = (sel3_i == 0) ? operand_2_i: (sel3_i == 1) ? offset_i : 8'bx;
    
    //Connect CU to Memory
    assign data_in_i = operand_2_i;
  	assign addr_i=result1_i;
    
    //Connect datamem to CU
    assign result2_i = (sel1_i == 0) ? data_out_i : (sel1_i == 1) ? result1_i : 8'bx;  
    
endmodule