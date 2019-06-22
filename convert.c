#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
	FILE *outfile, *infile;
	unsigned char buf1[32];
	unsigned char buf2[32];
	outfile = fopen("font.bin", "wb");
	infile = fopen("font.gbc", "rb");
	for(int i=0; i<0x3FE40; i+=32) {
		fread(buf1, 1, 32, infile);
		for(int x=0; x<8; ++x) {
			buf2[x] = buf1[2*x];
			buf2[8+x] = buf1[2*x+1];
			buf2[16+x] = buf1[16+2*x];
			buf2[24+x] = buf1[17+2*x];
		}
		fwrite(buf2, 1, 32, outfile);
	}
	fclose(infile);
	fclose(outfile);
	return 0;
}
