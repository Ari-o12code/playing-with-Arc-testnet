// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// import "forge-std/Test.sol";
// import "../src/HelloArchitect.sol";

// contract HelloArchitectTest is Test {
//     HelloArchitect helloArchitect;

//     function setUp() public {
//         helloArchitect = new HelloArchitect();
//     }

//     function testInitialGreeting() public view {
//         string memory expected = "Hello Architect!";
//         string memory actual = helloArchitect.getGreeting();
//         assertEq(actual, expected);
//     }

//     function testSetGreeting() public {
//         string memory newGreeting = "Welcome to Arc Chain!";
//         helloArchitect.setGreeting(newGreeting);
//         string memory actual = helloArchitect.getGreeting();
//         assertEq(actual, newGreeting);
//     }

//     function testGreetingChangedEvent() public {
//         string memory newGreeting = "Building on Arc!";

//         // Expect the GreetingChanged event to be emitted
//         vm.expectEmit(true, true, true, true);
//         emit HelloArchitect.GreetingChanged(newGreeting);

//         helloArchitect.setGreeting(newGreeting);
//     }
// }

// import "forge-std/Test.sol";
// import "../src/HelloArchitect.sol";

// contract HelloArchitectV2Test is Test {
//     HelloArchitectV2 hello;

//     address user = address(0x1);

//     function setUp() public {
//         hello = new HelloArchitectV2();
//     }

//     function testInitialState() public view {
//         assertEq(hello.getGreeting(), "Hello Architect!");
//         assertEq(hello.updateCount(), 0);
//         assertEq(hello.lastUpdater(), address(0));
//         assertEq(hello.owner(), address(this));
//     }

//     function testSetGreetingUpdatesState() public {
//         vm.prank(user);
//         hello.setGreeting("Welcome to Arc!");

//         assertEq(hello.getGreeting(), "Welcome to Arc!");
//         assertEq(hello.updateCount(), 1);
//         assertEq(hello.lastUpdater(), user);
//     }

//     function testGreetingChangedEvent() public {
//         vm.prank(user);

//         vm.expectEmit(true, true, true, true);
//         emit HelloArchitectV2.GreetingChanged("Building on Arc", user, 1);

//         hello.setGreeting("Building on Arc");
//     }

//     function testOnlyOwnerCanReset() public {
//         vm.prank(user);
//         vm.expectRevert("Not owner");
//         hello.resetGreeting();
//     }

//     function testOwnerCanReset() public {
//         hello.setGreeting("Temporary Message");

//         hello.resetGreeting();

//         assertEq(hello.getGreeting(), "Hello Architect!");
//         assertEq(hello.updateCount(), 0);
//         assertEq(hello.lastUpdater(), address(0));
//     }
// }

import "forge-std/Test.sol";
import "../src/HelloArchitect.sol";

contract HelloArchitectV3Test is Test {
    HelloArchitectV3 board;

    address owner = address(this);
    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        board = new HelloArchitectV3();
    }

    /*//////////////////////////////////////////////////////////////
                            DEPLOYMENT
    //////////////////////////////////////////////////////////////*/

    function testOwnerIsDeployer() public view {
        assertEq(board.owner(), owner);
    }

    function testInitialMessageCountIsZero() public view {
        assertEq(board.messageCount(), 0);
    }

    /*//////////////////////////////////////////////////////////////
                          POST MESSAGE
    //////////////////////////////////////////////////////////////*/

    function testPostMessage() public {
        vm.prank(alice);
        board.postMessage("Hello Arc");

        assertEq(board.messageCount(), 1);

        (
            address author,
            string memory text,
            uint256 timestamp,
            uint256 likes
        ) = board.getMessage(1);

        assertEq(author, alice);
        assertEq(text, "Hello Arc");
        assertEq(likes, 0);
        assertGt(timestamp, 0);
    }

    function testPostMessageEmitsEvent() public {
        vm.prank(alice);

        vm.expectEmit(true, true, true, true);
        emit HelloArchitectV3.MessagePosted(1, alice, "First post");

        board.postMessage("First post");
    }

    /*//////////////////////////////////////////////////////////////
                           LIKE MESSAGE
    //////////////////////////////////////////////////////////////*/

    function testLikeMessage() public {
        vm.prank(alice);
        board.postMessage("Like me");

        vm.prank(bob);
        board.likeMessage(1);

        (, , , uint256 likes) = board.getMessage(1);
        assertEq(likes, 1);
    }

    function testLikeMessageEmitsEvent() public {
        vm.prank(alice);
        board.postMessage("Like event");

        vm.prank(bob);
        vm.expectEmit(true, true, true, true);
        emit HelloArchitectV3.MessageLiked(1, bob, 1);

        board.likeMessage(1);
    }

    function testLikeNonExistentMessageReverts() public {
        vm.prank(alice);
        vm.expectRevert("Message does not exist");
        board.likeMessage(999);
    }

    /*//////////////////////////////////////////////////////////////
                          DELETE MESSAGE
    //////////////////////////////////////////////////////////////*/

    function testOwnerCanDeleteMessage() public {
        vm.prank(alice);
        board.postMessage("To be deleted");

        board.deleteMessage(1);

        vm.expectRevert("Message does not exist");
        board.getMessage(1);
    }

    function testNonOwnerCannotDeleteMessage() public {
        vm.prank(alice);
        board.postMessage("Protected");

        vm.prank(bob);
        vm.expectRevert("Not owner");
        board.deleteMessage(1);
    }

    function testDeleteNonExistentMessageReverts() public {
        vm.expectRevert("Message does not exist");
        board.deleteMessage(1);
    }

    /*//////////////////////////////////////////////////////////////
                        MESSAGE IDS BEHAVIOR
    //////////////////////////////////////////////////////////////*/

    function testMessageIdsIncrement() public {
        vm.prank(alice);
        board.postMessage("One");

        vm.prank(bob);
        board.postMessage("Two");

        assertEq(board.messageCount(), 2);

        (, string memory text1, , ) = board.getMessage(1);
        (, string memory text2, , ) = board.getMessage(2);

        assertEq(text1, "One");
        assertEq(text2, "Two");
    }
}
