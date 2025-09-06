import uuid
import logging
from sqlalchemy.orm import Session

from app.api.v1.endpoints.topping.schemas import ToppingCreateSchema, ToppingListItemSchema
from app.database.models import Topping


def create_topping(schema: ToppingCreateSchema, db: Session):
    logging.info(f'Creating a new topping with data: {schema.dict()}')
    entity = Topping(**schema.dict())
    db.add(entity)
    db.commit()
    logging.info(f'Topping {entity.name} created with ID {entity.id}.')
    return entity


def get_topping_by_id(topping_id: uuid.UUID, db: Session):
    logging.info(f'Fetching topping with ID: {topping_id}')
    entity = db.query(Topping).filter(Topping.id == topping_id).first()
    if entity:
        logging.info(f'Topping found: {entity.name} (ID: {topping_id})')
    else:
        logging.warning(f'Topping with ID {topping_id} not found.')
    return entity


def get_topping_by_name(topping_name: str, db: Session):
    logging.info(f'Fetching topping with name: {topping_name}')
    entity = db.query(Topping).filter(Topping.name == topping_name).first()
    if entity:
        logging.info(f'Topping found: {entity.name} (ID: {entity.id})')
    else:
        logging.warning(f'Topping with name {topping_name} not found.')
    return entity


def get_all_toppings(db: Session):
    logging.info('Fetching all toppings.')
    entities = db.query(Topping).all()
    if entities:
        logging.info(f'{len(entities)} toppings found.')
        return_entities = []
        for entity in entities:
            list_item_entity = ToppingListItemSchema(
                **{'id': entity.id, 'name': entity.name, 'price': entity.price, 'description': entity.description})
            return_entities.append(list_item_entity)
        return return_entities
    logging.warning('No toppings found.')
    return entities


def update_topping(topping: Topping, changed_topping: ToppingCreateSchema, db: Session):
    logging.info(f'Updating topping with ID {topping.id} using data: {changed_topping.dict()}')
    for key, value in changed_topping.dict().items():
        setattr(topping, key, value)

    db.commit()
    db.refresh(topping)
    logging.info(f'Topping with ID {topping.id} updated successfully.')
    return topping


def delete_topping_by_id(topping_id: uuid.UUID, db: Session):
    logging.info(f'Attempting to delete topping with ID {topping_id}.')
    entity = get_topping_by_id(topping_id, db)
    if entity:
        db.delete(entity)
        db.commit()
        logging.info(f'Topping with ID {topping_id} deleted successfully.')
    else:
        logging.warning(f'Topping with ID {topping_id} not found.')
