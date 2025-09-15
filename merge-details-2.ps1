$licensesFile = "formatted-licenses.txt"
$outdatedFile = "formatted-outdated.txt"
$outputFile = "sbom-result.txt"

# Read and process licenses file with updated regex to capture full License text (with spaces)
$licenses = Get-Content $licensesFile | ForEach-Object {
    if ($_ -notmatch '^Dependency\s+Version\s+License' -and $_ -notmatch '^-+$') {
        # Regex to capture: Dependency, Version, License (all text after version)
        $match = [regex]::Match($_, '^\s*(\S+)\s+(\S+)\s+(.+)$')
        if ($match.Success) {
            [PSCustomObject]@{
                Dependency = $match.Groups[1].Value.Trim()
                Version = $match.Groups[2].Value.Trim()
                License = $match.Groups[3].Value.Trim()
            }
        }
    }
}

# Read and process outdated file (simpler, no change needed)
$outdated = Get-Content $outdatedFile | ForEach-Object {
    if ($_ -notmatch '^Dependency\s+Current\s+Latest' -and $_ -notmatch '^-+$') {
        $fields = $_ -split '\s{2,}'
        if ($fields.Length -ge 3) {
            [PSCustomObject]@{
                Dependency = $fields[0].Trim()
                CurrentVersion = $fields[1].Trim()
                LatestVersion = $fields[2].Trim()
            }
        }
    }
}

# Initialize a hashtable to store unique merged entries
$outputHash = @{}

# Process licenses file first, merge with outdated info if present
foreach ($license in $licenses) {
    $outdatedDep = $outdated | Where-Object { $_.Dependency -eq $license.Dependency }
    $currentVersion = $license.Version
    $latestVersion = $license.Version
    if ($outdatedDep) {
        $currentVersion = $outdatedDep.CurrentVersion
        $latestVersion = $outdatedDep.LatestVersion
        if ($currentVersion -ne $latestVersion) {
            $currentVersion += "**"
            $latestVersion += "**"
        }
    }
    $outputHash[$license.Dependency] = [PSCustomObject]@{
        Dependency = $license.Dependency
        CurrentVersion = $currentVersion
        LatestVersion = $latestVersion
        License = $license.License
    }
}

# Add outdated entries that were not in licenses file, mark License as N/A
foreach ($outdatedDep in $outdated) {
    if (-not $outputHash.ContainsKey($outdatedDep.Dependency)) {
        $currentVersion = $outdatedDep.CurrentVersion
        $latestVersion = $outdatedDep.LatestVersion
        if ($currentVersion -ne $latestVersion) {
            $currentVersion += "**"
            $latestVersion += "**"
        }
        $outputHash[$outdatedDep.Dependency] = [PSCustomObject]@{
            Dependency = $outdatedDep.Dependency
            CurrentVersion = $currentVersion
            LatestVersion = $latestVersion
            License = "N/A"
        }
    }
}

# Output sorted result as a formatted table to file
# Use Out-String to capture the formatted table text nicely
$outputText = $outputHash.Values | Sort-Object Dependency | Format-Table -AutoSize | Out-String

# Save to output file with UTF8 encoding
Set-Content -Path $outputFile -Value $outputText -Encoding UTF8

Write-Host "Merged SBOM file generated: $outputFile"
