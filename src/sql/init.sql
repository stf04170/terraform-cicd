CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    phone_number VARCHAR(15)
);

-- updated_atを自動更新するためのトリガーを作成
CREATE
OR REPLACE FUNCTION update_updated_at_column() RETURNS TRIGGER AS $ $ BEGIN NEW.updated_at = CURRENT_TIMESTAMP;

RETURN NEW;

END;

$ $ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE
UPDATE
    ON users FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

INSERT INTO
    users (
        user_id,
        name,
        email,
        password_hash,
        created_at,
        updated_at,
        phone_number
    )
VALUES
    (
        gen_random_uuid(),
        'Alice Smith',
        'alice.smith@example.com',
        'hashed_password_1',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        '123-456-7890'
    ),
    (
        gen_random_uuid(),
        'Bob Johnson',
        'bob.johnson@example.com',
        'hashed_password_2',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        '234-567-8901'
    ),
    (
        gen_random_uuid(),
        'Charlie Brown',
        'charlie.brown@example.com',
        'hashed_password_3',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        '345-678-9012'
    ),
    (
        gen_random_uuid(),
        'Diana Prince',
        'diana.prince@example.com',
        'hashed_password_4',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        '456-789-0123'
    ),
    (
        gen_random_uuid(),
        'Ethan Hunt',
        'ethan.hunt@example.com',
        'hashed_password_5',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        '567-890-1234'
    ),
    (
        gen_random_uuid(),
        'Fiona Gallagher',
        'fiona.gallagher@example.com',
        'hashed_password_6',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        NULL
    ),
    (
        gen_random_uuid(),
        'George Costanza',
        'george.costanza@example.com',
        'hashed_password_7',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        '678-901-2345'
    ),
    (
        gen_random_uuid(),
        'Hannah Baker',
        'hannah.baker@example.com',
        'hashed_password_8',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        '789-012-3456'
    ),
    (
        gen_random_uuid(),
        'Isaac Newton',
        'isaac.newton@example.com',
        'hashed_password_9',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        NULL
    ),
    (
        gen_random_uuid(),
        'Jack Sparrow',
        'jack.sparrow@example.com',
        'hashed_password_10',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        '890-123-4567'
    );