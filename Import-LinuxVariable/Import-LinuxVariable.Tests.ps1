$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Import-LinuxVariable" {

    Context "Empty file provided" {

        BeforeEach {

            New-Item -Path TestDrive:\EmptyFile.sh -ItemType File -Force

        }

        AfterEach {

            Remove-Item -Path TestDrive:\EmptyFile.sh -Force

        }

        It "Declared variables are the same" {

            $VariablesBefore = Get-ChildItem -Path env:

            Import-LinuxVariable -Path TestDrive:\EmptyFile.sh

            $VariablesBefore| Should -Be $(Get-ChildItem -Path env:)

        }

        It "Set-Variable cmdlet is not called" {

            Mock -CommandName Set-Variable -MockWith {}

            Assert-MockCalled -CommandName Set-Variable -Exactly 0

        }

    }

}
