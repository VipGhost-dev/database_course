Create table Roles (
	"id" int primary key generated always as identity,
	"role" varchar(50) not null check ("role" ~ '^[A-Za-zА-Яа-я\s]+$') unique
);

Create table Users (
	"id" int primary key generated always as identity,
	"name" varchar(50) not null check ("name" ~ '^[A-Za-zА-Яа-я\s]+$'),
	"secondname" varchar(50) not null check ("secondname" ~ '^[A-Za-zА-Яа-я\s]+$'),
	"thirdname" varchar(50) check ("thirdname" ~ '^[A-Za-zА-Яа-я\s]+$'),
	"status" int not null check ("status" in (0, 1)),
	"role_id" int not null check ("role_id" in (1, 2, 3)),
	constraint roles_to_users foreign key ("role_id") references Roles ("id")
);

Create table Fuel_type (
	"id" int primary key generated always as identity,
	"type" varchar(50) not null unique
);

Create table Fuel_storage (
	"id" int primary key generated always as identity,
	"fuel_type_id" int not null unique,
	"volume" int not null check ("volume" <= "volume_limit"),
	"volume_limit" int not null check ("volume_limit" >= "volume"),
	constraint fuel_type_to_fuel_storage foreign key ("fuel_type_id") references Fuel_type ("id")
);

Create table Discounts (
	"id" int primary key generated always as identity,
	"discount" int not null unique
);

Create table Discount_cards (
	"id" int primary key generated always as identity,
	"user_id" int not null unique,
	"discount_id" int not null check ("discount_id" in (1,2,3)),
	constraint users_to_discount_cards foreign key ("user_id") references Users ("id"),
	constraint dicounts_to_discount_cards foreign key ("discount_id") references Discounts ("id")
);

Create table Fuel_prices (
	"id" int primary key generated always as identity,
	"fuel_type_id" int not null check ("fuel_type_id" in (1,2,3,4)) unique,
	"price" float not null,
	constraint fuel_types_to_fuel_prices foreign key ("fuel_type_id") references Fuel_type ("id")
);

Create table Orders (
	"id" int primary key generated always as identity,
	"user_id" int not null,
	"fuel_dispenser" int not null check ("fuel_dispenser" in (1,2,3,4)),
	"fuel_type_id" int not null check ("fuel_type_id" in (1,2,3,4)),
	"volume" int not null,
	"discount_card_id" int not null,
	"cost" float not null,
	constraint users_to_orders foreign key ("user_id") references Users ("id"),
	constraint fuel_type_to_orders foreign key ("fuel_type_id") references Fuel_type ("id"),
	constraint discount_card_to_orders foreign key ("discount_card_id") references Discount_cards ("id")
);

Create table Purchase_orders (
	"id" int primary key generated always as identity,
	"fuel_type_id" int not null check ("fuel_type_id" in (1,2,3,4)),
	"volume" int not null,
	"cost" float not null,
	constraint fuel_type_to_purchase_orders foreign key ("fuel_type_id") references Fuel_type("id")
);

CREATE OR REPLACE FUNCTION calculate_order_cost()
RETURNS TRIGGER AS $$
DECLARE
    fuel_price FLOAT;
    discount_percent INT;
BEGIN
    -- Получаем цену топлива из таблицы Fuel_prices
    SELECT price INTO fuel_price
    FROM Fuel_prices
    WHERE fuel_type_id = NEW.fuel_type_id;

    -- Получаем скидку из таблицы Discounts через Discount_cards
    SELECT d.discount INTO discount_percent
    FROM Discounts d
    JOIN Discount_cards dc ON d.id = dc.discount_id
    WHERE dc.id = NEW.discount_card_id;

    -- Рассчитываем стоимость заказа
    NEW.cost := (fuel_price * NEW.volume) * (1 - discount_percent / 100.0);

    -- Возвращаем обновленную строку
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_order_cost
BEFORE INSERT OR UPDATE ON Orders
FOR EACH ROW
EXECUTE FUNCTION calculate_order_cost();

-- Заполнение таблицы Roles
INSERT INTO Roles ("role") VALUES
('Администратор'),
('Оператор'),
('Клиент');

-- Заполнение таблицы Fuel_type
INSERT INTO Fuel_type ("type") VALUES
('АИ-92'),
('АИ-95'),
('Дизель'),
('Газ');

-- Заполнение таблицы Discounts
INSERT INTO Discounts ("discount") VALUES
(5),  -- Скидка 5%
(10), -- Скидка 10%
(15); -- Скидка 15%

-- Заполнение таблицы Users
DO $$
DECLARE
    first_names TEXT[] := ARRAY['Иван', 'Петр', 'Сидор', 'Алексей', 'Дмитрий', 'Андрей', 'Сергей', 'Николай', 'Владимир', 'Михаил'];
    last_names TEXT[] := ARRAY['Иванов', 'Петров', 'Сидоров', 'Алексеев', 'Дмитриев', 'Андреев', 'Сергеев', 'Николаев', 'Владимиров', 'Михайлов'];
    middle_names TEXT[] := ARRAY['Иванович', 'Петрович', 'Сидорович', 'Алексеевич', 'Дмитриевич', 'Андреевич', 'Сергеевич', 'Николаевич', 'Владимирович', 'Михайлович'];
BEGIN
    FOR i IN 1..100000 LOOP
        INSERT INTO Users ("name", "secondname", "thirdname", "status", "role_id")
        VALUES (
            first_names[1 + floor(random() * array_length(first_names, 1))],
            last_names[1 + floor(random() * array_length(last_names, 1))],
            middle_names[1 + floor(random() * array_length(middle_names, 1))],
            floor(random() * 2), -- status (0 или 1)
            1 + floor(random() * 3) -- role_id (1, 2 или 3)
        );
    END LOOP;
END $$;

-- Заполнение таблицы Fuel_storage
DO $$
BEGIN
    FOR i IN 1..4 LOOP
        INSERT INTO Fuel_storage ("fuel_type_id", "volume", "volume_limit")
        VALUES (
            i, -- fuel_type_id (1, 2, 3, 4)
            floor(random() * 10000), -- volume
            10000 + floor(random() * 10000) -- volume_limit
        );
    END LOOP;
END $$;

-- Заполнение таблицы Discount_cards
DO $$
BEGIN
    FOR i IN 1..100000 LOOP
        INSERT INTO Discount_cards ("user_id", "discount_id")
        VALUES (
            i, -- user_id (1..100000)
            1 + floor(random() * 3) -- discount_id (1, 2 или 3)
        );
    END LOOP;
END $$;

-- Заполнение таблицы Fuel_prices
DO $$
BEGIN
    FOR i IN 1..4 LOOP
        INSERT INTO Fuel_prices ("fuel_type_id", "price")
        VALUES (
            i, -- fuel_type_id (1, 2, 3, 4)
            40 + floor(random() * 20) -- price (40..60)
        );
    END LOOP;
END $$;

-- Заполнение таблицы Orders
DO $$
DECLARE
    i INT := 1;
    user_id INT;
    fuel_dispenser INT;
    fuel_type_id INT;
    volume INT;
    discount_card_id INT;
BEGIN
    -- Цикл для вставки 100 000 записей
    FOR i IN 1..100000 LOOP
        -- Выбираем случайный user_id из существующих пользователей
        SELECT id INTO user_id FROM Users ORDER BY RANDOM() LIMIT 1;

        -- Генерируем случайный номер топливного диспенсера (1-4)
        fuel_dispenser := (floor(random() * 4) + 1);

        -- Выбираем случайный fuel_type_id из существующих типов топлива
        SELECT id INTO fuel_type_id FROM Fuel_type ORDER BY RANDOM() LIMIT 1;

        -- Генерируем случайный объем топлива (например, от 1 до 100 литров)
        volume := (floor(random() * 100) + 1);

        -- Выбираем случайный discount_card_id из существующих дисконтных карт
        SELECT id INTO discount_card_id FROM Discount_cards ORDER BY RANDOM() LIMIT 1;

        -- Вставляем данные в таблицу Orders
        INSERT INTO Orders (user_id, fuel_dispenser, fuel_type_id, volume, discount_card_id, cost)
        VALUES (user_id, fuel_dispenser, fuel_type_id, volume, discount_card_id, 0);
    END LOOP;
END $$;

-- Заполнение таблицы Purchase_orders
DO $$
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO purchase_orders ("fuel_type_id", "volume", "cost")
        VALUES (
            1 + floor(random() * 4), -- fuel_type_id (1, 2, 3, 4)
            100 + floor(random() * 1000), -- volume (100..1100)
            5000 + floor(random() * 10000) -- cost (5000..15000)
        );
    END LOOP;
END $$;