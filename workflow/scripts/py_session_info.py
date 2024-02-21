#!/usr/bin/env python
# coding: utf-8

# In[1]:


import sys
import platform

def get_python_session_info():
    info = {
        "Python Version": sys.version,
        "Python Compiler": platform.python_compiler(),
        "Python Implementation": platform.python_implementation(),
        "Platform": platform.platform(),
        "System": platform.system(),
        "Processor": platform.processor(),
    }
    return info

# Get Python session information
python_session_info = get_python_session_info()

# Save the information to a text file
output_file_path = 'python_session_info.txt'
with open(output_file_path, 'w') as file:
    for key, value in python_session_info.items():
        file.write(f"{key}: {value}\n")

print(f"Python session information saved to {output_file_path}")


# In[2]:


import pkg_resources

def get_installed_packages():
    installed_packages = []
    for package in pkg_resources.working_set:
        installed_packages.append((package.project_name, package.version))
    return installed_packages

# Get installed packages
installed_packages = get_installed_packages()

# Save the information to a text file
output_file_path = 'python_installed_packages.txt'
with open(output_file_path, 'w') as file:
    for package, version in installed_packages:
        file.write(f"{package}: {version}\n")

print(f"Installed packages information saved to {output_file_path}")


# In[ ]:




