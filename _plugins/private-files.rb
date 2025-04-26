# _plugins/hide_marbles.rb

module Jekyll
  class MarbleHidingGenerator < Generator
    safe true
    priority :normal

    def generate(site)
      Jekyll.logger.info "MarbleHidingGenerator:", "Starting private content processing"

      # STEP 1: Find all private documents and create mapping
      private_docs = {}  # Will store filename -> url mapping

      # Check regular pages
      private_pages = site.pages.select do |page|
        # Check for either frontmatter setting or tag in content
        page.data['visibility'] == 'private' ||
        page.content.include?('#private-marble-keep-from-public')
      end

      private_pages.each do |page|
        filename = File.basename(page.path, '.*')
        reason = page.data['visibility'] == 'private' ? "frontmatter" : "tag"
        Jekyll.logger.info "MarbleHidingGenerator:", "Found private page: #{page.path} (#{filename}) - via #{reason}"
        private_docs[filename] = page.url
      end

      # Check mms-md collection
      if site.collections.key?('mms-md')
        Jekyll.logger.info "MarbleHidingGenerator:", "Checking mms-md collection"

        private_documents = site.collections['mms-md'].docs.select do |doc|
          # Check for either frontmatter setting or tag in content
          doc.data['visibility'] == 'private' ||
          doc.content.include?('#private-marble-keep-from-public')
        end

        private_documents.each do |doc|
          filename = File.basename(doc.path, '.*')
          reason = doc.data['visibility'] == 'private' ? "frontmatter" : "tag"
          Jekyll.logger.info "MarbleHidingGenerator:", "Found private document: #{doc.path} (#{filename}) - via #{reason}"
          private_docs[filename] = doc.url
        end
      else
        Jekyll.logger.warn "MarbleHidingGenerator:", "mms-md collection not found!"
      end

      Jekyll.logger.info "MarbleHidingGenerator:", "Found #{private_docs.size} private files to hide"

      # STEP 2: Process all content to replace links to private files
      if private_docs.any?
        Jekyll.logger.info "MarbleHidingGenerator:", "Processing links to private content"

        # Update links in all pages
        site.pages.each do |page|
          update_links(page, private_docs)
        end

        # Update links in all collections
        site.collections.each do |_, collection|
          collection.docs.each do |doc|
            update_links(doc, private_docs)
          end
        end
      end

      # STEP 3: Remove all private content from the site
      private_pages.each do |page|
        Jekyll.logger.info "MarbleHidingGenerator:", "Removing page: #{page.path}"
        site.pages.delete(page)
      end

      if site.collections.key?('mms-md')
        private_documents = site.collections['mms-md'].docs.select do |doc|
          doc.data['visibility'] == 'private' ||
          doc.content.include?('#private-marble-keep-from-public')
        end

        private_documents.each do |doc|
          Jekyll.logger.info "MarbleHidingGenerator:", "Removing document: #{doc.path}"
          site.collections['mms-md'].docs.delete(doc)
        end
      end

      Jekyll.logger.info "MarbleHidingGenerator:", "Finished processing private content"
    end

    private

    def update_links(item, private_docs)
      changed = false
      content = item.content.dup

      # Process each private document
      private_docs.each do |filename, url|
        # 1. Process wiki-style links: [[FILENAME]]
        if content.include?("[[#{filename}]]")
          content = content.gsub(/\[\[#{Regexp.escape(filename)}\]\]/, '[🛑 PRIVATE MARBLE](PRIVATE-MARBLE.md)')
          changed = true
          Jekyll.logger.info "MarbleHidingGenerator:", "Replaced wiki link [[#{filename}]] in #{item.path}"
        end

        # 2. Process standard markdown links: [TEXT](FILENAME.md)
        if content.match(/\[[^\]]+\]\(#{Regexp.escape(filename)}\.md\)/)
          content = content.gsub(/\[([^\]]+)\]\(#{Regexp.escape(filename)}\.md\)/, '[🛑 PRIVATE MARBLE](PRIVATE-MARBLE.md)')
          changed = true
          Jekyll.logger.info "MarbleHidingGenerator:", "Replaced markdown link to #{filename}.md in #{item.path}"
        end

        # 3. Process URL links in HTML: <a href="/marbles/FILENAME/">
        if content.include?(url)
          content = content.gsub(/<a[^>]*href=["']#{Regexp.escape(url)}["'][^>]*>.*?<\/a>/i, '<a href="PRIVATE-MARBLE.md">🛑 PRIVATE MARBLE</a>')
          changed = true
          Jekyll.logger.info "MarbleHidingGenerator:", "Replaced HTML link to #{url} in #{item.path}"
        end
      end

      # Update content if changes were made
      if changed
        item.content = content
      end
    end
  end
end
