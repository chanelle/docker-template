# Building Asyncy Containers

To make a container Asyncy-ready there are just a few things to be aware of.
Most containers can work quickly with limited configuration.

> Our mission is to make container support **as simple as possible without restricting container capabilities**.

### Topics
1. [Design](#design)
1. [Inputs](#inputs)
1. [Outputs](#outputs)
1. [Commands](#commands)
1. [Environment](#environment)
1. [Metrics](#metrics)
1. [Logs](#logs)
1. [Volumes](#volumes)
1. [Ports](#ports)
1. [Scaling](#scaling)
1. [Health Checks](#health-checks)
1. [Lifecycle](#lifecycle)
1. [Linux Capacities](#linux-capacities)

# Design

Use the best practices from Docker.

A container can accept input and write output (like a traditional function) or stream output into the Storyscript  (like web servers, chat bots, social streams).

# Input

A container accepts input in the same way you would pass the data via `docker run`.
Lists and objects in the Storyscript are encoded in JSON format.

| Shell | Storyscript |
| ----- | ----------- |
| `docker run container args --kwargs` | `container args --kwargs` |
| `docker run alpine echo 'Hello world'` | `alpine echo 'Hello world'` |

# Output

Data written to `stdout` is considered the results of the containers operation.

```py
# Storyscript
data = alpine echo 'Hello world'
log data
>>> 'Hello world'
```

You can also stream data into the Storyscript.

```py
# Storyscript
twitter stream '#FOSS' as tweet
    log tweet.message
>>> "Everything should be #FOSS"
>>> "Checkout my new project on @github #FOSS"
```

# Commands

Defining commands outline the containers operations and assists the service discovery during Storyscript writting.

```yml
# asyncy.yml
commands:
  go:
    help: Short description
    args:
    - name: foo
      type: string
      required: false         # default
      help: Short description
    - bar                     # basic argument, description only
    kwargs:
    - name: block
      type: json
    result:
      type: json
```

### Advanced Configuration

In addition to the basics above there are advanced configurations.

<details>
<summary>Simple Arguments</summary><br>

Containers may list arguments in another way.

```yml
# asyncy.yml
commands:
  go:
    args:
    - foo:string
    - bar
```
Where `foo` must be a string and `bar` can be anything.

</details>

<details>
<summary>Validation</summary><br>

```yml
# asyncy.yml
commands:
  go:
    args:
    - name: color hex
      type: string
      pattern: '^\#?\w{6}$'
```

```yml
# asyncy.yml
commands:
  go:
    args:
    - name: choose
      type: string
      enum:
      - this
      - that
```

</details>

<details>
<summary>Formatting</summary><br>

Change the order of arguments the container will receive.
Default is `'* **'` for all args (ordered) then all kwargs (unordered).

```yml
# asyncy.yml
commands:
  go:
    format: '{bar} {foo} * **' # default
    args:
    - foo
    - bar
```

</details>

<details>
<summary>Additional args and kwargs</summary><br>

Container may optionally disable additional args and kwargs.

```yml
# asyncy.yml
commands:
  go:
    additional_args:
      type: string
    additional_kwargs: false
```

</details>


# Environment

Containers should list environment variables that are needed to run the container.

```yml
# asyncy.yml
env:
  access_token:
    type: string      # define the object type: string, int, list
    pattern: "^key_"  # regexp validation
    required: true    # default
    help: |
      Description of how the user should produce this variable
```
> Lists are JSON encoded `KEY="[1,2,3]"`

Containers will **only** get the environment variables that are requested.
Application and other container environment variables are strictly not provided.

# Metrics

Containers can write custom metrics which are handled automatically by Asyncy.

Choose your metrics output format:

<details>
<summary>Metrics 2.0 (recommended)</summary><br>

Write [Metrics 2.0](http://metrics20.org/) output to `/data/metrics/2.0`.

```shell
echo '
{
    host: dfs1
    what: diskspace
    mountpoint: srv/node/dfs10
    unit: B
    type: used
    metric_type: gauge
}
meta: {
    agent: diamond,
    processed_by: statsd2
}
' >> /data/metrics/2.0
```

</details>


# Logs

Write logs to `/data/logs` formatted with log level first.

```shell
echo 'INFO foobar' > /data/logs
```
> `INFO` is assumed if no level is provided.
> Timestamp is included if not provided.



# Volumes

### Story Volume
A temporary volume is unique to each Storyline and destroyed when the Storyline finishes. If a Storyline is paused the volume will persist until.

```yml
# asyncy.yml
volumes:
  story:
    dest: /tmp/session
    mode: rw
```

### Repository Volume
This volume is a clone of the repository from which the Storyscript is stored.
Access the repository assets e.g., images, html and source code.
Changes made to this volume will not commit back to source repository.

```yml
# asyncy.yml
volumes:
  repository:
    dest: /tmp/repository
    mode: rw
```

### Persistent Volume

Persistent volumes may be created and shared between containers. Used for storing long-term data.

```yml
# asyncy.yml
volumes:
  foobar:  # custom title
    dest: /var/data
```

# Scaling

Define scaling schedules.

```yml
# asyncy.yml
scale:
  # [TODO]
```

# Ports

List the ports that need binding upon container startup.

```yml
# asyncy.yml
ports:
  - 8080
```

# System Requirements

Define containers system requirements.

```yml
# asyncy.yml
system:
  cpu: 1         # default
  gpu: 0         # default
  memory: 250GB  # default
```

# Health Checks

Inherit from the Dockerfile's `HEALTHCHECK`. https://docs.docker.com/engine/reference/builder/#healthcheck

# Lifecycle

Asyncy will startup containers before they are called in the Storyscript and shutdown the container once no longer needed.
A user-defined command may be provided to prepare the containers execution environment or clean-up workspace.

```yml
# asyncy.yml
lifecycle:
  startup: ./startup.sh
  shutdown: ./shutdown.sh
```

This command must exit with status 0. `stdout` is logged and not accessable in the Storyline.

# Linux Capacities

All capacities are stripped from the containers.
It's required to list linux capacities in the configuration.
Learn more about [Docker runtime privilege and linux capabilities](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities).

```yml
# asyncy.yml
cap:
  - chown
```
> The configuration above will designate `chown` to be included in the capabilities.
