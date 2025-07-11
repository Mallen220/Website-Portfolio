---
layout: project
title:  "Adding Multiple languages in Projects"
summary: "Learn how to add languages inprojects"
author: MatthewAllen
date: '2021-02-28 1:35:23 +0530'
languages: ['jekyll','guides', 'sample_language']
thumbnail: /assets/img/projects/code.jpg
keywords: devlopr jekyll, how to use devlopr, devlopr, how to use devlopr-jekyll, devlopr-jekyll tutorial,best jekyll themes, multi languages and tags
usemathjax: false
permalink: /projects/adding-languages-tags-in-projects/
---

## Adding Multiple languages in Projects

To add languages in projectsprojects all you have to do is add a **language** key with language values in frontmatter of the project :

```yml
---
languages: ['jekyll', 'guides', 'sample_language']
---
```

Then to render this language using link and pages. All we need to do is,

1. Create a new file with [your_language_name].md inside languages folder.

2. Copy languages/sample_language.md file and replace the content in [your_language_name].md in that. (Please don't copy the code below its just sample, since it renders the jekyll syntax dynamically)

```jsx
---
layout: page
title: Guides
permalink: /projects/languages/your_language_name/
---

<h5> Projects by Language : {{ page.title }} </h5>

<div class="card">
{% for project in site.languages.your_language_name %}
 <li class="language-projects"><span>{{ project.date | date_to_string }}</span> &nbsp; <a href="{{ project.url }}">{{ project.title }}</a></li>
{% endfor %}
</div>
```

Using the language, all theprojects associated with the language will be listed on
`http://localhost:4000/projects/languages/your_language_name`