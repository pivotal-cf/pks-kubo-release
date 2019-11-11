package oslStructs

import (
	"reflect"
	"testing"
)

func TestMergePackages_EmptyInput(t *testing.T) {
	merged := MergePackages([]OSLData{})

	if len(merged.Packages) != 0 {
		t.Errorf("Should not have merged any packages from empty input, but found %d\n", len(merged.Packages))
	}
}

func TestMergePackages_HappyCase(t *testing.T) {
	firstPackage := OSLPackage{"Name1", "1.0.0", "url1", "CC1.0"}
	secondPackage := OSLPackage{"Name2", "2.0.0", "url2", "CC2.0"}
	thirdPackage := OSLPackage{"Name3", "3.0.0", "url3", "CC3.0"}

	firstData := OSLData{[]OSLPackage{firstPackage}}
	secondData := OSLData{[]OSLPackage{secondPackage, thirdPackage}}

	merged := MergePackages([]OSLData{firstData, secondData})

	if len(merged.Packages) != 3 {
		t.Errorf("Should have merged to 3 packages but resulted in %d\n", len(merged.Packages))
	}
	if !reflect.DeepEqual(merged.Packages[0], firstPackage) {
		t.Errorf("Expected first element %+v but was %+v", firstPackage, merged.Packages[0])
	}
	if !reflect.DeepEqual(merged.Packages[1], secondPackage) {
		t.Errorf("Expected second element %+v but was %+v", secondPackage, merged.Packages[1])
	}
	if !reflect.DeepEqual(merged.Packages[2], thirdPackage) {
		t.Errorf("Expected third element %+v but was %+v", thirdPackage, merged.Packages[2])
	}
}
