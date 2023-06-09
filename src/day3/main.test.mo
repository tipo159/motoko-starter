import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import MoSpec "mo:mospec/MoSpec";

import Main "main";
import Type "Types";

let day3Actor = await Main.StudentWall();

let assertTrue = MoSpec.assertTrue;
let describe = MoSpec.describe;
let context = MoSpec.context;
let before = MoSpec.before;
let it = MoSpec.it;
let skip = MoSpec.skip;
let pending = MoSpec.pending;
let run = MoSpec.run;

let contentTest : Type.Content = #Text("Test");

let success = run([
  describe(
    "#writeMessage",
    [
      it(
        "should write message on Student Wall",
        do {
          let id = await day3Actor.writeMessage(contentTest);
          assertTrue(id == 0);
        },
      ),
    ],
  ),
  describe(
    "#getMessage",
    [
      it(
        "should get message from id",
        do {
          let response = await day3Actor.getMessage(0);
          switch (response) {
            case (#ok(message)) {
              assertTrue(message.content == contentTest);
            };
            case (#err(message)) {
              Debug.trap(message);
            };
          };
        },
      ),
      it(
        "should return an error message, if the messageId is invalid",
        do {
          let response = await day3Actor.getMessage(1);
          switch (response) {
            case (#ok(message)) {
              Debug.trap("");
            };
            case (#err(message)) {
              assertTrue(true);
            };
          };
        },
      ),
    ],
  ),
  describe(
    "#updateMessage",
    [
      it(
        "should update message based on an Id",
        do {
          let newContent : Type.Content = #Text("Test2");
          let response = await day3Actor.updateMessage(0, newContent);
          switch (response) {
            case (#ok) {
              true;
            };
            case (#err(message)) {
              Debug.trap(message);
            };
          };
        },
      ),
      it(
        "should return an error message, if the messageId is invalid",
        do {
          let newContent : Type.Content = #Text("Test2");
          let response = await day3Actor.updateMessage(1, newContent);
          switch (response) {
            case (#ok(message)) {
              Debug.trap("");
            };
            case (#err(message)) {
              assertTrue(true);
            };
          };
        },
      ),
    ],
  ),
  describe(
    "#deleteMessage",
    [
      it(
        "should delete an existent Message",
        do {
          let response = await day3Actor.deleteMessage(0);
          switch (response) {
            case (#ok) {
              true;
            };
            case (#err(message)) {
              Debug.trap(message);
            };
          };
        },
      ),
      it(
        "should return an error message, if the messageId is invalid",
        do {
          let response = await day3Actor.deleteMessage(1);
          switch (response) {
            case (#ok(message)) {
              Debug.trap("");
            };
            case (#err(message)) {
              assertTrue(true);
            };
          };
        },
      ),
    ],
  ),
  describe(
    "#upVote",
    [
      it(
        "should increment vote by 1",
        do {
          let id = await day3Actor.writeMessage(contentTest);
          let response = await day3Actor.upVote(id);
          switch (response) {
            case (#ok) {
              let response = await day3Actor.getMessage(id);
              switch (response) {
                case (#ok(message)) {
                  assertTrue(message.vote == 1);
                };
                case (#err(message)) {
                  Debug.trap(message);
                };
              };
            };
            case (#err(message)) {
              Debug.trap(message);
            };
          };
        },
      ),
      it(
        "should return an error message, if the messageId is invalid",
        do {
          let response = await day3Actor.upVote(0);
          switch (response) {
            case (#ok(message)) {
              Debug.trap("");
            };
            case (#err(message)) {
              assertTrue(true);
            };
          };
        },
      ),
    ],
  ),
  describe(
    "#downVote",
    [
      it(
        "should decrement vote by 1",
        do {
          let response = await day3Actor.downVote(1);
          switch (response) {
            case (#ok) {
              let response = await day3Actor.getMessage(1);
              switch (response) {
                case (#ok(message)) {
                  assertTrue(message.vote == 0);
                };
                case (#err(message)) {
                  Debug.trap(message);
                };
              };
            };
            case (#err(message)) {
              Debug.trap(message);
            };
          };
        },
      ),
      it(
        "should return an error message, if the messageId is invalid",
        do {
          let response = await day3Actor.downVote(0);
          switch (response) {
            case (#ok(message)) {
              Debug.trap("");
            };
            case (#err(message)) {
              assertTrue(true);
            };
          };
        },
      ),
    ],
  ),
  describe(
    "#getAllMessages",
    [
      it(
        "should get all messages on Student Wall",
        do {
          ignore await day3Actor.writeMessage(contentTest);
          let messages = await day3Actor.getAllMessages();
          assertTrue(messages.size() == 2);
        },
      ),
    ],
  ),
  describe(
    "#getAllMessagesRanked",
    [
      it(
        "should get all messages on Student Wall, ordered by the number of votes in descending order",
        do {
          let id = await day3Actor.writeMessage(contentTest);
          ignore await day3Actor.upVote(id);
          ignore await day3Actor.upVote(id);
          ignore await day3Actor.upVote(2);
          let messages = await day3Actor.getAllMessagesRanked();
          assertTrue(
            messages.size() == 3 and messages[0].vote == 2 and messages[1].vote == 1 and messages[2].vote == 0
          );
        },
      ),
    ],
  ),
]);

if (success == false) {
  Debug.trap("Tests failed");
};
