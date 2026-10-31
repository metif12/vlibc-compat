#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int vc_strlen(const char* s);
extern int vc_write_file(const char* path, const char* data);
extern const char* vc_read_file(const char* path);

int main(void) {
    const char* msg = "hello from consumer";
    int n = vc_strlen(msg);
    printf("len=%d\n", n);
    if (vc_write_file("/tmp/consumer_out.txt", msg) != 0) {
        fprintf(stderr, "write failed\n");
        return 1;
    }
    const char* r = vc_read_file("/tmp/consumer_out.txt");
    printf("read=%s\n", r ? r : "(null)");
    return 0;
}
