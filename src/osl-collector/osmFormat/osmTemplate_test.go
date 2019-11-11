package osmFormat_test

import (
	"osl-collector/core/oslStructs"
	"osl-collector/osmFormat"
	"testing"
)

func TestGenerateYml_EmptyInput_ShouldReturn_EmptyString(t *testing.T) {
	result := osmFormat.GenerateYml([]oslStructs.OSLPackage{})
	if result != "" {
		t.Errorf("Empty input should have returned empty string, but returned %s\n", result)
	}
}

func TestGenerateYml_SinglePackage_ShouldReturn_ExpectedString(t *testing.T) {
	result := osmFormat.GenerateYml([]oslStructs.OSLPackage{{
		Name:    "autoconf",
		Version: "1.2.3",
		License: "BSD-3",
		Url:     "http://package/url/foobar.tgz",
	}})

	expectedResult := `other:autoconf:1.2.3:
  name: autoconf
  version: 1.2.3
  repository: Other
  license: BSD-3
  other-distribution: /tmp/osl/foobar.tgz
  url: http://package/url/foobar.tgz
`
	if result != expectedResult {
		t.Errorf("Expected: \n%s\n, but received: \n%s\n", expectedResult, result)
	}
}

func TestGenerateYml_TwoPackages_ShouldReturn_ExpectedString(t *testing.T) {
	result := osmFormat.GenerateYml([]oslStructs.OSLPackage{
		{
			Name:    "libnetfilter-conntrack3",
			Version: "1.0.5",
			License: "GPL2.0",
			Url:     "http://archive.ubuntu.com/ubuntu/pool/main/libn/libnetfilter-conntrack/libnetfilter-conntrack_1.0.5.orig.tar.bz2",
		},
		{
			Name:    "flannel",
			Version: "0.11.0",
			License: "Apache2.0",
			Url:     "https://github.com/coreos/flannel/archive/v0.11.0.tar.gz",
		},
	})

	expectedResult := `other:libnetfilter-conntrack3:1.0.5:
  name: libnetfilter-conntrack3
  version: 1.0.5
  repository: Other
  license: GPL2.0
  other-distribution: /tmp/osl/libnetfilter-conntrack_1.0.5.orig.tar.bz2
  url: http://archive.ubuntu.com/ubuntu/pool/main/libn/libnetfilter-conntrack/libnetfilter-conntrack_1.0.5.orig.tar.bz2
other:flannel:0.11.0:
  name: flannel
  version: 0.11.0
  repository: Other
  license: Apache2.0
  other-distribution: /tmp/osl/v0.11.0.tar.gz
  url: https://github.com/coreos/flannel/archive/v0.11.0.tar.gz
`
	if result != expectedResult {
		t.Errorf("Expected: \n%s\n, but received: \n%s\n", expectedResult, result)
	}
}
