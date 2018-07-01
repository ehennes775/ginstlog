# Manual Configuration

The configuration for ginstlog is stored in a single XML file that is passed in
as a command line argument when ginstlog is invoked. See docs/example.xml for
a complete configuration file.

The following XML shows the configuration for a single  instrument in the
configuration file.

   ```xml
   <OmegaHH309A id="2">
       <Name>Four Channel Thermometer</Name>
       <PollInterval>1000000</PollInterval>
       <ChannelTable>
           <Channel index="0">
               <Name>T1: Ambient</Name>
           </Channel>
           <Channel index="1">
               <Name>T2: Thermocouple</Name>
           </Channel>
           <Channel index="2">
               <Name>T3: Ambient</Name>
           </Channel>
           <Channel index="3">
               <Name>T4: Thermocouple</Name>
           </Channel>
       </ChannelTable>
       <DeviceTable activeId="0">
           <TtySerialDevice id="0">
               <DeviceFile>/dev/ttyUSB2</DeviceFile>
           </TtySerialDevice>
           <TcpSerialServer id="1">
               <Address>192.168.1.25</Address>
               <Port>4000</Port>
           </TcpSerialServer>
       </DeviceTable>
   </OmegaHH309A>
   ```

1. __Set the instrument type.__ Locate the instrument being configured in the
InstrumentTable.xml file inside the src directory.

1. __Edit the name of the instrument.__ The name identifies the instrument in
the GUI.

1. __Set the poll interval.__ The poll interval controls the rate measurements
are made from the instrument. The poll interval is only applicable to
instruments that are polled. Instruments that stream output do not use the
poll interval. The interval is in microseconds.

1. __Edit the channel table.__ The channel table contains user defined metadata
for each channel on the instrument. The number of channels must match the
number of channels on the instrument.

   | Element | Description |
   | --- | --- |
   | Name | A user friendly name for the channel, displayed in the GUI |

1. __Edit the device table.__ The device table contains a list of devices used
to communicate with the instrument. Only one device is active at any given
time. The `activeId` attribute in the `DeviceTable` element specifies the
active device. Any number of devices can be specified in the `DeviceTable`. The
`id` attribute for each device must be unique.

    a. __Edit a TTY serial device.__ A TTY serial device provides communication
    over a serial port.

       | Element | Description |
       | --- | --- |
       | DeviceFile | The device file (e.g. /dev/ttyUSB0) |

    b. __Edit a TCP serial server.__ A TCP serial server provides communication
    over the network to a serial instrument. The baud rate, data bits, parity,
    and stop bits need to be configured on the serial server.

       | Element | Description |
       | --- | --- |
       | Address | The IP address of the serial server |
       | Port | The port number of the process handling the serial I/O |
