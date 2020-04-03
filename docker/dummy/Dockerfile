FROM golang:1.14-alpine as builder

WORKDIR /src

COPY main.go .

RUN CGO_ENABLED=0 GOOS=linux go build -o dummy .

FROM alpine:latest as runner

WORKDIR /
COPY --from=0 /src/dummy /usr/bin/dummy

CMD ["/usr/bin/dummy"]
