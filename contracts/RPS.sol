// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract RPS {
    constructor() payable {}

    enum Hand {
        rock,
        paper,
        scissors
    }

    enum PlayerStatus {
        STATUS_WIN,
        STAUTS_LOSE,
        STATUS_TIE,
        STATUS_PENDING
    }

    enum GameStatus {
        STATUS_NOT_STARTED,
        STATUS_STARTED,
        STATUS_COMPLETE,
        STATUS_ERROR
    }

    struct Player {
        address payable addr;
        uint256 playerBetAmount;
        Hand hand;
        PlayerStatus playerStatus;
    }

    struct Game {
        Player originator;
        Player taker;
        uint256 betAmount;
        GameStatus GameStatus;
    }

    mapping(uint256 => Game) rooms;
    uint256 roomLen = 0;

    modifier isValidHand(Hand _hand) {
        require(
            (_hand == Hand.rock) ||
                (_hand == Hand.paper) ||
                (_hand == Hand.scissors)
        );
        _;
    }

    modifier isPlayer(uint256 roomNum, address sender) {
        require(
            sender == rooms[roomNum].originator.addr ||
                sender == rooms[roomNum].taker.addr
        );
        _;
    }

    function createRoom(Hand _hand)
        public
        payable
        isValidHand(_hand)
        returns (uint256 roomNum)
    {
        rooms[roomLen] = Game({
            betAmount: msg.value,
            GameStatus: GameStatus.STATUS_NOT_STARTED,
            originator: Player({
                hand: _hand,
                addr: payable(msg.sender),
                playerStatus: PlayerStatus.STATUS_PENDING,
                playerBetAmount: msg.value
            }),
            taker: Player({
                hand: Hand.rock,
                addr: payable(msg.sender),
                playerStatus: PlayerStatus.STATUS_PENDING,
                playerBetAmount: 0
            })
        });
        roomNum = roomLen;
        roomLen = roomLen + 1;
    }

    function joinRoom(uint256 roomNum, Hand _hand)
        public
        payable
        isValidHand(_hand)
    {
        rooms[roomNum].taker = Player({
            hand: _hand,
            addr: payable(msg.sender),
            playerStatus: PlayerStatus.STATUS_PENDING,
            playerBetAmount: msg.value
        });
        rooms[roomNum].betAmount = rooms[roomNum].betAmount + msg.value;
        compareHands(roomNum);
    }

    function compareHands(uint256 roomNum) private {
        uint8 originator = uint8(rooms[roomNum].originator.hand);
        uint8 taker = uint8(rooms[roomNum].taker.hand);

        rooms[roomNum].GameStatus = GameStatus.STATUS_STARTED;

        if (taker == originator) {
            rooms[roomNum].originator.playerStatus = PlayerStatus
                .STATUS_PENDING;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_PENDING;
        } else if ((taker + 1) % 3 == originator) {
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_WIN;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STAUTS_LOSE;
        } else if ((taker + 1) % 3 == originator) {
            rooms[roomNum].originator.playerStatus = PlayerStatus.STAUTS_LOSE;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_WIN;
        } else {
            rooms[roomNum].GameStatus = GameStatus.STATUS_ERROR;
        }
    }

    function checkTotalPay(uint256 roomNum)
        public
        view
        returns (uint256 roomNumPay)
    {
        return rooms[roomNum].betAmount;
    }

    function payout(uint256 roomNum)
        public
        payable
        isPlayer(roomNum, msg.sender)
    {
        if (
            rooms[roomNum].originator.playerStatus == PlayerStatus.STATUS_TIE &&
            rooms[roomNum].taker.playerStatus == PlayerStatus.STATUS_TIE
        ) {
            rooms[roomNum].originator.addr.transfer(
                rooms[roomNum].originator.playerBetAmount
            );
            rooms[roomNum].taker.addr.transfer(
                rooms[roomNum].taker.playerBetAmount
            );
        } else {
            if (
                rooms[roomNum].originator.playerStatus ==
                PlayerStatus.STATUS_WIN
            ) {
                rooms[roomNum].originator.addr.transfer(
                    rooms[roomNum].betAmount
                );
            } else if (
                rooms[roomNum].taker.playerStatus == PlayerStatus.STATUS_WIN
            ) {
                rooms[roomNum].taker.addr.transfer(rooms[roomNum].betAmount);
            } else {
                rooms[roomNum].originator.addr.transfer(
                    rooms[roomNum].originator.playerBetAmount
                );
                rooms[roomNum].taker.addr.transfer(
                    rooms[roomNum].taker.playerBetAmount
                );
            }
        }
        rooms[roomNum].GameStatus = GameStatus.STATUS_COMPLETE;
    }
}
