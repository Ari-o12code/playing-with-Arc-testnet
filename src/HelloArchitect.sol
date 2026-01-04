// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// contract HelloArchitect {
//     string private greeting;

//     // Event emitted when the greeting is changed
//     event GreetingChanged(string newGreeting);

//     // Constructor that sets the initial greeting to "Hello Architect!"
//     constructor() {
//         greeting = "Hello Architect!";
//     }

//     // Setter function to update the greeting
//     function setGreeting(string memory newGreeting) public {
//         greeting = newGreeting;
//         emit GreetingChanged(newGreeting);
//     }

//     // Getter function to return the current greeting
//     function getGreeting() public view returns (string memory) {
//         return greeting;
//     }
// }

// contract HelloArchitectV2 {
//     string private greeting;
//     address public owner;
//     address public lastUpdater;
//     uint256 public updateCount;

//     event GreetingChanged(
//         string newGreeting,
//         address indexed updater,
//         uint256 updateCount
//     );

//     event GreetingReset(address indexed owner);

//     modifier onlyOwner() {
//         require(msg.sender == owner, "Not owner");
//         _;
//     }

//     constructor() {
//         owner = msg.sender;
//         greeting = "Hello Architect!";
//     }

//     function setGreeting(string memory newGreeting) public {
//         greeting = newGreeting;
//         lastUpdater = msg.sender;
//         updateCount++;

//         emit GreetingChanged(newGreeting, msg.sender, updateCount);
//     }

//     function resetGreeting() public onlyOwner {
//         greeting = "Hello Architect!";
//         updateCount = 0;
//         lastUpdater = address(0);

//         emit GreetingReset(msg.sender);
//     }

//     function getGreeting() public view returns (string memory) {
//         return greeting;
//     }
// }

contract HelloArchitectV3 {
    struct Message {
        address author;
        string text;
        uint256 timestamp;
        uint256 likes;
        bool exists;
    }

    address public owner;
    uint256 public messageCount;

    mapping(uint256 => Message) public messages;

    event MessagePosted(
        uint256 indexed id,
        address indexed author,
        string text
    );

    event MessageLiked(
        uint256 indexed id,
        address indexed liker,
        uint256 totalLikes
    );

    event MessageDeleted(uint256 indexed id);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Anyone can post a message
    function postMessage(string calldata text) external {
        messageCount++;

        messages[messageCount] = Message({
            author: msg.sender,
            text: text,
            timestamp: block.timestamp,
            likes: 0,
            exists: true
        });

        emit MessagePosted(messageCount, msg.sender, text);
    }

    // Anyone can like an existing message
    function likeMessage(uint256 id) external {
        require(messages[id].exists, "Message does not exist");

        messages[id].likes++;

        emit MessageLiked(id, msg.sender, messages[id].likes);
    }

    // Owner-only moderation
    function deleteMessage(uint256 id) external onlyOwner {
        require(messages[id].exists, "Message does not exist");

        delete messages[id];

        emit MessageDeleted(id);
    }

    // Helper read function
    function getMessage(
        uint256 id
    )
        external
        view
        returns (
            address author,
            string memory text,
            uint256 timestamp,
            uint256 likes
        )
    {
        require(messages[id].exists, "Message does not exist");

        Message storage m = messages[id];
        return (m.author, m.text, m.timestamp, m.likes);
    }
}
