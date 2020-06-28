FROM alpine
LABEL "repository"="https://https://github.com/senfung/golang-versioning-tags"
LABEL "homepage"="https://https://github.com/senfung/golang-versioning-tags"
LABEL "maintainer"="Felix Hui"

COPY ./contrib/semver ./contrib/semver
RUN install ./contrib/semver /usr/local/bin
COPY entrypoint.sh /entrypoint.sh

RUN apk update && apk add bash git curl jq

ENTRYPOINT ["/entrypoint.sh"]