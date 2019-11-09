package jsonReader_test

import (
	jsonReader "osl-collector/jsonReader"
	"testing"
)

func TestFindFiles(t *testing.T) {
	jsonFiles := jsonReader.FindFiles(jsonReader.DefaultFolder, jsonReader.DefaultJsonFile)

	if len(jsonFiles) != 1 {
		t.Errorf("Should have found 1 test json file but found %d", len(jsonFiles))
	}
	if jsonFiles[0] != "testDir2/"+jsonReader.DefaultJsonFile {
		t.Errorf("Should have found testDir2/"+jsonReader.DefaultJsonFile+" but found %s", jsonFiles[0])
	}

}
