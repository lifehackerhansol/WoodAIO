#include <fcntl.h>
#include <stdio.h>
#include <sys/stat.h>

bool engine2_access(int gamecode, int *address) {
    int iVar2;

    int f = fopen("fat0:/__rpg/engi.ne2", "rb");
    if (f) {
        fseek(f, 0, SEEK_END);
        int size = ftell(f);
        if (size != 0) {
            fseek(f, 0, SEEK_SET);
            fread(f, address, size);
            for (int i = size >> 2; i != 0; i--) {
                iVar2 = *address;
                address = address + 1;
                if (param_1 == iVar2) {
                    close(fd);
                    return true;
                }
            }
        }
        close(fd);
    }
    return false;
}
