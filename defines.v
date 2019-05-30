//全局宏定义
`define RstEnable				1'b1			//复位信号有效
`define RstDisable				1'b0			//复位信号无效
`define ChipEnable				1'b1			//芯片使能
`define ChipDisable				1'b0			//芯片禁用
`define	ZeroWord				32'h00000000	//32位的数值0
`define WriteEnable				1'b1			//使能写
`define WriteDisable			1'b0			//禁止写
`define ReadEnable				1'b1			//使能读
`define ReadDisable				1'b0			//禁止读
`define AluOpBus				7:0				//译码阶段的输出aluop_o（操作符）的宽度
`define AluSelBus				2:0				//译码阶段的输出alusel_o（这是干什么的？）的宽度	
`define InstValid				1'b0			//指令有效
`define InstInvalid				1'b1			//指令无效


/*************与具体指令有关的宏定义******************/
`define EXE_ORI					6'b001101		//指令ori的指令码
`define EXE_NOP					6'b000000		//没有指令码

//AluOp
`define EXE_OR_OP				8'b00100101		//运算的子类型：逻辑“或”运算
`define EXE_NOP_OP				8'b00000000

//AluSel
`define EXE_RES_LOGIC			3'b001			//运算的类型，逻辑运算还是其他运算(移位、算数)

`define EXE_RES_NOP				3'b000



//与指令寄存器ROM有关的宏定义
`define InstAddrBus 			31:0			//ROM的地址总线宽度
`define InstBus					31:0			//ROM的数据总线宽度
`define InstMemNum				131071			//ROM的大小是128KB
`define InstMemNumLog2			17				//ROM实际使用的地址线宽度

//与通用寄存器Regfile有关的宏定义
`define RegAddrBus				4:0				//寄存器的地址线宽度(因为一共有32个通用寄存器，2^5=32能访问到所有的寄存器了)
`define RegBus					31:0			//寄存器的数据线宽度（保存寄存器中的32位数据）
`define RegNum					32				//通用寄存器的数量
`define RegNumLog2				5				//寻址通用寄存器使用的地址位数
`define NOPRegAddr				5'b00000


