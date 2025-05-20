# _plugins/preview_processor.rb

module Jekyll
  module PreviewProcessor
    # Hook to replace our markers with real rendered includes after markdown processing
    def self.process_previews
      Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
        # Replace our markers with real rendered includes
        doc.output = doc.output.gsub(/<!-- MARBLE_PREVIEW_MARKER:([^ ]+) -->/) do |match|
          marble_id = $1
          
          # Render the include with the marble_id
          render_include(marble_id, doc.site)
        end
      end
    end
    
    def self.render_include(marble_id, site)
      # Find the include file
      include_file = File.join(site.source, "_includes", "marble-preview.html")
      
      # Check if the file exists
      unless File.exist?(include_file)
        return "<div class='marble-preview-error'>Include file not found: _includes/marble-preview.html</div>"
      end
      
      # Find the marble
      marble = find_marble(marble_id, site)
      
      unless marble
        return "<div class='marble-preview-error'>Marble not found: #{marble_id}</div>"
      end
      
      # Read the include file
      include_content = File.read(include_file)
      
      # Replace variables in the include file
      html = include_content.dup
      
      # Basic variable replacements
      html.gsub!('{{ marble_id }}', marble_id)
      html.gsub!('{{ marble_link }}', "../#{marble_id}/")
      
      # Title and subtitle
      title = marble.data['title'] || "Untitled Marble"
      subtitle = marble.data['subtitle']
      html.gsub!('{{ title }}', title)
      
      # Handle conditional sections for subtitle
      if subtitle
        html.gsub!('{% if subtitle %}', '')
        html.gsub!('{% endif %}', '')
        html.gsub!('{{ subtitle }}', subtitle)
      else
        # Remove the subtitle section
        html.gsub!(/{% if subtitle %}.*?{% endif %}/m, '')
      end
      
      # Image URL
      image_url = nil
      if marble.data['images'] && marble.data['images'].first
        image_url = marble.data['images'].first
      else
        # Fallback to extracting an image directly from content
        image_match = marble.content.match(/!\[.*?\]\((.*?)\)/)
        if image_match
          path = image_match[1]
          # Adjust relative paths
          if !path.start_with?('http') && !path.start_with?('/')
            path = "../#{path}"
          end
          image_url = path
        end
      end
      
      # Default image if none found
      image_url ||= "https://leonsanten.info/assets/marble-assets/images/marble-imagery/woven-marble-3.png"
      
      # Replace image variables and handle conditional section
      if image_url
        html.gsub!('{% if image_url %}', '')
        html.gsub!('{% endif %}', '')
        html.gsub!('{{ image_url }}', image_url)
      else
        # Remove the image section
        html.gsub!(/{% if image_url %}.*?{% endif %}/m, '')
      end
      
      # Excerpt
      excerpt = extract_first_paragraph(marble.content)
      html.gsub!('{{ excerpt }}', excerpt)
      
      # Date
      date_created = format_marble_date(marble.data['date_created'])
      if !date_created.empty?
        html.gsub!('{% if date_created != "" %}', '')
        html.gsub!('{% endif %}', '')
        html.gsub!('{{ date_created }}', date_created)
      else
        # Remove the date section
        html.gsub!(/{% if date_created != "" %}.*?{% endif %}/m, '')
      end
      
      html
    end
    
    def self.find_marble(marble_id, site)
      # First try to find by file_name in frontmatter
      marble = site.collections['mms-md'].docs.find { |d| d.data['file_name'] == marble_id }
      
      # If not found, try to find by filename (without extension)
      if !marble
        marble = site.collections['mms-md'].docs.find { |d| File.basename(d.path, '.*') == marble_id }
      end
      
      marble
    end
    
    def self.extract_first_paragraph(content)
      # Remove YAML front matter if present
      content_without_yaml = content.to_s.sub(/\A---(.|\n)*?---\n/m, '')
      
      # Remove headings
      content_without_headings = content_without_yaml.gsub(/^#.*$\n?/, '')
      
      # Split into paragraphs and process
      paragraphs = content_without_headings.split(/\n\n+/)
      
      # Find first substantive paragraph that isn't an image, code block, or other special element
      first_paragraph = paragraphs.find do |p|
        p = p.strip
        p.length > 0 && 
        !p.start_with?('!') &&     # Not an image
        !p.start_with?('```') &&   # Not a code block
        !p.start_with?('> ') &&    # Not a blockquote
        !p.start_with?('|') &&     # Not a table
        !p.start_with?('- ') &&    # Not a list
        !p.start_with?('* ') &&    # Not a list
        !p.start_with?('1. ')      # Not a numbered list
      end

      # Clean up and truncate
      if first_paragraph
        # Strip HTML and markdown formatting
        clean_text = first_paragraph.strip
                      .gsub(/<\/?[^>]*>/, '')  # Remove HTML tags
                      .gsub(/\[([^\]]+)\]\([^)]+\)/, '\1')  # Convert markdown links to just text
                      .gsub(/(?:\*\*|__)([^*_]+)(?:\*\*|__)/, '\1')  # Remove bold
                      .gsub(/(?:\*|_)([^*_]+)(?:\*|_)/, '\1')  # Remove italic
                      .gsub(/`([^`]+)`/, '\1')  # Remove inline code
        
        # Truncate with ellipsis if too long
        clean_text.length > 200 ? clean_text[0...197] + "..." : clean_text
      else
        "No preview available"
      end
    end
    
    def self.format_marble_date(date_value)
      return "" unless date_value
      
      begin
        # First try to extract just the date part if there's a comma in the string
        if date_value.is_a?(String)
          date_parts = date_value.split(',')
          date_string = date_parts[0].strip
          
          # Parse the date
          parsed_date = Date.parse(date_string)
          return parsed_date.strftime("%B %Y")
        elsif date_value.respond_to?(:strftime)
          # If it's already a date object
          return date_value.strftime("%B %Y")
        end
      rescue => e
        # If date parsing fails, use the original string
        return date_value.to_s.split(',').first.strip
      end
      
      ""
    end
  end
end

# Initialize the processor
Jekyll::PreviewProcessor.process_previews

# Make sure Date is available
require 'date'