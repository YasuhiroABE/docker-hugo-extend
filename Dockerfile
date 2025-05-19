
FROM docker.io/library/golang:1.24-alpine as hugodev

ARG hugo_version="v0.147.3"
ARG hugo_patch="20241204_hugo_0.139.3.diff"

RUN apk --no-cache add git make gcc g++ libc-dev patch

ENV GOPATH /root/go
RUN mkdir ${GOPATH}

RUN mkdir /work
WORKDIR /work

RUN git clone --branch ${hugo_version} https://github.com/gohugoio/hugo.git
COPY patch/${hugo_patch} a.diff
RUN cd hugo && patch -p1 < ../a.diff
RUN cd hugo && CGO_ENABLED=1 go install -tags extended

FROM docker.io/library/alpine:3.21

RUN apk update && apk add --no-cache tzdata bash ca-certificates rsync git asciidoctor libstdc++

COPY --from=hugodev /root/go/bin/hugo /usr/local/bin/hugo

ADD run.sh /run.sh
RUN chmod +x /run.sh

RUN addgroup hugo
RUN adduser -S -G hugo hugo
RUN mkdir /work
RUN chown hugo:hugo /work
USER hugo
WORKDIR /work

ENV HUGO_GIT_PROJECT_URL "https://github.com/YasuhiroABE/hugo-i18nsite-template.git"
ENV HUGO_GIT_PROJECT_NAME "hugo-example"
ENV HUGO_CONTENTS_DEST_PATH "/public"

ENTRYPOINT ["/run.sh"]
