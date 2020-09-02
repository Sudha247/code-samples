#include<stdio.h>
#include<stdatomic.h>
#include<pthread.h>

_Atomic int acnt;
void *adding(void *input)
{
    acnt++;
    pthread_exit(NULL);
}
int main()
{
    pthread_t tid[10];
    for(int i=0; i<10; i++)
        pthread_create(&tid[i],NULL,adding,NULL);
    for(int i=0; i<10; i++)
        pthread_join(tid[i],NULL);

    printf("the value of cnt is %d\n", acnt);
    return 0;
}