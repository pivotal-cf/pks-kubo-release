FROM golang:latest as build-env

WORKDIR /go/src/app
ADD simple-server.go /go/src/app

RUN go get -d -v ./...

RUN env GOOS=linux GOARCH=amd64 go build -o /go/bin/simple-server /go/src/app/simple-server.go
RUN chmod +x /go/bin/simple-server

FROM cloudfoundry/run:tiny
COPY --from=build-env /go/bin/simple-server /
EXPOSE 80/tcp
CMD ["/simple-server"]§