import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:modbus/modbus.dart' as modbus;
import 'package:modbus/modbus.dart';

/// Class for holding information on each modbus device
class MBServer{
  // Modbus parameters
  final String ipAddress;
  final int port;
  final ModbusMode mode;
  // Modbus server
  late final serverID;

  MBServer(this.ipAddress, {this.port=502, this.mode=ModbusMode.rtu, this.serverID=0});

  void updateServerID(int id){
    this.serverID = serverID;
  }
}

/// Class for handling Modbus connections and devices
class MBHandler extends ChangeNotifier{
  // List of Modbus Connections
  final List<_MBConnection> connections = [];

  // Initialize TCP Client Connection
  void createModbusConnection({required MBServer server, required bool readOnly, required int readSize, required int readStartAddress, int writeSize=0, int writeStartAddress=0}){
    ModbusClient client = modbus.createTcpClient(
      server.ipAddress,
      port: server.port,
      mode: server.mode,
      unitId: server.serverID,
    );

    _MBConnection connection = new _MBConnection(
      server: server,
      client: client,
      readOnly: readOnly,
      readSize: readSize,
      readStartAddress: readStartAddress,
      writeSize: writeSize,
      writeStartAddress: writeStartAddress,
    );
    this.connections.add(connection);
  }

  // TODO: TEST ONLY
  void startLoop() {
    Timer.periodic(Duration(milliseconds: 250), (timer) {print("Loop");});
  }

  // Attempt Connections
  void connectAll() async{
    for(_MBConnection c in this.connections){
      c.connect();
    }
  }

  // Perform Read on all connections
  void readAll() {
    for(_MBConnection c in this.connections){
      c.read();
    }
  }

  // Get Data
  List<int> getData(String ipAddress){
    for(_MBConnection c in this.connections){
      if(c.server.ipAddress == ipAddress){
        return c.inputRegisters;
      }
    }
    return []; // TODO: Handle Exceptions
  }

}

/// Class for each Modbus to Client Connection
/// This class holds all read and write parameters, and information on
/// modbus devices that are associated with this connection
class _MBConnection{
  // Modbus Read Parameters
  int readSize;
  int readStartAddress;
  late final List<int> inputRegisters;
  // Modbus Write Parameters
  int writeSize;
  int writeStartAddress;
  late final List<int> outputRegisters;
  // Read-Write Access
  final bool readOnly;
  // Modbus Server and Client
  final MBServer server;
  final ModbusClient client;

  // Constructor
  _MBConnection({required this.server, required this.client, required this.readOnly, required this.readSize, required this.readStartAddress, this.writeSize=0, this.writeStartAddress=0}){
    // Force Write access to nothing if read only mode is passed
    if(readOnly == true) {
      this.writeSize = 0;
      this.writeStartAddress = 0;
    }

    // Initialize output and input registers - 16 bit registers
    this.outputRegisters = new List.filled(writeSize*16, 0);
    this.inputRegisters = new List.filled(readSize*16, 0);
  }

  // Complete Connection
  void connect() async{
    try{
      await this.client.connect();
    }
    catch(e){
      print(e);
    }
  }

  // Read Input Registers
  void read() async {
    Uint16List registers = await client.readInputRegisters(this.readStartAddress, this.readSize);

    // Iterate through registers
    for(int reg in registers){
      // Convert to 16 bit sequence
      List<int> bits = _wordToBits(word: reg);

      print("${bits.toString()} --- ${reg.toString()}");
      // Save data
      for(int i = 0; i < bits.length; i++){
        this.inputRegisters[i] = bits[i];
      }
    }
  }

  // Write Output Registers
  void write() async {
    // TODO
  }

  // Convert word to bits
  List<int> _wordToBits({required int word, bool reversed=false}){
    List<int> bits = List.filled(16, 0);       // Allocation for 16 bit word
    List<int> revBits = List.filled(16, 0);  // Reversed version of bit sequence
    int num = word;       // Integer for modulo looping
    int i = 0;
    // For each iteration, 'num' modulo zero equates to bit assignment
    while(num > 0) {
      revBits[i] = num % 2;
      num = (num~/2).toInt();     // Conversion back to integer after division

      i += 1;
    }
    // Reverse the order of the bit sequence - dependent on server side implementation
    if(reversed == true) bits = new List.from(revBits.reversed);

    bits = revBits;
    return bits;
  }
}
