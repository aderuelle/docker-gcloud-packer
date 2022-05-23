FROM gcr.io/google.com/cloudsdktool/cloud-sdk:alpine
LABEL maintainer="Alexis Deruelle <alexis.deruelle@gmail.com>"

ARG PACKER_VERSION=1.8.0
ARG PACKER_OS=linux
ARG PACKER_ARCH=amd64
ARG PACKER_USER=packer
ARG PACKER_HOME=/home/${PACKER_USER}
ARG PACKER_GROUP=${PACKER_USER}
ARG PACKER_LOCATION=/bin
ARG TMPDIR=/tmp
ENV ENTRYPOINT=${PACKER_LOCATION}/packer
ENV PACKER_BASEURL=https://releases.hashicorp.com/packer/${PACKER_VERSION}
ENV PACKER_SUMS=packer_${PACKER_VERSION}_SHA256SUMS
ENV PACKER_ZIP=packer_${PACKER_VERSION}_${PACKER_OS}_${PACKER_ARCH}.zip

RUN deluser --remove-home cloudsdk

RUN addgroup -S ${PACKER_GROUP} && \
    adduser -S ${PACKER_USER} -G ${PACKER_GROUP} -h ${PACKER_HOME}

WORKDIR ${TMPDIR}

RUN curl -O ${PACKER_BASEURL}/${PACKER_ZIP}
# Alpine sha256sum doesn't have long options --check and --status
RUN curl ${PACKER_BASEURL}/${PACKER_SUMS} | grep ${PACKER_ZIP} | sha256sum -c -s && \
    unzip ${PACKER_ZIP} -d ${PACKER_LOCATION} && \
    rm ${PACKER_ZIP}

WORKDIR ${PACKER_HOME}

ADD .profile .

USER ${PACKER_USER}:${PACKER_GROUP}
ENTRYPOINT [${ENTRYPOINT}]
