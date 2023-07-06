// SPDX-License-Identifier: AGPL-3.0-or-later

// Copyright (C) 2023 Morningstar

pragma solidity 0.8.20;

contract TheQuan{

    struct Magic{
        bool    active;
        uint16  kwantized;
        uint168 ignitionFee;
    }

    struct Incantation{
        address angel;
        uint16  charm;
    }

    struct Codex{
        uint16  wave;
        uint64  dawn;
        uint256 halo;
        address mage;
    }

    struct Charge{
        uint80 cast;
        uint80 forge;
        uint80 mint;
    }

    struct MintBooster{
        uint24  ultraBasisPts;
        uint8   boosterCode;
        uint16  expiry;
    }

    struct MintPermit{
        uint256       mintable;
        MintBooster[] boosters;
        uint168[2][]  vesting;
        uint168[2][]  auditing;
    }

    string  public  constant  name     = "The Quan";
    string  public  constant  symbol   = "GLMR";
    string  public  constant  version  = "1";
    uint8   public  constant  decimals = 18;
    bytes32 private constant  EIP712_DOMAIN   = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant  PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bool    private constant  PROXIED  = true;
    uint168 private auditPeriod = 21 days;
    uint168 private allocatedETH;
    uint256 public  totalSupply;
    Charge  private fees = Charge(42000000 gwei, 69000000 gwei, 25000000 gwei);
    mapping(address => uint256)                     public  balanceOf;
    mapping(address => uint256)                     private accountOf;
    mapping(address => mapping(address => uint256)) public  allowance;
    mapping(address => MintPermit)                  private allowList;
    mapping(address => Magic)                       private grimoire;
    mapping(address => bool)                        private wizards;
    mapping(address => bool)                        private deities;
    mapping(address => mapping(uint256 => Codex))   private spells;
    mapping(address => uint256)                     private nonces;
    mapping(bytes4  => Incantation)                 private wand;
    bytes4[]                                        private charms;

    // --- Events ---

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    error BALANCE1();
    error TRANSFER2();
    error TRANSFER3();
    error TRANSFER4();
    error APPROVAL1();
    error APPROVAL2();
    error APPROVAL3();
    error SIGNATURE1();
    error SIGNATURE2();
    error SIGNATURE3();
    error INCANTATION1(bytes4 charm);

    // --- Utilities ---
    
    constructor(address angel, bytes4 charm){
        wizards[msg.sender] = true;
        wand[charm] = Incantation(angel, 0);
        charms.push(charm);
        balanceOf[msg.sender] = 21e24;
        totalSupply += 21e24;
        allowList[msg.sender].vesting.push([uint168(block.timestamp + 420 days), uint168(4e24)]);
    }

    receive() external payable{
        revert TRANSFER2();
    }

    fallback() external payable {
        address angel = wand[msg.sig].angel;

        if(angel == address(0))
            revert INCANTATION1(msg.sig);
        
        assembly{
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), angel, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    // --- ERC20 Functions ---

    function transfer(address recipient, uint256 amount) external returns (bool){
        if(recipient == address(0))
            revert TRANSFER3();

        if(amount > balanceOf[msg.sender])
            revert BALANCE1();

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool){
        if(spender == address(0))
            revert APPROVAL1();

        if(spender == msg.sender)
            revert APPROVAL2();

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s)
        external
    {
        if(owner == address(0))
            revert SIGNATURE1();

        if(deadline < block.timestamp)
            revert SIGNATURE2();

        bytes32 DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN,
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            block.chainid,
            address(this)
        ));

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                nonces[owner],
                deadline
            ))
        ));

        if(owner != ecrecover(digest, v, r, s))
            revert SIGNATURE3();

        ++nonces[owner];
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function transferFrom(address tokensOwner, address recipient, uint256 amount) public returns (bool){
        if(tokensOwner == recipient)
            revert TRANSFER4();

        if(amount > balanceOf[tokensOwner])
            revert BALANCE1();

        if(amount > allowance[tokensOwner][msg.sender])
            revert APPROVAL3();

        allowance[tokensOwner][msg.sender] -= amount;
        balanceOf[tokensOwner] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(tokensOwner, recipient, amount);
        return true;
    }
}