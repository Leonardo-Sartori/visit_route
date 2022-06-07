create table customer(id integer primary key, name text, cpf_cnpj text, logradouro text, number integer, cep integer, city_id integer, country_state_id integer, phone text, tag text);
create table visit(id integer primary key, init_date text, end_date text text);
create table visit_customer(id integer primary key, visit_id integer, customer_id integer);