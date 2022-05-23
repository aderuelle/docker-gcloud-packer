FROM gcr.io/google.com/cloudsdktool/cloud-sdk:alpine
LABEL maintainer="Alexis Deruelle <alexis.deruelle@gmail.com>"

ARG PACKER_VERSION=1.8.0
ENV PACKER_BASEURL=https://releases.hashicorp.com/packer/${PACKER_VERSION}
ENV SUMS_FILE=packer_${PACKER_VERSION}_SHA256SUMS
ENV PACKER_ZIP=packer_${PACKER_VERSION}_linux_amd64.zip

WORKDIR /tmp

RUN addgroup -S packer && adduser -S packer -G packer

RUN apk add --update bash openssl

RUN curl -O ${PACKER_BASEURL}/${PACKER_ZIP}

RUN test $(sha256sum ${PACKER_ZIP}) = $(curl ${PACKER_BASEURL}/${PACKER_SUMS} | grep "${PACKER_ZIP}" | cut -d' ' -f1) \
    && unzip "${PACKER_FILE}" -d /bin && rm "${PACKER_FILE}"

USER packer:packer
ENTRYPOINT ["/bin/packer"]
