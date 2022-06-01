# ircDDBGateway OCI Container

This builds an OCI compliant container image running the G4KLX's
[ircDDBGateway](https://github.com/g4klx/ircDDBGateway).

## Tools (required to build)

- [Buildah](https://buildah.io/)
- [qemu-user-static](https://github.com/multiarch/qemu-user-static) (for
  multi-arch builds)

## Building
To build and push a multi-arch image to Docker Hub at `sq7lrx/ircddbgateway`:

```sh
git clone https://github.com/sq7lrx/ircddbgateway-docker.git
cd ircddbgateway-docker
export IMAGE=docker.io/sq7lrx/ircddbgateway
./build.sh
```