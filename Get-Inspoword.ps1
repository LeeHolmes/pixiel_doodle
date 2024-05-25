$words = "Coffee", "Bed", "Spoon", "Castle", "Knife", "Cat", "Pot", "Dish", "Rainbow", "Sofa", "Stool", "Cup", "Happy", "Pencil", "Tree", "House", "Cow", "Computer", "Water", "Sun", "Night", "Horse", "Drum", "Person", "TV", "Dinosaur", "Lego", "Pencil", "Mask", "Music", "Logo", "Hand", "Heart", "Sport", "Dog", "Mountain", "Emoji", "Camera", "Box", "Ball", "Book", "Camping", "Key", "Leaf", "Boat", "Whale", "Balloon", "Sunset", "Fish", "Island", "Flower", "Airplane", "Apple", "Lightbulb", "Bee", "Teapot", "Umbrella", "Fire", "Mushroom", "Cactus", "Pattern", "Shapes", "Face", "Glasses", "Gift", "Ice Cream", "Rocket", "Instrument", "Spider", "Ninja", "Bird", "Unicorn", "Dolphin", "Car", "Butterfly", "Shoe", "Eye", "Hat", "Bike", "Book", "Key", "Skull", "Clock", "Feather", "Candle", "Spider", "Box", "Tractor", "Space", "Croissant", "Dress", "Hat", "Ball", "Elephant", "Fruit", "TV", "Battery", "Alien", "Shield", "Cake", "Robot"

$header = ""
$wordTargets = ""

$header += "VM_RAND VAR_RANDOMWORD, 0, $($words.Count)`r`n"

for($wordTarget = 0; $wordTarget -lt $words.Count; $wordTarget++)
{
    $currentWord = $words[$wordTarget]
    if($currentWord.Length -gt 14) { Write-Warning "Word too long: $currentWord" }
    $header += "VM_IF_CONST .EQ, VAR_RANDOMWORD, $wordTarget, _WORD_$wordTarget, 0`r`n"
    $wordTargets += "
_WORD_$wordTarget::
VM_LOAD_TEXT 0
.asciz `"\003\003\002$(" " * [Math]::Floor(((14 - $currentWord.Length) / 2)))$currentWord`"
VM_JUMP _END
    "
}

$header
$wordTargets