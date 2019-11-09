package main

import (
	"flag"
	jsonReader "osl-collector/jsonReader"
)

type OslCollectorInputs struct {
	Folder       string
	JsonFileName string
	OutputFile   string
}

func main() {
	inputs := gatherFlags()
	jsonReader.MyFunction(inputs.Folder, inputs.JsonFileName, inputs.OutputFile)
}

func gatherFlags() OslCollectorInputs {
	folderPtr := flag.String("folder", jsonReader.DefaultFolder, "Folder to search for sub directories")
	jsonFileNamePtr := flag.String("jsonFileName", jsonReader.DefaultJsonFile, "File name to search for")
	outputFilePtr := flag.String("OutputFile", jsonReader.DefaultOutputFile, "File name to write output to")

	flag.Parse()

	return OslCollectorInputs{
		Folder:       *folderPtr,
		JsonFileName: *jsonFileNamePtr,
		OutputFile:   *outputFilePtr,
	}
}
