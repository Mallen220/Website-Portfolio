---
layout: page
title: sample_language
permalink: /projects/languages/sample_language/
---

<h5> Projects by Language : {{ page.title }} </h5>

<div class="card">
{% for project in site.data.languages.sample_language %}
  <li class="language-project"><span>{{ project.date | date_to_string }}</span> &nbsp; <a href="{{ project.url }}">{{ project.title }}</a></li>
{% endfor %}

<h6>Available Languages:</h6>
<ul>
  {% for lang in site.languages %}
    <li>{{ lang[0] }}</li>
  {% endfor %}
</ul>

</div>
