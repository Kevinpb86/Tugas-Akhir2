import sys

def fix_main_py():
    with open('backend/main.py', 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    idx = -1
    for i, line in enumerate(lines):
        if 'if __name__ == "__main__":' in line:
            idx = i
            break
            
    if idx != -1:
        main_block = lines[idx:idx+3]
        del lines[idx:idx+3]
        lines.extend(main_block)
        with open('backend/main.py', 'w', encoding='utf-8') as f:
            f.write("".join(lines))
        print('Fixed main.py order using lines.')
    else:
        print('Could not find main block.')

fix_main_py()
