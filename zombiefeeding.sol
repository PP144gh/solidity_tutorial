pragma solidity >=0.5.0 <0.6.0;

// import ZombieFeeding
import "./zombiefactory.sol";


/*
INTERACTING WITH OTHER CONTRACTS
For our contract to talk to another contract on the blockchain that we don't own, first we need to define an interface.

Let's look at a simple example. Say there was a contract on the blockchain that looked like this:

contract LuckyNumber {
  mapping(address => uint) numbers;

  function setNum(uint _num) public {
    numbers[msg.sender] = _num;
  }

  function getNum(address _myAddress) public view returns (uint) {
    return numbers[_myAddress];
  }
}
This would be a simple contract where anyone could store their lucky number, and it will be associated with their Ethereum address. Then anyone else could look up that person's lucky number using their address.

Now let's say we had an external contract that wanted to read the data in this contract using the getNum function.

First we'd have to define an interface of the LuckyNumber contract:

contract NumberInterface {
  function getNum(address _myAddress) public view returns (uint);
}
Notice that this looks like defining a contract, with a few differences. For one, we're only declaring the functions we want to interact with — in this case getNum — and we don't mention any of the other functions or state variables.

Secondly, we're not defining the function bodies. Instead of curly braces ({ and }), we're simply ending the function declaration with a semi-colon (;).

So it kind of looks like a contract skeleton. This is how the compiler knows it's an interface.



*/

//full function from cryptoKitties contract
/*
function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
) {
    Kitty storage kit = kitties[_id];

    // if this variable is 0 then it's not gestating
    isGestating = (kit.siringWithId != 0);
    isReady = (kit.cooldownEndBlock <= block.number);
    cooldownIndex = uint256(kit.cooldownIndex);
    nextActionAt = uint256(kit.cooldownEndBlock);
    siringWithId = uint256(kit.siringWithId);
    birthTime = uint256(kit.birthTime);
    matronId = uint256(kit.matronId);
    sireId = uint256(kit.sireId);
    generation = uint256(kit.generation);
    genes = kit.genes;
}


*/

contract KittyInterface {
    function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
);
}

/*


This getKitty function is the first example we've seen that returns multiple values. Let's look at how to handle them:

function multipleReturns() internal returns(uint a, uint b, uint c) {
  return (1, 2, 3);
}

function processMultipleReturns() external {
  uint a;
  uint b;
  uint c;
  // This is how you do multiple assignment:
  (a, b, c) = multipleReturns();
}

// Or if we only cared about one of the values:
function getLastReturnValue() external {
  uint c;
  // We can just leave the other fields blank:
  (,,c) = multipleReturns();
}

*/


//ZombieFeeding inherits ZombieFactory's public functions
contract ZombieFeeding is ZombieFactory {

    //storage vs memory: memory = temporary(RAM-like), storage = blockchain (HD-like)
    //state variables (declared outside of functions) are by def storage

    /* EXAMPLE:

    contract SandwichFactory {
  struct Sandwich {
    string name;
    string status;
  }

  Sandwich[] sandwiches;

  function eatSandwich(uint _index) public {
    // Sandwich mySandwich = sandwiches[_index];

    // ^ Seems pretty straightforward, but solidity will give you a warning
    // telling you that you should explicitly declare `storage` or `memory` here.

    // So instead, you should declare with the `storage` keyword, like:
    Sandwich storage mySandwich = sandwiches[_index];
    // ...in which case `mySandwich` is a pointer to `sandwiches[_index]`
    // in storage, and...
    mySandwich.status = "Eaten!";
    // ...this will permanently change `sandwiches[_index]` on the blockchain.

    // If you just want a copy, you can use `memory`:
    Sandwich memory anotherSandwich = sandwiches[_index + 1];
    // ...in which case `anotherSandwich` will simply be a copy of the
    // data in memory, and...
    anotherSandwich.status = "Eaten!";
    // ...will just modify the temporary variable and have no effect
    // on `sandwiches[_index + 1]`. But you can do this:
    sandwiches[_index + 1] = anotherSandwich;
    // ...if you want to copy the changes back into blockchain storage.
  }
}
*/

//These changes are needed to change the address of the ckitties contract if something happens to it and we can't use it anymore.
//note the obvious vulnerability: setKittyContractAddress is external hence can only be called outside this contract and BY ANYONE. Some kind of ownership of this contract will have to be introduced.

/*
Below is the Ownable contract taken from the OpenZeppelin Solidity library. OpenZeppelin is a library of secure and community-vetted smart contracts that you can use in your own DApps. After this lesson, we highly recommend you check out their site to further your learning!

Give the contract below a read-through. You're going to see a few things we haven't learned yet, but don't worry, we'll talk about them afterward.


 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".

contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
  
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

   * @return the address of the owner.

  function owner() public view returns(address) {
    return _owner;
  }

   * @dev Throws if called by any account other than the owner.

  modifier onlyOwner() {
    require(isOwner());
    _;
  }

   * @return true if `msg.sender` is the owner of the contract.

  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }


   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }


   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
 
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }


   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
A few new things here we haven't seen before:

Constructors: constructor() is a constructor, which is an optional special function. It will get executed only one time, when the contract is first created.
Function Modifiers: modifier onlyOwner(). Modifiers are kind of half-functions that are used to modify other functions, usually to check some requirements prior to execution. In this case, onlyOwner can be used to limit access so only the owner of the contract can run this function. We'll talk more about function modifiers in the next chapter, and what that weird _; does.
indexed keyword: don't worry about this one, we don't need it yet.
So the Ownable contract basically does the following:

When a contract is created, its constructor sets the owner to msg.sender (the person who deployed it)

It adds an onlyOwner modifier, which can restrict access to certain functions to only the owner

It allows you to transfer the contract to a new owner

onlyOwner is such a common requirement for contracts that most Solidity DApps start with a copy/paste of this Ownable contract, and then their first contract inherits from it.

Since we want to limit setKittyContractAddress to onlyOwner, we're going to do the same for our contract.


*/



 // 1. Remove this:
  //address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  // 2. Change this to just a declaration:
  KittyInterface kittyContract;

/*
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }


Notice the onlyOwner modifier on the renounceOwnership function. When you call renounceOwnership, the code inside onlyOwner executes first. Then when it hits the _; statement in onlyOwner, it goes back and executes the code inside renounceOwnership.

So while there are other ways you can use modifiers, one of the most common use-cases is to add a quick require check before a function executes.

In the case of onlyOwner, adding this modifier to a function makes it so only the owner of the contract (you, if you deployed it) can call that function.

Note: Giving the owner special powers over the contract like this is often necessary, but it could also be used maliciously. For example, the owner could add a backdoor function that would allow him to transfer anyone's zombies to himself!

So it's important to remember that just because a DApp is on Ethereum does not automatically mean it's decentralized — you have to actually read the full source code to make sure it's free of special controls by the owner that you need to potentially worry about. There's a careful balance as a developer between maintaining control over a DApp such that you can fix potential bugs, and building an owner-less platform that your users can trust to secure their data.


*/


  // 3. Add setKittyContractAddress method here
  function setKittyContractAddress (address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) public {
    require(msg.sender == zombieToOwner[_zombieId]); //comparing hexadecimal numbers, eth address start with 0x and then have a hexadecimal number. 0x is a way to tell programs that is is a hexadecimal number
    Zombie storage myZombie = zombies[_zombieId];
    // start here
     _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2 ;
     if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
        newDna = newDna - newDna % 100 + 99; // 543 %10 gives 3, 543 %100 gives 43, nr of zeros of quotient = last # of digits of number. this changes last two digits to 99
        
    }




    _createZombie("NoName", newDna); //private? change to internal
    // In addition to public and private, Solidity has two more types of visibility for functions: internal and external.
    //internal is the same as private, except that it's also accessible to contracts that inherit from this contract. (Hey, that sounds like what we want here!).
    //external is similar to public, except that these functions can ONLY be called outside the contract — they can't be called by other functions inside that contract. We'll talk about why you might want to use external vs public later.
      
}


  function feedOnKitty (uint _zombieId, uint _kittyId) public {
      uint kittyDna; // uint = uint256
    (,,,,,,,,,kittyDna)=kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId,kittyDna, "kitty");





}

}