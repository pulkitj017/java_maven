$licensesFile = "formatted-licenses.txt"
$outdatedFile = "formatted-outdated.txt"
$outputFile = "sbom-result.txt"
# Read and process licenses file
$licenses = Get-Content $licensesFile | ForEach-Object {
    if ($_ -notmatch '^Dependency\s+Version\s+License' -and $_ -notmatch '^-+$') {
        $fields = $_ -split '\s{2,}'
        if ($fields.Length -ge 3) {
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
# Initialize the output hashtable to prevent duplicates
$outputHash = @{}
# Process licenses file
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
    # Store unique dependencies in a hashtable
    $outputHash[$license.Dependency] = [PSCustomObject]@{
        Dependency = $license.Dependency
        CurrentVersion = $currentVersion
        LatestVersion = $latestVersion
        License = $license.License
    }
}
# Add entries from outdated file not in the licenses file
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
# Write the output to the file, sorted by Dependency
$outputHash.Values | Sort-Object Dependency | Format-Table -AutoSize | Out-File $outputFile
