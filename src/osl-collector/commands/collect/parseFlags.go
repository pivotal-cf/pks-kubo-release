package collect

import (
	"flag"
	"osl-collector/core"
)

func GatherFlags() OslCollectorInputs {
	folderPtr := flag.String("folder", core.DefaultFolder, "Folder to search for sub directories")
	jsonFileNamePtr := flag.String("jsonFileName", core.DefaultOslPackageFile, "File name to search for")
	outputFilePtr := flag.String("outputFile", core.DefaultOslAggregateFile, "File name to write output to")

	flag.Parse()

	return OslCollectorInputs{
		Folder:       *folderPtr,
		JsonFileName: *jsonFileNamePtr,
		OutputFile:   *outputFilePtr,
	}
}
