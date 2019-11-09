package core

import (
	"encoding/json"
	"io/ioutil"
	"log"
	. "osl-collector/core/oslStructs"
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
	}

	return data
}
