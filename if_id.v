//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  if_id
// File:    if_id.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: IF/ID阶段的寄存器
// Revision: 1.0
//////////////////////////////////////////////////////////////////////
//暂时保存取指阶段取得的指令，以及对应的指令地址，并在下一个时钟传递到译码阶段
`include "defines.v"

module if_id(

	input wire										clk,//时钟信号
	input wire										rst,//复位信号

	//来自控制模块的信息
	input wire[5:0]               stall,	

	input wire[`InstAddrBus]	  if_pc,//InstAddrBus ROm的地址线宽度 32 instruction fecture 取指阶段指令对应的地址
	input wire[`InstBus]          if_inst,//Rom的地址线宽度 32 取值阶段取得的指令
	output reg[`InstAddrBus]      id_pc,//instruction decode 阶段的指令对应的地址
	output reg[`InstBus]          id_inst  //译码阶段的指令 
	
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin //再时钟上升沿如果是复位 就送空指令 
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end else if(stall[1] == `Stop && stall[2] == `NoStop) begin
			id_pc <= `ZeroWord;//或者流水线的暂停
			id_inst <= `ZeroWord;	
	  end else if(stall[1] == `NoStop) begin
		  id_pc <= if_pc;
		  id_inst <= if_inst;
		end
	end

endmodule