// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleBank {

    // 사용자별 예금 잔액(wei 단위로 저장)
    mapping(address => uint256) public balances;

    // ETH 입금
    function deposit() public payable {
        require(msg.value > 0, unicode"ETH를 보내야 합니다.");

        balances[msg.sender] += msg.value;
    }

    // 내 잔액 조회(ETH 단위)
    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender] / 1 ether;
    }

    // 은행 전체 잔액 조회(ETH 단위)
    function getBankBalance() public view returns (uint256) {
        return address(this).balance / 1 ether;
    }

    // ETH 단위로 출금
    function withdraw(uint256 ethAmount) public {

        uint256 amount = ethAmount * 1 ether;

        require(
            balances[msg.sender] >= amount,
            unicode"잔액이 부족합니다."
        );

        balances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);
    }
}
