import os

def search_files(directory, query):
    print(f"Searching for '{query}' in {directory}...")
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    lines = f.readlines()
                for i, line in enumerate(lines):
                    if query in line:
                        print(f"Found in: {filepath} at line {i+1}: {line.strip()}")

if __name__ == "__main__":
    search_files("amanin/lib", "Asuransi Pro-Siaga")

