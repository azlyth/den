class Template

  def initialize(template_dir, template_file=nil, post_location=nil)
    @template_dir = template_dir
    load_template(template_file) if !template_file.nil?
    @post_location = post_location
  end


  # Calls the appropriate render function
  def render(obj, prev_page=nil, next_page=nil)
    case obj
    when Resource
      return render_resource(obj)
    when Array
      return render_index(obj, prev_page, next_page)
    end
  end


  # Returns the HTML of a Resource
  def render_resource(r)
    data = {
      "title" => r[:title],
      "content" => r.html
    }

    populate(data)
  end


  # Returns the HTML of an index
  def render_index(posts, prev_page, next_page)
    # Get the HTML of each Post and combine them
    posts.collect! { |p| p.html(File.join('/', @post_location, p[:id].to_s)) }
    data = { "body" => posts.join("\n\n") }

    # Append next/previous links if necessary
    if !prev_page.nil?
      data["body"] += "<a class=\"nav\" id=\"future\" href=\"#{prev_page}\">Newer Posts</a>\n"
    end

    if !next_page.nil?
      data["body"] += "<a class=\"nav\" id=\"past\" href=\"#{next_page}\">Older Posts</a>\n"
    end

    # Return the rendered index
    populate(data)
  end


  # Fills in the template with the data provided
  def populate(data)
    @content.gsub(/\[\[ (\S*) \]\]/) { |x| data[$1] }
  end


  # Loads the template file into @content
  def load_template(filename)
    template_path = File.join(@template_dir, filename)

    if File.file?(template_path)
      # Load the template file
      template_file = ''
      File.open(template_path) do |f|
        template_file = f.read
      end

      # Check if this template is an extension
      if template_file =~ /{{ extends (\S*) }}/
        # Load the parent template into content
        load_template($1)

        # Find blocks
        template_file = template_file.split("{{ endblock }}")
        blocks = {}
        for block in template_file
          if /{{ block (?<label>\S*) }}(?<content>[\s\S]*)/ =~ block
            blocks[label] = content
          end
        end

        # Combine the parent template with the blocks
        merge_templates(blocks)
      else
        # Load the file into content
        @content = template_file
      end
    else
      puts "Unable to locate template: #{@template_dir + filename}."
    end
  end

  # Combine a template with its parent
  def merge_templates(blocks)
    @content.gsub!(/{{ (\S*) }}/) do |x|
      blocks[$1]
    end
  end

end
