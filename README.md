# Policy Number Reader
Kin has just recently purchased an ingenious machine to assist in reading policy
report documents. The machine scans the paper documents for policy numbers,
and produces a file with a number of entries which each look like this:

   _  _     _  _  _   _  _
 | _| _||_||_ |_   | |_||_|
 ||_  _|  | _||_|  | |_| _|
Each entry is 4 lines long, and each line has 27 characters. The first 3 lines of each
entry contain a policy number written using pipes and underscores, and the fourth
line is blank. Each policy number should have 9 digits, all of which should be in the
range 0-9. A normal file contains around 500 entries.

## How to run
1. Ensure [Ruby](https://www.ruby-lang.org/en/documentation/installation/) is installed and can be ran via CLI. I used the Windows 11 built in Ubuntu instance to install and run Ruby.

2. Provide your own text file that includes the policy number typed out in 7-segment display format. An exmaple file was provided under `policy.txt`

3. Run the following command, passing in your policy number file as the first argument.

`$ ruby read_policy_number.rb policy.txt`

Replacing policy.txt with your policy file.

## How User Story 1 Works
My first thought when I saw 7-segment displays was how was I going to efficiently store and parse this data. The trick was to read linearly while also reading vertically. So I split it into segments of 3, and then grabbed the first 3 rows of info at a time and stored that data.

My next problem was figuring out how to identify the numbers. I've done many binary mappings in the past, but this required me to use 3 different symbols to identify each number. I mapped out:
` ` - 0
`_` - 1
`|` - 2

Effectively creating a trinary mapping system. From there, I converted each number into 3 rows of trinary, which gave me a way to map the numbers into easily identifiable maps. Then I determined the uniqueness of each mapped number and did a case statement for it.

I think if I had more time to make it more efficient, I would hard-code the trinary values for each number, and then do an AND gate across the input numbers so that the one number that would match would be the one that drops out. This would be slightly more efficient and way less coding for specifics since the AND would be only a few lines, and the data would be managed on the hard-coded matrix.
