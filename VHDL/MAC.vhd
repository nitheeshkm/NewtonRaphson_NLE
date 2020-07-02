----------------------------------------------------------------------------------
-- Company: URTPC
-- Engineer: Nitheesh Manjunath
-- 
-- Create Date: 06/18/2020 10:24:23 AM
-- Design Name: 
-- Module Name: MAC - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MAC is
    Generic (
        dw_i : natural := 32;
        dw_o : natural := 32
    );
    Port ( 
        clk : in std_logic;
        rst_n : in std_logic;
        newMac : in std_logic; 
        A : in std_logic_vector(dw_i-1 downto 0);
        B : in std_logic_vector(dw_i-1 downto 0);
        P : out std_logic_vector(dw_o-1 downto 0);
        macdone : out std_logic
    );
end MAC;

architecture Behavioral of MAC is



signal newMac_1 : std_logic := '0';
signal newMac_2 : std_logic := '0';
signal newMac_3 : std_logic := '0';

signal partial_product : std_logic_vector(2*dw_o-1 downto 0) := (others => '0');
signal partialSum : std_logic_vector(2*dw_i-1 downto 0) := (others => '0');

begin

process(rst_n, partial_product, A, B) begin
    if rst_n = '1' then 
        partial_product <= (others => '0');
    else
        partial_product <= std_logic_vector(signed(A)*signed(B));
    end if;
end process;

process (clk)
begin
    if rising_edge(clk) then 
        if rst_n  = '1' then
            partialSum <= (others => '0');
        else 
            newMac_1 <= newMac;
            newMac_2 <= newMac_1;
            newMac_3 <= newMac_2;
            if newMac = '0' then
                partialSum <= std_logic_vector(signed(partialSum) + signed(partial_product));
            else 
                partialSum <= partial_product;
            end if;
        end if;
    end  if;
end process;

P <= partialSum(56-1 downto 24);
macdone <= newMac_3;
end Behavioral;
