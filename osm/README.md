### Purpose
This directory stores the manifests used for creating OSM tickets for bosh blobs used by the releases maintained/consumed by the PKS Core team.
Each of the file contains the list of the bosh blobs used by the corresponding release.

The OSM team dictates [the file format](https://osm.eng.vmware.com/doc/utilities/other.html).

### Prepare the tools:
```sh

# Clone the repo
cd ~/workspace
git clone git@gitlab.eng.vmware.com:core-build/osstpclients.git

# Installed required libs
cd osstpclients
pip install virtualenv
virtualenv venv
source ./venv/bin/activate
```

### Prepare the local files
Download the files listed in the `url` fields into `/tmp/osl/`, as they will need to be present locally for the OSM tickets to be created

(There is a tool for this; if you are automating, see pipeline in telemetry repo, "osl" directory. It uses `osstptool download` to download the source files.)
### Creating OSM tickets for each release
Use the `osstp-load.py` [script](https://osm.eng.vmware.com/doc/utilities/loading.html) to create the OSM tickets for each release (by specifying the release's manifest on the command line).

**This script requires python2 not python3**

To create the OSM tickets
```
osstp-load.py <release-name>.yml -R <release-name>/latest -I 'Distributed - No Linking' -U <username>
```
You will be prompted for your LDAP password.

To avoid password prompt, save your LDAP password to a file, say `~/.my-password`
```
osstp-load.py <release-name>.yml -R <release-name>/latest -I 'Distributed - No Linking' -U <username> -P ~/.my-password
```


