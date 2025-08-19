import motrack
import stbi
import gg

struct App {
mut:
	ctx   &gg.Context = unsafe { nil }
	coo   motrack.Coo
	image gg.Image
}

fn main() {
	image := stbi.load('img.jpg')!
	mut pixel_data := []u8{len: image.width * image.height}
	for i in 0 .. image.width * image.height {
		pixel_data[i] = unsafe { image.data[i] }
	}

	mut app := &App{}
	app.ctx = gg.new_context(
		create_window: true
		frame_fn: on_frame
                user_data:     app
	)
	app.coo = motrack.track_ball(pixel_data, image.width, image.height, image.nr_channels)
	app.image = app.ctx.create_image('img.jpg')!
	app.ctx.run()
}

fn on_frame(mut app App) {
	app.ctx.begin()
	app.ctx.draw_image(0, 0, app.image.width, app.image.height, app.image)
	app.ctx.draw_circle_filled(app.coo.x, app.coo.y, 10, gg.red)
	app.ctx.end()
}
