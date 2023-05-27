import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Order "mo:base/Order";

actor class StudentWall() {
  type Message = Type.Message;
  type Content = Type.Content;

  var messageId : Nat = 0;

  func hash(n: Nat) : Hash.Hash {
    return Text.hash(Nat.toText(n));
  };

  var wall = HashMap.HashMap<Nat, Message>(1, Nat.equal, hash);

  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    let newMessageId = messageId;
    messageId += 1;
    let message = {
      vote = 0;
      content = c;
      creator = caller;
    };
    wall.put(newMessageId, message);
    return newMessageId;
  };

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    let message = wall.get(messageId);
    switch message {
      case (?m) {
        return #ok(m);
      };
      case null {
        return #err("not founr");
      };
    };
  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    let message = wall.get(messageId);
    switch message {
      case (?m) {
        if (m.creator != caller) {
          return #err("creator is not same");
        };
        let updatedMessage : Message = {
          vote = m.vote;
          content = c;
          creator = m.creator;
        };
        ignore wall.replace(messageId, updatedMessage);
        return #ok(());
      };
      case null {
        return #err("not founr");
      };
    };
  };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    let message = wall.remove(messageId);
    switch message {
      case (?m) {
        return #ok(());
      };
      case null {
        return #err("not founr");
      };
    };
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
    let message = wall.get(messageId);
    switch message {
      case (?m) {
        let updatedMessage : Message = {
          vote = m.vote + 1;
          content = m.content;
          creator = m.creator;
        };
        ignore wall.replace(messageId, updatedMessage);
        return #ok(());
      };
      case null {
        return #err("not founr");
      };
    };
  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
    let message = wall.get(messageId);
    switch message {
      case (?m) {
        let updatedMessage : Message = {
          vote = m.vote - 1;
          content = m.content;
          creator = m.creator;
        };
        ignore wall.replace(messageId, updatedMessage);
        return #ok(());
      };
      case null {
        return #err("not founr");
      };
    };
  };

  // Get all messages
  public func getAllMessages() : async [Message] {
    var messages = Buffer.Buffer<Message>(0);
    for (m in wall.vals()) {
      messages.add(m);
    };
    return Buffer.toArray<Message>(messages);
  };

  func compare(x : Message, y : Message) : Order.Order {
    if (x.vote < y.vote) {
      return #greater;
    } else if (x.vote == y.vote) {
      return #equal;
    } else {
      return #less;
    };
  };

  // Get all messages ordered by votes
  public func getAllMessagesRanked() : async [Message] {
    var messages = Buffer.Buffer<Message>(0);
    for (m in wall.vals()) {
      messages.add(m);
    };
    messages.sort(compare);
    return Buffer.toArray<Message>(messages);
  };
};
