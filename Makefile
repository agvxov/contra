#LFLAGS := $(if $DEBUG, --debug --trace)
LDLIBS := -lboost_string_algo

OUT := a.out

SOURCE.d := source/
TEST.d   := test/

main:
	${LEX} ${LFLAGS} -o ${SOURCE.d}/main.yy.cpp ${SOURCE.d}/main.l
	${CXX} ${SOURCE.d}/main.yy.cpp -o ${OUT}

run:
	./${OUT} ${TEST.d}/draft.csml

clean:
	-rm ${OUT}
