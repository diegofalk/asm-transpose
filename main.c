/*
 * Author:    Diego Falk
 * Created:   19.12.2020
 */

#include <stdio.h>
#include <stdint.h>
#include <string.h>

// asm function to transpose 16x16 matrix
void transpose16x16(uint8_t*, uint8_t*);

// c function to transpose 16x16 matrix
void transpose16x16_c(uint8_t *x, uint8_t *y){
    for (int j=0;j<16;j++)
        for (int i=0;i<16;i++)
            y[j+16*i] = x[i+16*j];
}

// print square matrix of size n
void print_matrix(uint8_t *x,uint8_t n) {
    for (int j=0;j<n;j++) {
        for (int i=0;i<n;i++)
            printf("%02x\t", x[i+j*n]);
        printf("\n");
    }
}

// fill 16x16 matrix with values from [0x00 to 0xff]
void fill_matrix(uint8_t *x) {
    for (uint16_t i=0;i<256;i++)
        x[i] = (uint8_t)i;
}

int main() {

    // aux variables
    uint8_t x[256] = {0};       // input
    uint8_t y[256] = {0};       // asm output
    uint8_t z[256] = {0};       // c ouput

    fill_matrix(x);             // fill input matrix with values from [0x00 to 0xff]

    transpose16x16(x, y);       // transpose matrix using asm function
    transpose16x16_c(x, z);     // transpose matrix using c funciton

    // print results
    printf("\n");
    printf("-------------- X -------------\n");
    print_matrix(x,16);
    printf("\n");
    printf("-------------- Y -------------\n");
    print_matrix(y,16);
    printf("\n");
    printf("-------------- Z -------------\n");
    print_matrix(z,16);
    
    // compare results
    int ret = memcmp(y, z, 255);
    if (ret)
        printf("Matrices differ\n");
    else
        printf("Matrices are equal\n");

    return 0;
}