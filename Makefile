IMAGE=quay.io/jlindgren/consoledot-debugger:latest 

all: push

push:
	podman build . -t ${IMAGE}
	podman push ${IMAGE}
