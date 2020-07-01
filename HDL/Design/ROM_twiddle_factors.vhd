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

entity ROM_twiddle_factors is
    Port ( k : in unsigned (BIT_WIDTH-1 downto 0);
           w : out unsigned (BIT_WIDTH-1 downto 0));
end ROM_twiddle_factors;

architecture Behavioral of ROM_twiddle_factors is

signal k_integer : integer := 0;
signal w_integer : integer := 0;
signal main_data : port_t;

begin
    main_data <= read_mem_file("twiddle_factors_ram.hex");
    /*w <= to_unsigned(w_integer, BIT_WIDTH);*/
    k_integer <= to_integer(k);
    w <= unsigned(main_data(k_integer));

/*
            
            with k_integer select
            w_integer <=
            1 when 0,
            
            462262 when 1,
            
            365501 when 2,
            
            390723 when 3,
            
            1036830 when 4,
            
            308920 when 5,
            
            1031449 when 6,
            
            267117 when 7,
            
            263354 when 8,
            
            161010 when 9,
            
            136426 when 10,
            
            668555 when 11,
            
            639256 when 12,
            
            563908 when 13,
            
            850621 when 14,
            
            716612 when 15,
            
            55526 when 16,
            
            548338 when 17,
            
            181821 when 18,
            
            124778 when 19,
            
            165527 when 20,
            
            486770 when 21,
            
            370486 when 22,
            
            967349 when 23,
            
            791722 when 24,
            
            953891 when 25,
            
            767496 when 26,
            
            170665 when 27,
            
            451430 when 28,
            
            445314 when 29,
            
            545777 when 30,
            
            750320 when 31,
            
            913194 when 32,
            
            354830 when 33,
            
            409399 when 34,
            
            239472 when 35,
            
            1032562 when 36,
            
            711113 when 37,
            
            19435 when 38,
            
            712863 when 39,
            
            130316 when 40,
            
            395323 when 41,
            
            938627 when 42,
            
            972942 when 43,
            
            218703 when 44,
            
            526523 when 45,
            
            828848 when 46,
            
            845952 when 47,
            
            391407 when 48,
            
            399160 when 49,
            
            628422 when 50,
            
            768286 when 51,
            
            274673 when 52,
            
            697745 when 53,
            
            684318 when 54,
            
            302968 when 55,
            
            359383 when 56,
            
            615751 when 57,
            
            510371 when 58,
            
            739437 when 59,
            
            497603 when 60,
            
            752935 when 61,
            
            128707 when 62,
            
            419866 when 63,
            
            337358 when 64,
            
            703946 when 65,
            
            10743 when 66,
            
            742429 when 67,
            
            886205 when 68,
            
            132100 when 69,
            
            486777 when 70,
            
            459053 when 71,
            
            378589 when 72,
            
            379516 when 73,
            
            868078 when 74,
            
            831758 when 75,
            
            47185 when 76,
            
            223071 when 77,
            
            190614 when 78,
            
            623758 when 79,
            
            656213 when 80,
            
            347634 when 81,
            
            633266 when 82,
            
            160399 when 83,
            
            948374 when 84,
            
            803401 when 85,
            
            50706 when 86,
            
            710534 when 87,
            
            936521 when 88,
            
            1003762 when 89,
            
            504923 when 90,
            
            149661 when 91,
            
            419077 when 92,
            
            695612 when 93,
            
            823132 when 94,
            
            162462 when 95,
            
            972979 when 96,
            
            536973 when 97,
            
            411903 when 98,
            
            598353 when 99,
            
            392369 when 100,
            
            281468 when 101,
            
            795569 when 102,
            
            20861 when 103,
            
            21494 when 104,
            
            986598 when 105,
            
            500062 when 106,
            
            242717 when 107,
            
            875482 when 108,
            
            242199 when 109,
            
            616058 when 110,
            
            797790 when 111,
            
            695721 when 112,
            
            853418 when 113,
            
            136689 when 114,
            
            549137 when 115,
            
            249831 when 116,
            
            513335 when 117,
            
            773771 when 118,
            
            133630 when 119,
            
            661651 when 120,
            
            511146 when 121,
            
            204049 when 122,
            
            506848 when 123,
            
            376539 when 124,
            
            69783 when 125,
            
            640574 when 126,
            
            304515 when 127,
            
            1049088 when 128,
            
            586827 when 129,
            
            683588 when 130,
            
            658366 when 131,
            
            12259 when 132,
            
            740169 when 133,
            
            17640 when 134,
            
            781972 when 135,
            
            785735 when 136,
            
            888079 when 137,
            
            912663 when 138,
            
            380534 when 139,
            
            409833 when 140,
            
            485181 when 141,
            
            198468 when 142,
            
            332477 when 143,
            
            993563 when 144,
            
            500751 when 145,
            
            867268 when 146,
            
            924311 when 147,
            
            883562 when 148,
            
            562319 when 149,
            
            678603 when 150,
            
            81740 when 151,
            
            257367 when 152,
            
            95198 when 153,
            
            281593 when 154,
            
            878424 when 155,
            
            597659 when 156,
            
            603775 when 157,
            
            503312 when 158,
            
            298769 when 159,
            
            135895 when 160,
            
            694259 when 161,
            
            639690 when 162,
            
            809617 when 163,
            
            16527 when 164,
            
            337976 when 165,
            
            1029654 when 166,
            
            336226 when 167,
            
            918773 when 168,
            
            653766 when 169,
            
            110462 when 170,
            
            76147 when 171,
            
            830386 when 172,
            
            522566 when 173,
            
            220241 when 174,
            
            203137 when 175,
            
            657682 when 176,
            
            649929 when 177,
            
            420667 when 178,
            
            280803 when 179,
            
            774416 when 180,
            
            351344 when 181,
            
            364771 when 182,
            
            746121 when 183,
            
            689706 when 184,
            
            433338 when 185,
            
            538718 when 186,
            
            309652 when 187,
            
            551486 when 188,
            
            296154 when 189,
            
            920382 when 190,
            
            629223 when 191,
            
            711731 when 192,
            
            345143 when 193,
            
            1038346 when 194,
            
            306660 when 195,
            
            162884 when 196,
            
            916989 when 197,
            
            562312 when 198,
            
            590036 when 199,
            
            670500 when 200,
            
            669573 when 201,
            
            181011 when 202,
            
            217331 when 203,
            
            1001904 when 204,
            
            826018 when 205,
            
            858475 when 206,
            
            425331 when 207,
            
            392876 when 208,
            
            701455 when 209,
            
            415823 when 210,
            
            888690 when 211,
            
            100715 when 212,
            
            245688 when 213,
            
            998383 when 214,
            
            338555 when 215,
            
            112568 when 216,
            
            45327 when 217,
            
            544166 when 218,
            
            899428 when 219,
            
            630012 when 220,
            
            353477 when 221,
            
            225957 when 222,
            
            886627 when 223,
            
            76110 when 224,
            
            512116 when 225,
            
            637186 when 226,
            
            450736 when 227,
            
            656720 when 228,
            
            767621 when 229,
            
            253520 when 230,
            
            1028228 when 231,
            
            1027595 when 232,
            
            62491 when 233,
            
            549027 when 234,
            
            806372 when 235,
            
            173607 when 236,
            
            806890 when 237,
            
            433031 when 238,
            
            251299 when 239,
            
            353368 when 240,
            
            195671 when 241,
            
            912400 when 242,
            
            499952 when 243,
            
            799258 when 244,
            
            535754 when 245,
            
            275318 when 246,
            
            915459 when 247,
            
            387438 when 248,
            
            537943 when 249,
            
            845040 when 250,
            
            542241 when 251,
            
            672550 when 252,
            
            979306 when 253,
            
            408515 when 254,
            
            744574 when 255,
            
            1 when others;*/
end Behavioral;
