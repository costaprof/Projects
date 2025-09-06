import uuid
import logging
from typing import List, Optional
from decimal import Decimal

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.api.v1.endpoints.order.address.crud import create_address
from app.api.v1.endpoints.order.schemas import \
    (JoinedPizzaPizzaTypeSchema,
     OrderBeverageQuantityCreateSchema,
     OrderCreateSchema)
from app.database.models import Order, \
    Pizza, PizzaType, OrderBeverageQuantity, \
    Beverage, OrderStatus


def create_order(schema: OrderCreateSchema, db: Session):
    address = create_address(schema.address, db)
    order = Order(user_id=schema.user_id)
    order.address = address
    db.add(order)
    db.commit()
    logging.info(f'Order created with id: {order.id}')
    return order


def get_order_by_id(order_id: uuid.UUID, db: Session):
    entity = db.query(Order).filter(Order.id == order_id).first()
    if entity:
        logging.info(f'Order with id: {order_id} found')
    else:
        logging.warning(f'Order with id: {order_id} not found')
    return entity


def get_all_orders(db: Session, order_status: Optional[str] = None):
    if order_status:
        entities = db.query(Order).filter(Order.order_status == order_status).all()
    else:
        entities = db.query(Order).all()
    logging.info(f'Found {len(entities)} orders')
    return entities


def delete_order_by_id(order_id: uuid.UUID, db: Session):
    entity = get_order_by_id(order_id, db)
    if entity:
        db.delete(entity)
        db.commit()
        logging.info(f'Order with id: {order_id} deleted')
    else:
        logging.warning(f'Order with id: {order_id} not found')


def update_order_status(order: Order, changed_order: OrderStatus, db: Session):
    setattr(order, 'order_status', changed_order)

    db.commit()
    db.refresh(order)
    logging.info(f'Order status of order with id: {order.id}'
                 f'changed to {changed_order}')
    return order


def create_pizza(pizza_type: PizzaType,
                 db: Session):
    entity = Pizza()
    if pizza_type:
        entity.pizza_type_id = pizza_type.id
    db.add(entity)
    db.commit()
    logging.info(f'Pizza created with id: {entity.id}')
    return entity


def add_pizza_to_order(order: Order, pizza_type: PizzaType,
                       db: Session):
    pizza = create_pizza(pizza_type, db)
    order.pizzas.append(pizza)
    db.commit()
    db.refresh(order)
    logging.info(f'Pizza with id: {pizza.id}'
                 f'added to order with id: {order.id}')
    return pizza


def get_pizza_by_id(pizza_id: uuid.UUID, db: Session):
    entity = db.query(Pizza).filter(Pizza.id == pizza_id).first()
    if entity:
        logging.info(f'Pizza with id: {pizza_id} found')
    else:
        logging.warning(f'Pizza with id: {pizza_id} not found')
    return entity


def get_all_pizzas_of_order(order: Order, db: Session):
    pizza_types = db.query(Pizza.id, PizzaType.name,
                           PizzaType.price,
                           PizzaType.description,
                           PizzaType.dough_id) \
        .join(Pizza.pizza_type) \
        .filter(Pizza.order_id == order.id)

    returnlist: List[JoinedPizzaPizzaTypeSchema] = []
    for pizza_type in pizza_types.all():
        returnlist.append(pizza_type)

    logging.info(f'Found {len(returnlist)} pizzas for '
                 f'order with id: {order.id}')
    return returnlist


def delete_pizza_from_order(order: Order, pizza_id: uuid.UUID, db: Session):
    entity = db.query(Pizza).filter(Pizza.order_id == order.id,
                                    Pizza.id == pizza_id).first()
    if entity:
        db.delete(entity)
        db.commit()
        logging.info(f'Pizza with id: {pizza_id} deleted'
                     f'from order with id: {order.id}')
        return True
    else:
        logging.warning(f'Pizza with id: {pizza_id} not found '
                        f'in order with id: {order.id}')
        return False


def create_beverage_quantity(
        order: Order,
        schema: OrderBeverageQuantityCreateSchema,
        db: Session,
):
    entity = OrderBeverageQuantity(**schema.dict())
    order.beverages.append(entity)
    db.commit()
    db.refresh(order)
    logging.info(f'Beverage with id: {entity.beverage_id} added '
                 f'to order with id: {order.id}')
    return entity


def get_beverage_quantity_by_id(
        order_id: uuid.UUID,
        beverage_id: uuid.UUID,
        db: Session,
):
    entity = db.query(OrderBeverageQuantity) \
        .filter(OrderBeverageQuantity.beverage_id == beverage_id,
                OrderBeverageQuantity.order_id == order_id) \
        .first()
    if entity:
        logging.info(f'Beverage with id: {beverage_id} found in order '
                     f'with id: {order_id}')
    else:
        logging.warning(f'Beverage with id: {beverage_id} not found '
                        f'in order with id: {order_id}')
    return entity


def get_joined_beverage_quantities_by_order(
        order_id: uuid.UUID,
        db: Session,
):
    entities = db.query(OrderBeverageQuantity) \
        .filter(OrderBeverageQuantity.order_id == order_id)
    count = entities.count()
    logging.info(f'Found {count} beverages for order with id: {order_id}')
    return entities.all()


def update_beverage_quantity_of_order(order_id: uuid.UUID,
                                      beverage_id: uuid.UUID,
                                      new_quantity: int, db: Session):
    order_beverage = db.query(OrderBeverageQuantity).filter(
        order_id == OrderBeverageQuantity.order_id,
        beverage_id == OrderBeverageQuantity.beverage_id).first()
    if order_beverage:
        setattr(order_beverage, 'quantity', new_quantity)
        db.commit()
        db.refresh(order_beverage)
        logging.info(f'Quantity of beverage with id: {beverage_id} '
                     f'in order with id: {order_id} changed to {new_quantity}')
    return order_beverage


def delete_beverage_from_order(order_id: uuid.UUID,
                               beverage_id: uuid.UUID,
                               db: Session):
    entity = db.query(OrderBeverageQuantity).filter(
        order_id == OrderBeverageQuantity.order_id,
        beverage_id == OrderBeverageQuantity.beverage_id).first()
    if entity:
        db.delete(entity)
        db.commit()
        logging.info(f'Beverage with id: {beverage_id} deleted '
                     f'from order with id: {order_id}')
        return True
    else:
        logging.warning(f'Beverage id: {beverage_id} not found '
                        f'in orderid: {order_id}')
        return False


def get_price_of_order(
        order_id: uuid.UUID,
        db: Session,
):
    logging.info(f'Calculating total price of order with id: {order_id}')
    price_beverage: float = 0
    for row in db.query(Beverage.price, OrderBeverageQuantity.quantity) \
            .join(OrderBeverageQuantity) \
            .join(Order) \
            .filter(Order.id == order_id):
        price_beverage += (row.price * row.quantity)

    price_pizza = db.query(func.sum(PizzaType.price)) \
        .join(Pizza) \
        .join(Order) \
        .filter(Order.id == order_id).scalar()

    if price_pizza is None:
        logging.warning(f'No pizzas found for order with id: {order_id}')
        price_pizza = Decimal(0)

    if price_pizza:
        logging.info(f'Price of pizzas for order with id: {order_id} '
                     f'is {price_pizza}')
    else:
        logging.warning(f'No pizzas found for order with id: {order_id}')
        price_pizza = 0

    # Sum up total price
    total_price = price_pizza + price_beverage
    logging.info(f'Total price of order with id: {order_id} is {total_price}')
    return total_price
