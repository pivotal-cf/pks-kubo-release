package main

import (
	"flag"
	jsonReader "osl-collector/jsonReader"
)

type OslCollectorInputs struct {
	Folder string
	JsonFileName string
}

func main() {
	inputs := gatherFlags()
	jsonReader.MyFunction(inputs.Folder, inputs.JsonFileName)
}

func gatherFlags() OslCollectorInputs {
	folderPtr := flag.String("folder", jsonReader.DefaultFolder, "Folder to search for sub directories")
	jsonFileNamePtr := flag.String("jsonFileName", jsonReader.DefaultJsonFile, "File name to search for")

	flag.Parse()

	return OslCollectorInputs{
		Folder:       *folderPtr,
		JsonFileName: *jsonFileNamePtr,
	}
}
