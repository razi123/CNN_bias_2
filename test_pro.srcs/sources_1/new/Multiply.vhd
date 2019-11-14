

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.09.2019 12:09:46
-- Design Name: 
-- Module Name: Multiply - Behavioral
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

entity Multiply is
    port(clk: in STD_LOGIC;
         clkEnb : in STD_LOGIC := '0';
         rst : in STD_LOGIC := '0';
         readEnb: in STD_LOGIC := '0';
         readData : in t_2d_kernal(0 to kernRow-1, 0 to kernCol-1);
         doneMult : out STD_LOGIC_VECTOR(1 downto 0);
         writeData : out t_tempKernal2d(0 to kernRow-1, 0 to kernCol-1);
         normSum : out STD_LOGIC_VECTOR(7 downto 0);
         meanVar : out t_2d_out(0 to (matRow*matCol)-1);
         outDataMultiply : out t_2d_out(0 to (matRow*matCol)-1));
end Multiply;

architecture Behavioral of Multiply is


-- ---------------------------------------------------------------------------------------------------------------------
--                                         SIGNAL DECLERATION 
-- ---------------------------------------------------------------------------------------------------------------------


signal s_temp: t_tempKernal2d(0 to kernRow-1, 0 to kernCol-1) ; 
--signal s_temp: t_2d_kernal(0 to kernRow-1, 0 to kernCol-1) ;
--signal s_filtKernal : t_2d_kernal(0 to kernRow-1, 0 to kernCol-1) := (("0001","0000","0000"),("0000","0001","0000"),("0000","0000","0001"));
signal s_filtKernal : t_2d_kernal(0 to kernRow-1, 0 to kernCol-1) := (("1000","0100","0010"),("1000","0100","0010"),("1000","0100","0010"));
signal s_doneMultiply : STD_LOGIC :='0';
signal s_z : integer := 0;
signal s_tempOut: t_2d_out1(0 to (matRow*matCol)-1):= (others=>(others=> '0'));

signal s_tempOut_d : STD_LOGIC_VECTOR(15 downto 0);

signal s_readEnb_d : std_logic;
signal s_doneMult: STD_LOGIC_VECTOR(1 downto 0) := "00";
signal s_ReLU: STD_LOGIC := '0';
signal s_outDataMultiply, s_ReLU_Out, s_ReLUreadData: t_2d_out(0 to (matRow*matCol)-1);
signal s_bias : STD_LOGIC_VECTOR(7 downto 0):= "00000001";
signal s_normSum : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
signal s_tempSum : STD_LOGIC_VECTOR(15 downto 0):= "0000000000000000";

signal s_tempSignal : STD_LOGIC_VECTOR(7 downto 0);
signal m : integer range 0 to matRow-1 :=0;
signal n : integer range 0 to matCol-1 :=0;

signal s_finalOut : t_2d_matrix(0 to matRow-1, 0 to matCol-1);
signal s_doneReLU: STD_LOGIC := '0';
constant  clkPeriod : time := 20ns;

signal s_DataMultiply : t_2d_out1(0 to (matRow*matCol)-1):= (others=>(others=> '0'));
-- ---------------------------------------------------------------------------------------------------------------------
--                                          COMPONENTS DECLERATION 
-- ---------------------------------------------------------------------------------------------------------------------

--component ReLU
--    port(clk: in STD_LOGIC;
--         rst : in STD_LOGIC := '0';
--         ReLUreadData : in t_2d_out(0 to (matRow*matCol)-1);
--         ReLU_Out : out t_2d_out(0 to (matRow*matCol)-1);
--         doneReLU : out STD_LOGIC := '0');
--end component;

-- ---------------------------------------------------------------------------------------------------------------------
--                                         ARCHITECTURE BEGINS 
-- ---------------------------------------------------------------------------------------------------------------------

begin


-- ---------------------------------------------------------------------------------------------------------------------
--                                          COMPONENTS INSTANTIATION 
-- ---------------------------------------------------------------------------------------------------------------------

--ReLU_function : ReLU
--    port map(clk => clk,  
--         rst => rst, 
--         ReLUreadData => s_tempOut, 
--         ReLU_Out => outDataMultiply,
--         doneReLU => s_ReLU);

convolve: process(clk,rst) is
variable v_temp: std_logic_vector(7 downto 0) := "00000000" ; 
begin
if rising_edge(clk) then 
    if rst='1' then 
       s_doneMultiply <= '0';
       s_readEnb_d <= '0';    
       
    else 
        s_doneMultiply <= '0';
        if(readEnb = '1') then
            for i in 0 to 2 loop 
                for j in 0 to 2 loop
               
                v_temp :=  readData(i,j) * s_filtKernal(i,j);
                --s_temp(i,j) <= v_temp(15) & (v_temp(11 downto 5));
                s_temp(i,j) <= v_temp;
                end loop;
            end loop;
                    
        end if;
    s_readEnb_d <= readEnb;
    end if;
    
end if;
end process;  ---- convolve Process ends here



convolveAdd : process(clk,rst) is
--variable m : integer range 0 to matRow-1 :=0;
--variable n : integer range 0 to matCol-1 :=0;
variable v_meanEnb : STD_LOGIC := '1';
variable v_xyzTemp : t_2d_out(0 to (matRow*matCol)-1):= (others=>(others=> '0'));
variable v_normSum,  v_tempOut_d : STD_LOGIC_VECTOR(15 downto 0) := (others=>'0'); -- "0000000000000000";
variable v_tempSum : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
--variable s_doneMult: STD_LOGIC_VECTOR(1 downto 0) := "00";
variable v_readTemp : STD_LOGIC := '1';

variable v_DataMultiply : t_2d_out1(0 to (matRow*matCol)-1):= (others=>(others=> '0')) ; --(0 to (matRow*matCol)-1)); 

begin
if rising_edge(clk) then     
    if rst='1' then 
        s_doneMult <= "00";
        doneMult <= "00";
        s_z<=0;
        m <= 0;
        n <= 0;
        v_normSum := (others=>'0');
        v_meanEnb := '0';
        v_readTemp := '1';
        v_tempSum := (others=>'0'); --"0000000000000000";
        
    else
        if(s_readEnb_d = '1') then
            if(v_readTemp = '1') then
          --  s_tempOut(s_z) <= ("000" & s_temp(0,0)) +("000" & s_temp(0,1)) + ("000" & s_temp(0,2)) + ("000" & s_temp(1,0)) +("000" & s_temp(1,1)) + ("000" & s_temp(1,2))+ 
          --  ("000" & s_temp(2,0))+("000" & s_temp(2,1)) +("000" & s_temp(2,2));
          
              s_tempOut(s_z) <= (("0000" & s_temp(0,0)) + ("0000" & s_temp(0,1)) + ("0000" & s_temp(0,2)) + ("0000" & s_temp(1,0)) + ("0000" & s_temp(1,1)) 
                                 +("0000" & s_temp(1,2)) + ("0000" & s_temp(2,0)) + ("0000" & s_temp(2,1)) + ("0000" & s_temp(2,2)));
                                 
              v_normSum := v_normSum + s_temp(0,0) + s_temp(0,1) + s_temp(0,2) + s_temp(1,0) + s_temp(1,1) + s_temp(1,2) + s_temp(2,0) + s_temp(2,1) + s_temp(2,2);
              v_xyzTemp(s_z) := s_tempOut(s_z)(10 downto 3);
              --v_tempOut_d := s_tempOut(s_z);
              --v_DataMultiply(s_z) := s_tempOut(s_z);
            end if;
                            
            if(s_z < (matRow*matCol)-1) then
                s_z <= s_z + 1;
                s_doneMult <= "00";
            else 
                s_z <= 0;
               s_doneMult <= "11";
               v_readTemp := '0';                

            end if;
              
        end if;        
     
        if s_doneMult = "11" then
          
           --v_normSum := "00000000";
          
         -- outDataMultiply(s_z) <= v_xyzTemp(s_z);
          doneMult <= s_doneMult;
          v_meanEnb := '0';
          
        end if;  
 end if;
end if;

outDataMultiply(s_z) <= v_xyzTemp(s_z);
--s_DataMultiply(s_z) <= v_DataMultiply(s_z);
s_normSum <= v_normSum;
s_tempOut_d <=  v_tempOut_d;

end process;


--Mean : process(clk,rst) is
--variable v_normSum : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
----variable s_doneMult: STD_LOGIC_VECTOR(1 downto 0) := "00";
--begin
--if rising_edge(clk) then     
--    if rst='1' then 
--        s_doneMult <= "00";
--        doneMult <= "00";
--        s_z<=0;
--        m <= 0;
--        n <= 0;
--        v_normSum := "00000000";
--        s_normSum <= "00000000";
--    else
--        if(s_readEnb_d = '1') then
--           v_normSum := v_normSum + s_tempOut;
--            end if;  
--        end if;        
     
--end if;
--end process;



--s_ReLUreadData <= s_tempOut;
--ReLU: process(clk,rst) is

--begin
--if rising_edge(clk) then 
--    if rst ='1' then 
--       --s_readEnb <= '0';
--       s_doneReLU <= '0';      
--    else

--          for i in 0 to (matRow*matCol)-1 loop 
--                if (ReLUreadData(i) > 3) then
--                    ReLU_Out(i) <= ReLUreadData(i);
--                else
--                    ReLU_Out(i) <= "00000000";
--                end if;    
--          end loop;    
--             doneReLU <= '1';               
--     end if;
--end if;
 
--end process;  ---- ReLU Process ends here

--s_doneMult <= d_doneMult;
--doneMult <= d_doneMult;
---- convolveAdd Process ends here

--writeData <= s_temp;
--doneMult <= s_readEnb_d & '1';
--normSum <= s_normSum;
--meanVar <= s_tempOut;
end Behavioral;