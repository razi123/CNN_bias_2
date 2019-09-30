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
use IEEE.NUMERIC_STD.ALL;

--use IEEE.std_logic_arith.all;

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
         poolRead : in t_2d_matrix(0 to matRow-1, 0 to matCol-1);
         --poolRead : in t_2d_matrixInt(0 to matRow-1, 0 to matCol-1);
         poolOut : out t_2d_out(0 to ((matRow - kernRow)*(matCol - matCol)) -1);
         donePool : out STD_LOGIC := '0');
end maxPool;

architecture Behavioral of maxPool is
--signal s_tempPoolRegister : t_2d_matrixInt(0 to matRow-1, 0 to matCol-1);
signal s_tempPoolRegister : t_2d_matrix(0 to matRow-1, 0 to matCol-1); -- := (("00000001","00000001","00000001","00000001"),("00000001","00000001","00000001","00000001"), 
                                  -- ("00000001","00000001","00000001","00000001"),("00000001","00000001","00000001","00000001"));
signal s_temp1 : t_2d_matrix16(0 to kernRow-1, 0 to kernCol-1);
signal s_filtKernal : t_2d_kernal(0 to kernRow-1, 0 to kernCol-1) := (("0001","0001","0001"),("0001","0001","0001"),("0001","0001","0001"));
signal s_fetchDone : STD_LOGIC := '0';
--signal s_maxPoolOut :  t_2d_matrix16(0 to ((matRow-kernRow)/kernStride), 0 to ((matCol-kernCol)/kernStride));
signal s_maxPoolOut :  t_2d_matPool(0 to ((matRow-kernRow)/kernStride), 0 to ((matCol-kernCol)/kernStride));   

signal s_n : integer;  --range 0 to 3 :=0;
signal s_m : integer; -- range 0 to 3 :=0;
signal i,j :integer range 0 to 2;

begin

s_tempPoolRegister <= poolRead;

process(clk)

variable v_temp : t_2d_matrix16(0 to kernRow-1, 0 to kernCol-1);
variable v_tempInt : integer := 0;
variable  v_poolMax : STD_LOGIC_VECTOR(11 downto 0) := "000000000000"; 
variable v_i,v_j :integer range 0 to 2;
variable m, n : integer := 0;

begin

if rising_edge(clk) then 
    if rst = '1' then
        donePool <= '0';
        s_fetchDone <= '0';
        v_poolMax := "000000000000";
        m:= 0;
        n:= 0;
        
else
            v_poolMax := "000000000000";
            
            v_temp(0,0) := s_tempPoolRegister(0+s_m,1+s_n) * s_filtKernal(0,0);   
            v_temp(0,1) := s_tempPoolRegister(0+s_m,1+s_n) * s_filtKernal(0,1);
            v_temp(0,2) := s_tempPoolRegister(0+s_m,2+s_n) * s_filtKernal(0,2);
            
            v_temp(1,0) := s_tempPoolRegister(1+s_m,0+s_n) * s_filtKernal(1,0);
            v_temp(1,1) := s_tempPoolRegister(1+s_m,1+s_n) * s_filtKernal(1,1);
            v_temp(1,2) := s_tempPoolRegister(1+s_m,2+s_n) * s_filtKernal(1,2);
            
            v_temp(2,0) := s_tempPoolRegister(2+s_m,0+s_n) * s_filtKernal(2,0);
            v_temp(2,1) := s_tempPoolRegister(2+s_m,1+s_n) * s_filtKernal(2,1);
            v_temp(2,2) := s_tempPoolRegister(2+s_m,2+s_n) * s_filtKernal(2,2);
            
            
              for i in 0 to 2 loop
                for j in 0 to 2 loop
                    if(v_poolMax < v_temp(i,j)) then
                        v_poolMax := v_temp(i,j);
                     end if;
                 end loop;
              end loop; 
              
              
              if(m <= ((matRow - kernRow)/kernStride)) then
                if(n <= ((matCol - kernCol)/kernStride)) then
                    
                    v_tempInt := to_integer(unsigned(v_poolMax)); 
                    s_maxPoolOut(m,n) <= std_logic_vector(to_unsigned(v_tempInt,4)); 
                    n := n+ kernStride;
                    if(n = ((matCol - kernCol)/kernStride)+1) then
                       m := m + kernStride;
                       n := 0;  
                    end if;
                 end if;
              end if;
     end if;        
          
             
end if;

--s_temp1 <= s_temp;
--s_tempMax1 <= s_tempMax;
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
     
    
end process;
 
end Behavioral;