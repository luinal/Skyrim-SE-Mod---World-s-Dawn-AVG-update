@echo off
"G:\Miscellaneous\Mods & Games\Tools - Installed\Creation Kit\Papyrus Compiler\PapyrusCompiler.exe" ^
    scripts\source\xtd_config.psc ^
    -f="G:\Games\The Elder Scrolls - Skyrim - Special Edition\Data\Scripts\Source\Scripts\TESV_Papyrus_Flags.flg" ^
    -i="G:\Games\The Elder Scrolls - Skyrim - Special Edition\Data\Scripts\Source\Scripts;scripts\source" ^
    -o="G:\ModOrganizer\Skyrim Special Edition\mods\Worlds Dawn SSE\scripts"

"G:\Miscellaneous\Mods & Games\Tools - Installed\Creation Kit\Papyrus Compiler\PapyrusCompiler.exe" ^
    scripts\source\xtd_attributes.psc ^
    -f="G:\Games\The Elder Scrolls - Skyrim - Special Edition\Data\Scripts\Source\Scripts\TESV_Papyrus_Flags.flg" ^
    -i="G:\Games\The Elder Scrolls - Skyrim - Special Edition\Data\Scripts\Source\Scripts;scripts\source" ^
    -o="G:\ModOrganizer\Skyrim Special Edition\mods\Worlds Dawn SSE\scripts"

pause 