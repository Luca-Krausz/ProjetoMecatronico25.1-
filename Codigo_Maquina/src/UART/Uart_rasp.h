#ifndef UART_H
#define UART_H

#include "mbed.h"

class Leitor_UART {
public:
    explicit Leitor_UART(BufferedSerial &serial);

    bool getLine(char *dest, size_t maxLen);

private:
    BufferedSerial &_serial;
    static constexpr size_t BUF_LEN = 128;
    char _buf[BUF_LEN];
    size_t _idx = 0;    
};

#endif // UART_H