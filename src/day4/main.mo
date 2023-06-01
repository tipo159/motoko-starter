import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Array "mo:base/Array";

import Account "Account";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
import BootcampLocalActor "BootcampLocalActor";

actor class MotoCoin() {
  public type Account = Account.Account;

  var ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);
  var totalNumberOfMOC : Nat = 0;
  var airdropped : Bool = false;

  // Returns the name of the token
  public query func name() : async Text {
    return "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    return totalNumberOfMOC;
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
    let balance = ledger.get(account);
    switch balance {
      case (?b) {
        return b;
      };
      case null {
        return 0;
      };
    };
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {
    let sender_balance = ledger.get(from);
    switch sender_balance {
      case (?sender_b) {
        let reciever_balance = ledger.get(to);
        switch reciever_balance {
          case (?reciever_b) {
            if (sender_b >= amount) {
              let new_ender_b : Nat = sender_b - amount;
              ignore ledger.replace(from, new_ender_b);
              let new_reciever_b : Nat = reciever_b + amount;
              ignore ledger.replace(to, new_reciever_b);
              return #ok(());
            } else {
              return #err("the caller has not enough token");
            };
          };
          case null {
            if (sender_b >= amount) {
              let new_ender_b : Nat = sender_b - amount;
              ignore ledger.replace(from, new_ender_b);
              let new_reciever_b : Nat = amount;
              ledger.put(to, new_reciever_b);
              return #ok(());
            } else {
              return #err("the sender has not enough token");
            };
          };
        };
      };
      case null {
        return #err("invalid from account");
      };
    };
  };

  // Airdrop 100 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
    if (not airdropped) {
      let bootcampActor = await BootcampLocalActor.BootcampLocalActor();
      // let bootcampActor : actor {
      //   getAllStudentsPrincipal : shared () -> async [Principal];
      // } = actor ("rww3b-zqaaa-aaaam-abioa-cai");
      let principals = await bootcampActor.getAllStudentsPrincipal();
      airdropped := true;
      if (Array.size<Principal>(principals) != 0) {
        for (p in principals.vals()) {
          let account : Account = {
            owner = p;
            subaccount = null;
          };
          let balance = ledger.get(account);
          switch balance {
            case (?b) {
              let new_balance = b + 100;
              ignore ledger.replace(account, new_balance);
            };
            case null {
              let new_balance = 100;
              ledger.put(account, new_balance);
            };
          };
          totalNumberOfMOC += 100;
        };
        return #ok(());
      } else {
        return #err("no principal");
      };
    } else {
      return #err("alread airdropped");
    };
  };
};
