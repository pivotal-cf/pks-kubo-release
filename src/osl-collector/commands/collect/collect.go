package collect

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	. "osl-collector/core"
	. "osl-collector/core/oslStructs"
)

type OslCollectorInputs struct {
	Folder       string
	JsonFileName string
	OutputFile   string
}

func Collect(inputs OslCollectorInputs) {
	files := FindFiles(inputs.Folder, inputs.JsonFileName)
	contents := ReadFiles(files)
	rawOslData := ParseOSLData(contents)
	merged := MergePackages(rawOslData)
	writeOutput(merged, inputs.OutputFile)
}

func writeOutput(merged OSLData, outputFile string) {
	output, err := json.MarshalIndent(merged, "", "    ")
	if err != nil {
		log.Fatal(err)
	}
	err = ioutil.WriteFile(outputFile, output, 0644)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Print(string(output) + "\n")
}
