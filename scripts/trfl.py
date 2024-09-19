#!/usr/bin/env python3

import io
import os
import re
import sys
import urllib
import urllib.request
from urllib.parse import urlparse

if sys.argv[1].find('?') > -1:
    uri = urlparse(sys.argv[1] + '&action=raw')
else:
    uri = urlparse(sys.argv[1] + '?action=raw')

print(f'URI:\n\t{uri.geturl()}')

pathParts = uri.path.split('/')
articleName = pathParts[-1]
articleName = articleName.replace(':', '_')

if len(sys.argv) > 2:
    translationFileName = sys.argv[2]
elif os.path.isfile('translations.txt'):
    translationFileName = f'translations.txt'
else:
    pathParts = uri.path.split('/')
    translationFileName = f'{articleName}.txt'

print(f'Translation File:\n\t{translationFileName}')

if len(sys.argv) > 3:
    outputFileName = sys.argv[3]
else:
    outputFileName = f'{articleName}.wikitext'

print(f'Output File:\n\t{outputFileName}')

content = None
with urllib.request.urlopen(uri.geturl()) as response:
    content = response.read().decode()

translationsData = None
with io.open(translationFileName, 'rt') as file:
    translationsData = file.read()
translationsData = translationsData.split('\n')

# for debugging/comparison
# with io.open(f'{outputFileName}.tmp', 'wt') as file:
#     file.write(content)

__prefix_re = re.compile('\:[(ex|lc|tc|uc)\|*]+\:')

original:str = None
replacement:str = None
for line in translationsData:
    if line is None or len(line.rstrip()) == 0 or line[0] == '#':
        # skip empty lines, or lines starting with `#` character.
        # when these are encountered state is reset (expecting a new pair)
        # this because the translation page on the FR wiki has blank lines
        # and i want to make sure it works once they are done building it
        original = None
        replacement = None
        continue
    if original is None:
        original = line
        continue
    if replacement is None:
        replacement = line
    if original.startswith(':'):
        prefix = __prefix_re.findall(original)[0]
        original = original.replace(prefix, '')
        specifiers = prefix.split('|')
        for specifier in specifiers:
            specifier = specifier.replace(':', '')
            match specifier:
                case 'ex':
                    content = content.replace(original, replacement)
                case 'lc':
                    content = content.replace(original.lower(), replacement.lower())
                case 'tc':
                    tci = original.title()
                    tco = replacement.title()
                    content = content.replace(tci, tco)
                case 'uc':
                    content = content.replace(original.upper(), replacement.upper())
    else:
        content = content.replace(original, replacement)
    original = None
    replacement = None

with io.open(outputFileName, 'wt') as file:
    file.write(content)
