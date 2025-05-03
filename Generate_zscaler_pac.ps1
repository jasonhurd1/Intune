# Define domains/URLs to bypass proxy
$directDomains = (invoke-restmethod -Uri ("https://endpoints.office.com/endpoints/WorldWide?ServiceAreas=MEM`&`clientrequestid=" + ([GUID]::NewGuid()).Guid)) | ?{$_.ServiceArea -eq "MEM" -and $_.urls} | select -unique -ExpandProperty urls

# Hybrid join
$directDomains += "enterpriseregistration.windows.net"
$directDomains += "login.microsoftonline.com"
$directDomains += "device.login.microsoftonline.com"
$directDomains += "autologon.microsoftazuread-sso.com"

# Internet connectivity check
$directDomains += "*.msftconnecttest.com"
$directDomains += "*.msftncsi.com"

# TPM Attestation
$directDomains += "*.microsoftaik.azure.net"

# Autopilot Deployment Services https://learn.microsoft.com/en-us/autopilot/requirements?tabs=networking
$directDomains += "ztd.dds.microsoft.com"
$directDomains += "cs.dds.microsoft.com"

# CRL and OCSP checks
$directDomains += "crl.microsoft.com"
$directDomains += "ocsp.digicert.com"

# SentinelOne usea1-020
$directDomains += "usea1-020.sentinelone.net"

# Start building the PAC file content
$pacContent = @"
function FindProxyForURL(url, host) {
    host = host.toLowerCase();`n
"@

# Add conditions for direct connection
foreach ($domain in $directDomains) {
    $pacContent += "    if (shExpMatch(host,`"$domain`")) { return `"DIRECT`"; }`n"
}

# Default to proxy if no match
$pacContent += "}"

# Save the PAC file
$pacFilePath = "C:\Users\jlhurd\Downloads\Autopilot_Pre-login.pac"
$pacContent | Out-File -FilePath $pacFilePath -Encoding ASCII

Write-Host "PAC file generated successfully at $pacFilePath"