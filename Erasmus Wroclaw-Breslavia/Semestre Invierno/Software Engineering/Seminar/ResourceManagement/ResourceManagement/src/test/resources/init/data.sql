-- Base user entry (Admin)
INSERT INTO app_user (
    user_id,
    name,
    password,
    email,
    account_status,
    created_at,
    user_type
)
VALUES (
           1,
           'Admin User',
           '$2b$12$f57rTfdeve9qRiXhsWNIWeviiJgu/lATKerx7HKKaSbNXuAosN.Ve', -- goodlifegoodlife73
           'alvaropueblaruisanchez@gmail.com',
           'ACTIVE',
           NOW(),
           'ADMIN'
       )
    ON DUPLICATE KEY UPDATE
                         name = VALUES(name),
                         password = VALUES(password),
                                        email = VALUES(email),
                                        account_status = VALUES(account_status),
                                        created_at = VALUES(created_at),
                                        user_type = VALUES(user_type);

-- Admin-specific entry (joined inheritance)
INSERT INTO admin (
    user_id,
    admin_level,
    active,
    department_id,
    employee_code
)
VALUES (
           1, 10, TRUE, 1001, 'ADM001'
       )
    ON DUPLICATE KEY UPDATE
                         admin_level = VALUES(admin_level),
                         active = VALUES(active),
                                      department_id = VALUES(department_id),
                                      employee_code = VALUES(employee_code);

-- Base user entry (Client)
INSERT INTO app_user (
    user_id,
    name,
    password,
    email,
    account_status,
    created_at,
    user_type
)
VALUES (
           2,
           'Client User',
           '$2b$12$f57rTfdeve9qRiXhsWNIWeviiJgu/lATKerx7HKKaSbNXuAosN.Ve', -- goodlifegoodlife73
           'alvaropueblaruisanchezclient@gmail.com',
           'ACTIVE',
           NOW(),
           'CLIENT'
       )
    ON DUPLICATE KEY UPDATE
                         name = VALUES(name),
                         password = VALUES(password),
                                        email = VALUES(email),
                                        account_status = VALUES(account_status),
                                        created_at = VALUES(created_at),
                                        user_type = VALUES(user_type);

-- Client-specific entry (joined inheritance)
INSERT INTO client (
    user_id,
    client_type,
    max_active_loans,
    max_active_reservations,
    blocked_until
)
VALUES (
           2,
           'STANDARD',
           5,
           3,
           NULL
       )
    ON DUPLICATE KEY UPDATE
                         client_type = VALUES(client_type),
                         max_active_loans = VALUES(max_active_loans),
                                                max_active_reservations = VALUES(max_active_reservations),
                                                blocked_until = VALUES(blocked_until);


-- Resources (parent rows first)

INSERT INTO resource (resource_id, resource_type, available)
VALUES (101, 'BOOK', TRUE)
    ON DUPLICATE KEY UPDATE
                         available = VALUES(available),
                         resource_type = VALUES(resource_type);

INSERT INTO book (resource_id, title, author, year, isbn, copies_available)
VALUES (101, 'Clean Code', 'Robert C. Martin', 2008, '9780132350884', 3)
    ON DUPLICATE KEY UPDATE
                         title = VALUES(title),
                         author = VALUES(author),
                                      year = VALUES(year),
                                      isbn = VALUES(isbn),
                                      copies_available = VALUES(copies_available);


INSERT INTO resource (resource_id, resource_type, available)
VALUES (102, 'BOOK', TRUE)
    ON DUPLICATE KEY UPDATE
                         available = VALUES(available),
                         resource_type = VALUES(resource_type);

INSERT INTO book (resource_id, title, author, year, isbn, copies_available)
VALUES (102, 'Effective Java', 'Joshua Bloch', 2018, '9780134685991', 2)
    ON DUPLICATE KEY UPDATE
                         title = VALUES(title),
                         author = VALUES(author),
                                      year = VALUES(year),
                                      isbn = VALUES(isbn),
                                      copies_available = VALUES(copies_available);


INSERT INTO resource (resource_id, resource_type, available)
VALUES (201, 'ROOM', TRUE)
    ON DUPLICATE KEY UPDATE
                         available = VALUES(available),
                         resource_type = VALUES(resource_type);

INSERT INTO room (resource_id, room_code, name, capacity, location)
VALUES (201, 'RM101', 'Conference Room A', 20, 'Building 1, Floor 2')
    ON DUPLICATE KEY UPDATE
                         room_code = VALUES(room_code),
                         name = VALUES(name),
                                    capacity = VALUES(capacity),
                                    location = VALUES(location);


INSERT INTO resource (resource_id, resource_type, available)
VALUES (202, 'ROOM', TRUE)
    ON DUPLICATE KEY UPDATE
                         available = VALUES(available),
                         resource_type = VALUES(resource_type);

INSERT INTO room (resource_id, room_code, name, capacity, location)
VALUES (202, 'RM202', 'Study Room B', 6, 'Library Wing')
    ON DUPLICATE KEY UPDATE
                         room_code = VALUES(room_code),
                         name = VALUES(name),
                                    capacity = VALUES(capacity),
                                    location = VALUES(location);