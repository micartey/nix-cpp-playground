from conan import ConanFile
from conan.tools.gnu import PkgConfigDeps
from conan.tools.meson import Meson, MesonToolchain


class PistacheWebserverConan(ConanFile):
    name = "pistache-webserver"
    version = "1.0.0"
    settings = "os", "compiler", "build_type", "arch"
    options = {"static": [True, False]}
    default_options = {
        "static": False,
        "pistache/*:with_ssl": True,
    }
    requires = (
        "pistache/0.4.25",
        "openssl/[>=3.0]",
        "sqlite3/[>=3.40]",
        "sqlite_orm/1.9.1",
    )

    def layout(self):
        self.folders.source = "."
        self.folders.build = "build"
        self.folders.generators = "build/conan"

    def generate(self):
        deps = PkgConfigDeps(self)
        deps.generate()
        tc = MesonToolchain(self)
        if self.options.static:
            static_flags = [
                "-static",
                "-static-libgcc",
                "-static-libstdc++",
                "-pthread",
            ]
            tc.c_link_args.extend(static_flags)
            tc.cpp_link_args.extend(static_flags)
        tc.generate()

    def build(self):
        meson = Meson(self)
        meson.configure()
        meson.build()
