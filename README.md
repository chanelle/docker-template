# Asyncy Container Template

This repository serves as a template on how to build a container for Asyncy.

#### Container Goals
> 1. **Small footprint.** Containers should be small and quick.
> 2. **Low complexity.** Containers should do one thing really well.
> 3. **Simple in/outs.** Simple to define inputs and outputs.
> 4. **Any language.** Write a container in any programming language.

# Asyncy Container Guide

There are 5 important aspects to Asyncy containers to keep in mind
1. Starting Arguments
1. Volumes and Files
1. Environment Variables
1. Output
1. Port Binding

### Starting Arguments

These arguments are provided in the Storyscript, as seen below in this example.

```rb
# example Storyscript
a = 10
b = "string"
if true
  run owner/container a b
```

This script above would a container like this: `docker run owner/container 10 "string"`.

> **Note** in your Dockerfile the `ENTRYPOINT` will be executed with the provided arguemnts.
> If no arguments are provied the `CMD` in your Dockerfile is executed. This is default Docker behavior.


### Volume and Files

When a container runs it is passed a shared volume which is private to the Storyline and writable.

```
/tmp/asyncy
           /repository     # This is the repository the Storyscript belongs to. [Read-only]
           /example
              /foobar.txt  # A file that a previous container wrote. [Read-Write]
```

Your container can read assets from the repository, such as html files, images, etc.
Your container may write files to the volume. These files are stored in the volume for the next containers being executed.


### Environment Variables

Define the environment variables in the `Dockerfile`.
For security purposes, only designated environment variables are passed through containers.

```sh
# Dockerfile
ENV     EXAMPLE_DEFAULT    default
ENV     EXAMPLE_REQUIRED   !
ENV     EXAMPLE_OPTIONAL   _
ENV     EXAMPLE_READONLY   data --read-only
```
> Environment are case-sensitive within your container. Asyncy will case-insensitive map environment variables.

```sh
# using Asyncy CLI
asyncy config:set example_required=red EXAMPLE_OPTIONAL=yellow
```


### Output

#### Stdout
All container `stdout` is passed back to the Storyscript when the container exits with status `0` (default).

```sh
# your foobar/container
echo "Hello world"
```

```sh
# Storyscript
data = foobar/container
print data
>>> "Hello world"
```

#### Stderr
If your container exits with not `0` it is considered an error.
Stdout will be logged then ignored.
Stderr will be used as the description for the error.

```sh
# your foobar/container
echo "Hello world"
exit "Woops!"
```

```sh
# Storyscript
try
  data = foobar/container
  print data
catch output
  print output
>>> "Woops!"
```
> The variable data was never assigned because the container exited with an error.

#### Iteration
Containers that yield data but remain running are considered streaming containers.

To yield data back into the Storyscript write the data to stdout then a carriage return character to designate the end of the current yield.

```sh
# your foobar/container
echo "1"
echo -e "\r"
exit "2"
```

```sh
# Storyscript
stream foobar/container as res
  print res
  print 'done'
>>> "1"
>>> "done"
>>> "2"
>>> "done"
```


### Port Binding
Your container may require port binding. To request a port binding simply add the port number to the Dockerfile under `EXPOSE`.
The container then can bind to the port and wait for incoming traffic.
