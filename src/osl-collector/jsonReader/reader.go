package jsonReader

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	. "osl-collector/oslStructs"
)

const DefaultOutputFile = "output.json"

func ReadFiles(files []string) [][]byte {
	var jsonData [][]byte
	for _, fileName := range files {
		bytes, err := ioutil.ReadFile(fileName)
		if err != nil {
			log.Fatal(err)
		}
		jsonData = append(jsonData, bytes)
	}

	return jsonData
}

func ParseOSLData(inputs [][]byte) []OSLData {
	var data []OSLData
	for _, input := range inputs {
		var datum OSLData
		err := json.Unmarshal(input, &datum)
		if err != nil {
			log.Fatal(err)
		}
		data = append(data, datum)
		fmt.Printf("Found %d entries\n", len(datum.Packages))
	}

	return data
}

func MyFunction(folder string, jsonFile string, outputFile string) {
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
