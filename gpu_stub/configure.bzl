"""Stub repository rules for GPU configs and other TF infra repos.

These provide the build_defs.bzl and targets that TF unconditionally loads,
but with everything disabled since libedgetpu doesn't use GPU acceleration.
"""

_CUDA_BUILD_DEFS = """
def cuda_library(**kwargs):
    native.cc_library(**kwargs)

def if_cuda(if_true, if_false = []):
    return if_false

def if_cuda_exec(if_true, if_false = []):
    return if_false

def if_cuda_is_configured(if_true, if_false = []):
    return if_false

def is_cuda_configured():
    return False

def if_cuda_newer_than(wanted_ver, if_true, if_false = []):
    return if_false
"""

_ROCM_BUILD_DEFS = """
def if_rocm(if_true, if_false = []):
    return if_false

def rocm_copts():
    return []

def if_rocm_is_configured(if_true, if_false = []):
    return if_false
"""

_TENSORRT_BUILD_DEFS = """
def if_tensorrt(if_true, if_false = []):
    return if_false

def if_tensorrt_exec(if_true, if_false = []):
    return if_false
"""

_NVIDIA_COMMON_RULES = """
def cuda_rpath_flags(relpath):
    return []
"""

_WHEEL_VERSION_SUFFIX = """
WHEEL_VERSION_SUFFIX = ""
SEMANTIC_WHEEL_VERSION_SUFFIX = ""
"""

def _gpu_stub_impl(ctx):
    if ctx.attr.kind == "cuda":
        ctx.file("cuda/build_defs.bzl", _CUDA_BUILD_DEFS)
        ctx.file("cuda/BUILD", """
package(default_visibility = ["//visibility:public"])
cc_library(name = "cuda_headers", hdrs = [])
cc_library(name = "cuda_runtime", hdrs = [])
""")
        ctx.file("BUILD", 'package(default_visibility = ["//visibility:public"])')
    elif ctx.attr.kind == "rocm":
        ctx.file("rocm/build_defs.bzl", _ROCM_BUILD_DEFS)
        ctx.file("rocm/BUILD", 'package(default_visibility = ["//visibility:public"])')
        ctx.file("BUILD", 'package(default_visibility = ["//visibility:public"])')
    elif ctx.attr.kind == "tensorrt":
        ctx.file("build_defs.bzl", _TENSORRT_BUILD_DEFS)
        ctx.file("BUILD", 'package(default_visibility = ["//visibility:public"])')
    elif ctx.attr.kind == "nccl":
        ctx.file("BUILD", 'package(default_visibility = ["//visibility:public"])')
    elif ctx.attr.kind == "rules_ml_toolchain":
        ctx.file("third_party/gpus/nvidia_common_rules.bzl", _NVIDIA_COMMON_RULES)
        ctx.file("third_party/gpus/BUILD", 'package(default_visibility = ["//visibility:public"])')
        ctx.file("BUILD", 'package(default_visibility = ["//visibility:public"])')
    elif ctx.attr.kind == "wheel_suffix":
        ctx.file("wheel_version_suffix.bzl", _WHEEL_VERSION_SUFFIX)
        ctx.file("BUILD", 'package(default_visibility = ["//visibility:public"])')
    else:
        ctx.file("BUILD", 'package(default_visibility = ["//visibility:public"])')

gpu_stub_repository = repository_rule(
    implementation = _gpu_stub_impl,
    attrs = {
        "kind": attr.string(mandatory = True),
    },
)
