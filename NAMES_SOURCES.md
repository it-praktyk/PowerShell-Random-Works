# The sources for the culture files

## Info for the culture files Contributors

### The file structure
The list of the required fields in the culture files
- FemaleLastName
- MaleLastName
- FemaleFirstName
- MaleFirstName
- FemaleLastNameNationalChars
- MaleLastNameNationalChars
- FemaleFirstNameNationalChars
- MaleFirstNameNationalChars

The culture files need to be comma delimited csv files, with "" as a text delimiter.

### The charsets encoding
The cultures files need to be saved/encoded as UTF8.

### Language specific grammar form for female/male last names
In Polish - as you can check in a culture subfolder - we are different last name forms for males and females so if in your language is the same situation please fill columns with correct forms.

### Striping "non English" chars
If in your languages are some "non English" chars please put two versions - correct in your language and 'stripped'. A strip operation you can perform using the scripts posted as a comments to the post http://www.powershellmagazine.com/2014/08/26/pstip-replacing-special-characters/ .

### The reference file
For the reference please check the file https://raw.githubusercontent.com/it-praktyk/New-RandomPerson/master/cultures/pl-PL.csv

### Tips
"My" list I've prepared based on googled data, next I've copied it to LibreOffice Calc - I'm not sure if Microsoft Excel can save csv as UTF8.

### Please include
In comments for submitted files.
- add the source of names
- your name and email address
- information if I can include you as a contributor

 Please contribute by sending me a file via email or via GitHub pull request (prefered way).

# Thank you in advance!

## Contributed files

### en-US

The last names taken the first 100 on the state 2016-01-15  
http://names.mongabay.com/data/1000.html

The first names taken the first 100 for dacade 1981-1990 on the state 2016-01-15
http://www.behindthename.com/top/lists/united-states-decade/1980/100

Contributed by: Wojciech Sciesinski wojciech[at]sciesinski[dot]net  
Contribution date: 2106-01-15

### pl-PL

The last names taken the first 100 on the state 2016-01-16  
http://www.expressilustrowany.pl/artykul/3631584,oto-najpopularniejsze-nazwiska-w-polsce,id,t.html

The first names taken the first 100 for new born in the year 2005  
http://gorny.edu.pl/imiona/index.php?rok=2005

Contributed by: Wojciech Sciesinski wojciech[at]sciesinski[dot]  
Contribution date: 2106-01-16
