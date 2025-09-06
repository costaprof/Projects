import uuid
import logging

from sqlalchemy.orm import Session
from sqlalchemy import select
from app.api.v1.endpoints.pizza_type.schemas import \
    PizzaTypeCreateSchema, \
    PizzaTypeToppingQuantityCreateSchema
from app.database.models import PizzaType, PizzaTypeToppingQuantity, Order, Pizza, OrderStatus


def create_pizza_type(schema: PizzaTypeCreateSchema, db: Session):
    logging.info(f'Creating new pizza type with data: {schema.dict()}')
    entity = PizzaType(**schema.dict())
    db.add(entity)
    db.commit()
    logging.info(f'Pizza type {entity.id} created successfully.')
    return entity


def get_pizza_type_by_id(pizza_type_id: uuid.UUID, db: Session):
    logging.info(f'Fetching pizza type with ID: {pizza_type_id}')
    entity = db.query(PizzaType).filter(PizzaType.id == pizza_type_id).first()
    if entity:
        logging.info(f'Pizza type found: {entity}')
    else:
        logging.warning(f'Pizza type with ID {pizza_type_id} not found.')
    return entity


def get_pizza_type_by_name(pizza_type_name: str, db: Session):
    logging.info(f'Fetching pizza type with name: {pizza_type_name}')
    entity = db.query(PizzaType).filter(PizzaType.name == pizza_type_name).first()
    if entity:
        logging.info(f'Pizza type found: {entity}')
    else:
        logging.warning(f'Pizza type with name {pizza_type_name} not found.')
    return entity


def get_all_pizza_types(db: Session):
    logging.info('Fetching all pizza types.')
    entities = db.query(PizzaType).all()
    logging.info(f'{len(entities)} pizza types retrieved.')
    return entities


def update_pizza_type(pizza_type: PizzaType, changed_pizza_type: PizzaTypeCreateSchema, db: Session):
    logging.info(f'Updating pizza type {pizza_type.id} with data: {changed_pizza_type.dict()}')
    for key, value in changed_pizza_type.dict().items():
        setattr(pizza_type, key, value)

    db.commit()
    db.refresh(pizza_type)
    logging.info(f'Pizza type {pizza_type.id} updated successfully.')
    return pizza_type


def delete_pizza_type_by_id(pizza_type_id: uuid.UUID, db: Session):
    logging.info(f'Deleting pizza type with ID: {pizza_type_id}')
    entity = get_pizza_type_by_id(pizza_type_id, db)
    if entity:
        db.delete(entity)
        db.commit()
        logging.info(f'Pizza type {pizza_type_id} deleted successfully.')
    else:
        logging.warning(f'Pizza type with ID {pizza_type_id} not found.')


def create_topping_quantity(
        pizza_type: PizzaType,
        schema: PizzaTypeToppingQuantityCreateSchema,
        db: Session,
):
    logging.info(f'Adding topping quantity to pizza type {pizza_type.id} with data: {schema.dict()}')
    entity = PizzaTypeToppingQuantity(**schema.dict())
    pizza_type.toppings.append(entity)
    db.commit()
    db.refresh(pizza_type)
    logging.info(f'Topping quantity added successfully to pizza type {pizza_type.id}.')
    return entity


def get_topping_quantity_by_id(
        pizza_type_id: uuid.UUID,
        topping_id: uuid.UUID,
        db: Session,
):
    logging.info(f'Fetching topping quantity for pizza type {pizza_type_id} and topping {topping_id}')
    entity = db.query(PizzaTypeToppingQuantity) \
        .filter(PizzaTypeToppingQuantity.topping_id == topping_id,
                PizzaTypeToppingQuantity.pizza_type_id == pizza_type_id) \
        .first()
    if entity:
        logging.info(f'Topping quantity found: {entity}')
    else:
        logging.warning(f'Topping quantity not found for pizza type {pizza_type_id} and topping {topping_id}')
    return entity


def get_joined_topping_quantities_by_pizza_type(
        pizza_type_id: uuid.UUID,
        db: Session,
):
    logging.info(f'Fetching all topping quantities for pizza type {pizza_type_id}')
    entities = db.query(PizzaTypeToppingQuantity) \
        .filter(PizzaTypeToppingQuantity.pizza_type_id == pizza_type_id)
    logging.info(f'{entities.count()} topping quantities retrieved for pizza type {pizza_type_id}')
    return entities.all()


def can_delete_sauce(sauce_id: uuid.UUID, db: Session) -> bool:
    pizza_types_stmt = select(PizzaType).where(PizzaType.sauce_id == sauce_id)
    pizza_types = db.execute(pizza_types_stmt).scalars().all()

    if not pizza_types:
        return True

    pizza_type_ids = [pt.id for pt in pizza_types]

    order_stmt = (
        select(Order)
        .join(Pizza, Order.id == Pizza.order_id)
        .where(
            Pizza.pizza_type_id.in_(pizza_type_ids),
            Order.order_status != OrderStatus.COMPLETED,
        )
    )
    open_orders = db.execute(order_stmt).scalars().all()

    return len(open_orders) == 0
