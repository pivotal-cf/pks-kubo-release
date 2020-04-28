FROM golang:latest as build-env

WORKDIR /go/src/app
ADD simple-server.go /go/src/app

RUN go get -d -v ./...

RUN go build -o /go/bin/simple-server /go/src/app/simple-server.go

FROM gcr.io/distroless/base
COPY --from=build-env /go/bin/simple-server /
EXPOSE 80/tcp
CMD ["/simple-server"]§