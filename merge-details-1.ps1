# Define the path to the input and output files
$inputFile = "licenses_output.txt"
$outputFile = "formatted-licenses.txt"
# Read the content of the input file
$content = Get-Content $inputFile
# Initialize an empty array to store formatted lines
$formattedLines = @()
# Set column widths
$columnWidthDependency = 30
$columnWidthVersion = 15
$columnWidthLicense = 50
# Define a regex pattern to match lines with the expected format
$pattern = "^\s*([\w\.\-]+)\s+(\S+)\s+(.*)$"
# Flag to track if header has been added
$headerAdded = $false
foreach ($line in $content) {
    # Skip lines that are dashes or not in the expected format
    if ($line -match "^-{3,}" -or $line -match "^\s*$") {
        continue
    }
    if ($line -match $pattern) {
        # Extract and format the dependency information
        $dependency = $matches[1]
        $version = $matches[2]
        $license = $matches[3]
        # Create a formatted line with more spacing
        $formattedLine = "{0,-$columnWidthDependency} {1,-$columnWidthVersion} {2,-$columnWidthLicense}" -f $dependency, $version, $license
        $formattedLines += $formattedLine
    }
    elseif (-not $headerAdded -and $line -match "Dependency\s+Version\s+License") {
        # Add the header if not added yet
        $header = "{0,-$columnWidthDependency} {1,-$columnWidthVersion} {2,-$columnWidthLicense}" -f "Dependency", "Version", "License"
        $formattedLines += $header
        $headerAdded = $true
    }
}

# Write the formatted lines to the output file
$formattedLines | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "Formatted licenses content has been written to $outputFile"
