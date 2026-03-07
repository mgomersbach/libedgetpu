# Edge TPU runtime library (libedgetpu)

Community-maintained fork of the userspace runtime driver for
[Coral Edge TPU](https://coral.ai/products) devices (USB Accelerator and PCIe).

The upstream repo ([google-coral/libedgetpu](https://github.com/google-coral/libedgetpu))
has been archived. This fork keeps the library building against modern toolchains
and TensorFlow releases.

## Current versions

| Component | Version |
|-----------|---------|
| TensorFlow | 2.21.0 |
| Bazel | 7.7.0 |
| GCC | 15+ supported |

## Quick start (Arch Linux)

Install from AUR or build locally:

```
makepkg -si
```

Or build manually:

```
make libedgetpu
sudo cp out/direct/k8/libedgetpu.so.1.0 /usr/lib/
sudo ln -sf libedgetpu.so.1.0 /usr/lib/libedgetpu.so.1
sudo ln -sf libedgetpu.so.1 /usr/lib/libedgetpu.so
sudo cp debian/edgetpu-accelerator.rules /etc/udev/rules.d/99-edgetpu-accelerator.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
```

## Building

### Prerequisites

- [Bazelisk](https://github.com/bazelbuild/bazelisk) (or Bazel 7.7.0)
- libusb 1.0
- GCC (tested with 15.x; older versions should also work)
- Python 3 (build-time only, for Bazel's hermetic toolchain)

The `.bazelversion` file ensures bazelisk downloads the correct Bazel version automatically.

### Native build (Linux)

```
make libedgetpu
```

This builds both `direct` (max performance) and `throttled` (reduced clock, safer thermals)
variants into `out/direct/k8/` and `out/throttled/k8/`.

### Cross-compile

```
CPU=aarch64 make
CPU=armv7a make
```

### Docker build

```
DOCKER_CPUS="k8" DOCKER_IMAGE="ubuntu:22.04" DOCKER_TARGETS=libedgetpu make docker-build
DOCKER_CPUS="armv7a aarch64" DOCKER_IMAGE="debian:bookworm" DOCKER_TARGETS=libedgetpu make docker-build
```

### Debian package

```
debuild -us -uc -tc -b
```

## Verifying your device

After installing, check that your Edge TPU is detected:

```
edgetpu-check
```

To also test the USB connection by uploading firmware (catches bad cables):

```
edgetpu-check --test
```

## Device setup

### udev rules (Linux)

The Coral USB Accelerator needs udev rules for non-root access:

```
sudo cp debian/edgetpu-accelerator.rules /etc/udev/rules.d/99-edgetpu-accelerator.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
```

The rules use the `plugdev` group. Create it and add your user:

```
sudo groupadd plugdev
sudo usermod -aG plugdev $USER
```

Then log out and back in.

### Direct vs throttled

- **Throttled** (default, recommended): reduced clock speed, safer thermals
- **Direct**: maximum performance, device may get hot under sustained load

**Warning:** The Edge TPU can get very hot during operation. The Coral USB
Accelerator is designed to safely operate at the following temperatures:

- **Direct (max frequency):** ambient temperatures up to 25°C
- **Throttled (reduced frequency):** ambient temperatures up to 35°C

Touching the device during or immediately after operation at high temperatures
may cause burns. The USB Accelerator does not include built-in thermal
management — use the throttled variant unless you need peak throughput and have
adequate cooling (e.g. a heatsink or active airflow).

## License

[Apache License 2.0](LICENSE)
