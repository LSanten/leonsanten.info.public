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
      # Replace [preview](file.md) with a special marker that won't be processed by markdown
      content.gsub(/\[preview\]\(([^)]+)\)/) do |match|
        path = $1
        marble_id = File.basename(path, '.*')
        "<!-- MARBLE_PREVIEW_MARKER:#{marble_id} -->"
      end
    end
  end
end
