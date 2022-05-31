FROM alpine:3.16
LABEL maintainer="Alexis Deruelle <alexis.deruelle@gmail.com>"

ARG PACKER_VERSION=1.8.1
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

# see https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# Create packer group & user
RUN addgroup -g 1000 -S ${PACKER_GROUP} && \
    adduser -u 1000 -S ${PACKER_USER} -G ${PACKER_GROUP} -h ${PACKER_HOME}

# Install prereq
# hadolint ignore=DL3018
RUN apk --no-cache -U upgrade && \
    apk --no-cache add \
    curl \
    python3 \
    py3-crcmod \
    py3-openssl \
    openssh-client

# - download & install cloud sdk
RUN curl https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz | \
    tar xz && \
    ln -sf /google-cloud-sdk/bin/gcloud /bin/gcloud && \
    gcloud components list --format="value(id)" --filter="state.name!='Not Installed'  id!='core'" 2> /dev/null | \
    xargs -r gcloud components remove --quiet && \
    rm -rf /google-cloud-sdk/.install/.backup && \
    rm -f /google-cloud-sdk/bin/anthoscli

# - download packer executable zip archive
# - inline check of sha256sum, decompression of packer in /bin and removal of zip file
#   Alpine sha256sum doesn't have long options --check and --status
RUN curl -O ${PACKER_BASEURL}/${PACKER_ZIP} && \
    curl ${PACKER_BASEURL}/${PACKER_SUMS} | grep ${PACKER_ZIP} | sha256sum -c -s && \
    unzip ${PACKER_ZIP} -d ${PACKER_LOCATION} && \
    rm ${PACKER_ZIP}

# As packer user:
# - create default empty configuration
USER ${PACKER_USER}:${PACKER_GROUP}
RUN gcloud config configurations create default && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud --version

# - set workdir to packer home directory
# - set default user & group to packer:packer
# - set entry point
WORKDIR ${PACKER_HOME}
USER ${PACKER_USER}:${PACKER_GROUP}
# hadolint ignore=DL3025
ENTRYPOINT [${ENTRYPOINT}]
