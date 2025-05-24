#!/usr/bin/env ruby

# Super simple markdown excerpt extractor - basic version

def extract_excerpt_simple(content)
  puts "🔍 STARTING EXTRACTION"

  # Remove YAML frontmatter
  if content.start_with?('---')
    parts = content.split('---', 3)
    if parts.length >= 3
      content = parts[2].strip
      puts "✅ Removed YAML frontmatter"
    end
  end

  lines = content.split("\n")
  puts "📄 Processing #{lines.length} lines"

  collected_content = []

  lines.each_with_index do |line, index|
    line = line.strip
    puts "\n#{index + 1}. Line: '#{line}'"
    puts "   Length: #{line.length}"

    # Check each condition and say what we're doing
    if line.empty?
      puts "   → SKIP: Empty line"
      next
    elsif line.start_with?('#')
      puts "   → SKIP: Header (starts with #)"
      next
    elsif line.start_with?('![')
      puts "   → SKIP: Image (starts with ![)"
      next
    elsif line.start_with?('>')
      cleaned = line.gsub(/^\s*>\s*/, '')
      puts "   → INCLUDE: Blockquote -> '#{cleaned}'"
      collected_content << cleaned
      next
    elsif line.start_with?('-') || line.start_with?('*') || line.start_with?('+')
      if line.match?(/^\s*[-*+]\s/)
        cleaned = line.gsub(/^\s*[-*+]\s*/, '• ')
        puts "   → INCLUDE: List item -> '#{cleaned}'"
        collected_content << cleaned
        next
      end
    elsif line.length < 10
      puts "   → SKIP: Too short (< 10 chars)"
      next
    end

    # If we get here, it's regular content
    puts "   → INCLUDE: Regular content -> '#{line}'"
    collected_content << line
  end

  puts "\n📋 FINAL RESULTS:"
  puts "Collected #{collected_content.length} pieces of content:"
  collected_content.each_with_index do |content, i|
    puts "  #{i + 1}: #{content[0...60]}#{'...' if content.length > 60}"
  end

  final_text = collected_content.join(' ')
  puts "\n📖 JOINED TEXT:"
  puts "\"#{final_text}\""

  return final_text
end

# Get all markdown files in current directory
markdown_files = Dir.glob("*.md").sort

puts "🔄 Scanning current directory for markdown files..."
puts "📁 Current directory: #{Dir.pwd}"

if markdown_files.empty?
  puts "❌ No markdown files found in current directory"
  exit 1
end

puts "✅ Found markdown files: #{markdown_files.join(', ')}"

puts "🚀 MARKDOWN EXCERPT EXTRACTION TESTS"
puts "📁 Working directory: #{Dir.pwd}"
puts "📂 Found #{markdown_files.length} markdown files"
puts "=" * 80

markdown_files.each_with_index do |file, index|
  puts "\n🔢 TEST #{index + 1}/#{markdown_files.length}: #{file}"
  puts "=" * 60

  begin
    content = File.read(file)
    puts "📄 File size: #{content.length} characters"

    excerpt = extract_excerpt_simple(content)

    puts "\n📊 SUMMARY:"
    puts "   Word count: #{excerpt.split(/\s+/).length}"
    puts "   Character count: #{excerpt.length}"
    puts "   First 100 chars: \"#{excerpt[0...100]}#{'...' if excerpt.length > 100}\""

  rescue => e
    puts "❌ Error processing #{file}: #{e.message}"
    puts "🔍 Backtrace: #{e.backtrace.first(3).join(', ')}"
  end

  puts "\n" + "." * 80 if index < markdown_files.length - 1
end

puts "\n✅ ALL TESTS COMPLETE!"
puts "🎉 Ready to integrate into Jekyll plugin"
puts "=" * 80
