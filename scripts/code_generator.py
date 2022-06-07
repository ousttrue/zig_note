from typing import Optional
import logging
import pathlib
import coloredlogs
from rawtypes.parser.header import Header, StructConfiguration
from rawtypes.parser.type_context import ParamContext
from rawtypes.interpreted_types.basetype import BaseType
from rawtypes.interpreted_types import ReferenceType
from rawtypes.generator.zig_generator import ZigGenerator

LOGGER = logging.getLogger(__name__)
HERE = pathlib.Path(__file__).absolute().parent
WORKSPACE = HERE.parent


def generate_glfw():
    GLFW_HEADER = WORKSPACE / 'pkgs/glfw/pkgs/glfw/include/GLFW/glfw3.h'
    GLFW_ZIG = WORKSPACE / 'pkgs/glfw/src/main.zig'
    LOGGER.debug(f'{GLFW_HEADER.name} => {GLFW_ZIG}')
    generator = ZigGenerator(Header(GLFW_HEADER))
    generator.generate(GLFW_ZIG)


def generate_nanovg():
    NANOVG_HEADER = WORKSPACE / 'pkgs/nanovg/pkgs/picovg/src/nanovg.h'
    NANOVG_ZIG = WORKSPACE / 'pkgs/nanovg/src/main.zig'
    LOGGER.debug(f'{NANOVG_HEADER.name} => {NANOVG_ZIG}')
    generator = ZigGenerator(Header(NANOVG_HEADER))
    generator.generate(NANOVG_ZIG)


def generate_imgui():
    IMGUI_HEADER = WORKSPACE / 'pkgs/imgui/pkgs/imgui/imgui.h'
    IMGUI_HEADER_INTERNAL = WORKSPACE / 'pkgs/imgui/pkgs/imgui/imgui_internal.h'
    IMGUI_IMPL_GLFW = WORKSPACE / 'pkgs/imgui/pkgs/imgui/backends/imgui_impl_glfw.h'
    IMGUI_IMPL_OPENGL3 = WORKSPACE / \
        'pkgs/imgui/pkgs/imgui/backends/imgui_impl_opengl3.h'
    IMGUI_ZIG = WORKSPACE / 'pkgs/imgui/src/main.zig'
    LOGGER.debug(f'{IMGUI_HEADER.name} => {IMGUI_ZIG}')

    headers = [
        Header(IMGUI_HEADER, include_dirs=[IMGUI_HEADER.parent],
               structs=[
                   StructConfiguration('ImFontAtlas', methods=True),
                   StructConfiguration('ImDrawList', methods=True),
        ],
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
        for template in ('ImVector', 'ImSpan', 'ImChunkStream', 'ImPool', 'ImBitArray'):
            if t.name.startswith(f'{template}<'):
                return template

        if t.name == 'ImStb::STB_TexteditState':
            return 'STB_TexteditState'

    workarounds = generator.generate(
        IMGUI_ZIG, custom=custom, return_byvalue_workaround=True)

    #
    # return byvalue to pointer
    #
    IMGUI_CPP_WORKAROUND = IMGUI_ZIG.parent / 'imvec2_byvalue.cpp'
    with IMGUI_CPP_WORKAROUND.open('w') as w:
        w.write(f'''// https://github.com/ziglang/zig/issues/1481 workaround
#include <imgui.h>

#ifdef __cplusplus
extern "C" {{
#endif
{"".join([w.code for w in workarounds if w.f.path == IMGUI_HEADER])}
#ifdef __cplusplus
}}
#endif        
''')


def main():
    coloredlogs.install(level='DEBUG')
    logging.basicConfig(level=logging.DEBUG)
    generate_glfw()
    generate_imgui()
    generate_nanovg()


if __name__ == '__main__':
    main()
