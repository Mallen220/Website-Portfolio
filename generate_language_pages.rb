# generate_language_pages.rb

languages = [
  "Python", "JavaScript", "Java", "HTML", "CSS",
  "Ruby", "PHP", "Swift", "Kotlin", "Go", "Rust",
  "sample_language", "guides", "jekyll"
]

languages.each do |lang|
  slug = lang.downcase.gsub(" ", "-").gsub("#", "sharp").gsub("++", "pp")

  File.open("languages/#{slug}.md", "w") do |file|
    file.puts <<~MARKDOWN
      ---
      layout: page
      title: #{lang}
      permalink: /projects/languages/#{slug}/
      ---

      <h5> Projects by Language : {{ page.title }} </h5>

      <div class="card">
      {% for project in site.languages.#{lang} %}
        <li class="language-project"><span>{{ project.date | date_to_string }}</span> &nbsp; <a href="{{ project.url }}">{{ project.title }}</a></li>
      {% endfor %}
      </div>
    MARKDOWN
  end

#   puts "Generated: #{slug}.md"
end
