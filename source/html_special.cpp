#include "html_special.hpp"

const size_t html_special_table_size =
	sizeof(html_special_table)
		/
	sizeof(html_special_table[0]);

extern "C"
const char * html_special_table_lookup(const char * const name) {
	// XXX: this should be a iterating-decreasing jump search
	for (size_t i = 0; i < html_special_table_size; i++) {
		if (!strcmp(name, html_special_table[i][0])) {
			return html_special_table[i][1];
		}
	}
	return NULL;
}

extern "C"
const char * html_special_to_utf8(const char * const special) {
	static std::string r;
	r = std::string(special);
	trim(r);
	uint32_t i(std::stoi(r));	// XXX: with no-exception this is suicide
	std::wstring_convert<std::codecvt_utf8<char32_t>, char32_t> conv1;
	r = conv1.to_bytes(i);
	return r.c_str();
}

extern "C"
const char * utf8_to_html_special(const char * const utf) {
	for (size_t i = 0; i < html_special_table_size; i++) {
		if (!strcmp(utf, html_special_table[i][2])) {
			fflush(stdout);
			return html_special_table[i][0];
		}
	}
	
	return utf;
}
