---
layout: page
title: sample_language
permalink: /projects/languages/sample_language/
---

<h5> Projects by Language : {{ page.title }} </h5>

<div class="card">
{% for post in site.categories.sample_language %}
 <li class="category-posts"><span>{{ post.date | date_to_string }}</span> &nbsp; <a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}

</div>
