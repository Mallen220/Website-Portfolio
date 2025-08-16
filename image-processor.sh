#!/bin/bash
# image-processor.sh
# Run this before committing images
# Requires ImageMagick (brew install imagemagick)

GALLERY_DIR="assets/img/gallery"

# Cross-platform file size (Linux/macOS)
get_file_size() {
  if stat --version >/dev/null 2>&1; then
    # GNU stat (Linux)
    stat -c%s "$1"
  else
    # BSD stat (macOS)
    stat -f%z "$1"
  fi
}

for gallery in "$GALLERY_DIR"/*; do
  if [ -d "$gallery" ]; then
    gallery_name=$(basename "$gallery")
    echo "Processing gallery: $gallery_name"

    for image in "$gallery"/*; do
      if [ -f "$image" ]; then
        filename=$(basename "$image")
        extension="${filename##*.}"
        base_name="${filename%.*}"

        # Watermark + recompress original if no thumbnail yet
            image_height=$(magick identify -format "%h" "$image")
            image_width=$(magick identify -format "%w" "$image")
            original_pointsize=$(awk -v h="$image_height" 'BEGIN {
                ps = int(h * 0.05);
                if (ps < 12) ps = 12;
                print ps
            }')

            echo " → Watermarking original: $filename"

            # Start parameters
            quality=80
            width=$image_width
            tmpfile="${image%.${extension}}-tmp.jpg"

            # Loop until file < 1MB or limits reached
            while true; do
              magick "$image" \
                  -resize "${width}x" \
                  -quality "$quality" \
                  -gravity south \
                  -depth 8 \
                  -strip \
                  -format jpg \
                  -pointsize "$original_pointsize" \
                  -stroke black -strokewidth 2 -annotate +0+10 'Photo by Matthew Allen' \
                  -stroke none -fill white -annotate +0+10 'Photo by Matthew Allen' \
                  +profile '*' \
                  "$tmpfile"

              filesize=$(get_file_size "$tmpfile")

              max_filesize=750000  # 0.5 MB

              if [ "$filesize" -lt $max_filesize ] || [ "$quality" -le 50 ] || [ "$width" -le 2000 ]; then
                mv "$tmpfile" "$image"
                break
              fi

              # Decrease quality first
              if [ "$quality" -gt 60 ]; then
                quality=$((quality - 5))
              fi

              # Then start decreasing width
              if [ "$filesize" -ge $max_filesize ] && [ "$width" -gt 2000 ]; then
                width=$((width - 300))
              fi
            done
        fi

    done
  fi
done
