// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleBank {
    // 컨트랙트 배포자의 주소를 저장하는 상태 변수
    address public owner;

    // 배포할 때 한 번만 실행
    constructor() {
        owner = msg.sender;
    }

    // 호출할 때 ETH를 함께 전송할 수 있는 함수
    function deposit() public payable {
        // payable 함수이므로 별도 코드가 없어도 ETH를 받을 수 있음
    }

    // 현재 컨트랙트가 보유한 ETH 잔액 조회
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
