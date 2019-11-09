package oslStructs

import (
	"reflect"
	"testing"
)

func TestFlattenPackages_EmptyInput(t *testing.T) {
	flattened := FlattenPackages([]OSLData{})

	if len(flattened.Packages) != 0 {
		t.Errorf("Should not have flattened any packages from empty input, but found %d\n", len(flattened.Packages))
	}
}

func TestFlattenPackages_HappyCase(t *testing.T) {
	firstPackage := OSLPackage{"Name1", "1.0.0", "url1", "CC1.0"}
	secondPackage := OSLPackage{"Name2", "2.0.0", "url2", "CC2.0"}
	thirdPackage := OSLPackage{"Name3", "3.0.0", "url3", "CC3.0"}

	firstData := OSLData{[]OSLPackage{firstPackage}}
	secondData := OSLData{[]OSLPackage{secondPackage, thirdPackage}}

	flattened := FlattenPackages([]OSLData{firstData, secondData})

	if len(flattened.Packages) != 3 {
		t.Errorf("Should have flattened to 3 packages but resulted in %d\n", len(flattened.Packages))
	}
	if !reflect.DeepEqual(flattened.Packages[0], firstPackage) {
		t.Errorf("Expected first element %+v but was %+v", firstPackage, flattened.Packages[0])
	}
	if !reflect.DeepEqual(flattened.Packages[1], secondPackage) {
		t.Errorf("Expected second element %+v but was %+v", secondPackage, flattened.Packages[1])
	}
	if !reflect.DeepEqual(flattened.Packages[2], thirdPackage) {
		t.Errorf("Expected third element %+v but was %+v", thirdPackage, flattened.Packages[2])
	}
}
