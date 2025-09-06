import logging
from sqlalchemy.orm import Session

from app.database.models import PizzaType


def ingredients_are_available(pizza_type: PizzaType):
    logging.info(f'Checking stock for: {pizza_type.dough.name}')
    if pizza_type.dough.stock == 0:
        logging.info(f'Out of stock: {pizza_type.dough.name}')
        return False

    for topping_quantity in pizza_type.toppings:
        if topping_quantity.topping.stock < topping_quantity.quantity:
            logging.info(f'Out of stock: {topping_quantity.topping.name}')
            return False

    return True


def reduce_stock_of_ingredients(pizza_type: PizzaType, db: Session):
    pizza_type.dough.stock -= 1
    for topping_quantity in pizza_type.toppings:
        topping_quantity.topping.stock -= topping_quantity.quantity
    logging.info('Ingredients stock reduced.')
    db.commit()


def increase_stock_of_ingredients(pizza_type: PizzaType, db: Session):
    pizza_type.dough.stock += 1

    for topping_quantity in pizza_type.toppings:
        topping_quantity.topping.stock += topping_quantity.quantity
    logging.info('Ingredients stock increased.')
    db.commit()
