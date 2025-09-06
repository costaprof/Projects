import pytest

import app.api.v1.endpoints.beverage.crud as beverage_crud
from app.api.v1.endpoints.beverage.schemas import BeverageCreateSchema
from app.database.connection import SessionLocal
from decimal import Decimal


@pytest.fixture(scope='module')
def db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def test_beverage_create_read_delete(db):
    test_beverage_name = 'test_beverage'
    test_beverage_price = Decimal('1')
    test_beverage_description = 'test_beverage_description'
    test_beverage_stock = Decimal('2')

    number_of_beverages_before = len(beverage_crud.get_all_beverages(db))

    # Arrange: Instantiate a new beverage object
    beverage = BeverageCreateSchema(name=test_beverage_name,
                                    price=test_beverage_price,
                                    description=test_beverage_description,
                                    stock=test_beverage_stock)

    # Act: Add beverage to database
    db_beverage = beverage_crud.create_beverage(beverage, db)
    created_beverage_id = db_beverage.id

    # Assert: One more beverage in database
    beverages = beverage_crud.get_all_beverages(db)
    assert len(beverages) == number_of_beverages_before + 1

    # Act: Re-read beverage from database
    read_beverage = beverage_crud.get_beverage_by_id(created_beverage_id, db)

    # Assert: Correct beverage was stored in database
    assert read_beverage.id == created_beverage_id
    assert read_beverage.name == test_beverage_name

    # Arrange: Create update Beverage
    updated_test_beverage_name = 'updated_test_beverage'
    updated_test_beverage_price = Decimal('3')
    updated_test_beverage_description = 'upated_test_beverage_description'
    updated_test_beverage_stock = Decimal('4')

    updated_beverage_schema = BeverageCreateSchema(name=updated_test_beverage_name,
                                                   price=updated_test_beverage_price,
                                                   description=updated_test_beverage_description,
                                                   stock=updated_test_beverage_stock)

    # Act: Update Beverage
    beverage_crud.update_beverage(read_beverage, updated_beverage_schema, db)

    # Assert: Check if correct Beverage has been updated
    updated_beverage = beverage_crud.get_beverage_by_id(created_beverage_id, db)
    assert updated_beverage.name == updated_test_beverage_name
    assert updated_beverage.price == updated_test_beverage_price
    assert updated_beverage.description == updated_test_beverage_description
    assert updated_beverage.stock == updated_test_beverage_stock

    # Act: Get Beverage by Name
    beverage_by_name = beverage_crud.get_beverage_by_name(updated_test_beverage_name, db)

    # Assert: Beverage by Name is the same
    assert beverage_by_name == updated_beverage

    # Act: Delete beverage
    beverage_crud.delete_beverage_by_id(created_beverage_id, db)

    # Assert: Correct number of beverage in database after deletion
    users = beverage_crud.get_all_beverages(db)
    assert len(users) == number_of_beverages_before

    # Assert: Correct beverage was deleted from database
    deleted_beverage = beverage_crud.get_beverage_by_id(created_beverage_id, db)
    assert deleted_beverage is None
