#!make

IMAGE_REPO=quay.io
REPO_USER=markllama
IMAGE_NAME=dhcpd
BUILD_CONTAINER_NAME=dhcpd-build
INTERFACE=br-prov
DATADIR=$(shell pwd)/data

$(IMAGE_NAME)-oci.tgz: build
	podman save --format oci-archive ${IMAGE_NAME} --output $(IMAGE_NAME)-oci.tgz

build:
	buildah unshare ./build.sh $(BUILD_CONTAINER_NAME) $(IMAGE_NAME)

clean:
	-rm $(IMAGE_NAME).tgz
	-buildah delete $(BUILD_CONTAINER_NAME)
	-podman rmi ${IMAGE_NAME}

run:
	+podman run -d --init --privileged --name ${IMAGE_NAME} --net=host \
	  --volume ${DATADIR}:/data \
	  --env INTERFACE=$(INTERFACE) \
	  $(IMAGE_REPO)/$(REPO_USER)/${IMAGE_NAME}


cli:
	+podman run -it --rm --privileged --name ${IMAGE_NAME} --net=host \
	  --volume ${DATADIR}:/data \
	  --entrypoint=/bin/bash \
	  ${IMAGE_NAME}


stop:
	-podman stop ${IMAGE_NAME}
	-podman rm ${IMAGE_NAME}

tag:
	podman tag ${IMAGE_NAME} ${IMAGE_REPO}/${REPO_USER}/${IMAGE_NAME}

push:
	podman push $(IMAGE_REPO)/$(REPO_USER)/${IMAGE_NAME}
