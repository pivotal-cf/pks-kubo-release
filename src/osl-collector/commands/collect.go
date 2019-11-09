package commands

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	. "osl-collector/core"
	. "osl-collector/core/oslStructs"
)

func Collect(folder string, jsonFile string, outputFile string) {
	files := FindFiles(folder, jsonFile)
	contents := ReadFiles(files)
	rawOslData := ParseOSLData(contents)
	flattened := FlattenPackages(rawOslData)
	writeOutput(flattened, outputFile)
}

func writeOutput(flattened OSLData, outputFile string) {
	output, err := json.MarshalIndent(flattened, "", "    ")
	if err != nil {
		log.Fatal(err)
	}
	err = ioutil.WriteFile(outputFile, output, 0644)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Print(string(output) + "\n")
}
