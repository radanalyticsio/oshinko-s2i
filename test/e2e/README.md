# oshinko-s2i end-to-end test suite (based on OpenShift Command-Line Integration Test Suite)

The oshinko-s2i end-to-end test suite is built on a subset of the OpenShift Command-Line Integration Test Suite.
In particular, it uses the `os::cmd` utility functions described below to determine success or failure of
test commands.

It uses its own test runner in `run.sh` which is based on the test runner `hack/test-cmd.sh` in
the OpenShift Command-Line Test Suite. However, `run.sh` is different in a number of ways:

* it assumes that the tests are written to run against an existing, fully functioning OpenShift instance and does
  not attempt to spin up an instance on its own. This is the biggest difference. The instance may be a full
  OpenShift install or it may be the result of `oc cluster up` (see below).
* it descends through directories under `test/e2e` one at a time
* a new project is created at each directory level
* all *.sh files in the directory (filtered by an optional regex) are run in the same project
* it does not do anything fancy regarding log preservation, integration with junit, etc beyond
  the simple declaration of the beginning and end of each test suite

## Test Structure

The script to run the entire suite lives in `test/e2e/run.sh`. All of the test suites that make up
the parent suite live in `test/e2e`, and are divided into subdirectories by functional area.

Common functions or environment variables used across test suites should be defined in text files in `test/e2e`
and sourced from test scripts. For example `test/e2e/common` defines some common functions.

Common resources should be put in `test/e2e/resources`; this subdirectory will be ignored
by `run.sh` when it looks for test scripts.

## Important environment variables

The `test/e2e/common` file reads or sets several environment variables:

``S2I_TEST_LOCAL_IMAGES`` (default is true)

  This indicates that the s2i images to be tested are local, that is they
  are available from the local docker daemon but not in an external registry
  like docker hub.

  If this is set to "false", all s2i images are assumed to be in an external
  registy. **S2I_TEST_INTEGRATED_REGISTRY** and **S2I_TEST_EXTERNAL_REGISTRY**
  will be ignored because there will be no need to push local images to
  a registry.

``S2I_TEST_INTEGRATED_REGISTRY``

  This is the IP address of the integrated registry. Use this setting when:
  * running tests using local images
  * running tests on a host where the integrated registry is reachable (like the OpenShift master)
  * using an OpenShift instance that was not created with `oc cluster up`

```sh
$ S2I_TEST_INTEGRATED_REGISTRY=172.123.456.89:5000 test/e2e/run.sh
```

``S2I_TEST_EXTERNAL_REGISTRY``

  This is the IP address of a docker registry. If this is set then
  **S2I_TEST_EXTERNAL_USER** and **S2I_TEST_EXTERNAL_PASSWORD** must also
  be set so that the tests can log in to the registry.
  Use this setting when:
  * running tests using local images
  * running tests from a host where the integrated registry is not reachable
  * using an OpenShift instance that was not created with `oc cluster up`

``S2I_TEST_IMAGE_PYSPARK`` (default: radanalytics-pyspark if S2I_TEST_LOCAL_IMAGES is true, otherwise docker.io/radanalyticsio/radanalytics-pyspark)

  This is the name of a pyspark S2I image that the tests will use.

``S2I_TEST_IMAGE_JAVA`` (default: radanalytics-java-spark if S2I_TEST_LOCAL_IMAGES is true, otherwise docker.io/radanalyticsio/radanalytics-java-spark)

  This is the name of a java spark S2I image that the tests will use.

``S2I_TEST_IMAGE_SCALA`` (default: radanalytics-scala-spark if S2I_TEST_LOCAL_IMAGES is true, otherwise docker.io/radanalyticsio/radanalytics-scala-spark)

  This is the name of a scala spark S2I image that the tests will use.
 
``S2I_TEST_SPARK_IMAGE`` (default is docker.io/radanalyticsio/openshift-spark)

  The Spark image that will be used for generated clusters

``S2I_TEST_WORKERS`` (default is 1)

  Number of workers in generated clusters

``S2I_SAVE_FAIL`` (default is false)

  If this is set to true, run.sh will not delete a project for which there are
  test failures. This allows left over objects to be inspected for clues.

``MY_SCRIPT``

  Convenience variable set in `test/e2e/common`. This is the base name of the currently
  running script and it can be used in test code. The current tests use this to set the
  test suite identifier.

## Running Tests with `make` (this builds and uses local images)

The `test-e2e` make target can be run from the `oshinko-s2i` root directory.
It will build new local images and then run all of the end-to-end tests
using those images.

To run against an OpenShift instance created with "oc cluster up"

```
$ make test-e2e
```

To run against a full OpenShift instance from the master host
where the integrated registry is reachable

```sh
$ S2I_TEST_INTEGRATED_REGISTRY=<registry ip> make test-e2e
```

To run against a full OpenShift instance when the integrated
registry is not reachable, specify an external registry

```sh
$ S2I_TEST_EXTERNAL_REGISTRY=<registry ip> S2I_TEST_EXTERNAL_USER=myuser S2I_TEST_EXTERNAL_PASSWORD=password make test-e2e
```

To build and use a local pyspark image with a name differrent than
then default, use the **S2I_TEST_IMAGE_PYSPARK** env var:

```sh
$ S2I_TEST_IMAGE_PYSPARK=my_test_image make test-e2e
```

## Running Tests with run.sh (this can use local or external images)

Tests may be run using `run.sh` instead of make. If you are using
local images, you must build them first.

To run the full test suite with local images, use:
```sh
$ test/e2e/run.sh
```

To run the full test suite with default external images, use:

```sh
$ S2I_TEST_LOCAL_IMAGES=false test/e2e/run.sh

To run against a full OpenShift instance with local images, specify an integrated
or external registry

```sh
$ S2I_TEST_INTEGRATED_REGISTRY=<registry ip> test/e2e/run.sh
```

To run a single test suite, use:
```sh
$ test/e2e/run.sh <name>
```

To run a set of suites matching some regex, use:
```sh
$ test/e2e/run.sh <regex>
```
To use a local pyspark image with a name differrent than
then default, use the **S2I_TEST_IMAGE_PYSPARK** env var:

```sh
$ S2I_TEST_IMAGE_PYSPARK=my_test_image test/e2e/run.sh
```

Any test can also be run in the current project by invoking it directly. Note, this assumes
that the oshinko serviceaccount has been created and given edit privileges in the current
project.  For example:

```sh
$ test/e2e/ephemeral/non_ephemeral_app_completed.sh 
```

## Adding Tests

New end-to-end tests should be added in specific subdirectories under `test/e2e`, grouped by functionality.

Any non end-to-end tests should be added under `test` in a different subdirectory. They should be given their own make target
and perhaps their own test runner. The `e2e` subdirectory is specifically for live end-to-end tests against a full
OpenShift instance.

## `os::cmd` Utility Functions (text based on the OpenShift CLI Integration Test Suite readme)

The `os::cmd` namespace provides a number of utility functions for writing integration tests.

The utility functions have two major functions - expecting a specific exit code from the command to be tested, and expecting something
about the output of that command to `stdout` and/or `stderr`. There are three classes of utility functions - those that expect "success"
or "failure", those that expect a specific exit code, and those that re-try their command until either some condition is met or some
time passes. The latter type of function is useful when waiting for some component to update, be it an imagestream, the project cache,
etc.

All utility functions that expect something about the output of the command to `stdout` or `stderr` use `grep -Eq` to run their test,
so the functions can accept either text literals or regex compliant with `grep -E` for input.

The utility functions use `eval` to run the commands passed to them, and do so in a sub-shell. In order to pass a command into a utility
function, it must be quoted. Therefore, if there is a literal string (`'text'`) in your command, you must use double-quotes (`"there is
the text: 'text'"`) to ensure that when the command is passed to `eval`, the text that you wanted to be a literal string remains so
and does not get interpreted as a command itself. 

Furthermore, variables can be passed in either surrounded by single quotes (`'$var'`) or double quotes (`"$var"`). It is best practice
to use double-quotes in your test scripts when passing variables to the utility functions, as this will allow the test to see the 
expanded variable and display your command exactly as it will be run, instead of displaying the fact that there is a variable that has
yet to be expanded.

In some cases, you may want to pass a string in to the wrapper functions that contains what looks like a `bash` variable but is not.
In this case, you must escape the dollar-sign when passing it in, for example: `"\$notavar"`. 

`bash` variable assignments done inside of a command passed to a utility function are not visible to the shell running your test. 
Therefore, if your test uses bash variables and you would like to do an assignment, you should *not* use the `os::cmd` wrapper functions. 

---

The utility functions contingent on command success or failure are:

#### `os::cmd::expect_success CMD` 
`expect_success` takes one argument, the command to be run, and runs it. If the command succeeds (its return code is `0`), the utility 
function returns `0`. Otherwise, the utility function returns `1`.

In order to test that a command succeeds, pass it to `os::cmd::expect_success` like:
```sh
$ os::cmd::expect_success 'openshift admin config'
```
   
#### `os::cmd::expect_failure CMD`
`expect_failure` takes one argument, the command to be run, and runs it. If the command fails (its return code is not `0`), the utility
function returns `0`. Otherwise, the utility function returns `1`.

In order to test that a command fails, pass it to `os::cmd::expect_failure` like:
```sh
$ os::cmd::expect_failure 'openshift admin policy TYPO'
```

#### `os::cmd::expect_success_and_text CMD TEXT`
`expect_success_and_text` takes two arguments, the command to be run and the text that is expected, and runs the command. If the command
succeeds (its return code is `0`) *and* `stdout` or `stderr` contain the expected text, the utility function returns `0`. Otherwise, the
utility function returns `1`.

In order to test that a command succeeds and outputs some text, pass it to `os::cmd::expect_success_and_text` like:
```sh
$ os::cmd::expect_success_and_text 'oadm create-master-certs -h' 'Create keys and certificates'
```

In order to test that a command succeeds and outputs some text matching a regular expression, pass it to `os::cmd::expect_success_and_text` like:
```sh
$ os::cmd::expect_success_and_text "oc get imageStreams wildfly --template='{{index .metadata.annotations \"openshift.io/image.dockerRepositoryCheck\"}}'" '[0-9]{4}\-[0-9]{2}\-[0-9]{2}' # expect a date like YYYY-MM-DD
```

#### `os::cmd::expect_failure_and_text CMD TEXT`
`expect_failure_and_text` takes two arguments, the command to be run and the text that is expected, and runs the command. If the command
fails (its return code is not `0`) *and* `stdout` or `stderr` contain the expected text, the utility function returns `0`. Otherwise, the
utility function returns `1`.

In order to test that a command fails and outputs some text, pass it to `os::cmd::expect_failure_and_text` like:
```sh
$ os::cmd::expect_failure_and_text 'oc login --certificate-authority=/path/to/invalid' 'no such file or directory'
```

#### `os::cmd::expect_success_and_not_text CMD TEXT`
`expect_success_and_not_text` takes two arguments, the command to be run and the text that is not expected, and runs the command. If the
command succeeds (its return code is `0`) *and* `stdout` or `stderr` *do not* contain the text, the utility function returns `0`. Otherwise,
the utility function returns `1`.

In order to test that a command succeeds and does not output some text, pass it to `os::cmd::expect_success_and_not_text` like:
```sh
$ os::cmd::expect_success_and_not_text 'openshift' 'Atomic'
```

#### `os::cmd::expect_failure_and_not_text CMD TEXT`
`expect_failure_and_not_text` takes two arguments, the command to be run and the text that is not expected, and runs the command. If the
command fails (its return code is not `0`) *and* `stdout` or `stderr` *do not* contain the text, the utility function returns `0`. Otherwise,
the utility function returns `1`.

In order to test that a command fails and does not output some text, pass it to `os::cmd::expect_failure_and_not_text` like:
```sh
$ os::cmd::expect_failure_and_not_text 'oc get' 'NAME'
```

---

The utility functions that re-try the command until a condition is satisified or some time passes all default to trying the command
once every 200ms and time-out after one minute. The functions are:

#### `os::cmd::try_until_success CMD [TIMEOUT INTERVAL]`
`try_until_success` expects at least one argument, the command to be run, but will accept a second argument setting the timeout and a third
setting the command re-try interval. `try_until_success` will run the given command once every interval until the timeout, expecting it to
succeed (its exit code is `0`). If that occurs, the function will return `0`. Otherwise, the utility function will return `1`.

In order to re-try a command until it succeeds, pass it to `os::cmd::try_until_success` like:
```sh
$ os::cmd::try_until_success 'oc get imagestreamTags mysql:5.5'
```

#### `os::cmd::try_until_failure CMD [TIMEOUT INTERVAL]`
`try_until_failure` expects at least one argument, the command to be run, but will accept a second argument setting the timeout and a third
setting the command re-try interval. `try_until_failure` will run the given command once every interval until the timeout, expecting it to fail\
(its exit code is not `0`). If that occurs, the function will return `0`. Otherwise, the utility function will return `1`.

In order to re-try a command until it fails, pass it to `os::cmd::try_until_failure` like:
```sh
$ os::cmd::expect_success 'oc delete project recreated-project'
$ os::cmd::try_until_failure 'oc get project recreated-project'
```

#### `os::cmd::try_until_text CMD TEXT [TIMEOUT INTERVAL]`
`try_until_text` expects at least two arguments, the command to be run and the expected text, but will accept a third argument setting the
timeout and a fourth setting the command re-try interval. `try_until_text` will run the given command once every interval until the timeout,
expecting `stdout` and/or `stderr` to contain the expected text. If that occurs, the function will return `0`. Otherwise, the utility function
will return `1`.

In order to re-try a command until it outputs a certain text, without regard to its exit code, pass it to `os::cmd::try_until_text` like:
```sh
$ os::cmd::try_until_text 'oc get projects' 'ui-test-project'
```

---

The utility functions that allow a developer to expect a specific exit code are:

#### `os::cmd::expect_code CMD CODE`
`expect_code` takes two arguments, the command to be run and the code to be expected from it, and runs the command. If the command returns the
expected code, the utility function returns `0`. Otherwise, the utility function returns `1`.

#### `os::cmd::expect_code_and_text CMD CODE TEXT`
`expect_code_and_text` takes three arguments, the command to be run, the code and the text to be expected from it, and runs the command. If the
command returns the expected code *and* `stdout` or `stderr` contain the expected text, the utility function returns `0`. Otherwise, the utility
function returns `1`.


#### `os::cmd::expect_code_and_not_text CMD CODE TEXT`
`expect_code_and_not_text` takes three arguments, the command to be run, the code to be expected and the text not to be expected from it, and 
runs the command. If the command returns the expected code *and* `stdout` or `stderr` *do not* contain the expected text, the utility function
returns `0`. Otherwise, the utility function returns `1`.

### Correctly Quoting Text and Variables

In order to pass in a command that doesn't contain any quoted text, quote your command with single- or double-quotes:
```sh
$ os::cmd::expect_success 'oc get routes'
$ os::cmd::expect_success "oc get routes"
```

In order to pass in a command that contains literal text, use double quotes around the command and single-quotes around your text literal:
```sh
$ os::cmd::expect_success "oc get dc/ruby-hello-world --template='{{ .spec.replicas }}'"
```

In order to pass in a command that contains a `bash` variable you would like to be expanded, double-quote your command:
```sh
$ imagename="isimage/mysql@${name:0:15}"
$ os::cmd::expect_success "oc describe ${imagename}"
```

In order to pass in a command that contains something that looks like a `bash` variable, but isn't, escape the `$` with a forward-slash:
```sh
$ os::cmd::expect_success "oc new-build --dockerfile=\$'FROM centos:7\nRUN yum install -y httpd'"
```