#!/bin/pwsh
$ErrorActionPreference = "Stop"

if ([String]::IsNullOrWhiteSpace($args[0])) {
    Write-Error "Missing required URL parameter, aborting."
    return
}

if ($args[0].Contains("?")) {
    $uri = [System.Uri]$($args[0] + "&action=raw")
} else {
    $uri = [System.Uri]$($args[0] + "?action=raw")
}

Write-Host "URI:`n`t$($uri)"

$pathParts = $uri.AbsolutePath.Split(@("/"))
$articleName = $pathParts[$pathParts.Count - 1]
$articleName = $articleName.Replace(":", "_")

if ($args.Count -gt 1) {
    $translationFileName = $args[1]
} else {
    if ([IO.File]::Exists("translations.txt")) {
        $translationFileName = "translations.txt"        
    } else {
        $pathParts = $uri.AbsolutePath.Split(@("/"))
        $translationFileName = "$($articleName).txt"
    }
}

Write-Host "Translation File:`n`t$($translationFileName)"

if ($args.Count -gt 2) {
    $replacementFileName = $args[2]
} else {
    $replacementFileName = "$($articleName).wikitext"
}

Write-Host "Output File:`n`t$($replacementFileName)"

$response = Invoke-WebRequest -URI $uri
$content = $response.Content

$cito = (Get-Culture).TextInfo

$translationsData = Get-Content -Path $translationFileName
$translationsData = $translationsData.Replace("`r", "").Split(@("`n"))

# for debugging/comparison
# $content | Out-File -Force "$($replacementFileName).tmp"

$original = $null
$replacement = $null
foreach ($line in $translationsData) {
    if ($null -eq $line -or $line.Length -eq 0 -or $line.StartsWith("#")) {
        # skip empty lines, or lines starting with `#` character.
        # when these are encountered state is reset (expecting a new pair)
        # this because the translation page on the FR wiki has blank lines
        # and i want to make sure it works once they are done building it
        $original = $null
        $replacement = $null
        continue
    }
    if ($null -eq $original) {
        $original = $line
        continue
    }
    if ($null -eq $replacement) {
        $replacement = $line
    }
    if ($original.StartsWith(":")) {
        $prefix = [Regex]::Match($original, "\:[(ex|lc|tc|uc)\|*]+\:").Value
        $original = $original.Replace($prefix, "")
        $specifiers = $prefix.Split(@("|"))
        foreach ($specifier in $specifiers) {
            $specifier = $specifier.Replace(":", "")
            switch ($specifier) {
                "ex" {
                    $content = $content.Replace($original, $replacement)
                }
                "lc" {
                    $content = $content.Replace($original.ToLower(), $replacement.ToLower())
                }
                "tc" {
                    $tci = $cito.ToTitleCase($original)
                    $tco = $cito.ToTitleCase($replacement)
                    $content = $content.Replace($tci, $tco)
                }
                "uc" {
                    $content = $content.Replace($original.ToUpper(), $replacement.ToUpper())
                }
            }
        }
    } else {
        $content = $content.Replace($original, $replacement)
    }
    $original = $null
    $replacement = $null
}

$content | Out-File -Force $replacementFileName
