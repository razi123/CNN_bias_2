----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.09.2019 16:06:10
-- Design Name: 
-- Module Name: regFIFO - Behavioral
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

entity regFIFO is
        port(   clk : in STD_LOGIC;
              rst : in STD_LOGIC := '0';
              w_en : in STD_LOGIC := '0';
              wData : in t_2d_out(0 to (matRow*matCol)-1);
              rData : out t_2d_out(0 to (matRow*matCol)-1));
end regFIFO;

architecture Behavioral of regFIFO is
signal s_WDATA : t_2d_out(0 to (matRow*matCol)-1);
begin


process(clk,rst)
variable temp : t_2d_out;
begin

temp := wData;
if rising_edge(clk)then
    if rst ='1' then
        s_WDATA <= (others=>(others=> '0'));
    
    elsif rising_edge(clk) then
        --if(w_en ='0') then
        --s_WDATA <= wData;    
        s_WDATA <= temp; 
    --end if;
    end if;
end if;

end process;

rData <= s_WData;
end Behavioral;
