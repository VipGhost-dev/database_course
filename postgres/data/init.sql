Create table Roles (
	"id" int primary key generated always as identity,
	"role" varchar(50)
);

Create table Users (
	"id" int primary key generated always as identity,
	"name" varchar(50),
	"secondname" varchar(50),
	"thirdname" varchar(50),
	"status" int,
	"role_id" int,
	constraint roles_to_users foreign key ("role_id") references Roles ("id")
);

Create table Fuel_type (
	"id" int primary key generated always as identity,
	"type" varchar(50)
);

Create table Fuel_storage (
	"id" int primary key generated always as identity,
	"fuel_type_id" int,
	"volume" int,
	"volume_limit" int,
	constraint fuel_type_to_fuel_storage foreign key ("fuel_type_id") references Fuel_type ("id")
);

Create table Discounts (
	"id" int primary key generated always as identity,
	"discount" int
);

Create table Discount_cards (
	"id" int primary key generated always as identity,
	"user_id" int,
	"discount_id" int,
	constraint users_to_discount_cards foreign key ("user_id") references Users ("id"),
	constraint dicounts_to_discount_cards foreign key ("discount_id") references Discounts ("id")
);

Create table Fuel_prices (
	"id" int primary key generated always as identity,
	"fuel_type_id" int,
	"price" float,
	constraint fuel_types_to_fuel_prices foreign key ("fuel_type_id") references Fuel_type ("id")
);

Create table Orders (
	"id" int primary key generated always as identity,
	"user_id" int,
	"fuel_dispenser" int,
	"fuel_type_id" int,
	"volume" int,
	"discount_card_id" int,
	"cost" float,
	constraint users_to_orders foreign key ("user_id") references Users ("id"),
	constraint fuel_type_to_orders foreign key ("fuel_type_id") references Fuel_type ("id"),
	constraint discount_card_to_orders foreign key ("discount_card_id") references Discount_cards ("id")
);

Create table Purchase_orders (
	"id" int primary key generated always as identity,
	"fuel_type_id" int,
	"volume" int,
	"cost" float,
	constraint fuel_type_to_purchase_orders foreign key ("fuel_type_id") references Fuel_type("id")
);