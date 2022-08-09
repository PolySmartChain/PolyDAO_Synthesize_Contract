// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token//ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interface/IPloyDaoPRC20.sol";

contract PolyDaoMinter is Ownable {

    using SafeMath for uint256;

    struct assetsInfo {
        uint256 lockTime;
        uint256 releaseTime;
        uint256 tge;
    }
	
	
	

    struct unitPscPriceInfo {
        uint256 unitPscPrice;
        uint256 unitOnePscPrice;
        uint256 unitOneWdcPrice;
    }

    mapping(uint256 => uint256) public jetValid;

    mapping(uint256 => unitPscPriceInfo) public kindUnitPscPriceInfo;

    mapping(uint256 => uint256) public kindAmount;

    mapping(uint256 => uint256) public totalMintAmount;

    mapping(uint256 => assetsInfo) public kindAssetsInfo;

    uint256 public ONE_PSC = 1 ether;

    bool public disabled = true;

    address payable public pscPayAddr;

    address public wdcPayAddr;

    address public WDCPRC20 = 0x4B262D34D7defb4D5B1f9A1A8C3Ee695122351b2;
//    address public WDCPRC20 = 0x101D4507E0c07Aa929EF4Fd1eabcB7bcAef5e391;

    address public jetAddr = 0xC04cb528Ef1c182d053e84bf1705C9E2b2a3deAf;

    address public polyDaoAddr;

    constructor(address payable _addr, address _polyDaoAddr) {
        transferOwnership(_addr);
        pscPayAddr = _addr;
        wdcPayAddr = _addr;
        polyDaoAddr = _polyDaoAddr;
    }

    function setKindUnitPscPriceInfo(uint256 kind, uint256 _unitPscPrice, uint256 _unitOnePscPrice, uint256 _unitOneWdcPrice) external onlyOwner {
        kindUnitPscPriceInfo[kind].unitPscPrice = _unitPscPrice;
        kindUnitPscPriceInfo[kind].unitOnePscPrice = _unitOnePscPrice;
        kindUnitPscPriceInfo[kind].unitOneWdcPrice = _unitOneWdcPrice;
    }

    function setDisabled(bool b) external onlyOwner {
        disabled = b;
    }

    function setKindAmount(uint256 kind, uint256 amount) external onlyOwner {
        kindAmount[kind] = amount;
    }

    function setKindAssetsInfo(uint256 kind, uint256 lockTime, uint256 releaseTime, uint256 tge) external onlyOwner {
        kindAssetsInfo[kind].lockTime = lockTime;
        kindAssetsInfo[kind].releaseTime = releaseTime;
        kindAssetsInfo[kind].tge = tge;
    }

    function setPscPayAddr(address payable _addr) external onlyOwner {
        pscPayAddr = _addr;
    }

    function setWdcPayAddr(address _addr) external onlyOwner {
        wdcPayAddr = _addr;
    }

    function mix(uint256 tokenId, uint256 wdcPrice, uint256 pscPrice, uint256 mintMultiple, uint256 mintKind) external payable {
        require(!disabled, "DISABLED");
        require(msg.value == pscPrice, "PSC PRICE");
        require(IERC721(jetAddr).ownerOf(tokenId) == msg.sender, "NOT JET OWNER");
        require(jetValid[tokenId] != 1, "JET IS VALID");
        require(0 < mintMultiple && mintMultiple < 21, "MINT MULTIPLE");
        require(kindAmount[mintKind] >= mintMultiple, "MINT AMOUNT EXCEED");
        require(kindUnitPscPriceInfo[mintKind].unitPscPrice > 0 && kindUnitPscPriceInfo[mintKind].unitOnePscPrice > 0 && kindUnitPscPriceInfo[mintKind].unitOneWdcPrice > 0, "PRICE ERROR");
        if(wdcPrice == 0){
            require(pscPrice == mintMultiple.mul(kindUnitPscPriceInfo[mintKind].unitPscPrice), "PSC PRICE ERROR");
        }else{
            require(pscPrice == mintMultiple.mul(kindUnitPscPriceInfo[mintKind].unitOnePscPrice), "PSC ONE PRICE ERROR");
            require(wdcPrice == mintMultiple.mul(kindUnitPscPriceInfo[mintKind].unitOneWdcPrice), "WDC ONE PRICE ERROR");
            IERC20(WDCPRC20).transferFrom(msg.sender, wdcPayAddr, wdcPrice);
        }
        Address.sendValue(pscPayAddr, pscPrice);
        IPloyDaoPRC20(polyDaoAddr).mint(mintMultiple.mul(ONE_PSC).div(4), kindAssetsInfo[mintKind].lockTime, kindAssetsInfo[mintKind].releaseTime, kindAssetsInfo[mintKind].tge, msg.sender);
        kindAmount[mintKind] = kindAmount[mintKind].sub(mintMultiple);
        totalMintAmount[mintKind] = totalMintAmount[mintKind].add(mintMultiple);
        jetValid[tokenId] = 1;
    }
}

contract RePolyDaoMinter is Ownable {

    PolyDaoMinter p;

    using SafeMath for uint256;

    struct assetsInfo {
        uint256 lockTime;
        uint256 releaseTime;
        uint256 tge;
    }

    struct unitPscPriceInfo {
        uint256 unitPscPrice;
        uint256 unitOnePscPrice;
        uint256 unitOneWdcPrice;
    }

    mapping(uint256 => uint256) public jetValid;

    mapping(uint256 => unitPscPriceInfo) public kindUnitPscPriceInfo;

    mapping(uint256 => uint256) public kindAmount;

    mapping(uint256 => uint256) public totalMintAmount;

    mapping(uint256 => assetsInfo) public kindAssetsInfo;

    uint256 public ONE_PSC = 1 ether;

    bool public disabled = true;

    address payable public pscPayAddr;

    address public wdcPayAddr;

    address public WDCPRC20 = 0x4B262D34D7defb4D5B1f9A1A8C3Ee695122351b2;
    //    address public WDCPRC20 = 0x101D4507E0c07Aa929EF4Fd1eabcB7bcAef5e391;

    address public jetAddr = 0xC04cb528Ef1c182d053e84bf1705C9E2b2a3deAf;

    address public polyDaoAddr;

    constructor(address payable _addr, address _polyDaoAddr, address _p) {
        p = PolyDaoMinter(_p);
        transferOwnership(_addr);
        pscPayAddr = _addr;
        wdcPayAddr = _addr;
        polyDaoAddr = _polyDaoAddr;
        for (uint256 i = 1; i < 4; i++){
            (kindUnitPscPriceInfo[i].unitPscPrice, kindUnitPscPriceInfo[i].unitOnePscPrice, kindUnitPscPriceInfo[i].unitOneWdcPrice) = p.kindUnitPscPriceInfo(i);
            kindUnitPscPriceInfo[i].unitOneWdcPrice = 10 ** 10 * kindUnitPscPriceInfo[i].unitOneWdcPrice;
            kindAmount[i] = p.kindAmount(i);
            totalMintAmount[i] = p.totalMintAmount(i);
            (kindAssetsInfo[i].lockTime, kindAssetsInfo[i].releaseTime, kindAssetsInfo[i].tge)  = p.kindAssetsInfo(i);
        }
    }

    function setKindUnitPscPriceInfo(uint256 kind, uint256 _unitPscPrice, uint256 _unitOnePscPrice, uint256 _unitOneWdcPrice) external onlyOwner {
        kindUnitPscPriceInfo[kind].unitPscPrice = _unitPscPrice;
        kindUnitPscPriceInfo[kind].unitOnePscPrice = _unitOnePscPrice;
        kindUnitPscPriceInfo[kind].unitOneWdcPrice = _unitOneWdcPrice;
    }

    function setDisabled(bool b) external onlyOwner {
        disabled = b;
    }

    function setKindAmount(uint256 kind, uint256 amount) external onlyOwner {
        kindAmount[kind] = amount;
    }

    function setKindAssetsInfo(uint256 kind, uint256 lockTime, uint256 releaseTime, uint256 tge) external onlyOwner {
        kindAssetsInfo[kind].lockTime = lockTime;
        kindAssetsInfo[kind].releaseTime = releaseTime;
        kindAssetsInfo[kind].tge = tge;
    }

    function setPscPayAddr(address payable _addr) external onlyOwner {
        pscPayAddr = _addr;
    }

    function setWdcPayAddr(address _addr) external onlyOwner {
        wdcPayAddr = _addr;
    }

    function setWDCPRC20(address _addr) external onlyOwner {
        WDCPRC20 = _addr;
    }

    function setJetAddr(address _addr) external onlyOwner {
        jetAddr = _addr;
    }

    function isJetAddrValid(uint256 tokenId) public view returns (bool) {
        return (jetValid[tokenId] != 1 && p.jetValid(tokenId) != 1);
    }

    function mix(uint256 tokenId, uint256 wdcPrice, uint256 pscPrice, uint256 mintMultiple, uint256 mintKind) external payable {
        require(!disabled, "DISABLED");
        require(msg.value == pscPrice, "PSC PRICE");
        require(IERC721(jetAddr).ownerOf(tokenId) == msg.sender, "NOT JET OWNER");
        require(jetValid[tokenId] != 1 && p.jetValid(tokenId) != 1, "JET IS VALID");
        require(0 < mintMultiple && mintMultiple < 21, "MINT MULTIPLE");
        require(kindAmount[mintKind] >= mintMultiple, "MINT AMOUNT EXCEED");
        require(kindUnitPscPriceInfo[mintKind].unitPscPrice > 0 && kindUnitPscPriceInfo[mintKind].unitOnePscPrice > 0 && kindUnitPscPriceInfo[mintKind].unitOneWdcPrice > 0, "PRICE ERROR");
        if(wdcPrice == 0){
            require(pscPrice == mintMultiple.mul(kindUnitPscPriceInfo[mintKind].unitPscPrice), "PSC PRICE ERROR");
        }else{
            require(pscPrice == mintMultiple.mul(kindUnitPscPriceInfo[mintKind].unitOnePscPrice), "PSC ONE PRICE ERROR");
            require(wdcPrice == mintMultiple.mul(kindUnitPscPriceInfo[mintKind].unitOneWdcPrice), "WDC ONE PRICE ERROR");
            IERC20(WDCPRC20).transferFrom(msg.sender, wdcPayAddr, wdcPrice);
        }
        Address.sendValue(pscPayAddr, pscPrice);
        IPloyDaoPRC20(polyDaoAddr).mint(mintMultiple.mul(ONE_PSC).div(4), kindAssetsInfo[mintKind].lockTime, kindAssetsInfo[mintKind].releaseTime, kindAssetsInfo[mintKind].tge, msg.sender);
        kindAmount[mintKind] = kindAmount[mintKind].sub(mintMultiple);
        totalMintAmount[mintKind] = totalMintAmount[mintKind].add(mintMultiple);
        jetValid[tokenId] = 1;
    }

}