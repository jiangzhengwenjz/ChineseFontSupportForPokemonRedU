#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
	FILE *outfile, *infile;
	unsigned char buf[16384-15040];
	short sum=0;
	outfile = fopen("PokemonBrown54.gb", "rb+");
	infile = fopen("textreader.bin", "rb");
	fseek(infile, 0x1955, SEEK_SET);
	fseek(outfile, 0x1955, SEEK_SET);
	fread(buf, 1, 0x1A00-0x1955, infile);
	fwrite(buf, 1, 0x1A00-0x1955, outfile);
	fseek(infile, 0x200000, SEEK_SET);
	fseek(outfile, 0x200000, SEEK_SET);
//	for(int i=0; i<18; ++i) {
		fread(buf, 1, 16384-15040, infile);
		fwrite(buf, 1, 16384-15040, outfile);
//		fseek(infile, 15040, SEEK_CUR);
//		fseek(outfile, 15040, SEEK_CUR);
//	}
	fseek(infile, 0x9526C, SEEK_SET);
	fseek(outfile, 0x9526C, SEEK_SET);
	fread(buf, 1, 17, infile);
	fwrite(buf, 1, 17, outfile);
	fclose(infile);
	fclose(outfile);
	return 0;
}
