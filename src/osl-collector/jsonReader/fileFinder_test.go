package jsonReader_test

import (
	jsonReader "osl-collector/jsonReader"
	"testing"
)

func TestFindFiles(t *testing.T) {
	jsonFiles := jsonReader.FindFiles("testNested", jsonReader.DefaultJsonFile)

	if len(jsonFiles) != 1 {
		t.Errorf("Should have found 1 test json file but found %d", len(jsonFiles))
	}
	expected := "testNested/testDir2/" + jsonReader.DefaultJsonFile
	if jsonFiles[0] != expected {
		t.Errorf("Should have found %s but found %s\n", expected, jsonFiles[0])
	}

}
