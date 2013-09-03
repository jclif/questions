require 'questions.rb'

describe User do
  subject(:albert) { User.find_by_name("Albert", "Einstein").first }
  its(:fname) { should eq "Albert"}
  its(:lname) { should eq "Einstein"}

  before(:each) do
    raise "No import_db.sql file." unless File.exist?("#{Dir.pwd}/import_db.sql")

    system("rm school.db")
    system("cat import_db.sql | sqlite3 school.db")

  end

  after(:all) do

    system("rm school.db")

  end

  describe "::find_by_name(fname, lname)" do
    it "returns array of users in db" do
      expect(User.find_by_name("Albert", "Einstein").all? { |x| x.is_a?(User)}).to be_true
    end
  end

  describe "#create" do
    it "creates db row with ruby object"
  end

  describe "#authored_questions" do
    it "returns an array of questions" do
      expect(albert.authored_questions.all? { |x| x.is_a?(Question)}).to be_true
    end

    it "returns the correct question" do
      expect(albert.authored_questions.first.title).to eq("Title 1")
    end
  end

  describe "#authored_replies" do
    it "returns correct replies" do
      expect(albert.authored_replies.first.title).to eq('R Title 1')
    end
  end

  describe "#followed_questions" do
    it "returns followed questions" do
      expect(albert.followed_questions.first.title).to eq('Title 2')
    end
  end
end

describe Question do
  subject(:question) { Question.find_by_author_id(1).first }
  its(:title) { should eq "Title 1"}
  its(:body) { should eq "Body 1"}

  before(:each) do
    raise "No import_db.sql file." unless File.exist?("#{Dir.pwd}/import_db.sql")

    system("rm school.db")
    system("cat import_db.sql | sqlite3 school.db")

  end

  after(:all) do

    system("rm school.db")

  end

  describe "::find_by_author_id(author_id)" do
    it "returns array of questions in db" do
      expect(Question.find_by_author_id(1).all? { |x| x.is_a?(Question)}).to be_true
    end
  end

  describe "#create" do
    it "creates db row with ruby object"
  end

  describe "#author" do
    it "returns the correct author" do
      expect(question.author.first.fname).to eq("Albert")
    end
  end

  describe "#replies" do
    it "returns the correct replies" do
      expect(question.replies.first.title).to eq("R Title 1")
    end
  end

  describe "#followers" do
    it "returns the followers of a question" do
      expect(question.followers.first.fname).to eq('Kurt')
    end
  end
end

describe Reply do
  subject(:reply) { Reply.find_by_question_id(2).first }
  its(:title) { should eq "R Title 2"}
  its(:body) { should eq "R Body 2"}

  before(:each) do
    raise "No import_db.sql file." unless File.exist?("#{Dir.pwd}/import_db.sql")

    system("rm school.db")
    system("cat import_db.sql | sqlite3 school.db")

  end

  after(:all) do

    system("rm school.db")

  end

  describe "::find_by_question_id(question_id)" do
    it "returns array of replies from db" do
      expect(Reply.find_by_question_id(1).all? { |x| x.is_a?(Reply)}).to be_true
    end
  end

  describe "#create" do
    it "creates db row with ruby object"
  end

  describe "#author" do
    it "returns the correct author" do
      expect(reply.author.first.fname).to eq("Kurt")
    end
  end

  describe "#question" do
    it "returns the correct question" do
      expect(reply.question.first.title).to eq("Title 2")
    end
  end

  describe "#parent_reply" do
    it "returns the correct parent reply" do
      expect(reply.parent_reply.first).to eq(nil)
    end
  end

  describe "#child_replies" do
    it "returns the correct child replies" do
      expect(reply.child_replies.first.title).to eq("R Title 3")
    end
  end

end

describe QuestionFollower do
  describe "::followers_for_question_id(question_id)" do
    it "returns an array users who follow the question" do
      expect(QuestionFollower.followers_for_question_id(2).first.fname).to eq("Albert")
    end
  end

  describe "::followed_questions_for_user_id(user_id)" do
    it "returns an array of questions that are followed by user" do
      expect(QuestionFollower.followed_questions_for_user_id(2).first.title).to eq("Title 1")
    end
  end

end

  <<-TODO

  These involve GROUP BY and ORDER. Use JOINs to solve these, do not use Ruby iteration methods.

  QuestionFollower::most_followed_questions(n)
  Fetches the n most followed questions.
  Question::most_followed(n)
  Simple call to QuestionFollower
  Add a QuestionLike class to use your join table question_likes. Some easy queries:

  QuestionLike::likers_for_question_id(question_id)
  QuestionLike::num_likes_for_question_id(question_id)
  Don't just use QuestionLike::likers_for_question_id and count; do a SQL query to just do this.
  This is more efficient, since the SQL DB will return just the number, and not the data for each of the likes.
  QuestionLike::liked_questions_for_user_id(user_id)
  These instance methods are one-liners with the above:

  Question#likers
  Question#num_likes
  User#liked_questions
  And some harder queries with likes:

  QuestionLike::most_liked_questions(n)
  Question::most_liked(n)
  Fetches n most liked questions.
  User#average_karma
  Avg number of likes for a User's questions.
  This is the hardest query of the project.

  TODO