---
layout: page
title: Python
permalink: /projects/languages/Python/
---

<h5> Projects by Language : {{ page.title }} </h5>

<div class="card">
{% for post in site.categories.Python %}
 <li class="category-posts"><span>{{ post.date | date_to_string }}</span> &nbsp; <a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}

</div>
