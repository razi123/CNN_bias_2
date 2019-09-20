
-- *************************************************Multiply COUNT ********************************************************

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
--use IEEE.NUMERIC_STD.ALL;

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
         doneMult : out STD_LOGIC := '0';
         writeData : out t_tempKernal2d(0 to kernRow-1, 0 to kernCol-1);
         outDataMultiply : out t_2d_out(0 to (matRow*matCol)-1));
end Multiply;

architecture Behavioral of Multiply is


-- ---------------------------------------------------------------------------------------------------------------------
--                                         SIGNAL DECLERATION 
-- ---------------------------------------------------------------------------------------------------------------------


signal s_temp: t_tempKernal2d(0 to kernRow-1, 0 to kernCol-1) ; 
--signal s_filtKernal : t_2d_kernal(0 to kernRow-1, 0 to kernCol-1) := (("0001","0000","0000"),("0000","0001","0000"),("0000","0000","0001"));
signal s_filtKernal : t_2d_kernal(0 to kernRow-1, 0 to kernCol-1) := (("1111","1111","1111"),("1111","1111","1111"),("1111","1111","1111"));
signal s_doneMultiply : STD_LOGIC :='0';
signal s_z : integer ;
signal s_tempOut : t_2d_out(0 to (matRow*matCol)-1);
signal s_tempOut_11 :  STD_LOGIC_VECTOR(10 downto 0);

signal s_readEnb_d : std_logic;
signal s_doneMult : STD_LOGIC := '0';
signal s_ReLU: STD_LOGIC := '0';
signal s_outDataMultiply, s_ReLU_Out, s_ReLUreadData: t_2d_out(0 to (matRow*matCol)-1);
signal s_bias : STD_LOGIC_VECTOR(7 downto 0):= "00000001";

signal s_tempSignal : STD_LOGIC_VECTOR(7 downto 0);
signal m : integer range 0 to matRow-1 :=0;
signal n : integer range 0 to matCol-1 :=0;

signal s_finalOut : t_2d_matrix(0 to matRow-1, 0 to matCol-1);
signal s_doneReLU: STD_LOGIC := '0';
constant  clkPeriod : time := 20ns;

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

begin
if rising_edge(clk) then 
    if rst='1' then 
       s_doneMultiply <= '0';
       s_readEnb_d<='0';
    else
        s_doneMultiply <= '0';
        if(readEnb = '1') then
            for i in 0 to 2 loop 
                for j in 0 to 2 loop
               
                s_temp(i,j) <=  readData(i,j) * s_filtKernal(i,j);
              
                end loop;
            end loop;
                    
        end if;
    s_readEnb_d<=readEnb;
    end if;
    
end if;
end process;  ---- convolve Process ends here



convolveAdd : process(clk,rst) is
--variable m : integer range 0 to matRow-1 :=0;
--variable n : integer range 0 to matCol-1 :=0;

begin
if rising_edge(clk) then     
    if rst='1' then 
        s_doneMult <= '0';
        doneMult <= '0';
        s_z<=0;
        m <= 0;
        n <= 0;
    else
        if(s_readEnb_d = '1') then
            s_tempOut(s_z) <= ("000" & s_temp(0,0)) +("000" & s_temp(0,1)) + ("000" & s_temp(0,2)) + ("000" & s_temp(1,0)) +("000" & s_temp(1,1)) + ("000" & s_temp(1,2))+ 
            ("000" & s_temp(2,0))+("000" & s_temp(2,1)) +("000" & s_temp(2,2));
            
           -- s_tempOut(s_z) <= s_tempOut_11; 
           
            if(s_z < (matRow*matCol)-1) then
                s_z <= s_z + 1;
                s_doneMult <= '0';
            else 
                s_z <= 0;
                s_doneMult <= '1';                

            end if;  
        end if;        
     
        if s_doneMult='1' then
          outDataMultiply <= s_tempOut;
          doneMult <= s_doneMult;
        end if;  
 end if;
end if;
end process;
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





writeData <= s_temp;
--doneMult <= s_doneMult;

end Behavioral;
