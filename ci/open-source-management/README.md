# OSM

## Usage
To fly pipeline 
 
For all releases before and including 1.7.x

 `fly -t pks-bosh-lifecycle sp -p osm-1.5.x  -c ci/osm-pipeline-tarball.yml -v release-line=1.5.x`

 `fly -t pks-bosh-lifecycle sp -p osm-1.6.x  -c ci/osm-pipeline-tarball.yml -v release-line=1.6.x`

 `fly -t pks-bosh-lifecycle sp -p osm-1.7.x  -c ci/osm-pipeline-tarball.yml -v release-line=1.7.x`

For all releases from 1.8.x
`fly -t pks-bosh-lifecycle sp -p osm-1.8.x  -c ci/osm-pipeline.yml -v release-line=1.8`

