[DSCResource()]
class GitCredentials {
    #Path to the repository
    [DscProperty(Key)]
    [String]$URI

    #Credential to save. If saving a Azure Devops Personal Access Token, make the username PersonalAccessToken
    [DscProperty(Mandatory)]
    [PSCredential]$Credential

    #Whether the credential is present
    [DscProperty(NotConfigurable)]
    [Bool]$cmdkeyPresent

    #The formatted cmdkey URI
    [DscProperty(NotConfigurable)]
    [String]$cmdkeyURI

    #The username associated with the system
    [DscProperty(NotConfigurable)]
    [String]$cmdkeyUser

    # Gets the resource's current state.
    [GitCredentials] Get() {
        [URI]$GitRepoURI = $this.URI
        
        $GitUserInfo = if ($GitRepoURI.UserInfo) {$GitRepoURI.UserInfo + '@'}
        $this.cmdKeyURI = 'git:' + $GitRepoURI.scheme + '://' + $GitUserInfo + $GitRepoURI.host + '/' + ($GitRepoURI.segments[1] -replace '/$','')
        $cmdkeyResult = & cmdkey.exe /list $this.cmdkeyURI
        
        #We don't use -notmatch because if cmdkeyResult doesn't return the correct format this will still return true
        $cmdkeyAbsent = $cmdkeyResult -match '\* NONE \*'
        $this.cmdkeyPresent = (!$cmdKeyAbsent)

        if ($this.cmdkeyPresent) {
            $UserLineRegex = '^ +User:'
            $this.cmdkeyUser = ([String]($cmdKeyResult | Where-Object {$_ -match $userLineRegex}) -replace $UserLineRegex,'').trim()
        }
        return $this
    }

    # Sets the desired state of the resource.
    [void] Set() {
        [GitCredentials]$GitCredentials = $this.get()
        $targetName = $GitCredentials.cmdkeyURI
        write-verbose "Adding credentials for target $targetName and user $($this.credential.username)"
        $cmdKeyResult = & cmdkey.exe /generic:$targetName /user:$($this.credential.username) /pass:$($this.credential.GetNetworkCredential().password) 2>&1
        if ($LASTEXITCODE -ne 0) {throw "Cmdkey failed with error $LASTEXITCODE`: $cmdKeyResult"}
    }

    # Tests if the resource is in the desired state.
    [bool] Test() {
        [GitCredentials]$GitCredentials = $this.get()
        return $GitCredentials.cmdkeyPresent
    }
}
