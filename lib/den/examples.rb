# A module used to keep all the skeleton defaults in one place.
module Examples
  CONFIG = ":site:\n    :root: /var/www/\n    :posts: musings\n"

  TEMPLATES = {
    # Base template
    :base => "<html>\n	<head>\n		<title>{{ title }} | mysite</title>\n	</head>\n	<body>\n		<div id=\"content\">\n			{{ body }}\n		</div>\n	</body>\n</html>\n",

    # Index template
    :index => "{{ extends base.html }}\n\n{{ block title }}index{{ endblock }}\n\n{{ block body }}\n[[ body ]]\n{{ endblock }}\n",

    # Page template
    :page => "{{ extends base.html }}\n\n{{ block title }}[[ title ]]{{ endblock }}\n\n{{ block body }}\n[[ content ]]\n{{ endblock }}\n",

    # Post template
    :post => "{{ extends base.html }}\n\n{{ block title }}[[ title ]]{{ endblock }}\n\n{{ block body }}\n[[ content ]]\n{{ endblock }}\n",
  }

  # Example page
  PAGE = "[About me]\n\nThis is a test \"about me\" page.\nAsdfasdf.\n\n# Intro\n\n## Past\n\nBlah blah, I did this and that.\n\n## Now\n\nWoah, you do WHAT these days?\n"

  # Example post
  POST = "[What a post.]\n\nNo, but really, what a post. I'm kidding this is an example post.\nIt's a post that makes a world of a difference.\n\n# Some great point\n\n## A worthy subpoint\n\nAnd some info.\n\nAnd conclude.\n"

end
