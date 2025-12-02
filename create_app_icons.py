#!/usr/bin/env python3
"""
Script to generate CollegePro app icons in different sizes for Android
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon(size, output_path):
    """Create a CollegePro app icon with the specified size"""
    
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Background gradient effect (simplified as solid color for better visibility)
    background_color = (102, 126, 234)  # Modern blue
    accent_color = (245, 87, 108)       # Coral pink
    
    # Draw rounded rectangle background
    margin = size // 20
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=size // 8,
        fill=background_color
    )
    
    # Draw graduation cap
    cap_size = size // 3
    cap_x = size // 2 - cap_size // 2
    cap_y = size // 4
    
    # Cap base (mortarboard)
    draw.rectangle(
        [cap_x, cap_y, cap_x + cap_size, cap_y + size // 12],
        fill=(45, 55, 72)
    )
    
    # Cap top
    cap_top_margin = size // 20
    draw.rectangle(
        [cap_x + cap_top_margin, cap_y - size // 20, 
         cap_x + cap_size - cap_top_margin, cap_y + size // 20],
        fill=(74, 85, 104)
    )
    
    # Tassel
    tassel_x = cap_x + cap_size - size // 30
    tassel_y = cap_y
    draw.circle([tassel_x, tassel_y], size // 40, fill=accent_color)
    
    # Draw book
    book_width = size // 2
    book_height = size // 3
    book_x = size // 2 - book_width // 2
    book_y = size // 2
    
    # Book cover
    draw.rounded_rectangle(
        [book_x, book_y, book_x + book_width, book_y + book_height],
        radius=size // 40,
        fill=(255, 255, 255)
    )
    
    # Book spine
    spine_width = size // 25
    draw.rounded_rectangle(
        [book_x, book_y, book_x + spine_width, book_y + book_height],
        radius=size // 80,
        fill=(74, 85, 104)
    )
    
    # Text lines on book
    line_height = size // 80
    line_spacing = size // 20
    line_start_x = book_x + size // 15
    line_start_y = book_y + size // 15
    
    for i in range(4):
        line_width = book_width - size // 10 - (i * size // 40)
        draw.rectangle(
            [line_start_x, line_start_y + i * line_spacing,
             line_start_x + line_width, line_start_y + i * line_spacing + line_height],
            fill=background_color
        )
    
    # Add "CP" text
    try:
        # Try to use a system font
        font_size = size // 8
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    text = "CP"
    text_bbox = draw.textbbox((0, 0), text, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]
    
    text_x = size - text_width - size // 10
    text_y = size - text_height - size // 10
    
    draw.text((text_x, text_y), text, fill=accent_color, font=font)
    
    # Save the image
    img.save(output_path, 'PNG')
    print(f"Created icon: {output_path} ({size}x{size})")

def main():
    """Generate all required icon sizes for Android"""
    
    # Android icon sizes
    icon_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    base_path = "android/app/src/main/res"
    
    for folder, size in icon_sizes.items():
        folder_path = os.path.join(base_path, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        icon_path = os.path.join(folder_path, "ic_launcher.png")
        create_app_icon(size, icon_path)
    
    print("\n✅ All CollegePro app icons generated successfully!")
    print("The app icon should now be clearly visible on your device.")

if __name__ == "__main__":
    main()
