# PSDI data transfer container image

This repository houses machinery for building container images for
data transfer and synchronisation tools. Moreover the GitHub Container
Registry linked to this repository houses the container images themselves.

## User documentation 

See the [user guide](USERGUIDE.md).

## License

The code in this repository is provided under the conditions
described in the `LICENSE` file in this repository. However, while some of this
code describes container images or processes to build container images,
the software license applicable to these container images will in general not be the
same as `LICENSE`. This is because a container image typically includes binaries
and source code from many pieces of software; the software license for a
container image depends on the licenses of its constitutent software.
This should be kept in mind when using any container image linked to this
repository, or any container image built using code in this repository.

## Notes for developers

### CI/CD pipeline

Note that GitHub Actions is used to implement a CI/CD pipeline which, every
commit:
1. Builds the container image and scans it for **security vulnerabilities**.
   Reports regarding vulnerabilities can be found
   [here](https://github.com/PSDI-UK/data-transfer-container/security/code-scanning).
3. Builds Docker and SIF-format container images, gives them a version tag, and publishes them
   the [Packages](https://github.com/orgs/PSDI-UK/packages?repo_name=data-transfer-container)
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

