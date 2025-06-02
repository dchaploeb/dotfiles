from PIL import Image
import sys

png_path = sys.argv[1]
ico_path = sys.argv[2]

img = Image.open(png_path)
img.save(ico_path, format='ICO', sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
