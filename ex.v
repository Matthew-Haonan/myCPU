`include "defines.v"

module ex(
	input wire				rst,
	
	//译码阶段送到执行阶段的信息
	input wire[`AluOpBus]		aluop_i,				//运算子类型
	input wire[`AluSelBus]		alusel_i,				//运算类型
	input wire[`RegBus]			reg1_i,
	input wire[`RegBus]			reg2_i,
	input wire[`RegAddrBus]		wd_i,
	input wire					wreg_i,
	
	//执行的结果
	output reg[`RegAddrBus]		wd_o,
	output reg					wreg_o,					//写使能
	output reg[`RegBus]			wdata_o
);

	reg[`RegBus] 				logicout;				//保存逻辑运算的结果
	/*第一段：根据aluop_i的运算子类型进行运算,将结果放在logicout中*/
	always @ (*) begin
		if(rst == `RstEnable) begin
			logicout <= `ZeroWord;
		end else begin
			case(aluop_i)
				`EXE_OR_OP: begin
					logicout <= reg1_i | reg2_i;
				end
				default: begin
					logicout <= `ZeroWord;
				end
			endcase
		end
	end
	
	/*
	**第二段：根据alusel_i的运算类型，选择一个运算结果作为最终结果，
	**目前只有逻辑运算结果
	**此处实际上是为以后扩展做准备，当添加其他运算类型的指令时，
	**只需要修改这里的case情况即可								
	*/
	always @ (*) begin
		wd_o <= wd_i;			//写目的寄存器地址
		wreg_o <= wreg_i;		//写使能的传递
		case(alusel_i)
			`EXE_RES_LOGIC:	begin
				wdata_o <= logicout;		//wdata_o存放运算结果
			end
			default:	begin
				wdata_o <= `ZeroWord;
			end
		endcase
	end
	
endmodule