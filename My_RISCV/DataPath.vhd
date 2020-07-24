library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DataPath is
    port (
        clk         : in std_logic;
        rst         : in std_logic; --reset is button, must be debounced
        step        : in std_logic; --this must be connected to a button for step by step execution
        clk_man     : in std_logic  --decides whether is going to be controlled by a clock or manually
    );
end entity DataPath;

architecture arch_DataPath of DataPath is

    component PC
        port (
            PCIn    : in std_logic_vector(31 downto 0);
            clk     : in std_logic;
            rst     : in std_logic;                                                     
            PCOut   : out std_logic_vector(31 downto 0)
        );
    end component;

    component Instruction_Mem
        port (
            Address     :in std_logic_vector(15 downto 0);
            instruction :out std_logic_vector(31 downto 0)
        );
    end component;

    component Reg_File
        port (
            clk         :in std_logic;
            writeReg    :in std_logic;                          --signal for write in register
            sourceReg1  :in std_logic_vector(4 downto 0);       --address of rs1
            sourceReg2  :in std_logic_vector(4 downto 0);       --address of rs2
            destinyReg  :in std_logic_vector(4 downto 0);       --address of rd
            data        :in std_logic_vector(31 downto 0);      --Data to be written
            readData1   :out std_logic_vector(31 downto 0);     --data in rs1
            readData2   :out std_logic_vector(31 downto 0)      --data in rs2    
        );
    end component;

    component Mux
        port (
            muxIn0      :in std_logic_vector(31 downto 0);
            muxIn1      :in std_logic_vector(31 downto 0);
            selector    :in std_logic;
            muxOut      :out std_logic_vector(31 downto 0)    
    );
    end component;

    component ALU_RV32
        port (
            operator1   :in std_logic_vector(31 downto 0);
            operator2   :in std_logic_vector(31 downto 0);
            ALUOp       :in std_logic_vector(2 downto 0);
            result      :out std_logic_vector(31 downto 0);
            zero        :out std_logic;
            carryOut    :out std_logic;
            signo  		:out std_logic
        );
    end component;

    component Data_Mem
        port (
            clk     :in std_logic;
            writeEn :in std_logic;
            Address :in std_logic_vector(3 downto 0);
            dataIn  :in std_logic_vector(31 downto 0);
            dataOut :out std_logic_vector(31 downto 0)
        );
    end component;

    component Immediate_Generator
        port (
            instruction     : in std_logic_vector(31 downto 0);
            immediate       : out std_logic_vector(31 downto 0)
        );
    end component;

    component Mux_Store
        port (
            muxIn0      :in std_logic_vector(31 downto 0);  --SB
            muxIn1      :in std_logic_vector(31 downto 0);  --SW
            selector    :in std_logic;
            muxOut      :out std_logic_vector(31 downto 0)
    );
    end component;

    component Branch_Control
        port (
            branch      : in std_logic_vector(2 downto 0);
            signo       : in std_logic;
            zero        : in std_logic;
            PCSrc       : out std_logic
        );
    end component;

    component Mux_ToRegFile
        generic (
            busWidth    :integer := 32;
            selWidth    :integer := 3
        );
        port (
            muxIn0     :in std_logic_vector(busWidth-1 downto 0);       --register
            muxIn1     :in std_logic_vector(busWidth-1 downto 0);       --LB
            muxIn2     :in std_logic_vector(busWidth-1 downto 0);       --LW
            muxIn3     :in std_logic_vector(busWidth-1 downto 0);       --PC
            muxIn4     :in std_logic_vector(busWidth-1 downto 0);       --mult
            muxIn5     :in std_logic_vector(busWidth-1 downto 0);       --PC+4
            selector   :in std_logic_vector(selWidth-1 downto 0);       --ToRegister
            muxOut     :out std_logic_vector(busWidth-1 downto 0)
        );
    end component;

    component Control
        port (
            opcode      : in std_logic_vector(6 downto 0);
            funct3      : in std_logic_vector(2 downto 0);
            funct7      : in std_logic_vector(6 downto 0);
            jump        : out std_logic;
            ToRegister  : out std_logic_vector(2 downto 0);
            MemWrite    : out std_logic;
            Branch      : out std_logic_vector(2 downto 0);
            ALUOp       : out std_logic_vector(2 downto 0);
            StoreSel    : out std_logic;
            ALUSrc      : out std_logic;
            WriteReg    : out std_logic
        );
    end component;
    
    component rising_edge_detector
        Port ( 
            CLK 	: in  STD_LOGIC;
            rst 		: in  STD_LOGIC;
            step 		: in  STD_LOGIC;
            CLKOut 		: out  STD_LOGIC
        );
        end component;


    signal PCOut, PCOutPlus    : std_logic_vector(31 downto 0);    --data out from PC register
    signal instruction          : std_logic_vector(31 downto 0);    --instruction from ROM mem
    signal PCIn                 : std_logic_vector(31 downto 0);    --PC updated
    signal regData1,regData2    : std_logic_vector(31 downto 0);    --data readed from register file
    signal signo, zero, carry   : std_logic;
    signal result, dataIn       : std_logic_vector(31 downto 0);    --alu result and data in to memory
    signal immediate            : std_logic_vector(31 downto 0);    --immediate generated
    signal dataOut              : std_logic_vector(31 downto 0);    --data from memory
    signal jump, memWrite       : std_logic;
    signal StoreSel, ALUSrc     : std_logic;
    signal writeReg, PCSrc      : std_logic;
    signal toRegister, Branch, ALUOp : std_logic_vector(2 downto 0);
    signal dataForReg           : std_logic_vector(31 downto 0);    --data to be written in register File
    signal op2                  : std_logic_vector(31 downto 0);    --operator for ALU(output from mux)
    signal offset               : std_logic_vector(31 downto 0);    --PC+immediate after shift or result(jal)
    signal regData2Anded        : std_logic_vector(31 downto 0);
    signal newAddress           : std_logic_vector(31 downto 0);
    signal shifted              : std_logic_vector(31 downto 0);
    signal stepDetected         : std_logic;
    signal globalClk            : std_logic;
begin
    
    EdgDet: rising_edge_detector port map (CLK => clk, rst => rst, step => step, CLKOut => stepDetected);

    PCount: PC port map (clk => globalClk, rst => rst, PCIn => PCIn, PCOut => PCOut);

    ROM: Instruction_Mem port map (Address => PCOut(15 downto 0), instruction => instruction);

    RFILE: Reg_File port map (clk => globalClk, writeReg => writeReg, sourceReg1 => instruction(19 downto 15),
    sourceReg2 => instruction(24 downto 20), destinyReg => instruction(11 downto 7), data => dataForReg,
    readData1 => regData1, readData2 => regData2);

    Mux0: Mux port map (muxIn0 => immediate, muxIn1 => regData2, selector => ALUSrc, muxOut => op2);
    
    ALU: ALU_RV32 port map (operator1 => regData1, operator2 => op2, ALUOp => ALUOp, 
    result => result, zero => zero, carryOut => carry, signo => signo);

    Mux1: Mux port map (muxIn0 => regData2, muxIn1 => regData2Anded, selector => StoreSel, muxOut => dataIn);

    RAM: Data_Mem port map (clk => globalClk, writeEn => memWrite, Address => result(3 downto 0), dataIn => dataIn, dataOut => dataOut);

    BRControl: Branch_Control port map (branch => Branch, signo => signo, zero => zero,PCSrc => PCSrc);

    MuxReg: Mux_ToRegFile port map (muxIn0 => result, muxIn1 => dataOut, muxIn2 => dataOut, muxIn3 => PCOut,
    muxIn4 => (others => '0'), muxIn5 => PCOutPlus, selector => toRegister, muxOut => dataForReg);

    Ctrl: Control port map (opcode => instruction(6 downto 0), funct3 => instruction(14 downto 12), funct7 => instruction(31 downto 25),
    jump => jump, MemWrite => memWrite, Branch => Branch, ALUOp => ALUOp, StoreSel => StoreSel, ALUSrc => ALUSrc, 
    WriteReg => WriteReg, ToRegister => toRegister);

    Mux2: Mux port map (muxIn0 => immediate, muxIn1 => result, selector => jump, muxOut => offset);

    Mux3: Mux port map (muxIn0 => PCOutPlus, muxIn1 => newAddress, selector => PCSrc, muxOut => PCIn);
    
    Imm: Immediate_Generator port map (instruction => instruction, immediate => immediate);

    globalClk <= clk when clk_man = '1' else stepDetected;     
    -- the clock for the system will be the system clock or the step button
    -- depending on the CLK_MAN signal.
    regData2Anded <= regData2 and X"000000FF";
    PCOutPlus <= PCOut + 4;
    shifted <= offset(30 downto 0) & '0';
    newAddress <= PCOut + shifted;

end architecture arch_DataPath;