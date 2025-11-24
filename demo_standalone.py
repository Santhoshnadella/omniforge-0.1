"""
Omniforge Standalone Demo
Demonstrates FSR + Waifu2x upscaling without game injection
"""

import numpy as np
from PIL import Image
import subprocess
import os
import sys

def create_test_image():
    """Create a 720p test image with clear details"""
    width, height = 1280, 720
    img = Image.new('RGB', (width, height))
    pixels = img.load()
    
    # Create a gradient background
    for y in range(height):
        for x in range(width):
            r = int(255 * x / width)
            g = int(255 * y / height)
            b = int(128 + 127 * np.sin(x * 0.01) * np.cos(y * 0.01))
            pixels[x, y] = (r, g, b)
    
    # Add some text and shapes for detail
    from PIL import ImageDraw, ImageFont
    draw = ImageDraw.Draw(img)
    
    # Draw some geometric shapes
    draw.rectangle([100, 100, 300, 300], outline=(255, 255, 255), width=3)
    draw.ellipse([400, 150, 600, 350], outline=(255, 0, 0), width=3)
    draw.line([700, 100, 900, 400], fill=(0, 255, 0), width=5)
    
    # Add text
    try:
        font = ImageFont.truetype("arial.ttf", 60)
    except:
        font = ImageFont.load_default()
    
    draw.text((50, 500), "Omniforge Demo - 720p Input", fill=(255, 255, 255), font=font)
    draw.text((50, 600), "Testing FSR + Waifu2x Upscaling", fill=(255, 255, 0), font=font)
    
    return img

def run_fsr_upscale(input_path, output_path):
    """
    Call the FSR upscaling function from our DLL
    For this demo, we'll simulate it with bicubic + sharpening
    """
    print("🔧 Running FSR upscaling (1280x720 → 2560x1440)...")
    
    img = Image.open(input_path)
    # FSR simulation: high-quality bicubic + edge enhancement
    upscaled = img.resize((2560, 1440), Image.Resampling.BICUBIC)
    
    # Simple sharpening filter (FSR does edge-adaptive sharpening)
    from PIL import ImageFilter
    sharpened = upscaled.filter(ImageFilter.SHARPEN)
    sharpened.save(output_path)
    print(f"✅ FSR upscale complete: {output_path}")
    return output_path

def run_waifu2x_upscale(input_path, output_path):
    """
    Call Waifu2x NCNN for AI upscaling
    """
    print("🤖 Running Waifu2x AI upscaling (1280x720 → 2560x1440)...")
    
    # Check if waifu2x-ncnn-vulkan executable exists
    waifu2x_path = r"c:\omniforge\external\waifu2x-ncnn-vulkan\waifu2x-ncnn-vulkan.exe"
    
    if not os.path.exists(waifu2x_path):
        print(f"⚠️ Waifu2x executable not found at {waifu2x_path}")
        print("   Using fallback: Lanczos upscaling")
        img = Image.open(input_path)
        upscaled = img.resize((2560, 1440), Image.Resampling.LANCZOS)
        upscaled.save(output_path)
    else:
        # Run waifu2x-ncnn-vulkan
        model_path = r"c:\omniforge\models\models-cunet"
        cmd = [
            waifu2x_path,
            "-i", input_path,
            "-o", output_path,
            "-n", "0",  # Noise reduction level
            "-s", "2",  # Scale factor
            "-m", model_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
        except subprocess.CalledProcessError as e:
            print(f"⚠️ Waifu2x failed: {e}")
            print("   Using fallback: Lanczos upscaling")
            img = Image.open(input_path)
            upscaled = img.resize((2560, 1440), Image.Resampling.LANCZOS)
            upscaled.save(output_path)
    
    print(f"✅ Waifu2x upscale complete: {output_path}")
    return output_path

def run_hybrid_upscale(input_path, output_path):
    """
    Run FSR first, then Waifu2x for refinement
    """
    print("🔀 Running HYBRID upscaling (FSR → Waifu2x)...")
    
    # Step 1: FSR to intermediate resolution
    temp_path = "temp_fsr.png"
    img = Image.open(input_path)
    fsr_intermediate = img.resize((1920, 1080), Image.Resampling.BICUBIC)
    from PIL import ImageFilter
    fsr_intermediate = fsr_intermediate.filter(ImageFilter.SHARPEN)
    fsr_intermediate.save(temp_path)
    
    # Step 2: Waifu2x from 1080p to 1440p
    run_waifu2x_upscale(temp_path, output_path)
    
    # Cleanup
    if os.path.exists(temp_path):
        os.remove(temp_path)
    
    print(f"✅ Hybrid upscale complete: {output_path}")
    return output_path

def create_comparison_image(original, fsr, waifu2x, hybrid, output):
    """Create a side-by-side comparison"""
    print("📊 Creating comparison image...")
    
    # Load all images
    img_orig = Image.open(original).resize((640, 360))  # Thumbnail
    img_fsr = Image.open(fsr).resize((640, 360))
    img_waifu = Image.open(waifu2x).resize((640, 360))
    img_hybrid = Image.open(hybrid).resize((640, 360))
    
    # Create comparison grid (2x2)
    comparison = Image.new('RGB', (1280, 720))
    comparison.paste(img_orig, (0, 0))
    comparison.paste(img_fsr, (640, 0))
    comparison.paste(img_waifu, (0, 360))
    comparison.paste(img_hybrid, (640, 360))
    
    # Add labels
    from PIL import ImageDraw, ImageFont
    draw = ImageDraw.Draw(comparison)
    try:
        font = ImageFont.truetype("arial.ttf", 30)
    except:
        font = ImageFont.load_default()
    
    draw.text((10, 10), "Original (720p)", fill=(255, 255, 0), font=font)
    draw.text((650, 10), "FSR Upscaled (1440p)", fill=(255, 255, 0), font=font)
    draw.text((10, 370), "Waifu2x AI (1440p)", fill=(255, 255, 0), font=font)
    draw.text((650, 370), "Hybrid (1440p)", fill=(255, 255, 0), font=font)
    
    comparison.save(output)
    print(f"✅ Comparison saved: {output}")
    return output

def main():
    print("=" * 60)
    print("🎮 OMNIFORGE STANDALONE DEMO")
    print("=" * 60)
    print()
    
    # Create output directory
    os.makedirs("demo_output", exist_ok=True)
    
    # Step 1: Create test image
    print("📸 Creating test image (720p)...")
    test_img = create_test_image()
    input_path = "demo_output/input_720p.png"
    test_img.save(input_path)
    print(f"✅ Test image saved: {input_path}")
    print()
    
    # Step 2: Run FSR upscaling
    fsr_output = "demo_output/fsr_1440p.png"
    run_fsr_upscale(input_path, fsr_output)
    print()
    
    # Step 3: Run Waifu2x upscaling
    waifu2x_output = "demo_output/waifu2x_1440p.png"
    run_waifu2x_upscale(input_path, waifu2x_output)
    print()
    
    # Step 4: Run Hybrid upscaling
    hybrid_output = "demo_output/hybrid_1440p.png"
    run_hybrid_upscale(input_path, hybrid_output)
    print()
    
    # Step 5: Create comparison
    comparison_output = "demo_output/comparison.png"
    create_comparison_image(input_path, fsr_output, waifu2x_output, hybrid_output, comparison_output)
    print()
    
    print("=" * 60)
    print("✅ DEMO COMPLETE!")
    print("=" * 60)
    print()
    print("📁 Output files:")
    print(f"   - Input (720p):      {input_path}")
    print(f"   - FSR (1440p):       {fsr_output}")
    print(f"   - Waifu2x (1440p):   {waifu2x_output}")
    print(f"   - Hybrid (1440p):    {hybrid_output}")
    print(f"   - Comparison:        {comparison_output}")
    print()
    print("🖼️  Opening comparison image...")
    
    # Open the comparison image
    try:
        if sys.platform == 'win32':
            os.startfile(comparison_output)
        else:
            subprocess.run(['xdg-open', comparison_output])
    except:
        print(f"   Please open manually: {os.path.abspath(comparison_output)}")

if __name__ == "__main__":
    main()
