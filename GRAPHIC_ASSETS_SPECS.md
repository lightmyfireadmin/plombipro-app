# PlombiPro - Graphic Assets Specifications

## Required Assets for Android Deployment

### 1. App Launcher Icons

**Location**: `android/app/src/main/res/`

Create PNG files with transparency:

```
mipmap-mdpi/ic_launcher.png        48x48px    (1x density)
mipmap-hdpi/ic_launcher.png        72x72px    (1.5x density)
mipmap-xhdpi/ic_launcher.png       96x96px    (2x density)
mipmap-xxhdpi/ic_launcher.png      144x144px  (3x density)
mipmap-xxxhdpi/ic_launcher.png     192x192px  (4x density)
```

**Design Specifications**:
- **Main Element**: Blue wrench or pipe wrench icon
- **Accent**: Water drop or plumbing-related element
- **Colors**: 
  - Primary: #0066CC (PlombiPro blue)
  - Secondary: #FF6B35 (PlombiPro orange accent)
  - Background: White or light blue (#F0F8FF)
- **Style**: Modern, flat design with subtle gradient
- **Format**: PNG with transparency
- **Safe Zone**: Keep important elements within 80% center of canvas
- **No Text**: Icon only, no text in launcher icon

**Example Design**:
```
┌─────────────────┐
│                 │
│    🔧 💧       │  ← Wrench + water drop
│   PlombiPro     │  ← In gradient circle
│                 │
└─────────────────┘
```

### 2. Adaptive Icons (Android 8.0+)

**Foreground** (`ic_launcher_foreground.png`):
```
mipmap-mdpi/ic_launcher_foreground.png      108x108px
mipmap-hdpi/ic_launcher_foreground.png      162x162px
mipmap-xhdpi/ic_launcher_foreground.png     216x216px
mipmap-xxhdpi/ic_launcher_foreground.png    324x324px
mipmap-xxxhdpi/ic_launcher_foreground.png   432x432px
```
- Icon element only (wrench + drop)
- Transparent background
- Centered, fits within 66dp safe zone

**Background** (`ic_launcher_background.png`):
```
mipmap-mdpi/ic_launcher_background.png      108x108px
mipmap-hdpi/ic_launcher_background.png      162x162px
mipmap-xhdpi/ic_launcher_background.png     216x216px
mipmap-xxhdpi/ic_launcher_background.png    324x324px
mipmap-xxxhdpi/ic_launcher_background.png   432x432px
```
- Solid color or gradient
- PlombiPro blue (#0066CC) to teal (#00BFA5)
- No transparency

### 3. Splash Screen

**Location**: `android/app/src/main/res/drawable/`

**File**: `splash_logo.png`
- Size: 512x512px
- Format: PNG with transparency
- Design: PlombiPro logo with text
- Use: Centered on white background during app launch

**Create**: `launch_background.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />
    <item>
        <bitmap
            android:gravity="center"
            android:src="@drawable/splash_logo" />
    </item>
</layer-list>
```

### 4. Play Store Assets (For Future)

**App Icon** (512x512px):
- High-resolution version for Play Store
- Same design as launcher icon
- PNG or JPEG, max 1MB

**Feature Graphic** (1024x500px):
- Banner for Play Store listing
- Include: Logo + tagline + app preview
- Text: "Gérez votre activité de plomberie"
- Professional screenshot preview on right side

**Screenshots** (Minimum 2, recommended 8):
- Portrait: 1080x1920px (16:9 ratio)
- Landscape: 1920x1080px (16:9 ratio)
- Show these screens:
  1. Modern dashboard with metrics
  2. Quote creation form
  3. Invoice with e-signature
  4. Client management list
  5. Appointment calendar
  6. Hydraulic calculator
  7. Supplier product catalog
  8. Bank reconciliation

**Promotional Video** (Optional):
- Max 30 seconds
- YouTube upload
- Show key features
- French voiceover or subtitles

## Design Guidelines

### Colors (PlombiPro Brand)
```
Primary Blue:      #0066CC
Secondary Orange:  #FF6B35  
Tertiary Teal:     #00BFA5
Success Green:     #10B981
Warning Yellow:    #F59E0B
Error Red:         #EF4444
Info Blue:         #3B82F6

Gradients:
Primary:  #0066CC → #00BFA5
Success:  #10B981 → #34D399
Warning:  #F59E0B → #FBBF24
```

### Typography
- Font Family: Inter (Google Fonts)
- Weights: 400 (Regular), 600 (SemiBold), 700 (Bold), 800 (ExtraBold)

### Icon Style
- Modern, minimal, flat design
- Rounded corners (8px radius)
- Subtle gradients acceptable
- No drop shadows
- Clean, professional look

## Asset Creation Tools

### Recommended Tools

**Free**:
- Figma (web-based, professional)
- Inkscape (vector graphics)
- GIMP (raster graphics)
- Canva (templates available)

**Paid**:
- Adobe Illustrator (vector)
- Adobe Photoshop (raster)
- Sketch (Mac only)
- Affinity Designer

### Online Generators

**Icon Generators**:
- https://icon.kitchen/ (Android adaptive icons)
- https://romannurik.github.io/AndroidAssetStudio/ (all Android assets)
- https://appicon.co/ (multi-platform icons)

**Design Resources**:
- https://www.flaticon.com/ (plumbing icons)
- https://iconscout.com/ (premium icons)
- https://undraw.co/ (illustrations)

## Quick Start Template

If you want to create assets quickly:

1. **Use Icon Kitchen** (https://icon.kitchen/):
   - Upload a simple wrench + water drop icon
   - Set background color: #0066CC
   - Set foreground color: White
   - Generate all sizes
   - Download ZIP
   - Extract to `android/app/src/main/res/`

2. **For Splash Screen**:
   - Create 512x512px PNG with logo + "PlombiPro" text
   - Use PlombiPro colors
   - Save as `splash_logo.png`
   - Place in `android/app/src/main/res/drawable/`

3. **For Play Store** (later):
   - Take screenshots using Android emulator
   - Use device frames from https://mockuphone.com/
   - Edit in Figma to add marketing text

## Verification Checklist

Before building:
- [ ] All `ic_launcher.png` files created (5 sizes)
- [ ] All `ic_launcher_foreground.png` files created (5 sizes)
- [ ] All `ic_launcher_background.png` files created (5 sizes)
- [ ] `splash_logo.png` created (512x512px)
- [ ] `launch_background.xml` created
- [ ] All files in correct directories
- [ ] All PNGs have transparency where needed
- [ ] Colors match PlombiPro brand (#0066CC)
- [ ] Icons look good at all sizes
- [ ] No text in launcher icons
- [ ] Safe zones respected

## File Structure Example

```
android/app/src/main/res/
├── drawable/
│   ├── launch_background.xml
│   └── splash_logo.png
├── mipmap-mdpi/
│   ├── ic_launcher.png (48x48)
│   ├── ic_launcher_foreground.png (108x108)
│   └── ic_launcher_background.png (108x108)
├── mipmap-hdpi/
│   ├── ic_launcher.png (72x72)
│   ├── ic_launcher_foreground.png (162x162)
│   └── ic_launcher_background.png (162x162)
├── mipmap-xhdpi/
│   ├── ic_launcher.png (96x96)
│   ├── ic_launcher_foreground.png (216x216)
│   └── ic_launcher_background.png (216x216)
├── mipmap-xxhdpi/
│   ├── ic_launcher.png (144x144)
│   ├── ic_launcher_foreground.png (324x324)
│   └── ic_launcher_background.png (324x324)
└── mipmap-xxxhdpi/
    ├── ic_launcher.png (192x192)
    ├── ic_launcher_foreground.png (432x432)
    └── ic_launcher_background.png (432x432)
```

## Need Help?

If you don't have design skills:
1. Hire a designer on Fiverr ($20-50 for all assets)
2. Use Icon Kitchen free generator
3. Ask ChatGPT/DALL-E to generate base icon design
4. Use Canva templates (search "app icon")

Your assets should convey:
✓ Professional plumbing business
✓ Modern technology
✓ Trustworthy and reliable
✓ French market (optional fleur-de-lis accent)
