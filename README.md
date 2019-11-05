# This repository is deprecated!

This repository is deprecated. All [BOSH Ops Files][] which are intended for PKS
should be added directly to the appropriate place within the [service adapter][].
The longer term migration plan is to:

- standardize property sharing using [BOSH links][]
- move defaults to the [BOSH job spec][] which needs the value
- move static assets into the BOSH release which contains the job template which consumes the asset

[BOSH Ops Files]: https://bosh.io/docs/cli-ops-files/
[service adapter]: https://github.com/pivotal-cf/kubo-service-adapter-release/tree/master/src/kubo-service-adapter/ops-files
[BOSH links]: https://bosh.io/docs/links/
[BOSH job spec]: https://bosh.io/docs/jobs/#spec

