#pragma once

#include <vcpkg/base/files.h>

namespace vcpkg
{
    struct VcpkgPaths;
}

namespace vcpkg::Archives
{
    void extract_archive(const VcpkgPaths& paths, const fs::path& archive, const fs::path& to_path);
}
