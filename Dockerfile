FROM golang:1.20-alpine3.18 as builder

RUN apk update && apk add tzdata && apk add -U --no-cache ca-certificates git
ENV TZ Asia/Jakarta

WORKDIR /app

ENV GO111MODULE=on
COPY go.mod go.sum ./
RUN export GOPROXY=https://proxy.golang.org && \
    go mod download -x && \
    go mod verify

COPY . .
RUN GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    go build -a -installsuffix cgo -ldflags '-extldflags "-static"' \
    -o deploy/dd-integration-test \
    ./main.go

FROM alpine:3.18.4

WORKDIR /app
ENV USER=appuser
ENV UID=10001
ENV TZ=Asia/Jakarta

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

COPY --from=builder --chown=appuser:appuser /app/deploy/dd-integration-test .

RUN apk update && apk upgrade
RUN apk add curl bash-completion

STOPSIGNAL SIGINT

EXPOSE 8080

ENTRYPOINT ["./dd-integration-test"]
