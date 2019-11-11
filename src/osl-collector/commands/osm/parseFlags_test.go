package osm_test

import (
	"flag"
	"os"
	"osl-collector/commands/osm"
	"osl-collector/core"
	"reflect"
	"testing"
)

func TestGatherFlags_ExplicitArguments(t *testing.T) {
	flag.CommandLine = flag.NewFlagSet(os.Args[0], flag.ContinueOnError)
	oldArgs := os.Args
	defer func() { os.Args = oldArgs }()
	os.Args = []string{"./osl-collector", "-inputFile", "foo.json", "-outputFile", "bar.yml", "osm"}

	expected := osm.OsmInputs{
		InputJsonFile:  "foo.json",
		OutputYamlFile: "bar.yml",
	}
	actual := osm.GatherFlags()

	if !reflect.DeepEqual(expected, actual) {
		t.Errorf("Expected %+v but got %+v", expected, actual)
	}
}

func TestGatherFlags_ImplicitArguments(t *testing.T) {
	flag.CommandLine = flag.NewFlagSet(os.Args[0], flag.ContinueOnError)
	oldArgs := os.Args
	defer func() { os.Args = oldArgs }()
	os.Args = []string{"./osl-collector", "osm"}

	expected := osm.OsmInputs{
		InputJsonFile:  core.DefaultOslAggregateFile,
		OutputYamlFile: osm.DefaultOsmYmlFile,
	}
	actual := osm.GatherFlags()

	if !reflect.DeepEqual(expected, actual) {
		t.Errorf("Expected %+v but got %+v", expected, actual)
	}
}
