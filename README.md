# `trfl`

Scripts to aid with translating mediawiki content.

The scripts in this repo are designed to fetch raw mediawiki content and then apply a series of text replacements using data from a "translation file". The result is saved locally for human review and submission.

The provided scripts are written for PowerShell and Python.

On Unix-like systems you can symlink these into to `/usr/bin/local` without a file extension. Although not required, all sample commands in this README assume you've done this.

On Windows systems you will probably need to specify the full path to the script, including the file extension. To run the PowerShell script you would also want to launch PowerShell first.

## Usage

Provide the target wiki article URL, a translation file to use, and an (optional) output file name.

```bash
trfl https://the-wiki.com/wiki/Article ./translations.txt outfile.wikitext
```

If you do not provide an output file name, a file name will be generated from the Article name in the url (for example "Article.wikitext"). You can also omit specifying the translation file. The tool will first look for a default named "translations.txt" and if not found will then look for a file sharing the same name as the Article name in the url (for example "Article.txt".)

```bash
trfl https://the-wiki.com/wiki/Article
```

## Translation Files

The translation files contain simple value pairs separated by new-lines.  Odd-numbered lines are the text to be replaced, followed by a line containing the text to replace it with. As an example:

```txt
Deviation
Anomalie
Danger Zone Map Icon
Zone de Danger Carte Icôn
Residential Map Icon
Résidentielle Carte Icôn
```

### Specifiers

By default, the translations are case-sensitive, so a translation entry for `Deviation` will not be applied to "deviation", it will only be applied to an exact match of `Devation` (upper-case `D`). 

> **NOTE**: Specifiers are optional. It is better to not use them. They exist so that you can enter a transaltion _once_ and have the translation match multiple forms of text such as "exact match + lower case + title case". If you don't need this behavior you can avoid using any specifiers. The default behavior is equivalent to using a specifier of `:ex:`.

You can change the default behavior by providing one or more "specifiers":

```txt
:ex|lc|tc|uc:Deviation
Anomalie
Danger Zone Map Icon
Zone de Danger Carte Icôn
:tc:Residential Map Icon
Résidentielle Carte Icôn
```

Specifiers are wrapped by two colons and separated by pipe characters.

The specifiers augment behavior as follows:

| Specifier | Behavior |
|-|-|
| `ex` | Exact Match; this is the default behavior if there is no specifier. The input must match exactly. |
| `lc` | Lower Case; the input AND replacement text are converted to lower-case before matching. |
| `tc` | Title Case; the input AND replacement text are converted to title-case before matching. |
| `uc` | Upper Case; the input AND replacement text are converted to upper-case before matching. |

Examples:

Consider the following translation entry:

:ex|lc|tc|uc:Danger Zone Map Icon
Zone de Danger Carte Icôn

This results in the following match->replacement behavior:

| Specifier | Matches | Replaced With |
|-|-|-|
| `ex` | Danger Zone Map Icon | Zone de Danger Carte Icôn |
| `lc` | danger zone map icon | zone de danger carte icôn |
| `tc` | Danger Zone Map Icon | Zone De Danger Carte Icôn |
| `uc` | DANGER ZONE MAP ICON | ZONE DE DANGER CARTE ICÔN |

## Contact

You can reach me on [Discord](https://discordapp.com/users/307684202080501761) or [open an Issue on Github](https://github.com/wilson0x4d/trfl/issues/new/choose).
