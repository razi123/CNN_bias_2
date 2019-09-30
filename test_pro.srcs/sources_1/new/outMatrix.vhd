----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.09.2019 17:40:36
-- Design Name: 
-- Module Name: outMatrix - Behavioral
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

entity outMatrix is
     port(clk : in STD_LOGIC;  
      rst: in STD_LOGIC := '0'; 
      readEnb: in STD_LOGIC;
      readData: in t_2d_out(0 to (matRow*matCol)-1); 
      poolEnb : out STD_LOGIC := '0';
      matReady: out STD_LOGIC := '0'; 
      normSum : in STD_LOGIC_VECTOR(7 downto 0);
      mat2Conv2: out t_2d_matrix(0 to matRow-1, 0 to matCol-1));
      --mat2Conv2: out t_2d_matrixInt(0 to matRow-1, 0 to matCol-1));
end outMatrix;

architecture Behavioral of outMatrix is

signal s_readData : t_2d_out(0 to (matRow*matCol)-1);
signal s_mat2Conv2 : t_2d_matrix(0 to matRow-1, 0 to matCol-1);
--signal s_mat2Conv2 : t_2d_matrixInt(0 to matRow-1, 0 to matCol-1);
signal s_matReady, d_matReady,d1_matReady : STD_LOGIC:= '0'; 

signal s_tempNorm :  STD_LOGIC_VECTOR(7 downto 0) :="00000000";
begin

process(clk,rst)
variable k : integer range 0 to (matRow*matCol)-1 ;
variable tempNorm : STD_LOGIC_VECTOR(7 downto 0) :="00000000";
begin

if rising_edge(clk) then
    if rst ='1' then 
        s_matReady <= '0';
        d_matReady <= '0';
        poolEnb <= '0';
        
        
    else
       if(readEnb ='1') then 
            s_readData <= readData;
            for i in 0 to matRow-1 loop
                for j in 0 to matCol-1 loop
                    --s_mat2Conv2(i,j) <= to_integer(unsigned(s_readData(k)));
                    s_mat2Conv2(i,j) <= s_readData(k);
                    tempNorm := tempNorm + s_mat2Conv2(i,j);
                    if(k>(matRow*matCol)-2) then
                        k:= 0;
                        --s_matReady <= '1';
                    else
                        k:= k+1;
                        --s_matReady <= '0';
                    end if;
                 end loop;
             end loop;
             s_matReady <= '1';          
       end if;
   
       if s_matReady = '1' then
            poolEnb <= '1';
            mat2Conv2 <= s_mat2Conv2;
            d_matReady <= s_matReady;
            
       end if; 

    end if; 
end if;

s_tempNorm  <= tempNorm;
end process;

matReady <= d_matReady;
--mat2Conv2 <= s_readData;

end Behavioral;