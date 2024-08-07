<#
.NOTES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Module: PSPassPhrase
Function: New-Passphrase
Author: Martin Cooper (@mc1903)
Date: 29-07-2024
GitHub Repo: https://github.com/mc1903/PSpassPhrase
Version: 1.0.3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.SYNOPSIS
Generates one or more passphrases composed of random words, numbers, and optional special characters.

.DESCRIPTION
The New-Passphrase function generates passphrases by selecting a specified number of random words from a word list. These words can be separated by spaces or concatenated together. 

The passphrase may optionally include a random number and a special character at the end. The function allows customisation of the word length, capitalisation, and special characters used.

.PARAMETER passPhraseCount
Specifies the number of passphrases to generate. Default is 1.

.PARAMETER wordsPerpassPhrase
Specifies the number of words to use in each passphrase. Default is 3.

.PARAMETER minWordLength
Specifies the minimum length of words to be included in the passphrase. Default is 5.

.PARAMETER maxWordLength
Specifies the maximum length of words to be included in the passphrase. Default is 8.

.PARAMETER firstCapitalOnly
If specified, only the first letter of the passphrase will be capitalised. Otherwise, the first letter of each word in the passphrase will be capitalised.

.PARAMETER noSpaceBetween
If specified, no spaces will be included between words in the passphrase.

.PARAMETER randomNumberLength
Specifies the length of the random number to append to each passphrase. Default is 3.

.PARAMETER noLastSpecialChar
If specified, no special character will be appended to the end of the passphrase.

.PARAMETER specialCharacterList
Specifies the list of special characters to choose from when appending a special character to the passphrase. Default is a list containing "!", "$", "*", and "&".

.PARAMETER wordListPath
Specifies the path to the word list file to use for generating passphrases. If not specified, a default list will be used.

.EXAMPLE
# Generate a single passphrase with the default settings
New-Passphrase

.EXAMPLE
# Generate 3 passphrases, each composed of 4 words, with a minimum word length of 6 and maximum word length of 10
New-Passphrase -passPhraseCount 3 -wordsPerPassPhrase 4 -minWordLength 6 -maxWordLength 10

.EXAMPLE
# Generate a passphrase with words concatenated together, a 5-digit random number, and no special character at the end
New-Passphrase -noSpaceBetween -randomNumberLength 5 -noLastSpecialChar

#>
Function New-Passphrase {
    [CmdletBinding()]
    Param (
        [int]$passPhraseCount = 1,
        [int]$wordsPerPassPhrase = 3,
        [int]$minWordLength = 5,
        [int]$maxWordLength = 8,
        [switch]$firstCapitalOnly,
        [switch]$noSpaceBetween,
        [int]$randomNumberLength = 3,
        [switch]$noLastSpecialChar,
        [string[]]$specialCharacterList = @("!", "$", "*", "&"),
        [string]$wordListPath
    )

    if ($minWordLength -gt $maxWordLength) {
        throw "The minimum word length ($minWordLength) cannot be greater than the maximum word length ($maxWordLength)"
    }
    
    if (-not $wordListPath) {
        try {
            $modulePath = Get-ModulePath
            $wordListPath = Join-Path -Path $modulePath -ChildPath 'src\private\DefaultWordList.txt'
        }
        catch {
            throw "The default word list could not be found. Please specify the word list location using the -wordListPath parameter."
        }
    }

    if (-not (Test-Path -Path $wordListPath)) {
        throw "Word list file not found at path: $wordListPath"
    }

    Write-Verbose "Loading word list from $($wordListPath)"
    $wordList = Get-Content -Path $wordListPath

    Write-Verbose "The word list contains $($wordList.count) entries"

    Write-Verbose "Filtering word list and selecting only the words between $($minWordLength) and $($maxWordLength) characters"
    $pattern = '^[a-zA-Z]+$'
    $filteredWordList = $wordList | Where-Object { $_ -match $pattern -and $_.Length -ge $minWordLength -and $_.Length -le $maxWordLength }

    $passPhrases = @()
    for ($i = 0; $i -lt $passPhraseCount; $i++) {
        Write-Verbose "Generating passPhrase $($i+1) of $($passPhraseCount)"
        $passPhraseWords = @()
        for ($j = 0; $j -lt $wordsPerPassPhrase; $j++) {
            $random = Get-Random -InputObject $filteredWordList
            $passPhraseWords += $random
        }
    
        $passPhrase = ""
        foreach ($word in $passPhraseWords) {
            if ($firstCapitalOnly) {
                $passPhrase += $word.ToLower()
            }
            else {
                $passPhrase += $word.Substring(0, 1).ToUpper() + $word.Substring(1).ToLower()
            }
            if (!$noSpaceBetween -and $word -ne $passPhraseWords[-1]) {
                $passPhrase += " "
            }
        }

        if ($firstCapitalOnly) {
            $passPhrase = $passPhrase.Substring(0, 1).ToUpper() + $passPhrase.Substring(1)
        }

        if (!$noSpaceBetween) {
            $passPhrase += " "
        }

        $randomNumber = -join ((0..9) | Get-Random -Count $randomNumberLength)
        $passPhrase += $randomNumber

        if (!$noLastSpecialChar) {
            $randomSpecialChar = Get-Random -InputObject $specialCharacterList
            $passPhrase += $randomSpecialChar
        }
        $passPhrases += @{
            Index      = ($i + 1)
            PassPhrase = $passPhrase
        }
    }
    Write-Output "Index PassPhrase"
    Write-Output "----- ----------"
    foreach ($entry in $passPhrases) {
        $formatString = "{0,-5} {1}"
        Write-Output ($formatString -f $entry.Index, $entry.PassPhrase)
    }
}
