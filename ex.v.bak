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
// Module:  ex
// File:    ex.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 执行阶段
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module ex(

	input wire					 rst,//复位信号
	
	//送到执行阶段的信息
	input wire[`AluOpBus]         aluop_i,//执行阶段要进行的运算的类型
	input wire[`AluSelBus]        alusel_i,//执行阶段要进行的运算的子类型
	input wire[`RegBus]           reg1_i,//参与运算的源操作数1
	input wire[`RegBus]           reg2_i,//参与运算的源操作数2
	input wire[`RegAddrBus]       wd_i,//写入的寄存器地址
	input wire                    wreg_i,//写使能 有没有


	//是否转移、以及link address
	input wire[`RegBus]           link_address_i,//处于执行阶段的转移指令要保存的返回地址
	input wire                    is_in_delayslot_i,//当前处于执行阶段的指令是否位于延迟槽
	//执行的结果
	output reg[`RegAddrBus]       wd_o,
	output reg                    wreg_o,
	output reg[`RegBus]			  wdata_o,
		
	
);

	reg[`RegBus] logicout;//保存逻辑运算的结果
	reg[`RegBus] shiftres;//移位操作的结果
	reg[`RegBus] arithmeticres;//保存算术运算的结果
	wire[`RegBus] reg2_i_mux;//保存输入的第二个操作数reg2_i的补码 
	 //如果是减法或者有符号比较运算，那么reg2_i_mux等于第二个操作数reg2_i的补码，否则就等于第二个操作数
	wire[`RegBus] reg1_i_not;	//保存输入的第一个操作数reg1_i取反后的值
	wire[`RegBus] result_sum;	//保存加法结果
	wire ov_sum;//保存溢出的情况
	wire reg1_eq_reg2;//第一个操作数是否等于第二个操作数
	wire reg1_lt_reg2;//第一个操作数是否小于第二个操作数

			
	always @ (*) begin
		if(rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_i)//哪种运算
				`EXE_OR_OP:			begin//或
					logicout <= reg1_i | reg2_i;
				end
				`EXE_AND_OP:		begin//与
					logicout <= reg1_i & reg2_i;
				end
				`EXE_NOR_OP:		begin//或非
					logicout <= ~(reg1_i |reg2_i);
				end
				`EXE_XOR_OP:		begin//异或
					logicout <= reg1_i ^ reg2_i;
				end
				default:			begin
					logicout <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always

	always @ (*) begin
		if(rst == `RstEnable) begin
			shiftres <= `ZeroWord;
		end else begin
			case (aluop_i)//细的指令  这里是移位
				`EXE_SLL_OP:			begin //逻辑左移
					shiftres <= reg2_i << reg1_i[4:0] ;
				end
				`EXE_SRL_OP:		begin	//逻辑右移
					shiftres <= reg2_i >> reg1_i[4:0];
				end
				`EXE_SRA_OP:		begin	//算术右移 可能要思量一下这里的操作
					shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
				end
				default:				begin
					shiftres <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always

	assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) ||(aluop_i == `EXE_SLT_OP) ) 
	? (~reg2_i)+1 : reg2_i;  //如果是减法或者有符号比较运算，那么reg2_i_mux等于第二个操作数reg2_i的补码，否则就等于第二个操作数

	assign result_sum = reg1_i + reg2_i_mux;		//reg1_i参与运行的源操作数								 
	//分三种情况
	//A 如果是加法运算，此时reg2_i_mux就是第二个操作数reg2_i
	//	所以此时result_sum就是加法运算的结果
	//B 如果是减法运算，此时reg2_i_mux就是第二个操作数reg2_i的补码
	//	所以是减法运算的结果
	//C	如果是有符号比较运算，此时reg2_i_mux也是第二个操作数reg2_i的补码，所以result是减法运算的结果，
	//	可以通过判断减法的结果是否小于零，进而判断第一个操作数是否小于第二个操作数

	assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||
	((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));  
	//计算是否溢出，加法指令（add和addi）。减法指令（sub）执行的时候
	// 需要判断是否溢出，满足以下两种情况之一时，有溢出
	// A reg1_i为正数，reg2_i_mux时正数，但两者之和为负数
	// B reg1_i为负数，reg2_i_mus是负数，但两者之和为正数

	assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)) ?
	((reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && result_sum[31])||(reg1_i[31] && reg2_i[31] && result_sum[31]))
	:(reg1_i < reg2_i);
	//计算操作数1是否小于操作数2，分两种情况：
	//	A.aluop_i为EXE_SLT_OP表示有符号比较运算，此时又分三种情况
	//		1.reg1_i为负数，reg2_i为正数，显然reg1_i小于reg2_i
	//		2.reg1_i为正数，reg2_i为正数，并且reg1_i减去reg2_i的值小于0
	//		此时也有reg1_i小于reg2_i	
	//		3.reg1_i为负数，reg2_i为负数，并且reg1_i减去reg2_i的值小于0
	//		此时也有reg1_i小于reg2_i
	//	B.无符号数比较的时候 直接使用比较运算符 
  assign reg1_i_not = ~reg1_i;
	// 对操作数1逐位取反，赋给reg1_i_not /保存输入的第一个操作数reg1_i取反后的值
	always @ (*) begin
		if(rst == `RstEnable) begin
			arithmeticres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLT_OP, `EXE_SLTU_OP:		begin	//比较运算
					arithmeticres <= reg1_lt_reg2 ;
				end
				`EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:		begin	//加法运算
					arithmeticres <= result_sum; 
				end
				`EXE_SUB_OP, `EXE_SUBU_OP:		begin//减法运算
					arithmeticres <= result_sum; 
				end		
				default:				begin
					arithmeticres <= `ZeroWord;
				end
			endcase
		end
	end




//这里涉及到溢出，老师说好像不用考虑溢出的情况
//  always @ (*) begin
// 	 wd_o <= wd_i;
// 	 if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || 
// 	      (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
// 	 	wreg_o <= `WriteDisable;
// 	 end else begin
// 	  wreg_o <= wreg_i;
// 	 end
	 
	 case ( alusel_i ) 
	 	`EXE_RES_LOGIC:		begin//逻辑运算
	 		wdata_o <= logicout;
	 	end
	 	`EXE_RES_SHIFT:		begin//移位运算
	 		wdata_o <= shiftres;
	 	end	 	
	 	`EXE_RES_ARITHMETIC:	begin
	 		wdata_o <= arithmeticres;
	 	end
	 	`EXE_RES_JUMP_BRANCH:	begin
	 		wdata_o <= link_address_i;
	 	end	 	
	 	default:					begin
	 		wdata_o <= `ZeroWord;
	 	end
	 endcase
 end	


endmodule