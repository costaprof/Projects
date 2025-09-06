import pytest

import app.api.v1.endpoints.dough.crud as dough_crud
from app.api.v1.endpoints.dough.schemas import DoughCreateSchema
from app.database.connection import SessionLocal
from decimal import Decimal


@pytest.fixture(scope='module')
def db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def test_dough_create_read_delete(db):
    new_dough_name = 'test dough'
    price_of_new_dough = Decimal('10.0')
    description_of_new_dough = 'test description'
    stock_of_new_dough = Decimal('50.0')

    number_of_doughs_before = len(dough_crud.get_all_doughs(db))

    # Arrange: Instantiate a new dough object
    dough = DoughCreateSchema(name=new_dough_name,
                              price=price_of_new_dough,
                              description=description_of_new_dough,
                              stock=stock_of_new_dough)

    # Act: Add dough to database
    db_dough = dough_crud.create_dough(dough, db)
    created_dough_id = db_dough.id

    # Assert: One more dough in database
    doughs = dough_crud.get_all_doughs(db)
    assert len(doughs) == number_of_doughs_before + 1

    # Act: Re-read dough from database
    read_dough = dough_crud.get_dough_by_id(created_dough_id, db)

    # Assert: Correct dough was stored in database
    assert read_dough.id == created_dough_id
    assert read_dough.name == new_dough_name
    assert read_dough.price == price_of_new_dough
    assert read_dough.description == description_of_new_dough
    assert read_dough.stock == stock_of_new_dough

    # Act: Delete dough
    dough_crud.delete_dough_by_id(created_dough_id, db)

    # Assert: Correct number of doughs in database after deletion
    doughs = dough_crud.get_all_doughs(db)
    assert len(doughs) == number_of_doughs_before

    # Assert: Correct dough was deleted from database
    deleted_user = dough_crud.get_dough_by_id(created_dough_id, db)
    assert deleted_user is None
