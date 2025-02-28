#include "mbed.h"

BusOut DP(D3, D4, D5, D6);
float t = 0.005;


int main (){

    while (true) {

        DP.write(0x8);
            wait(t);
        DP.write(0x4);
            wait(t);
        DP.write(0x2);
            wait(t);
        DP.write(0x1);
            wait(t);
    
    }
}