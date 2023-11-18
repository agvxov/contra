#ifndef HTML_SPECIAL_HPP

#include <string.h>
#include <string>
#include <codecvt>
#include <locale>
#include "global.hpp"

extern "C"
const char * html_special_table_lookup(const char * const name);

extern "C"
const char * html_special_to_utf8(const char * const special);

extern "C"
const char * utf8_to_html_special(const char * const utf);

inline
const char * const html_special_table[][3] = 
{
	{"&Aacute;",  "&#193;",  "Á"},
	{"&aacute;",  "&#225;",  "á"},
	{"&Acirc;",   "&#194;",  "Â"},
	{"&acirc;",   "&#226;",  "â"},
	{"&acute;",   "&#180;",  "´"},
	{"&AElig;",   "&#198;",  "Æ"},
	{"&aelig;",   "&#230;",  "æ"},
	{"&Agrave;",  "&#192;",  "À"},
	{"&agrave;",  "&#224;",  "à"},
	{"&Alpha;",   "&#913;",  "Α"},
	{"&alpha;",   "&#945;",  "α"},
	{"&amp;",     "&#38;",   "&"},
	{"&and;",     "&#8743;", "∧"},
	{"&ang;",     "&#8736;", "∠"},
	{"&apos;",    "&#39;",   "'"},
	{"&Aring;",   "&#197;",  "Å"},
	{"&aring;",   "&#229;",  "å"},
	{"&asymp;",   "&#8776;", "≈"},
	{"&Atilde;",  "&#195;",  "Ã"},
	{"&atilde;",  "&#227;",  "ã"},
	{"&Auml;",    "&#196;",  "Ä"},
	{"&auml;",    "&#228;",  "ä"},
	{"&bdquo;",   "&#8222;", "„"},
	{"&Beta;",    "&#914;",  "Β"},
	{"&beta;",    "&#946;",  "β"},
	{"&brvbar;",  "&#166;",  "¦"},
	{"&bull;",    "&#8226;", "•"},
	{"&cap;",     "&#8745;", "∩"},
	{"&Ccedil;",  "&#199;",  "Ç"},
	{"&ccedil;",  "&#231;",  "ç"},
	{"&cedil;",   "&#184;",  "¸"},
	{"&cent;",    "&#162;",  "¢"},
	{"&Chi;",     "&#935;",  "Χ"},
	{"&chi;",     "&#967;",  "χ"},
	{"&circ;",    "&#710;",  "ˆ"},
	{"&clubs;",   "&#9827;", "♣"},
	{"&cong;",    "&#8773;", "≅"},
	{"&copy;",    "&#169;",  "©"},
	{"&crarr;",   "&#8629;", "↵"},
	{"&cup;",     "&#8746;", "∪"},
	{"&curren;",  "&#164;",  "¤"},
	{"&dagger;",  "&#8224;", "†"},
	{"&Dagger;",  "&#8225;", "‡"},
	{"&darr;",    "&#8595;", "↓"},
	{"&deg;",     "&#176;",  "°"},
	{"&Delta;",   "&#916;",  "Δ"},
	{"&delta;",   "&#948;",  "δ"},
	{"&diams;",   "&#9830;", "♦"},
	{"&divide;",  "&#247;",  "÷"},
	{"&Eacute;",  "&#201;",  "É"},
	{"&eacute;",  "&#233;",  "é"},
	{"&Ecirc;",   "&#202;",  "Ê"},
	{"&ecirc;",   "&#234;",  "ê"},
	{"&Egrave;",  "&#200;",  "È"},
	{"&egrave;",  "&#232;",  "è"},
	{"&empty;",   "&#8709;", "∅"},
	{"&emsp;",    "&#8195;", ""},
	{"&ensp;",    "&#8194;", ""},
	{"&Epsilon;", "&#917;",  "Ε"},
	{"&epsilon;", "&#949;",  "ε"},
	{"&equiv;",   "&#8801;", "≡"},
	{"&Eta;",     "&#919;",  "Η"},
	{"&eta;",     "&#951;",  "η"},
	{"&ETH;",     "&#208;",  "Ð"},
	{"&eth;",     "&#240;",  "ð"},
	{"&Euml;",    "&#203;",  "Ë"},
	{"&euml;",    "&#235;",  "ë"},
	{"&euro;",    "&#8364;", "€"},
	{"&exist;",   "&#8707;", "∃"},
	{"&fnof;",    "&#402;",  "ƒ"},
	{"&forall;",  "&#8704;", "∀"},
	{"&frac12;",  "&#189;",  "½"},
	{"&frac14;",  "&#188;",  "¼"},
	{"&frac34;",  "&#190;",  "¾"},
	{"&Gamma;",   "&#915;",  "Γ"},
	{"&gamma;",   "&#947;",  "γ"},
	{"&ge;",      "&#8805;", "≥"},
	{"&gt;",      "&#62;",   ">"},
	{"&harr;",    "&#8596;", "↔"},
	{"&hearts;",  "&#9829;", "♥"},
	{"&hellip;",  "&#8230;", "…"},
	{"&Iacute;",  "&#205;",  "Í"},
	{"&iacute;",  "&#237;",  "í"},
	{"&Icirc;",   "&#206;",  "Î"},
	{"&icirc;",   "&#238;",  "î"},
	{"&iexcl;",   "&#161;",  "¡"},
	{"&Igrave;",  "&#204;",  "Ì"},
	{"&igrave;",  "&#236;",  "ì"},
	{"&infin;",   "&#8734;", "∞"},
	{"&int;",     "&#8747;", "∫"},
	{"&Iota;",    "&#921;",  "Ι"},
	{"&iota;",    "&#953;",  "ι"},
	{"&iquest;",  "&#191;",  "¿"},
	{"&isin;",    "&#8712;", "∈"},
	{"&Iuml;",    "&#207;",  "Ï"},
	{"&iuml;",    "&#239;",  "ï"},
	{"&Kappa;",   "&#922;",  "Κ"},
	{"&kappa;",   "&#954;",  "κ"},
	{"&Lambda;",  "&#923;",  "Λ"},
	{"&lambda;",  "&#955;",  "λ"},
	{"&laquo;",   "&#171;",  "«"},
	{"&larr;",    "&#8592;", "←"},
	{"&lceil;",   "&#8968;", "⌈"},
	{"&ldquo;",   "&#8220;", "“"},
	{"&le;",      "&#8804;", "≤"},
	{"&lfloor;",  "&#8970;", "⌊"},
	{"&lowast;",  "&#8727;", "∗"},
	{"&loz;",     "&#9674;", "◊"},
	{"&lrm;",     "&#8206;", ""},
	{"&lsaquo;",  "&#8249;", "‹"},
	{"&lsquo;",   "&#8216;", "‘"},
	{"&lt;",      "&#60;",   "<"},
	{"&macr;",    "&#175;",  "¯"},
	{"&mdash;",   "&#8212;", "—"},
	{"&micro;",   "&#181;",  "µ"},
	{"&middot;",  "&#183;",  "·"},
	{"&minus;",   "&#8722;", "−"},
	{"&Mu;",      "&#924;",  "Μ"},
	{"&mu;",      "&#956;",  "μ"},
	{"&nabla;",   "&#8711;", "∇"},
	{"&nbsp;",    "&#160;",  " "},
	{"&ndash;",   "&#8211;", "–"},
	{"&ne;",      "&#8800;", "≠"},
	{"&ni;",      "&#8715;", "∋"},
	{"&not;",     "&#172;",  "¬"},
	{"&notin;",   "&#8713;", "∉"},
	{"&nsub;",    "&#8836;", "⊄"},
	{"&Ntilde;",  "&#209;",  "Ñ"},
	{"&ntilde;",  "&#241;",  "ñ"},
	{"&Nu;",      "&#925;",  "Ν"},
	{"&nu;",      "&#957;",  "ν"},
	{"&Oacute;",  "&#211;",  "Ó"},
	{"&oacute;",  "&#243;",  "ó"},
	{"&Ocirc;",   "&#212;",  "Ô"},
	{"&ocirc;",   "&#244;",  "ô"},
	{"&OElig;",   "&#338;",  "Œ"},
	{"&oelig;",   "&#339;",  "œ"},
	{"&Ograve;",  "&#210;",  "Ò"},
	{"&ograve;",  "&#242;",  "ò"},
	{"&oline;",   "&#8254;", "‾"},
	{"&Omega;",   "&#937;",  "Ω"},
	{"&omega;",   "&#969;",  "ω"},
	{"&Omicron;", "&#927;",  "Ο"},
	{"&omicron;", "&#959;",  "ο"},
	{"&oplus;",   "&#8853;", "⊕"},
	{"&or;",      "&#8744;", "∨"},
	{"&ordf;",    "&#170;",  "ª"},
	{"&ordm;",    "&#186;",  "º"},
	{"&Oslash;",  "&#216;",  "Ø"},
	{"&oslash;",  "&#248;",  "ø"},
	{"&Otilde;",  "&#213;",  "Õ"},
	{"&otilde;",  "&#245;",  "õ"},
	{"&otimes;",  "&#8855;", "⊗"},
	{"&Ouml;",    "&#214;",  "Ö"},
	{"&ouml;",    "&#246;",  "ö"},
	{"&para;",    "&#182;",  "¶"},
	{"&part;",    "&#8706;", "∂"},
	{"&permil;",  "&#8240;", "‰"},
	{"&perp;",    "&#8869;", "⊥"},
	{"&Phi;",     "&#934;",  "Φ"},
	{"&phi;",     "&#966;",  "φ"},
	{"&Pi;",      "&#928;",  "Π"},
	{"&pi;",      "&#960;",  "π"},
	{"&piv;",     "&#982;",  "ϖ"},
	{"&plusmn;",  "&#177;",  "±"},
	{"&pound;",   "&#163;",  "£"},
	{"&prime;",   "&#8242;", "′"},
	{"&Prime;",   "&#8243;", "″"},
	{"&prod;",    "&#8719;", "∏"},
	{"&prop;",    "&#8733;", "∝"},
	{"&Psi;",     "&#936;",  "Ψ"},
	{"&psi;",     "&#968;",  "ψ"},
	{"&quot;",    "&#34;",   "\""},
	{"&radic;",   "&#8730;", "√"},
	{"&raquo;",   "&#187;",  "»"},
	{"&rarr;",    "&#8594;", "→"},
	{"&rceil;",   "&#8969;", "⌉"},
	{"&rdquo;",   "&#8221;", "”"},
	{"&reg;",     "&#174;",  "®"},
	{"&rfloor;",  "&#8971;", "⌋"},
	{"&Rho;",     "&#929;",  "Ρ"},
	{"&rho;",     "&#961;",  "ρ"},
	{"&rlm;",     "&#8207;", ""},
	{"&rsaquo;",  "&#8250;", "›"},
	{"&rsquo;",   "&#8217;", "’"},
	{"&sbquo;",   "&#8218;", "‚"},
	{"&Scaron;",  "&#352;",  "Š"},
	{"&scaron;",  "&#353;",  "š"},
	{"&sdot;",    "&#8901;", "⋅"},
	{"&sect;",    "&#167;",  "§"},
	{"&shy;",     "&#173;",  "­"},
	{"&Sigma;",   "&#931;",  "Σ"},
	{"&sigma;",   "&#963;",  "σ"},
	{"&sigmaf;",  "&#962;",  "ς"},
	{"&sim;",     "&#8764;", "∼"},
	{"&spades;",  "&#9824;", "♠"},
	{"&sub;",     "&#8834;", "⊂"},
	{"&sube;",    "&#8838;", "⊆"},
	{"&sum;",     "&#8721;", "∑"},
	{"&sup1;",    "&#185;",  "¹"},
	{"&sup2;",    "&#178;",  "²"},
	{"&sup3;",    "&#179;",  "³"},
	{"&sup;",     "&#8835;", "⊃"},
	{"&supe;",    "&#8839;", "⊇"},
	{"&szlig;",   "&#223;",  "ß"},
	{"&Tau;",     "&#932;",  "Τ"},
	{"&tau;",     "&#964;",  "τ"},
	{"&there4;",  "&#8756;", "∴"},
	{"&Theta;",   "&#920;",  "Θ"},
	{"&theta;",   "&#952;",  "θ"},
	{"&thetasym;", "&#977;", "ϑ"},
	{"&thinsp;",  "&#8201;", ""},
	{"&THORN;",   "&#222;",  "Þ"},
	{"&thorn;",   "&#254;",  "þ"},
	{"&tilde;",   "&#732;",  "˜"},
	{"&times;",   "&#215;",  "×"},
	{"&trade;",   "&#8482;", "™"},
	{"&Uacute;",  "&#218;",  "Ú"},
	{"&uacute;",  "&#250;",  "ú"},
	{"&uarr;",    "&#8593;", "↑"},
	{"&Ucirc;",   "&#219;",  "Û"},
	{"&ucirc;",   "&#251;",  "û"},
	{"&Ugrave;",  "&#217;",  "Ù"},
	{"&ugrave;",  "&#249;",  "ù"},
	{"&uml;",     "&#168;",  "¨"},
	{"&upsih;",   "&#978;",  "ϒ"},
	{"&Upsilon;", "&#933;",  "Υ"},
	{"&upsilon;", "&#965;",  "υ"},
	{"&Uuml;",    "&#220;",  "Ü"},
	{"&uuml;",    "&#252;",  "ü"},
	{"&Xi;",      "&#926;",  "Ξ"},
	{"&xi;",      "&#958;",  "ξ"},
	{"&Yacute;",  "&#221;",  "Ý"},
	{"&yacute;",  "&#253;",  "ý"},
	{"&yen;",     "&#165;",  "¥"},
	{"&yuml;",    "&#255;",  "ÿ"},
	{"&Yuml;",    "&#376;",  "Ÿ"},
	{"&Zeta;",    "&#918;",  "Ζ"},
	{"&zeta;",    "&#950;",  "ζ"},
	{"&zwj;",     "&#8205;", ""},
	{"&zwnj;",    "&#8204;", ""},
};

#define HTML_SPECIAL_HPP
#endif