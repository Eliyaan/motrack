import motrack
import stbi

fn main() {
	// n := 7
	// a := motrack.generer_masque(n)
	// for l in a {
	// 	println(l)
	// }
	image := stbi.load('${@VMODROOT}/examples/img.jpg')!
	mut pixel_data := []u8{len: image.width * image.height * image.nr_channels}
	for i in 0 .. image.width * image.height * image.nr_channels {
		pixel_data[i] = unsafe { image.data[i] }
	}
	motrack.track_ball(pixel_data, image.width, image.height, image.nr_channels, 70)
}
