# _plugins/preview_converter.rb
module Jekyll
  class PreviewConverter < Converter
    priority :high

    def matches(ext)
      ext =~ /^\.(md|markdown)$/i
    end

    def output_ext(ext)
      ext
    end

    def convert(content)
      # Replace [preview](file.md) with a Jekyll include tag
      content.gsub(/\[preview\]\(([^)]+)\)/) do |match|
        path = $1
        marble_id = File.basename(path, '.*')
        "{% include marble-preview.html marble_id='#{marble_id}' %}"
      end
    end
  end
end
