@ECHO OFF
SetLocal EnableExtensions EnableDelayedExpansion
For /F "Delims=" %%I In ('WHERE /R . *.%1') Do Set V=!V!%%~I 
echo !V:\=/!