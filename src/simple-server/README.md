## How to update the `simple-server` web server

1. Make changes to `simple-server.go`
    1. Use `go build -o simple-server simple-server.go` to build during development
1. `brew install gnu-tar` # use gnu tar on macos, which has bsdtar by default
1. `export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"` # use gnu tar!
1.  `tar --version` # should include "GNU tar" and not "bsdtar"
1. `docker build -t simple-server:latest .`
1.  `docker save simple-server:latest -o simple-server.tgz`
1. `cd ../..` (get to project root)
1. `bosh add-blob src/simple-server/simple-server.tgz container-images/simple-server.tgz`
1. `bosh upload-blobs`
