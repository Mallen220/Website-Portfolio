require 'yaml'
require 'date'

LANGUAGE_FILE = '_config_languages.yml'
PROJECT_DIR = '_projects'

languages = {}

Dir.glob("#{PROJECT_DIR}/*.md").each do |filename|
  content = File.read(filename)

  # Extract YAML front matter
  if content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
    front_matter = YAML.safe_load($1, permitted_classes: [Date, Time])

    title = front_matter['title']
    url = front_matter['permalink'] || "/projects/#{File.basename(filename, '.md')}/"
    date = front_matter['date']
    langs = front_matter['languages']

    next if title.nil? || langs.nil?

    langs = [langs] unless langs.is_a?(Array)

    langs.each do |lang|
      languages[lang.downcase] ||= []
      languages[lang.downcase] << {
        'title' => title,
        'url' => url,
        'date' => date ? Date.parse(date.to_s) : nil
      }
    end
  end
end

# Sort each language's projects by date descending
languages.each do |lang, projects|
  languages[lang] = projects.sort_by { |p| p['date'] || Date.today }.reverse
end

# ✅ REMOVE the top-level 'languages' key here!
File.write(LANGUAGE_FILE, languages.to_yaml.sub(/\A---\s*\n/, ''))

puts "[language generator] Wrote language data to #{LANGUAGE_FILE}"
