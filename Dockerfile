FROM gcr.io/google.com/cloudsdktool/cloud-sdk:alpine
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

# As root:
# - Link gcloud in /bin
# - remove cloudsdk user from cloud-sdk image
# - add packer group & user
USER root

RUN ln -sf /google-cloud-sdk/bin/gcloud /bin/gcloud && \
    deluser --remove-home cloudsdk && \
    addgroup -S ${PACKER_GROUP} && \
    adduser -S ${PACKER_USER} -G ${PACKER_GROUP} -h ${PACKER_HOME}

RUN gcloud components list --format="value(id)" --filter="state.name!='Not Installed'  id!='core'" 2> /dev/null | \
    xargs gcloud components remove --quiet && rm -rf /google-cloud-sdk/.install/.backup && \
    rm -rf $(find /google-cloud-sdk/ -regex ".*/__pycache__") && \
    rm -f /google-cloud-sdk/bin/anthoscli

# As packer user:
# - create default empty configuration
USER ${PACKER_USER}:${PACKER_GROUP}
RUN gcloud config configurations create default

# As root:
# - download packer executable zip archive
# - inline check of sha256sum, decompression of packer in /bin and removal of zip file
USER root
# Alpine sha256sum doesn't have long options --check and --status
RUN curl -O ${PACKER_BASEURL}/${PACKER_ZIP} && \
    curl ${PACKER_BASEURL}/${PACKER_SUMS} | grep ${PACKER_ZIP} | sha256sum -c -s && \
    unzip ${PACKER_ZIP} -d ${PACKER_LOCATION} && \
    rm ${PACKER_ZIP}

# - upgrade Alpine package & cleanup apk cache
RUN apk -U upgrade

# - set workdir to packer home directory
# - set default user & group to packer:packer
# - set entry point
WORKDIR ${PACKER_HOME}
USER ${PACKER_USER}:${PACKER_GROUP}
ENTRYPOINT ["${ENTRYPOINT}"]
