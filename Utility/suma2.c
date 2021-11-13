#include <stdio.h>
/* prototipo para la rutina ensamblador */
int calc_sum(int) __attribute__((cdecl));

int main(void){
    int n;

    printf("Sumar enteros hasta: ");
    scanf("%d", &n);
    printf("Sum is %d\n", calc_sum(n));
    return 0;
}
