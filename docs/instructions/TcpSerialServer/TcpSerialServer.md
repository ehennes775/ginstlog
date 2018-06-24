# Setting up an Instrument on a TCP Serial Server

This example connects an Extech SDL200 temperature meter to ginstlog using an
Advantech VESP211-232 serial server.

1. __Configure the serial server.__ Configure the serial server using the
instructions from the manufacturer. These settings will vary depending on the
network configuration and instrument. The key settings for this example follow:

| Item | Value | Notes |
| --- | --- | --- |
| DHCP | OFF | Set to match network configuration |
| IP Address | 192.168.2.30 | Set to match network configuration |
| Protocol | TCP | Set to match ginstlog |
| Mode | Server | Set to match ginstlog |
| Port Number | 4000 | Uses VESP211-232 default |
| Mode | RS-232 | Set to match SDL200 |
| Baud Rate | 9600 | Set to match SDL200 |
| Data Bits | 8 | Set to match SDL200 |
| Stop Bits | 1 | Set to match SDL200 |
| Parity | None | Set to match SDL200 |
| Flow Control | None | Set to match SDL200 |

1. __Check Grounding.__ Ensure current paths will not cause harm to people or
damage equipment.

1. __Connect the instrument.__

1. [optional] __Test the connection.__ The Extech SDL200 continuously
transmits (mostly) printable ASCII data. So, the connection can be tested
with the following steps:

   a. __Check the serial server status LEDs.__ Turn the instrument on. The LEDs
   on the serial server should indicate activity. This step ensures the
   connection from the instrument to the serial server is operational.

   b. __Ensure the network connection is operational.__ Use the following
   command to test the connection between the serial server and the computer.
   The `socat` command will echo the data arriving over the TCP connection to
   the terminal. The output in this example shows channel 4 reading 73.5 &deg;F.

```bash
$ socat - TCP4:192.168.2.30:4000
 34020100000735
```

1. __Edit the instrument configuration.__ In the configuration file, set the
`Address` and `Port` to match the address and port for the serial server. Set
the `activeId` to the `id` of the serial server.

```xml
<DeviceTable activeId="1">
    <SerialDevice id="0">
        <DeviceFile>/dev/ttyUSB3</DeviceFile>
        <Timeout>2000 ms</Timeout>
    </SerialDevice>
    <TcpSerialServer id="1">
        <Address>192.168.2.30</Address>
        <Port>4000</Port>
    </TcpSerialServer>
</DeviceTable>
```

1. __Run the application.__

```bash
$ ./ginstlog configuration.xml
```
