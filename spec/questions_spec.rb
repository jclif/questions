require 'questions.rb'

describe User do

  describe "::find_by_name(fname, lname)" do
    it "returns array of user with fname and lname in db" do
      User.find_by_name()

  User#authored_questions
  User#authored_replies
  Question::find_by_author_id
  Will want to use this in User#authored_questions
  Question#author
  Question#replies
  Reply::find_by_question_id
  All replies to the question at any depth
  Use this for Question#replies
  Reply::find_by_user_id
  Use this for User#authored_replies
  Reply#author
  Reply#question
  Reply#parent_reply
  Reply#child_replies
  Only do child replies one-deep; don't find grandchild comments.