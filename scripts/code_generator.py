from typing import Optional
import logging
import pathlib
import coloredlogs
from rawtypes.parser.header import Header, StructConfiguration
from rawtypes.generator.zig_generator import ZigGenerator
from rawtypes.interpreted_types.basetype import BaseType


LOGGER = logging.getLogger(__name__)
HERE = pathlib.Path(__file__).absolute().parent
WORKSPACE = HERE.parent


GLFW_HEADER = WORKSPACE / 'pkgs/glfw/pkgs/glfw/include/GLFW/glfw3.h'
GLFW_ZIG = WORKSPACE / 'pkgs/glfw/src/main.zig'


IMGUI_HEADER = WORKSPACE / 'pkgs/imgui/pkgs/imgui/imgui.h'
IMGUI_IMPL_GLFW = WORKSPACE / 'pkgs/imgui/pkgs/imgui/backends/imgui_impl_glfw.h'
IMGUI_IMPL_OPENGL3 = WORKSPACE / \
    'pkgs/imgui/pkgs/imgui/backends/imgui_impl_opengl3.h'
IMGUI_ZIG = WORKSPACE / 'pkgs/imgui/src/main.zig'


def generate_glfw():
    LOGGER.debug(f'glfw')
    generator = ZigGenerator(Header(GLFW_HEADER))
    generator.generate(GLFW_ZIG)


def generate_imgui():
    LOGGER.debug(f'imgui')

    headers = [
        Header(IMGUI_HEADER, include_dirs=[IMGUI_HEADER.parent],
               structs=[StructConfiguration('ImFontAtlas', methods=True)],
               begin='''
pub const ImVector = extern struct {
    Size: c_int,
    Capacity: c_int,
    Data: *anyopaque,
};

'''),
        Header(IMGUI_IMPL_GLFW),
        Header(IMGUI_IMPL_OPENGL3),
    ]

    generator = ZigGenerator(*headers)

    def custom(t: BaseType) -> Optional[str]:
        if t.name.startswith('ImVector<'):
            return 'ImVector'

    generator.generate(IMGUI_ZIG, custom=custom)


def main():
    coloredlogs.install(level='DEBUG')
    logging.basicConfig(level=logging.DEBUG)
    generate_glfw()
    generate_imgui()


if __name__ == '__main__':
    main()
