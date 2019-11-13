package osmStructs

import (
	"osl-collector/core/oslStructs"
	"path"
)

type OSMElement struct {
	Name string
	Version string
	Url string
	License string
	Filename string
	Repository string
	LocalPath string
}

func FromOSLPackage(input oslStructs.OSLPackage, repository string, localPath string) OSMElement {
	return OSMElement{
		Name: input.Name,
		Version: input.Version,
		Url: input.Url,
		License: input.License,
		Filename: path.Base(input.Url),
		Repository: repository,
		LocalPath: localPath,
	}
}
