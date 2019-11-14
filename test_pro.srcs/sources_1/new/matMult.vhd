----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.08.2019 15:51:36
-- Design Name: 
-- Module Name: matMult - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.multPkg.all;

entity matMult is

    Port ( clk : in STD_LOGIC;
           clkEnb : in STD_LOGIC :='0';
           readEnb: in STD_LOGIC :='0';
           inpMat : in t_2d_array(0 to matRow-1, 0 to matcol-1); 
           rst : in STD_LOGIC:='0';
           outMat : out t_2d_out(0 to (matRow*matCol)-1);
           readNext : out STD_LOGIC;
           doneBit : out STD_LOGIC:='0');
end matMult;

architecture Behavioral of matMult is

constant  clkPeriod : time := 20ns;

-- ---------------------------------------------------------------------------------------------------------------------
--                                         LAYER-1 SIGNAL DECLERATION 
-- ---------------------------------------------------------------------------------------------------------------------

signal writeEnb_1 : STD_LOGIC:= '0';
signal outData :  t_2d_kernal(0 to kernRow-1, 0 to kernCol-1);

signal s_cntEnb : STD_LOGIC:= '0';
signal s_cntRow : integer range 0 to (((matRow-kernRow)/kernStride)+1)-1 ;
signal s_cntCol : integer range 0 to (((matRow-kernRow)/kernStride)+1)-1 ;
--signal cntRow : integer range 0 to ((matRow-kernRow)/(kernStride+1))+ 1 ;
--signal cntCol : integer range 0 to ((matRow-kernCol)/(kernStride+1))+ 1 ;


signal s_tempMult: t_tempKernal2d(0 to kernRow-1, 0 to kernCol-1) := (others=>(others=>(others=>'0'))); --(("00000000","00000000","00000000"),("00000000","00000000","00000000"),("00000000","00000000","00000000")); 
signal s_outDataMultiply : t_2d_out(0 to (matRow*matCol)-1);
signal s_ReLU_Out, s_FIFO_Out, s_outDataFIFO: t_2d_out(0 to (matRow*matCol)-1);
signal s_meanVar : t_2d_out(0 to (matRow*matCol)-1);
signal s_colDone, s_doneBit, s_poolDone, s_enbConv2, s_poolCntDone, s_poolEnb, s_nxtEnb: STD_LOGIC := '0';
signal s_doneOutBit : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal s_poolData : t_2d_matPool(0 to ((matRow-kernRow)/kernStride), 0 to ((matCol-kernCol)/kernStride)); 
signal s_outMatrix : t_2d_matrix(0 to matRow-1, 0 to matCol-1);
--signal s_outMatrix : t_2d_matrixInt(0 to matRow-1, 0 to matCol-1);
signal s_normSum : STD_LOGIC_VECTOR(7 downto 0);
signal s_BNorm_mat : t_2d_matrix(0 to matRow-1, 0 to matCol-1); 

signal s_sqrtInput : STD_LOGIC_VECTOR(7 downto 0) := "11111111";


-- ---------------------------------------------------------------------------------------------------------------------
--                                         LAYER-2 SIGNAL DECLERATION 
-- ---------------------------------------------------------------------------------------------------------------------
signal s_cntEnb_2 : STD_LOGIC:= '0';
signal s_cntRow_2 : integer range 0 to (((matRow-kernRow)/kernStride)+1)-1 ;
signal s_cntCol_2: integer range 0 to (((matRow-kernRow)/kernStride)+1)-1 ;

signal s_writeEnb_2 : STD_LOGIC:= '0';
signal s_colDone_2 , s_doneBit_2, s_poolDone_2, s_poolEnb_2, s_enbConv2_2: STD_LOGIC := '0'; 
signal s_outData_2 :  t_2d_kernal_2(0 to kernRow-1, 0 to kernCol-1);
signal s_doneOutBit_2 : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal s_tempMult_2: t_tempKernal2d(0 to kernRow-1, 0 to kernCol-1) := (others=>(others=>(others=>'0')));
signal s_normSum_2 : STD_LOGIC_VECTOR(7 downto 0);
signal s_meanVar_2 : t_2d_out(0 to (matRow*matCol)-1);
signal s_outDataMultiply_2 : t_2d_out(0 to ((matRow-2)*(matCol-2)-1));
signal s_outMatrix_2 : t_2d_matrix(0 to matRow-2-1, 0 to matCol-2-1);

-- ---------------------------------------------------------------------------------------------------------------------
--                                         ARCHITECTURE BEGINS 
-- ---------------------------------------------------------------------------------------------------------------------

begin

-- ---------------------------------------------------------------------------------------------------------------------
--                                          COMPONENTS INSTANTIATION 
-- ---------------------------------------------------------------------------------------------------------------------

BUFFER_INPUT : entity work.BufferInput
port map(clk => clk, 
        clkEnb => clkEnb, 
        rst => rst, 
        inpMat => inpMat,
        readData => inpMat,
        writeEnb => writeEnb_1, 
        writeData => outData,
        cntRow => s_cntRow,
        cntCol => s_cntCol,
        cntEnb =>s_cntEnb,
        doneBuff => s_doneBit);
 
 
ROW_COUNTER : entity work.rowCount 
port map(clk => clk,
              cntEnb => s_cntEnb, 
              rst => rst,
              cntRow => s_cntRow, 
              cntCol => s_cntCol,
              colDone => s_colDone);       
        

MULTIPLY : entity work.Multiply
    port map(clk => clk, 
         clkEnb => clkEnb, 
         rst => rst, 
         readEnb => writeEnb_1,
         readData => outData, 
         doneMult => s_doneOutBit, 
         writeData => s_tempMult,
         normSum => s_normSum,
         meanVar => s_meanVar, 
         outDataMultiply => s_outDataMultiply);
         
     
OUT_MATRIX : entity work.outMatrix
 port map(clk => clk, 
         rst => rst, 
         readEnb => s_doneOutBit(0),
         poolEnb => s_poolEnb,
         readData => s_outDataMultiply, 
         matReady => s_enbConv2, 
         normSum => s_normSum,
         mat2Conv2 => s_outMatrix);


--MEAN_VARIANCE : entity work.sqrtNorm
--port map(clk => clk,
--         rst => rst,
--       --readEnb => s_doneOutBit(1),
--         readEnb => s_doneOutBit(0),  
--         norm_in => s_normSum,
--         data_in => s_outMatrix, 
--         data_out => s_BNorm_mat);
                      
MAX_POOLING: entity work.maxPool
     port map(clk => clk,  
              rst => rst,
              poolEnb => s_poolEnb,
              poolRead => s_outMatrix,
              poolOut => s_poolData,
              nxtEnb => s_nxtEnb,
              donePool => s_poolDone);  


BUFFER_Conv2 : entity work.Buffer_Conv2
port map(clk => clk, 
        clkEnb => clkEnb, 
        rst => rst, 
        readEnb_2 => s_nxtEnb,
        inpMat => s_poolData,
        writeEnb => s_writeEnb_2, 
        writeData => s_outData_2,
        cntRow => s_cntRow_2,
        cntCol => s_cntCol_2,
        cntEnb => s_cntEnb_2,
        doneBuff => s_doneBit_2);
        
ROW_COUNTER_2 : entity work.rowCount2 
port map(clk => clk,
         cntEnb => s_cntEnb_2, 
         rst => rst,
         cntRow => s_cntRow_2, 
         cntCol => s_cntCol_2,
         colDone => s_colDone_2); 

MULTIPLY_2 : entity work.Multiply2
    port map(clk => clk, 
         clkEnb => clkEnb, 
         rst => rst, 
         readEnb => s_writeEnb_2,
         readData => s_outData_2, 
         doneMult => s_doneOutBit_2, 
         writeData => s_tempMult_2,
         normSum => s_normSum_2,
         meanVar => s_meanVar_2, 
         outDataMultiply => s_outDataMultiply_2);     
         
OUT_MATRIX_2 : entity work.outMatrix2
 port map(clk => clk, 
         rst => rst, 
         readEnb => s_doneOutBit_2(0),
         poolEnb => s_poolEnb,
         readData => s_outDataMultiply_2, 
         matReady => s_enbConv2_2, 
         normSum => s_normSum_2,
         mat2Conv2 => s_outMatrix_2);        
         
         
         
         
           
--doneBit <= s_doneBit;         
--outMat <= s_FIFO_Out;

   
--doneBit <= s_doneOutBit;         
--outMat <= s_outDataMultiply;
     
doneBit <= s_enbConv2;     
readNext <= s_doneOutBit(1);
end Behavioral;