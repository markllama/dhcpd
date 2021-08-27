#!/bin/bash

set -x

CONTAINER_NAME=$1
BASE_IMAGE=registry.access.redhat.com/ubi8/ubi
IMAGE_NAME=$2

RPMS=(dhcp-server)
SERVICES=(dhcpd)

# from fedora
buildah from --name ${CONTAINER_NAME} ${BASE_IMAGE}
buildah config --label maintainer="${MAINTAINER}" ${CONTAINER_NAME}

buildah config --env INTERFACE=eno1 ${CONTAINER_NAME}
buildah config --env DHCPD_PROTOCOL=4 ${CONTAINER_NAME}

#buildah config --port 68/tcp,68/udp,69/tcp,69/udp ${CONTAINER_NAME}

buildah run ${CONTAINER_NAME} dnf -y install ${RPMS[@]}
#buildah run ${CONTAINER_NAME} systemctl enable dhcpd
buildah run ${CONTAINER_NAME} dnf clean all

# copy entrypoint.sh
buildah copy ${CONTAINER_NAME} entrypoint.sh /opt/entrypoint.sh

# set entrypoint
buildah config --entrypoint '["/opt/entrypoint.sh"]' ${CONTAINER_NAME}

buildah commit ${CONTAINER_NAME} ${IMAGE_NAME}

buildah unmount ${CONTAINER_NAME}
