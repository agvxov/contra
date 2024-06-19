.PHONY: clean test install uninstall code_install vim_install

ifeq (${DEBUG}, 1)
  LFLAGS   += --debug --trace
  CXXFLAGS += -Wall -Wextra -Wpedantic 
  CXXFLAGS += -DDEBUG -O0 -ggdb -fno-inline	
  WRAP     := valgrind --track-origins=yes --leak-check=full --show-leak-kinds=all 
else
  CXXFLAGS += -O3 -fno-stack-protector -fno-exceptions -fno-rtti
endif

OUT := contra

SOURCE.d  := source/
OBJECT.d  := object/
TEST.d    := test/
INSTALL.d := /bin/

SOURCE := main.cpp xml.cpp csml.cpp cli.cpp html_special.cpp
OBJECT := $(addprefix ${OBJECT.d}/,${SOURCE})
OBJECT := ${OBJECT:.cpp=.o}
OBJECT := ${OBJECT:.c=.o}

DIFF := diff --side-by-side --report-identical-files --expand-tabs --ignore-trailing-space --color=always

%.cpp: %.l
	${LEX} --prefix=$(basename $(notdir $<))_ ${LFLAGS} -o $@ $<

${OBJECT.d}/%.o: ${SOURCE.d}/%.cpp
	${COMPILE.cpp} -o $@ $<

${OUT}: ${OBJECT}
	${LINK.cpp} -o $@ ${OBJECT} ${LDLIBS}

install: ${OUT}
	cp ${OUT} ${INSTALL.d}/${OUT}

uninstall:
	${RM} ${INSTALL.d}/${OUT}

vim_install:
	cp plugin/contra.vim ~/.vim/plugin/

code_install: code
	code --install-extension plugin/vscode/*.vsix

code:
	cd plugin/vscode/; \
	yarn package

test: ${OUT}
	${DIFF} <(bat ${TEST.d}/draft.html) <(${WRAP} ./${OUT} -s 'html' -c ${TEST.d}/draft.csml)
	${DIFF} <(bat ${TEST.d}/draft.csml) <(${WRAP} ./${OUT} -s 'html' -x ${TEST.d}/draft.html)
	${DIFF} <(bat ${TEST.d}/complex.html) <(${WRAP} ./${OUT} -s 'html' -c ${TEST.d}/complex.csml)
	${DIFF} <(bat ${TEST.d}/complex.csml) <(${WRAP} ./${OUT} -s 'html' -x ${TEST.d}/complex.html)

clean:
	-rm ${OUT}
	-rm ${OBJECT}

docs:
	for i in documentation/*.md; do \
		kramdown-man "$$i" -o documentation/manual/$$(basename -s .md $$i) ; \
	done
