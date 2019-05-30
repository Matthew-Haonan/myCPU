`include "defines.v"
module id(
	input wire					rst,
	input wire[`InstAddrBus]	pc_i,
	input wire[`InstBus]		inst_i,
	
	//读取的Regfile的值
	input wire[`RegBus]			reg1_data_i,
	input wire[`RegBus]			reg2_data_i,
	
	//输出到Regfile的信息
	output reg 					reg1_read_o,
	output reg 					reg2_read_o,
	output reg[`RegAddrBus] 	reg1_addr_o,
	output reg[`RegAddrBus] 	reg2_addr_o,
	
	//送到执行阶段的信息
	output reg[`AluOpBus]		aluop_o,
	output reg[`AluSelBus]		alusel_o,
	output reg[`RegBus]			reg1_o,
	output reg[`RegBus]			reg2_o,
	output reg[`RegAddrBus]		wd_o,
	output reg					wreg_o			//是写使能吗？应该是，译码阶段的指令是否有要写入的目的寄存器
);
//取得指令码和功能码，此时只为ori指令
wire[5:0] op = inst_i[31:26];					//指令码的位置
wire[4:0] op2 = inst_i[10:6];					//
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];					//rt,运算结果保存的寄存器索引

//保存指令执行需要的立即数 ori一定有一个立即数
reg[`RegBus]	imm;

//指示指令是否有效
reg instvalid;

/*第一段：指令译码*/
always @ (*) begin
	if(rst == `RstEnable) begin
		aluop_o <= `EXE_NOP_OP;
		alusel_o <= `EXE_RES_NOP;
		wd_o 	<= `NOPRegAddr;
		wreg_o	<= `WriteDisable;
		instvalid <= `InstValid;					//？？？此时指令有效，why？
		reg1_read_o <= 1'b0;
		reg2_read_o <= 1'b0;
		reg1_addr_o <= `NOPRegAddr;
		reg2_addr_o <= `NOPRegAddr;
		imm			<= `ZeroWord;
	end else begin
		aluop_o <= `EXE_NOP_OP;
		alusel_o <= `EXE_RES_NOP;
		wd_o 	<= inst_i[15:11];				//个人理解，一般的指令15:11位是rd，所以默认wd_o的值是它
		wreg_o	<= `WriteDisable;
		instvalid <= `InstInvalid;					//此时指令无效，只是一个默认的开始吗？
		reg1_read_o <= 1'b0;
		reg2_read_o <= 1'b0;
		reg1_addr_o <= inst_i[25:21];
		reg2_addr_o <= inst_i[20:16];
		imm			<=`ZeroWord;
		
		case(op)
			`EXE_ORI:	begin					//如果op是ORI指令的操作码，就进行下面的操作
				wreg_o		<= `WriteEnable;		//ori指令需要将结果写入目的寄存器
				alusel_o	<= `EXE_RES_LOGIC;		//运算类型是逻辑运算
				aluop_o 	<= `EXE_OR_OP;			//子类型是逻辑或
				reg1_read_o	<= 1'b1;				//需要读寄存器1，不需要读寄存器2
				reg2_read_o	<= 1'b0;
				imm			<= {16'h0, inst_i[15:0]};	//16位到32位立即数的扩展，ori指令是无符号扩展！
				wd_o		<=inst_i[20:16];
				instvalid	<=`InstValid;			//ori是有效指令
			end
			default: begin
			end
		endcase	//case op
	end	// else
end		//always

/* 第二段：确定源操作数1*/
always @ (*) begin
	if(rst == `RstEnable) begin
		reg1_o <= `ZeroWord;				//复位时操作数就是0
	end else if(reg1_read_o == 1'b1) begin
		reg1_o <= reg1_data_i;				//寄存器1读使能时，操作数是寄存器1的值
	end else if(reg1_read_o == 1'b0) begin
		reg1_o <= imm;						//读禁用时， 操作数是立即数
	end else begin
		reg1_o <= `ZeroWord;
	end
end

/* 第三段：确定源操作数2*/
always @ (*) begin
	if(rst == `RstEnable) begin
		reg2_o <= `ZeroWord;				//复位时操作数就是0
	end else if(reg2_read_o == 1'b1) begin
		reg2_o <= reg2_data_i;				//寄存器1读使能时，操作数是寄存器1的值
	end else if(reg2_read_o == 1'b0) begin
		reg2_o <= imm;						//读禁用时， 操作数是立即数
	end else begin
		reg2_o <= `ZeroWord;
	end
end

endmodule