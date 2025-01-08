# PSDI data transfer container image

This repository houses machinery for building a container image for
data transfer and synchronisation tools.

## Obtaining an image

Images can be found in  the [Packages](https://github.com/PSDI-UK/data-transfer-container/pkgs/container/data-transfer-container%2Fdata-transfer)
section of this GitHub project.
Commands are provided there to pull a specific version to your local
instance of docker, e.g.
```
docker pull ghcr.io/psdi-uk/data-transfer-container/data-transfer:v0.0.1
```

## Running the image and injecting secrets

To run the image and inject the required environmental variables
there are various options. Assuming that `PSDI_VAR_1` and `PSDI_VAR_2` are
environmental variables to be set within the container when it is initialised,
the command is
```
docker run -e PSDI_VAR_1='foo' -e PSDI_VAR_2='bar' data-transfer
```

However, note that this command might not be suitable for secret variables,
since the command names the values of the variables explicitly. An
alternative approach is to set `PSDI_VAR_1` and `PSDI_VAR_2` as
enviromnent variables in the host system, and then simply run
```
docker run -e PSDI_VAR_1 -e PSDI_VAR_2 data-transfer
```
This command sets the environment variables in the container to match
the values of the host system. Including the commands to
set the environment variables on the host, the relevant commands
are:
```
export PSDI_VAR_1='foo'
export PSDI_VAR_2='bar'
docker run -e PSDI_VAR_1 -e PSDI_VAR_2 data-transfer
```

Another option is to inject environmental variables stored in a file. Here
is an example of a file `env.list` containing our variables:
```
PSDI_VAR_1='foo'
# Note that comments are supported in the file!
PSDI_VAR_2='bar'
```
The command to invoke the container with the environment variables
stored in this file is
```
docker run --env-file ./env.list data-transfer
```


## Building the image

To use the `Dockerfile` to build the image locally the command is:
```
docker build -t data-transfer .
```
where it is assumed that the image is to be named `data-transfer` and it
is also assumed that the `Dockerfile` file is in the current
directory.


## Notes for developers

### CI/CD pipeline
Note that GitHub Actions is used to implement a CI/CD pipeline which, every
commit:
1. Builds the container image and scans it for **security vulnerabilities**.
   Reports regarding vulnerabilities can be found
   [here](https://github.com/PSDI-UK/data-transfer-container/security/code-scanning).
3. Builds the container image, gives it a version tag, and publishes it in
   the [Packages](https://github.com/PSDI-UK/data-transfer-container/pkgs/container/data-transfer-container%2Fdata-transfer)
   section of this project.
4. Creates an archive containing the source code of this repository, gives
   it a version tag, and publishes it in the [Releases](https://github.com/PSDI-UK/data-transfer-container/releases)
   section.

It is important to keep this pipeline up to date with regards to upstream
dependencies. For example, the pipeline uses a particular version of the
`anchore/scan-action` Action (e.g. `anchore/scan-action@v6` means version 6).
This should be updated if a new version of this Action is released. Note that
certain Actions will print warnings if, e.g. certain features in the Actions
which are used in this repo are to be deprecated; pay attention to such
warnings.

