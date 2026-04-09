load(":cc_toolchain_config.bzl", "cc_toolchain_config")

package(default_visibility = ["//visibility:public"])

cc_toolchain_suite(
    name = "toolchains",
    toolchains = {
        "k8": ":cc-compiler-k8",
        "k8|gcc": ":cc-compiler-k8",
        "armv7a": ":cc-compiler-armv7a",
        "armv7a|gcc": ":cc-compiler-armv7a",
        "aarch64": ":cc-compiler-aarch64",
        "aarch64|gcc": ":cc-compiler-aarch64",
        "riscv64": ":cc-compiler-riscv64",
        "riscv64|gcc": ":cc-compiler-riscv64",
    },
)

filegroup(name = "empty")

cc_toolchain(
    name = "cc-compiler-k8",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    dynamic_runtime_lib = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    static_runtime_lib = ":empty",
    strip_files = ":empty",
    supports_param_files = True,
    toolchain_config = ":k8-config",
)

cc_toolchain_config(
    name = "k8-config",
    cpu = "k8",
)

cc_toolchain(
    name = "cc-compiler-armv7a",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    dynamic_runtime_lib = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    static_runtime_lib = ":empty",
    strip_files = ":empty",
    supports_param_files = True,
    toolchain_config = ":armv7a-config",
)

cc_toolchain_config(
    name = "armv7a-config",
    cpu = "armv7a",
)

cc_toolchain(
    name = "cc-compiler-aarch64",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    dynamic_runtime_lib = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    static_runtime_lib = ":empty",
    strip_files = ":empty",
    supports_param_files = True,
    toolchain_config = ":aarch64-config",
)

cc_toolchain_config(
    name = "aarch64-config",
    cpu = "aarch64",
)

cc_toolchain(
    name = "cc-compiler-riscv64",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    dynamic_runtime_lib = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    static_runtime_lib = ":empty",
    strip_files = ":empty",
    supports_param_files = True,
    toolchain_config = ":riscv64-config",
)

cc_toolchain_config(
    name = "riscv64-config",
    cpu = "riscv64",
)
