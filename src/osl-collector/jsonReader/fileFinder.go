package jsonReader

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

const DefaultFolder = "."
const DefaultJsonFile = "boshcycle_osm.json"

/**
Searches the given folder for subdirectories containing jsonFile at the root
For example, this tree:
jsonReader/
├── fileFinder.go
├── fileFinder_test.go
├── testDir1
│   └── temp.json
└── testDir2
    └── boshcycle_osm.json
Will return only ["testDir2/boshcycle_osm.json"] with the default value of jsonFile
 */
func FindFiles(folder string, jsonFile string) []string {
	fmt.Println("Opening "+ folder)
	files, err := ioutil.ReadDir(folder)
	if err != nil {
		log.Fatal(err)
	}
	var directories []string
	for _, f := range files {
		if f.IsDir() {
			fmt.Println(f.Name() + " is a dir")
			directories = append(directories, f.Name())
		} else {
			fmt.Printf("%s is a file\n", f.Name())
		}
	}

	var jsonFiles []string
	for _, f := range directories {
		testFile := f + "/" + jsonFile
		_, err = os.Stat(testFile)
		if err == nil {
			fmt.Printf("%s exists!\n", testFile)
			jsonFiles = append(jsonFiles, testFile)
		} else if os.IsNotExist(err) {
			fmt.Printf("%s does not exist\n", testFile)
			// permissible
		} else {
			log.Fatal(err)
		}
	}

	return jsonFiles
}
