#!/bin/bash
# image-processor.sh
# Run this before committing images
# Requires ImageMagick (brew install imagemagick)

GALLERY_DIR="assets/img/gallery"

for gallery in "$GALLERY_DIR"/*; do
  if [ -d "$gallery" ]; then
    gallery_name=$(basename "$gallery")
    echo "Processing gallery: $gallery_name"

    for image in "$gallery"/*; do
      if [ -f "$image" ]; then
        filename=$(basename "$image")
        extension="${filename##*.}"
        base_name="${filename%.*}"

        output_thumb="$gallery/$base_name-thumbnail.$extension"

        # Skip already processed thumbnails
        if [[ "$filename" == *-thumbnail.* ]]; then
            echo "Skipping processed file: $filename"
            continue
        fi

        # Watermark original image if thumbnail doesn't exist yet
        if [ ! -f "$output_thumb" ]; then
            image_height=$(magick identify -format "%h" "$image")
            original_pointsize=$(awk -v h="$image_height" 'BEGIN {
                ps = int(h * 0.05);
                if (ps < 12) ps = 12;
                print ps
            }')

            echo " → Watermarking original: $filename"

            magick "$image" \
                -quality 75 \
                -gravity south \
                -pointsize "$original_pointsize" \
                -stroke black -strokewidth 2 -annotate +0+10 'Photo by Matthew Allen' \
                -stroke none -fill white -annotate +0+10 'Photo by Matthew Allen' \
                +profile '*' \
                "$image"
        fi

        # Create 800px thumbnail from already-watermarked original
        if [ ! -f "$output_thumb" ]; then
            echo " → Creating thumbnail: $output_thumb"

            magick "$image" \
                -resize 800x \
                -quality 65 \
                +profile '*' \
                "$output_thumb"
        fi
      fi
    done
  fi
done
