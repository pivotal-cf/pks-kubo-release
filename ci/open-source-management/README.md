# OSM

## Usage
To fly pipeline 
 
This is assuming you are running from the current folder where the README.md lives
# For release lines 
`fly -t pks-bosh-lifecycle sp -p osm-1.8.x  -c ../osm-pipeline.yml -v release-line=1.8.x`

# To use master
`fly -t pks-bosh-lifecycle sp -p osm-1.9.x  -c ../osm-pipeline.yml -v release-line=master`


