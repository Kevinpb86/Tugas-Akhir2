import os
import re

def fix_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find all occurrences of "GestureDetector("
    # But skip if it's already "child: GestureDetector" and preceded by MouseRegion
    
    # We will iterate character by character
    out = []
    i = 0
    changed = False
    while i < len(content):
        # Look ahead for GestureDetector(
        if content[i:].startswith("GestureDetector("):
            # Check if it's preceded by "MouseRegion" within the last 100 characters ignoring whitespace
            preceding = content[max(0, i-100):i]
            if "MouseRegion" in preceding and "cursor:" in preceding:
                out.append(content[i])
                i += 1
                continue
                
            # It's an unwrapped GestureDetector.
            # Find its extent by counting parentheses.
            start_idx = i + len("GestureDetector(")
            paren_count = 1
            j = start_idx
            while j < len(content) and paren_count > 0:
                if content[j] == '(':
                    paren_count += 1
                elif content[j] == ')':
                    paren_count -= 1
                j += 1
                
            # Now content[i:j] is the whole GestureDetector(...)
            # We want to wrap it.
            original_gesture = content[i:j]
            wrapped = f"MouseRegion(cursor: SystemMouseCursors.click, child: {original_gesture})"
            
            # Actually, what about the indentation? 
            # We can just inline it or let dart format handle it.
            out.append(wrapped)
            i = j
            changed = True
        else:
            out.append(content[i])
            i += 1
            
    if changed:
        with open(path, 'w', encoding='utf-8') as f:
            f.write("".join(out))
        print(f"Fixed {path}")

def main():
    lib_dir = "lib"
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith(".dart"):
                fix_file(os.path.join(root, file))

if __name__ == "__main__":
    main()
