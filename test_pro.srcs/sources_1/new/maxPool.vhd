----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.09.2019 15:02:33
-- Design Name: 
-- Module Name: maxPool - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.multPkg.all;


entity maxPool is
     port(clk: in STD_LOGIC;
         rst : in STD_LOGIC := '0';
         poolRead : in t_2d_out(0 to (matRow*matCol)-1);
         poolOut : out t_2d_out(0 to ((matRow - kernRow)*(matCol - matCol)) -1);
         donePool : out STD_LOGIC := '0');
end maxPool;

architecture Behavioral of maxPool is
signal s_tempPoolRegister : t_2d_out(0 to (matRow*matCol)-1);

begin

process(clk,rst)
begin
if rising_edge(clk) then 

    s_tempPoolRegister <= poolRead;

end if;
end process;    
        
    
    
end Behavioral;
