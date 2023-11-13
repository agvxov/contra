#include "cli.h"

#include <getopt.h>
#include <stdio.h>

const char * const version =
# include "version.inc"
;

const char * help_message =
"?! [options] <file>+\n"
"    -c        : the input is to be force interpeted as CSML\n"
"    -x        : the input is to be force interpeted as XML/HTML\n"
"    -o <file> : specify output file name for the NEXT file\n"
"    -q <char> : use <char> for quoting (default: \"'\")\n"
"    -v        : print version and quit\n"
"    -h        : print help and quit\n"
;

signed parse_r1_arguments(int argc, char * * argv){
	const char * const optstring = "hv" "cxo:q:";

    static struct option long_options[] = {
        {"help", no_argument, 0, 'h'},
        {"version", no_argument, 0, 'v'},
        {0, 0, 0, 0}
    };
	
	char opt;
    while ((opt = getopt_long(argc, argv, optstring, long_options, NULL)) != -1) {
        switch (opt) {
            case 'h': {
				fputs(help_message, stdout);
			} return 1;
            case 'v': {
				fputs(version, stdout);
			} return 1;
            case '?': {
			} return 2;
			default: {
			} break;
        }
    }

	return 0;
}
