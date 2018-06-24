# Setting up an Instrument on a TCP Serial Server

1. _Configure the serial server._

1. _Test the connection._

```bash
$ socat - TCP4:192.168.2.30:4000
 34020100000735
```

1. _Edit the instrument configuration._

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
