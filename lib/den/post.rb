require "date"
require "cgi"
require "den/resource"

class Post < Resource

  def to_s
    "Post #{@content[:id]}"
  end


  def [](index)
    @content[index]
  end


  # Return the HTML rendering of the post
  def html(link="")
    _html = "<div id=\"post\">\n"

    # Wrap title in anchor if link is provided
    _html += "<h1 id=\"title\">"
    if link != ""
      _html += "<a href=\"#{link}\">"
    end
    _html += "#{@content[:title]}"
    if link != ""
      _html += "</a>"
    end

    _html += "</h1>\n"


    # Add the rest of the necessary content
    _html += "<h2 id=\"date\">#{@content[:date].strftime("%B %e, %Y")}</h2>\n" +
      "<div id=\"body\">\n" +
      "#{@content[:body]}\n" +
      "</div>\n" +
      "</div>"

    _html
  end


  # Pull out metadata and markup the post
  def process
    File.open(@file) do |f|
      # Extract the date
      post = {
        :id => f.readline.chomp,
        :date => DateTime.strptime(f.readline.chomp, "%Y-%m-%d %H:%M:%S %z")
      }

      # Process the post
      post.merge!(markup(f.read))

      # Store the processed info
      @content = post
    end
  end

end
