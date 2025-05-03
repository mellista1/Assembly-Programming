#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"


uint32_t catalogo[32];

char *productos[256] = {"Intel Core i9 9900K", "AMD Ryzen 9 3900X", "Nvidia RTX 2080 Ti", "AMD Radeon RX 5700 XT", "Corsair Vengeance LPX 16GB", "G.Skill Trident Z RGB 16GB", "Samsung 970 EVO 1TB", "Crucial MX500 1TB", "Corsair RM750x", "Seasonic Focus Plus Gold 750W", "NZXT H510", "Fractal Design Meshify C", "Cooler Master Hyper 212", "Noctua NH-D15", "Asus ROG Strix Z390-E", "Gigabyte X570 Aorus Elite", "MSI RTX 2080 Super", "Sapphire RX 5700 XT Nitro+", "Kingston HyperX Fury 16GB", "Patriot Viper Steel 16GB", "Western Digital Blue 1TB", "Seagate Barracuda 1TB", "EVGA SuperNOVA 750 G3", "Thermaltake Toughpower Grand RGB 750W", "Phanteks P400A", "Lian Li Lancool II", "be quiet! Dark Rock Pro 4", "Thermalright Le Grand Macho RT", "Asrock Z390 Taichi", "MSI B450 Tomahawk Max", "Zotac RTX 2080 Super AMP", "PowerColor RX 5700 XT Red Devil", "Intel Core i7 9700K", "AMD Ryzen 7 3700X", "Nvidia RTX 2070 Super", "AMD Radeon RX 5600 XT", "Corsair Vengeance RGB Pro 32GB", "G.Skill Ripjaws V 32GB", "Samsung 860 EVO 500GB", "Crucial P1 1TB", "Corsair CX650M", "Seasonic S12III 650W", "NZXT H710", "Fractal Design Define R6", "Cooler Master MasterLiquid ML240R", "Noctua NH-U12S", "Asus TUF Gaming X570-Plus", "Gigabyte Z390 Aorus Pro", "MSI GTX 1660 Ti", "Sapphire RX 580 Pulse", "Kingston A2000 1TB", "Patriot Burst 480GB", "Western Digital Black 2TB", "Seagate FireCuda 2TB", "EVGA 600 W1", "Thermaltake Smart 600W", "Phanteks Eclipse P300", "Lian Li PC-O11 Dynamic", "be quiet! Pure Rock", "Thermalright Macho Rev. B", "Asrock B450 Steel Legend", "MSI MPG Z390 Gaming Edge AC", "Zotac GTX 1660 Super", "PowerColor RX 590 Red Dragon", "Intel Core i5 9600K", "AMD Ryzen 5 3600", "Nvidia GTX 1660", "AMD Radeon RX 5500 XT", "Corsair Dominator Platinum 16GB", "G.Skill Sniper X 16GB", "Samsung 970 Pro 512GB", "Crucial BX500 480GB", "Corsair TX750M", "Seasonic Prime Ultra 750W", "NZXT H200", "Fractal Design Node 202", "Cooler Master MasterAir MA410M", "Noctua NH-L9i", "Asus Prime Z390-A", "Gigabyte B450 Aorus M", "MSI RX 570 Armor", "Sapphire RX 590 Nitro+", "Kingston KC2000 1TB", "Patriot Scorch 512GB", "Western Digital Red 4TB", "Seagate IronWolf 4TB", "EVGA 500 W1", "Thermaltake TR2 600W", "Phanteks Enthoo Pro", "Lian Li PC-Q37", "be quiet! Shadow Rock 3", "Thermalright Silver Arrow IB-E", "Asrock X570 Phantom Gaming 4", "MSI Z390-A Pro", "Zotac GTX 1650 Super", "PowerColor RX 580 Red Devil", "Intel Core i3 9100F", "AMD Ryzen 3 3200G", "Nvidia GTX 1650", "AMD Radeon RX 570", "Corsair Vengeance LPX 8GB", "G.Skill Aegis 8GB", "Samsung 860 QVO 1TB", "Crucial P2 500GB", "Corsair VS550", "Seasonic M12II 620W", "NZXT H1", "Fractal Design Core 500", "Cooler Master MasterLiquid ML120L", "Noctua NH-L12S", "Asus ROG Strix B450-F", "Gigabyte Z390 UD", "MSI RX 560 Aero", "Sapphire RX 570 Pulse", "Kingston UV500 480GB", "Patriot Burst Elite 240GB", "Western Digital Green 2TB", "Seagate SkyHawk 2TB", "EVGA 450 BT", "Thermaltake Litepower 450W", "Phanteks Evolv Shift", "Lian Li PC-TU150", "be quiet! Pure Rock Slim", "Thermalright AXP-100", "Asrock H370M-ITX/ac", "MSI B450 Gaming Plus Max", "Zotac GTX 1050 Ti", "PowerColor RX 560 Red Dragon", "Intel Pentium G5400", "AMD Athlon 3000G", "Nvidia GT 1030", "AMD Radeon R7 240", "Corsair Vengeance RGB Pro 16GB", "G.Skill Ripjaws 16GB", "Samsung 850 EVO 250GB", "Crucial MX300 525GB", "Corsair SF600", "Seasonic Focus SGX 650W", "NZXT H440", "Fractal Design Define Mini C", "Cooler Master MasterAir MA620P", "Noctua NH-U14S", "Asus Prime B450M-A", "Gigabyte B450M DS3H", "MSI GTX 1050", "Sapphire R7 370", "Kingston A400 240GB", "Patriot Ignite 480GB", "Western Digital Purple 1TB", "Seagate Exos 1TB", "EVGA 400 N1", "Thermaltake Smart RGB 500W", "Phanteks Evolv X", "Lian Li PC-O11 Air", "be quiet! Dark Rock Slim", "Thermalright Macho Direct", "Asrock B365M Pro4", "MSI H310M Pro-VDH Plus", "Zotac GTX 1070 Mini", "PowerColor R9 380", "Intel Celeron G4930", "AMD A6-9500", "Nvidia Quadro P400", "AMD FirePro W4100", "Corsair Dominator Platinum RGB 32GB", "G.Skill Trident Z Royal 32GB", "Samsung 970 EVO Plus 2TB", "Crucial P5 1TB", "Corsair HX850", "Seasonic Prime Titanium 850W", "NZXT S340", "Fractal Design Define S2", "Cooler Master MasterLiquid ML360R", "Noctua NH-D9L", "Asus TUF Gaming B550-Plus", "Gigabyte Z490 Aorus Master", "MSI GTX 1080 Ti", "Sapphire RX Vega 64", "Kingston HyperX Predator 32GB", "Patriot Viper 4 32GB", "Western Digital Gold 4TB", "Seagate IronWolf Pro 4TB", "EVGA 850 GQ", "Thermaltake Toughpower PF1 850W", "Phanteks Evolv Shift X", "Lian Li PC-O11 Dynamic XL", "be quiet! Pure Loop 240mm", "Thermalright True Spirit 140", "Asrock X299 Taichi", "MSI MEG Z490 Godlike", "Zotac RTX 2070 Super Mini", "PowerColor RX Vega 56 Red Devil", "Intel Xeon E-2288G", "AMD Ryzen Threadripper 3960X", "Nvidia Titan RTX", "AMD Radeon Pro WX 9100", "Corsair Vengeance LPX 64GB", "G.Skill Trident Z Neo 64GB", "Samsung 860 EVO 4TB", "Crucial MX500 2TB", "Corsair AX1600i", "Seasonic Prime Ultra 1000W", "NZXT H710i", "Fractal Design Define R5", "Cooler Master MasterAir MA410P", "Noctua NH-C14S", "Asus ROG Crosshair VIII Hero", "Gigabyte X299 Designare EX", "MSI RTX 2080 Ti Gaming X Trio", "Sapphire RX 5700 XT Pulse", "Kingston HyperX Savage 32GB", "Patriot Viper Steel 32GB", "Western Digital Ultrastar 10TB", "Seagate Exos X16 10TB", "EVGA SuperNOVA 1000 T2", "Thermaltake Toughpower iRGB Plus 1000W", "Phanteks Enthoo Evolv ATX", "Lian Li PC-O11 WGX", "be quiet! Silent Loop 360mm", "Thermalright Macho Rev. C", "Asrock TRX40 Taichi", "MSI Creator TRX40", "Zotac RTX 2080 Ti ArcticStorm", "PowerColor RX 5700 XT Liquid Devil", "Intel Core i9 10900K", "AMD Ryzen 9 3950X", "Nvidia RTX 3090", "AMD Radeon RX 6800 XT", "Corsair Vengeance RGB Pro 64GB", "G.Skill Trident Z RGB 64GB", "Samsung 980 Pro 1TB", "Crucial P5 Plus 1TB", "Corsair RM850x", "Seasonic Focus GX 850W", "NZXT H510 Elite", "Fractal Design Meshify S2", "Cooler Master MasterLiquid ML240L", "Noctua NH-U12A", "Asus ROG Strix X570-E", "Gigabyte Z490 Vision G", "MSI RTX 3070 Gaming X Trio", "Sapphire RX 6800 XT Nitro+", "Kingston Fury Renegade 32GB", "Patriot Viper RGB 32GB", "Western Digital Black SN750 1TB", "Seagate FireCuda 520 1TB", "EVGA SuperNOVA 850 P2", "Thermaltake Toughpower GF1 850W", "Phanteks Eclipse P500A", "Lian Li Lancool 215", "be quiet! Dark Rock TF", "Thermalright Le Grand Macho RT", "Asrock Z490 Taichi", "MSI MPG B550 Gaming Edge WiFi", "Zotac RTX 3080 Trinity", "PowerColor RX 6800 XT Red Devil"};


void imprimir_producto(FILE *pfile, uint32_t id, uint32_t precio, uint32_t moneda, uint32_t stock)
{

    char* prod = productos[id]; //Para el nombre del producto accedo al array utilizando como indice el id/
    char* mon = moneda?"USD":"ARG"; //aqui uso un condicional para que si moneda == 1 == TRUE, entonces imprima USD. En caso contrario imprime ARG/

    fprintf(pfile,"%s, %u, %s, %u\n", prod, precio, mon, stock);
    
}

void procesar_e_imprimir_catalogo(FILE *pfile)
{

    fprintf(pfile, "Nombre del producto, Precio, Moneda, Stock\n");

    /* Primero necesito identificar del array cada elemento por separado. Como se trata de posiciones de memoria seguidas, necesito utilizar shifts o mascaras para poder dividir correctamente los datos*/
    uint32_t ID1;
    uint32_t ID2;
    uint32_t precio1;
    uint32_t precio2;
    uint32_t moneda1;
    uint32_t moneda2;
    uint32_t stock1;
    uint32_t stock2;
    int i= 0;

    for (size_t i = 0; i < 32; i=i+2)
    {
        ID1 = (catalogo[i]&0xFF000000)>>24;

        ID2= ((catalogo[i] & 0x00FF0000)<<8)>>24;

        precio1 = ((catalogo[i] & 0x0000FFF0))>>4;

        moneda1 = ((catalogo[i] & 0x00000008)<<28)>>31;

        moneda2 = ((catalogo[i+1] & 0x00400000)<<9)>>31;

        stock1 = ((catalogo[i+1] & 0x003FF800)<<10)>>21;

        stock2 = ((catalogo[i+1] & 0x000007FF)<<21)>>21;

        uint32_t val1= (catalogo[i] & 0x00000007) << 9;
        uint32_t val2 = (catalogo[i+1] & 0xFF800000) >> 23;
        precio2 = val1 | val2;

        imprimir_producto(pfile, ID1, precio1, moneda1, stock1);

        imprimir_producto(pfile, ID2, precio2, moneda2, stock2);
    }
    }
