module Jekyll
  class LanguagePage < Page
    def initialize(site, base, dir, language_name, projects)
      @site = site
      @base = base
      @dir  = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'language_template.html')

      self.data['layout'] = 'language_template'
      self.data['title'] = language_name
      self.data['permalink'] = "/projects/languages/#{language_name.downcase.gsub('#', 'sharp').gsub('+', 'p')}/"
      self.data['language_key'] = language_name
      self.data['projects'] = projects
    end
  end

  class LanguagePageGenerator < Generator
    safe true

    def generate(site)
      if site.config['languages']
        site.config['languages'].each do |language_name, projects|
          slug = language_name.downcase.gsub('#', 'sharp').gsub('+', 'p')
          site.pages << LanguagePage.new(site, site.source, File.join('projects', 'languages', slug), language_name, projects)
        end
      end
    end
  end
end
