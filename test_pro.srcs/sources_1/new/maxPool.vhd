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


entity maxPool is
     port(clk: in STD_LOGIC;
         rst : in STD_LOGIC := '0';
         poolEnb : in STD_LOGIC := '0';
         --poolRow : in integer range 0 to (((matRow-kernRow)/kernStride)+1)-1 ;
         --poolCol : in integer range 0 to (((matRow-kernRow)/kernStride)+1)-1 ;
         poolRead : in t_2d_matrix(0 to matRow-1, 0 to matCol-1);
         poolOut : out t_2d_out(0 to ((matRow - kernRow)*(matCol - matCol)) -1);
         donePool : out STD_LOGIC := '0');
end maxPool;

architecture Behavioral of maxPool is
signal s_tempPoolRegister : t_2d_matrix(0 to matRow-1, 0 to matCol-1); -- := (("00000001","00000001","00000001","00000001"),("00000001","00000001","00000001","00000001"), 
                                  -- ("00000001","00000001","00000001","00000001"),("00000001","00000001","00000001","00000001"));
signal s_temp : t_2d_matrix16(0 to kernRow-1, 0 to kernCol-1);
signal s_filtKernal : t_2d_kernal(0 to kernRow-1, 0 to kernCol-1) := (("0001","0001","0001"),("0001","0001","0001"),("0001","0001","0001"));
signal s_fetchDone,s_tempMaxDone : STD_LOGIC := '0';
signal s_maxPoolOut :  t_2d_matrix16(0 to ((matRow-kernRow)/kernStride), 0 to ((matCol-kernCol)/kernStride));
signal s_tempMax : STD_LOGIC_VECTOR(11 downto 0) := "000000000000"; 

signal s_n : integer;  --range 0 to 3 :=0;
signal s_m : integer; -- range 0 to 3 :=0;

begin
s_tempPoolRegister <= poolRead;

process(clk,rst)
begin
if rising_edge(clk) then 
    if rst = '1' then
        donePool <= '0';
        s_fetchDone <= '0';
        s_tempMax <= "000000000000";
    else
 
         --   for i in 0 to (((matRow-kernRow)/kernStride)+1) loop
         --       for j in 0 to (((matCol-kernCol)/kernStride)+1) loop
                
                for i in 0 to 2 loop
                for j in 0 to 2 loop
                    
                    s_temp(i,j) <= s_tempPoolRegister(i + s_m , j+ s_n) *  s_filtKernal(i,j);
                        if s_tempMax >= s_temp(i,j) then
                            s_tempMax <= s_tempMax;
                        else
                            s_tempMax <= s_temp(i,j);
                        end if;
                        
                 end loop;
                 end loop;
                 s_fetchDone <= '1';
                 
     end if;
end if;
end process;    


process(clk,rst)
begin 

if rising_edge(clk) then
    if rst = '1' then
        s_m <= 0;
        s_n <= 0;
        donePool <= '0';
           
    else  
            if (s_n < ((matCol-kernRow)/kernStride)) then       
                s_n <= s_n + 1;
                s_m <= s_m;
                donePool <= '0';
      
            elsif(s_m < ((matRow-kernRow)/kernStride)) then     
                s_n <= 0;
                s_m <= s_m + 1;
                donePool <= '0';
          
            else
                s_n <= 0;
                s_m <= 0;
                donePool <= '1';
           
            end if;
     
    end if;
    end if;
    --end if;     
    
end process;



--process(clk,rst)
----variable tempMax : STD_LOGIC_VECTOR(11 downto 0);
--begin
--if rising_edge(clk) then 
--    if rst = '1' then
--        donePool <= '0';
--        s_tempMaxDone <= '0';
--    else
--        --if s_fetchdone <= '1' then
            
--            for i in 0 to kernRow-1 loop
--                for j in 0 to kernCol-1 loop
                   
--                    if s_tempMax > s_temp(i,j) then
--                        s_tempMax <= s_tempMax; 
--                    else
--                        s_tempMax <=  s_temp(j,i);
--                    end if;
                       
--                end loop;
--                end loop;
--                 --s_tempMaxDone <='1';
                
                         
--        --end if;
        
--end if;
--end if;
--end process;
   
   
process(clk,rst)
begin
if rising_edge(clk) then 
    if rst = '1' then
        donePool <= '0';
    else
       -- if s_fetchdone <= '1' then
                          
            for m in 0 to ((matRow - kernRow)/kernStride) loop
                for n in 0 to ((matCol - kernCol)/kernStride) loop
                   
                   s_maxPoolOut(m,n) <= s_tempMax;
                             
                 end loop;
             end loop;
        --end if;
end if;
end if;
end process;
 
 
end Behavioral;