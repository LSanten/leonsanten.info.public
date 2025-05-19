# _plugins/preview_processor.rb

module Jekyll
  class PreviewProcessor < Jekyll::Generator
    priority :normal  # Normal priority to run after other generators

    def generate(site)
      @site = site
      @preview_placeholders = {}

      # Process each markdown document in the site
      process_collection(site.pages)
      process_collection(site.posts.docs) if site.posts

      # Process mms-md collection if it exists
      if site.collections['mms-md']
        process_collection(site.collections['mms-md'].docs)
      end

      # Register a post-convert hook to replace placeholders
      Jekyll::Hooks.register [:pages, :documents], :post_convert do |doc|
        @preview_placeholders.each do |placeholder, marble_id|
          # Generate HTML at post-convert time, when all frontmatter processing is done
          html = generate_preview_html(marble_id)
          doc.content = doc.content.gsub(placeholder, html) if doc.content.include?(placeholder)
        end
      end
    end

    def process_collection(documents)
      documents.each do |document|
        # Skip non-markdown files
        next unless document.extname =~ /^\.(md|markdown)$/i
        # Skip unless content contains a preview link
        next unless document.content.include?('[preview]')

        # Process preview links
        document.content = document.content.gsub(/\[preview\]\(([^)]+)\)/) do |match|
          path = $1
          marble_id = File.basename(path, '.*')

          # Create a unique placeholder that won't be further processed
          placeholder = "PREVIEW_PLACEHOLDER_#{SecureRandom.hex(8)}"

          # Store just the marble_id, not the HTML yet
          @preview_placeholders[placeholder] = marble_id

          # Return placeholder that will be replaced after markdown processing
          placeholder
        end
      end
    end

    private

    def generate_preview_html(marble_id)
      # Find the referenced marble
      marble = find_marble(marble_id)

      return "<div class='marble-preview-error'>Marble not found: #{marble_id}</div>" unless marble

      # Extract data from the marble
      title = marble.data['title'] || "Untitled Marble"

      # Get the image from frontmatter
      image_url = nil
      if marble.data['images'] && marble.data['images'].first
        image_url = marble.data['images'].first
      else
        # Fallback to extracting an image directly from content
        image_match = extract_first_image(marble.content)
        image_url = image_match if image_match
      end

      # Get marble ID (for the link)
      marble_link = "../#{marble_id}/"

      # Extract excerpt and date
      excerpt = extract_excerpt(marble.content)
      date_created = marble.data['date_created']

      # Format the date to show only month and year if available
      formatted_date = ""
      if date_created
        begin
          # Try to parse the date and format it as month year
          if date_created.is_a?(String)
            # First try to extract just the date part if there's a comma in the string
            date_parts = date_created.split(',')
            date_string = date_parts[0].strip

            # Parse the date
            parsed_date = Date.parse(date_string)
            formatted_date = parsed_date.strftime("%B %Y")
          elsif date_created.respond_to?(:strftime)
            # If it's already a date object
            formatted_date = date_created.strftime("%B %Y")
          end
        rescue
          # If date parsing fails, use the original string
          formatted_date = date_created.to_s
        end
      end

      # Debug output
      Jekyll.logger.info "PreviewProcessor:", "Marble: #{marble_id}, Has Image: #{image_url ? true : false}, Image URL: #{image_url}"

      # Build the HTML with the new layout including timestamp
      html = <<-HTML
      <div class="marble-preview">
        <div class="marble-preview-inner">
          #{image_url ? "<div class='marble-preview-image-container'><img src='#{image_url}' alt='#{title}' class='marble-preview-image'></div>" : ""}

          <div class="marble-preview-content">
            <a href="#{marble_link}" class="marble-preview-title-link">
              <h3 class="marble-preview-title">#{title}</h3>
            </a>

            #{marble.data['subtitle'] ? "<h4 class='marble-preview-subtitle'>#{marble.data['subtitle']}</h4>" : ""}

            #{formatted_date.empty? ? "" : "<ul class='card-meta list-inline marble-preview-timestamp'>
              <li class='list-inline-item'>
                <i class='ti-calendar'></i> #{formatted_date}
              </li>
            </ul>"}

            <div class="marble-preview-text">
              <p>#{excerpt}</p>
            </div>

            <a href="#{marble_link}" class="marble-preview-link">Read more</a>
          </div>
        </div>
      </div>
      HTML

      html
    end

    def find_marble(marble_id)
      # First try to find by file_name in frontmatter
      marble = @site.collections['mms-md'].docs.find { |d| d.data['file_name'] == marble_id }

      # If not found, try to find by filename (without extension)
      if !marble
        marble = @site.collections['mms-md'].docs.find { |d| File.basename(d.path, '.*') == marble_id }
      end

      marble
    end

    def extract_excerpt(content)
      # Remove headings and get first non-empty paragraph
      content_without_headings = content.gsub(/^#.+$/, '')
      paragraphs = content_without_headings.split("\n\n")

      # Find first non-empty paragraph that isn't an image
      first_paragraph = paragraphs.find { |p| !p.strip.empty? && !p.match(/^!\[/) }

      # Truncate and sanitize
      excerpt = first_paragraph ? first_paragraph.strip.gsub(/<\/?[^>]*>/, '') : ""
      excerpt.length > 200 ? excerpt[0...197] + "..." : excerpt
    end

    def extract_first_image(content)
      # Try to find the first image in markdown content
      image_match = content.match(/!\[.*?\]\((.*?)\)/)
      image_match ? image_match[1] : nil
    end
  end
end

# Make sure SecureRandom is available
require 'securerandom'
