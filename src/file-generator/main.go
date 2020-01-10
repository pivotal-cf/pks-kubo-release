package main

import (
	"errors"
	"fmt"
	"os"

	. "file-generator/generator"
)

var (
	filePath string
	jobName  string
)

func main() {
	if len(os.Args) != 3 {
		panic(errors.New("Insufficient args: should have <path-to-flag-configuration> <bosh-job-name>"))
	}

	filePath = os.Args[1]
	_, err := os.Stat(filePath)
	if err != nil {
		panic(fmt.Errorf("Could not read file at path %s", filePath))
	}
	jobName = os.Args[2]

	pathGenerator := JobFilePathGenerator{}
	gen := NewFileGenerator(filePath, jobName, pathGenerator)
	err = gen.Generate()
	if err != nil {
		panic(err)
	}
}
