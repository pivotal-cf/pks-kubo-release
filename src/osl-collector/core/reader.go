package core

import (
	"encoding/json"
	"io/ioutil"
	"log"
	. "osl-collector/core/oslStructs"
)

const DefaultOslAggregateFile = "osl-output.json"

func ReadFiles(files []string) [][]byte {
	var jsonData [][]byte
	for _, fileName := range files {
		jsonData = append(jsonData, ReadFile(fileName))
	}
	return jsonData
}

func ReadFile(file string) []byte {
	bytes, err := ioutil.ReadFile(file)
	if err != nil {
		log.Fatal(err)
	}
	return bytes
}

func ParseOSLData(inputs [][]byte) []OSLData {
	var data []OSLData
	for _, input := range inputs {
		data = append(data, ParseOSLDatum(input))
	}
	return data
}

func ParseOSLDatum(input []byte) OSLData {
	var datum OSLData
	err := json.Unmarshal(input, &datum)
	if err != nil {
		log.Fatal(err)
	}
	return datum
}
