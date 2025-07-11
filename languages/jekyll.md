---
layout: page
title: jekyll
permalink: /projects/languages/jekyll/
---

<h5> Projects by Language : {{ page.title }} </h5>

<div class="card">
{% for project in site.languages.jekyll %}
  <li class="language-project"><span>{{ project.date | date_to_string }}</span> &nbsp; <a href="{{ project.url }}">{{ project.title }}</a></li>
{% endfor %}
</div>
