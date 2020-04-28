# CFCR Smoke Tests

Tests that run against a remote kubernetes cluster

## How to update the `simple-server` web server

1. Make changes to `simple-server.go`
    1. Use `go build -o simple-server simple-server.go` to build during development
1. `docker build -t simple-server:latest .`
1.  docker save simple-server:latest -o simple-server.tgz
1. `cd ../..` (get to project root)
1. `bosh add-blob src/smoke-tests/simple-server.tgz container-images/simple-server.tgz`
1. `bosh upload-blobs`

## How To Run

1. Local from the command line given `kubectl` works

```
ginkgo -r
```

2. As a bosh-errand

```
bosh -d cfcr run-errand smoke-tests
```

3. Remote using a binary (e.g. jumphost)

```
GOARCH=amd64 GOOS=linux go test  -c -v -o run-tests
scp run-tests jumphost:~/
ssh jumphost -c ~/run-tests
```

