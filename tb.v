`timescale 1ns / 1ps

//******************* TestBench *********************
module tb_simple_CPU;
       
    parameter DATA_WIDTH = 8; //8 bit wide data
    parameter ADDR_BITS = 5; //32 Addresses
    parameter INSTR_WIDTH =20; //20b instruction
   
    reg clk, rst;
    reg [INSTR_WIDTH-1:0] instruction;

    
    simple_cpu  #(DATA_WIDTH,ADDR_BITS,INSTR_WIDTH) SCPU_DUT(clk, rst, instruction);
    
    initial begin
      	$dumpfile("dump.vcd");
      $dumpvars(0, tb_simple_CPU);
      	
        clk = 1'b1;
        rst = 1'b1;
        instruction = 20'd0;
        repeat(3) #1 clk=!clk;
        rst = 1'b0;
        repeat(2) #1 clk=!clk;
                
      	
                
        /*Info on the simple CPU:
            * Reset sets regfile = [0,1,2,3]
            * ADD = opcode 0, SUB = opcode 1  
        */
            
                                        //ADD:    reg0  = reg1 + reg3   //1+3=4
        //In the instruction this is:    (instr)  (X1)    (X2)   (X3)  
      instruction = 20'b01000111000000000000;
      	
      
      repeat(8) #1 clk=!clk; //4 rising edges
        
                                        //ADD:    reg1  = reg0 + reg3   //4+3=7
        //In the instruction this is:    (instr)  (X1)    (X2)   (X3)
      instruction = 20'b01010011000000000000;
      
      
      repeat(6) #1 clk=!clk; 
                
                                         //SUB:   reg3  = reg0 - reg2  //4-2=2  
       //In the instruction this is:    (instr)  (X1)    (X2)   (X3) 
      instruction = 20'b01110010000000000001;
      
      
      repeat(6) #1 clk=!clk;
        
                                         //STORE_R:   DATA_MEM(reg2 + 15) = reg1  //DATA_MEM(2+15)=7  
        //In the instruction this is:    (instr)               (X2)         (X1)
      instruction = 20'b11011000000011110000;
      
      
      repeat(6) #1 clk=!clk;
        
      									 //STORE_R:   DATA_MEM(reg3 + 22) = reg0  //DATA_MEM(2+22)= 4
        //In the instruction this is:    (instr)                 (X2)         (X1)
        instruction = 20'b11001100000101100000;

      repeat(6) #1 clk=!clk;

                                           //LOAD_R:   DATA_MEM(reg2 + 15) = reg3  //reg3 = DATA_MEM(2+15)  -> reg3 becomes 7  
        //In the instruction this is:    (instr)                (X2)         (X1)
      instruction = 20'b10111000000011110000;
      
      repeat(8) #1 clk=!clk;
       				
      
      //********* added LOAD and STORE instructions *********
      
      //store reg0 (4) at address 8(reg1+offset of 1)
      // ie store 4
      $display("custom: store 4 in memory address 8");  
      instruction = 20'b11000100000000010000;
      repeat(6) #1 clk=!clk; //6 for store
      
      //load reg2 (2) with address 8(reg1+offset of 1) = 4
      //ie load 4 into reg2 (regfile_2[7:0])
      $display("custom: load 4 into register 2");  
      instruction = 20'b10100100000000010000;
      repeat(8) #1 clk=!clk;//8 for load
      //tested and works, becomes 4747
      
      
      
      repeat(3) #1 clk=!clk;//1 extra clock cycle needed for regfile_X to update on EPwave 
      //because a recase need to be reached for regfiles to load on EPwave
      //so a repeat of 2 is needed, the 3 is to turn clock off after.

      
    end
    
    
endmodule