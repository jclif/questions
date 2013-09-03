
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_followers(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  parent_id INTEGER,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Albert', 'Einstein'),
  ('Kurt', 'Godel');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('Title 1', 'Body 1',
  (SELECT id FROM users WHERE fname = 'Albert')),

  ('Title 2', 'Body 2',
  (SELECT id FROM users WHERE fname = 'Kurt'));

INSERT INTO
  question_followers(question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Title 2'),
  (SELECT id FROM users WHERE fname = 'Albert')),

  ((SELECT id FROM questions WHERE title = 'Title 1'),
  (SELECT id FROM users WHERE fname = 'Kurt'));

INSERT INTO
  replies(title, body, parent_id, question_id, user_id)
VALUES
  ('R Title 1',
  'R Body 1',
  NULL,
  (SELECT id FROM questions WHERE title = 'Title 1'),
  (SELECT id FROM users WHERE fname = 'Albert')),

  ('R Title 2',
  'R Body 2',
  NULL,
  (SELECT id FROM questions WHERE title = 'Title 2'),
  (SELECT id FROM users WHERE fname = 'Kurt')),

  ('R Title 3',
  'R Body 3',
  (SELECT id FROM replies WHERE title = 'R Title 2'),
  (SELECT id FROM questions WHERE title = 'Title 2'),
  (SELECT id FROM users WHERE fname = 'Kurt'));

INSERT INTO
  question_likes(question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Title 2'),
  (SELECT id FROM users WHERE fname = 'Albert')),

  ((SELECT id FROM questions WHERE title = 'Title 1'),
  (SELECT id FROM users WHERE fname = 'Kurt'));
