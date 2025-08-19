import motrack
import stbi
import gg

struct App {
mut:
	ctx   &gg.Context = unsafe { nil }
	coord motrack.Coord
	image gg.Image
}

fn main() {
	image := stbi.load('${@VMODROOT}/examples/img.jpg')!
	mut pixel_data := []u8{len: image.width * image.height * image.nr_channels}
	for i in 0 .. image.width * image.height * image.nr_channels {
		pixel_data[i] = unsafe { image.data[i] }
	}

	mut app := &App{}
	app.ctx = gg.new_context(
		create_window: true
		frame_fn:      on_frame
		user_data:     app
	)
	app.coord = motrack.track_ball(pixel_data, image.width, image.height, image.nr_channels)
	app.image = app.ctx.create_image('${@VMODROOT}/examples/img.jpg')!
	app.ctx.run()
}

fn on_frame(mut app App) {
	app.ctx.begin()
	app.ctx.draw_image(0, 0, app.image.width, app.image.height, app.image)
	app.ctx.draw_circle_filled(app.coord.x, app.coord.y, 10, gg.red)
	app.ctx.end()
}
