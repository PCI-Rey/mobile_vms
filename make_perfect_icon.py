from PIL import Image

try:
    # Load original logo
    logo = Image.open('assets/images/VMS.png').convert("RGBA")
    
    # Manually find bounds of non-transparent pixels
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
    
    # Crop tightly
    if right >= left and bottom >= top:
        logo = logo.crop((left, top, right + 1, bottom + 1))
        
    try:
        resample_filter = Image.Resampling.LANCZOS
    except AttributeError:
        resample_filter = Image.ANTIALIAS
        
    # Scale to 750 (gives about 13-14% margin on all sides)
    target_size = 750
    
    # Calculate aspect ratio preserving size
    ratio = min(target_size / logo.width, target_size / logo.height)
    new_w = int(logo.width * ratio)
    new_h = int(logo.height * ratio)
    
    logo = logo.resize((new_w, new_h), resample_filter)
    
    bg_color = (25, 118, 210, 255) # #1976D2
    
    # 1. iOS icon
    bg_ios = Image.new('RGBA', (1024, 1024), bg_color)
    x = (1024 - logo.width) // 2
    y = (1024 - logo.height) // 2
    bg_ios.paste(logo, (x, y), logo)
    bg_ios.convert("RGB").save('assets/images/icon_ios.png', format="PNG")
    
    # 2. Android foreground
    bg_android = Image.new('RGBA', (1024, 1024), (255, 255, 255, 0))
    bg_android.paste(logo, (x, y), logo)
    bg_android.save('assets/images/icon_android_fg.png', format="PNG")
    
    print(f"Created perfectly sized icons! New logo size inside is {new_w}x{new_h}")
except Exception as e:
    print("Error:", e)

