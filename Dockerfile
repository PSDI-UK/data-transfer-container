
FROM ubuntu:latest

# Update
RUN apt-get update

# Install required software...
#
# Amali to provide shell commands here after 'RUN'. Note that you can't change directory
# with 'cd', rather you should use 'WORKDIR' instead. Below is an example set of
# instructions to install 'wget', change directory to '/an/example/dir', invoke a shell
# script 'example.sh', and copy a file from the repo into the container:
#    RUN apt-get install wget
#    WORKDIR /an/example/dir
#    RUN sh example.sh
#    COPY file.txt /target/dir/for/file/
