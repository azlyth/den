require "cgi"
require "den/resource"

class Page < Resource

  def to_s
    "Page: #{@content[:id]}"
  end


  # Return the HTML rendering of this page
  def html()
    _html = "<div id=\"page\">\n"

    # Wrap title in anchor if link is provided
    _html += "<h1 id=\"title\">#{@content[:title]}</h1>\n"

    # Add the rest of the necessary content
    _html += "<div id=\"body\">\n" +
      "#{@content[:body]}\n" +
      "</div>" +
      "</div>"

    _html
  end


  # Pull out metadata and markup the page
  def process
    File.open(@file) do |f|
      page = markup(f.read)
    end

    # Extract the url from the filename
    page[:id] = @file.split('/')[-1]

    # Store the processed info
    @content = page
  end

end
