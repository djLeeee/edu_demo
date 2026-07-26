// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CampusToken is ERC20 {
    constructor() ERC20("Campus Token", "CAMP") {
        // Campus Token : TokenName
        // CAMP : Token Symbol
        // 컨트랙트를 배포한 계정에 1,000 CAMP 발행
        _mint(msg.sender, 1000);
    }

    // 실습에서는 입력값을 쉽게 확인하기 위해 소수점 자릿수를 0으로 설정
    function decimals() public pure override returns (uint8) {
        return 0;
    }
}
