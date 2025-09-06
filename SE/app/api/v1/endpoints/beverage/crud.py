import uuid
import logging

from sqlalchemy.orm import Session

from app.api.v1.endpoints.beverage.schemas import BeverageCreateSchema
from app.database.models import Beverage


def create_beverage(schema: BeverageCreateSchema, db: Session):
    entity = Beverage(**schema.dict())
    db.add(entity)
    db.commit()
    logging.info('Beverage created successfully {}'.format(entity))
    return entity


def get_beverage_by_id(beverage_id: uuid.UUID, db: Session):
    entity = db.query(Beverage).filter(Beverage.id == beverage_id).first()
    if entity:
        logging.info('Got beverage {} by id {} '.format(entity, beverage_id))
    else:
        logging.warning('No beverage found with id {}'.format(beverage_id))
    return entity


def get_beverage_by_name(beverage_name: str, db: Session):
    entity = db.query(Beverage).filter(Beverage.name == beverage_name).first()
    if entity:
        logging.info('Got beverage {} with name {} successfully'.format(entity, beverage_name))
    else:
        logging.warning('No beverage with name {} found'.format(beverage_name))
    return entity


def get_all_beverages(db: Session):
    all_beverages = db.query(Beverage).all()
    logging.info('Retrieved all beverages {}'.format(all_beverages))
    return db.query(Beverage).all()


def update_beverage(beverage: Beverage, changed_beverage: BeverageCreateSchema, db: Session):
    for key, value in changed_beverage.dict().items():
        setattr(beverage, key, value)

    db.commit()
    db.refresh(beverage)
    logging.info('Changed beverage {} to {}'.format(beverage, changed_beverage))
    return beverage


def delete_beverage_by_id(beverage_id: uuid.UUID, db: Session):
    entity = get_beverage_by_id(beverage_id, db)
    if entity:
        db.delete(entity)
        db.commit()
        logging.info('Beverage {} deleted successfully with id {}'.format(entity, beverage_id))
    else:
        logging.warning('No Beverage with id {} found'.format(beverage_id))
