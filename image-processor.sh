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

        # Skip files with EXIF comment "processed"
        processed=$(magick identify -format "%[comment]" "$image" 2>/dev/null | tr -d '\n\r')
        if [ "$processed" = "processed" ]; then
            echo " → Skipping already processed: $filename"
            continue
        fi

        extension="${filename##*.}"
        base_name="${filename%.*}"

        # Watermark + recompress original if no thumbnail yet
        image_width=$(magick identify -format "%w" "$image" 2>/dev/null)
        image_height=$(magick identify -format "%h" "$image" 2>/dev/null)

        if [ -z "$image_width" ] || [ -z "$image_height" ]; then
            echo " → Skipping $filename, cannot read dimensions"
            continue
        fi

        min_dim=$(( image_width < image_height ? image_width : image_height ))

        original_pointsize=$(awk -v d="$min_dim" 'BEGIN {
            ps = int(d * 0.03);
            if (ps < 12) ps = 12;
            print ps
        }')

        echo " → Watermarking: $filename"

        quality=70
        width=$image_width
        tmpfile="${image%.${extension}}-tmp.jpg"

        while true; do
          magick "$image" \
              -resize "${width}x" \
              -quality "$quality" \
              -gravity south \
              -depth 8 \
              -strip \
              -format jpg \
              -pointsize "$original_pointsize" \
              -stroke black -strokewidth 10 -annotate +0+10 'Photo by Matthew Allen' \
              -stroke none -fill white -annotate +0+10 'Photo by Matthew Allen' \
              +profile '*' \
              "$tmpfile"

          filesize=$(get_file_size "$tmpfile")
          max_filesize=750000  # 0.75 MB

          if [ "$filesize" -lt $max_filesize ] || [ "$quality" -le 50 ] || [ "$width" -le 2000 ]; then
            # Mark as processed
            magick "$tmpfile" -set comment "processed" "$image"
            rm -f "$tmpfile"
            break
          fi

          if [ "$filesize" -ge $max_filesize ] && [ "$width" -gt 2000 ]; then
            width=$((width - 400))
          fi
        done
      fi
    done
  fi
done