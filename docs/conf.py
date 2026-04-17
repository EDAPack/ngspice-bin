# Configuration file for the Sphinx documentation builder.
#
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import os
import sys

# -- Project information -----------------------------------------------------
project = 'ngspice-bin'
copyright = '2025, Matthew Ballance and Contributors'
author = 'Matthew Ballance'

# -- General configuration ---------------------------------------------------
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',
    'myst_parser',
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

source_suffix = {
    '.rst': 'restructuredtext',
    '.md': 'markdown',
}

# -- Options for HTML output -------------------------------------------------
html_theme = 'alabaster'
html_static_path = ['_static']

html_theme_options = {
    'description': 'Portable NGSpice binary distribution for Linux',
    'github_user': 'EDAPack',
    'github_repo': 'ngspice-bin',
    'github_banner': True,
    'fixed_sidebar': False,
}
