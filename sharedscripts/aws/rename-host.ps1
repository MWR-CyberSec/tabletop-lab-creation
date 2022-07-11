param(
    [string] $name = "SomeHostName"
)

if (!$name) {
    $name = "SomeHostName"
}

Rename-Computer -NewName $name 

