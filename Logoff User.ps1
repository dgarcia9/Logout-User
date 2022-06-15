param ($five9Username, $five9UserPass, $logoutUsername)
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

Function GetFive9Username {
        $title = 'Admin/Supervisor Username'
        $msg = 'Your Admin or Supervisor username:'

        $loginUserName = [Microsoft.VisualBasic.Interaction]::Inputbox($msg, $title)

        return $loginUserName
    }

Function GetFive9Password {
        $title = 'Admin/Supervisor Username'
        $msg = 'Your Admin or Supervisor password:'

        $loginUserPass = [Microsoft.VisualBasic.Interaction]::Inputbox($msg, $title)

        return $loginUserPass
    }


Function GetUser {
    $title = 'User to logout'
    $msg = 'Username to logout:'

    $logoutUsername = [Microsoft.VisualBasic.Interaction]::Inputbox($msg, $title)

    return $logoutUsername
}

Function Login {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $loginUserName,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $loginUserPass
        )

    
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")

    $jsonBase = @{}
    $array = @{}
    $data = @{"username"=$loginUserName;"password"=$loginUserPass;}
    $jsonBase.Add("passwordCredentials",$data)
    $jsonBase.Add("policy","AttachExisting")
    $jsonBase.Add("appKey","web-ui")
    $body = $jsonBase | ConvertTo-Json

    $response = Invoke-RestMethod 'https://app-atl.five9.com:443/appsvcs/rs/svc/auth/login' -Method 'POST' -Headers $headers -Body $body    
    $userId = $response.userId
    $tokenId = $response.tokenId
    $farmId = $response.context.farmId
    $orgId = $response.orgId


    return $userId, $tokenId, $farmId, $orgId
}

Function CheckState {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $userId,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $tokenId,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $farmId
        )


    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("farmId", $farmId)
    $headers.Add("Authorization", "Bearer " + $tokenId)

    $response = Invoke-RestMethod ('https://app-atl.five9.com:443/supsvcs/rs/svc/supervisors/' + $userId + '/login_state') -Method 'GET' -Headers $headers

    return $response


}

Function StartSession {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $userId,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $tokenId,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $farmId
        )


    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("farmId", $farmId)
    $headers.Add("Authorization", "Bearer " + $tokenId)

    $body = "{`"stationId`":`"`",`"stationType`":`"EMPTY`"}"

    $response = Invoke-RestMethod 'https://app-atl.five9.com:443/supsvcs/rs/svc/supervisors/3780696/session_start?force=true' -Method 'PUT' -Headers $headers -Body $body

    $response


}

Function GetUsers {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $userId,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $tokenId,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $farmId
        )


    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("farmId", $farmId)
    $headers.Add("Authorization", "Bearer " + $tokenId)

    $response = Invoke-RestMethod ('https://app-atl.five9.com:443/supsvcs/rs/svc/orgs/132943/user_sessions/') -Method 'GET' -Headers $headers

    return $response


}

Function GetUsers {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $orgId,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $tokenId,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $farmId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $logoutUsername
        )


    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")
    $headers.Add("farmId", $farmId)
    $headers.Add("Authorization", "Bearer " + $tokenId)

    $response = Invoke-RestMethod ('https://app-atl.five9.com:443/supsvcs/rs/svc/orgs/' + $orgId + '/user_sessions') -Method 'GET' -Headers $headers

    $userFound = $false
    $response | ForEach-Object {
        if ($_.userName -eq $logoutUsername) {
            $sessionId = $_.sessionId
            LogoutUser ($orgId) ($tokenId) ($farmId) ($sessionId) ($logoutUsername)
            $userFound = $true
        }
    }

    if (-Not $userFound) {
        Write-Host $logoutUsername " was not found logged in"
    }
}

Function LogoutUser {
[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $orgId,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $tokenId,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $farmId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $sessionId,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $logoutUsername
        )

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("farmId", $farmId)
        $headers.Add("Authorization", "Bearer " + $tokenId)        

        $response = Invoke-RestMethod ('https://app-atl.five9.com:443/supsvcs/rs/svc/orgs/' + $orgId + '/user_sessions/' + $sessionId + '/logout') -Method 'PUT' -Headers $headers
         
        Write-Host "Logged out user:" $logoutUsername
}

Function Logout {
[CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $tokenId
        )

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")        
        $headers.Add("Authorization", "Bearer " + $tokenId)

        $sessionId

        $response = Invoke-RestMethod ('https://app-atl.five9.com:443/supsvcs/rs/svc/auth/logout') -Method 'POST' -Headers $headers

        $response
}

if (!$five9Username) {
    $five9Username = GetFive9Username
}

if (!$five9UserPass) {
    $five9UserPass = GetFive9Password
}


if (!$logoutUsername) {
    $logoutUsername = GetUser
}

$userId, $tokenId, $farmId, $orgId = Login ($five9Username) ($five9UserPass)


$state = CheckState ($userId) ($tokenId) ($farmId)

if ($state -ne "WORKING") {
    StartSession ($userId) ($tokenId) ($farmId)
    $state = CheckState ($userId) ($tokenId) ($farmId)
}

GetUsers ($orgId) ($tokenId) ($farmId) ($logoutUsername)

Logout ($tokenId)