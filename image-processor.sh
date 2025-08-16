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

        output_800="$gallery/$base_name-800.$extension"
        output_1600="$gallery/$base_name-1600.$extension"

        # Skip entirely if both resized versions exist
        if [ -f "$output_800" ] && [ -f "$output_1600" ]; then
          echo " → Skipping $filename (all sizes already exist)"
          continue
        fi

        if [[ "$filename" == *-800.* || "$filename" == *-1600.* ]]; then
            echo "Skipping processed file: $filename"
            continue
          fi

        for size in 800 1600; do
          output="$gallery/$base_name-$size.$extension"

          if [ -f "$output" ]; then
            echo "   → Skipping $output (already exists)"
            continue
          fi

          # Scale text size proportional to target size (base = 48 for 1600px)
          if [ "$size" -eq 1600 ]; then
            pointsize=48
          elif [ "$size" -eq 800 ]; then
            pointsize=24
          else
            pointsize=24
          fi

          echo "   → Creating $output"

          # Smaller Sizes
          magick convert "$image" \
            -resize ${size}x \
            -quality 65 \
            -gravity south \
            -pointsize $pointsize \
            -stroke black -strokewidth 2 -annotate +0+10 'Photo by Matthew Allen' \
            -stroke none -fill white -annotate +0+10 'Photo by Matthew Allen' \
            +profile '*' \
            "$output"

        done

        # Calculate pointsize by taking 0.03% of the image height
        image_height=$(magick identify -format "%h" "$image")
        original_pointsize=$(awk -v h="$image_height" 'BEGIN {
            ps = int(h * 0.05);
            if (ps < 12) ps = 12;  # set a minimum size
            print ps
        }')


        #Original Size but with a watermark and smaller quality
        magick convert "$image" \
            -quality 75 \
            -gravity south \
            -pointsize "$original_pointsize" \
            -stroke black -strokewidth 2 -annotate +0+10 'Photo by Matthew Allen' \
            -stroke none -fill white -annotate +0+10 'Photo by Matthew Allen' \
            +profile '*' \
            "$image"


      fi
    done
  fi
done
