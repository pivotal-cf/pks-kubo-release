package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
)

func hello(w http.ResponseWriter, req *http.Request) {
	log.Printf("Received request from %s\n", req.UserAgent())
	fmt.Fprintf(w, "Server: simple-server\n")
}

func main() {
	argsWithoutProgramName := os.Args[1:]

	// if we're running as a local executable to echo, just echo
	if len(argsWithoutProgramName) > 0 {
		log.Printf("Received '%s'\n", strings.Join(argsWithoutProgramName, " "))
		return
	}

	// if we're serving as a web server, serve:
	http.HandleFunc("/", hello)

	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal(err)
	}
}