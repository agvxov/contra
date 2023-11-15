#include "cli.hpp"

#include "exit_values.hpp"

#include <getopt.h>
#include <stdio.h>

const char * const version =
# include "version.inc"
;

const char * const help_message =
"contra [options] <file>+\n"
"    -c          : the input is to be force interpeted as CSML\n"
"    -x          : the input is to be force interpeted as XML/HTML\n"
"    -i <string> : colon separeted list of tags which contents should be ignored\n"
"    -o <file>   : specify output file name for the NEXT file\n"
"    -q <char>   : use <char> for quoting (default: \"'\")\n"
"    -v          : print version and quit\n"
"    -h          : print help and quit\n"
;

signed parse_round1_arguments(int argc, char * * argv){
	const char * const optstring = "-" "hv" "cxi:o:q:";

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
			} return EXIT_EARLY_SUCCESS;
            case 'v': {
				fputs(version, stdout);
			} return EXIT_EARLY_SUCCESS;
            case '?': {
			} return UNKNOWN_OPTION;
			default: {
			} break;
        }
    }

	return 0;
}
