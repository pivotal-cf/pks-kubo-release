package osm

import (
"flag"
"osl-collector/core"
)

const DefaultOsmYmlFile = "osm.yml"

func GatherFlags() OsmInputs {
	inputJsonFilePtr := flag.String("inputFile", core.DefaultOslAggregateFile, "Json file to load")
	outputYamlFilePtr := flag.String("outputFile", DefaultOsmYmlFile, "File name to write yaml output to")

	flag.Parse()

	return OsmInputs{
		InputJsonFile: *inputJsonFilePtr,
		OutputYamlFile:   *outputYamlFilePtr,
	}
}
