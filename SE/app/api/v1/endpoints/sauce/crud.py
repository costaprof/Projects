import uuid
import logging
from sqlalchemy.orm import Session

from app.api.v1.endpoints.sauce.schemas import SauceCreateSchema, SauceListItemSchema
from app.database.models import Sauce
from app.api.v1.endpoints.pizza_type.crud import can_delete_sauce


def create_sauce(schema: SauceCreateSchema, db: Session):
    logging.info(f'Creating a new sauce with data: {schema.dict()}')
    entity = Sauce(**schema.dict())
    db.add(entity)
    db.commit()
    logging.info(f'Sauce {entity.name} created with ID {entity.id}.')
    return entity


def get_sauce_by_id(sauce_id: uuid.UUID, db: Session):
    logging.info(f'Fetching sauce with ID: {sauce_id}')
    entity = db.query(Sauce).filter(Sauce.id == sauce_id).first()
    if entity:
        logging.info(f'Sauce found: {entity.name} (ID: {sauce_id})')
    else:
        logging.warning(f'Sauce with ID {sauce_id} not found.')
    return entity


def get_sauce_by_name(sauce_name: str, db: Session):
    logging.info(f'Fetching sauce with name: {sauce_name}')
    entity = db.query(Sauce).filter(Sauce.name == sauce_name).first()
    if entity:
        logging.info(f'Sauce found: {entity.name} (ID: {entity.id})')
    else:
        logging.warning(f'Sauce with name {sauce_name} not found.')
    return entity


def get_all_sauces(db: Session):
    logging.info('Fetching all sauces.')
    entities = db.query(Sauce).all()
    if entities:
        logging.info(f'{len(entities)} sauces found.')
        return_entities = []
        for entity in entities:
            list_item_entity = SauceListItemSchema(
                **{'id': entity.id, 'name': entity.name, 'price': entity.price, 'description': entity.description})
            return_entities.append(list_item_entity)
        return return_entities
    logging.warning('No sauces found.')
    return entities


def update_sauce(sauce: Sauce, changed_sauce: SauceCreateSchema, db: Session):
    logging.info(f'Updating sauce with ID {sauce.id} using data: {changed_sauce.dict()}')
    for key, value in changed_sauce.dict().items():
        setattr(sauce, key, value)

    db.commit()
    db.refresh(sauce)
    logging.info(f'Sauce with ID {sauce.id} updated successfully.')
    return sauce


def delete_sauce_by_id(sauce_id: uuid.UUID, db: Session):
    logging.info(f'Attempting to delete sauce with ID {sauce_id}.')

    if not can_delete_sauce(sauce_id, db):
        logging.warning(f'Sauce {sauce_id} cannot be deleted because it is used in an open order.')
        return False

    entity = get_sauce_by_id(sauce_id, db)
    if entity:
        db.delete(entity)
        db.commit()
        logging.info(f'Sauce with ID {sauce_id} deleted successfully.')
        return True
    else:
        logging.warning(f'Sauce with ID {sauce_id} not found.')
        return False
