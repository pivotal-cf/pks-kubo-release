package main

import (
	"flag"
	"log"
	"osl-collector/commands"
	jsonReader "osl-collector/core"
)

type OslCollectorInputs struct {
	Folder       string
	JsonFileName string
	OutputFile   string
}

func main() {
	inputs, command := gatherFlags()
	switch command {
	case "collect":
		commands.Collect(inputs.Folder, inputs.JsonFileName, inputs.OutputFile)
	case "osm":
		commands.Osm()
	}
}

func gatherFlags() (OslCollectorInputs, string) {
	folderPtr := flag.String("folder", jsonReader.DefaultFolder, "Folder to search for sub directories")
	jsonFileNamePtr := flag.String("jsonFileName", jsonReader.DefaultJsonFile, "File name to search for")
	outputFilePtr := flag.String("outputFile", jsonReader.DefaultOutputFile, "File name to write output to")

	flag.Parse()
	args := flag.Args()
	var command string
	if len(args) == 0 {
		log.Fatal("Please specify a command after all flags")
	} else {
		command = args[0]
	}

	return OslCollectorInputs{
		Folder:       *folderPtr,
		JsonFileName: *jsonFileNamePtr,
		OutputFile:   *outputFilePtr,
	}, command
}
