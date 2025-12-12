# Variables
$interval = 5
$code = 200
$url = "http://localhost:8085/bonita/healthz"
$username = "monitoring"
$password = "mon1tor1ng_adm1n"

function Poll-Status {
    while ($true) {
        $authHeader = ""
        
        # Create the authorization header if username is provided
        if ($username -ne "") {
            $authInfo = "${username}:${password}"
            $authHeader = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($authInfo))
        }

        # Send request and get the status code
        try {
            $response = Invoke-WebRequest -Uri ${url} -Headers @{ Authorization = "Basic $authHeader" } -TimeoutSec 3 -ErrorAction Stop
            $statusCode = $response.StatusCode
        } catch {
            $statusCode = $_.Exception.Response.StatusCode.Value__
        }
        
        # Display the status code with a timestamp
        Write-Output "$(Get-Date -Format "HH:mm:ss"): The status code is $statusCode"

        # Check if the status code matches the expected code
        if ($statusCode -eq ${code}) {
            Write-Output "success"
            exit 0
        }

        # Wait for the specified interval before retrying
        Start-Sleep -Seconds ${interval}
    }
}

# Display polling message
Write-Output "Polling '${url}' every ${interval} seconds, until status is '${code}'"
Poll-Status