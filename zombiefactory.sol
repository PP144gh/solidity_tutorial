pragma solidity >=0.5.0 <0.6.0;
//pragma solidity 0.8.17;

import "./ownable.sol";

contract ZombieFactory is Ownable{

    event NewZombie(uint zombieId, string name, uint dna);


    uint dnaDigits = 16;
       

    // uint x = 5 ** 2; // equal to 5^2 = 25
    // Division: x / y
    //Modulus / remainder: x % y (for example, 13 % 5 is 3, because if you divide 5 into 13, 3 is the remainder)

    uint dnaModulus =10**dnaDigits;

    /* TIME UNITS
The variable now will return the current unix timestamp of the latest block (the number of seconds that have passed since January 1st 1970). The unix time as I write this is 1515527488.
Solidity also contains the time units seconds, minutes, hours, days, weeks and years. These will convert to a uint of the number of seconds in that length of time. So 1 minutes is 60, 1 hours is 3600 (60 seconds x 60 minutes), 1 days is 86400 (24 hours x 60 minutes x 60 seconds), etc.

Here's an example of how these time units can be useful:

uint lastUpdated;

// Set `lastUpdated` to `now`
function updateTimestamp() public {
  lastUpdated = now;
}

// Will return `true` if 5 minutes have passed since `updateTimestamp` was 
// called, `false` if 5 minutes have not passed
function fiveMinutesHavePassed() public view returns (bool) {
  return (now >= (lastUpdated + 5 minutes));
}




    */

    //struct
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
    }

    // Array with a fixed length of 2 elements:
    // uint[2] fixedArray;
    // another fixed Array, can contain 5 strings:
    // string[5] stringArray;
    // a dynamic Array - has no fixed size, can keep growing:
    // uint[] dynamicArray;

    //Zombie[] zombie; // dynamic Array, we can keep adding to it

    Zombie[] public zombies; //You can declare an array as public, and Solidity will automatically create a getter method for it.
    mapping (uint => address) public zombieToOwner; //key is uint and value is address, address that owns zombie #id
    mapping (address => uint) ownerZombieCount; //how many zombies a user has

    /*
    function eatHamburgers(string memory _name, uint _amount) public { }

    This is a function named eatHamburgers that takes 2 parameters: a string and a uint. For now the body of the function is empty. Note that we're specifying the function visibility as public. We're also providing instructions about where the _name variable should be stored- in memory. This is required for all reference types such as arrays, structs, mappings, and strings.

What is a reference type you ask?

Well, there are two ways in which you can pass an argument to a Solidity function:

By value, which means that the Solidity compiler creates a new copy of the parameter's value and passes it to your function. This allows your function to modify the value without worrying that the value of the initial parameter gets changed.
By reference, which means that your function is called with a... reference to the original variable. Thus, if your function changes the value of the variable it receives, the value of the original variable gets changed.

It's convention (but not required) to start function parameter variable names with an underscore (_) in order to differentiate them from global variables. We'll use that convention throughout our tutorial.


Call this function like: eatHamburgers("vitalik", 100);

    */

    // memory _name because we want to pass it by value, so it can be changed without changing the initial value of the parameter
    /*
    function createZombie(string memory _name, uint _dna) public {
        zombies.push(Zombie(_name, _dna));
    }
    */

    // .push adds an object to an array
    // this function is public and This means anyone (or any other contract) can call your contract's function and execute its code.
    // a private function means only other functions within our contract will be able to call this function and add to the numbers array.

   function _createZombie(string memory _name, uint _dna) internal {
        //zombies.push(Zombie(_name, _dna));
        // and fire it here
        uint id = zombies.push(Zombie(_name, _dna)) - 1; //zombies.push() returns a uint of the new length of the array while adding the argument to the array zombies.
        //In Solidity, there are certain global variables that are available to all functions. One of these is msg.sender, which refers to the address of the person (or smart contract) who called the current function.
        zombieToOwner[id] = msg.sender; //atribute ownership of zombie #id to address=msg.sender
        ownerZombieCount[msg.sender]++; //increase zombie count in address=msg.sender
        emit NewZombie(id, _name, _dna);
    }
    //convention to start private functions name with _ 

   /*
    To return a value from a function, the declaration looks like this:

string greeting = "What's up dog";

function sayHello() public returns (string memory) {
  return greeting;
}

*/
// This function would be a view function because it doesnt change the state, only reads.

//function sayHello() public view returns (string memory) { return greeting;}
/*

function _multiply(uint a, uint b) private pure returns (uint) {
  return a * b;
}
This function doesn't even read from the state of the app — its return value depends only on its function parameters. So in this case we would declare the function as pure.
*/
  function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus; 
        //rand is a uint with possibly many digits. the remainder of the integer division by 10^16 is a number with necessarily 16 or less digits (we can always count 0 on the left and state that it always has 16 digits)
        // example
        // 543 div 10^1 = 54 and 543 % 10^1 = 3
        //3 has 1 digit, if it had 2 it would be integer divisible by 10^1 (10) and the division wouldn't be complete
        //the remainder of a integer division always has one less digit than the divisor
        //extra note: this gives last 16 digits of rand
    }
    //keccak256 is a version of SHA3, generates a 256-bit hexadecimal number from an input



  function createRandomZombie(string memory _name) public {
    require(ownerZombieCount[msg.sender]==0); //only runs the rest if ownerzombiecount is zero. for strings use keccak256(abi.encodePacked(_str)), solidity has no native string comparer
    uint randDna = _generateRandomDna(_name);
    _createZombie(_name, randDna);
  }






/* SAVING GAS VIA STRUCT PACKING


Struct packing to save gas
In Lesson 1, we mentioned that there are other types of uints: uint8, uint16, uint32, etc.

Normally there's no benefit to using these sub-types because Solidity reserves 256 bits of storage regardless of the uint size. For example, using uint8 instead of uint (uint256) won't save you any gas.

But there's an exception to this: inside structs.

If you have multiple uints inside a struct, using a smaller-sized uint when possible will allow Solidity to pack these variables together to take up less storage. For example:

struct NormalStruct {
  uint a;
  uint b;
  uint c;
}

struct MiniMe {
  uint32 a;
  uint32 b;
  uint c;
}

// `mini` will cost less gas than `normal` because of struct packing
NormalStruct normal = NormalStruct(10, 20, 30);
MiniMe mini = MiniMe(10, 20, 30); 
For this reason, inside a struct you'll want to use the smallest integer sub-types you can get away with.

You'll also want to cluster identical data types together (i.e. put them next to each other in the struct) so that Solidity can minimize the required storage space. For example, a struct with fields uint c; uint32 a; uint32 b; will cost less gas than a struct with fields uint32 a; uint c; uint32 b; because the uint32 fields are clustered together.



*/


}
