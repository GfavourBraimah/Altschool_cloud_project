## Command 10 `awk`

## Usage

`awk` A versatile text processing tool for extracting and manipulating data.


## Example 

Let's consider an example using a simple CSV file called data.csv that contains information about students:

data.csv:

Name, Age, Grade
John, 18, A
Emma, 17, B
Michael, 19, A
Sophia, 18, A

awk -F ', ' '$3 == "A" {print $1, $3}' data.csv
 

 ## Output 
 John A
Michael A
Sophia A
