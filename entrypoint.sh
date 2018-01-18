#!/usr/bin/env sh

# ** Arguments **
#   e.g., run team/container foo bar
echo "$1, $2, ..."
#   >>> "foo, bar, ..."

# ** Files **
#   A volume exists that container all the contents in the
#   repository that the storyscript is executed from.
#   e.g. a file at /assets/template.html in the repository
#   would be found at
cat /tmp/asyncy/repository/assets/template.html

#   You may save any data to the volume
#   These files will be stored for other containers to use
echo "Hello world!" >> /tmp/asyncy/hello.txt

# ** Environment **
#   Only the environment variables defined in the Dockerfile
#   will be set during the docker run command.
#   e.g. see the file Dockerfile in this repository
env
#   >>> CONFIG_OPTIONAL=
#   >>> CONFIG_DEFAULT=default
#   >>> CONFIG_REQUIRED=foobar

# ** stdout **
#   All stdout is passed to the storyscript
echo "hello"

# ** exit status **
#   Exit statuses operate what events occur next
exit 0  # (default) successful run, continue accordingly

exit "Error description"  # Write error to stderr
