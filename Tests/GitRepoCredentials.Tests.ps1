Describe "GitRepoCredentials" {
    $TestGitURI = 'https://gitPesterTest@dev.azure.com/gitPesterTest'
    $TestCred = [PSCredential]::New('fakePersonalAccessToken',(ConvertTo-SecureString 'fakePassword' -AsPlainText -Force))

    #Import the class
    Invoke-Expression (Get-Content -raw $PSSCRIPTROOT/../GitDSC.psm1)

    It "Initializes the Resource" {
        $dscResource = [GitRepoCredentials]::new()
        $dscResource.URI = $TestGitURI
        $dscResource | Should -Not -BeNullOrEmpty
    }
    It "Initially Tests False for Test Key" {
        $dscResource = [GitRepoCredentials]::new()
        $dscResource.uri = $TestGitURI
        $dscResource = $dscResource.get()
        #Delete the test key if already present
        $null = & cmdkey /delete:$($dscresource.cmdkeyURI)
        $dscResource.test() | Should -Be $false
    }
    It "Tests False for random uri" {
        $dscResource = [GitRepoCredentials]::new()
        $dscResource.uri = "https://www.google.com"
        $dscResource.test() | Should -Be $false
    }
    It "Sets the Test Key Correctly" {
        $dscResource = [GitRepoCredentials]::new()
        $dscResource.uri = $TestGitURI
        $dscResource.credential = $testCred
        if ($dscResource.test()) {throw "Problem, the key already exists, it should have been deleted by last step"}
        $dscResource.set()
        $dscResource.test() | Should -Be $true
        #Remove Afterwards
        #$null = & cmdkey /delete:$($dscresource.cmdkeyURI)
    }
}