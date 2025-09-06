import pytest

import app.api.v1.endpoints.order.crud as order_crud
import app.api.v1.endpoints.order.address.crud as address_crud
from app.api.v1.endpoints.order.address.schemas import AddressCreateSchema
from app.api.v1.endpoints.order.crud import get_price_of_order
from app.api.v1.endpoints.order.schemas import OrderCreateSchema
import app.api.v1.endpoints.user.crud as user_crud
from app.api.v1.endpoints.user.schemas import UserCreateSchema
import app.api.v1.endpoints.beverage.crud as beverage_crud
from app.api.v1.endpoints.beverage.schemas import BeverageCreateSchema
from app.api.v1.endpoints.order.schemas import OrderBeverageQuantityCreateSchema
from app.database.connection import SessionLocal
from decimal import Decimal

from tests.unit.api.v1.test_order_schemas import OrderStatus


@pytest.fixture(scope='module')
def db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def test_order_create_read_delete(db):
    test_address = {
        'street': 'Test Street',
        'post_code': Decimal(64283),
        'house_number': Decimal(33),
        'country': 'Test Country',
        'town': 'Test Town',
        'first_name': 'Dick',
        'last_name': 'Johnson',
    }
    new_user_name = 'Dick'

    # Arrange: Instantiate a new user object
    user = UserCreateSchema(username=new_user_name)

    # Act: Add user to database
    db_user = user_crud.create_user(user, db)
    test_user_id = db_user.id

    # Act: create test beverage
    test_beverage_name = 'test_beverage'
    test_beverage_price = Decimal('1')
    test_beverage_description = 'test_beverage_description'
    test_beverage_stock = Decimal('10')
    test_order_status = 'PREPARING'

    beverage = BeverageCreateSchema(name=test_beverage_name,
                                    price=test_beverage_price,
                                    description=test_beverage_description,
                                    stock=test_beverage_stock)

    # Act: Add beverage to database
    db_beverage = beverage_crud.create_beverage(beverage, db)
    created_beverage_id = db_beverage.id
    test_order_beverage_quantity = Decimal(5)

    order_beverage = OrderBeverageQuantityCreateSchema(quantity=test_order_beverage_quantity,
                                                       beverage_id=created_beverage_id)

    number_of_orders_before = len(order_crud.get_all_orders(db))

    # Act: Create AddressSchema
    address_schema = AddressCreateSchema(
        street=test_address.get('street'),
        post_code=test_address.get('post_code'),
        house_number=test_address.get('house_number'),
        country=test_address.get('country'),
        town=test_address.get('town'),
        first_name=test_address.get('first_name'),
        last_name=test_address.get('last_name'),
    )

    # Act: Get Address Counts
    number_of_addresses_before = len(address_crud.get_all_addresses(db))

    # Arrange: Instantiate a new address object
    address = address_crud.create_address(address_schema, db)
    address_id = address.id

    # Assert: Number of Addresses increased by 1
    assert len(address_crud.get_all_addresses(db)) == number_of_addresses_before + 1

    # Arrange: Instantiate a new order object
    order = OrderCreateSchema(address=address,
                              user_id=test_user_id)

    # Act: Add order to database
    db_order = order_crud.create_order(order, db)
    created_order_id = db_order.id

    # Arrange: Create updated Address
    updated_test_address = {
        'street': 'Yesstreet',
        'post_code': Decimal(12345),
        'house_number': Decimal(11),
        'country': 'Nirgendwo',
        'town': 'Irgendwo',
        'first_name': 'Dünn',
        'last_name': 'Peter',
    }

    updated_test_address_schema = AddressCreateSchema(
        street=updated_test_address.get('street'),
        post_code=updated_test_address.get('post_code'),
        house_number=updated_test_address.get('house_number'),
        country=updated_test_address.get('country'),
        town=updated_test_address.get('town'),
        first_name=updated_test_address.get('first_name'),
        last_name=updated_test_address.get('last_name'),
    )

    # Act: Update Address
    address_crud.update_address(address, updated_test_address_schema, db)
    updated_address = address_crud.get_address_by_id(address.id, db)

    # Assert: Address updated
    assert updated_address.street == updated_test_address_schema.street
    assert updated_address.post_code == updated_test_address_schema.post_code
    assert updated_address.house_number == updated_test_address_schema.house_number
    assert updated_address.country == updated_test_address_schema.country
    assert updated_address.town == updated_test_address_schema.town
    assert updated_address.first_name == updated_test_address_schema.first_name
    assert updated_address.last_name == updated_test_address_schema.last_name

    # Assert: One more order in database
    orders = order_crud.get_all_orders(db)
    assert len(orders) == number_of_orders_before + 1

    order_crud.create_beverage_quantity(db_order, order_beverage, db)
    # Act: Re-read order from database
    read_order = order_crud.get_order_by_id(created_order_id, db)

    # Assert: Correct order was stored in database
    assert read_order.id == created_order_id
    assert read_order.user_id == test_user_id

    # Assert: order_status was set correctly
    order_crud.update_order_status(db_order, OrderStatus[test_order_status].value, db)
    assert db_order.order_status == test_order_status

    test_quantity = order_crud.get_beverage_quantity_by_id(created_order_id, created_beverage_id, db).quantity
    assert (test_quantity == test_order_beverage_quantity)

    # Change quantity and test again
    updated_beverage_quantity = 2
    order_crud.update_beverage_quantity_of_order(created_order_id, created_beverage_id, updated_beverage_quantity, db)
    updated_test_quantity = order_crud.get_beverage_quantity_by_id(created_order_id, created_beverage_id, db).quantity
    assert (updated_test_quantity == updated_beverage_quantity)

    assert (get_price_of_order(created_order_id, db) == updated_beverage_quantity * test_beverage_price)

    # Act: Delete Beverage from Order
    order_beverage_count = len(order_crud.get_joined_beverage_quantities_by_order(created_order_id, db))
    order_crud.delete_beverage_from_order(created_order_id, created_beverage_id, db)

    # Assert: Correct amount of beverages
    assert len(order_crud.get_joined_beverage_quantities_by_order(created_order_id, db)) == order_beverage_count - 1

    # Act: Delete order
    order_crud.delete_order_by_id(created_order_id, db)

    # Act: Delete Address
    address_crud.delete_address_by_id(address_id, db)

    # Assert: Correct number of address in database after deletion
    all_address = address_crud.get_all_addresses(db)
    assert len(all_address) == number_of_addresses_before

    # Assert: Correct number of orders in database after deletion
    orders = order_crud.get_all_orders(db)
    assert len(orders) == number_of_orders_before

    # Assert: Correct order was deleted from database
    deleted_order = order_crud.get_order_by_id(created_order_id, db)
    assert deleted_order is None

    # Assert: Correct Address was deleted from database
    deleted_address = address_crud.get_address_by_id(address_id, db)
    assert deleted_address is None

    # Delete: Temporary user and beverage
    user_crud.delete_user_by_id(test_user_id, db)
    beverage_crud.delete_beverage_by_id(created_beverage_id, db)
