----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.09.2019 15:24:37
-- Design Name: 
-- Module Name: ReLU - Behavioral
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


entity ReLU is
      port(clk: in STD_LOGIC;
         rst : in STD_LOGIC := '0';
         ReLUreadData : in t_2d_out(0 to (matRow*matCol)-1);
         ReLU_Out : out t_2d_out(0 to (matRow*matCol)-1);
         doneReLU : out STD_LOGIC := '0');
         
end ReLU;

architecture Behavioral of ReLU is

begin

ReLU: process(clk,rst) is

begin
if rising_edge(clk) then 
    if rst ='1' then 
       --s_readEnb <= '0';
       doneReLU <= '0';      
    else

          for i in 0 to (matRow*matCol)-1 loop 
                if (ReLUreadData(i) > 3) then
                    ReLU_Out(i) <= ReLUreadData(i);
                else
                    ReLU_Out(i) <= "00000000";
                end if;    
          end loop;    
             doneReLU <= '1';  
              
     end if;
end if;
 
end process;  ---- ReLU Process ends here



end Behavioral;
