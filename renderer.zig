const std = @import("std");
const gl = @import("pkgs/zig-opengl/exports/gl_4v0.zig");
const imgui = @import("pkgs/imgui/src/main.zig");

pub const Renderer = struct {
    is_initialized: bool = false,
    show_demo_window: bool = true,
    show_another_window: bool = false,
    clear_color: imgui.ImVec4 = .{ .x = 0.45, .y = 0.55, .z = 0.60, .w = 1.00 },
    f: f32 = 0.0,
    counter: i32 = 0,

    fn init(self: *Renderer) void {
        if(self.is_initialized)
        {
            return;
        }
        self.is_initialized=true;

        const io = imgui.GetIO() orelse @panic("GetIO");
        // Load Fonts
        // - If no fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use imgui.PushFont()/PopFont() to select them.
        // - AddFontFromFileTTF() will return the ImFont* so you can store it if you need to select the font among multiple.
        // - If the file cannot be loaded, the function will return NULL. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
        // - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling ImFontAtlas::Build()/GetTexDataAsXXXX(), which ImGui_ImplXXXX_NewFrame below will call.
        // - Read 'docs/FONTS.md' for more instructions and details.
        // - Remember that in C/C++ if you want to include a backslash \ in a string literal you need to write a double backslash \\ !
        //io.Fonts->AddFontDefault();
        //io.Fonts->AddFontFromFileTTF("../../misc/fonts/Roboto-Medium.ttf", 16.0f);
        //io.Fonts->AddFontFromFileTTF("../../misc/fonts/Cousine-Regular.ttf", 15.0f);
        //io.Fonts->AddFontFromFileTTF("../../misc/fonts/DroidSans.ttf", 16.0f);
        //io.Fonts->AddFontFromFileTTF("../../misc/fonts/ProggyTiny.ttf", 10.0f);
        if (io.Fonts) |fonts| {
            const font = fonts.AddFontFromFileTTF("c:\\Windows\\Fonts\\msgothic.ttc", 18.0, null, fonts.GetGlyphRangesJapanese());
            std.debug.assert(font != null);
        }
    }

    pub fn render(self: *Renderer, width: i32, height: i32) void {
        self.init();

        // Start the Dear ImGui frame
        _ = imgui.ImGui_ImplOpenGL3_NewFrame();
        imgui.ImGui_ImplGlfw_NewFrame();
        imgui.NewFrame();

        // 1. Show the big demo window (Most of the sample code is in imgui.ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
        if (self.show_demo_window) {
            imgui.ShowDemoWindow(.{ .p_open = &self.show_demo_window });
        }

        // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
        {
            _ = imgui.Begin("Hello, world!", .{}); // Create a window called "Hello, world!" and append into it.

            imgui.Text("This is some useful text."); // Display some text (you can use a format strings too)
            _ = imgui.Checkbox("Demo Window", &self.show_demo_window); // Edit bools storing our window open/close state
            _ = imgui.Checkbox("Another Window", &self.show_another_window);

            _ = imgui.SliderFloat("float", &self.f, 0.0, 1.0, .{}); // Edit 1 float using a slider from 0.0f to 1.0f
            _ = imgui.ColorEdit3("clear color", &self.clear_color.x, .{}); // Edit 3 floats representing a color

            if (imgui.Button("Button", .{})) // Buttons return true when clicked (most widgets return true when edited/activated)
                self.counter += 1;
            imgui.SameLine(.{});
            // imgui.Text("counter = %d", counter);

            // imgui.Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0 / imgui.GetIO().Framerate, imgui.GetIO().Framerate);
            imgui.End();
        }

        // 3. Show another simple window.
        if (self.show_another_window) {
            _ = imgui.Begin("Another Window", .{ .p_open = &self.show_another_window }); // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
            imgui.Text("Hello from another window!");
            if (imgui.Button("Close Me", .{}))
                self.show_another_window = false;
            imgui.End();
        }

        imgui.Render();
        gl.viewport(0, 0, width, height);

        // Render here
        gl.clearColor(self.clear_color.x * self.clear_color.w, self.clear_color.y * self.clear_color.w, self.clear_color.z * self.clear_color.w, self.clear_color.w);
        gl.clear(gl.COLOR_BUFFER_BIT);
        imgui.ImGui_ImplOpenGL3_RenderDrawData(imgui.GetDrawData());
    }
};
