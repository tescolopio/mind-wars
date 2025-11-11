# Android Resources Directory

## Launcher Icons (ic_launcher.png)

### ⚠️ Important: Icon Requirements

The `ic_launcher.png` files in the `mipmap-*` directories are the app launcher icons displayed on Android devices.

**Key Requirements for AAPT2 Compatibility:**
- Must be valid, non-corrupted PNG files
- Should not contain problematic metadata (Adobe XMP, color profiles, etc.)
- Should be optimized for Android with tools like `optipng`
- Must follow Android's standard density sizes:
  - `mipmap-mdpi`: 48×48 px
  - `mipmap-hdpi`: 72×72 px  
  - `mipmap-xhdpi`: 96×96 px
  - `mipmap-xxhdpi`: 144×144 px
  - `mipmap-xxxhdpi`: 192×192 px

### 🛠️ Architectural Decision: Icon Regeneration (Nov 2025)

**Problem:** 
During alpha build troubleshooting, all launcher icon PNG files were found to have internal corruption:
- Error: "IDAT: invalid bit length repeat"
- Caused AAPT2 (Android Asset Packaging Tool) compilation failures
- Build failed with: `ERROR: file failed to compile` for all mipmap densities

**Solution:**
All launcher icons were regenerated using ImageMagick to create clean, valid PNG files:
```bash
# Icons generated with proper Android specifications
convert -size WxH gradient:'#4A90E2-#7B68EE' \
    -gravity center -font DejaVu-Sans-Bold \
    -pointsize SIZE -fill white -stroke black \
    -annotate +0+0 "MW" -strip PNG32:output.png
    
# Optimized for Android
optipng -o2 output.png
```

**Current Icons:**
- Simple gradient background (blue to purple)
- "MW" text for "Mind Wars"
- Properly sized for each density bucket
- Stripped of all metadata
- Optimized with optipng

**Future Enhancements:**
Consider replacing these placeholder icons with professionally designed launcher icons using tools like:
- Android Studio's Image Asset Studio
- Icon Kitchen (https://icon.kitchen/)
- Custom designs from a graphic designer

### 📝 Updating Launcher Icons

If you need to replace the launcher icons in the future:

1. **Use Android Studio's Image Asset Studio** (Recommended):
   - Right-click `res` folder → New → Image Asset
   - Select "Launcher Icons (Adaptive and Legacy)"
   - Provide your source image (512×512 px minimum)
   - Studio will generate all density variants automatically

2. **Manual Replacement**:
   ```bash
   # Ensure icons are valid PNGs
   identify your-icon.png
   
   # Strip metadata to avoid AAPT2 issues
   convert your-icon.png -strip PNG32:clean-icon.png
   
   # Optimize for size
   optipng -o2 clean-icon.png
   
   # Resize for each density and place in appropriate mipmap folder
   ```

3. **Verify icons before committing**:
   ```bash
   # Check all icons are valid
   for file in mipmap-*/ic_launcher.png; do
       identify "$file" || echo "ERROR: $file is corrupted"
   done
   
   # Test build
   flutter build apk --flavor alpha --release
   ```

### 🔍 Related Files

- AndroidManifest.xml: References `@mipmap/ic_launcher` for the app icon
- build.gradle: Android build configuration with flavor definitions
- .github/workflows/build-alpha.yml: CI/CD workflow that triggered the icon issue

### 📚 References

- [Android Icon Design Guidelines](https://developer.android.com/guide/practices/ui_guidelines/icon_design_launcher)
- [Material Design Icon Guidelines](https://m3.material.io/styles/icons/overview)
- [AAPT2 Documentation](https://developer.android.com/studio/command-line/aapt2)
