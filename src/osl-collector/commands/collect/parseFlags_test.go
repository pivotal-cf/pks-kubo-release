package collect_test

import (
	"flag"
	"os"
	"osl-collector/commands/collect"
	"osl-collector/core"
	"reflect"
	"testing"
)

func TestGatherFlags_ExplicitArguments(t *testing.T) {
	flag.CommandLine = flag.NewFlagSet(os.Args[0], flag.ContinueOnError)
	oldArgs := os.Args
	defer func() { os.Args = oldArgs }()
	os.Args = []string{"./osl-collector", "-folder", "/foo/packages", "-jsonFileName", "foo.json", "-outputFile", "bar.json", "collect"}

	expected := collect.OslCollectorInputs{
		Folder:       "/foo/packages",
		JsonFileName: "foo.json",
		OutputFile:   "bar.json",
	}
	actual := collect.GatherFlags()

	if !reflect.DeepEqual(expected, actual) {
		t.Errorf("Expected %+v but got %+v", expected, actual)
	}
}

func TestGatherFlags_ImplicitArguments(t *testing.T) {
	flag.CommandLine = flag.NewFlagSet(os.Args[0], flag.ContinueOnError)
	oldArgs := os.Args
	defer func() { os.Args = oldArgs }()
	os.Args = []string{"./osl-collector", "collect"}

	expected := collect.OslCollectorInputs{
		Folder:       core.DefaultFolder,
		JsonFileName: core.DefaultOslPackageFile,
		OutputFile:   core.DefaultOslAggregateFile,
	}
	actual := collect.GatherFlags()

	if !reflect.DeepEqual(expected, actual) {
		t.Errorf("Expected %+v but got %+v", expected, actual)
	}
}
