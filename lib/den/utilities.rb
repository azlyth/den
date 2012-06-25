# Given a filename (and extension, optionally), returns an unused filename.
def get_unused_filename(filename, extension="")
  extension = "." + extension if extension != ""

  full_path = filename + extension

  if File.exists?(full_path)
    count = 1

    # Keep adding to the count until we find filename that isn't taken.
    while File.exists?("#{filename}_#{count}#{extension}")
      count += 1
    end

    full_path = "#{filename}_#{count}#{extension}"
  end

  full_path
end
