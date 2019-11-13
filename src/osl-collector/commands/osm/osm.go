package osm

import (
	"fmt"
	"io/ioutil"
	"log"
	"osl-collector/core"
	"osl-collector/osmFormat"
)

type OsmInputs struct {
	InputJsonFile string
	OutputYamlFile string
}

func Osm(input OsmInputs) {
	jsonData := core.ReadFile(input.InputJsonFile)
	oslDatum := core.ParseOSLDatum(jsonData)
	yamlString := osmFormat.GenerateYml(oslDatum.Packages)
	fmt.Println(yamlString)
	err := ioutil.WriteFile(input.OutputYamlFile, []byte(yamlString), 0644)
	if err != nil {
		log.Fatalf("Unable to write output to %s: %v", input.OutputYamlFile, err)
	}
}
