from PIL import Image
try:
    logo = Image.open('assets/images/icon_ios.png').convert("RGB")
    print("icon_ios size:", logo.size)
    bg_color = (25, 118, 210)
    
    width, height = logo.size
    left = width
    top = height
    right = 0
    bottom = 0
    
    pixels = logo.load()
    for y in range(height):
        for x in range(width):
            # If color is significantly different from bg_color
            r, g, b = pixels[x, y]
            if abs(r - bg_color[0]) > 10 or abs(g - bg_color[1]) > 10 or abs(b - bg_color[2]) > 10:
                if x < left: left = x
                if x > right: right = x
                if y < top: top = y
                if y > bottom: bottom = y
    print("Logo bounds inside icon_ios:", (left, top, right, bottom))
    print("Logo width inside icon_ios:", right - left)
except Exception as e:
    print(e)
