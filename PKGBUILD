# Maintainer: Daniel Brain <me@danielbrain.com>
pkgname=libedgetpu-git
pkgver=r63.e35aed1
pkgrel=1
pkgdesc="Google Coral Edge TPU runtime library (direct and throttled)"
arch=('x86_64')
url="https://github.com/dbrain/libedgetpu"
license=('Apache-2.0')
depends=('libusb')
makedepends=('git' 'bazelisk' 'python')
provides=('libedgetpu')
conflicts=('libedgetpu' 'libedgetpu-std' 'libedgetpu-max')
install=libedgetpu.install
source=("${pkgname}::git+https://github.com/dbrain/libedgetpu.git")
sha256sums=('SKIP')

pkgver() {
  cd "${pkgname}"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

build() {
  cd "${pkgname}"
  make libedgetpu

  # Build diagnostic tool (standalone, no Bazel needed)
  gcc -O2 -Wall -o edgetpu-check tools/edgetpu-check.c -ldl
}

package() {
  cd "${pkgname}"

  # Install direct (max performance) library
  install -Dm755 "out/direct/k8/libedgetpu.so.1.0" "${pkgdir}/usr/lib/libedgetpu-direct.so.1.0"
  ln -sf libedgetpu-direct.so.1.0 "${pkgdir}/usr/lib/libedgetpu-direct.so.1"

  # Install throttled (reduced power) library
  install -Dm755 "out/throttled/k8/libedgetpu.so.1.0" "${pkgdir}/usr/lib/libedgetpu-throttled.so.1.0"
  ln -sf libedgetpu-throttled.so.1.0 "${pkgdir}/usr/lib/libedgetpu-throttled.so.1"

  # Default to throttled (safer for thermal management)
  ln -sf libedgetpu-throttled.so.1 "${pkgdir}/usr/lib/libedgetpu.so.1"
  ln -sf libedgetpu.so.1 "${pkgdir}/usr/lib/libedgetpu.so"

  # Public headers
  install -Dm644 "tflite/public/edgetpu.h" "${pkgdir}/usr/include/edgetpu.h"
  install -Dm644 "tflite/public/edgetpu_c.h" "${pkgdir}/usr/include/edgetpu_c.h"

  # Diagnostic tool
  install -Dm755 "edgetpu-check" "${pkgdir}/usr/bin/edgetpu-check"

  # udev rules (allows non-root access to Coral USB devices)
  install -Dm644 "debian/edgetpu-accelerator.rules" \
    "${pkgdir}/usr/lib/udev/rules.d/60-edgetpu-accelerator.rules"
}
