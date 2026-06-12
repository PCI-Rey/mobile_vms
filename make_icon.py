from PIL import Image

try:
    # Load original logo
    logo = Image.open('assets/images/VMS.png').convert("RGBA")
    
    # Crop transparent borders to get the actual logo bounds
    bbox = logo.getbbox()
    if bbox:
        logo = logo.crop(bbox)
    
    bg_color = (25, 118, 210, 255) # #1976D2
    bg_ios = Image.new('RGBA', (1024, 1024), bg_color)
    
    try:
        resample_filter = Image.Resampling.LANCZOS
    except AttributeError:
        resample_filter = Image.ANTIALIAS
        
    # Increase the size to 900x900 so it's significantly larger
    logo.thumbnail((900, 900), resample_filter)
    
    x = (1024 - logo.width) // 2
    y = (1024 - logo.height) // 2
    
    bg_ios.paste(logo, (x, y), logo)
    bg_ios.convert("RGB").save('assets/images/icon_ios.png', format="PNG")
    print("Created assets/images/icon_ios.png")
    
    bg_android = Image.new('RGBA', (1024, 1024), (255, 255, 255, 0))
    bg_android.paste(logo, (x, y), logo)
    bg_android.save('assets/images/icon_android_fg.png', format="PNG")
    print("Created assets/images/icon_android_fg.png")
    
except Exception as e:
    print("Error:", e)

