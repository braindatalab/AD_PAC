from PIL import Image, ImageChops
path = '' # specify your path here 
# Utility to crop transparent border
def crop_alpha(image):
    bg = Image.new("RGBA", image.size, (0, 0, 0, 0))
    diff = ImageChops.difference(image, bg)
    bbox = diff.getbbox()
    return image.crop(bbox) if bbox else image

for name in ['_L+R_Phase']: 

    img1_path = f'{path}/{name}_1.png'
    img2_path = f'{path}/{name}_2.png'
    img4_path = f'{path}/{name}_3.png'
    img3_path = f'{path}/{name}_4.png'
    img5_path = f'{path}/{name}_5.png'
    colorbar_path = f'{path}/{name}_colorbar.png'
    output_path = f'{path}/{name}.png'


    # Load and crop images
    img1 = crop_alpha(Image.open(img1_path).convert('RGBA'))
    img2 = crop_alpha(Image.open(img2_path).convert('RGBA'))
    img3 = crop_alpha(Image.open(img3_path).convert('RGBA'))
    img4 = crop_alpha(Image.open(img4_path).convert('RGBA'))
    img5 = crop_alpha(Image.open(img5_path).convert('RGBA'))
    colorbar = crop_alpha(Image.open(colorbar_path).convert('RGBA'))

    # scale the colorbar by 2x
    colorbar = colorbar.resize((colorbar.width * 2, colorbar.height * 2), Image.LANCZOS)

    # Set spacing
    spacing_x = 100  # spacing between diagonals
    spacing_y = -100  # vertical spacing

    # Get sizes
    w1, h1 = img1.size
    print(w1, h1)
    w2, h2 = img2.size
    w3, h3 = img3.size
    w4, h4 = img4.size
    wc, hc = img5.size
    wb, hb = colorbar.size

    # Estimate canvas size
    canvas_width = w1 + w2 + spacing_x + 200
    canvas_height = h1 + hc + h3 + 2 * spacing_y + hb + 300

    # Create canvas
    canvas = Image.new('RGBA', (canvas_width, canvas_height), (0, 0, 0, 0))

    # Center X
    center_x = canvas_width // 2



    # Compute positions
    # Top row
    x1 = center_x - spacing_x // 2 - w1
    x2 = center_x + spacing_x // 2
    y_top = 0

    # Middle image
    x5 = center_x - wc // 2 
    y5 = h1 + spacing_y

    # Bottom row
    x4 = x1
    x3 = x2
    y_bottom = y5 + hc + spacing_y


    # Colorbar
    xbar = center_x - wb // 2
    ybar = y_bottom + max(h3, h4) + 100



    # Paste all
    canvas.paste(img1, (x1, y_top), img1)
    canvas.paste(img2, (x2, y_top), img2)
    canvas.paste(img5, (x5, y5), img5)
    canvas.paste(img4, (x4, y_bottom), img4)
    canvas.paste(img3, (x3, y_bottom), img3)
    canvas.paste(colorbar, (xbar, ybar), colorbar)

    # Save output
    canvas.save(output_path, dpi=(300, 300))
    print(f"Saved as {output_path}")
