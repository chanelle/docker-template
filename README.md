# Asyncy Container Template

-- Logo --

This repository services as a template on how to build a Asyncy Container.
Your container could be anything that takes data in and put data out.

#### Container Goals
> 1. **Small footprint.** Containers should be small and quick.
> 2. **Low complexity.** Containers should do one thing really well.
> 3. **Simple in/outs.** Simple to define inputs and outputs.
> 4. **Any language.** Write a container in any programming language.


# How Asyncy runs a container

### Arguments

```sh
# example StoryScript
run owner/container:latest a b c
```

The example above will run the container as follows `docker run owner/container:latest a b c`.

If no arguments are provided in the StoryScript the container `CMD` is used.

### Data

When the StoryScript runs data is passed to and from containers. The file is passed through as a volume to the container.

```sh
# example StoryScript
person = {name: 'Joe'}
run owner/container
```

The container can access the `person` value through a file located at `/storydata.json`.
The docker run command would be `docker run -v "/path/to/data:/storydata.json" owner/container`.

```py
# /storydata.json
{
  "person": {
    "name": "Joe"
  }
}
```

### Environment

Define the environment variables in the `Dockerfile`.
For security purposes, only designated environment variables are passed through containers.

```sh
# Dockerfile
ENV     APPLE   _
ENV     BANANA  _
ENV     kiwi    green
```
> Environment are case-sensitive within your container, however Asyncy will case-insensitive map values.

```sh
asyncy config:set apple=red banana=yellow
```

The docker run command would be `docker run -e APPLE=red -e BANANA=yellow owner/container`.
The variable `kiwi` was not specified in Asyncy, therefore remains default to `green`.


### Ports
> Needs discussion if this opening ports is possible.


### Output
The output must be in `json` format.
The container may change, remove or create new data.
All output is saves, merged into the story data and passed along to the next line in the story.

```py
# /storydata.json
{
  "name": "Joe",
  "age": 10,
  "gender": "m"
}
```

```sh
# storyscipt
run container
# >>> {"last": "Smoe", "age": 11, "__remove": ["gender"]}
```

The output from the container is merged with the previous story data below.

```py
# /storydata.json
{
  "name": "Joe",     # value not adjusted
  "last": "Smoe",    # new value introduced
  "age": 11,         # changed previous value
  # "gender"         # value was removed
}
```
