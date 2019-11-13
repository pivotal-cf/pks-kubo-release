package core_test

import (
	"os"
	jsonReader "osl-collector/core"
	"path"
	"testing"
)

func TestFindFiles(t *testing.T) {
	jsonFiles := jsonReader.FindFiles("testNested", jsonReader.DefaultOslPackageFile)

	if len(jsonFiles) != 1 {
		t.Errorf("Should have found 1 test json file but found %d", len(jsonFiles))
	}
	expected := "testNested/testDir2/" + jsonReader.DefaultOslPackageFile
	if jsonFiles[0] != expected {
		t.Errorf("Should have found %s but found %s\n", expected, jsonFiles[0])
	}

}

func TestFindFiles_Symlink(t *testing.T) {
	symlinkPath := "symLinkToTestDir2"
	err := os.Symlink("testNested/testDir2/", symlinkPath)
	if err != nil {
		t.Error(err)
	}
	defer func() {
		err := os.Remove(symlinkPath)
		if err != nil {
			t.Error(err)
		}
	}()

	jsonFiles := jsonReader.FindFiles(jsonReader.DefaultFolder, jsonReader.DefaultOslPackageFile)

	if len(jsonFiles) != 1 {
		t.Errorf("Should have found 1 test json file but found %d", len(jsonFiles))
	}
	expected := path.Join(symlinkPath, jsonReader.DefaultOslPackageFile)
	if jsonFiles[0] != expected {
		t.Errorf("Should have found %s but found %s\n", expected, jsonFiles[0])
	}
}
