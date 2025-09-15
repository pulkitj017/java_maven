$xmlFilePath = "target/generated-resources/licenses/licenses.xml"
$outputFilePath = "licenses_output.txt"
try {
    $xml = [xml](Get-Content $xmlFilePath)
    $results = @()
    $uniqueDependencies = New-Object System.Collections.Generic.HashSet[string]
    foreach ($dependency in $xml.licenseSummary.dependencies.dependency) {
        $dependencyName = $dependency.artifactId
        $dependencyVersion = $dependency.version
        $licenseNames = @($dependency.licenses.license.name)
        # Combine multiple license names into a single string
        $licenseName = $licenseNames -join ', '
        # Create a unique key for each dependency based on name and version
        $dependencyKey = "${dependencyName}:${dependencyVersion}"
        # Check if the dependency has already been added
        if ($uniqueDependencies.Add($dependencyKey)) {
            $result = [PSCustomObject]@{
                Dependency = $dependencyName
                Version = $dependencyVersion
                License = $licenseName
            }
            $results += $result
        }
    }
    if ($results.Count -gt 0) {
        $results | Format-Table -AutoSize | Out-File -FilePath $outputFilePath -Encoding UTF8
        Write-Host "Output saved to: $outputFilePath"
    } else {
        Write-Host "No dependency information found in the XML."
    }
} catch {
    Write-Host "Error occurred: $_"
}
