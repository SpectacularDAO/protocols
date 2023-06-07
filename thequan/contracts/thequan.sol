// SPDX-License-Identifier: AGPL-3.0-or-later

// Copyright (C) 2023 Morningstar

pragma solidity 0.8.19;

import "./interfaces/IERC721.sol";

contract TheQuan {

    // --- Token Data Structures ---
    struct Magic{
        bool    status;
        uint168 sparkles;
        uint168 checkInFee;
        uint168 surgeUltraBasisPts;
        uint168 rewardUltraBasisPts;
        uint168 vestingPeriod;
        uint32  circle;
    }

    struct Incantation{
        address angel;
        uint16  charm;
    }

    struct Codex{
        uint168 dawn;
        uint168 glow;
        uint32  wave;
        address mage;
    }

    struct Charge{
        uint168 cast;
        uint168 forge;
        uint168 mint;
    }

    struct MintBooster{
        uint168 ultraBasisPts;
        uint8   boosterCode;
        uint256 expiry;
    }

    struct MintPermit{
        uint256       mintable;
        MintBooster[] boosters;
        uint256[2][]  vesting;
        uint256[2][]  auditing;
    }

    // --- Structured Storage ---
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

    
    // --- Admin Utilities ---
    constructor(address angel, bytes4 charm){
        wizards[msg.sender] = true;
        wand[charm] = Incantation(angel, 0);
        charms.push(charm);
        balanceOf[msg.sender] = 21e24;
        totalSupply += 21e24;
        allowList[msg.sender].vesting[0] = [uint168(block.timestamp + 420 days), uint168(4e24)];

    }
    }

    receive() external payable{
        revert("Only transfer ETH through checkIn(), cast(), forge(), or requestMint().");
    }

    // --- Core Logic ---

        
            }
            }
        }
    }

    // --- ERC20 Functions ---

    function transfer(address recipient, uint256 amount) external returns (bool){
        require(recipient != address(0), 
        "The Quan: can't transfer to 0x0, use burn() instead.");

        require(amount <= balanceOf[msg.sender], 
        "The Quan: insufficient balance.");

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool){
        require(spender != address(0), "The Quan: spender can't be 0x0.");
        require(spender != msg.sender, "The Quan: spender can't be the same as owner.");

        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

     function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s)
        external
    {
        bytes32 digest =
            keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH,
                                     owner,
                                     spender,
                                     value,
                                     nonce,
                                     expiry))
        ));

        require(owner == ecrecover(digest, v, r, s),
        "The Quan: signer isn't owner.");

        require(expiry >= block.timestamp,
        "The Quan: expired signature.");

        require(nonce == nonces[owner]++,
        "The Quan: invalid nonce.");

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function transferFrom(address tokensOwner, address recipient, uint256 amount) public returns (bool){
        require(tokensOwner != recipient, 
        "The Quan: tokens already in destination account.");

        require(amount <= balanceOf[tokensOwner],
        "The Quan: insufficient balance.");

        require(amount <= allowance[tokensOwner][msg.sender],
        "The Quan: transfer exceeds allowance.");

        allowance[tokensOwner][msg.sender] -= amount;

        balanceOf[tokensOwner] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(tokensOwner, recipient, amount);
        return true;
    }

    function mint(address recipient, uint168 amount) external onlyDeities {
        require(amount <= allowList[recipient].mintable, 
        "The Quan: insufficient mintables.");
        
        MintBooster[] memory boosters = allowList[recipient].boosters;
        uint168 boostUltraBasisPts;
        uint168 GLMR;
        
        if( boosters.length > 0){
            for(uint16 i = 0; i < boosters.length; i++){
                if(boosters[i].expiry >= block.timestamp){
                    boostUltraBasisPts += boosters[i].ultraBasisPts;
                }else{
                    if(boosters[i].expiry != 0)
                        delete allowList[recipient].boosters[i];
                }
            }
        }

        if( boostUltraBasisPts > 0)
            GLMR = amount + ((amount * boostUltraBasisPts) / 10**7);
        else
            GLMR = amount;
        
        allowList[recipient].mintable -= amount;
        balanceOf[recipient] += GLMR;
        totalSupply += GLMR;

        emit Minted(recipient, msg.sender, amount, GLMR);
    }

    function burn(uint256 amount) private {
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}