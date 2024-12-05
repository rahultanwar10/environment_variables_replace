import re
import os
import argparse
import warnings

# Parse variables from the cshrc file
def parse_cshrc(cshrc_path):
    variables = {}
    with open(cshrc_path, 'r') as cshrc_file:
        for line in cshrc_file:
            # Match `setenv variable value`
            match = re.match(r'setenv (\w+)\s+(.+)', line.strip())
            if match:
                key, value = match.groups()
                # Detect shell command substitutions and assign None
                if "`" in value or "$" in value and not re.match(r'\$\w+', value):
                    warnings.warn(f"Shell command or complex expression detected for '{key}'. Assigning None.")
                    value = "None"
                variables[key] = value
    return variables

# Resolve indirect variables
def resolve_variables(variables):
    resolved = {}
    
    def resolve(key):
        value = variables[key]
        # Recursively resolve variables
        while "$" in value:
            match = re.search(r'\$(\w+)', value)
            if not match:
                break
            ref_key = match.group(1)
            if ref_key not in variables:
                warnings.warn(f"Undefined variable: {ref_key} (in '{key}'). Assigning None.")
                value = value.replace(f"${ref_key}", "None")
                break
            value = value.replace(f"${ref_key}", resolve(ref_key))
        if value.startswith(("'", '"')) and value.endswith(("'", '"')):
            value = value[1:-1]
        return value

    for key in variables:
        resolved[key] = resolve(key)
    return resolved

# Replace variables in the config file
def replace_variables(cfg_path, resolved_vars, output_path):
    with open(cfg_path, 'r') as cfg_file:
        content = cfg_file.read()
    
    for key, value in resolved_vars.items():
        content = content.replace(f"${key}", value)
    
    with open(output_path, 'w') as output_file:
        output_file.write(content)

parser = argparse.ArgumentParser(description="Replace environment variables")
parser.add_argument("-cshrc_file", required=True, help="Path to the input cshrc file")
parser.add_argument("-config_file", required=True, help="Path to the input config file")
parser.add_argument("-output", required=True, help="Path to the output config file")
args = parser.parse_args()

# Execute
variables = parse_cshrc(args.cshrc_file)
resolved_vars = resolve_variables(variables)
replace_variables(args.config_file, resolved_vars, args.output)

print(f"Variables replaced successfully! Updated file: {args.output}")
