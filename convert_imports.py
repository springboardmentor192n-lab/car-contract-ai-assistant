import os
import re

def convert_imports(file_path, backend_root="E:\\autofinance_guardian\\backend"):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    relative_file_path = os.path.relpath(file_path, backend_root)
    
    # Determine the current package path for the file
    if os.path.basename(relative_file_path) == "__init__.py":
        file_package_dir = os.path.dirname(relative_file_path)
    else:
        file_package_dir = os.path.dirname(relative_file_path)
    
    file_package_dir = file_package_dir.replace(os.sep, '.')

    if file_package_dir == ".":
        current_package = "backend"
    elif file_package_dir:
        current_package = "backend." + file_package_dir
    else:
        current_package = "backend" # For files directly in backend/ 

    # New pattern: capture the dots, an optional module path after dots, and imported items
    # Group 1: dots (e.g., ".", "..")
    # Group 2: optional module path after dots (e.g., "submodule", "another.module"), or None
    # Group 3: imported items (e.g., "func", "ClassA, var_b")
    # This regex is more robust for cases like 'from .. import crud' where module_part is implicitly the imported item.
    pattern = r"from\s+(\.+)(?:\s*(\w[\w.]*))?\s+import\s+(.*)"
    
    def replace_relative_import(match):
        dots = match.group(1)
        module_path_after_dots = match.group(2) # This can be None
        imported_items = match.group(3)

        num_dots = len(dots)
        
        # Split the current package path into parts, excluding the 'backend' root
        current_package_parts = current_package.split('.')
        if current_package_parts[0] == "backend":
            current_package_parts = current_package_parts[1:]
        
        # Calculate how many levels up the import goes
        levels_up = num_dots - 1
        
        if levels_up > len(current_package_parts):
            # This relative import tries to go above the 'backend' root.
            # This is likely an error in project structure or the import itself.
            # Return original line to avoid breaking valid Python outside 'backend'.
            return match.group(0) 
        
        # Determine the base absolute path
        base_absolute_parts = ["backend"] + current_package_parts[:len(current_package_parts) - levels_up]
        
        # Construct the final absolute path
        if module_path_after_dots:
            absolute_path = ".".join(base_absolute_parts + [module_path_after_dots])
        else:
            absolute_path = ".".join(base_absolute_parts)

        return f"from {absolute_path} import {imported_items}"

    content = re.sub(pattern, replace_relative_import, content, flags=re.M)
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

# List of files to process (excluding venv)
# The glob command output was filtered to exclude venv, so using that list.
files_to_process = [
    "E:\\autofinance_guardian\\backend\\database.py",
    "E:\\autofinance_guardian\\backend\\main.py",
    "E:\\autofinance_guardian\\backend\\alembic\\env.py",
    "E:\\autofinance_guardian\\backend\\services\\ask_ai_service.py",
    "E:\\autofinance_guardian\\backend\\services\\market_data.py",
    "E:\\autofinance_guardian\\backend\\core\\security.py",
    "E:\\autofinance_guardian\\backend\\models\\schemas.py",
    "E:\\autofinance_guardian\\backend\\routes\\market.py",
    "E:\\autofinance_guardian\\backend\\routes\\negotiation.py",
    "E:\\autofinance_guardian\\backend\\routes\\contract.py",
    "E:\\autofinance_guardian\\backend\\crud.py",
    "E:\\autofinance_guardian\\backend\\routes\\vin.py",
    "E:\\autofinance_guardian\\backend\\routes\\user.py",
    "E:\\autofinance_guardian\\backend\\config.py",
    "E:\\autofinance_guardian\\backend\\models\\orm_models.py",
    "E:\\autofinance_guardian\\backend\\alembic\\versions\\3c711f272e36_add_price_benchmark_cache_table.py",
    "E:\\autofinance_guardian\\backend\\services\\negotiation_service.py",
    "E:\\autofinance_guardian\\backend\\__init__.py",
    "E:\\autofinance_guardian\\backend\\alembic\\versions\\e38e837ce6ae_initial_complete_schema.py",
    "E:\\autofinance_guardian\\backend\\core\\__init__.py",
    "E:\\autofinance_guardian\\backend\\models\\__init__.py",
    "E:\\autofinance_guardian\\backend\\routes\\__init__.py",
    "E:\\autofinance_guardian\\backend\\services\\__init__.py",
    "E:\\autofinance_guardian\\backend\\services\\contract_analysis.py",
    "E:\\autofinance_guardian\\backend\\services\\vin_lookup.py",
    "E:\\autofinance_guardian\\backend\\tests\\conftest.py",
    "E:\\autofinance_guardian\\backend\\tests\\test_crud.py",
    "E:\\autofinance_guardian\\backend\\utils\\__init__.py",
    "E:\\autofinance_guardian\\backend\\utils\\helpers.py",
]

modified_files_count = 0
for f_path in files_to_process:
    if convert_imports(f_path):
        modified_files_count += 1

print(f"Modified {modified_files_count} files.")
