# Define the path to the input and output files
$inputFile = "outdated.txt"
$outputFile = "formatted-outdated.txt"
# Read the content of the input file
$content = Get-Content $inputFile
# Initialize an empty array to store formatted lines and a hash set to track added dependencies
$formattedLines = @()
$uniqueDependencies = New-Object System.Collections.Generic.HashSet[string]
# Use a regex pattern to match and extract dependency lines
$pattern = "^\[INFO\] \s+([^\s:]+):([^\s]+)\s+\.+\s+([^\s]+) -> ([^\s]+)$"
foreach ($line in $content) {
    if ($line -match $pattern) {
        # Extract and format the dependency information
        $dependencyFull = $matches[1] + ":" + $matches[2]
        $currentVersion = $matches[3]
        $latestVersion = $matches[4]
        # Extract the base dependency name (after the colon)
        $dependency = $dependencyFull -replace '^[^:]+:', ''
        # Check if the dependency is already added
        if ($uniqueDependencies.Add($dependency)) {
            # Create a formatted line with spaces separating columns for better alignment
            $formattedLine = "{0,-35} {1,-15} {2,-15}" -f $dependency, $currentVersion, $latestVersion
            $formattedLines += $formattedLine
        }
    }
}
# Add header to the output with more spacing
$header = "{0,-35} {1,-15} {2,-15}" -f "Dependency", "Current Version", "Latest Version"
$formattedLines = $header, $formattedLines
# Write the formatted lines to the output file
$formattedLines | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "Formatted content has been written to $outputFile"
