require 'debugger'; # debugger
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

  attr_accessor :id, :fname, :lname

  def self.all
    # execute a SELECT; result in an `Array` of `Hash`es, each
    # represents a single row.
    results = QuestionsDatabase.instance.execute("SELECT * FROM users")
    results.map { |result| User.new(result) }
  end

  def initialize(options = {})
    @fname, @lname =
    options.values_at("fname", "lname")
  end

  def create
    raise "already saved!" unless self.id.nil?
    params = [self.first_name, self.last_name]
    QuestionDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        users (first_name, last_name)
      VALUES
        (?, ?)
    SQL

    @id = QuestionDatabase.instance.last_insert_row_id
  end

  def self.find_by_name(fname, lname)
    results = QuestionDatabase.instance.execute(<<-SQL, self.fname, self.lname)
      SELECT
        *
      FROM
      users
      WHERE
        users.fname = ? AND users.lname = ?
    SQL
  end

  def authored_questions
    results = Question.find_by_author_id(self.id)

    results.map { |result| Question.new(result) }
  end

  def authored_replies
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

    results.map { |result| User.new(result) }
  end

  attr_accessor :id, :title, :body, :user_id

  def initialize(options = {})
    @title, @body, @user_id =
    options.values_at("title", "body", "user_id")
  end

  def create
    raise "already saved!" unless self.id.nil?
    params = [self.title, self.body, self.user_id]
    QuestionDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        users ("title", "body", "user_id")
      VALUES
        (?, ?, ?)
    SQL

    @id = QuestionDatabase.instance.last_insert_row_id
  end

  def author
    results = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
      users
      WHERE
        users.user_id = ?
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
    @title, @body, @parent_id, @question_id, @user_id =
    options.values_at("title", "body", "parent_id", "question_id", "user_id")
  end

  def create
    raise "already saved!" unless self.id.nil?
    params = [self.title, self.body, self.parent_id, self.question_id, self.user_id]
    QuestionDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        users ("title", "body", "parent_id", "question_id", "user_id")
      VALUES
        (?, ?, ?, ?, ?)
    SQL

    @id = QuestionDatabase.instance.last_insert_row_id
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
