import pathlib

HERE = pathlib.Path(__file__).absolute().parent
WORKSPACE = HERE.parent

GLFW_HEADER = WORKSPACE / \
    'pkgs/imgui/pkgs/imgui/examples/libs/glfw/include/GLFW/glfw3.h'
GLFW_ZIG = WORKSPACE / 'pkgs/glfw/src/main.zig'


def main():
    from rawtypes.parser.header import Header
    from rawtypes.generator.zig_generator import ZigGenerator
    generator = ZigGenerator(Header(GLFW_HEADER))

    generator.generate(GLFW_ZIG)


if __name__ == '__main__':
    main()
