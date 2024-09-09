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

for i in range(0, len(translationsData)-1, 2):
    input = translationsData[i]
    output = translationsData[i + 1]
    if input.startswith(':'):
        prefix = __prefix_re.findall(input)[0]
        input = input.replace(prefix, '')
        specifiers = prefix.split('|')
        for specifier in specifiers:
            specifier = specifier.replace(':', '')
            match specifier:
                case 'ex':
                    content = content.replace(input, output)
                case 'lc':
                    content = content.replace(input.lower(), output.lower())
                case 'tc':
                    tci = input.title()
                    tco = output.title()
                    content = content.replace(tci, tco)
                case 'uc':
                    content = content.replace(input.upper(), output.upper())
    else:
        content = content.replace(input, output)

with io.open(outputFileName, 'wt') as file:
    file.write(content)
