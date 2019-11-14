----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.10.2019 16:45:20
-- Design Name: 
-- Module Name: sqrtNorm - Behavioral
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
use IEEE.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.multPkg.all;

entity sqrtNorm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           readEnb : in STD_LOGIC;
           norm_in : in STD_LOGIC_VECTOR(7 downto 0);
           data_in : in t_2d_matrix(0 to matRow-1, 0 to matCol-1);
           data_out : out t_2d_matrix(0 to matRow-1, 0 to matCol-1));
end sqrtNorm;


architecture behaviour of sqrtNorm is 
signal s_norm_in : STD_LOGIC_VECTOR(7 downto 0);
signal s_data_in :  t_2d_matrix(0 to matRow-1, 0 to matCol-1) := (others =>(others => "00000000"));
signal s_variance : t_2d_matrix(0 to matRow-1, 0 to matCol-1) ;
signal s_temp, s_mean, s_var: integer := 0;
signal s_tempDiff, s_var1 : STD_LOGIC_VECTOR(7 downto 0) := "00000000"; 


signal part_done  : std_logic := '0';
signal part_count : integer := 3; 
signal result     : std_logic_vector(4 downto 0) := "00000"; 
signal partialq   : std_logic_vector(5 downto 0) := "000000";

begin


process(clk,rst)

variable v_norm_in : STD_LOGIC_VECTOR(7 downto 0);
variable v_tempDiff, v_var : STD_LOGIC_VECTOR(7 downto 0) := "00000000"; 
variable v_mean, v_tempDifference, v_variance : integer := 0;
variable v_data_in : t_2d_matrix(0 to matRow-1, 0 to matCol-1) := (others=> (others=> "00000000"));

begin
--if rising_edge(clk) then
    if(rst='1') then
        v_mean := v_mean;
        v_tempDifference := 0;
        v_tempDiff := v_tempDiff;
    else  
       if readEnb ='1' then  
            v_norm_in := norm_in;     
                v_mean := to_integer(unsigned(v_norm_in))/(matRow*matCol);
                
                for i in 0 to matRow-1 loop
                    for j in 0 to matCol-1 loop
                       -- v_tempDiff :=  data_in(i,j) - std_logic_vector(to_unsigned(v_mean,8));
                       -- v_data_in(i,j) := v_tempDiff(6 downto 0) & '0';       
                                     
--                          v_tempDifference := ((to_integer(unsigned(data_in(i,j))) - v_mean)** 2) / (matRow*matCol);
--                          v_data_in(i,j) := std_logic_vector(to_unsigned(v_tempDifference, 8));
                       
                       --v_data_in(i,j) := std_logic_vector(to_unsigned((to_integer(unsigned(data_in(i,j))) - v_mean)** 2, 8)); -- works fine
                         v_tempDiff := v_tempDiff + std_logic_vector(to_unsigned((to_integer(unsigned(data_in(i,j))) - v_mean)** 2, 8)); -- works fine                                                    
                         -- v_var := v_tempDiff / "00010000";
                          -- if(v_data_in(i,j) < "00000000") then
--                          v_data_in(i,j) := "00000000";
--                       end if;     
                       
                        --v_tempDifference := v_tempDifference + (((to_integer(unsigned(data_in(i,j))) - v_mean)** 2) / matRow * matCol);
                        --v_variance := v_tempDifference ;
                    end loop;
                end loop;
                
        end if;
    end if;
--end if;
s_mean <= v_mean;
s_var <= v_variance;

s_variance <= v_data_in;
data_out <= s_variance; 
s_temp <= v_tempDifference;

s_tempDiff <= v_tempDiff;
--s_norm_in <= v_norm_in;   
--s_quot <= v_quot;          
end process;



--process(clk,rst)
--variable v_data_in : t_2d_matrix(0 to matRow-1, 0 to matCol-1);
--variable v_temp : integer;

--begin

----if rising_edge(clk) then
--    if(rst='1') then

--    else  
--    -- if readEnb ='1' then
--         for i in 0 to matRow-1 loop
--            for j in 0 to matCol-1 loop
--                v_data_in(i,j) := data_in(i,j) - std_logic_vector(to_unsigned(s_mean,v_data_in'length));  
--            end loop;
--         end loop;
--     end if;
--    -- end if;
----end if; 
--s_variance <= v_data_in;
----s_norm_in <= v_norm_in;   
----s_quot <= v_quot;          
--end process;                  
                    
 
process(clk,rst) 

begin




end process;









--   ********************* Square root progrm starts from here *********************************************


--    part_done_1: process(clk, data_in, part_done)  
--    begin
--        if(rising_edge(clk)) then
--            if(rst = '1') then
--                data_out <= "0000";
--                part_done <= '0';
                
--            else
--                --if(part_done='0') and (readEnb = '1') then
--                if(part_done='0') then
--                    if(part_count>=0)then
--                        partialq(1 downto 0)  <= data_in((part_count*2)+ 1 downto part_count*2);
--                        part_done <= '1';    
--                    else
--                        data_out <= result(3 downto 0);    
--                    end if;
                    
--                    part_count <= part_count - 1;
                
--                 elsif(part_done='1')then
--                        if((result(3 downto 0) & "01") <= partialq) then
--                            result   <= result(3 downto 0) & '1';
--                            partialq(5 downto 2) <= partialq(3 downto 0) - (result(1 downto 0)&"01");    
--                        else 
--                            result   <= result(3 downto 0) & '0';
--                            partialq(5 downto 2) <= partialq(3 downto 0);                     
--                        end if;  
                         
--                        part_done  <= '0';
                        
--                  end if;
                  
--              end if; 
--          end if;
           
--        end process;  
         
end behaviour;

