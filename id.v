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
// Module:  id
// File:    id.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 译码阶段
// Revision: 1.0
//////////////////////////////////////////////////////////////////////
//译码阶段 给出要进行的运算类型，以及参与运算的操作数，有reg id id/ex
`include "defines.v"
//ID模块的作用是对指令进行译码，得到最终运算的类型，子类型，源操作数1，源操作数2
//要写入的目的寄存器地址等信息 其中的运算类型是指逻辑运算，移位运算，算术运算，等 子类型指的是更加详细的运算类型，
module id(

	input wire										rst,//复位信号
	input wire[`InstAddrBus]						pc_i, //指令的地址
	input wire[`InstBus]          					inst_i,//指令的值

	//处于执行阶段的指令要写入的目的寄存器信息
	input wire										ex_wreg_i,//
	input wire[`RegBus]								ex_wdata_i,
	input wire[`RegAddrBus]       					ex_wd_i,
	
	//处于访存阶段的指令要写入的目的寄存器信息
	input wire										mem_wreg_i,
	input wire[`RegBus]								mem_wdata_i,
	input wire[`RegAddrBus]       					mem_wd_i,
	
	input wire[`RegBus]           					reg1_data_i,//读取的regfile的值
	input wire[`RegBus]           					reg2_data_i,

	//如果上一条指令是转移指令，那么下一条指令在译码的时候is_in_delayslot为true
	input wire                    is_in_delayslot_i,

	//送到regfile的信息
	output reg                    reg1_read_o,//regfile模块的第一个读寄存器的  使能信号
	output reg                    reg2_read_o,//第二个读寄存器的使能信号     
	output reg[`RegAddrBus]       reg1_addr_o,//第一个读寄存器的地址 4：0
	output reg[`RegAddrBus]       reg2_addr_o,//第二个读寄存器的地址 4：0
	
	//送到执行阶段的信息
	output reg[`AluOpBus]         aluop_o,//指令要进行的运算的子类型 7：0
	output reg[`AluSelBus]        alusel_o,//指令要进行的运算的类型 2：0 类型={子类型1+子类型2}
	output reg[`RegBus]           reg1_o,//译码阶段要进行的运算的操作数1 31：0
	output reg[`RegBus]           reg2_o,//译码阶段要进行的操作数2
	output reg[`RegAddrBus]       wd_o,//译码阶段要写入的目的寄存器地址 4：0
	output reg                    wreg_o,//译码阶段是否有要写入的目的寄存器

	output reg                    next_inst_in_delayslot_o,
	
	output reg                    branch_flag_o,
	output reg[`RegBus]           branch_target_address_o,       
	output reg[`RegBus]           link_addr_o,
	output reg                    is_in_delayslot_o,
	
	output wire                   stallreq	
);
//取得指令的指令码，功能码，

  wire[5:0] op = inst_i[31:26];
  wire[4:0] op2 = inst_i[10:6];
  wire[5:0] op3 = inst_i[5:0];
  wire[4:0] op4 = inst_i[20:16];
  reg[`RegBus]	imm; //保存指令执行需要的立即数
  reg instvalid;//指示指令是否有效
  wire[`RegBus] pc_plus_8;
  wire[`RegBus] pc_plus_4;
  wire[`RegBus] imm_sll2_signedext;  
  
  assign pc_plus_8 = pc_i + 8;
  assign pc_plus_4 = pc_i +4;
  assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00 };  
  assign stallreq = `NoStop;
  // 
	always @ (*) begin	
		if (rst == `RstEnable) begin
			aluop_o <= `EXE_NOP_OP;//空指令 6个0
			alusel_o <= `EXE_RES_NOP;//3个比特的0
			wd_o <= `NOPRegAddr;//5个0
			wreg_o <= `WriteDisable;//不用写回
			instvalid <= `InstValid;//0 指令有效
			reg1_read_o <= 1'b0;//操作数1 为0
			reg2_read_o <= 1'b0;//操作数2 为0
			reg1_addr_o <= `NOPRegAddr;//5个0
			reg2_addr_o <= `NOPRegAddr;//5个0
			imm <= 32'h0;	//立即数为0
			link_addr_o <= `ZeroWord; //
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
			next_inst_in_delayslot_o <= `NotInDelaySlot;					
	  		end 
		else begin
			aluop_o <= `EXE_NOP_OP;	//空指令 6个0
			alusel_o <= `EXE_RES_NOP;//3个比特的0
			wd_o <= inst_i[15:11];//要写入的目标的寄存器的地址 5为 0~32可能 
			wreg_o <= `WriteDisable;//禁止写？译码阶段不要写入/? 那你给地址肝啥
			instvalid <= `InstInvalid;// 为1 指令无效
			reg1_read_o <= 1'b0;//数据为0
			reg2_read_o <= 1'b0;//数据为0
			reg1_addr_o <= inst_i[25:21];//标准的R型指令
			reg2_addr_o <= inst_i[20:16];//标准的R型指令
			imm <= `ZeroWord;//立即数为0
			link_addr_o <= `ZeroWord;//
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;	
			next_inst_in_delayslot_o <= `NotInDelaySlot; 			
		  case (op)//inst_i中的头部6位  都是000000 R型  
		    `EXE_SPECIAL_INST:	//000000 R型啦	
			begin
		    	case (op2)		//10：6那里 shanmt rd后面的部分
		    		5'b00000:			
					begin
		    			case (op3) //5:0那里 每个都不一样！ 赞 
		    				`EXE_OR:	begin //or func为 100101 or $1,$2,$3 $1=$2|$3  
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;//8'b00100101 
		  						alusel_o <= `EXE_RES_LOGIC; 	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	//0 有效  属于逻辑运算
								end  
		    				`EXE_AND:	begin//and func为100100 and $1,$2,$3 $1=$2&$3
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_AND_OP;//8'd8'b00100100
		  						alusel_o <= `EXE_RES_LOGIC;	  reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	//也是逻辑运算
								end  	
		    				`EXE_XOR:	begin//xor func为100110 xor $1,$2,$3 $1=$2^$3 
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_XOR_OP;// 8'b00100110
		  						alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end  				
		    				`EXE_NOR:	begin//nor func是100111 nor $1,$2,$3 $1=~($2|$3) 
		    					wreg_o <= `WriteEnable;		aluop_o <= `EXE_NOR_OP;//8'b00100111
		  						alusel_o <= `EXE_RES_LOGIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
								end 
							`EXE_SLLV: begin//sllv func为000100 sllv $1,$2,$3 $1=$2<<$3 
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLL_OP;//8'b00000100
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	//移位运算
								end 
							`EXE_SRLV: begin//srlv func为000110 srlv $1,$2,$3 $1=$2>>$3 逻辑右移
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRL_OP;//8'b00000110
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	//移位运算
								end 					
							`EXE_SRAV: begin //srlv func为000111 srav $1,$2,$3 $1=$2>>$3 算数右移 保留符号位 
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRA_OP;//8'b00000111
		  						alusel_o <= `EXE_RES_SHIFT;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	//移位运算		
		  					end
							`EXE_MFHI: begin//
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_MFHI_OP;
		  						alusel_o <= `EXE_RES_MOVE;   reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
		  						instvalid <= `InstValid;	
								end
								`EXE_MFLO: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_MFLO_OP;
		  						alusel_o <= `EXE_RES_MOVE;   reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
		  						instvalid <= `InstValid;	
								end
								`EXE_MTHI: begin
									wreg_o <= `WriteDisable;		aluop_o <= `EXE_MTHI_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0; instvalid <= `InstValid;	
								end
								`EXE_MTLO: begin
									wreg_o <= `WriteDisable;		aluop_o <= `EXE_MTLO_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0; instvalid <= `InstValid;	
								end
								`EXE_MOVN: begin
									aluop_o <= `EXE_MOVN_OP;
		  						alusel_o <= `EXE_RES_MOVE;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;
								 	if(reg2_o != `ZeroWord) begin
	 									wreg_o <= `WriteEnable;
	 								end else begin
	 									wreg_o <= `WriteDisable;
	 								end
								end
								`EXE_MOVZ: begin
									aluop_o <= `EXE_MOVZ_OP;
		  						alusel_o <= `EXE_RES_MOVE;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;
								 	if(reg2_o == `ZeroWord) begin
	 									wreg_o <= `WriteEnable;
	 								end else begin
	 									wreg_o <= `WriteDisable;
	 								end		  							
								end
								`EXE_SLT: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLT_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								`EXE_SLTU: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLTU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								`EXE_ADD: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADD_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								`EXE_ADDU: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADDU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								`EXE_SUB: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SUB_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								`EXE_SUBU: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_SUBU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
								end
								`EXE_MULT: begin
									wreg_o <= `WriteDisable;		aluop_o <= `EXE_MULT_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= `InstValid;	
								end
								`EXE_MULTU: begin
									wreg_o <= `WriteDisable;		aluop_o <= `EXE_MULTU_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= `InstValid;	
								end
								`EXE_DIV: begin
									wreg_o <= `WriteDisable;		aluop_o <= `EXE_DIV_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= `InstValid;	
								end
								`EXE_DIVU: begin
									wreg_o <= `WriteDisable;		aluop_o <= `EXE_DIVU_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= `InstValid;	
								end			
								`EXE_JR: begin
									wreg_o <= `WriteDisable;		aluop_o <= `EXE_JR_OP;
		  						alusel_o <= `EXE_RES_JUMP_BRANCH;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  						link_addr_o <= `ZeroWord;
		  						
			            	branch_target_address_o <= reg1_o;
			            	branch_flag_o <= `Branch;
			           
			            next_inst_in_delayslot_o <= `InDelaySlot;
			            instvalid <= `InstValid;	
								end
								`EXE_JALR: begin
									wreg_o <= `WriteEnable;		aluop_o <= `EXE_JALR_OP;
		  						alusel_o <= `EXE_RES_JUMP_BRANCH;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  						wd_o <= inst_i[15:11];
		  						link_addr_o <= pc_plus_8;
		  						
			            	branch_target_address_o <= reg1_o;
			            	branch_flag_o <= `Branch;
			           
			            next_inst_in_delayslot_o <= `InDelaySlot;
			            instvalid <= `InstValid;	
								end													 											  											
						    default:	begin
						    end
						  endcase
						 end
						default: begin
						end
					endcase	
					end									  
		  	`EXE_ORI:			begin                        //ORI指令
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  		alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];
					instvalid <= `InstValid;	
		  	end
		  	`EXE_ANDI:			begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_AND_OP;
		  		alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end	 	
		  	`EXE_XORI:			begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_XOR_OP;
		  		alusel_o <= `EXE_RES_LOGIC;	reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {16'h0, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end	 		
		  	`EXE_LUI:			begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  		alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {inst_i[15:0], 16'h0};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end			
				`EXE_SLTI:			begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLT_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end
				`EXE_SLTIU:			begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLTU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end
				`EXE_ADDI:			begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADDI_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end
				`EXE_ADDIU:			begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADDIU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end
				`EXE_J:			begin
		  		wreg_o <= `WriteDisable;		aluop_o <= `EXE_J_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
		  		link_addr_o <= `ZeroWord;
			    branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
			    branch_flag_o <= `Branch;
			    next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    instvalid <= `InstValid;	
				end
				`EXE_JAL:			begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_JAL_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b0;
		  		wd_o <= 5'b11111;	
		  		link_addr_o <= pc_plus_8 ;
			    branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
			    branch_flag_o <= `Branch;
			    next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    instvalid <= `InstValid;	
				end
				`EXE_BEQ:			begin
		  		wreg_o <= `WriteDisable;		aluop_o <= `EXE_BEQ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  		instvalid <= `InstValid;	
		  		if(reg1_o == reg2_o) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= `Branch;
			    	next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    end
				end
				`EXE_BGTZ:			begin
		  		wreg_o <= `WriteDisable;		aluop_o <= `EXE_BGTZ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  		instvalid <= `InstValid;	
		  		if((reg1_o[31] == 1'b0) && (reg1_o != `ZeroWord)) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= `Branch;
			    	next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    end
				end
				`EXE_BLEZ:			begin
		  		wreg_o <= `WriteDisable;		aluop_o <= `EXE_BLEZ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  		instvalid <= `InstValid;	
		  		if((reg1_o[31] == 1'b1) || (reg1_o == `ZeroWord)) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= `Branch;
			    	next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    end
				end
				`EXE_BNE:			begin
		  		wreg_o <= `WriteDisable;		aluop_o <= `EXE_BLEZ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  		instvalid <= `InstValid;	
		  		if(reg1_o != reg2_o) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= `Branch;
			    	next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    end
				end
				`EXE_REGIMM_INST:		begin
					case (op4)
						`EXE_BGEZ:	begin
							wreg_o <= `WriteDisable;		aluop_o <= `EXE_BGEZ_OP;
		  				alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  				instvalid <= `InstValid;	
		  				if(reg1_o[31] == 1'b0) begin
			    			branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    			branch_flag_o <= `Branch;
			    			next_inst_in_delayslot_o <= `InDelaySlot;		  	
			   			end
						end
						`EXE_BGEZAL:		begin
							wreg_o <= `WriteEnable;		aluop_o <= `EXE_BGEZAL_OP;
		  				alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  				link_addr_o <= pc_plus_8; 
		  				wd_o <= 5'b11111;  	instvalid <= `InstValid;
		  				if(reg1_o[31] == 1'b0) begin
			    			branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    			branch_flag_o <= `Branch;
			    			next_inst_in_delayslot_o <= `InDelaySlot;
			   			end
						end
						`EXE_BLTZ:		begin
						  wreg_o <= `WriteDisable;		aluop_o <= `EXE_BGEZAL_OP;
		  				alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  				instvalid <= `InstValid;	
		  				if(reg1_o[31] == 1'b1) begin
			    			branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    			branch_flag_o <= `Branch;
			    			next_inst_in_delayslot_o <= `InDelaySlot;		  	
			   			end
						end
						`EXE_BLTZAL:		begin
							wreg_o <= `WriteEnable;		aluop_o <= `EXE_BGEZAL_OP;
		  				alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;
		  				link_addr_o <= pc_plus_8;	
		  				wd_o <= 5'b11111; instvalid <= `InstValid;
		  				if(reg1_o[31] == 1'b1) begin
			    			branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    			branch_flag_o <= `Branch;
			    			next_inst_in_delayslot_o <= `InDelaySlot;
			   			end
						end
						default:	begin
						end
					endcase
				end								
				`EXE_SPECIAL2_INST:		begin
					case ( op3 )
						`EXE_CLZ:		begin
							wreg_o <= `WriteEnable;		aluop_o <= `EXE_CLZ_OP;
		  				alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
							instvalid <= `InstValid;	
						end
						`EXE_CLO:		begin
							wreg_o <= `WriteEnable;		aluop_o <= `EXE_CLO_OP;
		  				alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
							instvalid <= `InstValid;	
						end
						`EXE_MUL:		begin
							wreg_o <= `WriteEnable;		aluop_o <= `EXE_MUL_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  				instvalid <= `InstValid;	  			
						end
						`EXE_MADD:		begin
							wreg_o <= `WriteDisable;		aluop_o <= `EXE_MADD_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  			
		  				instvalid <= `InstValid;	
						end
						`EXE_MADDU:		begin
							wreg_o <= `WriteDisable;		aluop_o <= `EXE_MADDU_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  			
		  				instvalid <= `InstValid;	
						end
						`EXE_MSUB:		begin
							wreg_o <= `WriteDisable;		aluop_o <= `EXE_MSUB_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  			
		  				instvalid <= `InstValid;	
						end
						`EXE_MSUBU:		begin
							wreg_o <= `WriteDisable;		aluop_o <= `EXE_MSUBU_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  			
		  				instvalid <= `InstValid;	
						end						
						default:	begin
						end
					endcase      //EXE_SPECIAL_INST2 case
				end																		  	
		    default:			begin
		    end
		  endcase		  //case op
		  
		  if (inst_i[31:21] == 11'b00000000000) begin
		  	if (op3 == `EXE_SLL) begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SLL_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end else if ( op3 == `EXE_SRL ) begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRL_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end else if ( op3 == `EXE_SRA ) begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_SRA_OP;
		  		alusel_o <= `EXE_RES_SHIFT; reg1_read_o <= 1'b0;	reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end
			end		  
		  
		end       //if
	end         //always
	

	always @ (*) begin
		if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;		
		end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg1_addr_o)) begin
			reg1_o <= ex_wdata_i; 
		end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg1_addr_o)) begin
			reg1_o <= mem_wdata_i; 			
	  end else if(reg1_read_o == 1'b1) begin
	  	reg1_o <= reg1_data_i;
	  end else if(reg1_read_o == 1'b0) begin
	  	reg1_o <= imm;
	  end else begin
	    reg1_o <= `ZeroWord;
	  end
	end
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
		end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg2_addr_o)) begin
			reg2_o <= ex_wdata_i; 
		end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg2_addr_o)) begin
			reg2_o <= mem_wdata_i;			
	  end else if(reg2_read_o == 1'b1) begin
	  	reg2_o <= reg2_data_i;
	  end else if(reg2_read_o == 1'b0) begin
	  	reg2_o <= imm;
	  end else begin
	    reg2_o <= `ZeroWord;
	  end
	end

	always @ (*) begin
		if(rst == `RstEnable) begin
			is_in_delayslot_o <= `NotInDelaySlot;
		end else begin
		  is_in_delayslot_o <= is_in_delayslot_i;		
	  end
	end

endmodule