package osmStructs_test

import (
	"osl-collector/core/oslStructs"
	"osl-collector/core/osmStructs"
	"osl-collector/osmFormat"
	"reflect"
	"testing"
)

func TestFromOSLPackage(t *testing.T) {
	autoConfName := "autoconf"
	autoConfVersion := "2.69.0"
	autoConfFileName := "autoconf-2.69.tar.gz"
	autoConfUrl := "http://ftp.gnu.org/gnu/autoconf/" + autoConfFileName
	autoConfLicense := "GPL2.0"
	input := oslStructs.OSLPackage{
		Name:    autoConfName,
		Version: autoConfVersion,
		Url:     autoConfUrl,
		License: autoConfLicense,
	}
	expected := osmStructs.OSMElement{
		Name:       autoConfName,
		Version:    autoConfVersion,
		Url:        autoConfUrl,
		License:    autoConfLicense,
		Filename:   autoConfFileName,
		Repository: osmFormat.DefaultRepository,
		LocalPath:  osmFormat.DefaultLocalPath,
	}

	actual := osmStructs.FromOSLPackage(input, osmFormat.DefaultRepository, osmFormat.DefaultLocalPath)

	if !reflect.DeepEqual(expected, actual) {
		t.Errorf("Wrong OSM Element, expected %+v but got %+v", expected, actual)
	}
}
