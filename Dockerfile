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

FROM debian:stable-slim

WORKDIR /app

RUN apt-get update
RUN apt-get install -y ca-certificates \
        nano \
        bash-completion \
        iproute2 \
        procps \

COPY --from=builder /app/deploy/dd-integration-test .

COPY --from=datadog/serverless-init /datadog-init .

STOPSIGNAL SIGINT

EXPOSE 8080

CMD ["./datadog-init", "./dd-integration-test"]
