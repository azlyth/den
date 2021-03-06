# General Den resource object (included by Page and Post)
class Resource

  # Initialize the object
  def initialize(file)
    @file = file
    process
  end


  def [](index)
    @content[index]
  end


  # Deletes itself
  def delete
    File.delete(@file)
  end


  # General markup function
  def markup(s)
    s = CGI::escapeHTML(s)
    title = nil

    # Extract title
    s.gsub!(/\A\[(.*\S)\]$/) do |x|
      title = $1
      ""
    end

    # Remove duplicate newlines
    s.gsub!(/\n\n+/, "\n\n")

    # Remove leading spaces from lines
    s.gsub!(/^ +/, "")

    # Pad string to remove edge cases
    s.gsub!(/(\A\n*)|(\n*\z)/, "\n")

    # Headers
    s.gsub!(/^(#+)\s*(.*)/) {
      len = $1.length
      "<h#{len+1} class=\"header\">#$2</h#{len+1}>"
    }

    # Code (leaving placeholder pre tags)
    s.gsub!(/^\t(.*)$/, "<pre>\\1</pre>")

    # Paragraphs
    s.gsub!(/(\A|\n)\n([^<])/, "\n\n<p>\\2")
    s.gsub!(/([^>])\n\n/, "\\1</p>\n\n")

    # Remove placeholder pre tags
    s.gsub!(/<\/pre>\n<pre>/, "\n")

    {:title => title, :body => s}
  end

end
