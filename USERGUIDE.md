# User Guide for the Data Transfer Tools Container (Toolbox)


This guide provides instructions for working with the container image equipped with data
transfer tools like rclone, s3cmd, Cyberduck CLI and AWS CLI. Follow the steps below to
start the container image, perform operations, and manage it.

## Introduction

### What does the container image do?

The container image enables you to interact with PSDI S3 storage. Possible applications of
the image include: viewing files in a specific S3 'bucket' which you have the credentials
to access; transferring files from your computer system into the bucket; and transferring
files from the bucket onto your computer system. 

### Prerequisites

Before using the container image you must have access to a PSDI S3 bucket. _Please contact the
PSDI Team to obtain credentials for an S3 bucket, ensuring that the request aligns with
the necessary security protocols._ The PSDI team should provide you with 3 credentials
required to access your bucket:

1. The bucket name. In the rest of this document this will be depicted as `<bucket-name>`

2. An access key required for authentication when accessing the bucket

3. A secret key required for authentication when accessing the bucket

Moreover, since a key use of the container image is to transfer files between your computer
system and a PSDI S3 bucket, the usage outlined below assumes that there is a directory in
your system which you wish to use as the working directory for such transfers. In the rest
of this document we depict this directory as `<host-data-dir>`. Note that this directory is
mounted by the container so that the container can transfer data to and from the directory.

### Available formats of the container: Docker-format vs. Singularity Image Format

The data transfer container image is provided in two different formats. One is the default
format used by [Docker](https://www.docker.com/). This will be referred to here as 'docker
format'. The other is the [Singularity Image Format (SIF)](https://github.com/apptainer/sif)
favoured by [Apptainer](https://apptainer.org/) and [SingularityCE](https://github.com/sylabs/singularity)
(or the predecessor to both, Singularity). Here we assume that users will either want to run docker-format
images on Docker, or SIF-format images on Apptainer (though note that the usage for
SingularityCE is very similar to Apptainer). Below we provide the usage for both cases,
assuming that the user has Docker or Apptainer installed on their system. Moreover we assume
that the user already has basic knowledge of Docker or Apptainer.

## Obtaining the Container

Images can be found in the [Packages](https://github.com/orgs/PSDI-UK/packages?repo_name=data-transfer-container)
section of the [container image’s GitHub project](https://github.com/PSDI-UK/data-transfer-container).
Note that there are two packages, one for the [Docker images](https://github.com/PSDI-UK/data-transfer-container/pkgs/container/data-transfer-container%2Fdata-transfer)
and the other for the [SIF-format images](https://github.com/PSDI-UK/data-transfer-container/pkgs/container/data-transfer-container%2Fdata-transfer-sif).. 

### Docker

Regarding the former, commands are provided [there](https://github.com/PSDI-UK/data-transfer-container/pkgs/container/data-transfer-container%2Fdata-transfer)
to pull a specific version to your local instance of docker, e.g.
```
docker pull ghcr.io/psdi-uk/data-transfer-container/data-transfer:v0.0.11
```
After running this command you should be able to see the container image in your local
instance of docker, e.g. by running the `docker images` command.


### Apptainer

For the SIF images note that, while a command is provided to pull the container to your local
system using Docker, *SIF images will not work with Docker* and hence this command should not be
used. To obtain a SIF image using Apptainer the command is, e.g.

```
apptainer pull oras://ghcr.io/psdi-uk/data-transfer-container/data-transfer-sif:v0.0.11
```
This will download the SIF image and store it as a file on your local system in the directory
in which the above command was invoked. Once the container is downloaded, you may wish to
rename the container. The name of the SIF container image used in the rest of this guide is
`data-transfer.sif`. With this in mind, the command to change the name of the image downloaded
using the command above to `data-transfer.sif` is
```
mv data-transfer-sif_v0.0.11.sif data-transfer.sif
```

## Setting up the environment

Before running the container you should set the environment variables `PSDI_S3_ACCESS_KEY` and
`PSDI_S3_SECRET_KEY` on your host system to the access key and secret key credentials for the
S3 bucket. These variables will be passed to the container image when it is invoked in order to
'inject' the credentials into the container, enabling the container to access your bucket. 

_Please contact the PSDI Team to obtain the credentials for the S3 bucket, ensuring that the
request aligns with the necessary security protocols._

There are various ways in which `PSDI_S3_ACCESS_KEY` and `PSDI_S3_SECRET_KEY` can be set.
Assuming the host is a unix system, the simplest way is to use the commands
```
export PSDI_S3_ACCESS_KEY=<access-key> 
```
and
```
export PSDI_S3_SECRET_KEY=<secret-key>
```
where `<access-key>` and `<secret-key>` are the credentials for the bucket. These commands could
be added to your `.bashrc` or `.bash_profile` files to initialise `PSDI_S3_ACCESS_KEY` and
`PSDI_S3_SECRET_KEY` automatically every time you log in. *Note, however, that the above
approaches will result in the credentials being stored in plaintext in your system, something
which may not be appropriate from a security perspective.*

## Running the Container

There are different ways in which the container image can be used in order to interact with
your bucket. Here we describe how to run the container in the background - as a detached
container (in Docker terminology) or as an instance (in Apptainer terminology). Once the
container is running in the background, commands can be passed to it to interact with your
bucket. These commands are given in the next section.

### Docker

Run the following command to start the container running in the background:
```
docker run -id --name data-transfer-container --user $(id -u):$(id -g) -v <host-data-dir>:/data -e ACCESS_KEY=$PSDI_S3_ACCESS_KEY -e SECRET_KEY=$PSDI_S3_SECRET_KEY data-transfer bash 
```
where recall `<host-data-dir>` is the local directory which will be used for transferring files
between the host system and the S3 bucket. Note that this can be the current directory `.`.
The arguments in this command do the following:

1. Mount the local directory `<host-data-dir>`, e.g. `./test_data`, to the `/data` directory
inside the container. Note that Docker can be picky regarding absolute and relative paths;
if in doubt use the full absolute path. 

2. Use the user and group ID of the user on the host within the container. This is the
function of the argument `--user $(id -u):$(id -g)`. (This is required so that the container
can access the directory `<host-data-dir>` with the required permissions).

3. Names the container `data-transfer-container`.

4. Runs the container persistently in the background, i.e. the container is 'detached' (via
the `-d` argument).

Once the container is running in the background, you can transfer data using the commands
given in the next sections.

#### Stopping the container

To stop the container immediately the command is:
```
docker container kill data-transfer-container
```

### Apptainer

To launch the container in the background as an 'instance' named `data-transfer` the command is:
```
apptainer instance run --writable-tmpfs --env ACCESS_KEY=$PSDI_S3_ACCESS_KEY --env SECRET_KEY=$PSDI_S3_SECRET_KEY data-transfer.sif data-transfer
```

#### Stopping the container

To stop the instance the command is:
```
apptainer instance stop data-transfer
```

## Using the container: rclone commands

Here we give some commands for using rclone in the container to perform various tasks. Detailed
usage of rclone can be found in the [rclone documentation](https://rclone.org/).
Note that the following commands only work once the container is running in the
background, as described above.

### Viewing Bucket Contents

To list the contents of the bucket using rclone the commands are as follows.

#### Docker

```
docker exec data-transfer-container rclone ls ceph-remote:<bucket-name>
```
where `<bucket-name>` is the name of your bucket, e.g. `psdi-datatransfertest`.

In rclone, `ceph-remote` is a named remote configuration that refers to our Ceph
Object Store. It acts as an alias for the Ceph Object Store, allowing you to
interact with Ceph storage using rclone commands.

_Please contact the PSDI Team to create a specific bucket for your experiments._

#### Apptainer

```
apptainer exec instance://data-transfer rclone ls ceph-remote:<bucket-name>
```

### Uploading a File to the Bucket

To upload a file named `hello.txt` from the mounted directory to the bucket using rclone
the commands are as follows.

#### Docker

```
docker exec data-transfer-container rclone copy /data/hello.txt ceph-remote:<bucket-name>
```

#### Apptainer

```
apptainer exec instance://data-transfer rclone copy hello.txt ceph-remote:<bucket-name> 
``` 

### Downloading a File from the Bucket

To download a file `hello.txt` from the bucket to the mounted directory using rclone the
commands are as follows.

#### Docker

```
docker exec data-transfer-container rclone copy ceph-remote:<bucket-name>/hello.txt /data
```

#### Apptainer

```
apptainer exec instance://data-transfer rclone copy ceph-remote:<bucket-name>/hello.txt .
```

### Deleting files in the bucket

To delete a file `hello.txt` in the bucket using rclone, the commands are as follows.
*Be careful with this command, since it could result in permanent loss of data.*

#### Docker

```
docker exec data-transfer-container rclone delete ceph-remote:<bucket-name>/hello.txt
```

#### Apptainer

```
apptainer exec instance://data-transfer rclone delete ceph-remote:<bucket-name>/hello.txt
```

## Using the container: Other Available Data Transfer Tools and Commands

:construction: *This section is still under construction* :construction:

As well as rclone, the container comes pre-installed with the following tools. Below
we describe how you can use each in Docker.

### s3cmd 

:construction: *This section is still under construction* :construction:

This is a CLI tool for working with S3-compatible object storage. Common commands for
using this are as follows.

#### List bucket contents

```
docker exec data-transfer-container s3cmd ls s3://<bucket-name>
```

#### Upload file to bucket

```
docker exec data-transfer-container s3cmd put <file-path-to-upload> s3://<bucket-name>
```
*<file path to upload> -> ex: /data/<file name>

#### Download file from bucket

```
docker exec data-transfer-container s3cmd get s3://<bucket name>/<file name> <folder path of local directory>/<file name> 
```
*<folder path of local directory> -> ex: /data/

### Cyberduck CLI (Duck)

:construction: *This section is still under construction* :construction:

This is a command-line interface for Cyberduck, useful for data transferring.
Common commands for using this are as follows.

#### List bucket contents

```
docker exec data-transfer-container duck --profile /app/.duck/profiles/S3-deprecatedprofile.cyberduckprofile --username ACCESS_KEY --password SECRET_KEY --list s3://ACCESS_KEY@s3.echo.stfc.ac.uk/<bucket name>/
```

#### Upload file to bucket

```
docker exec data-transfer-container duck --profile /app/.duck/profiles/S3-deprecatedprofile.cyberduckprofile --username ACCESS_KEY --password SECRET_KEY --upload s3://ACCESS_KEY@s3.echo.stfc.ac.uk/<bucket name> <file path of upload>/<file name>
```
*<file path of upload> -> ex: /data

#### Download file from bucket

```
docker exec data-transfer-container duck --profile /app/.duck/profiles/S3-deprecatedprofile.cyberduckprofile --username ACCESS_KEY --password SECRET_KEY --download s3://ACCESS_KEY@s3.echo.stfc.ac.uk/<bucket name>/<file name that you want to download>  <folder path to download>
```
*<folder path to download> -> ex: /data

### AWS CLI

:construction: *This section is still under construction* :construction:

This is the official CLI for managing AWS services, including S3.
Common commands for this are as follows.

#### List all buckets in object store

```
docker exec data-transfer-container aws s3 ls --endpoint https://s3.echo.stfc.ac.uk
```

#### List bucket contents

```
docker exec data-transfer-container aws s3 ls s3://<bucket-name> --endpoint https://s3.echo.stfc.ac.uk/
```

#### Upload file to bucket

```
docker exec data-transfer-container aws s3 cp <file path to upload>/<file name> s3://<bucket-name>/ --endpoint https://s3.echo.stfc.ac.uk
```
*<file path of upload> -> ex: /data

#### Download file from bucket

```
docker exec data-transfer-container aws s3 cp s3://<bucket-name>/<file name> <folder path to download> --endpoint https://s3.echo.stfc.ac.uk
```
*<folder path to download> -> ex: /data

## Best Practices

:construction: *This section is still under construction* :construction:

Always ensure the required environment variables (`ACCESS_KEY and `SECRET_KEY`) are correctly set before starting the container.

For further assistance, contact PSDI Team or refer to the official documentation for the respective tools.