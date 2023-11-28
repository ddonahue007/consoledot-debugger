all: push

push:
	bash scripts/console-debugger.sh build

debug:
	bash scripts/console-debugger.sh run ${DBSECRET}
