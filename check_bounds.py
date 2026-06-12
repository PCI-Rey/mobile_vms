from PIL import Image
logo = Image.open('assets/images/VMS.png').convert("RGBA")
print("Original size:", logo.size)
print("getbbox():", logo.getbbox())

width, height = logo.size
left = width
top = height
right = 0
bottom = 0

pixels = logo.load()
for y in range(height):
    for x in range(width):
        if pixels[x, y][3] > 10:
            if x < left: left = x
            if x > right: right = x
            if y < top: top = y
            if y > bottom: bottom = y
print("Manual crop bounds:", (left, top, right, bottom))
