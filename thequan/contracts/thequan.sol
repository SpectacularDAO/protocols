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
    }



    // --- Token Data ---
    string  public constant name     = "The Quan";
    string  public constant symbol   = "GLMR";
    string  public constant version  = "1";
    uint8   public constant decimals = 18;
    uint168 public castFee     = 42000000 gwei;
    uint168 public forgeFee    = 69000000 gwei;
    uint168 public mintFee     = 25000000 gwei;
    uint168 public auditPeriod = 21 days;
    uint256 public totalSupply;
    uint256 public allocatedETH;
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = 0x5d47d58eeeff0d09d899baa5faca6c0ac32b6bb20a1749ab96e0a0d6cebe514e;

    mapping(address => uint256)                     public balanceOf;
    mapping(address => uint256)                     public accountOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => MintPermit)                  public allowList;
    mapping(address => Magic)                       public grimoire;
    mapping(address => mapping(uint256 => Codex))   public spells;
    mapping(address => bool)                        public deities;
    mapping(address => bool)                        public wizards;
    mapping(address => bool)                        public fairies;
    mapping(address => uint256)                     public nonces;


    // --- Token Events ---
    event DeityExalted(address indexed wizard, address candidate);
    event DeityDeposed(address indexed wizard, address incumbent);
    event WizardInducted(address indexed wizard, address candidate);
    event WizardRevoked(address indexed wizard, address incumbent);
    event FairyCommissioned(address indexed wizard, address candidate);
    event FairyDecommissioned(address indexed wizard, address incumbent);
        uint256[2][]  vesting;
        uint256[2][]  auditing;
    }

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

    event ETHAllocated(
        address indexed wizard,
        address recipient,
        uint256 amount
    );

    event Cast(
        address indexed recipient,
        address indexed asset,
        uint256 fee,
        uint256 mintable
    );

    event Forged(
        address indexed recipient,
        address indexed deity,
        uint256 fee,
        uint256 mintable
    );
    
    event CheckedIn(
        address indexed asset,
        address indexed holder,
        uint256 tokenId,
        uint256 fee
    );

    event Rewarded(
        address indexed recipient,
        uint168 amount
    );

    event Refunded(
        address indexed recipient,
        uint168 amount
    );

    event Withdrawn(
        address indexed recipient,
        uint256 amount
    );

    event Vested(
        address indexed recipient,
        uint168 amount
    );

    event MintRequested(
        address indexed requester,
        uint168 amount,
        uint256 fee
    );

    event RedemptionRequested(
        address indexed requester,
        uint168 dueDate,
        uint168 amount
    );

    event RedemptionCompleted(
        address indexed requester,
        address deity,
        uint168 ETH
    );

    event Minted(
        address indexed recipient,
        address indexed deity,
        uint168 amount,
        uint168 GLMR
    );

    event FeesUpdated(
        address indexed wizard,
        uint168 newCastFee, 
        uint168 newForgeFee, 
        uint168 newMintFee
    );

    event GeneratorCalibrated(
        address indexed asset,
        address indexed wizard,
        bool    status,
        uint168 sparkles,
        uint168 checkInFee,
        uint168 surgeUltraBasisPts,
        uint168 rewardUltraBasisPts,
        uint168 vestingPeriod,
        uint32  circle
    );

    event AuditPeriodSet(
        address indexed wizard,
        uint168 period
    );
    
    // --- Admin Utilities ---
    constructor() {
        wizards[msg.sender] = true;
        balanceOf[msg.sender] =  21e24;
        totalSupply += 21e24;
        allowList[msg.sender].vesting[0] = [uint168(block.timestamp + 420 days), uint168(4e24)];

        DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            block.chainid,
            address(this)
        ));
    }

    modifier onlyDeities{
       require(deities[msg.sender] == true, 
        "The Quan: only dieties can wield this power.");
        _; 
    }

    modifier onlyWizards{
        require(wizards[msg.sender] == true, 
        "The Quan: only wizards can work this magic.");
        _;
    }

    modifier onlyFairies{
        require(fairies[msg.sender] == true, 
        "The Quan: only fairies can grant mintables.");
        _;
    }

    function exalt(address candidate) external onlyWizards {
        require(deities[candidate] != true,
        "The Quan: candidate is already a deity.");
        deities[candidate] = true;
        emit DeityExalted(candidate, msg.sender);
    }

    function depose(address incumbent) external onlyWizards {
        require(deities[incumbent] != false,
        "The Quan: incumbent is not currently exalted.");
        deities[incumbent] = false;
        emit DeityDeposed(incumbent, msg.sender);
    }

    function induct(address candidate) external onlyWizards {
        require(wizards[candidate] != true, 
        "The Quan: candidate is already a wizard.");
        wizards[candidate] = true;
        emit WizardInducted(candidate, msg.sender);
    }

    function revoke(address incumbent) external onlyWizards {
        require(wizards[incumbent] != false, 
        "The Quan: wizard is not currently inducted.");
        wizards[incumbent] = false;
        emit WizardRevoked(incumbent, msg.sender);
    }

    function commission(address candidate) external onlyWizards {
        require(fairies[candidate] != true, 
        "The Quan: fairy already commissioned.");
        fairies[candidate] = true;
        emit FairyCommissioned(candidate, msg.sender);
    }

    function decommission(address incumbent) external onlyWizards {
        require(fairies[incumbent] != false, 
        "The Quan: fairy not currently commissioned.");
        fairies[incumbent] = false;
        emit FairyDecommissioned(incumbent, msg.sender);
    }

    function setAuditPeriod(uint168 newPeriod) external onlyWizards {
        auditPeriod = newPeriod;
        emit AuditPeriodSet(msg.sender, newPeriod);
    }

    function updateFees(
        uint168 newCastFee,
        uint168 newForgeFee,
        uint168 newMintFee)
        external
        onlyWizards {

        if(newCastFee != 0 && newCastFee != castFee)
            castFee = newCastFee;
        
        if(newForgeFee != 0 && newForgeFee != forgeFee)
            forgeFee = newForgeFee;
        
        if(newMintFee != 0 && newMintFee != mintFee)
            mintFee = newMintFee;
        
        emit FeesUpdated(msg.sender, castFee, forgeFee, mintFee);
    }

    function calibrateGenerator(
        address asset,
        bool generatorStatus,
        bool statusSwitch,
        uint168 sparkles,
        uint168 checkInFee,
        uint168 surgeUltraBasisPts,
        uint168 rewardUltraBasisPts,
        uint168 vestingPeriod,
        uint32  circle)
        external
        onlyWizards{

        Magic memory spawner = grimoire[asset];
        Magic memory updated;

        if(statusSwitch)
            grimoire[asset].status = generatorStatus;
        
        if(checkInFee > 0 && checkInFee != spawner.checkInFee)
            grimoire[asset].checkInFee = checkInFee;

        if(sparkles > 0 && sparkles != spawner.sparkles)
            grimoire[asset].sparkles = sparkles;

        if(rewardUltraBasisPts > 0 && rewardUltraBasisPts != spawner.rewardUltraBasisPts)
            grimoire[asset].rewardUltraBasisPts = rewardUltraBasisPts;

        if(surgeUltraBasisPts > 0 && surgeUltraBasisPts != spawner.surgeUltraBasisPts)
            grimoire[asset].surgeUltraBasisPts = surgeUltraBasisPts;

        if(vestingPeriod > 0 && vestingPeriod != spawner.vestingPeriod)
            grimoire[asset].vestingPeriod = vestingPeriod;

        if(circle > 0 && circle != spawner.circle)
            grimoire[asset].circle = circle;

        updated = grimoire[asset];

        emit GeneratorCalibrated(
            asset,
            msg.sender,
            updated.status,
            updated.sparkles,
            updated.checkInFee,
            updated.surgeUltraBasisPts,
            updated.rewardUltraBasisPts,
            updated.vestingPeriod,
            updated.circle
        );
    }

    function allocateETH(address payable recipient, uint168 amount) external onlyWizards {
        uint256 allocated = allocatedETH;
        uint256 allocationQuota = ((address(this).balance + allocated) * 2) / 3;
        require(allocated + amount < allocationQuota,
        "The Quan: cannot violate golden ratio reserves.");

        (bool success,) = recipient.call{value: amount}("");
        require(success, "transfer failed.");
        allocatedETH += amount;
        emit ETHAllocated(msg.sender, recipient, amount);
    }

    receive() external payable{
        revert("Only transfer ETH through checkIn(), cast(), forge(), or requestMint().");
    }

    // --- Core Logic ---

    function checkIn(address asset, uint256[] calldata tokens)external payable returns(uint168, uint168){
        CheckInCache memory checkin;
        checkin.formula = grimoire[asset];
        checkin.fee = checkin.formula.checkInFee * tokens.length;
        require(msg.value >= checkin.fee, 
        "The Quan: submitted insufficient fee.");

        checkin.vesting = allowList[msg.sender].vesting;
        for (uint32 i = 0; i < tokens.length; i++){
            if(IERC721(asset).ownerOf(tokens[i]) == msg.sender){
                spells[asset][tokens[i]].dawn = uint168(block.number);
                spells[asset][tokens[i]].mage = msg.sender;
                emit CheckedIn(asset, msg.sender, tokens[i], checkin.fee);
                checkin.items++;
            }
        }

        if(checkin.items < tokens.length){
            checkin.refund = checkin.formula.checkInFee * (uint168(tokens.length) - checkin.items);
            accountOf[msg.sender] += checkin.refund;
            emit Refunded(msg.sender, checkin.refund);
        }
        
        checkin.reward = (((checkin.formula.checkInFee * checkin.formula.rewardUltraBasisPts) / 10**7) + checkin.formula.checkInFee) * checkin.items;
        checkin.toVest = [checkin.reward , uint168(block.timestamp) + checkin.formula.vestingPeriod];
        grimoire[asset].checkInFee += ((checkin.formula.checkInFee * checkin.formula.surgeUltraBasisPts) / 10**7) * checkin.items;

        for(uint32 i = 0; i < checkin.vesting.length; i++){
            if(checkin.vesting[i][0] == 0){
                checkin.rewarded = true;
                allowList[msg.sender].vesting[i] = checkin.toVest;
                break;
            }
        }

        if(!checkin.rewarded)
            allowList[msg.sender].vesting.push(checkin.toVest);

        emit Rewarded(msg.sender, checkin.toVest[1]);
        return (checkin.items, checkin.toVest[1]);
    }

    function unlockVested()external returns(uint168){
        uint168[2][] memory vesting = allowList[msg.sender].vesting;
        uint168 vested;

        for(uint32 i = 0; i < vesting.length; i++){
            if(vesting[i][0] > 0 && vesting[i][0] < block.timestamp){
                delete allowList[msg.sender].vesting[i];
                allowList[msg.sender].mintable += vesting[i][1];
                vested += vesting[i][1];
            }
        }

        emit Vested(msg.sender, vested);
        return vested;
    }

    function cast(address asset, uint256 NFTID) external payable returns(uint256){
        Magic memory magic = grimoire[asset];
        Codex memory craft = spells[asset][NFTID];
        require(craft.mage == msg.sender,
        "The Quan: can only cast GLMR from NFTs you own.");
        require(msg.value == castFee,
        "The Quan: pay exact fee to cast GLMR.");

        uint256   dawn = craft.dawn;
        uint256  phase = craft.wave > 0 ? craft.wave : magic.circle;
        uint256 lunars = (block.number - dawn) / phase;

        if(lunars > 0){
            uint256 emissions = craft.glow > 0 ? craft.glow : magic.sparkles;
            spells[asset][NFTID].dawn = uint168(block.number - ((block.number - dawn) % phase));
            allowList[msg.sender].mintable += lunars * emissions;

            emit Cast(msg.sender, asset, msg.value, lunars * emissions);
            return lunars * emissions;
        }else {
            revert("Must have at least 1 complete lunar.");
        }
    }

    function forge(address recipient, uint256 mintable) external payable onlyDeities {
        require(msg.value == forgeFee,
        "The Quan: pay exact fee to forge new mintable.");

        allowList[recipient].mintable += mintable;
        emit Forged(recipient, msg.sender, msg.value, mintable);
    }

    function requestMint(uint168 amount) external payable {
        require(msg.value == mintFee,
        "The Quan: pay exact mint fee.");
        
        uint256 mintable = allowList[msg.sender].mintable;
        require(amount <= mintable,
        "The Quan: insufficient mintable balance.");

        emit MintRequested(msg.sender, amount, msg.value);
    }

    function requestRedemption(uint168 amount) external {
        require(amount <= balanceOf[msg.sender],
        "The Quan: insufficient balance.");

        uint256 liquidityScaled = ((address(this).balance + allocatedETH) / 3) * 10**10;
        uint256 redeemableETH = ((liquidityScaled / totalSupply) * amount) / 10**10;
        balanceOf[msg.sender] -= amount;
        burn(amount);
        
        uint168[2] memory redemptionSlip = [uint168(block.timestamp + auditPeriod), uint168(redeemableETH)];
        allowList[msg.sender].auditing.push(redemptionSlip);
        emit RedemptionRequested(msg.sender, redemptionSlip[0], redemptionSlip[1]);
    }

    function fulfillRedemption(address payable recipient, uint16 slipID) external onlyDeities {
        uint168[2] memory redemptionSlip = allowList[recipient].auditing[slipID];
        require(redemptionSlip[0] < block.timestamp,
        "The Quan: this redemption is still being audited.");

        (bool success, ) = recipient.call{value: redemptionSlip[1]}("");
        require(success,
        "The Quan: transfer failed");

        emit RedemptionCompleted(recipient, msg.sender, redemptionSlip[1]);
    }

    function withdraw(uint256 amount) external {
        require(amount <= accountOf[msg.sender],
        "The Quan: insufficient ETH balance.");

        accountOf[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success,
        "The Quan: transfer failed.");

        emit Withdrawn(msg.sender, amount);
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