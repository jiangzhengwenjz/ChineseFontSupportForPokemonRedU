#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
	FILE *outfile, *infile;
	unsigned char buf[15040];
	char namebuf[100];
	sprintf(namebuf,"font");
	infile = fopen("font.gbc", "rb");
	for(int i=0; i<17; ++i) {
		fread(buf,1, 15040, infile);
		sprintf(namebuf+4, "%d.gbc", i);
		outfile = fopen(namebuf,"wb");
		fwrite(buf,1,15040,outfile);
		fclose(outfile);
	}
	fread(buf, 1, 6016, infile);
	sprintf(namebuf+4, "%d.gbc", 17);
	outfile = fopen(namebuf, "wb");
	fwrite(buf, 1, 6016, outfile);
	fclose(outfile);
	fclose(infile);
	return 0;
}
