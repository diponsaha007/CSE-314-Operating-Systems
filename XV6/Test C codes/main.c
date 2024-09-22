#include <stdio.h>

struct info{
    int x,y
};

void inc(struct info *a)
{
    a->x++;
}
int main()
{
    struct info a;
    a.x = 0;
    a.y = 0;
    inc(&a);
    inc(&a);
    inc(&a);
    inc(&a);
    printf("%d\n",a.x);
    return 0;
}
