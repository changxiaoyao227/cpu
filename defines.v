//全局
`define RstEnable 1'b1  //复位信号有效
`define RstDisable 1'b0 //复位信号无效
`define ZeroWord 32'h00000000   //32位的数值0
`define WriteEnable 1'b1    //使能写
`define WriteDisable 1'b0   //禁止写
`define ReadEnable 1'b1     //使能读
`define ReadDisable 1'b0    //禁止读
`define AluOpBus 7:0    //译码阶段输出aluop_o的宽度
`define AluSelBus 2:0   //译码阶段输出alusel_o的宽度
`define InstValid 1'b0  //指令有效
`define InstInvalid 1'b1    //指令无效
`define Stop 1'b1   //
`define NoStop 1'b0    
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0
`define Branch 1'b1
`define NotBranch 1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0
`define True_v 1'b1     //逻辑真
`define False_v 1'b0    //逻辑假
`define ChipEnable 1'b1 //芯片使能
`define ChipDisable 1'b0    //芯片禁止


//逻辑指令
`define EXE_AND  6'b100100  //指令and的指令码
`define EXE_OR   6'b100101  //指令or的指令码
`define EXE_XOR 6'b100110   //指令xor
`define EXE_NOR 6'b100111   //指令nor
`define EXE_ANDI 6'b001100  //指令andi  i型
`define EXE_ORI  6'b001101  //指令ori   i型
`define EXE_XORI 6'b001110  //指令xori  i型
`define EXE_LUI 6'b001111   //指令lui   i型
//移位指令
`define EXE_SLL  6'b000000  //指令sll 
`define EXE_SLLV  6'b000100 //指令sllv 
`define EXE_SRL  6'b000010  //指令srl
`define EXE_SRLV  6'b000110 //指令srlv
`define EXE_SRA  6'b000011  //指令sra 
`define EXE_SRAV  6'b000111 //指令srav
//算术运算
`define EXE_SLT  6'b101010  //指令slt
`define EXE_SLTU  6'b101011 //指令sltu
`define EXE_SLTI  6'b001010 //指令slti    i
`define EXE_SLTIU  6'b001011//指令sltiu   i
`define EXE_ADD  6'b100000  //指令add
`define EXE_ADDU  6'b100001 //指令addu
`define EXE_SUB  6'b100010  //指令sub
`define EXE_SUBU  6'b100011 //指令subu
`define EXE_ADDI  6'b001000 //指令addi  i型
`define EXE_ADDIU  6'b001001//addiu  i


//转移指令
`define EXE_J  6'b000010    //j     j
`define EXE_JAL  6'b000011  //jal   j
`define EXE_JR  6'b001000   //jr    r
`define EXE_BEQ  6'b000100  //beq   i
`define EXE_BNE  6'b000101  //bne   i

`define EXE_NOP 6'b000000   //空指令
`define SSNOP 32'b00000000000000000000000001000000

`define EXE_SPECIAL_INST 6'b000000
`define EXE_REGIMM_INST 6'b000001


//AluOp 逻辑
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP  8'b00100110
`define EXE_NOR_OP  8'b00100111
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP  8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP  8'b01011100   
//移位
`define EXE_SLL_OP  8'b01111100
`define EXE_SLLV_OP  8'b00000100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRLV_OP  8'b00000110
`define EXE_SRA_OP  8'b00000011
`define EXE_SRAV_OP  8'b00000111
//算术
`define EXE_SLT_OP  8'b00101010
`define EXE_SLTU_OP  8'b00101011
`define EXE_SLTI_OP  8'b01010111
`define EXE_SLTIU_OP  8'b01011000   
`define EXE_ADD_OP  8'b00100000
`define EXE_ADDU_OP  8'b00100001
`define EXE_SUB_OP  8'b00100010
`define EXE_SUBU_OP  8'b00100011
`define EXE_ADDI_OP  8'b01010101
`define EXE_ADDIU_OP  8'b01010110
//转移
`define EXE_J_OP  8'b01001111
`define EXE_JAL_OP  8'b01010000
`define EXE_JR_OP  8'b00001000
`define EXE_BEQ_OP  8'b01010001
`define EXE_BNE_OP  8'b01010010

`define EXE_NOP_OP    8'b00000000

//AluSel
`define EXE_RES_LOGIC 3'b001
`define EXE_RES_SHIFT 3'b010

`define EXE_RES_ARITHMETIC 3'b100	

`define EXE_RES_JUMP_BRANCH 3'b110

`define EXE_RES_NOP 3'b000


//指令存储器inst_rom
`define InstAddrBus 31:0        //ROM的地址总线宽度
`define InstBus 31:0            //ROM的数据总线宽度
`define InstMemNum 131071       //ROM的实际大小为128KB
`define InstMemNumLog2 17       //ROM实际使用的地址线宽度


//通用寄存器regfile
`define RegAddrBus 4:0          //regfile模块的地址线宽度
`define RegBus 31:0             //regfile模块的数据线宽度
`define RegWidth 32             //通用寄存器的宽度

`define RegNum 32               //通用寄存器的数量
`define RegNumLog2 5            //寻址通用寄存器使用的地址位数
`define NOPRegAddr 5'b00000     //

