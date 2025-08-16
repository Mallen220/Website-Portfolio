#!/usr/bin/env ruby
# scripts/generate_galleries.rb
# Generates:
#   - _data/galleries/<folder>.yml for each subfolder in assets/img/gallery
#   - _data/galleries/overview.yml with one entry per folder
#
# Behavior:
#  - Only considers originals (ignores files ending with -thumbnail.*).
#  - Supports extensions: jpg|jpeg|png|gif|webp (case-insensitive).
#  - Writes "filename" without extension; "original"/"thumbnail" use the same extension as the source.
#  - Ensures overview preview images exist; if missing, copies from the first picture’s resized thumbnail.
#  - Removes stale *_data/galleries/*.yml (except overview.yml) that no longer correspond to a folder.

require "yaml"
require "fileutils"

ROOT       = File.expand_path(__dir__ + "/..") # repo root (scripts/..)
GALLERY    = File.join(ROOT, "Website-Portfolio/assets/img/gallery")
DATA_DIR   = File.join(ROOT, "Website-Portfolio/_data/galleries")
VALID_EXTS = %w[jpg jpeg png gif webp]

def valid_image?(filename)
  ext = File.extname(filename).downcase.delete_prefix(".")
  return false unless VALID_EXTS.include?(ext)
  base = File.basename(filename, ".*")
  return false if base.end_with?("-thumbnail")
  true
end

def list_folders(path)
  return [] unless Dir.exist?(path)
  Dir.children(path)
     .map { |d| File.join(path, d) }
     .select { |p| File.directory?(p) }
     .sort_by { |p| File.basename(p).downcase }
end

def list_originals(dir)
  return [] unless Dir.exist?(dir)
  Dir.children(dir)
     .select { |f| valid_image?(f) }
     .sort_by { |f| f.downcase }
end

def filename_yaml_value(base)
  # Convert purely numeric filenames to integers (but preserve leading-zero names like "001")
  if base =~ /\A(?:0|[1-9][0-9]*)\z/
    base.to_i
  else
    base
  end
end

def write_yaml_file(path, data)
  yaml = YAML.dump(data)
  # Remove leading document marker '---' if present
  yaml.sub!(/\A---\s*\n/, "")
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, yaml)
  path
end

def write_gallery_yaml(folder_name, pictures)
  yml_path = File.join(DATA_DIR, "#{folder_name}.yml")
  data = {
    "picture_path" => folder_name,
    "pictures" => pictures
  }

  yaml = YAML.dump(data)
  yaml.sub!(/\A---\s*\n/, "")

  # Fix indentation for the pictures array
  fixed_yaml = []
  in_pictures = false
  yaml.each_line do |line|
    if line.start_with?("pictures:")
      in_pictures = true
      fixed_yaml << line
    elsif in_pictures && line =~ /^- /
      fixed_yaml << "  #{line}" # indent the `- filename:`
    elsif in_pictures && line =~ /^\s+\w+:/
      fixed_yaml << "  #{line}" # indent nested keys (`original`, `thumbnail`)
    else
      fixed_yaml << line
      in_pictures = false if line.strip.empty?
    end
  end

  FileUtils.mkdir_p(File.dirname(yml_path))
  File.write(yml_path, fixed_yaml.join)
  yml_path
end


def ensure_preview_images(folder_path, folder_name, pictures)
  preview_file = File.join(folder_path, "#{folder_name}-thumbnail")
  chosen_ext = VALID_EXTS.find { |ext| File.exist?("#{preview_file}.#{ext}") }
  return chosen_ext if chosen_ext

  return nil if pictures.empty?

  first = pictures.first
  ext   = first[:ext]
  src   = File.join(folder_path, "#{first[:filename]}-thumbnail.#{ext}")
  dst   = "#{preview_file}.#{ext}"

  FileUtils.cp(src, dst) if File.exist?(src) && !File.exist?(dst)
  File.exist?(dst) ? ext : nil
end

def build_pictures(folder_path, originals)
  originals.map do |fname|
    base = File.basename(fname, ".*")
    ext  = File.extname(fname).delete_prefix(".")
    {
      filename: "#{base}.#{ext}",
      original: "#{base}.#{ext}",
      thumbnail: "#{base}-thumbnail.#{ext}",
      ext: ext # internal only
    }
  end
end

def write_overview_yaml(entries)
  path = File.join(DATA_DIR, "overview.yml")
  write_yaml_file(path, entries)
end

def generate
  abort("Gallery folder not found: #{GALLERY}") unless Dir.exist?(GALLERY)
  FileUtils.mkdir_p(DATA_DIR)

  folders = list_folders(GALLERY)
  generated_files = []
  overview_entries = []

  folders.each do |folder_path|
    folder_name = File.basename(folder_path)
    originals = list_originals(folder_path)

    pictures = build_pictures(folder_path, originals)
    yaml_pictures = pictures.map do |p|
      {
        "filename"  => filename_yaml_value(p[:filename]),
        "original"  => p[:original],
        "thumbnail" => p[:thumbnail]
      }
    end

    yml_path = write_gallery_yaml(folder_name, yaml_pictures)
    generated_files << File.basename(yml_path)

    ext = ensure_preview_images(folder_path, folder_name, pictures) || "jpg"
    overview_entries << {
      "title" => folder_name,
      "directory" => folder_name,
      "preview" => {
        "filename" => "#{folder_name}-thumbnail.#{ext}",
        "thumbnail" => "#{folder_name}-thumbnail.#{ext}"
      }
    }
  end

  overview_entries.sort_by! { |e| e["title"].downcase }
  write_overview_yaml(overview_entries)
  generated_files << "overview.yml"

  # Delete stale YAMLs (only .yml files) that weren't generated this run
  Dir.children(DATA_DIR)
     .select { |f| f.end_with?(".yml") }
     .reject { |f| generated_files.include?(f) }
     .each do |stale|
       stale_path = File.join(DATA_DIR, stale)
       FileUtils.rm_f(stale_path)
     end

  puts "Generated YAML for #{folders.size} galleries."
end

generate
