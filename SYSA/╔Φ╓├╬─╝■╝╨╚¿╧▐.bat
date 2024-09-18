@echo off
cacls manager /t /e /c /g everyone:c
cacls message /t /e /c /g everyone:c
cacls email /t /e /c /g everyone:c
cacls in /t /e /c /g everyone:c
cacls out /t /e /c /g everyone:c
cacls out\mobile /t /e /c /g everyone:c
cacls load /t /e /c /g everyone:c
cacls reply\upload /t /e /c /g everyone:c
cacls document\upload /t /e /c /g everyone:c
cacls moban /t /e /c /g everyone:c
cacls images /t /e /c /g everyone:c
cacls skin\default\images /t /e /c /g everyone:c
cacls skin\default\images\logo /t /e /c /g everyone:c
cacls Edit\upimages /t /e /c /g everyone:c
cacls Edit\upimages\shop /t /e /c /g everyone:c
cacls Edit\upimages\product /t /e /c /g everyone:c
cacls car\load /t /e /c /g everyone:c
cacls hrm\load /t /e /c /g everyone:c
attrib manager\*.* -h -r /s /d
attrib message\*.* -h -r /s /d
attrib email\*.* -h -r /s /d
attrib in\*.* -h -r /s /d
attrib out\*.* -h -r /s /d
attrib out\mobile\*.* -h -r /s /d
attrib load\*.* -h -r /s /d
attrib reply\upload\*.* -h -r /s /d
attrib document\upload\*.* -h -r /s /d
attrib moban\*.*  -h -r /s /d
attrib images\*.* -h -r /s /d
attrib skin\default\images\*.*  -h -r /s /d
attrib skin\default\images\logo\*.*  -h -r /s /d
attrib Edit\upimages\*.*  -h -r /s /d
attrib Edit\upimages\shop\*.*  -h -r /s /d
attrib Edit\upimages\product\*.*  -h -r /s /d
attrib car\load\*.*  -h -r /s /d
attrib hrm\load\*.*  -h -r /s /d
