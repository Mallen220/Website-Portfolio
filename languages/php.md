---
layout: page
title: PHP
permalink: /projects/languages/php/
---

<h5> Projects by Language : {{ page.title }} </h5>

<div class="card">
{% for project in site.data.languages.php %}
  <li class="language-project"><span>{{ project.date | date_to_string }}</span> &nbsp; <a href="{{ project.url }}">{{ project.title }}</a></li>
{% endfor %}

<h6>Available Languages:</h6>
<ul>
  {% for lang in site.languages %}
    <li>{{ lang[0] }}</li>
  {% endfor %}
</ul>

</div>
