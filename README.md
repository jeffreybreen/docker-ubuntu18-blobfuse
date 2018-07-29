# docker-ubuntu18-blobfuse

Docker image based on ubuntu:18.04 which mounts an Azure blob
container via [Microsoft's FUSE
driver](https://github.com/Azure/azure-storage-fuse).

## `mount-blobfuse.sh` entrypoint

The provided `mount-blobfuse.sh` entrypoint simply mounts the given blob
container at the specified mount point and then executes whatever
command was provided via `exec "$@"`.

`make shell` is a shortcut for specifying `/bin/bash` to the `docker
run` command.

## Environment variables

The entrypoint expects the following environment variables:

* `AZURE_STORAGE_ACCOUNT`
* `AZURE_STORAGE_ACCESS_KEY` or `AZURE_STORAGE_SAS_TOKEN`
* `AZURE_STORAGE_ACCOUNT_CONTAINER`
* `AZURE_MOUNT_POINT`

Note: You must provide either `AZURE_STORAGE_ACCESS_KEY` or
`AZURE_STORAGE_SAS_TOKEN`. If you specify both, blobfuse will fail and
remind you "exactly one of the environment variables
`AZURE_STORAGE_ACCESS_KEY` or `AZURE_STORAGE_SAS_TOKEN` must be set."


As documented in the `Makefile`, there are (at least) three different
ways to handle these environment variables:

* If the calling shell already has the proper environment variables set,
simply naming them via the `-e` flag to `docker run` will safely pass in their
values automatically:
```
ENV = \
  -e AZURE_STORAGE_ACCOUNT \
  -e AZURE_STORAGE_SAS_TOKEN \
  -e AZURE_STORAGE_ACCOUNT_CONTAINER \
  -e AZURE_MOUNT_POINT
```

* During development, it may be convenient to read these environment
variables into `make` from a file (_e.g.,_ via the `include .env`
directive). You would then need to pass the names and values to `docker
run` **which would expose their values to the command line (and `ps`)**:
```
ENV = \
  -e AZURE_STORAGE_ACCOUNT="${AZURE_STORAGE_ACCOUNT}" \
  -e AZURE_STORAGE_SAS_TOKEN="${AZURE_STORAGE_SAS_TOKEN}" \
  -e AZURE_STORAGE_ACCOUNT_CONTAINER="${AZURE_STORAGE_ACCOUNT_CONTAINER}" \
  -e AZURE_MOUNT_POINT="${AZURE_MOUNT_POINT}"
```
 
* A safer way to read these credentials from a file is to use the `--env-file` flag to `docker run`:
```
ENV = --env_file /path/to/azure_secrets.env
```

See [this informative article by Vladislav
Supalov](https://vsupalov.com/docker-arg-env-variable-guide/) for more
information about passing environment variables to Docker containers,
including with Docker Compose.
