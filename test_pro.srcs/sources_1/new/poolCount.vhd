
-- *************************************************Row COUNT ********************************************************
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.09.2019 12:32:10
-- Design Name: 
-- Module Name: counter - Behavioral
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

entity poolCount is
 port(clk: in STD_LOGIC;
      cntEnb : in STD_LOGIC :='0';
      rst : in STD_LOGIC := '0';
      poolRow : out integer range 0 to (((matRow-kernRow)/kernStride)+1)-1   := 0;
      poolCol : out integer range 0 to (((matCol-kernCol)/kernStride)+1)-1   := 0;
      poolDone : out STD_LOGIC := '0');
end poolCount;

architecture Behavioral of poolCount is

-- ---------------------------------------------------------------------------------------------------------------------
--                                         SIGNAL DECLERATION 
-- ---------------------------------------------------------------------------------------------------------------------

signal s_n : integer;  --range 0 to 3 :=0;
signal s_m : integer; -- range 0 to 3 :=0;

-- ---------------------------------------------------------------------------------------------------------------------
--                                         ARCHITECTURE BEGINS 
-- ---------------------------------------------------------------------------------------------------------------------

begin

counterRC: process(clk,rst) is
begin 

if rising_edge(clk) then
if rst='1' then
    s_m<=0;
    s_n<=0;
    poolDone<='0';

else

--  if cntEnb ='1' then    
--            if (s_n < (matRow-1)) then       
--                s_n <= s_n + 1;
--                s_m <= s_m;
--                colDone <= '0';
--            elsif(s_m < (matCol-1)) then     
--                s_n <= 0;
--                s_m <= s_m + 1;
--                colDone <= '0';
--            else
--                s_n <= 0;
--                s_m <= 0;
--                colDone <= '1';
--            end if;
     
--    end if;
--    end if;
--    end if;

 if cntEnb ='1' then    
            if (s_n < (((matCol-kernCol)/kernStride)+1)-1) then       
                s_n <= s_n + 1;
                s_m <= s_m;
                poolDone <= '0';
            elsif(s_m < (((matRow-kernRow)/kernStride)+1)-1) then     
                s_n <= 0;
                s_m <= s_m + 1;
                poolDone <= '0';
            else
                s_n <= 0;
                s_m <= 0;
                poolDone <= '1';
            end if;
     
    end if;
    end if;
    end if;


end process;        ---- counterRC Process ends here

poolRow <= s_n;
poolCol <= s_m;

--cntRow <= s_m;
--cntCol <= s_n;
end Behavioral;

