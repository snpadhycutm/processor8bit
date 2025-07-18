`timescale 1ns / 1ps
// Code your design here

//program counter-------------------------------------------

module program_counter(
  input clk,
  input rst,
  input [3:0] pc_addr_in,
  output reg [3:0] pc_addr_out
);
  
  always @ (posedge clk or posedge rst)
    begin
      if(rst)
        pc_addr_out <= 4'b0;
      else
        pc_addr_out <= pc_addr_in;
    end
  
endmodule

//instruction memory-----------------------------------------

module instruction_memory(
  input [3:0] addr_in,
  output reg [7:0] instruction
);
  
  reg [7:0] memory [0:15];
  
  initial
    begin
      memory[0] = 8'hAB;
      memory[1] = 8'hDE;
      memory[2] = 8'h3C;
      memory[3] = 8'hD6;
      memory[4] = 8'hBC;
      memory[5] = 8'hCD;
      memory[6] = 8'hAE;
      memory[7] = 8'hA1;
      memory[8] = 8'hB2;
      memory[9] = 8'hD4;
      memory[10] = 8'hE5;
      memory[11] = 8'hF6;
      memory[12] = 8'hAF;
      memory[13] = 8'hEF;
      memory[14] = 8'h67;
      memory[15] = 8'h88;
    end
  
  always @ (*) instruction = memory[addr_in];
  
endmodule

//Control unit----------------------------------------------

module control_unit(
  input [1:0] opcode,
  output reg reg_write,
  output reg pc_src,
  output reg [2:0] alu_op
);
  
  
  always @ (*)
    begin
      reg_write =0;
      pc_src = 0;
      alu_op = 3'b000;
      case(opcode)
        2'b00 : begin
                  reg_write = 1;   // write in register file
                  alu_op = 3'b001; // Addition op
                end
        2'b01 : begin
                  reg_write = 1; // write in register file
          		  alu_op = 3'b010;// AND op
        		end
        2'b10 : begin
                  reg_write = 1;// write in register file
          		  alu_op = 3'b011; // OR op
        		end
        2'b11 : begin
                  pc_src = 1;// Jump op        		 
        		end
      endcase
    end
  
endmodule

//resister file----------------------------------------------------

module register_file(
  input clk,
  input reg_write,
  input [1:0] source_reg1,
  input [1:0] source_reg2,
  input [1:0] destinition_reg,
  input [7:0] write_data,
  output  [7:0] data_out_source_reg1,
  output  [7:0] data_out_source_reg2
);
  
  reg [7:0] memory [0:3];
  
  initial
    begin
      memory[0] = 8'haa;
      memory[1] = 8'h1a;
      memory[2] = 8'h33;
      memory[3] = 8'hdd;

    end
  
     assign data_out_source_reg1 = memory[source_reg1];
     assign data_out_source_reg2 = memory[source_reg2];

  always @ (posedge clk)
    begin
      if(reg_write)
        memory[destinition_reg] <= write_data;
    end
  
endmodule

// 8 bit ALU-----------------------------------------------------

module arithmatic_logical_unit(
  input [7:0] alu_in1,
  input [7:0] alu_in2,
  input [2:0] alu_op,
  output reg [7:0] alu_out
);
  
  always @ (*)
    begin
      case(alu_op)
        3'b001 : alu_out = alu_in1 + alu_in2; // addition
        3'b010 : alu_out = alu_in1 & alu_in2; // bitwise and
        3'b011 : alu_out = alu_in1 | alu_in2; // bitwise and
        default: alu_out = 8'b0;
      endcase
    end
  
endmodule


//processor module-----------------------------------------------------

module processor(
  input clk,
  input rst,
  output [3:0] addr_out,
  output [7:0] instruction,
  output [1:0] opcode,
  output       reg_write,
  output       pc_src,
  output [2:0] alu_op,
  output [7:0] data_out_source_reg1,
  output [7:0] data_out_source_reg2,
  output [7:0] alu_out
);
  
  wire [3:0] addr_in;
  wire [1:0] source_reg1,source_reg2,destinition_reg;
  
  program_counter pc (clk,rst,addr_in,addr_out); // program counter
  instruction_memory im (addr_out,instruction);
  assign opcode = instruction[7:6];
  assign source_reg1 = instruction[5:4];
  assign source_reg2 = instruction[3:2];
  assign destinition_reg = instruction[1:0];
  
  control_unit cu (opcode,reg_write,pc_src,alu_op); // control_unit
  register_file rf (clk, reg_write,source_reg1,source_reg2,destinition_reg,alu_out,data_out_source_reg1,data_out_source_reg2); // resister file
  
  arithmatic_logical_unit alu (data_out_source_reg1,data_out_source_reg2,alu_op,alu_out); // 8 bit alu
  
 assign addr_in = (pc_src) ? 4'b000 : addr_out + 1;
endmodule

//top module---------------------------------------------------------------------------------------------------

module tt_um_myprocessor (
    input  wire clk,              // Clock from Tiny Tapeout
    input  wire rst_n, 
    input wire ena,// Active-low reset
    input  wire [7:0] ui_in,  
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,
    output wire [7:0] uo_out, 
    output wire [7:0] uio_oe // 8-bit output
    );

    // Internal connections to your processor
    wire [3:0] addr_out;
    wire [7:0] instruction;
    wire [1:0] opcode;
    wire       reg_write;
    wire       pc_src;
    wire [2:0] alu_op;
    wire [7:0] data_out_source_reg1;
    wire [7:0] data_out_source_reg2;
    wire [7:0] alu_out;

    // Instantiate your processor
    processor cpu (clk,rst_n,addr_out,instruction,opcode,reg_write,pc_src,alu_op,data_out_source_reg1,data_out_source_reg2,alu_out);

    // Choose what to output (here we show ALU result)
    assign uo_out = alu_out;
    assign uio_out  = 8'b00000000; // Not used
    assign uio_oe   = 8'b00000000; // All inputs
  // wire _unused = &{uio_oe,uio_ot,uio_in,ui_in,1'b0};

endmodule


