library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DataPath is
    port (
        CLOCK_50    : in std_logic; -- clk
        KEY         : in std_logic_vector(3 downto 0); --key(0) rst, key(1) = step
        SW          : in std_logic_vector(9 downto 0); 
        LEDR		:out	std_logic_vector (9 downto 0);
        HEX0		:out	std_logic_vector (6 downto 0);
        HEX1		:out	std_logic_vector (6 downto 0);
        HEX2		:out	std_logic_vector (6 downto 0);
        HEX3		:out	std_logic_vector (6 downto 0);
        HEX4		:out	std_logic_vector (6 downto 0);
        HEX5		:out	std_logic_vector (6 downto 0)
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
            rst         :in std_logic;
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
            rst     :in std_logic;
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
            muxIn6     :in std_logic_vector(busWidth-1 downto 0);       --Input Register
            selector   :in std_logic_vector(selWidth-1 downto 0);       --ToRegister
            muxOut     :out std_logic_vector(busWidth-1 downto 0)
        );
    end component;

    component Control
        port (
            opcode      : in std_logic_vector(6 downto 0);
            funct3      : in std_logic_vector(2 downto 0);
            funct7      : in std_logic_vector(6 downto 0);
            result      : in std_logic_vector(31 downto 0);
            jump        : out std_logic;
            ToRegister  : out std_logic_vector(2 downto 0);
            MemWrite    : out std_logic;
            Branch      : out std_logic_vector(2 downto 0);
            ALUOp       : out std_logic_vector(2 downto 0);
            StoreSel    : out std_logic;
            ALUSrc      : out std_logic;
            outputSel   : out std_logic_vector(2 downto 0);
            WriteReg    : out std_logic
        );
    end component;

    component multiplier2
        generic(size: INTEGER := 16);
        port (
            operator1   : in std_logic_vector(size-1 downto 0);
            operator2   : in std_logic_vector(size-1 downto 0);
            product     : out std_logic_vector(2*size-1 downto 0)
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

    component OutputLogic
        port (
            reset       : in std_logic;
            Reg         : in std_logic_vector(31 downto 0);
            outputSel   : in std_logic_vector(2 downto 0);
            LEDR        : out std_logic_vector(9 downto 0);
            HEX0        : out std_logic_vector(6 downto 0);
            HEX1        : out std_logic_vector(6 downto 0);
            HEX2        : out std_logic_vector(6 downto 0);
            HEX3        : out std_logic_vector(6 downto 0);
            HEX4        : out std_logic_vector(6 downto 0);
            HEX5        : out std_logic_vector(6 downto 0)
        );
    end component;


    signal PCOut, PCOutPlus     : std_logic_vector(31 downto 0);    --data out from PC register
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
    signal outSelector          : std_logic_vector(2 downto 0);
    signal SEVSEG0,SEVSEG1,
    SEVSEG2,SEVSEG3,SEVSEG4,SEVSEG5 : std_logic_vector(6 downto 0);
    signal LEDS                 : std_logic_vector(9 downto 0);
    signal InputRegister        : std_logic_vector(31 downto 0);
    signal debugON              : std_logic := '0';
    signal clk,step             : std_logic;
    signal rst                  : std_logic;
    signal multResult           : std_logic_vector(31 downto 0);
begin
    
    EdgDet: rising_edge_detector port map (CLK => clk, rst => rst, step => step, CLKOut => stepDetected);

    PCount: PC port map (clk => globalClk, rst => rst, PCIn => PCIn, PCOut => PCOut);

    ROM: Instruction_Mem port map (Address => PCOut(15 downto 0), instruction => instruction);

    RFILE: Reg_File port map (clk => globalClk, writeReg => writeReg, sourceReg1 => instruction(19 downto 15),
    sourceReg2 => instruction(24 downto 20), destinyReg => instruction(11 downto 7), data => dataForReg,
    readData1 => regData1, readData2 => regData2, rst => rst);

    Mux0: Mux port map (muxIn0 => immediate, muxIn1 => regData2, selector => ALUSrc, muxOut => op2);
    
    ALU: ALU_RV32 port map (operator1 => regData1, operator2 => op2, ALUOp => ALUOp, 
    result => result, zero => zero, carryOut => carry, signo => signo);

    Mult: multiplier2 port map (operator1 => regData1(15 downto 0), operator2 => regData2(15 downto 0), product => multResult); 

    Mux1: Mux port map (muxIn0 => regData2, muxIn1 => regData2Anded, selector => StoreSel, muxOut => dataIn);

    RAM: Data_Mem port map (clk => globalClk, writeEn => memWrite, Address => result(3 downto 0), dataIn => dataIn, 
    dataOut => dataOut, rst => rst);

    BRControl: Branch_Control port map (branch => Branch, signo => signo, zero => zero,PCSrc => PCSrc);

    MuxReg: Mux_ToRegFile port map (muxIn0 => result, muxIn1 => dataOut, muxIn2 => dataOut, muxIn3 => PCOut,
    muxIn4 => multResult, muxIn5 => PCOutPlus, muxIn6 => InputRegister, selector => toRegister, muxOut => dataForReg);

    Ctrl: Control port map (opcode => instruction(6 downto 0), funct3 => instruction(14 downto 12), funct7 => instruction(31 downto 25),
    jump => jump, MemWrite => memWrite, Branch => Branch, ALUOp => ALUOp, StoreSel => StoreSel, ALUSrc => ALUSrc, 
    WriteReg => WriteReg, ToRegister => toRegister, result => result, outputSel => outSelector);

    Mux2: Mux port map (muxIn0 => immediate, muxIn1 => result, selector => jump, muxOut => offset);

    Mux3: Mux port map (muxIn0 => PCOutPlus, muxIn1 => newAddress, selector => PCSrc, muxOut => PCIn);
    
    Imm: Immediate_Generator port map (instruction => instruction, immediate => immediate);

    outInterface: OutputLogic port map (reset => rst, Reg => dataIn, outputSel => outSelector, LEDR => LEDS,
    HEX0 => SEVSEG0, HEX1 => SEVSEG1, HEX2 => SEVSEG2, HEX3 => SEVSEG3, HEX4 => SEVSEG4, HEX5 => SEVSEG5);

    process(stepDetected, rst)
    begin
        if rst = '0' then
            debugOn <= '0';
        elsif rising_edge(stepDetected) then
            debugOn <= '1';
        end if ;
    end process ; --   
    globalClk <= clk when (debugOn = '0' and rst = '1') else stepDetected;

    -- debugOn starts with 0, once the button is pressed the edge 
    -- is detected and debugOn takes 1, after that, the clk will be the
    -- the clock for the step button. If the button is never pressed, the clk is normal

    regData2Anded <= regData2 and X"000000FF";   -- this a mask for the sb instruction, so only store the byte
    PCOutPlus <= PCOut + 4;                     -- PC inscreases by 4 every time
    shifted <= offset(30 downto 0) & '0';       -- this is the shift left block for RISC-V architecture
    newAddress <= PCOut + shifted;              -- this is the address that enters to PC when there is a branch

    -----------------INPUT OUTPUT ASSIGNMENT------------
    clk <= CLOCK_50;                -- clock pin
    rst <= KEY(0);                  -- if the KEYs are zero active no need of negation
    step <= not(KEY(1));            -- the debug button is KEY1, since is zero active is negated for the rising edge detector

    inputRegister <= X"0000" & "00" & KEY(3 downto 0) & SW(9 downto 0);     -- the input register formed by combination of inputs
    LEDR(9 downto 0) <= LEDS;
    HEX0(6 downto 0) <= SEVSEG0;
    HEX1(6 downto 0) <= SEVSEG1;
    HEX2(6 downto 0) <= SEVSEG2;
    HEX3(6 downto 0) <= SEVSEG3;
    HEX4(6 downto 0) <= SEVSEG4;
    HEX5(6 downto 0) <= SEVSEG5;

end architecture arch_DataPath;