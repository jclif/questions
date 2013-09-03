require 'debugger'; debugger
require 'singleton'
require 'sqlite3'

class QuestionDatabase < SQLite3::Database
  include Singleton

  def initialize
    # Tell the SQLite3::Database the db file to read/write.
    super("school.db")

    # Typically each row is returned as an array of values; it's more
    # convenient for us if we receive hashes indexed by column name.
    self.results_as_hash = true

    # Typically all the data is returned as strings and not parsed
    # into the appropriate type.
    self.type_translation = true
  end

end

class User

  def self.find_by_name(fname, lname)
    results = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
      users
      WHERE
        users.fname = ? AND users.lname = ?
    SQL

    results.map { |result| User.new(result) }
  end

  attr_accessor :id, :fname, :lname

  def self.all
    # execute a SELECT; result in an `Array` of `Hash`es, each
    # represents a single row.
    results = QuestionsDatabase.instance.execute("SELECT * FROM users")
    results.map { |result| User.new(result) }
  end

  def initialize(options = {})
    @id, @fname, @lname =
    options.values_at("id", "fname", "lname")
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    results = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
      replies
      WHERE
        replies.user_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def followed_questions
    QuestionFollower.followed_questions_for_user_id(id)
  end

end

class Question

  def self.find_by_author_id(author_id)
    results = QuestionDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.user_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  attr_accessor :id, :title, :body, :user_id

  def initialize(options = {})
    @id, @title, @body, @user_id =
    options.values_at("id", "title", "body", "user_id")
  end

  def author
    results = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
      users
      WHERE
        users.id = ?
    SQL

    results.map { |result| User.new(result) }
  end

  def replies
    results = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
      replies
      WHERE
        replies.question_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def followers
    QuestionFollower.followers_for_question_id(id)
  end

  def likers
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(id)
  end

end

class Reply

  def self.find_by_question_id(question_id)
    results = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
      replies
      WHERE
        replies.question_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def self.find_by_user_id(user_id)
    results = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.user_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  attr_accessor :id, :title, :body, :parent_id, :question_id, :user_id

  def initialize(options = {})
    @id, @title, @body, @parent_id, @question_id, @user_id =
    options.values_at("id", "title", "body", "parent_id", "question_id", "user_id")
  end

  def author
    results = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
    SQL

    results.map { |result| User.new(result) }
  end

  def question
    results = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def parent_reply
    results = QuestionDatabase.instance.execute(<<-SQL, parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def child_replies
    results = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.parent_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end
end

class QuestionFollower

  def self.followers_for_question_id(question_id)
    results = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_followers INNER JOIN users ON (user_id = users.id)
      WHERE
        question_id = ?
    SQL

    results.map { |result| User.new(result) }
  end

  def self.followed_questions_for_user_id(user_id)
    results = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions INNER JOIN question_followers ON (questions.id = question_id)
        INNER JOIN users ON (question_followers.user_id = users.id)
      WHERE
        users.id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

end

class QuestionLike

  def self.likers_for_question_id(question_id)
    results = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_likes INNER JOIN users ON (user_id = users.id)
      WHERE
        question_id = ?
    SQL

    results.map { |result| User.new(result) }
  end

  def self.num_likes_for_question_id(question_id)
    results = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
    COUNT(*)
      FROM
        question_likes INNER JOIN users ON (user_id = users.id)
      WHERE
        question_id = ?
    SQL

    results.first["COUNT(*)"]
  end

  def self.liked_questions_for_user_id(user_id)
    results = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions INNER JOIN question_likes ON (questions.id = question_likes.question_id)
      INNER JOIN users ON (question_likes.user_id = users.id)
      WHERE
        users.id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

end

if __FILE__ == $0
  system("rm school.db") if File.exist?("#{Dir.pwd}/school.db")
  system("cat import_db.sql | sqlite3 school.db")

  albert = User.find_by_name("Albert", "Einstein").first
  albert.authored_questions

  question = Question.find_by_author_id(1).first
  question.replies

  reply = Reply.find_by_question_id(2).first
  reply.parent_reply
  reply.child_replies

  QuestionFollower.followed_questions_for_user_id(2)

  QuestionLike.num_likes_for_question_id(2)

  system("rm school.db")
end