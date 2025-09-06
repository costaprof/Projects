import uuid
import logging

from sqlalchemy.orm import Session

import app.api.v1.endpoints.beverage.crud as beverage_crud
from app.database.models import Beverage


def beverage_is_available(beverage_id: uuid.UUID, amount: int, db: Session):
    logging.info(f'Checking stock for: {beverage_id} amount {amount}')
    # Get Beverage
    beverage = beverage_crud.get_beverage_by_id(beverage_id, db)
    # Check if Beverage exists
    if beverage:
        # If there is enough stock return true. Stock CAN be zero
        logging.info(f'Out of stock: {beverage.stock >= amount}')
        return beverage.stock >= amount
    else:
        logging.info(f'Beverage not found: {beverage_id}')
        return False


def change_stock_of_beverage(beverage_id: uuid.UUID,
                             change_amount: int,
                             db: Session):
    # Get Beverage
    beverage = db.query(Beverage).filter(Beverage.id == beverage_id).first()

    # Check if Beverage exists and if Stock is not getting smaller than zero
    if beverage and beverage.stock + change_amount >= 0:
        setattr(beverage, 'stock', beverage.stock + change_amount)
        db.commit()
        db.refresh(beverage)
        logging.info(f'Stock of {beverage_id} changed by {change_amount}')
        return True
    logging.warning(f'Failed to change stock of {beverage_id} '
                    f'by {change_amount}')
    return False
