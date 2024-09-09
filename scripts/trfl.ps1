#!/bin/pwsh
$ErrorActionPreference = "Stop"

if ($args[0].Contains("?")) {
    $uri = [System.Uri]$($args[0] + "&action=raw")
} else {
    $uri = [System.Uri]$($args[0] + "?action=raw")
}

Write-Host "URI:`n`t$($uri)"

$pathParts = $uri.AbsolutePath.Split('/')
$articleName = $pathParts[$pathParts.Count - 1]
$articleName = $articleName.Replace(":", "_")

if ($args.Count -gt 1) {
    $translationFileName = $args[1]
} else {
    if ([IO.File]::Exists("translations.txt")) {
        $translationFileName = "translations.txt"        
    } else {
        $pathParts = $uri.AbsolutePath.Split('/')
        $translationFileName = "$($articleName).txt"
    }
}

Write-Host "Translation File:`n`t$($translationFileName)"

if ($args.Count -gt 2) {
    $outputFileName = $args[2]
} else {
    $outputFileName = "$($articleName).wikitext"
}

Write-Host "Output File:`n`t$($outputFileName)"

$response = Invoke-WebRequest -URI $uri
$content = $response.Content

$cito = (Get-Culture).TextInfo

$translationsData = Get-Content -Path $translationFileName
$translationsData = $translationsData.Split('`n')

# for debugging/comparison
# $content | Out-File -Force "$($outputFileName).tmp"

for ($i = 0; $i -lt $translationsData.Count; $i = $i + 2) {
    $input = $translationsData[$i]
    $output = $translationsData[$i + 1]
    if ($input.StartsWith(":")) {
        $prefix = [Regex]::Match($input, "\:[(ex|lc|tc|uc)\|*]+\:").Value
        $input = $input.Replace($prefix, "")
        $specifiers = $prefix.Split("|")
        foreach ($specifier in $specifiers) {
            $specifier = $specifier.Replace(":", "")
            switch ($specifier) {
                "ex" {
                    $content = $content.Replace($input, $output)
                }
                "lc" {
                    $content = $content.Replace($input.ToLower(), $output.ToLower())
                }
                "tc" {
                    $tci = $cito.ToTitleCase($input)
                    $tco = $cito.ToTitleCase($output)
                    $content = $content.Replace($tci, $tco)
                }
                "uc" {
                    $content = $content.Replace($input.ToUpper(), $output.ToUpper())
                }
            }
        }
    } else {
        $content = $content.Replace($input, $output)
    }
}

$content | Out-File -Force $outputFileName
