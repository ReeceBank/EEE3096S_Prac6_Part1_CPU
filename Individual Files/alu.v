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
