#LFLAGS := $(if $DEBUG, --debug --trace)
LDLIBS := -lboost_string_algo

OUT := a.out

main:
	${LEX} ${LFLAGS} -o main.yy.cpp main.l
	${CXX} main.yy.cpp -o ${OUT}

run:
	./${OUT} draft.csml
