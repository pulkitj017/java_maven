$licensesFile = "formatted-licenses.txt"
$outdatedFile = "formatted-outdated.txt"
$outputFile = "sbom-result.txt"

# Helper function to split lines by at least 2 spaces
function Split-Columns($line, $expectedCols) {
    $fields = @()
    $regex = '\s{2,}'
    if ($expectedCols -eq 3) {
        # Dependency | Version | License (License can have spaces)
        $matches = $line -split $regex, 3
        $fields = $matches
    }
    elseif ($expectedCols -eq 3) {
        # Dependency | Current | Latest
        $matches = $line -split $regex, 3
        $fields = $matches
    }
    return $fields
}

# Read and process licenses file
$licenses = Get-Content $licensesFile | ForEach-Object {
    if ($_ -notmatch '^Dependency\s+Version\s+License' -and $_ -notmatch '^-+$') {
        $fields = Split-Columns $_ 3
        if ($fields.Length -eq 3) {
            [PSCustomObject]@{
                Dependency = $fields[0].Trim()
                Version = $fields[1].Trim()
                License = $fields[2].Trim()
            }
        }
    }
}

# Read and process outdated file
$outdated = Get-Content $outdatedFile | ForEach-Object {
    if ($_ -notmatch '^Dependency\s+Current\s+Latest' -and $_ -notmatch '^-+$') {
        $fields = Split-Columns $_ 3
        if ($fields.Length -eq 3) {
            [PSCustomObject]@{
                Dependency = $fields[0].Trim()
                CurrentVersion = $fields[1].Trim()
                LatestVersion = $fields[2].Trim()
            }
        }
    }
}

# Initialize the output hashtable to prevent duplicates
$outputHash = @{}

# Merge licenses and outdated info
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

# Add outdated dependencies not in licenses
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

# Write output sorted by Dependency
$outputHash.Values | Sort-Object Dependency | Format-Table -AutoSize | Out-File $outputFile
