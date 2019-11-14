----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.10.2019 11:15:48
-- Design Name: 
-- Module Name: batchNorm - Behavioral
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

library work;
use work.multPkg.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity batchNorm is
 Port (clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       readEnb : in STD_LOGIC;
       --readData : in t_2d_matrix(0 to matRow-1, 0 to matCol-1);
       readData : in t_2d_out(0 to (matRow*matCol)-1));
       --batchNormOut : out t_2d_matrix(0 to matRow-1, 0 to matCol-1));
end batchNorm;

architecture Behavioral of batchNorm is

--signal s_readBatchNorm, s_batchNormOrignal : t_2d_matrix(0 to matRow-1, 0 to matCol-1);
signal s_readBatchNorm, s_batchNormOrignal : t_2d_out(0 to (matRow*matCol)-1);
signal s_mean : t_2d_out(0 to (matRow*matCol)-1);
signal s_readData: STD_LOGIC_VECTOR(7 downto 0);
begin

--s_readBatchNorm <= readData;
--s_batchNormOrignal <= readData;


process(clk,rst)
variable v_temp : STD_LOGIC_VECTOR(7 downto 0) := "00000000";

begin 
if rising_edge(clk) then
    
    if rst = '1' then
   
    else 
        if readEnb = '1' then
            s_mean <= readData;
            for i in 0 to (matRow*matCol)-1 loop 
                s_readData <= s_mean(i);
                end loop;    
--                --s_mean <= v_temp + s_readBatchNorm(i,j);  
                
--                end loop;
--                end loop;       
         end if;   
     end if;
end if;
end process;



process(clk,rst)
begin

--s_readData



end process;


end Behavioral;
