/*
  this was written quickly. There are checks to avoid few kinds of
  problems, but it isn't tested with malicious files - just with files
  which contain PNGs for real.

  USE IT AT YOUR OWN RISK.

  Also, portability wasn't in my mind at all.

 */
#define _LARGEFILE64_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <inttypes.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>


static const uint8_t sig[] = { 137, 80, 78, 71, 13, 10, 26, 10 };
static const size_t siglen = sizeof (sig) / sizeof (sig[0]);
static const size_t minpng = siglen + 4 + 4 + 4;


#define GET4(S) ((((((s[0] << 8) | s[1]) << 8) | s[2]) << 8) | s[3])

void dumpfile(int idx, uint8_t *from, size_t len)
{
    char fname[32];
    sprintf(fname, "png%05d.png", idx);
    FILE *f = fopen(fname, "wb");
    if (f == NULL) {
        perror("fopen");
        return;
    }
    size_t wlen = fwrite(from, len, 1, f);
    if (wlen != 1) {
        perror("fwrite");
    }
    fclose(f);
}

uint8_t *search_file(uint8_t *s, uint8_t *e, int d)
{
    int r;
    while (s < (e - siglen) && (r = memcmp(sig, s, siglen)) != 0) ++s;
    if (r == 0) {
        uint8_t *png_begin = s;
        s += siglen;
        while ((r = memcmp("IEND", s+4, 4)) != 0 && s < (e - 8)) {
            s += 4 + 4 + 4 + GET4(s);
        }
        if (r == 0) {
            s += 4 + 4 + 4;
            uint8_t *png_end = s;
            dumpfile(d, png_begin, png_end - png_begin);
        }
    }
    return s;
}

int main(int argc, char **argv)
{
    int fd = open(argv[1], O_RDONLY|O_LARGEFILE);
    if (fd < 0) {
        perror("open");
        return EXIT_FAILURE;
    }
    
    struct stat st;
    if (fstat(fd, &st) < 0) {
        perror("fstat");
        close(fd);
        return EXIT_FAILURE;
    }

    if (st.st_size < minpng) {
        fprintf(stderr, "no room for a minimal PNG\n");
        close(fd);
        return EXIT_FAILURE;
    }
    
    uint8_t *m = mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (m == MAP_FAILED) {
        perror("mmap");
        close(fd);
        return EXIT_FAILURE;
    }
    
    close(fd);

    uint8_t *mend = m + st.st_size;

    int d = 0;
    while (m < (mend - minpng))
        m = search_file(m, mend, d++);


    munmap(m, st.st_size);
    return 0;
}
