#include "Uart_rasp.h"
#include <cstdio>
#include <cstring>

Leitor_UART::Leitor_UART(BufferedSerial &serial) : _serial(serial) {}

bool Leitor_UART::getLine(char *dest, size_t maxLen)
{
    while(_serial.readable())
    {
        char c;
        if (_serial.read(&c, 1) != 1) {
            printf("ERROR!\r\n");   
            break;
        }
        if (c == '\r' || c == '\n'){
            if (_idx == 0) continue;

            _buf[_idx++] = '\0';
            std::strncpy(dest, _buf, maxLen);
            _idx = 0;
            return true;
        }

        else if (_idx < BUF_LEN - 1){
            _buf[_idx++] = c;
        } else {
            _idx = 0;
        }
    }
    
    return false;
}