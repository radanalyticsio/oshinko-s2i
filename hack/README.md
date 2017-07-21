# hack subdirectory in oshinko-s2i #

This is a partial copy of the `hack` directory from OpenShift Origin
sources which provides a bash framework for testing CLI commands.

Oshinko-s2i end-to-end tests (in oshinko-s2i/test/e2e) use the support
functions in ./lib but do not use any test runners included here. Instead,
oshinko-s2i provides it's own test runners (for example, `test/e2e/run.sh`) based
on the original test runners from origin. This is done in part because
the oshinko-s2i tests run against a full OpenShift instance and because
multiple tests run in the same project so that imagestreams, etc, can
be shared.

Except for this README.md file, no new files or changes to existing
files should be made in `hack` so that it can easily be updated
from the origin sources.
