require 'questions.rb'

describe User do
  before(:each) do
    raise "No import_db.sql file." unless File.exist?("#{Dir.pwd}/import_db.sql")

    system("rm school.db")
    system("cat import_db.sql | sqlite3 school.db")

  end

  after(:all) do

    system("rm school.db")

  end

  describe "::find_by_name(fname, lname)" do
    it "returns array of user with fname and lname in db" do
      User.find_by_name("Albert", "Einstein")
    end
  end
end

  <<-TODO
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
    TODO