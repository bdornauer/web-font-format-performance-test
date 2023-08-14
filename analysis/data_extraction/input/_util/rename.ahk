Loop, Files, %A_WorkingDir%\*.json(1), F
{
    filePath := A_LoopFileFullPath
    fileName := A_LoopFileName

    newName := RegExReplace(fileName, "(\.json)\(1\)$", "(1)$1")

    FileMove, %filePath%, %A_WorkingDir%\%newName%
}
Loop, Files, %A_WorkingDir%\*.json(2), F
{
    filePath := A_LoopFileFullPath
    fileName := A_LoopFileName

    newName := RegExReplace(fileName, "(\.json)\(2\)$", "(2)$1")

    FileMove, %filePath%, %A_WorkingDir%\%newName%
}