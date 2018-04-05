pragma solidity ^0.4.11;

contract Buffer
{
    event AddEntry(bytes32 start, uint number, string name, bytes32 end);
    event RemoveEntry(bytes32 start, uint number, string name, bytes32 end);
    uint public length; // Must be defined in the constructor
    bytes32 public lastEntry;
    uint public startPoint = uint(keccak256(msg.sender, now, length) % length); //Start point in a circular buffer doesn't matter just needs to be within range
    struct Object {
        bytes32 next;
        uint number;
        string name;
    }
    mapping (bytes32 => Object) objects;
    
    function Buffer(uint _length) public {
        length = _length;
    }

    function addEntry(uint _number,string _name) public returns (bool) {
    Object memory object = Object(lastEntry,_number,_name);
    bytes32 id = keccak256(object.number,object.name,now,length);
    objects[id] = object;
    lastEntry = id;
    length += 1;
    AddEntry(lastEntry,object.number,object.name,object.next);
  }

  function removeEntry(bytes32 _id) public returns (bool) {
    require(length > 0);
    bytes32 current = lastEntry;
    while (current != 0 && current != _id && objects[current].next != _id) {
      current = objects[current].next;
    }
    // Let's not waste gas if the id doesn't exist
    require(current != 0);
    if (current != _id) {
      objects[current].next = objects[_id].next;
    } else {
      lastEntry = objects[_id].next;
    }
    RemoveEntry(lastEntry, objects[_id].number, objects[_id].name, objects[_id].next);
    delete objects[_id];
  }
