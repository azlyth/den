require "fileutils"
require "date"
require "den/post"
require "den/page"
require "den/template"
require "den/utilities"
require "den/examples"

class Den

  # Creates a new Den site
  def self.create_skeleton(location)
    # Create the directories along with default templates
    Dir.mkdir(location)
    Dir.mkdir(File.join(location, 'pages'))
    Dir.mkdir(File.join(location, 'posts'))
    Dir.mkdir(File.join(location, 'posts', 'new'))
    Dir.mkdir(File.join(location, 'templates'))
    Examples::TEMPLATES.each_pair { |file, content|
      File.open(File.join(location, 'templates', file.to_s + '.html'), 'w') do |f|
        f.print(content)
      end
    }

    File.open(File.join(location, 'config.yml'), 'w') do |f|
      f.write(Examples::CONFIG)
    end

    # Create the file that indicates this is a Den instance
    FileUtils.touch(File.join(location, '.den'))

    puts "Created new site in '#{location}'."
  end

  # Default configuration values
  @@default_config = {
    # Where pages are actually served from
    # Note the following:
    # - 'root' gets prepended to all locations but 'index'
    # - 'posts' gets prepended to 'index'
    :site => {
      :root => "/var/www/",
      :pages => "",
      :posts => "posts/",
      :index => "index/",
    },
  }

  @@default_meta = {
    # The number of total posts
    :last_post => 0,
  }


  # Create the Den and store the config, prioritizing the provided one.
  def initialize(config=nil)
    @config = @@default_config

    if !config.nil?
      @config[:new_posts] = config[:new_posts] if !config[:new_posts].nil?
      @config[:site].merge!(config[:site]) if !config[:site].nil?
    end

    load_metadata
    gather_new_posts
    prepare_content
  end




  # Update the site
  def update_site(refresh=false)
    if refresh
      prepare_content
    end
    push_content
    create_indices
    puts "Updated the site."
  end


  # Display the Den's pages and posts, along with their metadata
  def print_content
    puts "Pages:" if !@pages.empty?
    @pages.each do |p|
      puts "  #{p[:id]} (title: '#{p[:title]}')"
    end

    puts "Posts:" if !@posts.empty?
    @posts.each do |p|
      puts "  #{p[:id]} (title: '#{p[:title]}', date: #{p[:date].strftime("%B %e, %Y")})"
    end

    if @pages.empty? and @posts.empty?
      puts "No content."
    end
  end


  # Adds a page or post. If a file is provided, it copies the contents of the
  # file. Otherwise, it will start the default editor to make the new resource.
  def new_resource(type, options)
    defaults = {:file => nil, :dest => nil}
    options = defaults.merge(options)
    type.downcase!

    if options[:file].nil?
      # Create the new page/post with the default editor
      if type == 'page'
        file = File.join('pages', options[:dest])
        system("/usr/bin/editor #{file}")
      elsif type == 'post'
        file = File.join('posts', 'new', 'new.post')
        system("/usr/bin/editor #{file}")
        gather_new_posts
      end

      if File.exists?(file)
        puts "Added a #{type}."
      else
        puts "Cancelled adding a #{type}."
      end

    else
      # Copy the file that will be the new page/post
      if type == 'page'
        FileUtils.cp(options[:file], File.join('pages', options[:dest]))
      elsif type == 'post'
        FileUtils.cp(options[:file], File.join('posts', 'new'))
        gather_new_posts
      end

      puts "Using #{options[:file]} as a new #{type}."
    end
  end


  # Deletes a page/post, identified by its ID
  def delete_resource(type, id)
    type.downcase!

    # Find the page/post
    if type == 'page'
      res = @pages.select { |p| p[:id] == id }
      fn = File.join(@config[:site][:root], @config[:site][:pages])
    elsif type == 'post'
      res = @posts.select { |p| p[:id] == id }
      fn = File.join(@config[:site][:root], @config[:site][:posts])
    end

    # If we found a resource, delete it.
    if !res.nil?
      res = res[0]
      fn = File.join(fn, res[:id])
      File.delete(fn) if File.exists?(fn)
      res.delete
      puts "Deleted #{type} '#{id}'."
    else
      puts "No #{type} with id '#{id}'."
    end
  end


  def load_metadata
    @meta = @@default_meta

    meta_file = File.join("metadata.yml")

    # Load the metadata
    if File.exists?(meta_file)
      yml = YAML::load(File.open(meta_file))
      @meta.merge!(yml)
    end
  end


  def save_metadata
    meta_file = File.join("metadata.yml")

    File.open(meta_file, 'w') do |f|
      f.puts("# Do not touch this file, as it's auto-generated.")
      YAML::dump(@meta, f)
    end
  end


  # Create the indices for the posts
  def create_indices
    destination = File.join(@config[:site][:root], @config[:site][:posts], @config[:site][:index])
    Dir.mkdir(destination) if !Dir.exists?(destination)

    # Clear out the indices before making them
    Dir.entries(destination).each do |f|
      index = File.join(destination, f)
      File.delete(index) if File.file?(index)
    end

    temp_dir = File.join("templates")
    template = Template.new(temp_dir, 'index.html', post_location=@config[:site][:posts])
    indices = []

    # Segment the posts into groups of 5
    @posts.each_slice(5) { |posts|
      indices << posts
    }

    # Create the indices and save them
    indices.length.times { |i|
      p_pg = nil
      n_pg = nil

      # Find the relative location (to the site) of the index
      rel_index = File.join("/", @config[:site][:posts], @config[:site][:index])

      # Figure out the previous/next pages, if they exist
      p_pg = File.join(rel_index, i.to_s) if i > 0
      n_pg = File.join(rel_index, (i+2).to_s) if i + 1 < indices.length

      # Render the index page
      indices[i] = template.render(indices[i], prev_page=p_pg, next_page=n_pg)

      # Save the index page
      index_file = File.join(destination, (i+1).to_s)
      File.open(index_file, 'w') do |f|
        f.print(indices[i])
      end
    }
  end


  # Publish the posts and pages
  def push_content
    temp_dir = File.join("templates")

    # Create the post directory if it doesn't exist
    destination = File.join(@config[:site][:root], @config[:site][:posts])
    Dir.mkdir(destination) if !Dir.exists?(destination)

    # Render and save each post to the post directory
    template = Template.new(temp_dir, 'post.html')
    @posts.each do |post|
      post_file = File.join(destination, post[:id])
      File.open(post_file, 'w') do |f|
        f.print(template.render(post))
      end
    end

    # Create the page directory if it doesn't exist
    destination = File.join(@config[:site][:root], @config[:site][:pages])
    Dir.mkdir(destination) if !Dir.exists?(destination)

    # Render and save each page to the page directory
    template = Template.new(temp_dir, 'page.html')
    @pages.each do |page|
      page_file = File.join(destination, page[:id])
      File.open(page_file, 'w') do |f|
        f.print(template.render(page))
      end
    end

  end

  # Move any new posts to the saved posts directory.
  def gather_new_posts
    new_dir = File.join("posts", "new")

    Dir.entries(new_dir).each do |f|
      post_file = File.join(new_dir, f)
      if File.file?(post_file)

        # Save the new post to the processed directory with metadata attached
        File.open(post_file) do |new_post|
          date = new_post.mtime
          save_path = get_unused_filename(File.join("posts", date.strftime("%Y-%m-%d")), "post")

          File.open(save_path, "w") do |save_file|
            save_file.puts(@meta[:last_post] + 1)
            save_file.puts(date.strftime("%Y-%m-%d %H:%M:%S %z"))
            save_file.print(new_post.read)
          end
        end

        # Remove the file from the new post directory
        File.delete(post_file)

        # Update the value of the last ID used
        @meta[:last_post] += 1

      end
    end
  end

  # Process the pages and posts
  def prepare_content
    @posts = []
    @pages = []

    # Create a Post for each file in the posts directory
    Dir.entries('posts').each do |f|
      entry = File.join('posts', f)
      if File.file?(entry)
        @posts << Post.new(entry)
      end
    end

    # Create a Page for each file in the pages directory
    Dir.entries('pages').each do |f|
      entry = File.join('pages', f)
      if File.file?(entry)
        @pages << Page.new(entry)
      end
    end

    save_metadata

    # Sort the posts by date, with most recent first
    @posts.sort_by! { |post| post[:date] }
    @posts.reverse!
  end

end
