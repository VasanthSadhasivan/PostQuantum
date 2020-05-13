----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/BIT_WIDTH-1/2019 09:07:08 PM
-- Design Name: 
-- Module Name: ROM_twiddle_factors - Behavioral
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
library work;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.my_types.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ROM_twiddle_factors_inv is
    Port ( k : in unsigned (BIT_WIDTH-1 downto 0);
           w : out unsigned (BIT_WIDTH-1 downto 0));
end ROM_twiddle_factors_inv;

architecture Behavioral of ROM_twiddle_factors_inv is

signal k_integer : integer := 0;
signal w_integer : integer := 0;

begin
    w <= to_unsigned(w_integer, BIT_WIDTH);
    k_integer <= to_integer(k);
    
            with k_integer select
            w_integer <=
            1 when 0,
            
            744574 when 1,
            
            408515 when 2,
            
            979306 when 3,
            
            672550 when 4,
            
            542241 when 5,
            
            845040 when 6,
            
            537943 when 7,
            
            387438 when 8,
            
            915459 when 9,
            
            275318 when 10,
            
            535754 when 11,
            
            799258 when 12,
            
            499952 when 13,
            
            912400 when 14,
            
            195671 when 15,
            
            353368 when 16,
            
            251299 when 17,
            
            433031 when 18,
            
            806890 when 19,
            
            173607 when 20,
            
            806372 when 21,
            
            549027 when 22,
            
            62491 when 23,
            
            1027595 when 24,
            
            1028228 when 25,
            
            253520 when 26,
            
            767621 when 27,
            
            656720 when 28,
            
            450736 when 29,
            
            637186 when 30,
            
            512116 when 31,
            
            76110 when 32,
            
            886627 when 33,
            
            225957 when 34,
            
            353477 when 35,
            
            630012 when 36,
            
            899428 when 37,
            
            544166 when 38,
            
            45327 when 39,
            
            112568 when 40,
            
            338555 when 41,
            
            998383 when 42,
            
            245688 when 43,
            
            100715 when 44,
            
            888690 when 45,
            
            415823 when 46,
            
            701455 when 47,
            
            392876 when 48,
            
            425331 when 49,
            
            858475 when 50,
            
            826018 when 51,
            
            1001904 when 52,
            
            217331 when 53,
            
            181011 when 54,
            
            669573 when 55,
            
            670500 when 56,
            
            590036 when 57,
            
            562312 when 58,
            
            916989 when 59,
            
            162884 when 60,
            
            306660 when 61,
            
            1038346 when 62,
            
            345143 when 63,
            
            711731 when 64,
            
            629223 when 65,
            
            920382 when 66,
            
            296154 when 67,
            
            551486 when 68,
            
            309652 when 69,
            
            538718 when 70,
            
            433338 when 71,
            
            689706 when 72,
            
            746121 when 73,
            
            364771 when 74,
            
            351344 when 75,
            
            774416 when 76,
            
            280803 when 77,
            
            420667 when 78,
            
            649929 when 79,
            
            657682 when 80,
            
            203137 when 81,
            
            220241 when 82,
            
            522566 when 83,
            
            830386 when 84,
            
            76147 when 85,
            
            110462 when 86,
            
            653766 when 87,
            
            918773 when 88,
            
            336226 when 89,
            
            1029654 when 90,
            
            337976 when 91,
            
            16527 when 92,
            
            809617 when 93,
            
            639690 when 94,
            
            694259 when 95,
            
            135895 when 96,
            
            298769 when 97,
            
            503312 when 98,
            
            603775 when 99,
            
            597659 when 100,
            
            878424 when 101,
            
            281593 when 102,
            
            95198 when 103,
            
            257367 when 104,
            
            81740 when 105,
            
            678603 when 106,
            
            562319 when 107,
            
            883562 when 108,
            
            924311 when 109,
            
            867268 when 110,
            
            500751 when 111,
            
            993563 when 112,
            
            332477 when 113,
            
            198468 when 114,
            
            485181 when 115,
            
            409833 when 116,
            
            380534 when 117,
            
            912663 when 118,
            
            888079 when 119,
            
            785735 when 120,
            
            781972 when 121,
            
            17640 when 122,
            
            740169 when 123,
            
            12259 when 124,
            
            658366 when 125,
            
            683588 when 126,
            
            586827 when 127,
            
            1049088 when 128,
            
            304515 when 129,
            
            640574 when 130,
            
            69783 when 131,
            
            376539 when 132,
            
            506848 when 133,
            
            204049 when 134,
            
            511146 when 135,
            
            661651 when 136,
            
            133630 when 137,
            
            773771 when 138,
            
            513335 when 139,
            
            249831 when 140,
            
            549137 when 141,
            
            136689 when 142,
            
            853418 when 143,
            
            695721 when 144,
            
            797790 when 145,
            
            616058 when 146,
            
            242199 when 147,
            
            875482 when 148,
            
            242717 when 149,
            
            500062 when 150,
            
            986598 when 151,
            
            21494 when 152,
            
            20861 when 153,
            
            795569 when 154,
            
            281468 when 155,
            
            392369 when 156,
            
            598353 when 157,
            
            411903 when 158,
            
            536973 when 159,
            
            972979 when 160,
            
            162462 when 161,
            
            823132 when 162,
            
            695612 when 163,
            
            419077 when 164,
            
            149661 when 165,
            
            504923 when 166,
            
            1003762 when 167,
            
            936521 when 168,
            
            710534 when 169,
            
            50706 when 170,
            
            803401 when 171,
            
            948374 when 172,
            
            160399 when 173,
            
            633266 when 174,
            
            347634 when 175,
            
            656213 when 176,
            
            623758 when 177,
            
            190614 when 178,
            
            223071 when 179,
            
            47185 when 180,
            
            831758 when 181,
            
            868078 when 182,
            
            379516 when 183,
            
            378589 when 184,
            
            459053 when 185,
            
            486777 when 186,
            
            132100 when 187,
            
            886205 when 188,
            
            742429 when 189,
            
            10743 when 190,
            
            703946 when 191,
            
            337358 when 192,
            
            419866 when 193,
            
            128707 when 194,
            
            752935 when 195,
            
            497603 when 196,
            
            739437 when 197,
            
            510371 when 198,
            
            615751 when 199,
            
            359383 when 200,
            
            302968 when 201,
            
            684318 when 202,
            
            697745 when 203,
            
            274673 when 204,
            
            768286 when 205,
            
            628422 when 206,
            
            399160 when 207,
            
            391407 when 208,
            
            845952 when 209,
            
            828848 when 210,
            
            526523 when 211,
            
            218703 when 212,
            
            972942 when 213,
            
            938627 when 214,
            
            395323 when 215,
            
            130316 when 216,
            
            712863 when 217,
            
            19435 when 218,
            
            711113 when 219,
            
            1032562 when 220,
            
            239472 when 221,
            
            409399 when 222,
            
            354830 when 223,
            
            913194 when 224,
            
            750320 when 225,
            
            545777 when 226,
            
            445314 when 227,
            
            451430 when 228,
            
            170665 when 229,
            
            767496 when 230,
            
            953891 when 231,
            
            791722 when 232,
            
            967349 when 233,
            
            370486 when 234,
            
            486770 when 235,
            
            165527 when 236,
            
            124778 when 237,
            
            181821 when 238,
            
            548338 when 239,
            
            55526 when 240,
            
            716612 when 241,
            
            850621 when 242,
            
            563908 when 243,
            
            639256 when 244,
            
            668555 when 245,
            
            136426 when 246,
            
            161010 when 247,
            
            263354 when 248,
            
            267117 when 249,
            
            1031449 when 250,
            
            308920 when 251,
            
            1036830 when 252,
            
            390723 when 253,
            
            365501 when 254,
            
            462262 when 255,
            
            1 when others;
        

end Behavioral;
