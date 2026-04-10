"""
This module contains workspace definitions for building and using libedgetpu.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# TF release 2.21.0 as of 2026-04-10.
TENSORFLOW_COMMIT = "a481b10260dfdf833a1b16007eead49c1d7febf3"
TENSORFLOW_SHA256 = "ef3568bb4865d6c1b2564fb5689c19b6b9a5311572cd1f2ff9198636a8520921"

# Crosstool release as of 02/28/2023.
CORAL_CROSSTOOL_COMMIT = "8e885509123395299bed6a5f9529fdc1b9751599"
CORAL_CROSSTOOL_SHA256 = "f86d488ca353c5ee99187579fe408adb73e9f2bb1d69c6e3a42ffb904ce3ba01"

def libedgetpu_dependencies(
        tensorflow_commit = TENSORFLOW_COMMIT,
        tensorflow_sha256 = TENSORFLOW_SHA256):
    """Sets up libedgetpu dependencies.

    Args:
      tensorflow_commit: https://github.com/tensorflow/tensorflow commit ID
      tensorflow_sha256: corresponding sha256 of the source archive
    """
    maybe(
        http_archive,
        name = "org_tensorflow",
        urls = [
            "https://github.com/tensorflow/tensorflow/archive/" + tensorflow_commit + ".tar.gz",
        ],
        sha256 = tensorflow_sha256,
        strip_prefix = "tensorflow-" + tensorflow_commit,
        patches = ["//patches:add_configure_cuda.diff"],
        patch_args = ["-p1"],
    )

    maybe(
        libusb_repository,
        name = "libusb",
    )

    _properties_repository(
        name = "libedgetpu_properties",
        properties = {
            "tensorflow_commit": tensorflow_commit,
        },
    )

def _brew_libusb_path(ctx):
    res = ctx.execute(["/bin/bash", "-c", "command -v brew"])
    if res.return_code != 0:
        return None
    brew = ctx.path(res.stdout.strip())

    res = ctx.execute([brew, "ls", "--versions", "libusb"])
    if res.return_code != 0:
        return None

    res = ctx.execute([brew, "--prefix", "libusb"])
    if res.return_code != 0:
        return None

    return res.stdout.strip()

def _port_libusb_path(ctx):
    res = ctx.execute(["/bin/bash", "-c", "command -v port"])
    if res.return_code != 0:
        return None
    port = ctx.path(res.stdout.strip())

    res = ctx.execute([port, "info", "libusb"])
    if res.return_code != 0:
        return None

    return port.dirname.dirname

def _libusb_impl(ctx):
    lower_name = ctx.os.name.lower()
    if lower_name.startswith("linux"):
        path = None
        build_file_content = """
cc_library(
  name = "headers",
  linkopts = ["-l:libusb-1.0.so"],
  visibility = ["//visibility:public"],
)
"""
    elif lower_name.startswith("mac os x"):
        path = _brew_libusb_path(ctx)
        if not path:
            path = _port_libusb_path(ctx)
            if not path:
                fail("Install libusb using MacPorts or Homebrew.")

        build_file_content = """
cc_library(
  name = "headers",
  includes = ["root/include"],
  hdrs = ["root/include/libusb-1.0/libusb.h"],
  srcs = ["root/lib/libusb-1.0.dylib"],
  visibility = ["//visibility:public"],
)
"""
    else:
        fail("Unsupported operating system.")

    if path:
        ctx.symlink(path, "root")
    ctx.file(
        "BUILD",
        content = build_file_content,
        executable = False,
    )

libusb_repository = repository_rule(
    implementation = _libusb_impl,
)

def _properties_impl(ctx):
    content = ""
    for name, value in ctx.attr.properties.items():
        content += "filegroup(name='" + name + "#" + value + "')\n"
    ctx.file("BUILD", content = content, executable = False)

_properties_repository = repository_rule(
    implementation = _properties_impl,
    attrs = {
        "properties": attr.string_dict(),
    },
)
