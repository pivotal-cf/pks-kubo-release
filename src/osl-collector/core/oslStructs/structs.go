package oslStructs

/**
Example json:
{ "packages": [
    {
    "name": "$JQ_PACKAGE",
    "version": "$JQ_VERSION",
    "url": "$JQ_SOURCE_URL",
    "license": "$JQ_LICENSE"
    }
]}
 */
type OSLData struct {
	Packages []OSLPackage `json:"packages"`
}

type OSLPackage struct {
	Name string `json:"name"`
	Version string `json:"version"`
	Url string `json:"url"`
	License string `json:"license"`
}

/**
Takes several OSLData structures and merges their `packages` arrays together, returning a single OSLData struct
 */
func MergePackages(data []OSLData) OSLData {
	var packages []OSLPackage = make([]OSLPackage, 0)
	for _, datum := range data {
		for _, singlePackage := range datum.Packages {
			packages = append(packages, singlePackage)
		}
	}

	var oslData OSLData
	oslData.Packages = packages
	return oslData
}
