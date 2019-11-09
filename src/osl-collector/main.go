package main

import (
	"os"
	jsonReader "osl-collector/jsonReader"
)

func main() {
	jsonReader.MyFunction(os.Args[1], os.Args[2])
}
