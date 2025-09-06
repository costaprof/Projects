import pytest

import app.api.v1.endpoints.pizza_type.crud as pizza_type_crud
import app.api.v1.endpoints.dough.crud as dough_crud
from app.api.v1.endpoints.dough.schemas import DoughCreateSchema
from app.api.v1.endpoints.pizza_type.schemas import PizzaTypeCreateSchema
from app.database.connection import SessionLocal
from decimal import Decimal


@pytest.fixture(scope='module')
def db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def test_pizza_type_create_read_update_delete(db):

    # Arrange: Create Dough Schema
    dough = DoughCreateSchema(
        name='Test Dough',
        price=Decimal('10.0'),
        description='A test dough',
        stock=Decimal('50.0'),
    )

    # Act: create dough
    dough = dough_crud.create_dough(dough, db)
    dough_id = dough.id

    # Arrange: Define Pizza
    pizza_name = 'Test Pizza'
    updated_pizza_name = 'Updated Pizza'
    description = 'A test pizza'
    price = Decimal('20.0')

    pizza_type_schema = PizzaTypeCreateSchema(
        name=pizza_name,
        price=price,
        description=description,
        dough_id=dough_id,
    )

    # Act: Get Number of Pizza Types
    number_of_pizza_types_before = len(pizza_type_crud.get_all_pizza_types(db))

    # Act: Create Pizza Type
    db_pizza_type = pizza_type_crud.create_pizza_type(pizza_type_schema, db)
    created_pizza_type_id = db_pizza_type.id

    # Assert: The number of pizza types increased by one
    all_pizza_types = pizza_type_crud.get_all_pizza_types(db)
    assert len(all_pizza_types) == number_of_pizza_types_before + 1

    # Act: Read back the created pizza type
    read_pizza_type = pizza_type_crud.get_pizza_type_by_id(created_pizza_type_id, db)
    assert read_pizza_type.id == created_pizza_type_id
    assert read_pizza_type.name == pizza_name
    assert abs(read_pizza_type.price - price) < Decimal('1e-6')
    assert read_pizza_type.description == description
    assert read_pizza_type.dough_id == dough_id

    # Act: Update the pizza type using pizza_type_crud
    updated_pizza_schema = PizzaTypeCreateSchema(
        name=updated_pizza_name,
        price=price,
        description=description,
        dough_id=dough_id,
    )
    updated_pizza = pizza_type_crud.update_pizza_type(read_pizza_type, updated_pizza_schema, db)
    updated_pizza_id = updated_pizza.id

    # Assert: The pizza type was updated
    updated_read_pizza_type = pizza_type_crud.get_pizza_type_by_id(updated_pizza_id, db)
    assert updated_read_pizza_type.name == updated_pizza_name

    # Assert: Get Pizza Type by Name
    assert updated_read_pizza_type == pizza_type_crud.get_pizza_type_by_name(updated_pizza_name, db)

    # Delete the pizza type using pizza_type_crud
    pizza_type_crud.delete_pizza_type_by_id(created_pizza_type_id, db)

    # Assert: The pizza type was deleted
    remaining_pizza_types = pizza_type_crud.get_all_pizza_types(db)
    assert len(remaining_pizza_types) == number_of_pizza_types_before

    deleted_pizza_type = pizza_type_crud.get_pizza_type_by_id(created_pizza_type_id, db)
    assert deleted_pizza_type is None

    # Act: Delete the dough
    dough_crud.delete_dough_by_id(dough_id, db)
