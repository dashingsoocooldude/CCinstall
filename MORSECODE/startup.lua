MorseCodeConverter = {}
MorseCodeConverter.__index = MorseCodeConverter
– Define a table to store the mapping of characters to Morse code.
local morseCodeTable = {
    [“A”] = “.-“,
    [“B”] = “-…”,
    [“C”] = “-.-.”,
    [“D”] = “-..”,
    [“E”] = “.”,
    [“F”] = “..-.”,
    [“G”] = “–.”,
    [“H”] = “....”,
    [“I”] = “..”,
    [“J”] = “.—“,
    [“K”] = “-.-“,
    [“L”] = “.-..”,
    [“M”] = “–“,
    [“N”] = “-.”,
    [“O”] = “—“,
    [“P”] = “.–.”,
    [“Q”] = “–.-“,
    [“R”] = “.-.”,
    [“S”] = “…”,
    [“T”] = “-“,
    [“U”] = “..-“,
    [“V”] = “…-“,
    [“W”] = “.–“,
    [“X”] = “-..-“,
    [“Y”] = “-.–“,
    [“Z”] = “–..”,
    [“0”] = “-----“,
    [“1”] = “.----“,
    [“2”] = “..—“,
    [“3”] = “…–“,
    [“4”] = “....-“,
    [“5”] = “.....”,
    [“6”] = “-....”,
    [“7”] = “–…”,
    [“8”] = “—..”,
    [“9”] = “----.”,
    [” “] = ” “
}
– This function converts a given text to Morse code.
– @param text: The text to be converted.
– @return: Returns the Morse code representation of the text.
function MorseCodeConverter.convertToMorseCode(text)
    local morseCode = “”
    for i = 1, #text do
        local char = string.upper(string.sub(text, i, i))
        local code = morseCodeTable[char]
        if code then
            morseCode = morseCode .. code .. ” “
        end
    end
    return morseCode
end
– Example usage of the MorseCodeConverter class
– Usage Example: Convert a text to Morse code
local text = “HELLO WORLD”
local morseCode = MorseCodeConverter.convertToMorseCode(text)
print(“Morse code for "” .. text .. “":”)
print(morseCode)
