import sys

def find_in_file(filepath, query):
    print(f"Searching for '{query}' in {filepath}...")
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    found = False
    for i, line in enumerate(lines):
        if query.lower() in line.lower():
            print(f"Line {i+1}: {line.strip()}")
            found = True
            
    if not found:
        print("Not found.")

if __name__ == "__main__":
    if len(sys.argv) > 2:
        find_in_file(sys.argv[1], sys.argv[2])
    else:
        print("Usage: python find_in_file.py <filepath> <query>")
