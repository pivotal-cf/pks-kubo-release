package core

import (
	"io/ioutil"
	"log"
	"os"
	"path"
)

const DefaultFolder = "."
const DefaultJsonFile = "boshcycle_osm.json"

/**
Searches the given folder for subdirectories containing jsonFile at the root
For example, this tree:
core/
├── fileFinder.go
├── fileFinder_test.go
├── testDir1
│   └── temp.json
└── testDir2
    └── boshcycle_osm.json
Will return only ["testDir2/boshcycle_osm.json"] with the default value of jsonFile
 */
func FindFiles(folder string, jsonFile string) []string {
	files, err := ioutil.ReadDir(folder)
	if err != nil {
		log.Fatal(err)
	}
	var directories []string
	for _, f := range files {
		if f.IsDir() {
			directories = append(directories, path.Join(folder, f.Name()))
			// TODO: not sure how to write unit tests for this, as git will not preserve symlinks in a repo
		} else if f.Mode() & os.ModeSymlink != 0 {
			directories = append(directories, path.Join(folder, f.Name()))
		} else {
			// ignore a file
		}
	}

	var jsonFiles []string
	for _, f := range directories {
		testFile := f + "/" + jsonFile
		_, err = os.Stat(testFile)
		if err == nil {
			jsonFiles = append(jsonFiles, testFile)
		} else if os.IsNotExist(err) {
			// permissible
		} else {
			log.Fatal(err)
		}
	}

	return jsonFiles
}
