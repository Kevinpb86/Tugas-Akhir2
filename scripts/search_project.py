import os

def search_files(directory, query):
    print(f"\nSearching for '{query}' in {directory}...")
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    lines = f.readlines()
                for i, line in enumerate(lines):
                    if query in line:
                        print(f"  {filepath} line {i+1}: {line.strip()[:120]}")

if __name__ == "__main__":
    queries = [
        "Simulasi Evakuasi",
        "Tas Siaga",
        "Lihat Daftar Lengkap",
        "Video Edukasi",
        "Buka di YouTube",
        "video_edukasi",
    ]
    for q in queries:
        search_files("amanin/lib", q)
