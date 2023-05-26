import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";

import Type "Types";

actor class Homework() {
  type Homework = Type.Homework;

  var HomeworkDiary = Buffer.Buffer<Homework>(0);

  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    HomeworkDiary.add(homework);
    return HomeworkDiary.size() - 1;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    if (id < HomeworkDiary.size()) {
      return #ok(HomeworkDiary.get(id));
    } else {
      return #err("not found");
    }
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    if (id < HomeworkDiary.size()) {
      HomeworkDiary.put(id, homework);
      return #ok(());
    } else {
      return #err("not found");
    }
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    if (id < HomeworkDiary.size()) {
      let old_homework = HomeworkDiary.get(id);
      let new_homework = {
        title = old_homework.title;
        description = old_homework.description;
        dueDate = old_homework.dueDate;
        completed = true;
      };
      HomeworkDiary.put(id, new_homework);
      return #ok(());
    } else {
      return #err("not found");
    }
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    if (id < HomeworkDiary.size()) {
      let homework = HomeworkDiary.remove(id);
      return #ok(());
    } else {
      return #err("not found");
    }
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    return Buffer.toArray<Homework>(HomeworkDiary);
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
    var filteredHomeworkDiary = Buffer.mapFilter<Homework, Homework>(HomeworkDiary, func (homework) {
      if (homework.completed == false) {
        ?homework;
      } else {
        null;
      }
    });
    return Buffer.toArray(filteredHomeworkDiary);
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    var foundHomework = Buffer.Buffer<Homework>(0);
    for (homework in HomeworkDiary.vals()) {
      if (Text.contains(homework.title, #text searchTerm)) {
        foundHomework.add(homework);
      } else if (Text.contains(homework.description, #text searchTerm)) {
        foundHomework.add(homework);
      }
    };
    return Buffer.toArray(foundHomework);
  };
};
