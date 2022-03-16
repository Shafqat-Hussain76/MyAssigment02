// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract MYERC1155 is ERC1155, ERC1155Burnable  {
    mapping(uint => uint) private _tokensCount;
    bytes32 private constant TOKEN_COST_ROLE = keccak256("TOKEN_COST_ROLE");
    uint private _tokenPrice;
    address owner;
    uint public constant KEY0 = 0;
    uint public constant KEY1 = 1;
    uint public constant KEY2 = 2;
    uint public constant KEY3 = 3;
    uint public constant KEY4 = 4;

    constructor (address _addPriceRole) ERC1155("") {
        //for(uint i; i < 5; i++){
        //    _mint(msg.sender, i, 10, "");
        //    _tokensCount[i] = 10;
        //}
        _mint(msg.sender, KEY0, 10, "");
        _tokensCount[KEY0] = 10;
        _mint(msg.sender, KEY1, 10, "");
        _tokensCount[KEY1] = 10;
        _mint(msg.sender, KEY2, 10, "");
        _tokensCount[KEY2] = 10;
        _mint(msg.sender, KEY3, 10, "");
        _tokensCount[KEY3] = 10;
        _mint(msg.sender, KEY4, 10, "");
        _tokensCount[KEY4] = 10;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(TOKEN_COST_ROLE, _addPriceRole);
        owner = _msgSender();
    }

    function tokenPrice(uint _price) external onlyRole(TOKEN_COST_ROLE){
        _tokenPrice = _price;
    }

    function availableTokens(uint _tokenId) external view returns(uint){
        require(_tokenId >= 0 && _tokenId <= 4, "Not a valid token id");
        return 100 - _tokensCount[_tokenId];
    }

    function tokensMint(uint _tokenId, uint _tokenQuantity) external payable {
        require(_tokenQuantity > 0, "The Quantity should not be zero");
        require(_tokenId >= 0 && _tokenId <= 4, "Not a valid token id");
        require(_tokensCount[_tokenId] <= 100, "Tokens already minted");
        uint tokensPrice = _tokenPrice * _tokenQuantity;
        require(msg.value == tokensPrice, "The token purchase amount is not enough");
        _mint(msg.sender, _tokenId, _tokenQuantity, "");
        _tokensCount[_tokenId] += _tokenQuantity;
    }
    function tokensBurn(address _from, uint _tokenId, uint _amount) external {
        _burn(_from, _tokenId, _amount);
        _tokensCount[_tokenId] -= _amount;// need clarity
    }

    function EthWithdraw() external payable{
        payable(owner).transfer(address(this).balance);
    }
    receive() external payable{}
    
}