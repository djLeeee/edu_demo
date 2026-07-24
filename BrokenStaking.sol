// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * Meta Pool mpETH 무상 발행 취약점
 *
 * 실제 프로토콜 코드를 그대로 구현한 것이 아니라,
 * 다음 핵심 원리를 초보자 수준으로 단순화
 *
 * 1. 부모 컨트랙트가 mint() 함수를 제공한다.
 * 2. 자식 컨트랙트가 내부 _deposit() 함수를 수정한다.
 * 3. 수정된 _deposit()이 실제 ETH 입금을 확인하지 않는다.
 * 4. 공격자는 ETH 없이 mint()를 호출해 토큰을 발행한다.
 */

contract BaseVault {
    string public constant name = "Mini Pool ETH";
    string public constant symbol = "mpETH";
    uint8 public constant decimals = 18;

    mapping(address => uint256) public balanceOf;

    uint256 public totalSupply;

    event TokenMinted(
        address indexed caller,
        address indexed receiver,
        uint256 shares,
        uint256 paidETH
    );

    event TokenRedeemed(
        address indexed owner,
        address indexed receiver,
        uint256 shares
    );

    /*
     * 부모 컨트랙트에서 제공하는 mint() 함수
     *
     * 정상적인 컨트랙트라면 요청한 토큰 수량만큼
     * 실제 ETH를 지불해야 합니다.
     *
     * 하지만 자식 컨트랙트가 _deposit()을 잘못 수정하면
     * 이 검사가 사라질 수 있습니다.
     */
    function mint(
        uint256 shares,
        address receiver
    ) external payable virtual returns (uint256 assets) {
        require(shares > 0, "Shares must be greater than zero");
        require(receiver != address(0), "Invalid receiver");

        //  1 mpETH = 1 ETH 단위로 계산합니다.
        assets = shares;

        _deposit(msg.sender, receiver, assets, shares);
    }

    /*
     * 정상적인 내부 입금 처리
     *
     * 실제 받은 ETH와 필요한 ETH가 같은지 확인합니다.
     */
    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) internal virtual {
        require(msg.value == assets, "Incorrect ETH amount");

        _mint(receiver, shares);

        emit TokenMinted(caller, receiver, shares, msg.value);
    }

    function _mint(address receiver, uint256 shares) internal {
        balanceOf[receiver] += shares;
        totalSupply += shares;
    }

    /*
     * 보유한 mpETH를 실제 ETH로 교환합니다.
     *
     * 실습에서는 공격자가 무료로 만든 mpETH를 사용해
     * 컨트랙트에 예치된 ETH를 가져갈 수 있습니다.
     */
    function redeem(
        uint256 shares,
        address payable receiver
    ) external {
        require(shares > 0, "Shares must be greater than zero");
        require(
            balanceOf[msg.sender] >= shares,
            "Not enough mpETH"
        );
        require(
            address(this).balance >= shares,
            "Not enough ETH in pool"
        );

        // 상태를 먼저 변경합니다.
        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;

        // ETH 전송은 마지막에 실행합니다.
        (bool success, ) = receiver.call{value: shares}("");
        require(success, "ETH transfer failed");

        emit TokenRedeemed(msg.sender, receiver, shares);
    }

    function contractETHBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

/*
 * BrokenStaking 컨트랙트
 */
contract BrokenStaking is BaseVault {
    /*
     * 정상적인 ETH 예치 함수
     *
     * 사용자가 보낸 ETH만큼 mpETH를 발행합니다.
     */
    function depositETH(address receiver) external payable {
        require(msg.value > 0, "Send ETH");
        require(receiver != address(0), "Invalid receiver");

        _mint(receiver, msg.value);

        emit TokenMinted(
            msg.sender,
            receiver,
            msg.value,
            msg.value
        );
    }

    /*
     *
     * 부모의 mint()가 이 함수를 호출하지만,
     * 실제 ETH가 들어왔는지 확인하지 않습니다.
     *
     * assets 값과 msg.value를 무시하고
     * 요청받은 shares만 발행합니다.
     */
    function _deposit(
        address caller,
        address receiver,
        uint256,
        uint256 shares
    ) internal override {
        // 취약점: require(msg.value == assets)가 없음
        _mint(receiver, shares);

        emit TokenMinted(
            caller,
            receiver,
            shares,
            msg.value
        );
    }
}

/*
 * SafeStaking 컨트랙트
 */
contract SafeStaking is BaseVault {
    function depositETH(address receiver) external payable {
        require(msg.value > 0, "Send ETH");
        require(receiver != address(0), "Invalid receiver");

        _mint(receiver, msg.value);

        emit TokenMinted(
            msg.sender,
            receiver,
            msg.value,
            msg.value
        );
    }

    /*
     * _deposit()을 잘못 재정의하지 않습니다.
     *
     * 따라서 부모 컨트랙트의 다음 검증이 유지됩니다.
     *
     * require(msg.value == assets)
     */
}
