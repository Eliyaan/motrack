module motrack

import stbi
import arrays

pub struct Coord {
pub mut:
	x f32
	y f32
}

struct ImageRGB {
mut:
	red   [][]int
	green [][]int
	blue  [][]int
}

pub fn generer_masque(rayon int) ([][]f32, int) {
	// Pour créer le masque, on va calculer la position de chaque élement du tableau et on va voir s'il est dans le cercle pour savoir si on met un 1 ou non
	taille_masque := rayon * 2 + 1
	mut masque := [][]int{len: taille_masque, init: []int{len: taille_masque, init: 1}}
	milieu := rayon // rajouter condition si <1
	mut compteur := 0
	for width in 0 .. taille_masque {
		for height in 0 .. taille_masque {
			if ((milieu - width) * (milieu - width) + (milieu - height) * (milieu - height)) > rayon * rayon {
				masque[width][height] = -1
				compteur = compteur + 1
			}
		}
	}
	// // On normalise
	// mut masque_normalised := [][]f32{len: taille_masque, init: []f32{len: taille_masque}}
	// nb_de_un := taille_masque * taille_masque - compteur
	// for width in 0 .. taille_masque {
	// 	for height in 0 .. taille_masque {
	// 		if masque[width][height] == -1 {
	// 			masque_normalised[width][height] = f32(masque[width][height]) / compteur
	// 		} else {
	// 			masque_normalised[width][height] = f32(masque[width][height]) / nb_de_un
	// 		}
	// 	}
	// }
	// return masque_normalised
	return masque.map(it.map(f32(it))), compteur
}

fn appliquer_masque(mut image_grise [][]int, masque_normalised [][]f32, rayon int, width int, height int) [][]f64 {
	mut image_convolution := [][]f64{len: width - 2 * rayon, init: []f64{len: height - 2 * rayon, init: 0}}
	taille_masque := rayon * 2 + 1
	mut somme_pixel := 0.0
	for w in rayon .. width - rayon {
		for h in rayon .. height - rayon {
			for i in 0 .. taille_masque {
				for j in 0 .. taille_masque {
					somme_pixel = somme_pixel + image_grise[w - rayon + i][h - rayon +
						j] * masque_normalised[i][j]
				}
			}
			image_convolution[w - rayon][h - rayon] = somme_pixel
			somme_pixel = 0
		}
	}
	return image_convolution
}

pub fn track_ball(image []u8, width int, height int, nb_channels int, rayon int) Coord {
	// Si on est en RGB+alpha
	if nb_channels == 4 {
		// On va couper le vecteur image en 3 vecteurs R, G, B
		mut img := ImageRGB{
			red:   [][]int{len: width, init: []int{len: height}}
			green: [][]int{len: width, init: []int{len: height}}
			blue:  [][]int{len: width, init: []int{len: height}}
		}

		// Decompresser le vecteur image en 3 vecteur RGB
		for i in 1 .. 5 { // on va pas prendre en compte le channel alpha mais vu que les pixels sont [p1r, p1g, p1b, p1a, p2r ...] il faut qu'on prenne en compte le pixel alpha
			for w in 0 .. width {
				for h in 0 .. height {
					img.red[w][h] = image[(w + h) * i]
					img.green[w][h] = image[(w + h) * i + 1]
					img.blue[w][h] = image[(w + h) * i + 2]
				}
			}
		}

		// Convertir en niveau de gris
		mut image_grise := [][]int{len: width, init: []int{len: height}}
		for w in 0 .. width {
			for h in 0 .. height {
				image_grise[w][h] = (img.red[w][h] + img.green[w][h] + img.blue[w][h]) / 3
			}
		}

		// On va appliquer un masque sur l'image en niveau de gris
		// TODO : prendre en compte les bords + rajouter les conditions si rayon est plus grand que width
		masque_normalised, nb_de_moins_de_un := generer_masque(rayon)
		mut image_convolue := [][]f64{len: width, init: []f64{len: height}}
		image_convolue = appliquer_masque(mut image_grise, masque_normalised, rayon, width,
			height)

		// Normaliser l'image
		min := f64(255 * nb_de_moins_de_un) * (-1.0)
		max := f64(255 * ((rayon * 2 + 1) * (rayon * 2 + 1) - nb_de_moins_de_un)) //(rayon * 2 + 1) = taille du masque ; mzx cest le nb de un * 255 et le min c'est le nb de -1 *-1 * 255
		for mut ligne in image_convolue { // le mut devant le pixel permet de lui réassigner une valeur
			for mut pixel in ligne {
				pixel = (*pixel - min) / (max - min) * 255
			}
		}
		stbi.stbi_write_jpg('image_convolue.jpg', width, height, 1, arrays.flatten(image_convolue).map(u8(it)).data,
			1) or { panic(err) }
		println(image_convolue[0])
	}
	return Coord{100.0, 100.0}
}
