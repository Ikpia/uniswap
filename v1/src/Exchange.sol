// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Exchange {
    address public tokenAddress;

    constructor(address _token) {
        require(
            _token != address(0),
            "The token address cannot be a zero address"
        );
        tokenAddress = _token;
    }

    function addLiquidity(uint256 amount) public payable {
        require(amount > 0, "amount to be transfered must be greater than 0");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
    }

    function getReserve() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getPrice(
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(
            inputReserve > 0 && outputReserve > 0,
            "Both input and output reserve must be greater than 0"
        );

        return (inputReserve / outputReserve);
    }

    function getAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(
            inputReserve > 0 && outputReserve > 0,
            "Both input and output reserve must be greater than 0"
        );
        require(inputAmount > 0, "input amount must be greater than 0");

        return (inputAmount * outputReserve) / (inputAmount / inputReserve);
    }

    function getEthAmount(uint256 _ethSold) public view returns (uint256) {
        require(_ethSold > 0, "eth sold must be greater than 0");
        uint256 tokenReserve = getReserve();
        return getAmount(_ethSold, address(this).balance, tokenReserve);
    }

    function getTokenAmount(uint256 _tokenSold) public view returns (uint256) {
        require(_tokenSold > 0, "eth sold must be greater than 0");
        uint256 tokenReserve = getReserve();
        return getAmount(_tokenSold, tokenReserve, address(this).balance);
    }

    function ethToToken(uint256 _minToken) public payable {
        uint256 tokenReserve = getReserve();

        uint256 tokensBought = getAmount(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );
        require(tokensBought >= _minToken, "Insufficient tokens");
        IERC20(tokenAddress).transfer(msg.sender, tokensBought);
    }

    function tokenToEth(uint256 _token, uint256 _minEth) public {
        uint256 tokenReserve = getReserve();

        uint256 ethBought = getAmount(
            _token,
            tokenReserve,
            address(this).balance
        );

        require(ethBought >= _minEth, "Insufficient eth");

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _token);
        payable(msg.sender).transfer(ethBought);
    }
}
