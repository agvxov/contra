#ifndef CLI_H

#include <vector>
#include <string>

/* Used for outputting a help message as the default behaviour
 */
extern bool did_any_work;

extern "C" void usage(void);

extern "C" signed parse_colon_list(char * const list, std::vector<std::string> destination);
extern "C" signed parse_sets(char * const list);

/* Parse arguments with global effects (-h)
 * Perform validation.
 */
extern "C" signed parse_round1_arguments(int argc, char * * argv);

/* Parse context sensitive arguments
 */
extern "C" signed parse_round2_arguments(int argc, char * * argv);

#define CLI_H
#endif
