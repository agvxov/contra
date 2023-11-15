.PHONY: clean test run

ifeq ($(DEBUG), 1)
  LFLAGS   += --debug --trace
  CXXFLAGS += -Wall -Wextra -Wpedantic 
  CXXFLAGS += -DDEBUG -O0 -ggdb -pg -fno-inline	
else
  CXXFLAGS += -O3 -fno-stack-protector -fno-exceptions -fno-rtti
endif

OUT := contra

SOURCE.d  := source/
OBJECT.d  := object/
TEST.d    := test/
INSTALL.d := /bin/

SOURCE := main.cpp xml.cpp csml.cpp cli.cpp
OBJECT := $(addprefix ${OBJECT.d}/,${SOURCE})
OBJECT := ${OBJECT:.cpp=.o}
OBJECT := ${OBJECT:.c=.o}

%.cpp: %.l
	${LEX} --prefix=$(basename $(notdir $<)) ${LFLAGS} -o $@ $<

${OBJECT.d}/%.o: ${SOURCE.d}/%.cpp
	${COMPILE.cpp} -o $@ $<

${OUT}: ${OBJECT}
	${LINK.cpp} -o $@ ${OBJECT} ${LDLIBS}

install:
	cp ${OUT} ${INSTALL.d}/${OUT}

uninstall:
	${RM} ${INSTALL.d}/${OUT}

test:
	bat ${TEST.d}/draft.csml
	./${OUT} -c ${TEST.d}/draft.csml
	bat ${TEST.d}/draft.html
	./${OUT} -x ${TEST.d}/draft.html

clean:
	-rm ${OUT}
	-rm ${OBJECT}
