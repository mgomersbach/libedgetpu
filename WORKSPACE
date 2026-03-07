# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
workspace(name = "libedgetpu")

load(":workspace.bzl", "libedgetpu_dependencies")
libedgetpu_dependencies()

# ==================================================================

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# rules_shell is required before tf_workspace3 for TF 2.21+
load("@org_tensorflow//third_party:repo.bzl", "tf_http_archive", "tf_mirror_urls")

tf_http_archive(
    name = "rules_shell",
    sha256 = "bc61ef94facc78e20a645726f64756e5e285a045037c7a61f65af2941f4c25e1",
    strip_prefix = "rules_shell-0.4.1",
    urls = tf_mirror_urls(
        "https://github.com/bazelbuild/rules_shell/releases/download/v0.4.1/rules_shell-v0.4.1.tar.gz",
    ),
)

# ==================================================================

load("@org_tensorflow//tensorflow:workspace3.bzl", "tf_workspace3")
tf_workspace3()

load("@rules_shell//shell:repositories.bzl", "rules_shell_dependencies", "rules_shell_toolchains")
rules_shell_dependencies()
rules_shell_toolchains()

# ==================================================================

# Initialize hermetic Python (TF 2.21+ pattern via @xla)
load("@xla//third_party/py:python_init_rules.bzl", "python_init_rules")
python_init_rules()

load("@xla//third_party/py:python_init_repositories.bzl", "python_init_repositories")
python_init_repositories(
    default_python_version = "system",
    requirements = {
        "3.10": "@org_tensorflow//:requirements_lock_3_10.txt",
        "3.11": "@org_tensorflow//:requirements_lock_3_11.txt",
        "3.12": "@org_tensorflow//:requirements_lock_3_12.txt",
        "3.13": "@org_tensorflow//:requirements_lock_3_13.txt",
    },
)

load("@xla//third_party/py:python_init_toolchains.bzl", "python_init_toolchains")
python_init_toolchains()

load("@xla//third_party/py:python_init_pip.bzl", "python_init_pip")
python_init_pip()

load("@pypi//:requirements.bzl", "install_deps")
install_deps()

# ==================================================================

load("@org_tensorflow//tensorflow:workspace2.bzl", "tf_workspace2")
tf_workspace2()

load("@org_tensorflow//tensorflow:workspace1.bzl", "tf_workspace1")
tf_workspace1()

load("@org_tensorflow//tensorflow:workspace0.bzl", "tf_workspace0")
tf_workspace0()

# ==================================================================

# GPU stub repositories — TF unconditionally loads these but libedgetpu
# doesn't need GPU acceleration.
local_repository(
    name = "gpu_stub",
    path = "gpu_stub",
)
load("@gpu_stub//:configure.bzl", "gpu_stub_repository")
gpu_stub_repository(name = "local_config_cuda", kind = "cuda")
gpu_stub_repository(name = "local_config_rocm", kind = "rocm")
gpu_stub_repository(name = "local_config_tensorrt", kind = "tensorrt")
gpu_stub_repository(name = "local_config_nccl", kind = "nccl")
gpu_stub_repository(name = "tf_wheel_version_suffix", kind = "wheel_suffix")
gpu_stub_repository(name = "rules_ml_toolchain", kind = "rules_ml_toolchain")

# ==================================================================

local_repository(
    name = "local_crosstool",
    path = "crosstool",
)
load("@local_crosstool//:configure.bzl", "cc_crosstool")
cc_crosstool(name = "crosstool", cpp_version = "c++17")
