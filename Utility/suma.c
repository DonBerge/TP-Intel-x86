#include <stdio.h>
/* prototipo para la rutina ensamblador */
void calc_sum(int, int *) __attribute__((cdecl));

int main(void){
    int n, sum;

    printf("Sumar enteros hasta: ");
    scanf("%d", &n);
    calc_sum(n, &sum);
    printf("Sum is %d\n", sum);
    return 0;
}
