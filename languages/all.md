---
layout: page
permalink: /projects/languages/
---


<h3>  {{ page.title }} </h3>

<div id="languages">
{% for language in site.languages %}
    <div class="language-box" >
    {% capture language_name %}{{ language | first }}{% endcapture %}
    <div id="#{{ language_name | slugize }}"></div>
    <h4 class="language-head"><a href="{{ site.baseurl }}/projects/languages/{{ language_name }}">{{ language_name }}</a></h4>
    <a name="{{ language_name | slugize }}"></a>
     {% for project in site.languages[language_name] %}
    <article class="center">
      <h6 ><a href="{{ site.baseurl }}{{ project.url }}">{{project.title}}</a></h6>
    </article>


    {% endfor %}

  </div>
{% endfor %}
</div>


