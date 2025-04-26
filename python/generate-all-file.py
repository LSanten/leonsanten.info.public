import os
import re
import yaml

# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))

# Define the path to the _mms-md folder relative to the script directory
folder_path = os.path.join(script_dir, '../_mms-md')
output_file = os.path.join(script_dir, '../_mms-md/ALL.md')

# Function to extract the first title from a markdown file
def extract_first_title(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            match = re.match(r'^#\s+(.*)', line)
            if match:
                return match.group(1)
    return "No Title"

# Function to check if a file should be excluded based on tags or frontmatter
def should_exclude_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()

            # Check for the specific tag #private-marble-keep-from-public
            if re.search(r'#private-marble-keep-from-public\b', content):
                return True

            # Check for frontmatter conditions
            if content.startswith('---'):
                end_frontmatter = content.find('---', 3)
                if end_frontmatter != -1:
                    frontmatter_text = content[3:end_frontmatter].strip()
                    try:
                        frontmatter = yaml.safe_load(frontmatter_text)
                        # Check for specific frontmatter condition: visibility: private
                        if frontmatter and isinstance(frontmatter, dict):
                            if frontmatter.get('visibility') == 'private':
                                return True
                    except yaml.YAMLError:
                        # If YAML parsing fails, don't exclude the file
                        pass

            return False
    except Exception as e:
        print(f"Error processing file {file_path}: {e}")
        return False

# Collect all markdown files in the folder
md_files = [f for f in os.listdir(folder_path) if f.endswith('.md')]
md_files.sort(key=lambda f: f.lower())  # Sort files alphabetically, case insensitive

# Generate the output content
output_content = ""
excluded_count = 0

for md_file in md_files:
    file_path = os.path.join(folder_path, md_file)

    # Skip files that should be excluded
    if should_exclude_file(file_path):
        excluded_count += 1
        continue

    title = extract_first_title(file_path)
    filename = os.path.splitext(md_file)[0]
    output_content += f"- [[{filename}]] - {title}\n"

# Write the output content to the all.md file
with open(output_file, 'w', encoding='utf-8') as file:
    file.write(output_content)
    file.write("\n\n#excludeFromGraph (to filter out write -tag:)")  # Add this line to append the tag at the end

print(f"PYTHON: Excluded {excluded_count} files based on tags and frontmatter conditions.")
