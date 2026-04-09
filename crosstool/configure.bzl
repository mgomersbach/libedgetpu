"""Rules for configuring the C++ cross-toolchain."""

def _get_gcc_include_dirs(ctx, compiler):
    """Query the compiler for its built-in include directories."""
    res = ctx.execute(["/bin/bash", "-c", "%s -E -xc++ - -v < /dev/null 2>&1" % compiler])
    if res.return_code != 0:
        return []
    lines = res.stdout.split("\n") + res.stderr.split("\n")
    in_includes = False
    dirs = []
    for line in lines:
        if "#include <...> search starts here:" in line:
            in_includes = True
            continue
        if "End of search list." in line:
            break
        if in_includes and line.startswith(" "):
            dirs.append(line.strip())
    return dirs

def _impl(repository_ctx):
    dir_labels = repository_ctx.attr.additional_system_include_directories
    additional_include_dirs = ", ".join([
        '"%s"' % repository_ctx.path(dir_label.relative("BUILD")).dirname
        for dir_label in dir_labels
    ])

    # Detect k8 GCC include directories dynamically
    k8_include_dirs = _get_gcc_include_dirs(repository_ctx, "/usr/bin/x86_64-linux-gnu-gcc")
    if not k8_include_dirs:
        k8_include_dirs = _get_gcc_include_dirs(repository_ctx, "gcc")
    k8_include_dirs_str = ", ".join(['"%s"' % d for d in k8_include_dirs])

    gcc_version = repository_ctx.execute(["/bin/bash", "-c", "gcc -dumpversion | cut -f1 -d."]).stdout.strip() or "0"
    bcm2708_toolchain_root = repository_ctx.os.environ.get("BCM2708_TOOLCHAIN_ROOT", "/tools/arm-bcm2708")

    # Detect k8 tool prefix: use x86_64-linux-gnu- if ar exists there, otherwise /usr/bin/
    k8_tool_prefix = "/usr/bin/x86_64-linux-gnu-"
    res = repository_ctx.execute(["/bin/bash", "-c", "test -x /usr/bin/x86_64-linux-gnu-ar"])
    if res.return_code != 0:
        k8_tool_prefix = "/usr/bin/"

    repository_ctx.template(
        "cc_toolchain_config.bzl",
        Label("//:cc_toolchain_config.bzl.tpl"),
        {
            "%{gcc_version}%": gcc_version,
            "%{c_version}%": repository_ctx.attr.c_version,
            "%{cpp_version}%": repository_ctx.attr.cpp_version,
            "%{bcm2708_toolchain_root}%": bcm2708_toolchain_root,
            "%{additional_system_include_directories}%": additional_include_dirs,
            "%{k8_include_directories}%": k8_include_dirs_str,
            "%{k8_tool_prefix}%": k8_tool_prefix,
        },
    )
    repository_ctx.template(
        "BUILD",
        Label("//:BUILD.tpl"),
        {},
    )

cc_crosstool = repository_rule(
    environ = [
        "BCM2708_TOOLCHAIN_ROOT",
    ],
    attrs = {
        "c_version": attr.string(default = "c99"),
        "cpp_version": attr.string(default = "c++11"),
        "additional_system_include_directories": attr.label_list(allow_files = True),
    },
    implementation = _impl,
    local = True,
)
