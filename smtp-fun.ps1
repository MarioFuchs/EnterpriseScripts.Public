$RemoteHost="vs061"
$Port=25

function readResponse {
    while ($stream.DataAvailable) {
        $read = $stream.Read($buffer, 0, 1024)
        $Result=$encoding.GetString($buffer, 0, $read)
        $ResultLines=$Result.ToString().Split("`r")

        $Label="RECEIVE: "
        foreach($Line in $ResultLines)
        {
            if($Line -ne "")
            {
            write-host -foregroundcolor cyan ($Label+$Line.Trim())
            $Label="         "
            }
        }
    }
}

function Send-Command {
    Param($Command)
    Write-Host ("SEND   : "+$Command)
                
    $writer.WriteLine($Command)
    $writer.Flush()
    Start-Sleep -m 1000
    readResponse($stream)
}

$socket = new-object System.Net.Sockets.TcpClient($RemoteHost, $Port)

if ($null -eq $socket) { return; }

$stream = $socket.GetStream()
$writer = new-object System.IO.StreamWriter($stream)
$buffer = new-object System.Byte[] 1024
$encoding = new-object System.Text.AsciiEncoding
readResponse($stream)

Send-Command -Command "EHLO"
Send-Command -Command "MAIL FROM:mario.fuchs@egos.co.at"
Send-Command -Command "RCPT TO:test@test.com"
Send-Command -Command "DATA"

Send-Command -Command "Subject:Testsubject `r"
Send-Command -Command "."
Send-Command -Command "QUIT"

readResponse($stream)