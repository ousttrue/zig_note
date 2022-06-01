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


def generate_imgui():
    IMGUI_HEADER = WORKSPACE / 'pkgs/imgui/pkgs/imgui/imgui.h'
    IMGUI_IMPL_GLFW = WORKSPACE / 'pkgs/imgui/pkgs/imgui/backends/imgui_impl_glfw.h'
    IMGUI_IMPL_OPENGL3 = WORKSPACE / \
        'pkgs/imgui/pkgs/imgui/backends/imgui_impl_opengl3.h'
    IMGUI_ZIG = WORKSPACE / 'pkgs/imgui/src/main.zig'
    LOGGER.debug(f'{IMGUI_HEADER.name} => {IMGUI_ZIG}')

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

    # 
    # return byvalue to pointer
    #
    IMGUI_CPP_WORKAROUND = IMGUI_ZIG.parent / 'imvec2_byvalue.cpp'
    with IMGUI_CPP_WORKAROUND.open('w') as w:
        w.write('''// https://github.com/ziglang/zig/issues/1481 workaround
#include <imgui.h>

#ifdef __cplusplus
extern "C" {
#endif
''')

        def to_cpp_arg(p: ParamContext):
            # t = generator.type_manager.to_type(p)
            return f'{p.type.spelling} {p.name}'

        for f in generator.parser.functions:
            if 'ImVec' in f.result_type.spelling:
                result = generator.type_manager.to_type(f.result)
                if isinstance(result, ReferenceType):
                    result = result.base

                args = [f'{result.name} *__ret__'] + [to_cpp_arg(p) for p in f.params]
                calls = [p.name for p in f.params]

                w.write(f'''
void imgui_{f.cursor.spelling}({", ".join(args)})
{{
    *__ret__ = ImGui::{f.cursor.spelling}({", ".join(calls)});
}}
''')

        w.write('''
#ifdef __cplusplus
}
#endif        
''')

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
